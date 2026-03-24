# 🔐 دليل اختبار PIN (كلمة سر للدخول)

دليل شامل لاختبار ميزة PIN في التطبيق.

---

## 📋 **قبل البدء**

### 1. تأكد من تشغيل الخدمات:
```bash
# في Terminal الأول - Backend
cd /Users/ahmadal-atharbeh/project/bnpl/backend
docker compose up -d

# تحقق من أن الخدمات تعمل
docker compose ps
```

### 2. تأكد من تسجيل الدخول في Flutter App:
- يجب أن تكون مسجلاً دخول في التطبيق
- يجب أن يكون لديك JWT token صالح

---

## 🧪 **الاختبار 1: تعيين PIN من Flutter App**

### الخطوات:

1. **افتح صفحة الخصوصية والأمان**:
   - من Profile Page → اضغط على "الخصوصية والأمان"
   - أو انتقل مباشرة إلى: `PrivacySecurityPage`

2. **اضغط على "كلمة سر للدخول للسحاب"**:
   - يجب أن يظهر: "غير مفعل - اضغط لتفعيل"

3. **أدخل PIN (4 أرقام)**:
   - مثال: `1234`
   - يجب أن تظهر 4 خانات بتصميم محسّن

4. **أعد إدخال PIN للتأكيد**:
   - نفس الرقم: `1234`
   - إذا لم يتطابق، ستظهر رسالة خطأ

### ✅ **النتائج المتوقعة**:

**في Flutter App**:
- ✅ يظهر Toast: "تم تفعيل كلمة السر بنجاح"
- ✅ الحالة تتغير من "غير مفعل" إلى "مفعل - 4 أرقام"
- ✅ يمكنك الآن الضغط على "كلمة سر للدخول للسحاب" لتغيير PIN

**في Console (Flutter)**:
```
🔐 Security Settings Loaded:
   PIN Enabled: true
   Biometric Enabled: false
```

**في Backend Logs**:
```bash
# شاهد الـ logs
docker compose logs -f app
```
يجب أن ترى:
```
POST /api/v1/security/pin
```

---

## 🧪 **الاختبار 2: التحقق من PIN في قاعدة البيانات**

### الخطوات:

1. **افتح phpMyAdmin أو TablePlus**:
   - URL: `http://localhost:8080` (phpMyAdmin)
   - أو استخدم TablePlus

2. **افتح قاعدة البيانات**:
   - Database: `bnpl_db`
   - Table: `user_security_settings`

3. **تحقق من البيانات**:
```sql
SELECT 
    id,
    user_id,
    pin_enabled,
    biometric_enabled,
    created_at,
    updated_at
FROM user_security_settings
WHERE user_id = YOUR_USER_ID;
```

### ✅ **النتائج المتوقعة**:

- ✅ `pin_enabled` = `1` (true)
- ✅ `pin_hash` موجود (مشفر بـ bcrypt)
- ✅ `updated_at` محدث بالوقت الحالي

**ملاحظة**: `pin_hash` مشفر، لا يمكنك رؤية PIN الأصلي.

---

## 🧪 **الاختبار 3: اختبار API مباشرة (Postman/curl)**

### 3.1. الحصول على Security Settings:

```bash
# احصل على JWT Token من Flutter App (من SharedPreferences)
# ثم استخدمه في Authorization header

curl -X GET "http://localhost:3000/api/v1/security/settings" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**النتيجة المتوقعة**:
```json
{
  "success": true,
  "data": {
    "pinEnabled": true,
    "biometricEnabled": false
  }
}
```

### 3.2. التحقق من PIN:

```bash
curl -X POST "http://localhost:3000/api/v1/security/pin/verify" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"pin": "1234"}'
```

**النتيجة المتوقعة (PIN صحيح)**:
```json
{
  "success": true,
  "data": {
    "isValid": true
  },
  "message": "رقم التعريف صحيح"
}
```

**النتيجة المتوقعة (PIN خاطئ)**:
```json
{
  "success": true,
  "data": {
    "isValid": false
  },
  "message": "رقم التعريف غير صحيح"
}
```

### 3.3. تعيين PIN جديد:

```bash
curl -X POST "http://localhost:3000/api/v1/security/pin" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"pin": "5678"}'
```

**النتيجة المتوقعة**:
```json
{
  "success": true,
  "message": "تم تفعيل رقم التعريف الشخصي بنجاح"
}
```

---

## 🧪 **الاختبار 4: تغيير PIN من Flutter App**

### الخطوات:

1. **افتح صفحة الخصوصية والأمان**

2. **اضغط على "كلمة سر للدخول للسحاب"**:
   - الآن يجب أن يظهر: "مفعل - 4 أرقام"

3. **أدخل PIN الحالي**:
   - مثال: `1234` (PIN القديم)

4. **أدخل PIN جديد**:
   - مثال: `5678`
   - أكد PIN الجديد: `5678`

### ✅ **النتائج المتوقعة**:

- ✅ إذا PIN الحالي صحيح: يتم حفظ PIN الجديد
- ✅ إذا PIN الحالي خاطئ: رسالة "كلمة السر غير صحيحة"
- ✅ الحالة تبقى "مفعل"

---

## 🧪 **الاختبار 5: تعطيل PIN**

### من Flutter App (غير متاح حالياً):
- يمكن إضافة زر "تعطيل PIN" في المستقبل

### من API مباشرة:

```bash
curl -X DELETE "http://localhost:3000/api/v1/security/pin" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

**النتيجة المتوقعة**:
```json
{
  "success": true,
  "message": "تم تعطيل رقم التعريف الشخصي"
}
```

**في قاعدة البيانات**:
- ✅ `pin_enabled` = `0` (false)
- ✅ `pin_hash` = `NULL`

---

## 🧪 **الاختبار 6: اختبار Edge Cases**

### 6.1. PIN غير صحيح (3 أرقام):
- ❌ يجب أن يرفض: "رقم التعريف يجب أن يكون 4 أرقام"

### 6.2. PIN غير صحيح (5 أرقام):
- ❌ يجب أن يرفض: "رقم التعريف يجب أن يكون 4 أرقام"

### 6.3. PIN غير صحيح (أحرف):
- ❌ يجب أن يرفض: فقط أرقام مسموحة

### 6.4. PIN غير متطابق في التأكيد:
- ❌ يجب أن يظهر: "كلمة السر غير متطابقة، يرجى المحاولة مرة أخرى"

### 6.5. التحقق من PIN غير مفعل:
- ❌ يجب أن يرجع: `isValid: false`

---

## 🔍 **التشخيص (Debugging)**

### 1. تحقق من Logs في Flutter:

افتح Console في IDE أو Terminal:
```bash
flutter run
```

ابحث عن:
```
🔐 Security Settings Loaded:
   PIN Enabled: true/false
   Biometric Enabled: true/false
```

### 2. تحقق من Logs في Backend:

```bash
cd backend
docker compose logs -f app
```

ابحث عن:
- `POST /api/v1/security/pin`
- `GET /api/v1/security/settings`
- `POST /api/v1/security/pin/verify`

### 3. تحقق من Network Requests:

في Flutter DevTools:
- افتح Network tab
- ابحث عن requests إلى `/security/*`
- تحقق من Request/Response

### 4. تحقق من قاعدة البيانات:

```sql
-- تحقق من جميع إعدادات الأمان
SELECT * FROM user_security_settings;

-- تحقق من PIN hash (يجب أن يكون مشفر)
SELECT 
    user_id,
    pin_enabled,
    CASE 
        WHEN pin_hash IS NULL THEN 'NULL'
        ELSE 'HASHED (encrypted)'
    END as pin_status
FROM user_security_settings;
```

---

## ✅ **قائمة التحقق النهائية**

### بعد تعيين PIN:

- [ ] PIN محفوظ في قاعدة البيانات (`pin_enabled = 1`)
- [ ] `pin_hash` موجود ومشفر
- [ ] الحالة في Flutter تتحدث إلى "مفعل"
- [ ] يمكن التحقق من PIN بنجاح
- [ ] لا يمكن التحقق بـ PIN خاطئ

### بعد تغيير PIN:

- [ ] PIN القديم لا يعمل
- [ ] PIN الجديد يعمل
- [ ] `pin_hash` محدث في قاعدة البيانات

### بعد تعطيل PIN:

- [ ] `pin_enabled = 0` في قاعدة البيانات
- [ ] `pin_hash = NULL`
- [ ] الحالة في Flutter تتحدث إلى "غير مفعل"
- [ ] لا يمكن التحقق من PIN

---

## 🐛 **حل المشاكل الشائعة**

### المشكلة 1: PIN لا يظهر كمفعل بعد الحفظ

**الحل**:
1. تحقق من Console logs في Flutter
2. تحقق من `_loadSecuritySettings()` يتم استدعاؤها بعد `_setPin()`
3. تحقق من بنية Response من API

### المشكلة 2: PIN محفوظ لكن التحقق يفشل

**الحل**:
1. تحقق من `pin_hash` في قاعدة البيانات (يجب أن يكون موجود)
2. تحقق من أن PIN يتم إرساله بشكل صحيح
3. تحقق من Backend logs

### المشكلة 3: خطأ "رقم التعريف يجب أن يكون 4 أرقام"

**الحل**:
- تأكد من أن PIN بالضبط 4 أرقام
- تأكد من أن `inputFormatters: [FilteringTextInputFormatter.digitsOnly]` موجود

### المشكلة 4: Response structure error

**الحل**:
- تحقق من `_loadSecuritySettings()` يقرأ `backendData['data'] ?? backendData`
- تحقق من Backend response structure

---

## 📝 **ملاحظات مهمة**

1. **PIN مشفر**: لا يمكن رؤية PIN الأصلي في قاعدة البيانات
2. **JWT Token مطلوب**: جميع Security endpoints تحتاج authentication
3. **PIN مطلوب للبصمة**: يجب تفعيل PIN قبل تفعيل Biometric
4. **PIN محلي**: PIN محفوظ في قاعدة البيانات، ليس في SharedPreferences

---

## 🎯 **الاختبار السريع (Quick Test)**

```bash
# 1. تعيين PIN
curl -X POST "http://localhost:3000/api/v1/security/pin" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"pin": "1234"}'

# 2. التحقق من PIN
curl -X POST "http://localhost:3000/api/v1/security/pin/verify" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"pin": "1234"}'

# 3. الحصول على Settings
curl -X GET "http://localhost:3000/api/v1/security/settings" \
  -H "Authorization: Bearer TOKEN"
```

---

**تم إنشاء الدليل بواسطة AI Assistant** 🤖

