# 🗑️ دليل حذف البيانات من قاعدة البيانات

## 📋 نظرة عامة

هذا الدليل يشرح كيفية حذف جميع البيانات من قاعدة البيانات MySQL.

---

## 🔌 طرق الاتصال بقاعدة البيانات

### 1️⃣ **phpMyAdmin (الطريقة الأسهل)** ✅

1. افتح المتصفح واذهب إلى:
   ```
   http://localhost:8080
   ```

2. بيانات الدخول:
   - **Username**: `bnpl_user`
   - **Password**: `bnpl_password`

3. اختر قاعدة البيانات `bnpl_db` من القائمة الجانبية

4. لحذف البيانات:
   - اختر أي جدول (مثل `users`)
   - اضغط على **Browse** لعرض البيانات
   - اضغط على **Empty** لحذف جميع البيانات
   - أو استخدم SQL: `TRUNCATE TABLE users;`

---

### 2️⃣ **TablePlus / MySQL Workbench**

**إعدادات الاتصال:**
- **Host**: `localhost`
- **Port**: `3306`
- **Username**: `bnpl_user`
- **Password**: `bnpl_password`
- **Database**: `bnpl_db`

---

### 3️⃣ **MySQL Command Line**

```bash
# الاتصال بقاعدة البيانات
mysql -h localhost -P 3306 -u bnpl_user -pbnpl_password bnpl_db

# أو مع كلمة مرور منفصلة
mysql -h localhost -P 3306 -u bnpl_user -p bnpl_db
# (سيطلب منك إدخال كلمة المرور)
```

---

## 🚀 حذف البيانات باستخدام Script (الطريقة الموصى بها)

### الخطوة 1: تأكد من تشغيل Docker

```bash
cd backend
docker compose ps
```

إذا لم تكن تعمل، شغلها:
```bash
docker compose up -d
```

---

### الخطوة 2: تشغيل Script حذف البيانات

```bash
cd backend
npm run clear-data
```

هذا الـ script سيقوم بحذف جميع البيانات من جميع الجداول بالترتيب الصحيح (مع احترام Foreign Keys).

---

## 📝 حذف البيانات يدوياً عبر SQL

إذا أردت حذف البيانات يدوياً، استخدم هذا الترتيب:

```sql
-- 1. حذف الجداول التي تعتمد على أخرى أولاً
TRUNCATE TABLE reward_points;
TRUNCATE TABLE postponements;
TRUNCATE TABLE payments;
TRUNCATE TABLE notifications;
TRUNCATE TABLE user_security_settings;
TRUNCATE TABLE otp_codes;
TRUNCATE TABLE deals;
TRUNCATE TABLE products;
TRUNCATE TABLE banners;
TRUNCATE TABLE promo_notifications;
TRUNCATE TABLE stores;
TRUNCATE TABLE contact_messages;
TRUNCATE TABLE contact_settings;
TRUNCATE TABLE categories;
TRUNCATE TABLE users;
```

**⚠️ تحذير**: استخدم `TRUNCATE` لحذف جميع البيانات، أو `DELETE FROM table_name` لحذف بيانات محددة.

---

## 🔍 التحقق من حذف البيانات

### عبر phpMyAdmin:
1. افتح `http://localhost:8080`
2. اختر قاعدة البيانات `bnpl_db`
3. افتح أي جدول (مثل `users`)
4. اضغط **Browse** - يجب أن تكون فارغة

### عبر MySQL CLI:
```bash
mysql -h localhost -P 3306 -u bnpl_user -pbnpl_password bnpl_db -e "SELECT COUNT(*) FROM users;"
```

يجب أن يعرض `0`.

---

## 🛠️ استكشاف الأخطاء

### المشكلة: لا يمكن الاتصال بقاعدة البيانات

**الحل:**
```bash
# تحقق من حالة Docker
cd backend
docker compose ps

# إذا لم تكن تعمل، شغلها
docker compose up -d

# تحقق من Logs
docker compose logs mysql
```

---

### المشكلة: خطأ في Foreign Key Constraints

**الحل**: استخدم الـ script `clear-data.ts` لأنه يحذف بالترتيب الصحيح.

أو قم بتعطيل Foreign Key Checks مؤقتاً:
```sql
SET FOREIGN_KEY_CHECKS = 0;
-- ثم قم بحذف البيانات
SET FOREIGN_KEY_CHECKS = 1;
```

---

## 📊 الجداول التي سيتم حذفها

الـ script يحذف البيانات من هذه الجداول بالترتيب:

1. `reward_points` - نقاط المكافآت
2. `postponements` - التأجيلات
3. `payments` - المدفوعات
4. `notifications` - الإشعارات
5. `user_security_settings` - إعدادات الأمان
6. `otp_codes` - أكواد OTP
7. `deals` - العروض
8. `products` - المنتجات
9. `banners` - البانرات
10. `promo_notifications` - إشعارات العروض
11. `stores` - المتاجر
12. `contact_messages` - رسائل التواصل
13. `contact_settings` - إعدادات التواصل
14. `categories` - الفئات
15. `users` - المستخدمين

---

## ✅ بعد حذف البيانات

بعد حذف البيانات، يمكنك:

1. **إضافة بيانات جديدة**:
   ```bash
   npm run seed
   ```

2. **إنشاء مستخدم جديد** عبر API التسجيل

3. **إضافة متاجر ومنتجات** عبر Admin Panel أو SQL مباشرة

---

## 🔐 معلومات الاتصال (ملخص)

| المعلومة | القيمة |
|---------|--------|
| Host | `localhost` |
| Port | `3306` |
| Username | `bnpl_user` |
| Password | `bnpl_password` |
| Database | `bnpl_db` |
| phpMyAdmin | `http://localhost:8080` |

---

## 💡 نصائح

- ✅ استخدم `npm run clear-data` للحذف الآمن
- ✅ احتفظ بنسخة احتياطية قبل الحذف (إذا كانت هناك بيانات مهمة)
- ✅ استخدم phpMyAdmin للتحقق من البيانات
- ✅ تأكد من تشغيل Docker قبل الاتصال

