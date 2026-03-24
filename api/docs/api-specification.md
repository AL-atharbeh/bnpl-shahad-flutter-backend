# BNPL API Specification

## نظرة عامة

هذا الملف يحتوي على مواصفات الـ API لتطبيق BNPL (Buy Now Pay Later).

## Base URL

```
http://localhost:3000/api/v1
```

## Authentication

جميع الـ endpoints تتطلب Bearer Token في الـ header:

```
Authorization: Bearer <token>
```

## Endpoints

### 1. Authentication

#### POST /auth/login
تسجيل الدخول

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "email": "user@example.com",
      "phone": "+962791234567"
    }
  }
}
```

#### POST /auth/register
إنشاء حساب جديد

**Request Body:**
```json
{
  "name": "أحمد محمد",
  "email": "user@example.com",
  "password": "password123",
  "phone": "+962791234567"
}
```

### 2. Stores

#### GET /stores
جلب قائمة المتاجر

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "شي إن",
      "logo": "https://example.com/shein-logo.jpg",
      "banner": "https://example.com/shein-banner.jpg",
      "rating": 4.5,
      "reviewsCount": 1250,
      "onlineOnly": true,
      "hasDeal": true,
      "description": "متجر أزياء عالمي"
    }
  ]
}
```

#### GET /stores/{id}
جلب تفاصيل متجر معين

### 3. Products

#### GET /stores/{storeId}/products
جلب منتجات متجر معين

#### GET /products/{id}
جلب تفاصيل منتج معين

### 4. User Profile

#### GET /profile
جلب معلومات المستخدم

#### PUT /profile
تحديث معلومات المستخدم

### 5. Notifications

#### GET /notifications
جلب الإشعارات

#### PUT /notifications/{id}/read
تحديد إشعار كمقروء

## Error Responses

جميع الأخطاء تتبع نفس التنسيق:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "بيانات غير صحيحة",
    "details": {
      "email": "البريد الإلكتروني مطلوب"
    }
  }
}
```

## Status Codes

- `200` - نجح الطلب
- `201` - تم الإنشاء بنجاح
- `400` - خطأ في البيانات
- `401` - غير مصرح
- `404` - غير موجود
- `500` - خطأ في الخادم
