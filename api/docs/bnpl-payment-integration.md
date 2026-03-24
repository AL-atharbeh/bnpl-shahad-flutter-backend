# نموذج دمج BNPL مع المتاجر

## نظرة عامة

هذا الملف يوضح كيفية دمج BNPL مع المتاجر كخيار دفع.

## الفكرة الأساسية

### 1. انضمام المتاجر
- المتجر يطلب الانضمام للتطبيق
- يتم الاتفاق على الشروط
- يتم إضافة المتجر لقائمة المتاجر المدعومة

### 2. عملية الدفع
- المستخدم يشتري من المتجر
- في صفحة الدفع، يظهر "BNPL" كخيار دفع
- المستخدم يختار BNPL
- التطبيق يدفع للمتجر مباشرة
- يتم خصم المبلغ من المستخدم فوراً

### 3. التوزيع الجغرافي
- خيار BNPL لا يظهر في جميع الدول
- يظهر فقط في الدول المدعومة

## هيكل البيانات

### Store Integration Object
```json
{
  "id": 1,
  "storeId": 1,
  "storeName": "زارا",
  "integrationStatus": "active",
  "integrationType": "payment_gateway",
  "supportedCountries": ["JO", "SA", "AE", "KW"],
  "supportedCurrencies": ["JOD", "SAR", "AED", "KWD"],
  "commissionRate": 2.5,
  "minOrderAmount": 50,
  "maxOrderAmount": 5000,
  "paymentMethods": ["credit_card", "debit_card", "bank_transfer"],
  "webhookUrl": "https://zara.com/webhooks/bnpl",
  "apiCredentials": {
    "merchantId": "zara_merchant_123",
    "apiKey": "zara_api_key_456",
    "webhookSecret": "zara_webhook_secret_789"
  },
  "features": {
    "supportsInstallments": true,
    "supportsImmediatePayment": true,
    "supportsDeferredPayment": false,
    "autoApproval": true
  },
  "agreement": {
    "signedAt": "2024-01-15T10:30:00Z",
    "validUntil": "2025-01-15T10:30:00Z",
    "terms": "https://bnpl.com/terms/zara",
    "commissionStructure": "percentage"
  }
}
```

### Payment Session Object
```json
{
  "id": "payment_session_123",
  "storeId": 1,
  "storeName": "زارا",
  "userId": 1,
  "orderId": "zara_order_456",
  "amount": 150.00,
  "currency": "JOD",
  "items": [
    {
      "productId": "zara_product_789",
      "name": "فستان أسود",
      "quantity": 1,
      "price": 150.00
    }
  ],
  "paymentMethod": "bnpl_immediate",
  "status": "pending",
  "createdAt": "2024-01-20T10:30:00Z",
  "expiresAt": "2024-01-20T11:30:00Z",
  "redirectUrl": "https://bnpl.com/payment/confirm/session_123",
  "webhookUrl": "https://zara.com/webhooks/bnpl/payment_123"
}
```

### Payment Transaction Object
```json
{
  "id": "transaction_123",
  "paymentSessionId": "payment_session_123",
  "storeId": 1,
  "userId": 1,
  "orderId": "zara_order_456",
  "amount": 150.00,
  "currency": "JOD",
  "paymentMethod": "bnpl_immediate",
  "status": "completed",
  "storePaymentStatus": "paid",
  "userPaymentStatus": "charged",
  "commission": 3.75,
  "storeAmount": 146.25,
  "transactionId": "bnpl_txn_789",
  "storeTransactionId": "zara_txn_456",
  "userTransactionId": "user_txn_123",
  "createdAt": "2024-01-20T10:35:00Z",
  "completedAt": "2024-01-20T10:36:00Z"
}
```

## الـ API Endpoints

### Store Integration

#### POST /stores/integration/request
طلب انضمام متجر للتطبيق

**Request Body:**
```json
{
  "storeName": "زارا",
  "website": "https://www.zara.com",
  "contactEmail": "partnership@zara.com",
  "contactPhone": "+962791234567",
  "supportedCountries": ["JO", "SA", "AE"],
  "supportedCurrencies": ["JOD", "SAR", "AED"],
  "estimatedMonthlyOrders": 1000,
  "averageOrderValue": 200
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "requestId": "integration_request_123",
    "status": "pending",
    "estimatedReviewTime": "5-7 business days",
    "nextSteps": [
      "سيتم مراجعة طلبك",
      "سيتم التواصل معك عبر البريد الإلكتروني",
      "سيتم إرسال اتفاقية الشراكة"
    ]
  }
}
```

#### GET /stores/integration/status/{requestId}
فحص حالة طلب الانضمام

#### POST /stores/integration/activate
تفعيل التكامل مع المتجر (للمدير)

### Payment Integration

#### POST /payment/session/create
إنشاء جلسة دفع

**Request Body:**
```json
{
  "storeId": 1,
  "orderId": "zara_order_456",
  "amount": 150.00,
  "currency": "JOD",
  "items": [
    {
      "productId": "zara_product_789",
      "name": "فستان أسود",
      "quantity": 1,
      "price": 150.00
    }
  ],
  "userCountry": "JO",
  "userCurrency": "JOD"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "sessionId": "payment_session_123",
    "redirectUrl": "https://bnpl.com/payment/confirm/session_123",
    "expiresAt": "2024-01-20T11:30:00Z",
    "supportedPaymentMethods": [
      {
        "type": "bnpl_immediate",
        "name": "BNPL الدفع الفوري",
        "description": "ادفع الآن واحصل على خصم 5%"
      }
    ]
  }
}
```

#### POST /payment/session/{sessionId}/process
معالجة الدفع

**Request Body:**
```json
{
  "paymentMethod": "bnpl_immediate",
  "userCardToken": "user_card_token_123",
  "installmentPlan": null
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "transactionId": "transaction_123",
    "status": "completed",
    "amount": 150.00,
    "commission": 3.75,
    "storeAmount": 146.25,
    "redirectUrl": "https://zara.com/order/success?orderId=zara_order_456"
  }
}
```

#### GET /payment/transaction/{transactionId}
جلب تفاصيل المعاملة

### Store Management

#### GET /stores/integration/list
قائمة المتاجر المتكاملة

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "storeName": "زارا",
      "integrationStatus": "active",
      "supportedCountries": ["JO", "SA", "AE"],
      "supportedCurrencies": ["JOD", "SAR", "AED"],
      "commissionRate": 2.5,
      "totalTransactions": 1250,
      "totalVolume": 187500.00
    }
  ]
}
```

#### PUT /stores/integration/{storeId}/settings
تحديث إعدادات التكامل

#### POST /stores/integration/{storeId}/webhook
استقبال webhooks من المتجر

## تدفق العملية

### 1. انضمام المتجر
```
المتجر يطلب الانضمام → مراجعة الطلب → الموافقة → توقيع الاتفاقية → تفعيل التكامل
```

### 2. عملية الشراء
```
المستخدم يشتري من المتجر → اختيار BNPL → إنشاء جلسة دفع → معالجة الدفع → إتمام الطلب
```

### 3. معالجة الدفع
```
التطبيق يدفع للمتجر → خصم المبلغ من المستخدم → إرسال تأكيد للمتجر → إتمام المعاملة
```

## ملاحظات مهمة

### للمتاجر:
- **يجب أن يكون لديهم API** لاستقبال المدفوعات
- **يجب أن يدعموا webhooks** لإرسال تحديثات الطلبات
- **يتم خصم عمولة** على كل معاملة

### للمستخدمين:
- **الدفع فوري** عند اختيار BNPL
- **يتم خصم المبلغ** من البطاقة مباشرة
- **يمكن الحصول على خصم** عند الدفع الفوري

### للتطبيق:
- **يعمل كوسيط دفع** بين المستخدم والمتجر
- **يجب أن يكون مرخص** كشركة خدمات مالية
- **يجب أن يتبع قوانين** حماية المستهلك
