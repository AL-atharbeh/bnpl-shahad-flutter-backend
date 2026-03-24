# 🔍 التحقق من ظهور حقول التأجيل

## ✅ الحقول موجودة في قاعدة البيانات

```sql
SELECT id, is_postponed, postponed_days, postponed_due_date 
FROM payments 
WHERE user_id = 8;
```

**النتيجة:**
```
id | is_postponed | postponed_days | postponed_due_date
13 | 0            | NULL           | NULL
14 | 0            | NULL           | NULL
15 | 0            | NULL           | NULL
```

---

## 📊 Backend Logs

عند استدعاء `/api/v1/payments/pending`، يجب أن ترى:

```
[PaymentsService] Found 3 pending payments for user 8
  Payment 1: ID=13, Amount=150.5, Store=Test Store 1
    Postponement: isPostponed=false, postponedDays=null, postponedDueDate=null
  Payment 2: ID=15, Amount=75.25, Store=Fashion Store
    Postponement: isPostponed=false, postponedDays=null, postponedDueDate=null
  Payment 3: ID=14, Amount=250, Store=Electronics Store
    Postponement: isPostponed=false, postponedDays=null, postponedDueDate=null

[PaymentsController] Sample payment fields: {
  id: 13,
  isPostponed: false,
  postponedDays: null,
  postponedDueDate: null
}
```

---

## 📱 Flutter Logs

في Flutter Console، يجب أن ترى:

```
📊 [PaymentsPage] Received 3 payments from backend
  Payment 1: ID=13, Amount=150.5, Store=Test Store 1
    Postponement fields: isPostponed=false, postponedDays=null, postponedDueDate=null
    All payment keys: [id, userId, storeId, orderId, amount, currency, paymentMethod, status, commission, storeAmount, transactionId, storeTransactionId, userTransactionId, dueDate, paidAt, extensionRequested, extensionDays, isPostponed, postponedDays, postponedDueDate, notes, createdAt, updatedAt, store]
```

---

## 🔧 كيفية التحقق

### 1. افتح Flutter App
- شغل التطبيق
- افتح صفحة "المدفوعات المعلقة"
- افتح Console/Logs

### 2. تحقق من Logs
- يجب أن ترى `Postponement fields` في كل دفعة
- يجب أن ترى `isPostponed`, `postponedDays`, `postponedDueDate` في `All payment keys`

### 3. إذا لم تظهر الحقول

#### المشكلة المحتملة 1: TypeORM لا يحمل الحقول
**الحل**: إعادة تشغيل Backend
```bash
cd backend
docker-compose restart app
```

#### المشكلة المحتملة 2: Entity غير محدث
**الحل**: تأكد من أن `payment.entity.ts` يحتوي على:
```typescript
@Column({ name: 'is_postponed', default: false })
isPostponed: boolean;

@Column({ name: 'postponed_days', nullable: true })
postponedDays: number;

@Column({ name: 'postponed_due_date', type: 'timestamp', nullable: true })
postponedDueDate: Date;
```

#### المشكلة المحتملة 3: JSON Serialization
**الحل**: NestJS يقوم بـ serialize تلقائياً. إذا لم تظهر، تحقق من:
- هل الحقول موجودة في Entity؟
- هل تم إعادة تشغيل Backend؟
- هل TypeORM يحمل الحقول من قاعدة البيانات؟

---

## ✅ اختبار API مباشرة

```bash
curl -X GET "http://localhost:3000/api/v1/payments/pending" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  | jq '.data[0] | {id, isPostponed, postponedDays, postponedDueDate}'
```

**النتيجة المتوقعة:**
```json
{
  "id": 13,
  "isPostponed": false,
  "postponedDays": null,
  "postponedDueDate": null
}
```

---

## 🎯 بعد التأجيل

عند استدعاء `POST /api/v1/payments/13/postpone` مع `{"daysToPostpone": 10}`:

```json
{
  "id": 13,
  "isPostponed": true,
  "postponedDays": 10,
  "postponedDueDate": "2025-11-20T20:13:53.000Z",
  "dueDate": "2025-11-20T20:13:53.000Z"
}
```

---

## 📝 ملاحظات

- الحقول موجودة في قاعدة البيانات ✅
- Entity محدث ✅
- Service method موجود ✅
- Controller endpoint موجود ✅
- Logging مضاف ✅

**إذا لم تظهر الحقول بعد كل هذا، أرسل:**
1. Backend logs من `/api/v1/payments/pending`
2. Flutter logs من Console
3. API response من curl أو Postman

