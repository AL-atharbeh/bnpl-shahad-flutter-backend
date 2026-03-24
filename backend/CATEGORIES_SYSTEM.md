# نظام الفئات (Categories System)

## نظرة عامة

تم إنشاء نظام فئات شامل لإدارة فئات المتاجر والمنتجات في نظام BNPL. النظام يدعم:

- ✅ إنشاء وإدارة الفئات (CRUD)
- ✅ ربط المتاجر والمنتجات بالفئات
- ✅ فلترة المتاجر والمنتجات حسب الفئة
- ✅ دعم متعدد اللغات (عربي/إنجليزي)

## قاعدة البيانات

### جدول categories

```sql
- id (PK)
- name (VARCHAR 255) - الاسم بالإنجليزية
- name_ar (VARCHAR 255) - الاسم بالعربية
- icon (VARCHAR 100) - اسم الأيقونة
- image_url (VARCHAR 500) - رابط صورة الفئة
- description (TEXT) - الوصف بالإنجليزية
- description_ar (TEXT) - الوصف بالعربية
- is_active (BOOLEAN) - حالة الفئة
- sort_order (INT) - ترتيب العرض
- created_at, updated_at
```

### تحديث الجداول الموجودة

تم إضافة عمود `category_id` إلى:
- جدول `stores` - رابط Foreign Key إلى `categories.id`
- جدول `products` - رابط Foreign Key إلى `categories.id`

## كيفية التنفيذ

### 1. تشغيل Migration Script

```bash
mysql -u root -p bnpl_db < create-categories-table.sql
```

أو عبر MySQL Client:
```sql
SOURCE create-categories-table.sql;
```

### 2. الفئات الافتراضية

يتم إنشاء 10 فئات افتراضية:
1. الأزياء والملابس (Fashion & Clothing)
2. الإلكترونيات (Electronics)
3. المنزل والأثاث (Home & Furniture)
4. الجمال ومستحضرات التجميل (Beauty & Cosmetics)
5. الرياضة والهواء الطلق (Sports & Outdoors)
6. الطعام والمشروبات (Food & Beverages)
7. الصحة والعافية (Health & Wellness)
8. الكتب والتعليم (Books & Education)
9. الألعاب (Toys & Games)
10. السيارات (Automotive)

## APIs

### Categories APIs

#### GET /categories
الحصول على جميع الفئات النشطة

**Query Parameters:**
- لا يوجد

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Fashion & Clothing",
      "nameAr": "الأزياء والملابس",
      "icon": "shopping_bag",
      "imageUrl": null,
      "description": "Fashion and clothing stores",
      "descriptionAr": "متاجر الأزياء والملابس",
      "isActive": true,
      "sortOrder": 1
    }
  ]
}
```

#### GET /categories/with-counts
الحصول على الفئات مع عدد المتاجر في كل فئة

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Fashion & Clothing",
      "nameAr": "الأزياء والملابس",
      "storesCount": 5
    }
  ]
}
```

#### GET /categories/:id
الحصول على فئة محددة

#### POST /categories
إنشاء فئة جديدة

**Body:**
```json
{
  "name": "New Category",
  "nameAr": "فئة جديدة",
  "icon": "icon_name",
  "description": "Category description",
  "descriptionAr": "وصف الفئة",
  "sortOrder": 11
}
```

#### PUT /categories/:id
تحديث فئة

#### DELETE /categories/:id
حذف فئة (soft delete إذا كانت مرتبطة بمتاجر/منتجات)

### Stores APIs - تحديثات

#### GET /stores
الحصول على جميع المتاجر مع فلترة حسب الفئة

**Query Parameters:**
- `categoryId` (optional): فلترة حسب ID الفئة

**Example:**
```
GET /stores?categoryId=1
```

#### GET /stores/category/:categoryId
الحصول على المتاجر في فئة محددة

#### GET /stores/deals?categoryId=1
الحصول على المتاجر التي لديها عروض مع فلترة حسب الفئة

#### GET /stores/search?q=search&categoryId=1
البحث في المتاجر مع فلترة حسب الفئة

### Products APIs - تحديثات

#### GET /products?categoryId=1
الحصول على جميع المنتجات مع فلترة حسب الفئة

#### GET /products/category/:categoryId
الحصول على المنتجات في فئة محددة

#### GET /products/store/:storeId?categoryId=1
الحصول على منتجات متجر مع فلترة حسب الفئة

#### GET /products/search?q=search&categoryId=1
البحث في المنتجات مع فلترة حسب الفئة

## أمثلة الاستخدام

### إضافة متجر جديد مع فئة

عند إنشاء متجر جديد، يجب تحديد `categoryId`:

```typescript
{
  name: "Nike Store",
  nameAr: "متجر نايك",
  categoryId: 5, // Sports & Outdoors
  // ... باقي الحقول
}
```

### إضافة منتج جديد مع فئة

```typescript
{
  storeId: 1,
  name: "Running Shoes",
  nameAr: "أحذية جري",
  categoryId: 5, // Sports & Outdoors
  // ... باقي الحقول
}
```

### فلترة المتاجر حسب الفئة

```javascript
// الحصول على جميع متاجر الأزياء
fetch('/stores?categoryId=1')

// البحث في متاجر الإلكترونيات
fetch('/stores/search?q=phone&categoryId=2')
```

## ملاحظات مهمة

1. **الرجوع للخلف (Backward Compatibility)**: تم الاحتفاظ بحقل `category` القديم (VARCHAR) للتوافق مع البيانات الموجودة، لكن يُفضل استخدام `categoryId`.

2. **Soft Delete**: عند حذف فئة مرتبطة بمتاجر أو منتجات، يتم تعطيلها فقط (soft delete) وليس حذفها نهائياً.

3. **الترتيب**: يتم ترتيب الفئات حسب `sortOrder` ثم حسب الاسم.

4. **العلاقات**: كل فئة يمكن أن تحتوي على متاجر ومنتجات متعددة.

## الخطوات التالية

1. ✅ تشغيل migration script
2. ✅ اختبار APIs
3. ⬜ تحديث Frontend لدعم الفئات
4. ⬜ إضافة واجهة إدارة الفئات في Admin Panel

