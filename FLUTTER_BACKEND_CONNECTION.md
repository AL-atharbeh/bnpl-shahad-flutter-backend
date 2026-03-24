# دليل الربط الكامل - Flutter مع Backend

## ✅ حالة الربط الحالية

### ✅ ما تم ربطه بشكل كامل:

1. **Authentication Service** ✅
   - `checkIfUserExists()` → `POST /api/v1/auth/check-phone`
   - `sendOTPToPhone()` → `POST /api/v1/auth/send-otp`
   - `verifyOTPCode()` → `POST /api/v1/auth/verify-otp`
   - `createAccountWithProfile()` → `POST /api/v1/auth/create-account`
   - `getProfile()` → `GET /api/v1/auth/profile`
   - حفظ JWT Token تلقائياً

2. **Home Service** ✅
   - `getHomeData()` → `GET /api/v1/home`
   - `getAllStores()` → `GET /api/v1/stores`
   - `getStoreDetails()` → `GET /api/v1/stores/:id`
   - `getStoreProducts()` → `GET /api/v1/stores/:id/products`
   - `getAllOffers()` → `GET /api/v1/deals`
   - `getFeaturedOffers()` → `GET /api/v1/deals/featured`
   - `searchStores()` → `GET /api/v1/stores/search`
   - `searchProducts()` → `GET /api/v1/products/search`

3. **API Endpoints** ✅
   - جميع الـ endpoints محدثة ليطابق Backend
   - Helper methods للـ dynamic endpoints

4. **API Service** ✅
   - GET, POST, PUT, DELETE requests
   - JWT Token management
   - Error handling
   - Response formatting

---

## 🔧 الإعدادات المطلوبة

### 1. Backend يعمل على Docker

```bash
cd backend
docker-compose up -d
```

**التحقق**:
```bash
curl http://localhost:3000
# يجب أن ترى: {"message":"Welcome to BNPL API",...}
```

### 2. Flutter Base URL

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
// استبدل YOUR_IP بـ IP الكمبيوتر
static const String baseUrl = 'http://192.168.1.100:3000';
```

---

## 📱 أمثلة الاستخدام

### 1. تسجيل الدخول الكامل

```dart
import 'package:bnpl/services/auth_service.dart';

final authService = AuthService();

// الخطوة 1: التحقق من رقم الهاتف
final checkResult = await authService.checkIfUserExists('77777777');
if (!checkResult['success']) {
  print('Error: ${checkResult['error']}');
  return;
}

final exists = checkResult['exists'];
print('User exists: $exists');

// الخطوة 2: إرسال OTP
final otpResult = await authService.sendOTPToPhone('77777777');
if (!otpResult['success']) {
  print('Error: ${otpResult['error']}');
  return;
}
print('OTP sent successfully');

// الخطوة 3: التحقق من OTP
final verifyResult = await authService.verifyOTPCode('77777777', '123456');
if (!verifyResult['success']) {
  print('Error: ${verifyResult['error']}');
  return;
}

if (verifyResult['userExists'] == true) {
  // المستخدم موجود - تم تسجيل الدخول
  final token = verifyResult['token'];
  print('✅ Logged in! Token: $token');
} else {
  // مستخدم جديد - يحتاج إكمال الملف الشخصي
  print('⚠️ User needs to complete profile');
}
```

### 2. إنشاء حساب جديد

```dart
// بعد التحقق من OTP
final createResult = await authService.createAccountWithProfile(
  phoneNumber: '77777777',
  fullName: 'أحمد محمد',
  civilId: '2991234567',
  frontIdPath: 'data:image/jpeg;base64,...', // أو مسار الملف
  backIdPath: 'data:image/jpeg;base64,...', // أو مسار الملف
  dateOfBirth: '1990-01-01',
  address: 'Amman, Jordan',
  monthlyIncome: '1500',
  employer: 'Tech Company',
  email: 'ahmad@example.com', // اختياري
);

if (createResult['success']) {
  final token = createResult['token'];
  final user = createResult['user'];
  print('✅ Account created!');
  print('Token: $token');
  print('User: ${user['name']}');
} else {
  print('❌ Error: ${createResult['error']}');
}
```

### 3. الحصول على بيانات الصفحة الرئيسية

```dart
import 'package:bnpl/services/home_service.dart';

final homeService = HomeService();

// الحصول على بيانات الصفحة الرئيسية
final homeResult = await homeService.getHomeData();
if (homeResult['success']) {
  final data = homeResult['data'];
  
  // البانرات
  final banners = data['banners'] ?? [];
  print('Banners: ${banners.length}');
  
  // الفئات
  final categories = data['categories'] ?? [];
  print('Categories: ${categories.length}');
  
  // المتاجر
  final topStores = data['topStores'] ?? [];
  print('Top Stores: ${topStores.length}');
  
  // العروض
  final bestOffers = data['bestOffers'] ?? [];
  print('Best Offers: ${bestOffers.length}');
  
  // المدفوعات المعلقة (إذا كان المستخدم مسجل دخول)
  final pendingPayments = data['pendingPayments'] ?? [];
  print('Pending Payments: ${pendingPayments.length}');
  
  // الإشعارات غير المقروءة (إذا كان المستخدم مسجل دخول)
  final unreadNotifications = data['unreadNotifications'] ?? [];
  print('Unread Notifications: ${unreadNotifications.length}');
  
  // الإحصائيات
  final stats = data['stats'] ?? {};
  print('Total Stores: ${stats['totalStores']}');
  print('Total Offers: ${stats['totalOffers']}');
  print('Pending Payments Count: ${stats['pendingPaymentsCount']}');
} else {
  print('❌ Error: ${homeResult['error']}');
}
```

### 4. الحصول على المتاجر

```dart
// جميع المتاجر
final storesResult = await homeService.getAllStores();
if (storesResult['success']) {
  final stores = storesResult['data']['data'] ?? [];
  print('Total stores: ${stores.length}');
  
  for (var store in stores) {
    print('Store: ${store['name']}');
    print('  ID: ${store['id']}');
    print('  Category: ${store['category']}');
    print('  Rating: ${store['rating']}');
  }
}

// البحث في المتاجر
final searchResult = await homeService.searchStores('إلكترونيات');
if (searchResult['success']) {
  final stores = searchResult['data']['data'] ?? [];
  print('Found ${stores.length} stores');
}
```

### 5. استخدام JWT Token

```dart
// Token يتم حفظه تلقائياً عند تسجيل الدخول
// يمكنك التحقق منه:
final authService = AuthService();
final isLoggedIn = await authService.isLoggedIn();
if (isLoggedIn) {
  final token = await authService.getSavedToken();
  print('Token: $token');
  
  // Token يتم إضافته تلقائياً في جميع الطلبات
  // لا حاجة لإضافته يدوياً
}
```

---

## 🔍 التحقق من الربط

### 1. اختبار الاتصال الأساسي

```dart
import 'package:bnpl/services/api_service.dart';

final apiService = ApiService();

// اختبار الاتصال
final response = await apiService.get('/');
print('Response: $response');

// يجب أن ترى:
// {
//   "success": true,
//   "data": {
//     "message": "Welcome to BNPL API",
//     "version": "1.0",
//     ...
//   }
// }
```

### 2. اختبار Authentication

```dart
// 1. Check Phone
final checkResult = await authService.checkIfUserExists('77777777');
print('Check Phone: $checkResult');

// 2. Send OTP
final otpResult = await authService.sendOTPToPhone('77777777');
print('Send OTP: $otpResult');

// 3. Verify OTP (استخدم الرمز الصحيح من Backend)
final verifyResult = await authService.verifyOTPCode('77777777', '123456');
print('Verify OTP: $verifyResult');
```

### 3. اختبار Home Data

```dart
final homeResult = await homeService.getHomeData();
print('Home Data: ${homeResult['success']}');
if (homeResult['success']) {
  print('Data keys: ${homeResult['data'].keys}');
}
```

---

## 🐛 حل المشاكل الشائعة

### المشكلة 1: Network Error

**الأعراض**: `Network error: Connection refused`

**الحل**:
1. تأكد من أن Backend يعمل: `http://localhost:3000`
2. للـ Android Emulator: استخدم `10.0.2.2:3000`
3. للـ iOS Simulator: استخدم `localhost:3000`
4. للجهاز الحقيقي: استخدم IP الكمبيوتر

### المشكلة 2: 401 Unauthorized

**الأعراض**: `Unauthorized` أو `401`

**الحل**:
1. تأكد من تسجيل الدخول أولاً
2. تحقق من حفظ Token:
   ```dart
   final token = await authService.getSavedToken();
   print('Token: $token');
   ```
3. إذا كان Token null، سجّل الدخول مرة أخرى

### المشكلة 3: CORS Error

**الأعراض**: `CORS policy` error

**الحل**: CORS مفعّل بالفعل في Backend. إذا استمرت المشكلة:
1. تأكد من أن Backend يعمل
2. تحقق من `baseUrl` في Flutter
3. أعد تشغيل Backend

### المشكلة 4: Invalid JSON Response

**الأعراض**: `Invalid JSON response`

**الحل**:
1. تحقق من أن Backend يعمل بشكل صحيح
2. تحقق من السجلات في Backend:
   ```bash
   docker-compose logs -f app
   ```
3. تأكد من أن الـ endpoint موجود في Backend

---

## 📊 حالة الخدمات

### ✅ Services المربوطة بالكامل:

- ✅ `AuthService` - المصادقة
- ✅ `HomeService` - الصفحة الرئيسية
- ✅ `ApiService` - خدمة API الأساسية

### ⚠️ Services التي تحتاج تحديث:

- ⚠️ `PaymentService` - يحتاج تحديث الـ endpoints
- ⚠️ `StoreService` - يحتاج تحديث الـ endpoints
- ⚠️ `PointsService` - يحتاج تحديث الـ endpoints
- ⚠️ `PostponeService` - يحتاج تحديث الـ endpoints
- ⚠️ `NotificationService` - يحتاج تحديث الـ endpoints

---

## ✅ Checklist النهائي

- [ ] Backend يعمل على Docker (`docker-compose up -d`)
- [ ] Backend متاح على `http://localhost:3000`
- [ ] Flutter `baseUrl` محدث بشكل صحيح
- [ ] `AuthService` مربوط بالـ API
- [ ] `HomeService` مربوط بالـ API
- [ ] JWT Token يتم حفظه واستخدامه
- [ ] اختبار الاتصال نجح
- [ ] اختبار Authentication نجح
- [ ] اختبار Home Data نجح

---

## 🚀 الخطوات التالية

1. **تحديث باقي الـ Services**:
   - `PaymentService`
   - `StoreService`
   - `PointsService`
   - `PostponeService`
   - `NotificationService`

2. **إضافة Error Handling أفضل**:
   - معالجة أخطاء الشبكة
   - معالجة أخطاء API
   - رسائل خطأ واضحة للمستخدم

3. **إضافة Loading States**:
   - Loading indicators
   - Skeleton screens

4. **إضافة Caching**:
   - Cache للبيانات الثابتة
   - Offline support

---

**آخر تحديث**: $(date)

