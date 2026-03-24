# دليل رفع التحديثات - Guide for Deploying Updates

## 📋 التحديثات المطلوبة
- إضافة عمود `otp` إلى جدول `users`
- تحديث منطق التحقق من OTP

---

## 🚀 الطريقة 1: التطوير المحلي (Development)

إذا كنت تعمل في وضع التطوير وكان `synchronize: true` في TypeORM، سيقوم TypeORM تلقائياً بإضافة العمود عند إعادة تشغيل الخادم.

### الخطوات:

```bash
# 1. الانتقال لمجلد Backend
cd backend

# 2. إعادة تشغيل الخوادم (Docker Compose)
docker-compose down
docker-compose up -d --build

# 3. التحقق من أن الخوادم تعمل
docker-compose ps

# 4. التحقق من السجلات (Logs)
docker-compose logs -f app
```

---

## 🚀 الطريقة 2: قاعدة بيانات موجودة (Existing Database)

إذا كان لديك قاعدة بيانات موجودة تحتوي على بيانات، استخدم SQL Migration:

### أ) استخدام Docker:

```bash
# 1. تنفيذ SQL Migration عبر Docker
docker exec -i bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db < add-otp-column.sql

# 2. التحقق من أن العمود تم إضافته
docker exec -it bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db -e "DESCRIBE users;"
```

### ب) استخدام MySQL مباشرة:

```bash
# 1. الاتصال بقاعدة البيانات
mysql -u bnpl_user -p bnpl_db

# 2. تنفيذ SQL
source add-otp-column.sql;

# أو مباشرة:
ALTER TABLE users ADD COLUMN otp VARCHAR(6) NULL AFTER employer;

# 3. التحقق
DESCRIBE users;
```

---

## 🚀 الطريقة 3: قاعدة بيانات جديدة (Fresh Database)

إذا كنت تنشئ قاعدة بيانات جديدة من الصفر:

```bash
# 1. الانتقال لمجلد Backend
cd backend

# 2. إيقاف الخوادم (إذا كانت تعمل)
docker-compose down

# 3. حذف قاعدة البيانات القديمة (اختياري - احذر من فقدان البيانات!)
docker volume rm bnpl_mysql_data

# 4. تشغيل الخوادم من جديد
docker-compose up -d

# 5. بعد أن يصبح MySQL جاهزاً، تنفيذ create-tables.sql
docker exec -i bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db < create-tables.sql
```

---

## 🚀 الطريقة 4: بيئة الإنتاج (Production)

### خطوات الإنتاج:

```bash
# 1. نسخ الكود إلى الخادم
git pull origin main

# 2. بناء التطبيق
npm run build

# 3. تنفيذ Migration على قاعدة البيانات
# عبر SSH أو أدوات إدارة قاعدة البيانات
mysql -u [USER] -p [DATABASE] < add-otp-column.sql

# 4. إعادة تشغيل التطبيق
pm2 restart bnpl-backend
# أو
systemctl restart bnpl-backend
```

---

## ✅ التحقق من نجاح التحديث

### 1. التحقق من قاعدة البيانات:

```sql
-- التحقق من وجود عمود otp
DESCRIBE users;

-- يجب أن ترى:
-- | otp | varchar(6) | YES | | NULL | |
```

### 2. التحقق من API:

```bash
# اختبار إرسال OTP
curl -X POST http://localhost:3000/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999"}'

# اختبار التحقق من OTP
curl -X POST http://localhost:3000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone": "+962799999999", "code": "123456"}'
```

### 3. التحقق من السجلات:

```bash
# عرض سجلات التطبيق
docker-compose logs -f app

# البحث عن أخطاء
docker-compose logs app | grep -i error
```

---

## 🔧 استكشاف الأخطاء

### المشكلة: عمود otp غير موجود
**الحل:**
```sql
-- تنفيذ Migration يدوياً
ALTER TABLE users ADD COLUMN otp VARCHAR(6) NULL AFTER employer;
```

### المشكلة: TypeORM لا يتعرف على التغييرات
**الحل:**
```bash
# إعادة بناء التطبيق
npm run build

# إعادة تشغيل الخوادم
docker-compose restart app
```

### المشكلة: OTP لا يُحفظ في جدول المستخدم
**الحل:**
- تأكد من أن `otp.service.ts` يحتوي على `userRepository`
- تحقق من أن `AuthModule` يستورد `User` entity
- راجع السجلات للبحث عن أخطاء

---

## 📝 ملاحظات مهمة

1. **في وضع Development:** TypeORM synchronize سيضيف العمود تلقائياً
2. **في وضع Production:** يجب تعطيل synchronize واستخدام Migrations
3. **قبل التحديث:** احفظ نسخة احتياطية من قاعدة البيانات
4. **بعد التحديث:** اختبر جميع وظائف OTP للتأكد من عملها

---

## 🎯 الخطوات السريعة (Quick Steps)

```bash
# للتطوير المحلي:
docker-compose restart

# لقاعدة بيانات موجودة:
docker exec -i bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db < add-otp-column.sql

# التحقق:
docker exec -it bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db -e "DESCRIBE users;"
```

