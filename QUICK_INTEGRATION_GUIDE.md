# دليل الربط السريع - BNPL

## 🚀 البدء السريع

### 1. تشغيل الباك اند

```bash
cd backend
npm install
npm run start:dev
```

الباك اند يعمل على: `http://localhost:3000`
Swagger Docs: `http://localhost:3000/api/docs`

### 2. تحديث إعدادات Flutter

**للـ Android Emulator**:
```dart
// forntendUser/lib/config/env/env_dev.dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

**للـ iOS Simulator**:
```dart
static const String baseUrl = 'http://localhost:3000';
```

**للجهاز الحقيقي**:
```dart
static const String baseUrl = 'http://YOUR_IP:3000';
// مثال: 'http://192.168.1.100:3000'
```

### 3. تشغيل Flutter

```bash
cd forntendUser
flutter pub get
flutter run
```

---

## 📱 استخدام الخدمات في Flutter

### المصادقة (Authentication)

```dart
import 'package:bnpl/services/auth_service.dart';

final authService = AuthService();

// 1. التحقق من رقم الهاتف
final checkResult = await authService.checkIfUserExists('77777777');
if (checkResult['success']) {
  final exists = checkResult['exists'];
  print('User exists: $exists');
}

// 2. إرسال OTP
final otpResult = await authService.sendOTPToPhone('77777777');
if (otpResult['success']) {
  print('OTP sent successfully');
}

// 3. التحقق من OTP
final verifyResult = await authService.verifyOTPCode('77777777', '123456');
if (verifyResult['success']) {
  if (verifyResult['userExists'] == true) {
    // المستخدم موجود - تم تسجيل الدخول
    final token = verifyResult['token'];
    print('Logged in with token: $token');
  } else {
    // مستخدم جديد - يحتاج إكمال الملف الشخصي
    print('User needs to complete profile');
  }
}

// 4. إنشاء حساب جديد
final createResult = await authService.createAccountWithProfile(
  phoneNumber: '77777777',
  fullName: 'أحمد محمد',
  civilId: '2991234567',
  frontIdPath: 'path/to/front.jpg', // أو base64 string
  backIdPath: 'path/to/back.jpg', // أو base64 string
  dateOfBirth: '1990-01-01',
  address: 'Amman, Jordan',
  monthlyIncome: '1500',
  employer: 'Tech Company',
  email: 'ahmad@example.com', // اختياري
);

if (createResult['success']) {
  final token = createResult['token'];
  print('Account created with token: $token');
}

// 5. الحصول على الملف الشخصي
final profileResult = await authService.getProfile();
if (profileResult['success']) {
  final user = profileResult['data']['user'];
  print('User: ${user['name']}');
}

// 6. تسجيل الخروج
await authService.logout();
```

### الصفحة الرئيسية (Home)

```dart
import 'package:bnpl/services/home_service.dart';

final homeService = HomeService();

// الحصول على بيانات الصفحة الرئيسية
final homeResult = await homeService.getHomeData();
if (homeResult['success']) {
  final data = homeResult['data'];
  
  final banners = data['banners'];
  final categories = data['categories'];
  final topStores = data['topStores'];
  final bestOffers = data['bestOffers'];
  final featuredStores = data['featuredStores'];
  final pendingPayments = data['pendingPayments'];
  final unreadNotifications = data['unreadNotifications'];
  final stats = data['stats'];
  
  print('Banners: ${banners.length}');
  print('Stores: ${topStores.length}');
  print('Offers: ${bestOffers.length}');
  print('Pending Payments: ${pendingPayments.length}');
}

// الحصول على جميع المتاجر
final storesResult = await homeService.getAllStores();
if (storesResult['success']) {
  final stores = storesResult['data']['data'];
  print('Total stores: ${stores.length}');
}

// البحث في المتاجر
final searchResult = await homeService.searchStores('إلكترونيات');
if (searchResult['success']) {
  final stores = searchResult['data']['data'];
  print('Found ${stores.length} stores');
}
```

### المدفوعات (Payments)

```dart
import 'package:bnpl/services/payment_service.dart';

final paymentService = PaymentService();

// الحصول على المدفوعات المعلقة
final pendingResult = await paymentService.getPendingPayments();
if (pendingResult['success']) {
  final payments = pendingResult['data']['data'];
  print('Pending payments: ${payments.length}');
}

// الحصول على تاريخ المدفوعات
final historyResult = await paymentService.getPaymentHistory();
if (historyResult['success']) {
  final payments = historyResult['data']['data'];
  print('Payment history: ${payments.length}');
}
```

### المتاجر (Stores)

```dart
import 'package:bnpl/services/store_service.dart';

final storeService = StoreService();

// الحصول على جميع المتاجر
final storesResult = await storeService.getAllStores();
if (storesResult['success']) {
  final stores = storesResult['data']['data'];
  print('Total stores: ${stores.length}');
}

// الحصول على تفاصيل متجر
final storeResult = await storeService.getStoreById(1);
if (storeResult['success']) {
  final store = storeResult['data']['data'];
  print('Store: ${store['name']}');
}
```

---

## 🔑 JWT Authentication

جميع الـ endpoints التي تتطلب JWT تحتاج إلى إضافة Header:

```dart
// في ApiService يتم إضافة Token تلقائياً عند استخدام setAuthToken
final authService = AuthService();
final token = await authService.getSavedToken();
if (token != null) {
  ApiService().setAuthToken(token);
}
```

**الـ endpoints التي تتطلب JWT**:
- `/api/v1/home` (وليس `/api/v1/home/public`)
- `/api/v1/payments/*`
- `/api/v1/rewards/*`
- `/api/v1/postponements/*`
- `/api/v1/notifications/*`
- `/api/v1/auth/profile`
- `/api/v1/users/*`

---

## 📊 هيكل البيانات المُرجعة

### Home Data Response

```json
{
  "success": true,
  "data": {
    "banners": [...],
    "categories": [...],
    "topStores": [...],
    "bestOffers": [...],
    "featuredStores": [...],
    "pendingPayments": [...],
    "unreadNotifications": [...],
    "stats": {
      "totalStores": 10,
      "totalOffers": 5,
      "pendingPaymentsCount": 3,
      "unreadNotificationsCount": 2
    }
  }
}
```

### Payment Response

```json
{
  "success": true,
  "data": {
    "id": 1,
    "amount": 100.50,
    "dueDate": "2024-01-15",
    "status": "pending",
    "installmentNumber": 1,
    "installmentsCount": 4,
    "store": {
      "id": 1,
      "name": "Store Name"
    }
  }
}
```

---

## 🐛 حل المشاكل

### 1. خطأ الاتصال بالباك اند

**المشكلة**: `Network error` أو `Connection refused`

**الحل**:
- تأكد أن الباك اند يعمل: `http://localhost:3000`
- تحقق من إعدادات `baseUrl` في Flutter
- للجهاز الحقيقي: استخدم IP الكمبيوتر بدلاً من `localhost`

### 2. خطأ JWT Token

**المشكلة**: `Unauthorized` أو `401`

**الحل**:
- تأكد من حفظ Token بعد تسجيل الدخول
- استخدم `ApiService().setAuthToken(token)` قبل الطلبات
- تحقق من انتهاء صلاحية Token

### 3. خطأ في الصور (Base64)

**المشكلة**: خطأ عند رفع صور الهوية

**الحل**:
- تأكد من تحويل الصور إلى base64
- استخدم `data:image/jpeg;base64,` كبادئة
- تحقق من حجم الصورة (يجب أن تكون أقل من 10MB)

---

## 📚 الملفات المهمة

### Backend
- `backend/src/main.ts` - نقطة البداية
- `backend/src/app.module.ts` - الوحدات الرئيسية
- `backend/src/**/*.controller.ts` - الـ Controllers
- `backend/src/**/*.service.ts` - الـ Services
- `backend/src/**/*.entity.ts` - الـ Database Entities

### Flutter
- `forntendUser/lib/services/api_service.dart` - خدمة API الأساسية
- `forntendUser/lib/services/api_endpoints.dart` - جميع الـ Endpoints
- `forntendUser/lib/services/auth_service.dart` - خدمة المصادقة
- `forntendUser/lib/services/home_service.dart` - خدمة الصفحة الرئيسية
- `forntendUser/lib/config/env/env_dev.dart` - إعدادات البيئة

---

## ✅ Checklist

- [ ] الباك اند يعمل على `http://localhost:3000`
- [ ] قاعدة البيانات متصلة
- [ ] Flutter `baseUrl` محدث بشكل صحيح
- [ ] جميع الـ Services محدثة
- [ ] JWT Token يتم حفظه واستخدامه
- [ ] الصور يتم تحويلها إلى base64 بشكل صحيح

---

**آخر تحديث**: $(date)

