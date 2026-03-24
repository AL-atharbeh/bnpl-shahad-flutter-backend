# أدوات إدارة قاعدة البيانات - Database Management Tools

## 🛠️ أدوات متاحة

### 1. phpMyAdmin (مضافة إلى Docker Compose)

**الوصول:**
- URL: `http://localhost:8080`
- طريقة الوصول:
  1. شغّل `docker-compose up -d`
  2. افتح المتصفح واذهب إلى `http://localhost:8080`
  3. معلومات تسجيل الدخول:
     - **Server**: `mysql` (أو اتركه فارغاً - سيختاره تلقائياً)
     - **Username**: `bnpl_user`
     - **Password**: `bnpl_password`

**المميزات:**
- ✅ واجهة ويب سهلة الاستخدام
- ✅ لا يحتاج تثبيت إضافي
- ✅ يعمل مباشرة في المتصفح
- ✅ يدعم العربية
- ✅ عرض جميع الأعمدة بشكل صحيح (بما في ذلك `otp`)

---

### 2. TablePlus (البرنامج المحلي)

**الوصول:**
- تحميل: [tableplus.com](https://tableplus.com)
- معلومات الاتصال:
  - **Host**: `127.0.0.1` أو `localhost`
  - **Port**: `3306`
  - **Username**: `bnpl_user`
  - **Password**: `bnpl_password`
  - **Database**: `bnpl_db`

**ملاحظة:** إذا لم يظهر عمود `otp`:
- اضغط `Cmd + R` (Mac) أو `Ctrl + R` (Windows) لتحديث Schema
- أو انقر بزر الماوس الأيمن على الجدول → Refresh

---

### 3. MySQL Workbench

**الوصول:**
- تحميل: [dev.mysql.com/downloads/workbench](https://dev.mysql.com/downloads/workbench/)
- معلومات الاتصال:
  - **Connection Name**: `BNPL Local`
  - **Hostname**: `127.0.0.1`
  - **Port**: `3306`
  - **Username**: `bnpl_user`
  - **Password**: `bnpl_password`
  - **Default Schema**: `bnpl_db`

---

### 4. DBeaver (مجاني ومفتوح المصدر)

**الوصول:**
- تحميل: [dbeaver.io](https://dbeaver.io)
- معلومات الاتصال:
  - **Database Type**: MySQL
  - **Host**: `localhost`
  - **Port**: `3306`
  - **Database**: `bnpl_db`
  - **Username**: `bnpl_user`
  - **Password**: `bnpl_password`

---

### 5. Terminal/Command Line

**الوصول عبر Docker:**
```bash
# الدخول إلى MySQL
docker exec -it bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db

# أو مباشرة
docker exec -it bnpl-mysql mysql -ubnpl_user -pbnpl_password bnpl_db -e "SELECT * FROM users;"
```

---

## 🚀 التوصية

**للاستخدام اليومي:** phpMyAdmin
- ✅ سهل الاستخدام
- ✅ متاح مباشرة في المتصفح
- ✅ لا يحتاج تثبيت
- ✅ يعرض جميع الأعمدة بشكل صحيح

**للعمل المتقدم:** DBeaver أو MySQL Workbench
- ✅ ميزات متقدمة
- ✅ SQL Editor قوي
- ✅ Export/Import سهل

---

## 📋 معلومات الاتصال الموحدة

جميع الأدوات تستخدم نفس المعلومات:

```
Host: localhost (أو 127.0.0.1)
Port: 3306
Username: bnpl_user
Password: bnpl_password
Database: bnpl_db
```

---

## 🔧 تشغيل phpMyAdmin

```bash
# إذا كانت الخوادم تعمل بالفعل
cd backend
docker-compose up -d phpmyadmin

# أو إعادة تشغيل الكل
docker-compose down
docker-compose up -d

# التحقق من حالة phpMyAdmin
docker-compose ps phpmyadmin
```

---

## ✅ التحقق من عمود OTP

في أي أداة، نفّذ:

```sql
-- عرض جميع الأعمدة
SHOW COLUMNS FROM users;

-- أو
SELECT * FROM users LIMIT 1;
```

يجب أن ترى عمود `otp` في جميع الأدوات.

