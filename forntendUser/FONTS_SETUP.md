# إعداد الخطوط

## الخطوط المستخدمة في التطبيق

### 1. خط Changa (للعناوين)
- **المصدر**: Google Fonts
- **الرابط**: https://fonts.google.com/specimen/Changa
- **الاستخدام**: العناوين الرئيسية والعناوين الفرعية

### 2. خط Mada (للنصوص)
- **المصدر**: Google Fonts  
- **الرابط**: https://fonts.google.com/specimen/Mada
- **الاستخدام**: النصوص العادية والأوصاف

## ✅ الحل المطبق

تم استخدام حزمة **Google Fonts** لتطبيق الخطوط مباشرة من الإنترنت:

### المميزات:
- ✅ لا حاجة لتنزيل ملفات الخطوط
- ✅ تحديث تلقائي للخطوط
- ✅ دعم كامل للخطوط العربية
- ✅ أداء محسن

### التطبيق:
```dart
// للعناوين
GoogleFonts.changa(
  fontSize: 32,
  fontWeight: FontWeight.bold,
)

// للنصوص
GoogleFonts.mada(
  fontSize: 16,
  color: Colors.grey,
)
```

## تطبيق الخطوط

### العناوين (Changa)
- `headlineLarge`, `headlineMedium`, `headlineSmall`
- `titleLarge`, `titleMedium`, `titleSmall`

### النصوص (Mada)
- `bodyLarge`, `bodyMedium`, `bodySmall`
- `labelLarge`, `labelMedium`, `labelSmall`

## ملاحظات
- تم إضافة حزمة `google_fonts: ^6.1.0` إلى `pubspec.yaml`
- الخطوط ستظهر تلقائياً عند تشغيل التطبيق
- لا حاجة لتنزيل ملفات إضافية
