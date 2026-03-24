# إضافة عمود عدد المتاجر في جدول الفئات

## نظرة عامة

تم إضافة عمود `stores_count` إلى جدول `categories` لحفظ عدد المتاجر النشطة في كل فئة. هذا العمود يتم تحديثه تلقائياً عبر Triggers في قاعدة البيانات.

## المميزات

✅ **عمود `stores_count`** في جدول `categories`
✅ **Triggers تلقائية** لتحديث العدد عند إضافة/تحديث/حذف المتاجر
✅ **عرض العدد في Frontend** في بطاقات الفئات في الصفحة الرئيسية
✅ **أداء محسّن** - لا حاجة لحساب العدد في كل مرة

## الخطوات التنفيذية

### 1. تشغيل Migration Script

```bash
mysql -u root -p bnpl_db < backend/add-stores-count-to-categories.sql
```

أو عبر MySQL Client:
```sql
SOURCE backend/add-stores-count-to-categories.sql;
```

### 2. التحقق من النجاح

بعد تشغيل السكريبت، يجب أن ترى:
- ✅ عمود `stores_count` تم إضافته
- ✅ Triggers تم إنشاؤها (3 triggers)
- ✅ العدد الأولي تم حسابه وتحديثه

يمكنك التحقق عبر:
```sql
SELECT id, name, name_ar, stores_count FROM categories;
```

## كيفية عمل Triggers

### 1. `after_store_insert`
- عند إضافة متجر جديد
- إذا كان `category_id` موجود و `is_active = TRUE`
- يزيد `stores_count` في الفئة المحددة

### 2. `after_store_update`
- عند تحديث متجر
- إذا تغير `category_id`: يقلل العدد في الفئة القديمة ويزيد في الجديدة
- إذا تغير `is_active`: يزيد/يقلل العدد حسب الحالة

### 3. `after_store_delete`
- عند حذف متجر
- يقلل `stores_count` في الفئة المحددة

## التحديثات في الكود

### Backend

1. **Category Entity** (`category.entity.ts`):
   - إضافة `storesCount: number`

2. **CategoriesService**:
   - استخدام `storesCount` من قاعدة البيانات مباشرة
   - لا حاجة لحساب العدد يدوياً

### Frontend

1. **CategoryService** (`category_service.dart`):
   - `storesCount` أصبح حقل إلزامي (default: 0)

2. **Home Page**:
   - عرض عدد المتاجر في بطاقة الفئة
   - Badge ملون يعرض "X متجر" أو "X stores"

## مثال على الاستخدام

### في API Response:

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Fashion & Clothing",
      "nameAr": "الأزياء والملابس",
      "storesCount": 15,
      ...
    }
  ]
}
```

### في Frontend:

البطاقة ستظهر:
- العنوان: "الأزياء والملابس"
- Badge: "15 متجر" (بالأخضر الفاتح)

## ملاحظات مهمة

1. **التحديث التلقائي**: العدد يتم تحديثه تلقائياً عند أي تغيير في المتاجر
2. **الأداء**: استخدام `stores_count` أسرع من حساب العدد في كل مرة
3. **التوافق**: الكود القديم سيعمل بشكل طبيعي (storesCount = 0 إذا لم يكن موجود)

## استكشاف الأخطاء

### المشكلة: stores_count = 0 لجميع الفئات

**الحل:**
```sql
-- إعادة حساب العدد يدوياً
UPDATE categories c
SET stores_count = (
  SELECT COUNT(*) 
  FROM stores s 
  WHERE s.category_id = c.id 
  AND s.is_active = TRUE
);
```

### المشكلة: Triggers لا تعمل

**الحل:**
```sql
-- التحقق من وجود Triggers
SHOW TRIGGERS;

-- إذا لم تكن موجودة، شغل السكريبت مرة أخرى
```

## الخطوات التالية

1. ✅ تشغيل migration script
2. ✅ اختبار إضافة متجر جديد والتحقق من تحديث العدد
3. ✅ التحقق من عرض العدد في Frontend

