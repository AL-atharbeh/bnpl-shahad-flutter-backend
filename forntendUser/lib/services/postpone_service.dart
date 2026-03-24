import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة لإدارة ميزة تأجيل القسط المجاني
/// التأجيل متاح مرة واحدة في الشهر لأي قسط
class PostponeService with ChangeNotifier {
  static const String _keyLastPostponeDate = 'last_postpone_date';
  static const String _keyLastPostponedInstallment = 'last_postponed_installment';
  
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  
  // تاريخ آخر استخدام للتأجيل المجاني≈
  DateTime? _lastPostponeDate;
  String? _lastPostponedInstallmentId;
  
  bool get isInitialized => _isInitialized;
  DateTime? get lastPostponeDate => _lastPostponeDate;
  String? get lastPostponedInstallmentId => _lastPostponedInstallmentId;
  
  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    // تحميل تاريخ آخر استخدام
    final lastDateStr = _prefs?.getString(_keyLastPostponeDate);
    if (lastDateStr != null) {
      _lastPostponeDate = DateTime.tryParse(lastDateStr);
    }
    
    _lastPostponedInstallmentId = _prefs?.getString(_keyLastPostponedInstallment);
    
    _isInitialized = true;
    notifyListeners();
  }
  
  /// التحقق من إمكانية استخدام التأجيل المجاني
  /// يمكن استخدامه مرة واحدة في الشهر فقط
  bool canPostponeForFree(String installmentId) {
    if (_lastPostponeDate == null) return true;
    
    final now = DateTime.now();
    final daysSinceLastPostpone = now.difference(_lastPostponeDate!).inDays;
    
    // إذا مر أكثر من 30 يوم، يمكن استخدام التأجيل مرة أخرى
    return daysSinceLastPostpone >= 30;
  }
  
  /// الحصول على عدد الأيام المتبقية حتى يمكن استخدام التأجيل مرة أخرى
  int getDaysUntilNextPostpone() {
    if (_lastPostponeDate == null) return 0;
    
    final now = DateTime.now();
    final daysSinceLastPostpone = now.difference(_lastPostponeDate!).inDays;
    final daysRemaining = 30 - daysSinceLastPostpone;
    
    return daysRemaining > 0 ? daysRemaining : 0;
  }
  
  /// تأجيل قسط مجاناً
  /// يرجع [true] إذا تم التأجيل بنجاح، [false] إذا كان قد تم استخدام التأجيل المجاني في آخر 30 يوم
  Future<bool> postponeForFree(String installmentId, {
    required String merchantName,
    required double amount,
    String? originalDueDate,
    String? newDueDate,
  }) async {
    if (!canPostponeForFree(installmentId)) {
      return false;
    }
    
    // تسجيل تاريخ الاستخدام الحالي
    _lastPostponeDate = DateTime.now();
    _lastPostponedInstallmentId = installmentId;
    
    // حفظ في التخزين المحلي
    await _prefs?.setString(
      _keyLastPostponeDate,
      _lastPostponeDate!.toIso8601String(),
    );
    await _prefs?.setString(
      _keyLastPostponedInstallment,
      installmentId,
    );
    
    debugPrint('✅ Postponed installment for free: $installmentId ($merchantName)');
    debugPrint('   Next postpone available after: ${_lastPostponeDate!.add(const Duration(days: 30))}');
    notifyListeners();
    
    return true;
  }
  
  /// إلغاء التأجيل الأخير (للاختبار أو التراجع)
  Future<void> cancelLastPostpone() async {
    _lastPostponeDate = null;
    _lastPostponedInstallmentId = null;
    
    await _prefs?.remove(_keyLastPostponeDate);
    await _prefs?.remove(_keyLastPostponedInstallment);
    
    debugPrint('🔄 Cancelled last postpone');
    notifyListeners();
  }
  
  /// مسح كل البيانات (للاختبار فقط)
  Future<void> clearAll() async {
    _lastPostponeDate = null;
    _lastPostponedInstallmentId = null;
    
    await _prefs?.remove(_keyLastPostponeDate);
    await _prefs?.remove(_keyLastPostponedInstallment);
    
    debugPrint('🗑️ Cleared all postpone data');
    notifyListeners();
  }
}

