# نظام تسجيل الدخول الجديد - النسخة الاحترافية

## نظرة عامة
تم إعادة تصميم نظام تسجيل الدخول بالكامل ليكون أكثر احترافية وأماناً باستخدام OTP والتحقق من الهوية المدنية.

## التدفق الجديد 🔄

```
1. صفحة إدخال رقم الهاتف
   ↓
2. التحقق من وجود الحساب (API Call)
   ↓
3. إرسال OTP إلى الرقم
   ↓
4. صفحة OTP للتحقق
   ↓
5a. إذا كان لديه حساب → تسجيل الدخول مباشرة
   |
5b. إذا لم يكن لديه حساب → 
      ↓
      6. صفحة تصوير البطاقة المدنية (أمامية + خلفية)
      ↓
      7. صفحة إكمال المعلومات الشخصية
      ↓
      8. إنشاء الحساب
```

## الصفحات

### 1. صفحة إدخال رقم الهاتف
- **الملف**: `lib/features/auth/presentation/pages/phone_input_page.dart`
- **المميزات**:
  - تصميم نظيف وبسيط
  - تنسيق تلقائي للرقم
  - التحقق من صحة الإدخال
  - Animations سلسة
  - دعم RTL/LTR
  
### 2. صفحة OTP
- **الملف**: `lib/features/auth/presentation/pages/otp_verification_page.dart`
- **المميزات**:
  - 6 خانات لإدخال الرمز
  - مؤقت عد تنازلي (60 ثانية)
  - إمكانية إعادة الإرسال
  - Auto-focus بين الخانات
  - Animations احترافية
  
### 3. صفحة تصوير البطاقة المدنية
- **الملف**: `lib/features/auth/presentation/pages/civil_id_capture_page.dart`
- **المميزات**:
  - التقاط صورة الجهة الأمامية والخلفية
  - إطار توجيهي للمستخدم
  - معاينة الصورة قبل الحفظ
  - إمكانية إعادة التصوير
  - الاختيار من المعرض كخيار بديل
  
### 4. صفحة إكمال المعلومات
- **الملف**: `lib/features/auth/presentation/pages/complete_profile_page.dart`
- **المميزات**:
  - نموذج شامل مع validation
  - حقول: الاسم، رقم الهوية، تاريخ الميلاد، العنوان، الدخل، جهة العمل
  - Date picker لتاريخ الميلاد
  - تصميم متسق مع باقي التطبيق

## الحزم المستخدمة

```yaml
dependencies:
  image_picker: ^1.0.7  # للتصوير واختيار الصور
  pinput: ^3.0.1        # لإدخال OTP بشكل احترافي
```

## الألوان والتصميم

### ألوان أساسية:
- **Primary Green**: `#10B981` - للأزرار والعناصر المهمة
- **Background**: `#FAFAFA` - خلفية الصفحات
- **Card**: `#FFFFFF` - الكروت والنماذج
- **Text Primary**: `#111827` - النصوص الرئيسية
- **Text Secondary**: `#6B7280` - النصوص الثانوية

### Animations:
- Fade in/out للعناصر
- Slide transitions بين الصفحات
- Scale animations للأزرار
- Shimmer effects للتحميل

## البنية التقنية

### AuthService التحديثات
```dart
class AuthService {
  // تحقق من وجود الحساب
  Future<bool> checkIfUserExists(String phoneNumber);
  
  // إرسال OTP
  Future<void> sendOTP(String phoneNumber);
  
  // التحقق من OTP
  Future<bool> verifyOTP(String phoneNumber, String otp);
  
  // إنشاء حساب جديد
  Future<void> createAccount({
    required String phoneNumber,
    required String fullName,
    required String civilId,
    required String frontIdPhoto,
    required String backIdPhoto,
    // ... المزيد
  });
}
```

## الأمان

### OTP:
- رمز مكون من 6 أرقام
- صالح لمدة 5 دقائق
- يمكن إعادة الإرسال بعد 60 ثانية
- محاولات محدودة (3-5 محاولات)

### البطاقة المدنية:
- حفظ الصور بشكل آمن
- تشفير قبل الإرسال للسيرفر
- التحقق من جودة الصورة

### البيانات الشخصية:
- تشفير البيانات الحساسة
- HTTPS فقط
- Token-based authentication

## Routes المحدثة

```dart
static const String phoneInput = '/phone-input';
static const String otpVerification = '/otp-verification';
static const String civilIdCapture = '/civil-id-capture';
static const String completeProfile = '/complete-profile';
```

## الاختبار

### اختبار التدفق الكامل:
1. ابدأ من splash screen
2. أدخل رقم هاتف (9XXXXXXX)
3. تلقى OTP (في التطوير: أي رمز 6 أرقام يعمل)
4. إذا مستخدم جديد:
   - التقط صورتي البطاقة
   - املأ النموذج
   - إنشاء الحساب
5. تسجيل الدخول للتطبيق

### أرقام اختبار:
- `77777777` - مستخدم موجود (تسجيل دخول مباشر)
- `99999999` - مستخدم جديد (يحتاج تسجيل)

## الملفات الجديدة

```
lib/features/auth/presentation/pages/
├── phone_input_page.dart       ✅ جديد
├── otp_verification_page.dart  ✅ جديد
├── civil_id_capture_page.dart  ✅ جديد
└── complete_profile_page.dart  ✅ جديد

lib/services/
└── auth_service.dart           📝 محدث

lib/routing/
└── app_router.dart             📝 محدث

lib/l10n/arb/
├── app_ar.arb                  📝 محدث
└── app_en.arb                  📝 محدث
```

## التطوير المستقبلي

1. **Biometric Authentication**: Face ID / Touch ID
2. **Social Login**: Google, Apple Sign In
3. **Remember Device**: عدم طلب OTP للأجهزة الموثوقة
4. **SMS Auto-read**: قراءة OTP تلقائياً من الرسالة
5. **Error Handling**: رسائل خطأ أفضل
6. **Offline Mode**: حفظ مؤقت للبيانات

## التاريخ
- **27 أكتوبر 2025**: بدء العمل على النظام الجديد
- **Status**: 🚧 قيد التطوير

