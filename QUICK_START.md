# ⚡ تشغيل المشروع - Quick Start

دليل سريع لتشغيل المشروع من الصفر.

---

## 🚀 **الخطوات السريعة**

### **1️⃣ تشغيل Backend**

```bash
cd backend
docker compose up -d
```

**النتيجة المتوقعة**:
- ✅ Backend يعمل على: `http://localhost:3000`
- ✅ MySQL يعمل على: `localhost:3306`

**التحقق**:
```bash
docker compose ps
```

يجب أن ترى:
```
NAME           STATUS
bnpl-backend   Up
bnpl-mysql     Up (healthy)
```

---

### **2️⃣ تشغيل Flutter**

#### **للـ iOS Simulator**:
```bash
cd ../forntendUser

# تأكد من baseUrl في env_dev.dart:
# baseUrl = 'http://localhost:3000'

flutter run -d ios
```

#### **للـ Android Emulator**:
```bash
cd ../forntendUser

# تأكد من baseUrl في env_dev.dart:
# baseUrl = 'http://10.0.2.2:3000'

flutter run -d android
```

#### **للـ Web**:
```bash
cd ../forntendUser

# تأكد من baseUrl في env_dev.dart:
# baseUrl = 'http://localhost:3000'

flutter run -d chrome
```

---

## ✅ **التحقق من أن كل شيء يعمل**

### **1. Backend يعمل:**

```bash
curl http://localhost:3000/api/v1/home/public
```

**النتيجة**: JSON response

---

### **2. Flutter متصل:**

- ✅ افتح التطبيق
- ✅ يجب أن ترى Splash Screen → Onboarding → Phone Input
- ✅ لا توجد أخطاء في Terminal

---

## 📱 **اختبار التطبيق**

### **1. التسجيل (مستخدم جديد):**

1. أدخل رقم: `799123456` (أي 9 أرقام)
2. اضغط "Continue"
3. للحصول على OTP:
   ```bash
   cd backend
   docker compose logs -f app
   ```
4. ابحث عن: `📱 OTP for +962799123456: XXXXXX`
5. أدخل OTP
6. التقط صور Civil ID (Front & Back)
7. املأ Profile
8. ✅ تم إنشاء الحساب!

---

### **2. بعد التسجيل:**

- ✅ ستجد Home Page (فارغة - لأن لا توجد Stores)
- ✅ يمكنك التجول في التطبيق
- ✅ Profile يعمل

---

## 🗄️ **إضافة البيانات الحقيقية**

### **الطريقة 1: TablePlus (الأسهل)**

1. افتح TablePlus
2. اتصل بـ MySQL:
   - Host: `localhost`
   - Port: `3306`
   - Username: `bnpl_user`
   - Password: `bnpl_password`
   - Database: `bnpl_db`

3. أضف Store:
   - افتح جدول `stores`
   - Add Row → املأ البيانات → Save

4. أضف Products:
   - افتح جدول `products`
   - Add Row → املأ البيانات (مع `store_id`) → Save

---

### **الطريقة 2: SQL مباشرة**

```sql
-- إضافة Store
INSERT INTO stores (
  name, name_ar, logo_url, description, description_ar,
  category, rating, has_deal, commission_rate,
  min_order_amount, max_order_amount, is_active, created_at, updated_at
) VALUES (
  'My Store', 'متجري', 'https://example.com/logo.png',
  'Description', 'الوصف', 'Fashion', 4.5, false,
  2.5, 50, 5000, true, NOW(), NOW()
);

-- إضافة Product (استخدم store_id من Store السابق)
INSERT INTO products (
  name, name_ar, price, currency, category, store_id,
  image_url, in_stock, rating, created_at, updated_at
) VALUES (
  'My Product', 'منتجي', 99.99, 'JOD', 'Electronics', 1,
  'https://example.com/product.jpg', true, 4.5, NOW(), NOW()
);
```

---

## 🔍 **أوامر مفيدة**

### **عرض Backend Logs:**
```bash
cd backend
docker compose logs -f app
```

### **إيقاف Backend:**
```bash
cd backend
docker compose down
```

### **إعادة تشغيل Backend:**
```bash
cd backend
docker compose restart app
```

### **عرض حالة Docker:**
```bash
docker compose ps
```

### **Hot Restart في Flutter:**
- اضغط `r` في Terminal
- أو `Cmd+Shift+P` → "Flutter: Hot Restart"

---

## 🐛 **مشاكل شائعة**

### **Backend لا يعمل:**

```bash
# شاهد الأخطاء
cd backend
docker compose logs app

# أعد التشغيل
docker compose restart app
```

### **Flutter لا يتصل:**

- **iOS Simulator**: `baseUrl = 'http://localhost:3000'`
- **Android Emulator**: `baseUrl = 'http://10.0.2.2:3000'`
- **Physical Device**: `baseUrl = 'http://YOUR_IP:3000'`

### **Database فارغة:**

- ✅ هذا طبيعي! البيانات تم حذفها
- ✅ أضف Stores و Products من TablePlus
- ✅ Users سيُضافون من خلال التسجيل

---

## ✅ **Checklist التشغيل**

- [ ] Backend يعمل (`docker compose ps`)
- [ ] Flutter يعمل (`flutter run`)
- [ ] لا توجد أخطاء في Terminal
- [ ] التطبيق يفتح بشكل صحيح
- [ ] يمكنك التسجيل بنجاح

---

## 📚 **ملفات مساعدة**

- `REAL_DATA_GUIDE.md` - دليل إضافة البيانات الحقيقية
- `TESTING_GUIDE.md` - دليل الاختبار الشامل
- `STEP_BY_STEP_TESTING.md` - خطوات الاختبار خطوة بخطوة

---

**جاهز للتشغيل! 🚀**

