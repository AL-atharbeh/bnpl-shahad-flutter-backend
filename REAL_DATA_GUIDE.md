# 📊 دليل إضافة البيانات الحقيقية - Real Data Guide

دليل كامل لإضافة البيانات الحقيقية إلى قاعدة البيانات MySQL.

---

## ✅ **ما تم إنجازه**

- ✅ تم حذف جميع البيانات التجريبية
- ✅ قاعدة البيانات الآن فارغة وجاهزة للبيانات الحقيقية
- ✅ جميع الـ Endpoints جاهزة للاستخدام
- ✅ التطبيق مربوط بالكامل مع MySQL

---

## 📋 **طرق إضافة البيانات**

### **1. من خلال التطبيق (Users فقط)**

المستخدمون يمكنهم:
- ✅ التسجيل من خلال التطبيق
- ✅ إضافة بياناتهم الشخصية
- ✅ رفع صور Civil ID

**البيانات التي تُضاف تلقائياً**:
- Users (من خلال Register)
- Payments (عند إجراء عمليات شراء)
- Notifications (تلقائياً من Backend)
- Reward Points (عند إجراء معاملات)
- Postponements (عند استخدام ميزة التأجيل)

---

### **2. من خلال MySQL مباشرة (Stores & Products)**

#### **إضافة Store:**

```sql
INSERT INTO stores (
  name, 
  name_ar, 
  logo_url, 
  description, 
  description_ar, 
  category, 
  rating, 
  has_deal, 
  deal_description, 
  deal_description_ar, 
  commission_rate, 
  min_order_amount, 
  max_order_amount, 
  is_active, 
  created_at, 
  updated_at
) VALUES (
  'Store Name',
  'اسم المتجر',
  'https://example.com/logo.png',
  'Store description',
  'وصف المتجر',
  'Fashion',
  4.5,
  true,
  'Special offer',
  'عرض خاص',
  2.5,
  50,
  5000,
  true,
  NOW(),
  NOW()
);
```

#### **إضافة Product:**

```sql
INSERT INTO products (
  name,
  name_ar,
  description,
  description_ar,
  price,
  currency,
  category,
  store_id,
  images,
  image_url,
  in_stock,
  rating,
  reviews_count,
  created_at,
  updated_at
) VALUES (
  'Product Name',
  'اسم المنتج',
  'Product description',
  'وصف المنتج',
  99.99,
  'JOD',
  'Electronics',
  1, -- Store ID
  '["https://example.com/image1.jpg", "https://example.com/image2.jpg"]',
  'https://example.com/image1.jpg',
  true,
  4.5,
  120,
  NOW(),
  NOW()
);
```

---

### **3. من خلال Backend API (موصى به)**

يمكنك إضافة Stores و Products من خلال API endpoints (يحتاج Admin Panel أو Postman):

#### **إضافة Store (يحتاج Admin Endpoint):**

```bash
POST /api/v1/admin/stores
{
  "name": "Store Name",
  "nameAr": "اسم المتجر",
  "logoUrl": "https://example.com/logo.png",
  "description": "Description",
  "descriptionAr": "الوصف",
  "category": "Fashion",
  "commissionRate": 2.5,
  "minOrderAmount": 50,
  "maxOrderAmount": 5000
}
```

**ملاحظة**: Admin endpoints غير موجودة حالياً، يمكن إضافتها لاحقاً.

---

### **4. استخدام TablePlus (أسهل طريقة)**

1. ✅ افتح TablePlus
2. ✅ اتصل بـ MySQL:
   - Host: `localhost`
   - Port: `3306`
   - Username: `bnpl_user`
   - Password: `bnpl_password`
   - Database: `bnpl_db`

3. ✅ افتح جدول `stores`
4. ✅ اضغط "Add Row"
5. ✅ املأ البيانات
6. ✅ Save

---

## 🔧 **أوامر SQL مفيدة**

### **عرض جميع البيانات:**

```sql
-- عرض جميع المتاجر
SELECT * FROM stores;

-- عرض جميع المنتجات
SELECT * FROM products;

-- عرض جميع المستخدمين
SELECT id, name, phone, email, created_at FROM users;

-- عرض جميع الدفعات
SELECT * FROM payments;
```

### **إضافة Store سريع:**

```sql
INSERT INTO stores (
  name, name_ar, logo_url, description, description_ar, 
  category, rating, has_deal, commission_rate, 
  min_order_amount, max_order_amount, is_active, created_at, updated_at
) VALUES (
  'My Store', 'متجري', 'https://example.com/logo.png', 
  'Description', 'الوصف', 'Fashion', 4.5, false, 
  2.5, 50, 5000, true, NOW(), NOW()
);
```

### **إضافة Product سريع:**

```sql
INSERT INTO products (
  name, name_ar, price, currency, category, store_id, 
  image_url, in_stock, rating, reviews_count, created_at, updated_at
) VALUES (
  'My Product', 'منتجي', 99.99, 'JOD', 'Electronics', 1,
  'https://example.com/product.jpg', true, 4.5, 0, NOW(), NOW()
);
```

---

## 📱 **البيانات التي تُضاف تلقائياً من التطبيق**

### **عند التسجيل:**
- ✅ User record
- ✅ Civil ID images (base64)

### **عند إجراء عملية شراء:**
- ✅ Payment record
- ✅ Reward Points (إذا كان متاح)

### **من Backend (تلقائياً):**
- ✅ Notifications (عند أحداث معينة)
- ✅ Postponements (عند استخدام التأجيل)

---

## 🗂️ **هيكل الجداول**

### **Users:**
- `id`, `name`, `phone`, `email`, `civil_id_front`, `civil_id_back`, `date_of_birth`, `address`, `monthly_income`, `employer`, etc.

### **Stores:**
- `id`, `name`, `name_ar`, `logo_url`, `description`, `description_ar`, `category`, `rating`, `has_deal`, `commission_rate`, etc.

### **Products:**
- `id`, `name`, `name_ar`, `description`, `description_ar`, `price`, `currency`, `category`, `store_id`, `images`, `image_url`, etc.

### **Payments:**
- `id`, `user_id`, `store_id`, `amount`, `currency`, `status`, `due_date`, etc.

---

## ✅ **التحقق من البيانات**

### **من MySQL:**

```sql
-- عدد المستخدمين
SELECT COUNT(*) FROM users;

-- عدد المتاجر
SELECT COUNT(*) FROM stores;

-- عدد المنتجات
SELECT COUNT(*) FROM products;

-- عدد الدفعات
SELECT COUNT(*) FROM payments;
```

### **من Backend API:**

```bash
# عرض جميع المتاجر
curl http://localhost:3000/api/v1/stores

# عرض جميع المنتجات
curl http://localhost:3000/api/v1/products

# عرض بيانات Home (public)
curl http://localhost:3000/api/v1/home/public
```

---

## 🎯 **خطوات العمل الموصى بها**

### **1. إضافة Stores أولاً:**

```sql
-- أضف 5-10 متاجر حقيقية
INSERT INTO stores (...) VALUES (...);
```

### **2. إضافة Products لكل Store:**

```sql
-- لكل متجر، أضف 10-20 منتج
INSERT INTO products (..., store_id, ...) VALUES (..., 1, ...);
```

### **3. اختبار من التطبيق:**

- ✅ افتح التطبيق
- ✅ سجّل حساب جديد
- ✅ تحقق من Home Page (يجب أن تظهر المتاجر)
- ✅ افتح Store Details (يجب أن تظهر المنتجات)

---

## 📝 **نموذج بيانات Store كاملة**

```sql
INSERT INTO stores (
  name, name_ar, logo_url, description, description_ar,
  category, rating, has_deal, deal_description, deal_description_ar,
  commission_rate, min_order_amount, max_order_amount,
  supported_countries, supported_currencies, is_active, created_at, updated_at
) VALUES (
  'Zara', 'زارا',
  'https://logos-world.net/wp-content/uploads/2020/04/Zara-Logo.png',
  'Spanish clothing retailer', 'متجر ملابس إسباني',
  'Fashion', 4.8, true,
  '10% OFF on selected items', 'خصم 10% على أصناف مختارة',
  2.5, 50, 5000,
  '["JO"]', '["JOD"]', true, NOW(), NOW()
);
```

---

## 📝 **نموذج بيانات Product كاملة**

```sql
INSERT INTO products (
  name, name_ar, description, description_ar, price, currency,
  category, store_id, images, image_url, in_stock, rating, reviews_count,
  created_at, updated_at
) VALUES (
  'T-Shirt', 'قميص',
  'Cotton t-shirt', 'قميص قطن',
  29.99, 'JOD',
  'Clothing', 1,
  '["https://example.com/tshirt1.jpg", "https://example.com/tshirt2.jpg"]',
  'https://example.com/tshirt1.jpg',
  true, 4.5, 120,
  NOW(), NOW()
);
```

---

## 🔍 **التحقق من الربط**

### **1. تحقق من Backend:**

```bash
curl http://localhost:3000/api/v1/stores
# يجب أن يعرض المتاجر التي أضفتها

curl http://localhost:3000/api/v1/home/public
# يجب أن يعرض البيانات الحقيقية
```

### **2. تحقق من التطبيق:**

- ✅ افتح Home Page
- ✅ يجب أن ترى المتاجر الحقيقية
- ✅ افتح Store Details
- ✅ يجب أن ترى المنتجات الحقيقية

---

## 💡 **نصائح**

1. ✅ **ابدأ بـ Stores**: أضف المتاجر أولاً
2. ✅ **أضف Products**: أضف منتجات لكل متجر
3. ✅ **استخدم TablePlus**: أسهل طريقة لإضافة البيانات
4. ✅ **تحقق دائماً**: بعد إضافة البيانات، تحقق من التطبيق

---

## 📞 **مشاكل شائعة**

### **المشكلة: لا تظهر المتاجر في التطبيق**

**التحقق**:
```sql
SELECT * FROM stores WHERE is_active = true;
```

**الحل**: تأكد من `is_active = true`

### **المشكلة: لا تظهر المنتجات في Store Details**

**التحقق**:
```sql
SELECT * FROM products WHERE store_id = 1;
```

**الحل**: تأكد من `store_id` صحيح

---

## ✅ **الخلاصة**

- ✅ البيانات التجريبية تم حذفها
- ✅ قاعدة البيانات فارغة وجاهزة
- ✅ التطبيق مربوط بالكامل مع MySQL
- ✅ أضف Stores و Products من MySQL أو TablePlus
- ✅ Users سيُضافون تلقائياً من خلال التطبيق

**جاهز لإضافة البيانات الحقيقية! 🚀**

