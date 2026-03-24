# إعداد البانرات (Banners Setup)

## خطوات الإعداد

### 1. إنشاء جدول البانرات

```bash
mysql -u root -p bnpl_db < backend/create-banners-table.sql
```

هذا الأمر سينشئ جدول `banners` مع بيانات تجريبية.

### 2. إضافة بيانات تجريبية إضافية (اختياري)

```bash
mysql -u root -p bnpl_db < backend/add-sample-banners.sql
```

هذا الأمر سيضيف 4 بانرات تجريبية:
- بانر للأزياء (Fashion)
- بانر للإلكترونيات (Electronics)
- بانر للرياضة (Sports)
- بانر عام (يظهر في كل الصفحات)

### 3. التحقق من البيانات

```bash
mysql -u root -p bnpl_db -e "SELECT id, title, title_ar, image_url, link_type, category_id, is_active FROM banners ORDER BY sort_order;"
```

## البانرات في التطبيق

### الصفحة الرئيسية (Home Page)
- البانرات تُعرض تلقائياً في أعلى الصفحة
- يتم تحميلها من API عند فتح الصفحة
- Carousel مع انتقال تلقائي كل 5 ثوانٍ
- عند النقر على البانر، يتم التنقل حسب نوع الرابط:
  - `category`: الانتقال إلى صفحة الفئة
  - `store`: الانتقال إلى صفحة المتجر
  - `product`: الانتقال إلى صفحة المنتج
  - `external`: فتح رابط خارجي
  - `none`: لا يوجد رابط

### صفحة الفلاتر (All Stores Page)
- البانرات تُعرض بعد الفلاتر مباشرة
- يتم تحديثها تلقائياً عند تغيير الفئة
- إذا كان `category_id` محدد، يظهر البانر فقط للفئة المحددة
- إذا كان `category_id` NULL، يظهر البانر في جميع الصفحات

## هيكل البانر في قاعدة البيانات

```sql
CREATE TABLE banners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NULL,                    -- العنوان بالإنجليزية
  title_ar VARCHAR(255) NULL,                 -- العنوان بالعربية
  image_url VARCHAR(500) NOT NULL,           -- رابط الصورة
  link_type ENUM('category', 'store', 'product', 'external', 'none') DEFAULT 'none',
  link_id INT NULL,                          -- معرف الرابط (category_id, store_id, etc.)
  category_id INT NULL,                      -- الفلتر: يظهر البانر فقط لهذه الفئة
  description TEXT NULL,                     -- الوصف بالإنجليزية
  description_ar TEXT NULL,                  -- الوصف بالعربية
  is_active BOOLEAN DEFAULT TRUE,            -- حالة التفعيل
  sort_order INT DEFAULT 0,                   -- ترتيب العرض
  start_date DATETIME NULL,                 -- تاريخ البدء
  end_date DATETIME NULL,                    -- تاريخ الانتهاء
  click_count INT DEFAULT 0,                 -- عدد النقرات
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## API Endpoints

### الحصول على جميع البانرات
```
GET /api/v1/banners
```

### الحصول على البانرات حسب الفئة
```
GET /api/v1/banners?categoryId=1
```

### الحصول على بانر محدد
```
GET /api/v1/banners/:id
```

### زيادة عدد النقرات
```
POST /api/v1/banners/:id/click
```

## إضافة بانر جديد

### عبر SQL:
```sql
INSERT INTO banners (title, title_ar, image_url, link_type, link_id, category_id, is_active, sort_order)
VALUES ('New Banner', 'بانر جديد', 'assets/images/banner.jpg', 'category', 1, 1, TRUE, 5);
```

### عبر API:
```bash
curl -X POST http://localhost:3000/api/v1/banners \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Banner",
    "titleAr": "بانر جديد",
    "imageUrl": "assets/images/banner.jpg",
    "linkType": "category",
    "linkId": 1,
    "categoryId": 1,
    "isActive": true,
    "sortOrder": 5
  }'
```

## ملاحظات مهمة

1. **الصور**: يجب أن تكون الصور موجودة في مجلد `assets/images/` في تطبيق Flutter
2. **الفئات**: تأكد من أن `category_id` موجود في جدول `categories`
3. **الروابط**: عند استخدام `link_type = 'category'`، يجب أن يكون `link_id` موجود في جدول `categories`
4. **التواريخ**: يمكن تحديد `start_date` و `end_date` لعرض البانر في فترة محددة
5. **الترتيب**: البانرات تُعرض حسب `sort_order` ثم `id`

