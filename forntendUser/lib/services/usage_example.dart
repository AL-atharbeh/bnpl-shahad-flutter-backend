// مثال على كيفية استخدام الـ Services في التطبيق
// يمكنك حذف هذا الملف بعد فهم كيفية الاستخدام

import 'service_manager.dart';

class ApiUsageExample {
  final _services = ServiceManager.instance;

  // مثال على تسجيل الدخول
  Future<void> loginExample() async {
    try {
      final response = await _services.auth.login(
        email: 'user@example.com',
        password: 'password123',
      );

      if (response['success']) {
        print('تم تسجيل الدخول بنجاح');
        print('Token: ${response['data']['token']}');
      } else {
        print('فشل تسجيل الدخول: ${response['error']}');
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
    }
  }

  // مثال على جلب بيانات الصفحة الرئيسية
  Future<void> getHomeDataExample() async {
    try {
      final response = await _services.home.getHomeData();

      if (response['success']) {
        final data = response['data'];
        print('الدفعات المعلقة: ${data['pendingPayments']}');
        print('أفضل المتاجر: ${data['topStores']}');
        print('أفضل العروض: ${data['bestOffers']}');
      } else {
        print('فشل جلب البيانات: ${response['error']}');
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
    }
  }

  // مثال على جلب المدفوعات المعلقة
  Future<void> getPendingPaymentsExample() async {
    try {
      final response = await _services.payment.getPendingPayments();

      if (response['success']) {
        final payments = response['data']['payments'];
        print('عدد المدفوعات المعلقة: ${payments.length}');
        
        for (var payment in payments) {
          print('المبلغ: ${payment['amount']} JD');
          print('تاريخ الاستحقاق: ${payment['dueDate']}');
        }
      } else {
        print('فشل جلب المدفوعات: ${response['error']}');
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
    }
  }

  // مثال على جلب الإشعارات
  Future<void> getNotificationsExample() async {
    try {
      final response = await _services.notification.getAllNotifications();

      if (response['success']) {
        final notifications = response['data']['notifications'];
        print('عدد الإشعارات: ${notifications.length}');
        
        for (var notification in notifications) {
          print('العنوان: ${notification['title']}');
          print('الرسالة: ${notification['message']}');
          print('مقروءة: ${notification['isRead']}');
        }
      } else {
        print('فشل جلب الإشعارات: ${response['error']}');
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
    }
  }

  // مثال على البحث في المتاجر
  Future<void> searchStoresExample() async {
    try {
      final response = await _services.home.searchStores('إلكترونيات');

      if (response['success']) {
        final stores = response['data']['stores'];
        print('نتائج البحث: ${stores.length} متجر');
        
        for (var store in stores) {
          print('اسم المتجر: ${store['name']}');
          print('الوصف: ${store['description']}');
        }
      } else {
        print('فشل البحث: ${response['error']}');
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
    }
  }

  // مثال على تمديد موعد الدفع
  Future<void> extendPaymentExample() async {
    try {
      final response = await _services.payment.extendDueDate(
        paymentId: 'payment_123',
        days: 7,
      );

      if (response['success']) {
        print('تم تمديد موعد الدفع بنجاح');
        print('الموعد الجديد: ${response['data']['newDueDate']}');
      } else {
        print('فشل تمديد الموعد: ${response['error']}');
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
    }
  }
}
