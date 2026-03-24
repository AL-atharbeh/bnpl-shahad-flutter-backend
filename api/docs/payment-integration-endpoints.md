# Payment Integration Endpoints

## نظرة عامة

هذا الملف يوثق جميع الـ endpoints المتعلقة بتكامل الدفع مع المتاجر.

## Store Integration Endpoints

### 1. طلب انضمام متجر

**POST** `/api/v1/stores/integration/request`

طلب انضمام متجر جديد للتطبيق.

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
    "requestId": "integration_request_1705748400000",
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

### 2. فحص حالة طلب الانضمام

**GET** `/api/v1/stores/integration/status/{requestId}`

فحص حالة طلب انضمام متجر.

**Response:**
```json
{
  "success": true,
  "data": {
    "requestId": "integration_request_1705748400000",
    "status": "under_review",
    "submittedAt": "2024-01-20T10:30:00Z",
    "estimatedCompletion": "2024-01-27T10:30:00Z",
    "currentStep": "مراجعة الطلب",
    "nextStep": "التواصل مع المتجر"
  }
}
```

### 3. تفعيل التكامل مع المتجر

**POST** `/api/v1/stores/integration/activate`

تفعيل التكامل مع متجر (للمدير).

**Request Body:**
```json
{
  "storeId": 3,
  "integrationData": {
    "storeName": "زارا",
    "supportedCountries": ["JO", "SA", "AE"],
    "supportedCurrencies": ["JOD", "SAR", "AED"],
    "website": "https://www.zara.com"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1705748400000,
    "storeId": 3,
    "storeName": "زارا",
    "integrationStatus": "active",
    "integrationType": "payment_gateway",
    "supportedCountries": ["JO", "SA", "AE"],
    "supportedCurrencies": ["JOD", "SAR", "AED"],
    "commissionRate": 2.5,
    "minOrderAmount": 50,
    "maxOrderAmount": 5000,
    "paymentMethods": ["credit_card", "debit_card", "bank_transfer"],
    "webhookUrl": "https://www.zara.com/webhooks/bnpl",
    "apiCredentials": {
      "merchantId": "zara_merchant_1705748400000",
      "apiKey": "zara_api_key_1705748400000",
      "webhookSecret": "zara_webhook_secret_1705748400000"
    },
    "features": {
      "supportsInstallments": true,
      "supportsImmediatePayment": true,
      "supportsDeferredPayment": false,
      "autoApproval": true
    },
    "agreement": {
      "signedAt": "2024-01-20T10:30:00Z",
      "validUntil": "2025-01-20T10:30:00Z",
      "terms": "https://bnpl.com/terms/zara",
      "commissionStructure": "percentage"
    }
  }
}
```

### 4. قائمة المتاجر المتكاملة

**GET** `/api/v1/stores/integration/list`

جلب قائمة جميع المتاجر المتكاملة مع إحصائيات.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "storeName": "شي إن",
      "integrationStatus": "active",
      "supportedCountries": ["JO", "SA", "AE", "KW"],
      "supportedCurrencies": ["JOD", "SAR", "AED", "KWD"],
      "commissionRate": 2.5,
      "totalTransactions": 1250,
      "totalVolume": 187500.00
    },
    {
      "id": 2,
      "storeName": "أناس",
      "integrationStatus": "active",
      "supportedCountries": ["JO", "SA", "AE"],
      "supportedCurrencies": ["JOD", "SAR", "AED"],
      "commissionRate": 3.0,
      "totalTransactions": 890,
      "totalVolume": 133500.00
    }
  ]
}
```

### 5. تحديث إعدادات التكامل

**PUT** `/api/v1/stores/integration/{storeId}/settings`

تحديث إعدادات التكامل مع متجر.

**Request Body:**
```json
{
  "commissionRate": 3.0,
  "minOrderAmount": 100,
  "maxOrderAmount": 3000
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "storeId": 1,
    "storeName": "شي إن",
    "integrationStatus": "active",
    "commissionRate": 3.0,
    "minOrderAmount": 100,
    "maxOrderAmount": 3000
  }
}
```

### 6. استقبال Webhooks

**POST** `/api/v1/stores/integration/{storeId}/webhook`

استقبال webhooks من المتجر.

**Request Body:**
```json
{
  "event": "order.status_changed",
  "orderId": "zara_order_456",
  "status": "shipped",
  "trackingNumber": "TRK123456789"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Webhook processed successfully"
}
```

## Payment Integration Endpoints

### 1. إنشاء جلسة دفع

**POST** `/api/v1/payment/session/create`

إنشاء جلسة دفع جديدة.

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
    "sessionId": "payment_session_1705748400000",
    "redirectUrl": "https://bnpl.com/payment/confirm/payment_session_1705748400000",
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

**Error Responses:**

**STORE_NOT_INTEGRATED:**
```json
{
  "success": false,
  "error": {
    "code": "STORE_NOT_INTEGRATED",
    "message": "المتجر غير متكامل مع BNPL"
  }
}
```

**COUNTRY_NOT_SUPPORTED:**
```json
{
  "success": false,
  "error": {
    "code": "COUNTRY_NOT_SUPPORTED",
    "message": "BNPL غير متاح في بلدك"
  }
}
```

### 2. معالجة الدفع

**POST** `/api/v1/payment/session/{sessionId}/process`

معالجة الدفع في جلسة محددة.

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
    "transactionId": "transaction_1705748400000",
    "status": "completed",
    "amount": 150.00,
    "commission": 3.75,
    "storeAmount": 146.25,
    "redirectUrl": "https://zara.com/order/success?orderId=zara_order_456"
  }
}
```

**Error Responses:**

**SESSION_NOT_FOUND:**
```json
{
  "success": false,
  "error": {
    "code": "SESSION_NOT_FOUND",
    "message": "جلسة الدفع غير موجودة"
  }
}
```

**SESSION_EXPIRED:**
```json
{
  "success": false,
  "error": {
    "code": "SESSION_EXPIRED",
    "message": "جلسة الدفع منتهية الصلاحية"
  }
}
```

### 3. جلب تفاصيل المعاملة

**GET** `/api/v1/payment/transaction/{transactionId}`

جلب تفاصيل معاملة دفع محددة.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "transaction_1705748400000",
    "paymentSessionId": "payment_session_1705748400000",
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
    "transactionId": "bnpl_txn_1705748400000",
    "storeTransactionId": "zara_txn_1705748400000",
    "userTransactionId": "user_txn_1705748400000",
    "createdAt": "2024-01-20T10:35:00Z",
    "completedAt": "2024-01-20T10:36:00Z"
  }
}
```

## تدفق العملية الكامل

### 1. انضمام المتجر
```
POST /stores/integration/request → GET /stores/integration/status/{requestId} → POST /stores/integration/activate
```

### 2. عملية الدفع
```
POST /payment/session/create → POST /payment/session/{sessionId}/process → GET /payment/transaction/{transactionId}
```

### 3. إدارة التكامل
```
GET /stores/integration/list → PUT /stores/integration/{storeId}/settings → POST /stores/integration/{storeId}/webhook
```

## ملاحظات مهمة

### الأمان:
- جميع الـ endpoints تتطلب authentication
- يتم التحقق من صلاحيات المستخدم
- يتم تشفير البيانات الحساسة

### التحقق:
- التحقق من دعم البلد للـ BNPL
- التحقق من صحة جلسة الدفع
- التحقق من حالة المتجر

### الأخطاء:
- جميع الأخطاء تتبع نفس التنسيق
- يتم إرجاع رسائل خطأ واضحة بالعربية
- يتم تسجيل جميع الأخطاء للتحليل
