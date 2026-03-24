# منطق التأجيل المجاني (Free Postponement Logic)

## 📋 القواعد الأساسية

1. **مرة واحدة كل 30 يوم**: يمكن لكل مستخدم استخدام التأجيل المجاني مرة واحدة كل 30 يوم
2. **منع التأجيل المتزامن**: لا يمكن تفعيل تأجيلين في نفس الوقت
3. **الانتظار حتى انتهاء الفترة**: يجب الانتظار 30 يوم بعد آخر تأجيل قبل إمكانية الاستخدام مرة أخرى

---

## 🔄 كيف يعمل النظام؟

### 1. التحقق من إمكانية التأجيل (`canPostponeForFree`)

```typescript
// يتحقق من آخر تأجيل مجاني للمستخدم
const lastFreePostponement = await findLastFreePostponement(userId);

// إذا لم يوجد تأجيل سابق → يمكن التأجيل
if (!lastFreePostponement) return true;

// حساب الأيام منذ آخر تأجيل
const daysSinceLastPostpone = calculateDaysSince(lastPostponement);

// إذا مضى 30 يوم أو أكثر → يمكن التأجيل
return daysSinceLastPostpone >= 30;
```

### 2. حساب الأيام المتبقية (`getDaysUntilNextPostpone`)

```typescript
// إذا لم يوجد تأجيل → متاح الآن (0)
if (!lastPostponement) return 0;

// حساب الأيام المتبقية
const daysRemaining = 30 - daysSinceLastPostpone;

// إذا كان متاحاً → 0، وإلا → عدد الأيام المتبقية
return daysRemaining > 0 ? daysRemaining : 0;
```

### 3. تنفيذ التأجيل (`postponeForFree`)

```typescript
// 1. التحقق المزدوج من إمكانية التأجيل (منع race conditions)
const canPostpone = await canPostponeForFree(userId);

// 2. التحقق من حالة الدفعة
if (payment.status !== 'pending') throw error;
if (payment.isPostponed) throw error; // منع التأجيل المزدوج لنفس الدفعة

// 3. تحديث الدفعة
await postponePayment(paymentId, 10); // due_date يبقى كما هو، postponed_due_date يتغير

// 4. حفظ التأجيل في التاريخ
await savePostponement(userId, paymentId, ...);
```

---

## 🛡️ الحماية من المشاكل

### 1. **منع التأجيل المتزامن**

- ✅ التحقق من `isPostponed` قبل التأجيل
- ✅ التحقق المزدوج في `postponeForFree` (منع race conditions)
- ✅ استخدام `created_at` لتتبع تاريخ آخر استخدام

### 2. **منع التأجيل المزدوج لنفس الدفعة**

```typescript
if (payment.isPostponed) {
  throw new BadRequestException('تم تأجيل هذه المعاملة مسبقاً');
}
```

### 3. **منع التأجيل المتكرر (أقل من 30 يوم)**

```typescript
const daysSinceLastPostpone = dayjs().diff(
  dayjs(lastPostponement.createdAt),
  'day',
);

if (daysSinceLastPostpone < 30) {
  throw new BadRequestException(`التأجيل التالي متاح بعد ${daysRemaining} يوم`);
}
```

---

## 📊 مثال على الاستخدام

### السيناريو 1: استخدام أول مرة
```
User: 8
Date: 2025-11-03
Action: تأجيل الدفعة 13
Result: ✅ نجح
Next Available: 2025-12-03 (بعد 30 يوم)
```

### السيناريو 2: محاولة استخدام قبل 30 يوم
```
User: 8
Date: 2025-11-10 (7 أيام فقط)
Action: تأجيل الدفعة 14
Result: ❌ فشل - "التأجيل التالي متاح بعد 23 يوم"
```

### السيناريو 3: استخدام بعد 30 يوم
```
User: 8
Date: 2025-12-05 (32 يوم)
Action: تأجيل الدفعة 15
Result: ✅ نجح
Next Available: 2026-01-04 (بعد 30 يوم)
```

---

## 🔍 البيانات المخزنة

### جدول `postponements`
```sql
- id: رقم التأجيل
- user_id: رقم المستخدم
- payment_id: رقم الدفعة
- original_due_date: تاريخ الاستحقاق الأصلي
- new_due_date: تاريخ الاستحقاق الجديد
- days_postponed: عدد الأيام (10)
- is_free: true (تأجيل مجاني)
- created_at: تاريخ الاستخدام
```

### جدول `payments`
```sql
- due_date: تاريخ الاستحقاق الأصلي (لا يتغير)
- postponed_due_date: تاريخ الاستحقاق الجديد (يُحدث)
- is_postponed: true (بعد التأجيل)
- postponed_days: 10
```

---

## 🎯 الفوائد

1. **عدالة الاستخدام**: كل مستخدم لديه نفس الفرصة (مرة كل 30 يوم)
2. **منع الإساءة**: لا يمكن استخدام التأجيل بشكل متكرر
3. **شفافية**: رسائل واضحة توضح متى يمكن استخدام التأجيل التالي
4. **أمان**: تحقق مزدوج يمنع race conditions

---

## 📝 ملاحظات مهمة

- `due_date` في جدول `payments` **لا يتغير أبداً** (التاريخ الأصلي)
- `postponed_due_date` هو الذي يتغير عند التأجيل
- يمكن للمستخدم تأجيل دفعات مختلفة في أوقات مختلفة (بعد 30 يوم)
- لا يمكن تأجيل نفس الدفعة مرتين
- النظام يحسب الأيام من `created_at` في جدول `postponements`

---

## 🔧 للمطورين

### إعادة تعيين الحالة (للاختبار)
```sql
DELETE FROM postponements WHERE user_id = 8;
UPDATE payments SET is_postponed = 0, postponed_days = NULL, postponed_due_date = NULL WHERE user_id = 8;
```

### التحقق من حالة التأجيل
```sql
SELECT 
  id, 
  user_id, 
  payment_id, 
  created_at,
  DATEDIFF(NOW(), created_at) as days_since_last_postpone,
  CASE 
    WHEN DATEDIFF(NOW(), created_at) >= 30 THEN 'Available'
    ELSE CONCAT(30 - DATEDIFF(NOW(), created_at), ' days remaining')
  END as status
FROM postponements 
WHERE user_id = 8 AND is_free = 1
ORDER BY created_at DESC
LIMIT 1;
```

