# حل مشكلة عدم ظهور عمود OTP في TablePlus

## المشكلة
العمود `otp` موجود في قاعدة البيانات لكن لا يظهر في TablePlus

## الحلول

### الحل 1: تحديث الـ Schema في TablePlus (الأسهل)

1. افتح TablePlus
2. اختر قاعدة البيانات `bnpl_db`
3. اضغط على `Cmd + R` (Mac) أو `Ctrl + R` (Windows/Linux) لتحديث الصفحة
4. أو اضغط بزر الماوس الأيمن على جدول `users` واختر `Refresh` أو `Reload Schema`

### الحل 2: إعادة الاتصال

1. أغلق الاتصال الحالي في TablePlus
2. افتح اتصال جديد
3. اختر قاعدة البيانات `bnpl_db` مرة أخرى

### الحل 3: التحقق من الاتصال الصحيح

تأكد من أنك متصل بقاعدة البيانات الصحيحة:

**معلومات الاتصال في Docker:**
- Host: `localhost` أو `127.0.0.1`
- Port: `3306`
- Username: `bnpl_user`
- Password: `bnpl_password`
- Database: `bnpl_db`

### الحل 4: تنفيذ Query مباشرة للتحقق

في TablePlus، نفّذ هذا الاستعلام:

```sql
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'bnpl_db' 
  AND TABLE_NAME = 'users' 
  AND COLUMN_NAME = 'otp';
```

إذا ظهرت النتيجة، فالعمود موجود بالفعل.

### الحل 5: عرض جميع الأعمدة مباشرة

```sql
SHOW COLUMNS FROM users;
```

أو

```sql
DESCRIBE users;
```

---

## تأكيد نهائي

نفّذ هذا الاستعلام للتأكد من وجود العمود:

```sql
SELECT * FROM users LIMIT 1;
```

يجب أن ترى عمود `otp` في النتائج (قد يكون NULL إذا لم يتم تعيين قيمة له بعد).

