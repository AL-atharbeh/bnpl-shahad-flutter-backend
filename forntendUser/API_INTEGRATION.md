# ربط Flutter مع Mock Server

## نظرة عامة

تم ربط تطبيق Flutter مع Mock Server للاختبار والتطوير.

## 🔧 الإعدادات

### BASE_URL
```dart
// lib/config/env/env_dev.dart
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

### ملاحظات مهمة:
- **`10.0.2.2`**: عنوان IP خاص يستخدمه Android Emulator للاتصال بالجهاز المضيف
- **`3000`**: منفذ Mock Server
- **`/api/v1`**: مسار API

## 📱 كيفية الاتصال

### 1. تشغيل Mock Server
```bash
cd api/mock-server
npm run dev
```

### 2. تشغيل Flutter App
```bash
cd forntendUser
flutter run
```

### 3. التأكد من الاتصال
- Mock Server يعمل على: `http://localhost:3000`
- Flutter App يتصل عبر: `http://10.0.2.2:3000/api/v1`

## 🛠️ API Service

### الملف: `lib/services/api_service.dart`

#### الميزات:
- ✅ Singleton pattern
- ✅ Generic HTTP methods (GET, POST, PUT, DELETE)
- ✅ Error handling
- ✅ Timeout management
- ✅ Logging support
- ✅ Authentication token management

#### الاستخدام:
```dart
final apiService = ApiService();

// GET request
final response = await apiService.get('/stores');

// POST request
final response = await apiService.post('/auth/login', {
  'email': 'ahmed@example.com',
  'password': 'password123'
});
```

## 📋 الـ Endpoints المتاحة

### Authentication
- `POST /auth/login` - تسجيل الدخول
- `POST /auth/register` - إنشاء حساب

### Stores
- `GET /stores` - قائمة المتاجر
- `GET /stores/{id}` - تفاصيل متجر
- `GET /stores/{storeId}/products` - منتجات متجر

### Products
- `GET /products` - قائمة المنتجات
- `GET /products/{id}` - تفاصيل منتج

### Store Integration
- `POST /stores/integration/request` - طلب انضمام متجر
- `GET /stores/integration/status/{requestId}` - فحص حالة طلب الانضمام
- `POST /stores/integration/activate` - تفعيل التكامل
- `GET /stores/integration/list` - قائمة المتاجر المتكاملة
- `PUT /stores/integration/{storeId}/settings` - تحديث إعدادات التكامل
- `POST /stores/integration/{storeId}/webhook` - استقبال webhooks

### Payment Integration
- `POST /payment/session/create` - إنشاء جلسة دفع
- `POST /payment/session/{sessionId}/process` - معالجة الدفع
- `GET /payment/transaction/{transactionId}` - تفاصيل المعاملة

### Notifications
- `GET /notifications` - قائمة الإشعارات
- `PUT /notifications/{id}/read` - تحديد إشعار كمقروء

### البيانات الأخرى
- `GET /categories` - الفئات
- `GET /cart` - سلة التسوق
- `GET /orders` - الطلبات
- `GET /payments` - المدفوعات
- `GET /bnpl_plans` - خطط التقسيط
- `GET /bnpl_installments` - الأقساط
- `GET /offers` - العروض
- `GET /reviews` - التقييمات
- `GET /addresses` - العناوين
- `GET /wishlist` - المفضلة
- `GET /search_history` - سجل البحث
- `GET /support_tickets` - تذاكر الدعم
- `GET /faq` - الأسئلة الشائعة

## 🔍 أمثلة على الاستخدام

### 1. تسجيل الدخول
```dart
final response = await ApiService().post(ApiEndpoints.login, {
  'email': 'ahmed@example.com',
  'password': 'password123'
});

if (response['success']) {
  final userData = response['data']['data']['user'];
  final token = response['data']['data']['token'];
  
  // حفظ token للمصادقة
  ApiService().setAuthToken(token);
  
  // الانتقال للصفحة الرئيسية
  AppRouter.navigateToHome(context);
} else {
  // عرض رسالة خطأ
  print('Login failed: ${response['error']}');
}
```

### 2. جلب قائمة المتاجر
```dart
final response = await ApiService().get(ApiEndpoints.stores);

if (response['success']) {
  final stores = response['data']['data'] as List;
  // استخدام البيانات
  print('Found ${stores.length} stores');
} else {
  print('Failed to fetch stores: ${response['error']}');
}
```

### 3. إنشاء جلسة دفع
```dart
final response = await ApiService().post(ApiEndpoints.paymentSessionCreate, {
  'storeId': 1,
  'orderId': 'zara_order_456',
  'amount': 150.00,
  'currency': 'JOD',
  'items': [
    {
      'productId': 'zara_product_789',
      'name': 'فستان أسود',
      'quantity': 1,
      'price': 150.00
    }
  ],
  'userCountry': 'JO',
  'userCurrency': 'JOD'
});

if (response['success']) {
  final sessionData = response['data']['data'];
  final sessionId = sessionData['sessionId'];
  // استخدام sessionId للمتابعة
} else {
  print('Failed to create payment session: ${response['error']}');
}
```

## 🚨 معالجة الأخطاء

### أنواع الأخطاء:
1. **Network Errors**: مشاكل في الاتصال
2. **HTTP Errors**: أخطاء من الخادم (4xx, 5xx)
3. **JSON Errors**: أخطاء في تنسيق البيانات
4. **Timeout Errors**: انتهاء مهلة الاتصال

### معالجة الأخطاء:
```dart
final response = await ApiService().get('/stores');

if (response['success']) {
  // نجح الطلب
  handleSuccess(response['data']);
} else {
  // فشل الطلب
  handleError(response['error'], response['statusCode']);
}
```

## 🔧 الإعدادات المتقدمة

### Timeout
```dart
// lib/config/env/env_dev.dart
static const int timeoutDuration = 30000; // 30 seconds
```

### Logging
```dart
// lib/config/env/env_dev.dart
static const bool enableLogging = true;
static const String logLevel = 'DEBUG';
```

### Authentication
```dart
// إضافة token للمصادقة
ApiService().setAuthToken('your-jwt-token');

// إزالة token
ApiService().clearAuthToken();
```

## 📱 اختبار الاتصال

### 1. اختبار بسيط
```dart
// في أي صفحة
void testConnection() async {
  final response = await ApiService().get('/stores');
  print('Connection test: ${response['success']}');
  if (response['success']) {
    print('✅ Connected to Mock Server successfully!');
  } else {
    print('❌ Connection failed: ${response['error']}');
  }
}
```

### 2. اختبار تسجيل الدخول
```dart
void testLogin() async {
  final response = await ApiService().post(ApiEndpoints.login, {
    'email': 'ahmed@example.com',
    'password': 'password123'
  });
  
  if (response['success']) {
    print('✅ Login successful!');
    print('User: ${response['data']['data']['user']['name']}');
  } else {
    print('❌ Login failed: ${response['error']}');
  }
}
```

## 🔄 الخطوات التالية

### 1. ربط الصفحات بالـ API
- تحديث صفحة تسجيل الدخول لاستخدام API حقيقي
- تحديث صفحة التسجيل لاستخدام API حقيقي
- ربط الصفحة الرئيسية بجلب البيانات من API

### 2. إضافة State Management
- استخدام Provider لإدارة حالة المستخدم
- حفظ token في SharedPreferences
- إدارة حالة تسجيل الدخول

### 3. تحسينات
- إضافة loading indicators
- تحسين معالجة الأخطاء
- إضافة retry mechanism
- تحسين UX

## 📋 ملاحظات مهمة

### الأمان
- لا تستخدم HTTP في الإنتاج
- استخدم HTTPS دائماً
- احمي البيانات الحساسة

### الأداء
- استخدم caching للبيانات
- قلل عدد الطلبات
- استخدم pagination للقوائم الكبيرة

### التطوير
- استخدم logging للتطوير
- اختبر جميع الـ endpoints
- تأكد من معالجة الأخطاء
