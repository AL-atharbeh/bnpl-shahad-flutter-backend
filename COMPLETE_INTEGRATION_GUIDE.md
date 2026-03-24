# دليل الربط الكامل - قاعدة البيانات والباك اند والفلاتر

## 📋 نظرة عامة على المشروع

مشروع BNPL (Buy Now Pay Later) يتكون من:
- **Backend**: NestJS + TypeScript + MySQL
- **Frontend**: Flutter + Dart
- **Database**: MySQL

---

## 🗄️ قاعدة البيانات (Database)

### إعدادات الاتصال

**الملف**: `backend/src/database/database.module.ts`

```typescript
{
  type: 'mysql',
  host: 'localhost',
  port: 3306,
  username: 'root',
  password: '',
  database: 'bnpl_db',
  synchronize: true, // يربط الجداول تلقائياً
}
```

### الجداول (Entities) الموجودة

#### 1. **Users** - جدول المستخدمين
**الملف**: `backend/src/users/entities/user.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم المستخدم
- `name`: الاسم الكامل
- `phone`: رقم الهاتف (فريد)
- `email`: البريد الإلكتروني (فريد)
- `civilIdNumber`: رقم الهوية المدنية
- `civilIdFront`: صورة الهوية الأمامية (base64)
- `civilIdBack`: صورة الهوية الخلفية (base64)
- `dateOfBirth`: تاريخ الميلاد
- `address`: العنوان
- `monthlyIncome`: الدخل الشهري
- `employer`: جهة العمل
- `avatarUrl`: رابط الصورة الشخصية
- `freePostponementCount`: عدد مرات التأجيل المجاني
- `daysSinceLastPostponement`: الأيام منذ آخر تأجيل
- `otp`: رمز OTP
- `isPhoneVerified`: هل تم التحقق من الهاتف
- `isEmailVerified`: هل تم التحقق من البريد
- `country`: الدولة (افتراضي: JO)
- `currency`: العملة (افتراضي: JOD)
- `role`: الدور (افتراضي: user)
- `isActive`: هل الحساب نشط
- `createdAt`: تاريخ الإنشاء
- `updatedAt`: تاريخ التحديث

**العلاقات**:
- `payments`: جميع المدفوعات للمستخدم
- `rewardPoints`: نقاط المكافآت
- `postponements`: التأجيلات
- `notifications`: الإشعارات

#### 2. **Payments** - جدول المدفوعات
**الملف**: `backend/src/payments/entities/payment.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم الدفعة
- `userId`: رقم المستخدم
- `orderId`: رقم الطلب
- `amount`: المبلغ
- `dueDate`: تاريخ الاستحقاق
- `status`: الحالة (pending, paid, overdue)
- `installmentNumber`: رقم القسط (1, 2, 3, 4)
- `installmentsCount`: إجمالي الأقساط (4)
- `isPostponed`: هل تم التأجيل
- `postponedDays`: عدد أيام التأجيل
- `postponedDueDate`: تاريخ الاستحقاق بعد التأجيل

#### 3. **Stores** - جدول المتاجر
**الملف**: `backend/src/stores/entities/store.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم المتجر
- `name`: اسم المتجر
- `description`: الوصف
- `logo`: الشعار
- `coverImage`: صورة الغلاف
- `categoryId`: رقم الفئة
- `link`: رابط المتجر
- `productsCount`: عدد المنتجات
- `isActive`: هل المتجر نشط

#### 4. **Products** - جدول المنتجات
**الملف**: `backend/src/products/entities/product.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم المنتج
- `storeId`: رقم المتجر
- `name`: اسم المنتج
- `description`: الوصف
- `price`: السعر
- `image`: الصورة
- `categoryId`: رقم الفئة
- `isActive`: هل المنتج نشط

#### 5. **Categories** - جدول الفئات
**الملف**: `backend/src/categories/entities/category.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم الفئة
- `name`: اسم الفئة
- `nameAr`: اسم الفئة بالعربية
- `icon`: الأيقونة
- `storesCount`: عدد المتاجر

#### 6. **Banners** - جدول البانرات
**الملف**: `backend/src/banners/entities/banner.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم البانر
- `title`: العنوان
- `image`: الصورة
- `link`: الرابط
- `order`: الترتيب
- `isActive`: هل البانر نشط

#### 7. **Deals** - جدول العروض
**الملف**: `backend/src/deals/entities/deal.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم العرض
- `storeId`: رقم المتجر
- `title`: العنوان
- `description`: الوصف
- `discount`: الخصم
- `startDate`: تاريخ البداية
- `endDate`: تاريخ النهاية
- `isActive`: هل العرض نشط

#### 8. **RewardPoints** - جدول نقاط المكافآت
**الملف**: `backend/src/rewards/entities/reward-point.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم النقطة
- `userId`: رقم المستخدم
- `points`: عدد النقاط
- `type`: النوع (earned, redeemed)
- `description`: الوصف
- `paymentId`: رقم الدفعة (إن وجد)

#### 9. **Postponements** - جدول التأجيلات
**الملف**: `backend/src/postponements/entities/postponement.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم التأجيل
- `userId`: رقم المستخدم
- `paymentId`: رقم الدفعة
- `days`: عدد الأيام
- `isFree`: هل التأجيل مجاني
- `postponedDate`: تاريخ التأجيل

#### 10. **Notifications** - جدول الإشعارات
**الملف**: `backend/src/notifications/entities/notification.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم الإشعار
- `userId`: رقم المستخدم
- `title`: العنوان
- `message`: الرسالة
- `type`: النوع
- `isRead`: هل تم القراءة
- `readAt`: تاريخ القراءة

#### 11. **OTPCodes** - جدول رموز OTP
**الملف**: `backend/src/users/entities/otp-code.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم الرمز
- `phone`: رقم الهاتف
- `code`: رمز OTP
- `expiresAt`: تاريخ الانتهاء
- `isUsed`: هل تم الاستخدام

#### 12. **ContactMessages** - جدول رسائل التواصل
**الملف**: `backend/src/contact/entities/contact-message.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم الرسالة
- `name`: الاسم
- `email`: البريد
- `phone`: الهاتف
- `subject`: الموضوع
- `message`: الرسالة
- `status`: الحالة

#### 13. **PromoNotifications** - جدول الإشعارات الترويجية
**الملف**: `backend/src/promo-notifications/entities/promo-notification.entity.ts`

**الحقول الرئيسية**:
- `id`: رقم الإشعار
- `title`: العنوان
- `message`: الرسالة
- `image`: الصورة
- `link`: الرابط
- `targetAudience`: الجمهور المستهدف
- `sendAt`: تاريخ الإرسال
- `isSent`: هل تم الإرسال

---

## 🔧 الباك اند (Backend)

### البنية الأساسية

**الملف الرئيسي**: `backend/src/main.ts`
- **Port**: 3000
- **API Prefix**: `/api/v1`
- **Swagger Docs**: `/api/docs`
- **CORS**: مفعّل لجميع المصادر

### الوحدات (Modules) الموجودة

#### 1. **Auth Module** - المصادقة
**الملف**: `backend/src/auth/auth.module.ts`

**Endpoints**:
- `POST /api/v1/auth/check-phone` - التحقق من رقم الهاتف
- `POST /api/v1/auth/send-otp` - إرسال رمز OTP
- `POST /api/v1/auth/verify-otp` - التحقق من رمز OTP
- `POST /api/v1/auth/create-account` - إنشاء حساب جديد
- `GET /api/v1/auth/profile` - الحصول على الملف الشخصي (يتطلب JWT)

**الملفات**:
- `auth.controller.ts`: المتحكم
- `auth.service.ts`: الخدمة
- `otp.service.ts`: خدمة OTP
- `dto/`: كائنات نقل البيانات
- `guards/jwt-auth.guard.ts`: حماية JWT
- `strategies/jwt.strategy.ts`: استراتيجية JWT

#### 2. **Users Module** - المستخدمين
**الملف**: `backend/src/users/users.module.ts`

**Endpoints**:
- `GET /api/v1/users/me` - الحصول على المستخدم الحالي
- `PUT /api/v1/users/profile` - تحديث الملف الشخصي
- `GET /api/v1/users/security` - إعدادات الأمان
- `PUT /api/v1/users/security` - تحديث إعدادات الأمان

#### 3. **Stores Module** - المتاجر
**الملف**: `backend/src/stores/stores.module.ts`

**Endpoints**:
- `GET /api/v1/stores` - جميع المتاجر
- `GET /api/v1/stores?categoryId=1` - المتاجر حسب الفئة
- `GET /api/v1/stores/deals` - المتاجر مع العروض
- `GET /api/v1/stores/search?q=query` - البحث في المتاجر
- `GET /api/v1/stores/category/:categoryId` - المتاجر حسب الفئة
- `GET /api/v1/stores/:id` - تفاصيل متجر
- `GET /api/v1/stores/:id/products` - منتجات المتجر

#### 4. **Products Module** - المنتجات
**الملف**: `backend/src/products/products.module.ts`

**Endpoints**:
- `GET /api/v1/products/store/:storeId` - منتجات متجر
- `GET /api/v1/products/search?q=query` - البحث في المنتجات
- `GET /api/v1/products/:id` - تفاصيل منتج

#### 5. **Payments Module** - المدفوعات
**الملف**: `backend/src/payments/payments.module.ts`

**Endpoints** (جميعها تتطلب JWT):
- `GET /api/v1/payments` - جميع المدفوعات
- `GET /api/v1/payments?installmentNumber=1&installmentsCount=4` - فلترة حسب الأقساط
- `GET /api/v1/payments/pending` - المدفوعات المعلقة
- `GET /api/v1/payments/history` - تاريخ المدفوعات
- `GET /api/v1/payments/:id` - تفاصيل دفعة
- `GET /api/v1/payments/order/:orderId` - مدفوعات طلب
- `POST /api/v1/payments/:id/pay` - دفع دفعة
- `PUT /api/v1/payments/:id/extend` - تمديد موعد الدفع
- `POST /api/v1/payments/:id/postpone` - تأجيل دفعة

#### 6. **Rewards Module** - المكافآت
**الملف**: `backend/src/rewards/rewards.module.ts`

**Endpoints** (جميعها تتطلب JWT):
- `GET /api/v1/rewards/points` - النقاط الحالية
- `GET /api/v1/rewards/history` - تاريخ النقاط
- `POST /api/v1/rewards/redeem` - استبدال النقاط

#### 7. **Postponements Module** - التأجيلات
**الملف**: `backend/src/postponements/postponements.module.ts`

**Endpoints** (جميعها تتطلب JWT):
- `GET /api/v1/postponements/can-postpone` - هل يمكن التأجيل
- `POST /api/v1/postponements/postpone-free` - تأجيل مجاني
- `GET /api/v1/postponements/history` - تاريخ التأجيلات

#### 8. **Notifications Module** - الإشعارات
**الملف**: `backend/src/notifications/notifications.module.ts`

**Endpoints** (جميعها تتطلب JWT):
- `GET /api/v1/notifications` - جميع الإشعارات
- `PUT /api/v1/notifications/:id/read` - تحديد كمقروء
- `PUT /api/v1/notifications/read-all` - تحديد الكل كمقروء
- `DELETE /api/v1/notifications/:id` - حذف إشعار

#### 9. **Home Module** - الصفحة الرئيسية
**الملف**: `backend/src/home/home.module.ts`

**Endpoints**:
- `GET /api/v1/home` - بيانات الصفحة الرئيسية (يتطلب JWT)
- `GET /api/v1/home/public` - بيانات الصفحة الرئيسية (بدون JWT)

**البيانات المُرجعة**:
- المتاجر
- العروض
- البانرات
- المدفوعات المعلقة (للمستخدم المسجل)
- الإشعارات (للمستخدم المسجل)

#### 10. **Categories Module** - الفئات
**الملف**: `backend/src/categories/categories.module.ts`

**Endpoints**:
- `GET /api/v1/categories` - جميع الفئات

#### 11. **Banners Module** - البانرات
**الملف**: `backend/src/banners/banners.module.ts`

**Endpoints**:
- `GET /api/v1/banners` - جميع البانرات النشطة

#### 12. **Deals Module** - العروض
**الملف**: `backend/src/deals/deals.module.ts`

**Endpoints**:
- `GET /api/v1/deals` - جميع العروض
- `GET /api/v1/deals/featured` - العروض المميزة

#### 13. **Contact Module** - التواصل
**الملف**: `backend/src/contact/contact.module.ts`

**Endpoints**:
- `POST /api/v1/contact` - إرسال رسالة تواصل

#### 14. **PromoNotifications Module** - الإشعارات الترويجية
**الملف**: `backend/src/promo-notifications/promo-notifications.module.ts`

**Endpoints**:
- `GET /api/v1/promo-notifications` - جميع الإشعارات الترويجية

---

## 📱 الفلاتر (Flutter Frontend)

### البنية الأساسية

**الملف الرئيسي**: `forntendUser/lib/main.dart`

### إعدادات الاتصال

**الملف**: `forntendUser/lib/config/env/env_dev.dart`

```dart
static const String baseUrl = 'http://10.0.2.2:3000'; // Android Emulator
// أو 'http://localhost:3000' للـ iOS Simulator
```

### الخدمات (Services)

#### 1. **ApiService** - خدمة API الأساسية
**الملف**: `forntendUser/lib/services/api_service.dart`

**الوظائف**:
- `get(String endpoint)`: طلب GET
- `post(String endpoint, Map data)`: طلب POST
- `put(String endpoint, Map data)`: طلب PUT
- `delete(String endpoint)`: طلب DELETE
- `setAuthToken(String token)`: إضافة JWT token
- `clearAuthToken()`: حذف JWT token

**معالجة الأخطاء**:
- معالجة تلقائية للأخطاء
- إرجاع `{success: true/false, data/error, statusCode}`

#### 2. **AuthService** - خدمة المصادقة
**الملف**: `forntendUser/lib/services/auth_service.dart`

**الوظائف**:
- `checkIfUserExists(String phoneNumber)`: التحقق من وجود المستخدم
- `sendOTPToPhone(String phoneNumber)`: إرسال OTP
- `verifyOTPCode(String phoneNumber, String otp)`: التحقق من OTP
- `createAccountWithProfile(...)`: إنشاء حساب جديد
- `saveLoginState(String token, String userId)`: حفظ حالة تسجيل الدخول
- `clearLoginState()`: حذف حالة تسجيل الدخول
- `isLoggedIn()`: التحقق من تسجيل الدخول
- `autoLogin()`: تسجيل دخول تلقائي

**ملاحظة**: حالياً بعض الوظائف محاكاة (mock)، يجب ربطها بالـ API الحقيقي

#### 3. **HomeService** - خدمة الصفحة الرئيسية
**الملف**: `forntendUser/lib/services/home_service.dart`

**الوظائف**:
- `getHomeData()`: بيانات الصفحة الرئيسية
- `getAllStores()`: جميع المتاجر
- `getStoreDetails(int storeId)`: تفاصيل متجر
- `getStoreProducts(int storeId)`: منتجات متجر
- `getAllOffers()`: جميع العروض
- `getFeaturedOffers()`: العروض المميزة
- `searchStores(String query)`: البحث في المتاجر
- `searchProducts(String query)`: البحث في المنتجات

#### 4. **PaymentService** - خدمة المدفوعات
**الملف**: `forntendUser/lib/services/payment_service.dart`

**الوظائف**:
- `getUserPayments()`: مدفوعات المستخدم
- `getPendingPayments()`: المدفوعات المعلقة
- `getPaymentHistory()`: تاريخ المدفوعات
- `payAmount(int paymentId, double amount)`: دفع مبلغ
- `extendDueDate(int paymentId, int days)`: تمديد موعد الدفع

#### 5. **StoreService** - خدمة المتاجر
**الملف**: `forntendUser/lib/services/store_service.dart`

**الوظائف**:
- `getAllStores()`: جميع المتاجر
- `getStoreById(int id)`: متجر حسب ID
- `searchStores(String query)`: البحث في المتاجر

#### 6. **PointsService** - خدمة النقاط
**الملف**: `forntendUser/lib/services/points_service.dart`

**الوظائف**:
- `getCurrentPoints()`: النقاط الحالية
- `getPointsHistory()`: تاريخ النقاط
- `redeemPoints(int points)`: استبدال النقاط

#### 7. **PostponeService** - خدمة التأجيل
**الملف**: `forntendUser/lib/services/postpone_service.dart`

**الوظائف**:
- `canPostpone()`: هل يمكن التأجيل
- `postponeFree(int paymentId)`: تأجيل مجاني

#### 8. **NotificationService** - خدمة الإشعارات
**الملف**: `forntendUser/lib/services/notification_service.dart`

**الوظائف**:
- `getNotifications()`: جميع الإشعارات
- `markAsRead(int notificationId)`: تحديد كمقروء
- `markAllAsRead()`: تحديد الكل كمقروء
- `deleteNotification(int notificationId)`: حذف إشعار

### Endpoints في Flutter

**الملف**: `forntendUser/lib/services/api_endpoints.dart`

**ملاحظة**: بعض الـ endpoints في Flutter لا تطابق الـ endpoints في Backend. يجب تحديثها.

---

## 🔗 كيفية الربط

### 1. ربط قاعدة البيانات بالباك اند

**يتم تلقائياً عبر TypeORM**:
- عند تشغيل الباك اند، TypeORM يربط الجداول تلقائياً (`synchronize: true`)
- جميع الـ Entities في `backend/src/**/*.entity.ts` يتم ربطها

**للتحقق من الاتصال**:
```bash
cd backend
npm run start:dev
```

### 2. ربط الباك اند بفلاتر

#### الخطوة 1: تشغيل الباك اند
```bash
cd backend
npm install
npm run start:dev
```

الباك اند يعمل على: `http://localhost:3000`

#### الخطوة 2: تحديث إعدادات Flutter

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
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000';
// مثال: 'http://192.168.1.100:3000'
```

#### الخطوة 3: استخدام الخدمات في Flutter

**مثال: الحصول على بيانات الصفحة الرئيسية**
```dart
import 'package:bnpl/services/home_service.dart';

final homeService = HomeService();
final response = await homeService.getHomeData();

if (response['success']) {
  final data = response['data'];
  // استخدام البيانات
}
```

**مثال: تسجيل الدخول**
```dart
import 'package:bnpl/services/auth_service.dart';

final authService = AuthService();

// 1. التحقق من رقم الهاتف
final exists = await authService.checkIfUserExists('77777777');

// 2. إرسال OTP
await authService.sendOTPToPhone('77777777');

// 3. التحقق من OTP
final verified = await authService.verifyOTPCode('77777777', '123456');

// 4. إنشاء حساب (للمستخدمين الجدد)
await authService.createAccountWithProfile(
  phoneNumber: '77777777',
  fullName: 'أحمد محمد',
  civilId: '2991234567',
  // ... باقي البيانات
);
```

---

## 📝 ملاحظات مهمة

### 1. JWT Authentication

**جميع الـ endpoints التي تتطلب JWT**:
- يجب إضافة Header: `Authorization: Bearer <token>`
- يتم الحصول على Token من `POST /api/v1/auth/verify-otp` أو `POST /api/v1/auth/create-account`

**في Flutter**:
```dart
final authService = AuthService();
final token = await authService.getSavedToken();
if (token != null) {
  ApiService().setAuthToken(token);
}
```

### 2. تحديث AuthService في Flutter

**يجب ربط الوظائف التالية بالـ API الحقيقي**:
- `checkIfUserExists()` → `POST /api/v1/auth/check-phone`
- `sendOTPToPhone()` → `POST /api/v1/auth/send-otp`
- `verifyOTPCode()` → `POST /api/v1/auth/verify-otp`
- `createAccountWithProfile()` → `POST /api/v1/auth/create-account`

### 3. تحديث ApiEndpoints في Flutter

**بعض الـ endpoints لا تطابق Backend**:
- يجب تحديث `forntendUser/lib/services/api_endpoints.dart` ليطابق الـ endpoints في Backend

### 4. معالجة الأخطاء

**في Flutter**:
```dart
final response = await apiService.get('/endpoint');
if (response['success']) {
  // نجح الطلب
  final data = response['data'];
} else {
  // فشل الطلب
  final error = response['error'];
  print('Error: $error');
}
```

---

## 🧪 اختبار الربط

### 1. اختبار الباك اند

```bash
# تشغيل الباك اند
cd backend
npm run start:dev

# فتح Swagger
# http://localhost:3000/api/docs
```

### 2. اختبار قاعدة البيانات

```bash
# الاتصال بقاعدة البيانات
mysql -u root -p
USE bnpl_db;
SHOW TABLES;
```

### 3. اختبار Flutter

```bash
# تشغيل Flutter
cd forntendUser
flutter run

# فتح DevTools
# flutter run --verbose
```

### 4. اختبار API من Flutter

**استخدام Swagger**:
1. افتح `http://localhost:3000/api/docs`
2. جرب الـ endpoints
3. انسخ الـ Request/Response
4. استخدمها في Flutter

---

## 📊 ملخص الـ Endpoints

### Authentication
- `POST /api/v1/auth/check-phone`
- `POST /api/v1/auth/send-otp`
- `POST /api/v1/auth/verify-otp`
- `POST /api/v1/auth/create-account`
- `GET /api/v1/auth/profile` (JWT)

### Users
- `GET /api/v1/users/me` (JWT)
- `PUT /api/v1/users/profile` (JWT)

### Stores
- `GET /api/v1/stores`
- `GET /api/v1/stores/deals`
- `GET /api/v1/stores/search?q=query`
- `GET /api/v1/stores/:id`
- `GET /api/v1/stores/:id/products`

### Products
- `GET /api/v1/products/store/:storeId`
- `GET /api/v1/products/search?q=query`
- `GET /api/v1/products/:id`

### Payments (JWT)
- `GET /api/v1/payments`
- `GET /api/v1/payments/pending`
- `GET /api/v1/payments/history`
- `GET /api/v1/payments/:id`
- `POST /api/v1/payments/:id/pay`
- `PUT /api/v1/payments/:id/extend`
- `POST /api/v1/payments/:id/postpone`

### Rewards (JWT)
- `GET /api/v1/rewards/points`
- `GET /api/v1/rewards/history`
- `POST /api/v1/rewards/redeem`

### Postponements (JWT)
- `GET /api/v1/postponements/can-postpone`
- `POST /api/v1/postponements/postpone-free`
- `GET /api/v1/postponements/history`

### Notifications (JWT)
- `GET /api/v1/notifications`
- `PUT /api/v1/notifications/:id/read`
- `PUT /api/v1/notifications/read-all`
- `DELETE /api/v1/notifications/:id`

### Home
- `GET /api/v1/home` (JWT)
- `GET /api/v1/home/public`

### Categories
- `GET /api/v1/categories`

### Banners
- `GET /api/v1/banners`

### Deals
- `GET /api/v1/deals`
- `GET /api/v1/deals/featured`

### Contact
- `POST /api/v1/contact`

---

## 🚀 الخطوات التالية

1. **تحديث AuthService في Flutter** لربطها بالـ API الحقيقي
2. **تحديث ApiEndpoints** ليطابق Backend
3. **إضافة معالجة أفضل للأخطاء** في Flutter
4. **إضافة Loading States** في Flutter
5. **إضافة Caching** للبيانات
6. **إضافة Offline Support** في Flutter

---

## 📞 الدعم

للمساعدة أو الأسئلة:
- راجع Swagger Docs: `http://localhost:3000/api/docs`
- راجع ملفات README في كل مجلد
- راجع ملفات التوثيق في `api/docs/`

---

**آخر تحديث**: $(date)
**الإصدار**: 1.0.0

