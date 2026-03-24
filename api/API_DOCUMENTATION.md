# BNPL API Documentation

## نظرة عامة
هذا التوثيق يغطي جميع الـ APIs المتاحة في تطبيق BNPL. جميع الـ APIs تعيد استجابة بتنسيق JSON مع حقل `success` للإشارة إلى نجاح أو فشل العملية.

## Base URL
```
http://localhost:3000/api/v1
```

## Authentication
معظم الـ APIs تتطلب مصادقة. أرسل `user-id` في headers:
```
user-id: 1
```

---

## 🔐 Authentication APIs

### 1. تسجيل مستخدم جديد
**POST** `/auth/register`

**Body:**
```json
{
  "name": "أحمد محمد",
  "email": "ahmed@example.com",
  "phone": "+962791234567",
  "password": "password123",
  "country": "JO",
  "currency": "JOD"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء الحساب بنجاح",
  "data": {
    "user": {
      "id": 1234567890,
      "name": "أحمد محمد",
      "email": "ahmed@example.com",
      "phone": "+962791234567",
      "isEmailVerified": false,
      "isPhoneVerified": false
    },
    "requiresVerification": true
  }
}
```

### 2. تسجيل الدخول
**POST** `/auth/login`

**Body:**
```json
{
  "phone": "+962791234567",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تسجيل الدخول بنجاح",
  "data": {
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "email": "ahmed@example.com",
      "phone": "+962791234567",
      "avatar": null,
      "isEmailVerified": true,
      "isPhoneVerified": true,
      "country": "JO",
      "currency": "JOD",
      "role": "user"
    },
    "token": "jwt_token_1_1234567890",
    "expiresIn": "7d"
  }
}
```

### 3. إرسال رمز التحقق
**POST** `/auth/send-otp`

**Body:**
```json
{
  "phone": "+962791234567"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إرسال رمز التحقق",
  "data": {
    "phone": "+962791234567",
    "expiresIn": "5 minutes"
  }
}
```

### 4. التحقق من رمز التحقق
**POST** `/auth/verify-otp`

**Body:**
```json
{
  "phone": "+962791234567",
  "code": "1234"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم التحقق من رقم الهاتف بنجاح",
  "data": {
    "phone": "+962791234567",
    "isVerified": true
  }
}
```

### 5. نسيت كلمة المرور
**POST** `/auth/forgot-password`

**Body:**
```json
{
  "phone": "+962791234567"
}
```
أو
```json
{
  "email": "ahmed@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إرسال رمز التحقق إلى رقم هاتفك",
  "data": {
    "contactInfo": "+962791234567",
    "expiresIn": "1 hour"
  }
}
```

### 6. إعادة تعيين كلمة المرور
**POST** `/auth/reset-password`

**Body:**
```json
{
  "token": "reset_token_1234567890",
  "newPassword": "newpassword123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إعادة تعيين كلمة المرور بنجاح",
  "data": {
    "userId": 1
  }
}
```

### 7. جلب الملف الشخصي
**GET** `/auth/profile`

**Headers:**
```
user-id: 1
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "email": "ahmed@example.com",
      "phone": "+962791234567",
      "avatar": null,
      "isEmailVerified": true,
      "isPhoneVerified": true,
      "country": "JO",
      "currency": "JOD",
      "role": "user",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  }
}
```

### 8. تحديث الملف الشخصي
**PUT** `/auth/profile`

**Headers:**
```
user-id: 1
```

**Body:**
```json
{
  "name": "أحمد محمد الجديد",
  "email": "ahmed.new@example.com",
  "avatar": "https://example.com/avatar.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تحديث الملف الشخصي بنجاح",
  "data": {
    "user": {
      "id": 1,
      "name": "أحمد محمد الجديد",
      "email": "ahmed.new@example.com",
      "phone": "+962791234567",
      "avatar": "https://example.com/avatar.jpg",
      "isEmailVerified": true,
      "isPhoneVerified": true,
      "country": "JO",
      "currency": "JOD",
      "role": "user"
    }
  }
}
```

### 9. تسجيل الخروج
**POST** `/auth/logout`

**Response:**
```json
{
  "success": true,
  "message": "تم تسجيل الخروج بنجاح"
}
```

---

## 💳 Payment APIs

### 1. جلب مدفوعات المستخدم
**GET** `/payments`

**Headers:**
```
user-id: 1
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "transaction_124",
      "paymentSessionId": "payment_session_124",
      "storeId": 2,
      "userId": 1,
      "orderId": "annas_order_789",
      "amount": 89.99,
      "currency": "JOD",
      "paymentMethod": "bnpl_immediate",
      "status": "pending",
      "storePaymentStatus": "pending",
      "userPaymentStatus": "pending",
      "commission": 2.25,
      "storeAmount": 87.74,
      "transactionId": "bnpl_txn_790",
      "storeTransactionId": "annas_txn_789",
      "userTransactionId": "user_txn_124",
      "createdAt": "2024-01-25T10:35:00Z",
      "dueDate": "2024-02-25T10:35:00Z",
      "extensionRequested": false,
      "extensionDays": null
    }
  ]
}
```

### 2. جلب المدفوعات المعلقة
**GET** `/payments/pending`

**Headers:**
```
user-id: 1
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "transaction_124",
      "amount": 89.99,
      "currency": "JOD",
      "status": "pending",
      "dueDate": "2024-02-25T10:35:00Z",
      "storeName": "Annas"
    }
  ]
}
```

### 3. جلب سجل المدفوعات
**GET** `/payments/history?startDate=2024-01-01&endDate=2024-12-31&status=completed`

**Headers:**
```
user-id: 1
```

**Query Parameters:**
- `startDate`: تاريخ البداية (اختياري)
- `endDate`: تاريخ النهاية (اختياري)
- `status`: حالة الدفع (اختياري)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "transaction_123",
      "amount": 150.00,
      "currency": "JOD",
      "status": "completed",
      "createdAt": "2024-01-20T10:35:00Z",
      "completedAt": "2024-01-20T10:36:00Z"
    }
  ]
}
```

### 4. تمديد موعد الدفع
**POST** `/payments/:paymentId/extend`

**Headers:**
```
user-id: 1
```

**Body:**
```json
{
  "extensionDays": 21
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تمديد موعد الدفع بنجاح",
  "data": {
    "id": "transaction_124",
    "dueDate": "2024-03-18T10:35:00Z",
    "extensionRequested": true,
    "extensionDays": 21
  }
}
```

### 5. دفع مبلغ
**POST** `/payments/:paymentId/pay`

**Headers:**
```
user-id: 1
```

**Body:**
```json
{
  "amount": 89.99,
  "paymentMethod": "credit_card"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم الدفع بنجاح",
  "data": {
    "id": "transaction_124",
    "status": "completed",
    "paidAmount": 89.99,
    "paymentMethod": "credit_card",
    "paidAt": "2024-01-25T10:35:00Z"
  }
}
```

---

## 🏠 Home Page APIs

### 1. جلب بيانات الصفحة الرئيسية
**GET** `/home`

**Headers:**
```
user-id: 1
```

**Response:**
```json
{
  "success": true,
  "data": {
    "pendingPayments": [
      {
        "id": "transaction_124",
        "amount": 89.99,
        "currency": "JOD",
        "dueDate": "2024-02-25T10:35:00Z",
        "storeName": "Annas"
      }
    ],
    "topStores": [
      {
        "id": 1,
        "name": "Shein",
        "logo": "https://example.com/shein-logo.png",
        "rating": 4.5,
        "category": "fashion"
      }
    ],
    "bestOffers": [
      {
        "id": 2,
        "name": "Annas",
        "logo": "https://example.com/annas-logo.png",
        "hasDeal": true,
        "dealDescription": "خصم 15% على جميع المنتجات"
      }
    ],
    "totalPendingAmount": 285.74
  }
}
```

---

## 🔔 Notification APIs

### 1. جلب جميع الإشعارات
**GET** `/notifications?type=offer&isRead=false`

**Headers:**
```
user-id: 1
```

**Query Parameters:**
- `type`: نوع الإشعار (اختياري)
- `isRead`: حالة القراءة (اختياري)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "userId": 1,
      "title": "عرض خاص!",
      "message": "خصم 20% على جميع المنتجات في متجر شي إن",
      "type": "offer",
      "isRead": false,
      "createdAt": "2024-01-20T14:30:00Z"
    }
  ]
}
```

### 2. تحديد إشعار كمقروء
**PUT** `/notifications/:id/read`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "isRead": true
  }
}
```

### 3. تحديد جميع الإشعارات كمقروءة
**PUT** `/notifications/read-all`

**Headers:**
```
user-id: 1
```

**Response:**
```json
{
  "success": true,
  "message": "تم تحديد جميع الإشعارات كمقروءة"
}
```

### 4. حذف إشعار
**DELETE** `/notifications/:id`

**Response:**
```json
{
  "success": true,
  "message": "تم حذف الإشعار بنجاح"
}
```

---

## 🔍 Search APIs

### 1. البحث في المتاجر
**GET** `/search/stores?q=shein&category=fashion&hasDeal=true`

**Query Parameters:**
- `q`: نص البحث (اختياري)
- `category`: فئة المتجر (اختياري)
- `hasDeal`: هل يحتوي على عروض (اختياري)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Shein",
      "description": "متجر أزياء عالمي",
      "category": "fashion",
      "hasDeal": true,
      "rating": 4.5
    }
  ]
}
```

### 2. البحث في المنتجات
**GET** `/search/products?q=shirt&storeId=1&category=clothing&minPrice=10&maxPrice=100`

**Query Parameters:**
- `q`: نص البحث (اختياري)
- `storeId`: معرف المتجر (اختياري)
- `category`: فئة المنتج (اختياري)
- `minPrice`: الحد الأدنى للسعر (اختياري)
- `maxPrice`: الحد الأقصى للسعر (اختياري)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "product_1",
      "name": "قميص قطني",
      "description": "قميص قطني مريح",
      "price": 25.99,
      "currency": "JOD",
      "category": "clothing",
      "storeId": 1
    }
  ]
}
```

---

## 🎁 Offers APIs

### 1. جلب جميع العروض
**GET** `/offers`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 2,
      "name": "Annas",
      "logo": "https://example.com/annas-logo.png",
      "hasDeal": true,
      "dealDescription": "خصم 15% على جميع المنتجات",
      "rating": 4.3
    }
  ]
}
```

### 2. جلب العروض المميزة
**GET** `/offers/featured`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Shein",
      "logo": "https://example.com/shein-logo.png",
      "hasDeal": true,
      "dealDescription": "خصم 20% على جميع المنتجات",
      "rating": 4.5
    }
  ]
}
```

---

## 🏪 Store APIs

### 1. جلب جميع المتاجر
**GET** `/stores`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Shein",
      "logo": "https://example.com/shein-logo.png",
      "description": "متجر أزياء عالمي",
      "category": "fashion",
      "rating": 4.5,
      "hasDeal": true,
      "supportedCountries": ["JO", "SA", "AE"],
      "supportedCurrencies": ["JOD", "SAR", "AED"]
    }
  ]
}
```

### 2. جلب متجر محدد
**GET** `/stores/:id`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Shein",
    "logo": "https://example.com/shein-logo.png",
    "description": "متجر أزياء عالمي",
    "category": "fashion",
    "rating": 4.5,
    "hasDeal": true,
    "supportedCountries": ["JO", "SA", "AE"],
    "supportedCurrencies": ["JOD", "SAR", "AED"],
    "commissionRate": 2.5,
    "minOrderAmount": 50,
    "maxOrderAmount": 5000
  }
}
```

### 3. جلب منتجات متجر
**GET** `/stores/:storeId/products`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "product_1",
      "name": "قميص قطني",
      "description": "قميص قطني مريح",
      "price": 25.99,
      "currency": "JOD",
      "category": "clothing",
      "storeId": 1,
      "images": ["https://example.com/shirt1.jpg"],
      "inStock": true
    }
  ]
}
```

---

## 🛒 Product APIs

### 1. جلب منتج محدد
**GET** `/products/:id`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "product_1",
    "name": "قميص قطني",
    "description": "قميص قطني مريح ومناسب لجميع المناسبات",
    "price": 25.99,
    "currency": "JOD",
    "category": "clothing",
    "storeId": 1,
    "images": ["https://example.com/shirt1.jpg"],
    "inStock": true,
    "rating": 4.2,
    "reviewsCount": 15
  }
}
```

---

## 💰 Payment Integration APIs

### 1. إنشاء جلسة دفع
**POST** `/payment/session/create`

**Body:**
```json
{
  "storeId": 1,
  "orderId": "order_123",
  "amount": 150.00,
  "currency": "JOD",
  "items": [
    {
      "id": "product_1",
      "name": "قميص قطني",
      "price": 25.99,
      "quantity": 2
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
    "sessionId": "payment_session_1234567890",
    "redirectUrl": "https://bnpl.com/payment/confirm/payment_session_1234567890",
    "expiresAt": "2024-01-20T11:35:00Z",
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

### 2. معالجة الدفع
**POST** `/payment/session/:sessionId/process`

**Body:**
```json
{
  "paymentMethod": "bnpl_immediate",
  "userCardToken": "card_token_123",
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
    "redirectUrl": "https://shein.com/order/success?orderId=order_123"
  }
}
```

### 3. جلب تفاصيل المعاملة
**GET** `/payment/transaction/:transactionId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "transaction_123",
    "paymentSessionId": "payment_session_123",
    "storeId": 1,
    "userId": 1,
    "orderId": "order_123",
    "amount": 150.00,
    "currency": "JOD",
    "paymentMethod": "bnpl_immediate",
    "status": "completed",
    "storePaymentStatus": "paid",
    "userPaymentStatus": "charged",
    "commission": 3.75,
    "storeAmount": 146.25,
    "transactionId": "bnpl_txn_789",
    "storeTransactionId": "shein_txn_456",
    "userTransactionId": "user_txn_123",
    "createdAt": "2024-01-20T10:35:00Z",
    "completedAt": "2024-01-20T10:36:00Z"
  }
}
```

---

## 🏢 Store Integration APIs

### 1. طلب تكامل متجر
**POST** `/stores/integration/request`

**Body:**
```json
{
  "storeName": "متجر جديد",
  "website": "https://newstore.com",
  "contactEmail": "contact@newstore.com",
  "contactPhone": "+962791234567",
  "supportedCountries": ["JO", "SA"],
  "supportedCurrencies": ["JOD", "SAR"],
  "estimatedMonthlyOrders": 1000,
  "averageOrderValue": 150
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "requestId": "integration_request_1234567890",
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

### 2. فحص حالة التكامل
**GET** `/stores/integration/status/:requestId`

**Response:**
```json
{
  "success": true,
  "data": {
    "requestId": "integration_request_1234567890",
    "status": "under_review",
    "submittedAt": "2024-01-20T10:30:00Z",
    "estimatedCompletion": "2024-01-27T10:30:00Z",
    "currentStep": "مراجعة الطلب",
    "nextStep": "التواصل مع المتجر"
  }
}
```

### 3. تفعيل التكامل
**POST** `/stores/integration/activate`

**Body:**
```json
{
  "storeId": 123,
  "integrationData": {
    "storeName": "متجر جديد",
    "supportedCountries": ["JO", "SA"],
    "supportedCurrencies": ["JOD", "SAR"],
    "website": "https://newstore.com"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1234567890,
    "storeId": 123,
    "storeName": "متجر جديد",
    "integrationStatus": "active",
    "integrationType": "payment_gateway",
    "supportedCountries": ["JO", "SA"],
    "supportedCurrencies": ["JOD", "SAR"],
    "commissionRate": 2.5,
    "minOrderAmount": 50,
    "maxOrderAmount": 5000,
    "paymentMethods": ["credit_card", "debit_card", "bank_transfer"],
    "webhookUrl": "https://newstore.com/webhooks/bnpl",
    "apiCredentials": {
      "merchantId": "newstore_merchant_1234567890",
      "apiKey": "newstore_api_key_1234567890",
      "webhookSecret": "newstore_webhook_secret_1234567890"
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
      "terms": "https://bnpl.com/terms/newstore",
      "commissionStructure": "percentage"
    }
  }
}
```

### 4. جلب قائمة التكاملات
**GET** `/stores/integration/list`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1234567890,
      "storeName": "متجر جديد",
      "integrationStatus": "active",
      "supportedCountries": ["JO", "SA"],
      "supportedCurrencies": ["JOD", "SAR"],
      "commissionRate": 2.5,
      "totalTransactions": 1500,
      "totalVolume": 250000
    }
  ]
}
```

### 5. تحديث إعدادات التكامل
**PUT** `/stores/integration/:storeId/settings`

**Body:**
```json
{
  "commissionRate": 3.0,
  "minOrderAmount": 75,
  "maxOrderAmount": 3000
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1234567890,
    "storeId": 123,
    "commissionRate": 3.0,
    "minOrderAmount": 75,
    "maxOrderAmount": 3000
  }
}
```

### 6. استقبال Webhook
**POST** `/stores/integration/:storeId/webhook`

**Body:**
```json
{
  "event": "order.created",
  "orderId": "order_123",
  "amount": 150.00,
  "currency": "JOD"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Webhook processed successfully"
}
```

---

## 📊 Error Codes

جميع الـ APIs تعيد رموز خطأ موحدة:

| Code | Description |
|------|-------------|
| `MISSING_REQUIRED_FIELDS` | الحقول المطلوبة مفقودة |
| `USER_ALREADY_EXISTS` | المستخدم موجود بالفعل |
| `INVALID_CREDENTIALS` | بيانات الدخول غير صحيحة |
| `MISSING_PHONE` | رقم الهاتف مطلوب |
| `MISSING_OTP_DATA` | بيانات رمز التحقق مفقودة |
| `INVALID_OTP` | رمز التحقق غير صحيح |
| `OTP_EXPIRED` | رمز التحقق منتهي الصلاحية |
| `MISSING_CONTACT_INFO` | معلومات الاتصال مفقودة |
| `USER_NOT_FOUND` | لم يتم العثور على المستخدم |
| `MISSING_RESET_DATA` | بيانات إعادة التعيين مفقودة |
| `INVALID_RESET_TOKEN` | رمز إعادة التعيين غير صحيح |
| `RESET_TOKEN_EXPIRED` | رمز إعادة التعيين منتهي الصلاحية |
| `PAYMENT_NOT_FOUND` | المعاملة غير موجودة |
| `INVALID_PAYMENT_STATUS` | حالة الدفع غير صحيحة |
| `STORE_NOT_INTEGRATED` | المتجر غير متكامل مع BNPL |
| `COUNTRY_NOT_SUPPORTED` | BNPL غير متاح في بلدك |
| `SESSION_NOT_FOUND` | جلسة الدفع غير موجودة |
| `SESSION_EXPIRED` | جلسة الدفع منتهية الصلاحية |
| `NOT_FOUND` | العنصر غير موجود |
| `INTERNAL_SERVER_ERROR` | خطأ داخلي في الخادم |

---

## 🚀 تشغيل الـ Mock Server

```bash
cd api/mock-server
npm install
npm start
```

الخادم سيعمل على `http://localhost:3000`

---

## 📝 ملاحظات مهمة

1. **المصادقة**: معظم الـ APIs تتطلب `user-id` في headers
2. **التواريخ**: جميع التواريخ بتنسيق ISO 8601
3. **العملة**: العملة الافتراضية هي الدينار الأردني (JOD)
4. **الحدود**: بعض الـ APIs تحتوي على حدود للبيانات المُرجعة
5. **الأخطاء**: جميع الأخطاء تعيد رسالة باللغة العربية
6. **البيانات الوهمية**: البيانات في الـ mock server هي بيانات تجريبية فقط
