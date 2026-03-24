# كيفية إضافة فئة جديدة

## الطريقة 1: استخدام API (مُوصى به)

### إضافة فئة جديدة عبر POST Request

**Endpoint:** `POST /categories`

**Headers:**
```
Content-Type: application/json
```

**Body Example:**
```json
{
  "name": "Jewelry & Watches",
  "nameAr": "المجوهرات والساعات",
  "icon": "diamond",
  "description": "Jewelry and watches stores",
  "descriptionAr": "متاجر المجوهرات والساعات",
  "sortOrder": 11,
  "isActive": true
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/categories \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jewelry & Watches",
    "nameAr": "المجوهرات والساعات",
    "icon": "diamond",
    "description": "Jewelry and watches stores",
    "descriptionAr": "متاجر المجوهرات والساعات",
    "sortOrder": 11
  }'
```

**JavaScript/Fetch Example:**
```javascript
const response = await fetch('http://localhost:3000/categories', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: 'Jewelry & Watches',
    nameAr: 'المجوهرات والساعات',
    icon: 'diamond',
    description: 'Jewelry and watches stores',
    descriptionAr: 'متاجر المجوهرات والساعات',
    sortOrder: 11,
    isActive: true
  })
});

const result = await response.json();
console.log(result);
```

**Response:**
```json
{
  "success": true,
  "message": "تم إنشاء الفئة بنجاح",
  "data": {
    "id": 11,
    "name": "Jewelry & Watches",
    "nameAr": "المجوهرات والساعات",
    "icon": "diamond",
    "imageUrl": null,
    "description": "Jewelry and watches stores",
    "descriptionAr": "متاجر المجوهرات والساعات",
    "isActive": true,
    "sortOrder": 11,
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

## الطريقة 2: استخدام SQL مباشرة

### استخدام SQL Script

```bash
mysql -u root -p bnpl_db < add-new-category.sql
```

أو عبر MySQL Client:
```sql
USE bnpl_db;

INSERT INTO categories (name, name_ar, icon, description, description_ar, sort_order, is_active) 
VALUES 
(
  'Jewelry & Watches',
  'المجوهرات والساعات',
  'diamond',
  'Jewelry and watches stores',
  'متاجر المجوهرات والساعات',
  11,
  TRUE
);
```

## أمثلة فئات إضافية

### فئات مقترحة:

1. **المجوهرات والساعات**
   - Name: `Jewelry & Watches`
   - NameAr: `المجوهرات والساعات`
   - Icon: `diamond`

2. **مستلزمات الحيوانات الأليفة**
   - Name: `Pet Supplies`
   - NameAr: `مستلزمات الحيوانات الأليفة`
   - Icon: `pets`

3. **الرضع والأطفال**
   - Name: `Baby & Kids`
   - NameAr: `الرضع والأطفال`
   - Icon: `child_care`

4. **المستلزمات المكتبية**
   - Name: `Office Supplies`
   - NameAr: `المستلزمات المكتبية`
   - Icon: `business`

5. **المواد الغذائية**
   - Name: `Grocery`
   - NameAr: `المواد الغذائية`
   - Icon: `shopping_cart`

6. **السفر والسياحة**
   - Name: `Travel & Tourism`
   - NameAr: `السفر والسياحة`
   - Icon: `flight`

## الحقول المطلوبة

- `name` (مطلوب) - الاسم بالإنجليزية
- `nameAr` (مطلوب) - الاسم بالعربية
- `icon` (اختياري) - اسم الأيقونة
- `description` (اختياري) - الوصف بالإنجليزية
- `descriptionAr` (اختياري) - الوصف بالعربية
- `sortOrder` (اختياري، افتراضي: 0) - ترتيب العرض
- `isActive` (اختياري، افتراضي: true) - حالة الفئة
- `imageUrl` (اختياري) - رابط صورة الفئة

## التحقق من الفئة المضافة

```bash
# الحصول على جميع الفئات
curl http://localhost:3000/categories

# الحصول على فئة محددة
curl http://localhost:3000/categories/11
```

## تحديث فئة موجودة

```bash
curl -X PUT http://localhost:3000/categories/11 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Category Name",
    "nameAr": "اسم الفئة المحدث"
  }'
```

