# API Services Documentation

## نظرة عامة

تم إنشاء نظام خدمات API شامل للتعامل مع جميع واجهات برمجة التطبيقات في التطبيق. النظام مقسم إلى خدمات منفصلة لكل مجموعة من الوظائف.

## الخدمات المتاحة

### 1. AuthService
خدمة المصادقة والتحقق من الهوية

```dart
final authService = ServiceManager.instance.auth;

// تسجيل مستخدم جديد
await authService.register(
  name: 'أحمد محمد',
  email: 'ahmed@example.com',
  phone: '+962791234567',
  password: 'password123',
  confirmPassword: 'password123',
);

// تسجيل الدخول
await authService.login(
  email: 'ahmed@example.com',
  password: 'password123',
);

// إرسال رمز التحقق
await authService.sendOtp(email: 'ahmed@example.com');

// التحقق من رمز التحقق
await authService.verifyOtp(
  email: 'ahmed@example.com',
  otp: '123456',
);

// نسيت كلمة المرور
await authService.forgotPassword(email: 'ahmed@example.com');

// إعادة تعيين كلمة المرور
await authService.resetPassword(
  token: 'reset_token_here',
  newPassword: 'newpassword123',
  confirmPassword: 'newpassword123',
);

// جلب الملف الشخصي
await authService.getProfile();

// تحديث الملف الشخصي
await authService.updateProfile(
  name: 'أحمد محمد الجديد',
  phone: '+962791234568',
);

// تسجيل الخروج
await authService.logout();
```

### 2. PaymentService
خدمة المدفوعات والمعاملات المالية

```dart
final paymentService = ServiceManager.instance.payment;

// جلب مدفوعات المستخدم
await paymentService.getUserPayments();

// جلب المدفوعات المعلقة
await paymentService.getPendingPayments();

// جلب تاريخ المدفوعات
await paymentService.getPaymentHistory();

// تمديد موعد الدفع
await paymentService.extendDueDate(
  paymentId: 'payment_123',
  days: 7,
);

// دفع مبلغ
await paymentService.payAmount(
  paymentId: 'payment_123',
  amount: 150.0,
  paymentMethod: 'credit_card',
);

// إنشاء جلسة دفع
await paymentService.createPaymentSession(
  amount: 500.0,
  currency: 'JOD',
  paymentMethod: 'bank_transfer',
);

// معالجة الدفع
await paymentService.processPayment(
  sessionId: 'session_123',
  paymentDetails: {
    'cardNumber': '1234567890123456',
    'expiryDate': '12/25',
    'cvv': '123',
  },
);

// جلب تفاصيل المعاملة
await paymentService.getTransactionDetails(
  transactionId: 'transaction_123',
);
```

### 3. HomeService
خدمة الصفحة الرئيسية والبحث

```dart
final homeService = ServiceManager.instance.home;

// جلب بيانات الصفحة الرئيسية
await homeService.getHomeData();

// جلب جميع المتاجر
await homeService.getAllStores();

// جلب تفاصيل متجر
await homeService.getStoreDetails(1);

// جلب منتجات متجر
await homeService.getStoreProducts(1);

// جلب جميع العروض
await homeService.getAllOffers();

// جلب العروض المميزة
await homeService.getFeaturedOffers();

// البحث في المتاجر
await homeService.searchStores('إلكترونيات');

// البحث في المنتجات
await homeService.searchProducts('هاتف ذكي');
```

### 4. NotificationService
خدمة الإشعارات

```dart
final notificationService = ServiceManager.instance.notification;

// جلب جميع الإشعارات
await notificationService.getAllNotifications();

// تحديد إشعار كمقروء
await notificationService.markNotificationAsRead(1);

// تحديد جميع الإشعارات كمقروءة
await notificationService.markAllNotificationsAsRead();

// حذف إشعار
await notificationService.deleteNotification(1);
```

### 5. StoreService
خدمة تكامل المتاجر

```dart
final storeService = ServiceManager.instance.store;

// طلب تكامل متجر
await storeService.requestStoreIntegration(
  storeName: 'متجر الإلكترونيات',
  storeUrl: 'https://electronics-store.com',
  contactEmail: 'contact@electronics-store.com',
  contactPhone: '+962791234567',
  description: 'متجر متخصص في الإلكترونيات',
);

// جلب حالة التكامل
await storeService.getIntegrationStatus('request_123');

// تفعيل تكامل المتجر
await storeService.activateStoreIntegration(
  requestId: 'request_123',
  activationCode: 'ACT123',
);

// جلب قائمة التكاملات
await storeService.getIntegrationList();

// تحديث إعدادات التكامل
await storeService.updateIntegrationSettings(
  storeId: 1,
  settings: {
    'autoSync': true,
    'syncInterval': 30,
    'notifications': true,
  },
);

// تحديث رابط الويب هوك
await storeService.updateWebhookUrl(
  storeId: 1,
  webhookUrl: 'https://my-store.com/webhook',
);
```

## كيفية الاستخدام في التطبيق

### 1. استيراد ServiceManager

```dart
import 'package:bnpl/services/service_manager.dart';
```

### 2. الحصول على الخدمة المطلوبة

```dart
final services = ServiceManager.instance;
```

### 3. استخدام الخدمة في Widget

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _services = ServiceManager.instance;
  Map<String, dynamic>? homeData;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final response = await _services.home.getHomeData();
      
      if (response['success']) {
        setState(() {
          homeData = response['data'];
        });
      } else {
        // معالجة الخطأ
        print('خطأ: ${response['error']}');
      }
    } catch (e) {
      print('خطأ في الاتصال: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الصفحة الرئيسية')),
      body: homeData == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // عرض البيانات هنا
              ],
            ),
    );
  }
}
```

## إدارة التوكن

يتم إدارة توكن المصادقة تلقائياً من خلال `ApiService`. عند تسجيل الدخول بنجاح، يتم حفظ التوكن تلقائياً. عند تسجيل الخروج، يتم حذف التوكن.

## معالجة الأخطاء

جميع الخدمات تعيد استجابة موحدة تحتوي على:

```dart
{
  'success': bool,        // نجاح أو فشل العملية
  'data': dynamic,        // البيانات في حالة النجاح
  'error': String,        // رسالة الخطأ في حالة الفشل
  'statusCode': int,      // رمز الحالة HTTP
}
```

## إعدادات التطوير

- **Base URL**: `http://10.0.2.2:3000` (للمحاكي)
- **Timeout**: 30 ثانية
- **Logging**: مفعل في وضع التطوير

## ملاحظات مهمة

1. تأكد من تشغيل الـ mock server قبل استخدام التطبيق
2. استخدم `10.0.2.2` للمحاكي و `localhost` للجهاز الفعلي
3. جميع الطلبات تحتوي على headers مناسبة تلقائياً
4. يتم إدارة التوكن تلقائياً عند تسجيل الدخول والخروج
