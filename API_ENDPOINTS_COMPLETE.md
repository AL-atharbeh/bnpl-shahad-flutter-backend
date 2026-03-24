# جميع الـ API Endpoints - BNPL

## 📍 Base URL
```
http://localhost:3000/api/v1
```

---

## 🔐 Authentication Endpoints

### 1. Check Phone
```http
POST /auth/check-phone
Content-Type: application/json

{
  "phone": "+962799999999"
}
```

**Response**:
```json
{
  "success": true,
  "exists": true,
  "message": "مستخدم موجود",
  "data": {
    "phone": "+962799999999",
    "name": "أحمد محمد",
    "requiresOtp": true
  }
}
```

### 2. Send OTP
```http
POST /auth/send-otp
Content-Type: application/json

{
  "phone": "+962799999999"
}
```

**Response**:
```json
{
  "success": true,
  "message": "تم إرسال رمز التحقق",
  "data": {
    "phone": "+962799999999",
    "expiresIn": 300
  }
}
```

### 3. Verify OTP
```http
POST /auth/verify-otp
Content-Type: application/json

{
  "phone": "+962799999999",
  "code": "123456"
}
```

**Response** (User exists):
```json
{
  "success": true,
  "message": "تم التحقق من رقم الهاتف بنجاح",
  "data": {
    "userExists": true,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "phone": "+962799999999"
    }
  }
}
```

**Response** (New user):
```json
{
  "success": true,
  "message": "تم التحقق من رقم الهاتف بنجاح",
  "data": {
    "userExists": false,
    "phone": "+962799999999",
    "requiresProfileCompletion": true
  }
}
```

### 4. Create Account
```http
POST /auth/create-account
Content-Type: application/json

{
  "phone": "+962799999999",
  "fullName": "أحمد محمد",
  "civilIdNumber": "2991234567",
  "dateOfBirth": "1990-01-01",
  "address": "Amman, Jordan",
  "monthlyIncome": 1500.00,
  "employer": "Tech Company",
  "civilIdFront": "data:image/jpeg;base64,...",
  "civilIdBack": "data:image/jpeg;base64,...",
  "email": "ahmad@example.com"
}
```

**Response**:
```json
{
  "success": true,
  "message": "تم إنشاء الحساب بنجاح",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "phone": "+962799999999"
    }
  }
}
```

### 5. Get Profile (JWT Required)
```http
GET /auth/profile
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "phone": "+962799999999",
      "email": "ahmad@example.com"
    }
  }
}
```

---

## 👤 Users Endpoints (JWT Required)

### 1. Get Current User
```http
GET /users/me
Authorization: Bearer <token>
```

### 2. Update Profile
```http
PUT /users/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "أحمد محمد",
  "email": "ahmad@example.com",
  "phone": "+962799999999",
  "avatar": "data:image/jpeg;base64,..."
}
```

---

## 🏠 Home Endpoints

### 1. Get Home Data (JWT Optional)
```http
GET /home
Authorization: Bearer <token>  # Optional
```

**Response**:
```json
{
  "success": true,
  "data": {
    "banners": [...],
    "categories": [...],
    "topStores": [...],
    "bestOffers": [...],
    "featuredStores": [...],
    "pendingPayments": [...],  # Only if JWT provided
    "unreadNotifications": [...],  # Only if JWT provided
    "stats": {
      "totalStores": 10,
      "totalOffers": 5,
      "pendingPaymentsCount": 3,
      "unreadNotificationsCount": 2
    }
  }
}
```

### 2. Get Public Home Data (No JWT)
```http
GET /home/public
```

---

## 🏪 Stores Endpoints

### 1. Get All Stores
```http
GET /stores
GET /stores?categoryId=1
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Store Name",
      "nameAr": "اسم المتجر",
      "logoUrl": "https://...",
      "category": "Electronics",
      "rating": 4.5,
      "productsCount": 50
    }
  ]
}
```

### 2. Get Stores with Deals
```http
GET /stores/deals
GET /stores/deals?categoryId=1
```

### 3. Search Stores
```http
GET /stores/search?q=query
GET /stores/search?q=query&categoryId=1
```

### 4. Get Stores by Category
```http
GET /stores/category/:categoryId
```

### 5. Get Store Details
```http
GET /stores/:id
```

### 6. Get Store Products
```http
GET /stores/:id/products
GET /stores/:id/products?categoryId=1
```

---

## 📦 Products Endpoints

### 1. Get Products by Store
```http
GET /products/store/:storeId
GET /products/store/:storeId?categoryId=1
```

### 2. Search Products
```http
GET /products/search?q=query
```

### 3. Get Product Details
```http
GET /products/:id
```

---

## 💳 Payments Endpoints (JWT Required)

### 1. Get All Payments
```http
GET /payments
GET /payments?installmentNumber=1&installmentsCount=4
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "amount": 100.50,
      "dueDate": "2024-01-15",
      "status": "pending",
      "installmentNumber": 1,
      "installmentsCount": 4,
      "store": {
        "id": 1,
        "name": "Store Name"
      }
    }
  ],
  "filters": {
    "installmentNumber": 1,
    "installmentsCount": 4
  }
}
```

### 2. Get Pending Payments
```http
GET /payments/pending
GET /payments/pending?installmentNumber=1&installmentsCount=4
Authorization: Bearer <token>
```

### 3. Get Payment History
```http
GET /payments/history
GET /payments/history?startDate=2024-01-01&endDate=2024-12-31&status=paid&installmentNumber=1&installmentsCount=4
Authorization: Bearer <token>
```

### 4. Get Payment by ID
```http
GET /payments/:id
Authorization: Bearer <token>
```

### 5. Get Payments by Order ID
```http
GET /payments/order/:orderId
Authorization: Bearer <token>
```

### 6. Process Payment
```http
POST /payments/:id/pay
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "message": "تم الدفع بنجاح",
  "data": {
    "id": 1,
    "status": "paid"
  }
}
```

### 7. Extend Due Date
```http
PUT /payments/:id/extend
Authorization: Bearer <token>
Content-Type: application/json

{
  "extensionDays": 7
}
```

### 8. Postpone Payment
```http
POST /payments/:id/postpone
Authorization: Bearer <token>
Content-Type: application/json

{
  "daysToPostpone": 10
}
```

---

## 🎁 Rewards Endpoints (JWT Required)

### 1. Get Current Points
```http
GET /rewards/points
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "currentPoints": 150,
    "pointsValue": 1.50,
    "conversionRate": 100
  }
}
```

### 2. Get Points History
```http
GET /rewards/history
Authorization: Bearer <token>
```

### 3. Redeem Points
```http
POST /rewards/redeem
Authorization: Bearer <token>
Content-Type: application/json

{
  "points": 100
}
```

---

## ⏰ Postponements Endpoints (JWT Required)

### 1. Check if Can Postpone
```http
GET /postponements/can-postpone
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": {
    "canPostpone": true,
    "freePostponementsRemaining": 1,
    "daysSinceLastPostponement": 15
  }
}
```

### 2. Free Postponement
```http
POST /postponements/postpone-free
Authorization: Bearer <token>
Content-Type: application/json

{
  "paymentId": 1
}
```

### 3. Get Postponement History
```http
GET /postponements/history
Authorization: Bearer <token>
```

---

## 🔔 Notifications Endpoints (JWT Required)

### 1. Get All Notifications
```http
GET /notifications
Authorization: Bearer <token>
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Notification Title",
      "message": "Notification Message",
      "type": "payment",
      "isRead": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 2. Mark Notification as Read
```http
PUT /notifications/:id/read
Authorization: Bearer <token>
```

### 3. Mark All Notifications as Read
```http
PUT /notifications/read-all
Authorization: Bearer <token>
```

### 4. Delete Notification
```http
DELETE /notifications/:id
Authorization: Bearer <token>
```

---

## 📂 Categories Endpoints

### 1. Get All Categories
```http
GET /categories
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Electronics",
      "nameAr": "الإلكترونيات",
      "icon": "devices",
      "storesCount": 10
    }
  ]
}
```

---

## 🎨 Banners Endpoints

### 1. Get All Active Banners
```http
GET /banners
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Banner Title",
      "image": "https://...",
      "link": "/offers",
      "order": 1
    }
  ]
}
```

---

## 🎯 Deals Endpoints

### 1. Get All Deals
```http
GET /deals
```

### 2. Get Featured Deals
```http
GET /deals/featured
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "storeId": 1,
      "productId": 1,
      "title": "Deal Title",
      "description": "Deal Description",
      "discountLabel": "50% OFF",
      "discountValue": "50",
      "imageUrl": "https://...",
      "startDate": "2024-01-01",
      "endDate": "2024-12-31",
      "isActive": true
    }
  ]
}
```

---

## 📧 Contact Endpoints

### 1. Send Contact Message
```http
POST /contact
Content-Type: application/json

{
  "name": "أحمد محمد",
  "email": "ahmad@example.com",
  "phone": "+962799999999",
  "subject": "Subject",
  "message": "Message"
}
```

**Response**:
```json
{
  "success": true,
  "message": "تم إرسال الرسالة بنجاح"
}
```

---

## 📢 Promo Notifications Endpoints

### 1. Get All Promo Notifications
```http
GET /promo-notifications
```

---

## 🔒 Authentication Headers

جميع الـ endpoints التي تتطلب JWT تحتاج إلى:

```http
Authorization: Bearer <your-jwt-token>
```

**الحصول على Token**:
- من `POST /auth/verify-otp` (للمستخدمين الموجودين)
- من `POST /auth/create-account` (للمستخدمين الجدد)

---

## 📝 ملاحظات

1. **Base URL**: جميع الـ endpoints تبدأ بـ `/api/v1`
2. **Content-Type**: جميع الـ POST/PUT requests تحتاج `Content-Type: application/json`
3. **JWT Token**: يتم إرساله في Header: `Authorization: Bearer <token>`
4. **Error Response**: جميع الأخطاء تُرجع:
   ```json
   {
     "success": false,
     "error": "Error message",
     "statusCode": 400
   }
   ```
5. **Success Response**: جميع النجاحات تُرجع:
   ```json
   {
     "success": true,
     "data": {...}
   }
   ```

---

## 🧪 اختبار الـ Endpoints

### استخدام Swagger
افتح: `http://localhost:3000/api/docs`

### استخدام cURL
```bash
# Check Phone
curl -X POST http://localhost:3000/api/v1/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999"}'

# Send OTP
curl -X POST http://localhost:3000/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999"}'

# Verify OTP
curl -X POST http://localhost:3000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999", "code": "123456"}'

# Get Home Data (with JWT)
curl -X GET http://localhost:3000/api/v1/home \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

**آخر تحديث**: $(date)

