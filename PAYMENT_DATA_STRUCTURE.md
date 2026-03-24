# 📊 بنية بيانات المدفوعات المعلقة

## 🔍 Backend Response Structure

### Endpoint: `GET /api/v1/payments/pending`

**Response Format:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "userId": 8,
      "storeId": 5,
      "orderId": "ORD-12345",
      "amount": 150.50,
      "currency": "JOD",
      "paymentMethod": "credit_card",
      "status": "pending",
      "commission": 7.50,
      "storeAmount": 143.00,
      "transactionId": "TXN-ABC123",
      "storeTransactionId": null,
      "userTransactionId": null,
      "dueDate": "2025-11-15T00:00:00.000Z",
      "paidAt": null,
      "extensionRequested": false,
      "extensionDays": null,
      "notes": null,
      "createdAt": "2025-10-15T10:30:00.000Z",
      "updatedAt": "2025-10-15T10:30:00.000Z",
      "store": {
        "id": 5,
        "name": "Store Name",
        "nameAr": "اسم المتجر",
        "logoUrl": "https://example.com/logo.png",
        "description": "Store description",
        "descriptionAr": "وصف المتجر",
        "category": "Electronics",
        "rating": 4.5,
        "hasDeal": true,
        "dealDescription": "Special offer",
        "dealDescriptionAr": "عرض خاص",
        "commissionRate": 5.00,
        "minOrderAmount": 10.00,
        "maxOrderAmount": 1000.00,
        "websiteUrl": "https://store.com",
        "supportedCountries": ["JO", "AE"],
        "supportedCurrencies": ["JOD", "USD"],
        "isActive": true,
        "createdAt": "2025-01-01T00:00:00.000Z",
        "updatedAt": "2025-01-01T00:00:00.000Z"
      }
    }
  ]
}
```

## 📝 ملاحظات مهمة

### 1. أسماء الحقول
- ✅ Backend يستخدم **camelCase** في JSON response (TypeORM default)
- ✅ `dueDate` (وليس `due_date`)
- ✅ `storeId` (وليس `store_id`)
- ✅ `createdAt` (وليس `created_at`)

### 2. العلاقات (Relations)
- ✅ `store` موجود كـ object كامل (بسبب `relations: ['store']`)
- ✅ يمكن الوصول: `payment.store.name` أو `payment.store.nameAr`

### 3. الحقول الرقمية
- ✅ `amount` هو `decimal(10,2)` في Database
- ✅ TypeORM يرجعه كـ `number` في JavaScript/JSON
- ✅ Flutter يستقبله كـ `double`

## 🔧 Flutter Code Mapping

### Current Code (payments_page.dart):
```dart
final amount = (p['amount'] ?? 0).toDouble(); // ✅ صحيح
final dueDate = DateTime.parse(p['dueDate']); // ✅ صحيح (camelCase)
'merchant': p['store']?['name'] ?? p['storeName'] ?? 'Unknown', // ✅ صحيح
'storeId': p['store']?['id'] ?? p['storeId'], // ✅ صحيح
```

## ✅ الخلاصة

**الكود مربوط بشكل صحيح!** 

- ✅ Backend endpoint موجود: `/payments/pending`
- ✅ Service يستعلم من Database بشكل صحيح
- ✅ Flutter يستقبل البيانات بشكل صحيح
- ✅ Mapping الحقول صحيح (camelCase)

**المشكلة الوحيدة:**
- ⚠️ قاعدة البيانات فارغة (0 payments) - لا توجد بيانات للاختبار

## 🧪 للاختبار

يمكن إضافة بيانات تجريبية:

```sql
INSERT INTO payments (user_id, store_id, amount, currency, payment_method, status, due_date)
VALUES 
  (8, 1, 150.50, 'JOD', 'credit_card', 'pending', DATE_ADD(NOW(), INTERVAL 7 DAY)),
  (8, 2, 200.00, 'JOD', 'debit_card', 'pending', DATE_ADD(NOW(), INTERVAL 15 DAY)),
  (8, 3, 75.25, 'JOD', 'credit_card', 'pending', DATE_ADD(NOW(), INTERVAL 30 DAY));
```

