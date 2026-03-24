# BNPL Mock Server

## نظرة عامة

Mock Server لتطبيق BNPL يوفر جميع الـ endpoints المطلوبة للتطوير والاختبار.

## التثبيت والتشغيل

### 1. تثبيت الـ dependencies
```bash
npm install
```

### 2. تشغيل الـ server
```bash
# تشغيل عادي
npm start

# تشغيل في وضع التطوير (مع auto-reload)
npm run dev
```

### 3. الوصول للـ server
- **API Base URL**: `http://localhost:3000/api/v1`
- **JSON Server Admin**: `http://localhost:3000`

## الـ Endpoints المتاحة

### 🔐 Authentication
- `POST /auth/login` - تسجيل الدخول
- `POST /auth/register` - إنشاء حساب جديد

### 🏪 المتاجر
- `GET /stores` - قائمة المتاجر
- `GET /stores/:id` - تفاصيل متجر
- `GET /stores/:storeId/products` - منتجات متجر

### 🛍️ المنتجات
- `GET /products` - قائمة المنتجات
- `GET /products/:id` - تفاصيل منتج

### 🔔 الإشعارات
- `GET /notifications` - قائمة الإشعارات
- `PUT /notifications/:id/read` - تحديد إشعار كمقروء

### 🔗 Store Integration (جديد)
- `POST /stores/integration/request` - طلب انضمام متجر
- `GET /stores/integration/status/:requestId` - فحص حالة طلب الانضمام
- `POST /stores/integration/activate` - تفعيل التكامل مع متجر
- `GET /stores/integration/list` - قائمة المتاجر المتكاملة
- `PUT /stores/integration/:storeId/settings` - تحديث إعدادات التكامل
- `POST /stores/integration/:storeId/webhook` - استقبال webhooks

### 💳 Payment Integration (جديد)
- `POST /payment/session/create` - إنشاء جلسة دفع
- `POST /payment/session/:sessionId/process` - معالجة الدفع
- `GET /payment/transaction/:transactionId` - تفاصيل المعاملة

### 📦 البيانات الأخرى
- `GET /categories` - الفئات
- `GET /cart` - سلة التسوق
- `GET /orders` - الطلبات
- `GET /payments` - المدفوعات
- `GET /bnpl_plans` - خطط التقسيط
- `GET /bnpl_installments` - الأقساط
- `GET /offers` - العروض
- `GET /reviews` - التقييمات
- `GET /addresses` - العناوين
- `GET /wishlist` - المفضلة
- `GET /search_history` - سجل البحث
- `GET /support_tickets` - تذاكر الدعم
- `GET /faq` - الأسئلة الشائعة

## أمثلة على الاستخدام

### 1. إنشاء جلسة دفع
```bash
curl -X POST http://localhost:3000/api/v1/payment/session/create \
  -H "Content-Type: application/json" \
  -d '{
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
  }'
```

### 2. طلب انضمام متجر
```bash
curl -X POST http://localhost:3000/api/v1/stores/integration/request \
  -H "Content-Type: application/json" \
  -d '{
    "storeName": "زارا",
    "website": "https://www.zara.com",
    "contactEmail": "partnership@zara.com",
    "contactPhone": "+962791234567",
    "supportedCountries": ["JO", "SA", "AE"],
    "supportedCurrencies": ["JOD", "SAR", "AED"],
    "estimatedMonthlyOrders": 1000,
    "averageOrderValue": 200
  }'
```

### 3. تسجيل الدخول
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "ahmed@example.com",
    "password": "password123"
  }'
```

## البيانات الافتراضية

### المستخدمين
- **Email**: `ahmed@example.com`
- **Password**: `password123`

### المتاجر المتكاملة
- **شي إن** (ID: 1) - يدعم الأردن، السعودية، الإمارات، الكويت
- **أناس** (ID: 2) - يدعم الأردن، السعودية، الإمارات

### المنتجات
- منتجات من متجر شي إن
- منتجات من متجر أناس
- منتجات من متجر نمشي

## هيكل البيانات

### Store Integration
```json
{
  "id": 1,
  "storeId": 1,
  "storeName": "شي إن",
  "integrationStatus": "active",
  "supportedCountries": ["JO", "SA", "AE", "KW"],
  "supportedCurrencies": ["JOD", "SAR", "AED", "KWD"],
  "commissionRate": 2.5
}
```

### Payment Session
```json
{
  "id": "payment_session_123",
  "storeId": 1,
  "storeName": "شي إن",
  "userId": 1,
  "orderId": "shein_order_456",
  "amount": 150.00,
  "currency": "JOD",
  "status": "pending"
}
```

### Payment Transaction
```json
{
  "id": "transaction_123",
  "paymentSessionId": "payment_session_123",
  "storeId": 1,
  "userId": 1,
  "amount": 150.00,
  "commission": 3.75,
  "storeAmount": 146.25,
  "status": "completed"
}
```

## الأخطاء والرموز

### رموز الأخطاء الشائعة
- `STORE_NOT_INTEGRATED` - المتجر غير متكامل مع BNPL
- `COUNTRY_NOT_SUPPORTED` - BNPL غير متاح في البلد
- `SESSION_NOT_FOUND` - جلسة الدفع غير موجودة
- `SESSION_EXPIRED` - جلسة الدفع منتهية الصلاحية
- `INVALID_CREDENTIALS` - بيانات الدخول غير صحيحة

### تنسيق الاستجابة
```json
{
  "success": true,
  "data": { ... }
}
```

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "رسالة الخطأ بالعربية"
  }
}
```

## التطوير

### إضافة endpoints جديدة
1. أضف الـ route في `server.js`
2. أضف البيانات في `db.json`
3. حدث التوثيق في `README.md`

### اختبار الـ endpoints
```bash
# اختبار جميع الـ endpoints
npm test

# اختبار endpoint محدد
curl http://localhost:3000/api/v1/stores
```

## الملاحظات

- جميع الـ endpoints تدعم CORS
- يتم تسجيل جميع الطلبات في الـ console
- البيانات محفوظة في `db.json`
- يمكن تعديل البيانات مباشرة من JSON Server Admin
