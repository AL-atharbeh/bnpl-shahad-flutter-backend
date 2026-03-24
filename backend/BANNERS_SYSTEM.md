# نظام البانرات (Banners System)

## نظرة عامة

تم إنشاء نظام شامل لإدارة البانرات الإعلانية في الصفحة الرئيسية. النظام يدعم:

- ✅ إنشاء وإدارة البانرات (CRUD)
- ✅ ربط البانرات بالفئات للفلترة
- ✅ أنواع روابط متعددة (فئة، متجر، منتج، رابط خارجي)
- ✅ دعم تواريخ البدء والانتهاء
- ✅ تتبع عدد النقرات
- ✅ عرض ديناميكي في Frontend

## قاعدة البيانات

### جدول banners

```sql
- id (PK)
- title (VARCHAR 255) - العنوان بالإنجليزية (اختياري)
- title_ar (VARCHAR 255) - العنوان بالعربية (اختياري)
- image_url (VARCHAR 500) - رابط الصورة (مطلوب)
- link_url (VARCHAR 500) - رابط التنقل (اختياري)
- link_type (ENUM) - نوع الرابط: category, store, product, external, none
- link_id (INT) - معرف الكيان المرتبط
- category_id (FK) - الفئة المرتبطة (للفلترة)
- description (TEXT) - الوصف بالإنجليزية
- description_ar (TEXT) - الوصف بالعربية
- is_active (BOOLEAN) - حالة البانر
- sort_order (INT) - ترتيب العرض
- start_date (DATETIME) - تاريخ البدء
- end_date (DATETIME) - تاريخ الانتهاء
- click_count (INT) - عدد النقرات
- created_at, updated_at
```

## كيفية التنفيذ

### 1. تشغيل Migration Script

```bash
mysql -u root -p bnpl_db < backend/create-banners-table.sql
```

أو عبر MySQL Client:
```sql
SOURCE backend/create-banners-table.sql;
```

### 2. البانرات الافتراضية

يتم إنشاء 3 بانرات افتراضية:
1. عرض الأزياء (Fashion Sale) - مرتبط بفئة الأزياء
2. عرض الإلكترونيات (Electronics Offer) - مرتبط بفئة الإلكترونيات
3. مجموعة الرياضة (Sports Collection) - مرتبط بفئة الرياضة

## APIs

### Banners APIs

#### GET /banners
الحصول على جميع البانرات النشطة

**Query Parameters:**
- `categoryId` (optional): فلترة حسب ID الفئة

**Example:**
```
GET /banners?categoryId=1
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Fashion Sale",
      "titleAr": "عرض الأزياء",
      "imageUrl": "assets/images/banner1.jpg",
      "linkType": "category",
      "linkId": 1,
      "categoryId": 1,
      "isActive": true,
      "sortOrder": 1,
      "clickCount": 0
    }
  ]
}
```

#### GET /banners/:id
الحصول على بانر محدد

#### POST /banners
إنشاء بانر جديد

**Body:**
```json
{
  "title": "New Banner",
  "titleAr": "بانر جديد",
  "imageUrl": "https://example.com/banner.jpg",
  "linkType": "category",
  "linkId": 1,
  "categoryId": 1,
  "description": "Banner description",
  "descriptionAr": "وصف البانر",
  "sortOrder": 1,
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-12-31T23:59:59Z"
}
```

#### PUT /banners/:id
تحديث بانر

#### DELETE /banners/:id
حذف بانر

#### POST /banners/:id/click
زيادة عدد النقرات (يتم استدعاؤه تلقائياً عند النقر)

#### GET /banners/category/:categoryId
الحصول على البانرات في فئة محددة

## أنواع الروابط (Link Types)

1. **category** - رابط لفئة
   - `linkId` = category_id
   - عند النقر، ينتقل إلى صفحة الفئة

2. **store** - رابط لمتجر
   - `linkId` = store_id
   - عند النقر، ينتقل إلى صفحة المتجر

3. **product** - رابط لمنتج
   - `linkId` = product_id
   - عند النقر، ينتقل إلى صفحة المنتج

4. **external** - رابط خارجي
   - `linkUrl` = الرابط الخارجي
   - عند النقر، يفتح الرابط في المتصفح

5. **none** - بدون رابط
   - عند النقر، يعرض رسالة فقط

## الفلترة حسب الفئة

يمكن عرض البانرات حسب الفئة:

```bash
# جميع البانرات
GET /banners

# بانرات فئة محددة
GET /banners?categoryId=1

# بانرات فئة محددة مباشرة
GET /banners/category/1
```

## Frontend Integration

### BannerService

```dart
// Get all banners
final banners = await bannerService.getAllBanners();

// Get banners by category
final banners = await bannerService.getAllBanners(categoryId: 1);

// Increment click count
await bannerService.incrementClick(bannerId);
```

### HomePage

- البانرات يتم تحميلها تلقائياً عند فتح الصفحة
- دعم الصور من الشبكة (network images) والـ assets
- Navigation تلقائي حسب نوع الرابط
- تتبع النقرات تلقائياً

## أمثلة الاستخدام

### إضافة بانر جديد

```bash
curl -X POST http://localhost:3000/banners \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Summer Sale",
    "titleAr": "عرض الصيف",
    "imageUrl": "https://example.com/summer-banner.jpg",
    "linkType": "category",
    "linkId": 1,
    "categoryId": 1,
    "sortOrder": 1
  }'
```

### تحديث بانر

```bash
curl -X PUT http://localhost:3000/banners/1 \
  -H "Content-Type: application/json" \
  -d '{
    "isActive": false
  }'
```

### حذف بانر

```bash
curl -X DELETE http://localhost:3000/banners/1
```

## ملاحظات مهمة

1. **التواريخ**: إذا تم تحديد `startDate` و `endDate`، سيتم عرض البانر فقط خلال هذه الفترة
2. **الفلترة**: `categoryId` يستخدم للفلترة - يمكن أن يكون null لعرض البانر لجميع الفئات
3. **النقرات**: يتم تتبع عدد النقرات تلقائياً عند النقر على البانر
4. **الترتيب**: يتم ترتيب البانرات حسب `sortOrder` ثم حسب `created_at`

## الخطوات التالية

1. ✅ تشغيل migration script
2. ✅ اختبار APIs
3. ⬜ تحديث Frontend لعرض البانرات الديناميكية (تم ✅)
4. ⬜ إضافة واجهة إدارة البانرات في Admin Panel

