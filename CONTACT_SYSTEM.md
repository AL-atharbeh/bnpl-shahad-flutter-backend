# نظام التواصل (Contact System)

## 📋 نظرة عامة

نظام التواصل يتكون من جزئين:
1. **إعدادات التواصل** (Contact Settings): معلومات الاتصال التي يمكن تغييرها (Email, Phone, WhatsApp)
2. **رسائل المستخدمين** (Contact Messages): استقبال وإدارة رسائل المستخدمين

---

## 🗄️ قاعدة البيانات

### جدول `contact_settings`
يحتوي على معلومات التواصل الأساسية (سجل واحد فقط):

| العمود | النوع | الوصف |
|--------|------|-------|
| `id` | INT | المعرف (دائماً 1) |
| `contact_email` | VARCHAR(255) | البريد الإلكتروني للاتصال |
| `contact_phone` | VARCHAR(20) | رقم الهاتف للاتصال |
| `whatsapp_number` | VARCHAR(20) | رقم واتساب |
| `created_at` | TIMESTAMP | تاريخ الإنشاء |
| `updated_at` | TIMESTAMP | تاريخ آخر تحديث |

### جدول `contact_messages`
يحتوي على رسائل المستخدمين:

| العمود | النوع | الوصف |
|--------|------|-------|
| `id` | INT | المعرف |
| `full_name` | VARCHAR(255) | الاسم الكامل |
| `email` | VARCHAR(255) | البريد الإلكتروني |
| `phone` | VARCHAR(20) | رقم الهاتف |
| `message` | TEXT | الرسالة |
| `status` | ENUM | الحالة: `new`, `read`, `replied`, `archived` |
| `created_at` | TIMESTAMP | تاريخ الإرسال |
| `updated_at` | TIMESTAMP | تاريخ آخر تحديث |

---

## 🔌 API Endpoints

### Public Endpoints (لا تحتاج authentication)

#### 1. الحصول على معلومات التواصل
```
GET /api/v1/contact/settings
```

**Response:**
```json
{
  "success": true,
  "data": {
    "contactEmail": "info@bnpl.com",
    "contactPhone": "+962791234567",
    "whatsappNumber": "+962791234567"
  }
}
```

#### 2. إرسال رسالة (من المستخدم)
```
POST /api/v1/contact/message
```

**Request Body:**
```json
{
  "fullName": "أحمد علي",
  "email": "ahmed@example.com",
  "phone": "+962791234567",
  "message": "أريد الاستفسار عن..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم إرسال رسالتك بنجاح. سنتواصل معك قريباً",
  "data": {
    "id": 1,
    "fullName": "أحمد علي",
    "email": "ahmed@example.com",
    "createdAt": "2025-11-05T13:52:01.225Z"
  }
}
```

---

### Admin Endpoints (تحتاج authentication)

#### 3. تحديث معلومات التواصل
```
PUT /api/v1/contact/settings
Headers: Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "contactEmail": "support@bnpl.com",
  "contactPhone": "+962791234568",
  "whatsappNumber": "+962791234568"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تحديث معلومات التواصل بنجاح",
  "data": {
    "contactEmail": "support@bnpl.com",
    "contactPhone": "+962791234568",
    "whatsappNumber": "+962791234568"
  }
}
```

#### 4. الحصول على جميع الرسائل
```
GET /api/v1/contact/messages
Headers: Authorization: Bearer <token>
```

**Query Parameters (optional):**
- `status`: `new`, `read`, `replied`, `archived`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "fullName": "أحمد علي",
      "email": "ahmed@example.com",
      "phone": "+962791234567",
      "message": "أريد الاستفسار عن...",
      "status": "new",
      "createdAt": "2025-11-05T13:52:01.225Z"
    }
  ]
}
```

#### 5. الحصول على رسالة واحدة
```
GET /api/v1/contact/messages/:id
Headers: Authorization: Bearer <token>
```

#### 6. تحديث حالة الرسالة
```
PUT /api/v1/contact/messages/:id/status
Headers: Authorization: Bearer <token>
```

**Request Body:**
```json
{
  "status": "read"
}
```

#### 7. حذف رسالة
```
DELETE /api/v1/contact/messages/:id
Headers: Authorization: Bearer <token>
```

---

## 📁 هيكل الملفات

```
backend/src/contact/
├── entities/
│   ├── contact-setting.entity.ts    # Entity لإعدادات التواصل
│   └── contact-message.entity.ts     # Entity لرسائل المستخدمين
├── contact.service.ts                 # Business Logic
├── contact.controller.ts              # API Endpoints
└── contact.module.ts                  # NestJS Module
```

---

## 🔧 الاستخدام

### في Flutter (Frontend):

#### 1. الحصول على معلومات التواصل:
```dart
final response = await apiService.get('/contact/settings');
final email = response['data']['contactEmail'];
final phone = response['data']['contactPhone'];
final whatsapp = response['data']['whatsappNumber'];
```

#### 2. إرسال رسالة:
```dart
final response = await apiService.post('/contact/message', {
  'fullName': 'أحمد علي',
  'email': 'ahmed@example.com',
  'phone': '+962791234567',
  'message': 'أريد الاستفسار عن...',
});
```

---

## 📝 ملاحظات

1. **إعدادات التواصل**: سجل واحد فقط في قاعدة البيانات (id = 1)
2. **رسائل المستخدمين**: يمكن إرسال رسائل متعددة
3. **الحالات**: `new` → `read` → `replied` → `archived`
4. **Public vs Admin**: بعض endpoints عامة والبعض الآخر يحتاج authentication

---

## ✅ تم إنجازه

- ✅ إنشاء الجداول في قاعدة البيانات
- ✅ إنشاء Entities في Backend
- ✅ إنشاء Service و Controller
- ✅ إضافة Module إلى AppModule
- ✅ إنشاء SQL Migration Script
- ✅ تحديث create-tables.sql

---

## 🚀 الخطوات التالية

1. إضافة UI في Flutter لعرض معلومات التواصل
2. إضافة نموذج "تواصل معنا" في Flutter
3. إضافة صفحة إدارة الرسائل في Admin Panel (إذا كان موجوداً)

