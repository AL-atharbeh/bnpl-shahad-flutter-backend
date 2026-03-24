import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  
  // معدل كسب النقاط: 1 نقطة لكل 1 دينار مدفوع
  static const double pointsPerDinar = 1.0;
  
  // معدل استبدال النقاط: 100 نقطة = 1 دينار
  static const int pointsPerDinarValue = 100;

  int _currentPoints = 0;
  int _totalEarnedPoints = 0;
  List<PointsTransaction> _transactions = [];
  bool _isInitialized = false;

  int get currentPoints => _currentPoints;
  int get totalEarnedPoints => _totalEarnedPoints;
  List<PointsTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isInitialized => _isInitialized;

  /// تهيئة الخدمة وتحميل البيانات
  Future<void> initialize() async {
    if (_isInitialized) return;

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
        // ترتيب العمليات من الأحدث إلى الأقدم
        _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing PointsService: $e');
      _isInitialized = true;
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

