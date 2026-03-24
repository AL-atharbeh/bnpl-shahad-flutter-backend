# ⚡ Quick Start Guide

## 🚀 البدء السريع (5 دقائق)

### الخطوة 1: تثبيت Dependencies

```bash
cd backend
npm install
```

### الخطوة 2: ملف `.env` جاهز ✅

الملف موجود بالفعل مع الإعدادات الصحيحة للتطوير المحلي.
لا حاجة لتعديل أي شيء!

### الخطوة 3: تشغيل Database + API مع Docker

```bash
docker-compose up -d
```

**أو بدون Docker:**

```bash
# تأكد من تشغيل MySQL محلياً أولاً
# ثم:
npm run start:dev
```

### الخطوة 4: فتح Swagger Documentation

افتح المتصفح وانتقل إلى:

**http://localhost:3000/api/docs**

---

## 📱 اختبار API

### 1. إرسال OTP

```bash
curl -X POST http://localhost:3000/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+962799999999"
  }'
```

**النتيجة:**
```json
{
  "success": true,
  "message": "تم إرسال رمز التحقق",
  "data": {
    "phone": "+962799999999",
    "expiresIn": "5 minutes"
  }
}
```

**ابحث في Console عن OTP:**
```
📱 OTP for +962799999999: 123456
```

### 2. التحقق من OTP

```bash
curl -X POST http://localhost:3000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+962799999999",
    "code": "123456"
  }'
```

### 3. إنشاء حساب جديد

```bash
curl -X POST http://localhost:3000/api/v1/auth/create-account \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+962799999999",
    "fullName": "أحمد محمد",
    "civilIdNumber": "2991234567",
    "dateOfBirth": "1990-01-01",
    "address": "Amman, Jordan",
    "monthlyIncome": 1500.00,
    "employer": "Tech Company",
    "civilIdFront": "base64_image_data",
    "civilIdBack": "base64_image_data",
    "email": "ahmad@example.com"
  }'
```

**النتيجة:**
```json
{
  "success": true,
  "message": "تم إنشاء الحساب بنجاح",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "أحمد محمد",
      "phone": "+962799999999",
      ...
    }
  }
}
```

### 4. استخدام JWT Token

احفظ الـ `token` من الخطوة السابقة واستخدمه:

```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET http://localhost:3000/api/v1/auth/profile \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🎯 الخطوات التالية

### 1. إضافة بيانات تجريبية (Seeds)

سنقوم بإضافة متاجر ومنتجات تجريبية:

```bash
# TODO: إنشاء seed script
npm run seed
```

### 2. ربط مع Flutter App

حدّث `baseUrl` في Flutter:

```dart
// lib/config/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api/v1';
}
```

### 3. تفعيل AWS Services (Production)

- **S3**: رفع الصور (Civil IDs, Avatars)
- **SNS**: إرسال SMS/OTP حقيقي
- **SES**: إرسال Emails
- **CloudWatch**: Monitoring & Logs

---

## 🛠️ الأوامر المفيدة

```bash
# مشاهدة Logs
docker-compose logs -f app

# إعادة تشغيل
docker-compose restart app

# إيقاف كل شيء
docker-compose down

# إيقاف + حذف Database
docker-compose down -v

# الدخول إلى MySQL
docker-compose exec mysql mysql -ubnpl_user -pbnpl_password bnpl_db

# بناء جديد
docker-compose build --no-cache
docker-compose up -d
```

---

## 🐛 حل المشاكل

### المشكلة: `Cannot connect to MySQL`

**الحل:**
```bash
# انتظر حتى يجهز MySQL
docker-compose logs mysql

# أو أعد تشغيل
docker-compose restart app
```

### المشكلة: `Port 3000 already in use`

**الحل:**
```bash
# غير البورت في docker-compose.yml
ports:
  - '3001:3000'  # استخدم 3001 بدلاً من 3000
```

### المشكلة: `Module not found`

**الحل:**
```bash
# احذف node_modules وأعد التثبيت
rm -rf node_modules
npm install
docker-compose build --no-cache
```

---

## ✅ Checklist

- [x] NestJS Project Setup
- [x] TypeORM + MySQL Configuration
- [x] Auth Module (Phone + OTP + JWT)
- [x] Users, Payments, Stores Modules
- [x] Rewards & Postponements
- [x] Swagger Documentation
- [x] Docker Setup
- [ ] Database Seeds
- [ ] AWS Integration (Production)
- [ ] Unit Tests
- [ ] E2E Tests

---

## 📞 الدعم

إذا واجهت أي مشكلة:

1. تحقق من `docker-compose logs -f`
2. تحقق من `.env` file
3. تأكد من أن MySQL يعمل
4. افتح Issue على GitHub

**Happy Coding! 🚀**

