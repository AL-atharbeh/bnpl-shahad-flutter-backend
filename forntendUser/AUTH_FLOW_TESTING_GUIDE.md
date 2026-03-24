# دليل اختبار نظام التسجيل الجديد 🧪

## نظرة عامة
تم إنشاء نظام تسجيل دخول احترافي جديد يعتمد على:
- رقم الهاتف + OTP
- التحقق من الهوية المدنية
- إكمال المعلومات الشخصية

---

## التدفق الكامل 🔄

```
🏁 Splash Screen
    ↓
📱 Welcome/Onboarding (3 صفحات)
    ↓ (عند الانتهاء)
📲 إدخال رقم الهاتف
    ↓
🔐 التحقق من OTP
    ↓
    ├─→ إذا مستخدم موجود: الدخول مباشرة ✅
    │
    └─→ إذا مستخدم جديد:
        ↓
        📸 تصوير البطاقة المدنية (أمامية + خلفية)
        ↓
        📝 إكمال المعلومات الشخصية
        ↓
        🎉 إنشاء الحساب والدخول
```

---

## كيفية الاختبار 🧑‍💻

### 1. بدء التطبيق
```bash
cd /Users/ahmadal-atharbeh/project/bnpl/forntendUser
flutter run
```

### 2. اختبار مستخدم موجود

**الخطوات:**
1. أكمل Onboarding (أو اضغط Skip)
2. في صفحة إدخال رقم الهاتف، أدخل: `77777777`
3. اضغط "متابعة"
4. في صفحة OTP، أدخل أي رمز 6 أرقام (مثال: `123456`)
5. اضغط "تحقق"
6. ✅ **النتيجة**: تسجيل دخول مباشرة للصفحة الرئيسية

### 3. اختبار مستخدم جديد

**الخطوات:**
1. أكمل Onboarding
2. في صفحة إدخال رقم الهاتف، أدخل أي رقم آخر (مثال: `99999999`)
3. اضغط "متابعة"
4. في صفحة OTP، أدخل أي رمز 6 أرقام
5. اضغط "تحقق"
6. **صفحة تصوير البطاقة:**
   - اضغط "التقاط صورة" للجهة الأمامية
   - اختر "الكاميرا" أو "المعرض"
   - اختر/التقط صورة
   - كرر للجهة الخلفية
   - اضغط "متابعة"
7. **صفحة إكمال المعلومات:**
   - املأ جميع الحقول:
     - الاسم الكامل
     - رقم البطاقة المدنية (12 رقم)
     - تاريخ الميلاد (اضغط على الحقل لفتح التقويم)
     - العنوان
     - الدخل الشهري
     - جهة العمل
   - اضغط "إنشاء حساب"
8. ✅ **النتيجة**: إنشاء الحساب والدخول للصفحة الرئيسية

---

## أرقام الاختبار 📱

| الرقم | الحالة | النتيجة |
|------|--------|---------|
| `77777777` | مستخدم موجود | تسجيل دخول مباشر بعد OTP |
| أي رقم آخر | مستخدم جديد | يطلب إكمال التسجيل |

**ملاحظة**: أي رمز OTP مكون من 6 أرقام سيعمل في الاختبار.

---

## ميزات التصميم ✨

### صفحة إدخال رقم الهاتف
- ✅ تصميم نظيف ومحترف
- ✅ رمز الدولة (+965) ثابت
- ✅ التحقق من صحة الإدخال (8 أرقام فقط)
- ✅ Animations سلسة (fade in/slide)
- ✅ Hero animation للشعار
- ✅ Feature chips (Secure, Fast)

### صفحة OTP
- ✅ 6 خانات احترافية باستخدام pinput
- ✅ Animations للخانات
- ✅ Shake animation عند الخطأ
- ✅ مؤقت عد تنازلي (60 ثانية)
- ✅ إمكانية إعادة الإرسال
- ✅ Auto-focus

### صفحة تصوير البطاقة
- ✅ معاينة الصور
- ✅ إمكانية إعادة التصوير
- ✅ الاختيار من المعرض كبديل
- ✅ رسائل توضيحية
- ✅ زر ثابت في الأسفل
- ✅ Success badge عند التقاط الصورة

### صفحة إكمال المعلومات
- ✅ Progress indicator (3 نقاط)
- ✅ حقول مخصصة مع أيقونات
- ✅ Date picker لتاريخ الميلاد
- ✅ Validation شامل
- ✅ تصميم متسق

---

## الألوان المستخدمة 🎨

```dart
Primary Green: #10B981 (AppColors.primary)
Light Green: #D1FAE5 (AppColors.financialGreen50)
Background: #FAFAFA
Card Background: #FFFFFF
Text Primary: #111827
Text Secondary: #6B7280
Border: #E5E7EB
Error: #EF4444
Warning: #FBB024
```

---

## الملفات المنشأة 📁

### صفحات جديدة:
- `lib/features/auth/presentation/pages/phone_input_page.dart`
- `lib/features/auth/presentation/pages/otp_verification_page.dart`
- `lib/features/auth/presentation/pages/civil_id_capture_page.dart`
- `lib/features/auth/presentation/pages/complete_profile_page.dart`

### ملفات محدثة:
- `lib/services/auth_service.dart` - إضافة دوال جديدة
- `lib/routing/app_router.dart` - إضافة routes جديدة
- `lib/features/onboarding/presentation/pages/welcome_page.dart` - تحديث التوجيه
- `lib/l10n/arb/app_ar.arb` - نصوص عربية
- `lib/l10n/arb/app_en.arb` - نصوص إنجليزية

### حزم جديدة:
- `image_picker: ^1.0.7` - للكاميرا
- `pinput: ^5.0.2` - لـ OTP

---

## AuthService - الدوال الجديدة 🔧

```dart
// التحقق من وجود المستخدم
Future<bool> checkIfUserExists(String phoneNumber)

// إرسال OTP
Future<bool> sendOTPToPhone(String phoneNumber)

// التحقق من OTP
Future<bool> verifyOTPCode(String phoneNumber, String otp)

// إنشاء حساب جديد
Future<bool> createAccountWithProfile({
  required String phoneNumber,
  required String fullName,
  required String civilId,
  required String frontIdPath,
  required String backIdPath,
  required String dateOfBirth,
  required String address,
  required String monthlyIncome,
  required String employer,
})

// حفظ حالة تسجيل الدخول
Future<void> saveLoginState(String phoneNumber, [String? userId])
```

---

## Routes الجديدة 🛣️

```dart
AppRouter.phoneInput          → '/phone-input'
AppRouter.otpVerification     → '/otp-verification'
AppRouter.civilIdCapture      → '/civil-id-capture'
AppRouter.completeProfile     → '/complete-profile'
```

---

## نصائح للتطوير 💡

### 1. لتجربة التطبيق بسرعة:
- استخدم `77777777` كرقم هاتف
- أدخل أي 6 أرقام كـ OTP
- تسجيل دخول فوري!

### 2. لاختبار التسجيل الكامل:
- استخدم أي رقم آخر
- أكمل جميع الخطوات
- استخدم صور اختبارية من المعرض

### 3. للتحقق من التصميم:
- جرب اللغتين (العربية والإنجليزية)
- اختبر على أحجام شاشات مختلفة
- تحقق من Animations

### 4. للتطوير المستقبلي:
- كل الدوال في `AuthService` جاهزة للربط بـ API حقيقي
- فقط استبدل `Future.delayed` بـ API calls فعلية
- البيانات محفوظة في `SharedPreferences`

---

## الاختبارات المقترحة 🧪

### اختبارات الوظائف:
- ✅ إدخال رقم صحيح/خاطئ
- ✅ OTP صحيح/خاطئ
- ✅ رفع صور/عدم رفع
- ✅ ملء حقول/ترك حقول فارغة
- ✅ التنقل بين الصفحات
- ✅ الرجوع للخلف

### اختبارات التصميم:
- ✅ RTL (العربية)
- ✅ LTR (الإنجليزية)
- ✅ شاشات صغيرة/كبيرة
- ✅ Landscape/Portrait
- ✅ Animations سلسة
- ✅ Loading states

### اختبارات الأداء:
- ✅ سرعة الانتقال
- ✅ استجابة الـ inputs
- ✅ معالجة الصور
- ✅ حفظ البيانات

---

## المشاكل المحتملة وحلولها 🔧

### 1. الكاميرا لا تعمل؟
**الحل**: تحقق من permissions في:
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

```xml
<!-- Android -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- iOS -->
<key>NSCameraUsageDescription</key>
<string>نحتاج للوصول للكاميرا لتصوير البطاقة المدنية</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>نحتاج للوصول للمعرض لاختيار صور البطاقة المدنية</string>
```

### 2. النصوص لا تظهر؟
**الحل**: تأكد من تشغيل:
```bash
flutter gen-l10n
```

### 3. الحزم لا تعمل؟
**الحل**:
```bash
flutter pub get
flutter clean
flutter pub get
```

---

## الخطوات التالية 🚀

### للإنتاج:
1. ✅ ربط AuthService بـ Backend API
2. ✅ إضافة تشفير للصور
3. ✅ معالجة الأخطاء بشكل شامل
4. ✅ إضافة Firebase Authentication (اختياري)
5. ✅ SMS Auto-read للـ OTP
6. ✅ إضافة Biometric (Face ID/Touch ID)

### تحسينات مقترحة:
1. ✅ حفظ الجهاز (Remember Me)
2. ✅ تسجيل دخول بالبريد الإلكتروني
3. ✅ Social Login (Google, Apple)
4. ✅ تحسين معالجة الصور (crop, compress)
5. ✅ Progress saving (حفظ التقدم)

---

## الدعم الفني 📞

لأي استفسارات أو مشاكل:
1. راجع هذا الدليل
2. تحقق من `NEW_AUTH_SYSTEM.md` للتفاصيل التقنية
3. اطلع على الكود المصدري مع التعليقات الموجودة

---

## ملاحظات مهمة ⚠️

1. **للاختبار فقط**: النظام الحالي يستخدم بيانات وهمية
2. **للإنتاج**: يجب ربط جميع API calls بالسيرفر الحقيقي
3. **الأمان**: تأكد من تشفير البيانات الحساسة قبل الإنتاج
4. **Permissions**: تحقق من صلاحيات الكاميرا والمعرض على الأجهزة
5. **التوافق**: تم الاختبار على iOS وAndroid

---

## الإصدار 📝

- **الإصدار**: 1.0.0
- **التاريخ**: 27 أكتوبر 2025
- **الحالة**: ✅ جاهز للاختبار
- **التطوير**: 🚧 يمكن الربط بالـ Backend

---

**تم الإنشاء بكل احترافية! 🎉**

استمتع بتجربة نظام التسجيل الجديد! 🚀

