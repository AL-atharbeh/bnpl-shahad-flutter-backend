import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

/// نموذج بيانات عملية النقاط
class PointsTransaction {
  final String id;
  final int points;
  final PointsTransactionType type;
  final DateTime timestamp;
  final String? description;
  final double? relatedPaymentAmount;

  PointsTransaction({
    required this.id,
    required this.points,
    required this.type,
    required this.timestamp,
    this.description,
    this.relatedPaymentAmount,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'points': points,
    'type': type.toString(),
    'timestamp': timestamp.toIso8601String(),
    'description': description,
    'relatedPaymentAmount': relatedPaymentAmount,
  };

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    // Handle backend entity format
    if (json.containsKey('transactionType')) {
      return PointsTransaction(
        id: json['id']?.toString() ?? '',
        points: (json['points'] as num?)?.toInt()?.abs() ?? 0,
        type: json['transactionType'] == 'earned' 
            ? PointsTransactionType.earned 
            : PointsTransactionType.redeemed,
        timestamp: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt']) 
            : DateTime.now(),
        description: json['description'] as String?,
        relatedPaymentAmount: (json['amount'] as num?)?.toDouble(),
      );
    }
    
    // Original local format support
    return PointsTransaction(
      id: json['id'] as String,
      points: json['points'] as int,
      type: PointsTransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => PointsTransactionType.earned,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
      relatedPaymentAmount: json['relatedPaymentAmount'] as double?,
    );
  }
}

/// نوع عملية النقاط
enum PointsTransactionType {
  earned,   // نقاط مكتسبة
  redeemed, // نقاط مستبدلة
  expired,  // نقاط منتهية
}

/// خدمة إدارة نظام النقاط
class PointsService extends ChangeNotifier {
  static const String _pointsKey = 'user_points';
  static const String _transactionsKey = 'points_transactions';
  static const String _totalEarnedKey = 'total_earned_points';
  
  final ApiService _apiService = ApiService();
  
  // معدل كسب النقاط: 1 نقطة لكل 1 دينار مدفوع (افتراضي، لكن السيرفر يكافئ 1 لكل جلسة)
  static const double pointsPerDinar = 1.0;
  
  // معدل استبدال النقاط: 100 نقطة = 1 دينار
  static const int pointsPerDinarValue = 100;

  int _currentPoints = 0;
  int _totalEarnedPoints = 0;
  List<PointsTransaction> _transactions = [];
  bool _isInitialized = false;
  bool _isLoading = false;

  int get currentPoints => _currentPoints;
  int get totalEarnedPoints => _totalEarnedPoints;
  List<PointsTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// تهيئة الخدمة وتحميل البيانات من السيرفر
  Future<void> initialize() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. تحميل رصيد النقاط الحالي
      final pointsResponse = await _apiService.get('/rewards/points');
      if (pointsResponse['success'] == true) {
        // Backend returns: { success: true, data: { currentPoints: N } }
        // ApiService puts it in: pointsResponse['data']
        final backendData = pointsResponse['data'];
        final data = backendData['data'] ?? backendData;
        _currentPoints = (data['currentPoints'] as num?)?.toInt() ?? 0;
      }
      
      // 2. تحميل تاريخ العمليات
      final historyResponse = await _apiService.get('/rewards/history');
      if (historyResponse['success'] == true) {
        // Backend returns: { success: true, data: [...] }
        final backendData = historyResponse['data'];
        final List<dynamic> historyData = backendData['data'] is List 
            ? backendData['data'] 
            : (backendData is List ? backendData : []);
            
        _transactions = historyData
            .map((json) => PointsTransaction.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // حساب إجمالي النقاط المكتسبة من التاريخ
        _totalEarnedPoints = _transactions
            .where((t) => t.type == PointsTransactionType.earned)
            .fold(0, (sum, t) => sum + t.points);
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      
      debugPrint('✅ PointsService initialized with $_currentPoints points');
    } catch (e) {
      debugPrint('❌ Error initializing PointsService from API: $e');
      // محاولة التحميل من SharedPreferences كاحتياطي
      await _loadFromLocal();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentPoints = prefs.getInt(_pointsKey) ?? 0;
      _totalEarnedPoints = prefs.getInt(_totalEarnedKey) ?? 0;
      
      final transactionsJson = prefs.getString(_transactionsKey);
      if (transactionsJson != null) {
        final List<dynamic> decoded = jsonDecode(transactionsJson);
        _transactions = decoded
            .map((json) => PointsTransaction.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Error loading from local: $e');
    }
  }

  /// حساب النقاط من مبلغ الدفع
  int calculatePointsFromPayment(double paymentAmount) {
    return (paymentAmount * pointsPerDinar).floor();
  }

  /// إضافة نقاط من عملية دفع
  Future<int> addPointsFromPayment({
    required double paymentAmount,
    String? description,
  }) async {
    final pointsEarned = calculatePointsFromPayment(paymentAmount);
    
    if (pointsEarned <= 0) return 0;

    final transaction = PointsTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: pointsEarned,
      type: PointsTransactionType.earned,
      timestamp: DateTime.now(),
      description: description,
      relatedPaymentAmount: paymentAmount,
    );

    _currentPoints += pointsEarned;
    _totalEarnedPoints += pointsEarned;
    _transactions.insert(0, transaction);

    await _saveToPreferences();
    notifyListeners();

    debugPrint('✅ Earned $pointsEarned points from payment of JD $paymentAmount');
    return pointsEarned;
  }

  /// استبدال النقاط
  Future<bool> redeemPoints(int pointsToRedeem, {String? description}) async {
    if (pointsToRedeem <= 0) {
      debugPrint('❌ Invalid points amount: $pointsToRedeem');
      return false;
    }

    if (pointsToRedeem > _currentPoints) {
      debugPrint('❌ Not enough points. Current: $_currentPoints, Requested: $pointsToRedeem');
      return false;
    }

    final transaction = PointsTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: pointsToRedeem,
      type: PointsTransactionType.redeemed,
      timestamp: DateTime.now(),
      description: description,
    );

    _currentPoints -= pointsToRedeem;
    _transactions.insert(0, transaction);

    await _saveToPreferences();
    notifyListeners();

    debugPrint('✅ Redeemed $pointsToRedeem points');
    return true;
  }

  /// حساب القيمة المالية للنقاط
  double getPointsValue(int points) {
    return points / pointsPerDinarValue;
  }

  /// الحصول على العمليات المكتسبة فقط
  List<PointsTransaction> get earnedTransactions {
    return _transactions
        .where((t) => t.type == PointsTransactionType.earned)
        .toList();
  }

  /// الحصول على العمليات المستبدلة فقط
  List<PointsTransaction> get redeemedTransactions {
    return _transactions
        .where((t) => t.type == PointsTransactionType.redeemed)
        .toList();
  }

  /// مسح كل البيانات (للاختبار فقط)
  Future<void> clearAllData() async {
    _currentPoints = 0;
    _totalEarnedPoints = 0;
    _transactions.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pointsKey);
    await prefs.remove(_totalEarnedKey);
    await prefs.remove(_transactionsKey);

    notifyListeners();
    debugPrint('✅ All points data cleared');
  }

  /// حفظ البيانات في SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt(_pointsKey, _currentPoints);
      await prefs.setInt(_totalEarnedKey, _totalEarnedPoints);
      
      final transactionsJson = jsonEncode(
        _transactions.map((t) => t.toJson()).toList(),
      );
      await prefs.setString(_transactionsKey, transactionsJson);
    } catch (e) {
      debugPrint('❌ Error saving points data: $e');
    }
  }

  /// إضافة نقاط يدوياً (للاختبار)
  Future<void> addPointsManually(int points, {String? description}) async {
    final transaction = PointsTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      points: points,
      type: PointsTransactionType.earned,
      timestamp: DateTime.now(),
      description: description ?? 'نقاط يدوية',
    );

    _currentPoints += points;
    _totalEarnedPoints += points;
    _transactions.insert(0, transaction);

    await _saveToPreferences();
    notifyListeners();
  }
}

