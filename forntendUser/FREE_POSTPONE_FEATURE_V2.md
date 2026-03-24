# ميزة تأجيل القسط المجاني (التحديث الثاني)

## التغييرات الجديدة ✨

### 1. **مرة واحدة في الشهر** (وليس مرة لكل قسط)
**قبل:** يمكن تأجيل كل قسط مرة واحدة بشكل منفصل  
**بعد:** يمكن استخدام التأجيل المجاني مرة واحدة في الشهر لأي قسط تختاره

### 2. **مدة التأجيل 10 أيام** (وليس 30 يوم)
**قبل:** التأجيل لمدة 30 يوم  
**بعد:** التأجيل لمدة 10 أيام إضافية فقط

## كيف يعمل النظام الجديد؟

### السيناريو 1: الاستخدام الأول
```
1. المستخدم يفتح صفحة الأقساط
2. يرى Badge "تأجيل مجاني • مرة شهرياً" على جميع الأقساط
3. يختار القسط الذي يريد تأجيله
4. ينقر "تأجيل مجاناً"
5. ✅ يتم التأجيل لمدة 10 أيام
6. ✅ يختفي Badge من جميع الأقساط الأخرى
7. لا يمكن استخدام التأجيل مرة أخرى لمدة 30 يوم
```

### السيناريو 2: محاولة الاستخدام مرة أخرى
```
1. المستخدم يحاول التأجيل مرة أخرى قبل مرور 30 يوم
2. ❌ رسالة: "لقد استخدمت التأجيل المجاني هذا الشهر"
3. 📅 "يمكنك استخدام التأجيل المجاني مرة أخرى بعد 15 يوم" (مثال)
```

### السيناريو 3: بعد مرور 30 يوم
```
1. مر 30 يوم على آخر استخدام
2. ✅ يظهر Badge على جميع الأقساط مرة أخرى
3. يمكن اختيار أي قسط للتأجيل
```

## التغييرات التقنية

### في `PostponeService`

#### قبل:
```dart
// كان يحفظ قائمة بمعرفات الأقساط المؤجلة
Set<String> _postponedInstallments = {};
```

#### بعد:
```dart
// يحفظ تاريخ آخر استخدام فقط
DateTime? _lastPostponeDate;
String? _lastPostponedInstallmentId;
```

#### الوظائف الجديدة:
```dart
// التحقق من إمكانية التأجيل (بناءً على التاريخ)
bool canPostponeForFree(String installmentId) {
  if (_lastPostponeDate == null) return true;
  final daysSinceLastPostpone = now.difference(_lastPostponeDate!).inDays;
  return daysSinceLastPostpone >= 30;
}

// معرفة كم يوم متبقي
int getDaysUntilNextPostpone() {
  final daysRemaining = 30 - daysSinceLastPostpone;
  return daysRemaining > 0 ? daysRemaining : 0;
}
```

### في `payments_page.dart`

#### التأجيل 10 أيام:
```dart
// قبل
final newDue = currentDue.add(const Duration(days: 30));

// بعد
final newDue = currentDue.add(const Duration(days: 10));
```

#### رسالة خطأ محسّنة:
```dart
if (!postponeService.canPostponeForFree(installmentId)) {
  final daysRemaining = postponeService.getDaysUntilNextPostpone();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        daysRemaining > 0
            ? l10n.freePostponeUsedWithDays(daysRemaining)
            : l10n.freePostponeUsed,
      ),
      backgroundColor: const Color(0xFFF59E0B),
      duration: const Duration(seconds: 4),
    ),
  );
}
```

## النصوص المحدّثة

### عربي:
- ✅ **Badge**: "تأجيل مجاني • مرة شهرياً" (بدلاً من "مرة واحدة")
- ✅ **الوصف**: "يمكنك تأجيل أي قسط مجاناً مرة واحدة في الشهر. سيتم تأجيله لمدة 10 أيام إضافية بدون رسوم."
- ✅ **رسالة الخطأ**: "لقد استخدمت التأجيل المجاني هذا الشهر"
- ✅ **رسالة الخطأ مع الأيام**: "يمكنك استخدام التأجيل المجاني مرة أخرى بعد {days} يوم"
- ✅ **الملاحظة**: "ملاحظة: يمكنك استخدام هذه الميزة مرة واحدة في الشهر لأي قسط."

### English:
- ✅ **Badge**: "Free Postpone • Monthly"
- ✅ **Description**: "You can postpone any installment for free once per month. It will be postponed for 10 additional days without fees."
- ✅ **Error**: "You've used your free postpone this month"
- ✅ **Error with days**: "You can use free postpone again after {days} days"
- ✅ **Note**: "Note: You can use this feature once per month for any installment."

## التخزين المحلي

### قبل:
```dart
Key: 'postponed_installments'
Type: List<String>
Example: ['Boutiqaat_1', 'Nike_2', 'Zara_3']
```

### بعد:
```dart
Key: 'last_postpone_date'
Type: String (ISO 8601)
Example: '2024-10-27T14:30:00.000'

Key: 'last_postponed_installment'
Type: String
Example: 'Boutiqaat_1'
```

## المزايا الجديدة

### للمستخدمين:
- ✅ **مرونة أكبر**: يمكن اختيار أي قسط للتأجيل
- ✅ **وضوح**: يعرف المستخدم متى يمكنه استخدام التأجيل مرة أخرى
- ✅ **واقعية**: 10 أيام تأجيل معقولة أكثر من 30 يوم

### للشركة:
- ✅ **تحكم أفضل**: تأجيل واحد في الشهر بدلاً من تأجيل لكل قسط
- ✅ **تقليل المخاطر**: 10 أيام أقل خطورة من 30 يوم
- ✅ **عدالة**: جميع المستخدمين لهم نفس الحد الشهري

## أمثلة الاستخدام

### مثال 1: المستخدم لديه 3 أقساط
```
قسط Boutiqaat: JD 4.060 - مستحق غداً
قسط Nike: JD 12.500 - مستحق بعد 7 أيام
قسط Zara: JD 15.300 - مستحق بعد 18 يوم

الثلاثة عليهم Badge "تأجيل مجاني • مرة شهرياً"

المستخدم يختار تأجيل قسط Boutiqaat
✅ تم التأجيل لمدة 10 أيام
❌ اختفى Badge من Nike و Zara
```

### مثال 2: بعد 15 يوم
```
المستخدم يحاول تأجيل قسط Nike
❌ رسالة: "يمكنك استخدام التأجيل المجاني مرة أخرى بعد 15 يوم"
```

### مثال 3: بعد 30 يوم
```
✅ يظهر Badge على جميع الأقساط الجديدة
المستخدم يمكنه تأجيل أي قسط مرة أخرى
```

## الاختبار

### للاختبار اليدوي:
1. استخدم التأجيل المجاني لقسط معين
2. حاول استخدامه مرة أخرى → يجب أن ترى رسالة خطأ
3. لمحاكاة مرور 30 يوم، استخدم:
```dart
await postponeService.clearAll();
```

### للتحقق من الأيام المتبقية:
```dart
final daysRemaining = postponeService.getDaysUntilNextPostpone();
print('أيام متبقية: $daysRemaining');
```

## الفرق بين النسخة القديمة والجديدة

| الميزة | النسخة القديمة | النسخة الجديدة |
|-------|----------------|----------------|
| **التكرار** | مرة واحدة لكل قسط | مرة واحدة في الشهر لأي قسط |
| **مدة التأجيل** | 30 يوم | 10 أيام |
| **Badge** | يظهر على كل قسط لم يُؤجل | يظهر على جميع الأقساط أو لا يظهر على الإطلاق |
| **رسالة الخطأ** | "تم استخدام التأجيل المجاني" | "لقد استخدمت التأجيل المجاني هذا الشهر + عدد الأيام المتبقية" |
| **التخزين** | قائمة بالأقساط المؤجلة | تاريخ آخر استخدام فقط |

## الملفات المعدّلة

1. ✅ `lib/services/postpone_service.dart` - تغيير كامل في المنطق
2. ✅ `lib/features/payments/presentation/pages/payments_page.dart` - تحديث مدة التأجيل ورسائل الخطأ
3. ✅ `lib/l10n/arb/app_ar.arb` - تحديث النصوص العربية
4. ✅ `lib/l10n/arb/app_en.arb` - تحديث النصوص الإنجليزية

## التاريخ
- **27 أكتوبر 2025**: النسخة الأولى (مرة لكل قسط، 30 يوم)
- **27 أكتوبر 2025**: النسخة الثانية (مرة في الشهر، 10 أيام) ✨

