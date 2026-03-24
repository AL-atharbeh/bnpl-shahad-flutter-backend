# 🚀 START HERE - البداية السريعة

## ✅ كل شيء جاهز للتشغيل!

---

## 📝 الملفات الموجودة

- ✅ `.env` - الإعدادات جاهزة (لا حاجة لنسخ)
- ✅ `docker-compose.yml` - MySQL + App جاهز
- ✅ `package.json` - Dependencies كاملة
- ✅ كل الأكواد جاهزة

---

## ⚡ البدء في 3 خطوات

### الخطوة 1: تثبيت Dependencies

```bash
cd /Users/ahmadal-atharbeh/project/bnpl/backend
npm install
```

### الخطوة 2: تشغيل Docker

```bash
docker-compose up -d
```

### الخطوة 3: فتح Swagger

افتح المتصفح:
```
http://localhost:3000/api/docs
```

**✅ تم! Backend يعمل!**

---

## 📋 أو استخدم Setup Script

```bash
./setup.sh
```

هذا سيقوم بكل شيء تلقائياً!

---

## 🔍 عرض Logs

```bash
docker-compose logs -f app
```

---

## 🛑 إيقاف Services

```bash
docker-compose down
```

---

## 📱 اختبار API

### 1. إرسال OTP

```bash
curl -X POST http://localhost:3000/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999"}'
```

### 2. تحقق من Console Logs للحصول على OTP

```bash
docker-compose logs app | grep "OTP"
```

سترى:
```
📱 OTP for +962799999999: 123456
```

### 3. التحقق من OTP

```bash
curl -X POST http://localhost:3000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+962799999999",
    "code": "123456"
  }'
```

---

## 🎯 الملفات المهمة

| File | What? |
|------|-------|
| `.env` | ✅ جاهز - الإعدادات |
| `docker-compose.yml` | ✅ جاهز - Docker |
| `README.md` | 📖 التوثيق الكامل |
| `QUICK_START.md` | ⚡ دليل سريع |
| `TEST_API.md` | 🧪 أوامر الاختبار |
| `PROJECT_SUMMARY.md` | 📊 ملخص المشروع |

---

## ❓ مشاكل شائعة

### المشكلة: Port 3000 مستخدم

**الحل:**
```bash
# غير البورت في docker-compose.yml
ports:
  - '3001:3000'  # استخدم 3001
```

### المشكلة: MySQL لم يجهز

**الحل:**
```bash
# انتظر 10 ثواني ثم
docker-compose restart app
```

### المشكلة: Cannot connect to MySQL

**الحل:**
```bash
docker-compose down
docker-compose up -d
docker-compose logs -f mysql
```

---

## 🎉 الآن ماذا؟

1. ✅ Backend يعمل على `http://localhost:3000`
2. ✅ Swagger Docs على `/api/docs`
3. 🔄 اربط مع Flutter App
4. 🔄 أضف بيانات تجريبية (seeds)
5. 🔄 Deploy إلى AWS

---

## 📞 الدعم

- افتح `TEST_API.md` لأوامر الاختبار
- افتح `README.md` للتوثيق الكامل
- شغل `docker-compose logs -f` للتصحيح

---

**Happy Coding! 🚀**

Backend جاهز 100% - ابدأ الاختبار الآن!

