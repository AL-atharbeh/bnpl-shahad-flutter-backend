# إعداد نظام الفئات - خطوات التنفيذ

## الخطوة 1: تشغيل Migration Script على قاعدة البيانات

### الطريقة 1: عبر MySQL Command Line

```bash
mysql -u root -p bnpl_db < backend/create-categories-table.sql
```

### الطريقة 2: عبر MySQL Client (TablePlus, MySQL Workbench, etc.)

1. افتح MySQL Client
2. اختر قاعدة البيانات `bnpl_db`
3. افتح ملف `backend/create-categories-table.sql`
4. نفذ السكريبت كاملاً

### التحقق من النجاح

بعد تشغيل السكريبت، يجب أن ترى رسالة:
```
Categories table created and stores/products tables updated successfully!
total_categories: 10
stores_with_category: X
products_with_category: Y
```

## الخطوة 2: اختبار APIs

### 1. الحصول على جميع الفئات

```bash
curl http://localhost:3000/categories
```

### 2. الحصول على المتاجر مع فلترة حسب الفئة

```bash
# جميع المتاجر
curl http://localhost:3000/stores

# المتاجر في فئة محددة (مثلاً ID: 1)
curl http://localhost:3000/stores?categoryId=1

# البحث في المتاجر مع فلترة
curl "http://localhost:3000/stores/search?q=nike&categoryId=5"
```

## الخطوة 3: اختبار Frontend

1. تأكد من أن Backend يعمل على `http://localhost:3000`
2. شغل Flutter App
3. اذهب إلى صفحة "جميع المتاجر"
4. يجب أن ترى فلاتر الفئات الديناميكية بدلاً من الثابتة

## ملاحظات

- ✅ الفئات الافتراضية (10 فئات) يتم إنشاؤها تلقائياً
- ✅ المتاجر والمنتجات الموجودة سيتم ربطها بالفئات تلقائياً إذا كان لها `category` موجود
- ✅ يمكنك إضافة فئات جديدة عبر API أو SQL (راجع `ADD_CATEGORY_EXAMPLES.md`)

## استكشاف الأخطاء

### المشكلة: "Table 'categories' already exists"

**الحل:** الجدول موجود بالفعل. يمكنك:
1. حذف الجدول وإعادة تشغيل السكريبت:
```sql
DROP TABLE IF EXISTS categories;
-- ثم شغل السكريبت مرة أخرى
```

2. أو تخطي خطوة إنشاء الجدول وتشغيل باقي الأوامر فقط

### المشكلة: "Foreign key constraint fails"

**الحل:** تأكد من أن الجدول `categories` موجود قبل تشغيل الأوامر التي تضيف Foreign Keys.

### المشكلة: Frontend لا يعرض الفئات

**الحل:**
1. تأكد من أن Backend يعمل
2. تحقق من console logs في Flutter
3. تأكد من أن API endpoint `/categories` يعمل
4. تحقق من أن `CategoryService` تم استيراده بشكل صحيح

