# 📋 حقول التأجيل في جدول Payments

## ✅ الحقول المضافة

تم إضافة 3 حقول جديدة في جدول `payments` للتأجيل لمرة واحدة:

### 1. `is_postponed` (BOOLEAN)
- **الوصف**: يشير إلى أن التأجيل تم تفعيله لهذه الدفعة
- **النوع**: `BOOLEAN` (tinyint)
- **الافتراضي**: `FALSE`
- **المثال**: `true` = تم التأجيل، `false` = لم يتم التأجيل

### 2. `postponed_days` (INT)
- **الوصف**: عدد الأيام المؤجلة
- **النوع**: `INT` (nullable)
- **الافتراضي**: `NULL`
- **المثال**: `10` = تم التأجيل لمدة 10 أيام

### 3. `postponed_due_date` (TIMESTAMP)
- **الوصف**: التاريخ الجديد المستحق بعد التأجيل
- **النوع**: `TIMESTAMP` (nullable)
- **الافتراضي**: `NULL`
- **المثال**: `2025-11-20 10:00:00` = التاريخ الجديد للاستحقاق

---

## 🔧 كيفية الاستخدام

### في Backend (TypeScript):

```typescript
// في Payment Entity
@Column({ name: 'is_postponed', default: false })
isPostponed: boolean;

@Column({ name: 'postponed_days', nullable: true })
postponedDays: number;

@Column({ name: 'postponed_due_date', type: 'timestamp', nullable: true })
postponedDueDate: Date;
```

### في Service:

```typescript
// Postpone payment
async postponePayment(paymentId: number, daysToPostpone: number): Promise<Payment> {
  const payment = await this.getPaymentById(paymentId);
  
  // Calculate new due date
  const newDueDate = dayjs(payment.dueDate).add(daysToPostpone, 'day').toDate();
  
  // Update payment fields
  payment.dueDate = newDueDate;
  payment.isPostponed = true;          // ✅ تم التفعيل
  payment.postponedDays = daysToPostpone;  // ✅ عدد الأيام
  payment.postponedDueDate = newDueDate;    // ✅ التاريخ الجديد
  
  return this.paymentRepository.save(payment);
}
```

---

## 📡 API Endpoint

### POST `/api/v1/payments/:id/postpone`

**Request Body:**
```json
{
  "daysToPostpone": 10
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تأجيل الدفعة بنجاح لمدة 10 أيام",
  "data": {
    "payment": { ... },
    "isPostponed": true,
    "postponedDays": 10,
    "postponedDueDate": "2025-11-20T10:00:00.000Z",
    "newDueDate": "2025-11-20T10:00:00.000Z"
  }
}
```

---

## 🔍 التحقق من الحقول

### SQL Query:
```sql
SELECT 
  id,
  amount,
  due_date AS original_due_date,
  is_postponed,
  postponed_days,
  postponed_due_date AS new_due_date
FROM payments
WHERE id = 13;
```

### النتيجة المتوقعة:
```
id | amount | original_due_date | is_postponed | postponed_days | new_due_date
---|--------|-------------------|--------------|----------------|-------------
13 | 150.50 | 2025-11-10        | 1            | 10             | 2025-11-20
```

---

## ⚠️ قواعد التأجيل

1. **للمرة الواحدة فقط**: إذا كان `is_postponed = true`، لا يمكن التأجيل مرة أخرى
2. **حالة الدفعة**: يجب أن تكون `status = 'pending'`
3. **التاريخ الأصلي**: يتم حفظه في `due_date` قبل التأجيل
4. **التاريخ الجديد**: يتم حفظه في `postponed_due_date` و `due_date`

---

## 📝 ملاحظات

- ✅ الحقول موجودة في قاعدة البيانات
- ✅ Entity محدث
- ✅ Service method جاهز (`postponePayment`)
- ✅ Controller endpoint جاهز (`POST /api/v1/payments/:id/postpone`)
- ✅ Integration مع `postponeForFree` موجود

---

## 🚀 الاستخدام في Flutter

```dart
// Call postpone endpoint
final response = await apiService.post(
  '/payments/$paymentId/postpone',
  {'daysToPostpone': 10}
);

if (response['success']) {
  final payment = response['data']['payment'];
  print('تم التأجيل: ${payment['isPostponed']}');
  print('عدد الأيام: ${payment['postponedDays']}');
  print('التاريخ الجديد: ${payment['postponedDueDate']}');
}
```

