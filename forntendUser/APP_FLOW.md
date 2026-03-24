# تدفق التطبيق - BNPL

## نظرة عامة

تدفق التطبيق الجديد: **Splash Screen → Login/Signup → Homepage**

## 🔄 التدفق المحدث

### 1. Splash Screen (صفحة البداية)
- **المدة**: 3 ثوانٍ
- **الوظيفة**: عرض شعار التطبيق مع رسوم متحركة
- **التوجيه التالي**: صفحة تسجيل الدخول

### 2. Login Page (صفحة تسجيل الدخول)
- **الوظيفة**: تسجيل دخول المستخدم
- **الحقول**: رقم الهاتف + كلمة المرور
- **التوجيه التالي**: 
  - ✅ **نجح تسجيل الدخول** → Homepage
  - 🔗 **ليس لديك حساب؟** → صفحة التسجيل

### 3. Register Page (صفحة التسجيل)
- **الوظيفة**: إنشاء حساب جديد
- **الحقول**: الاسم الكامل + البريد الإلكتروني + رقم الهاتف + كلمة المرور
- **التوجيه التالي**: 
  - ✅ **نجح التسجيل** → Homepage
  - 🔙 **العودة** → صفحة تسجيل الدخول

### 4. Homepage (الصفحة الرئيسية)
- **الوظيفة**: الصفحة الرئيسية للتطبيق
- **المحتوى**: المتاجر، المنتجات، العروض، إلخ

## 📱 تفاصيل التنفيذ

### Splash Screen
```dart
// الملف: lib/features/onboarding/presentation/pages/splash_page.dart
// التوجيه: AppRouter.navigateToLogin(context);
```

### Login Page
```dart
// الملف: lib/features/auth/presentation/pages/login_page.dart
// التوجيه عند النجاح: AppRouter.navigateToHome(context);
// التوجيه للتسجيل: AppRouter.navigateToRegister(context);
```

### Register Page
```dart
// الملف: lib/features/auth/presentation/pages/register_page.dart
// التوجيه عند النجاح: AppRouter.navigateToHome(context);
// التوجيه للعودة: AppRouter.goBack(context);
```

### App Router
```dart
// الملف: lib/routing/app_router.dart
// الـ initial route: AppRouter.splash
```

## 🎯 الميزات

### ✅ Splash Screen
- رسوم متحركة للشعار
- تأثير النبض
- تحميل تدريجي للنصوص
- مدة عرض 3 ثوانٍ

### ✅ Login Page
- تصميم عصري وأنيق
- التحقق من صحة البيانات
- رسائل خطأ واضحة
- دعم اللغة العربية والإنجليزية
- زر الانتقال للتسجيل

### ✅ Register Page
- نموذج تسجيل شامل
- التحقق من صحة البيانات
- رسائل خطأ واضحة
- دعم اللغة العربية والإنجليزية
- زر العودة لتسجيل الدخول

### ✅ Navigation
- تدفق منطقي ومتسلسل
- انتقالات سلسة
- إدارة صحيحة للـ routes

## 🔧 الإعدادات

### Main App
```dart
// lib/main.dart
initialRoute: AppRouter.splash, // بداية من splash screen
```

### System UI
```dart
// إخفاء شريط النظام في splash screen
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

// إعادة إظهار شريط النظام قبل الانتقال
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
```

## 🚀 كيفية التشغيل

1. **تشغيل التطبيق**:
   ```bash
   cd forntendUser
   flutter run
   ```

2. **تدفق التشغيل**:
   ```
   App Launch → Splash Screen (3s) → Login Page → Homepage
   ```

3. **خيارات المستخدم**:
   ```
   Login Page:
   ├── تسجيل الدخول → Homepage
   └── إنشاء حساب → Register Page → Homepage
   ```

## 📋 ملاحظات مهمة

### الأمان
- التحقق من صحة البيانات في كل صفحة
- رسائل خطأ واضحة ومفيدة
- حماية من الإدخال الخاطئ

### تجربة المستخدم
- انتقالات سلسة ومريحة
- رسوم متحركة جذابة
- تصميم متجاوب
- دعم اللغتين

### الأداء
- تحميل سريع للصفحات
- إدارة ذكية للذاكرة
- تحسين الرسوم المتحركة

## 🔄 التحديثات المستقبلية

### إضافة ميزات
- [ ] حفظ حالة تسجيل الدخول
- [ ] تسجيل الدخول التلقائي
- [ ] استعادة كلمة المرور
- [ ] المصادقة الثنائية

### تحسينات
- [ ] تحسين الأداء
- [ ] إضافة المزيد من الرسوم المتحركة
- [ ] تحسين التصميم
- [ ] إضافة المزيد من اللغات
