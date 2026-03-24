# نظام الإشعارات الترويجية - Promo Notifications

## ✅ حالة النظام

### 1. قاعدة البيانات ✅
- ✅ الجدول `promo_notifications` موجود
- ✅ البيانات موجودة (2 إشعارات)
- ✅ الربط مع جدول `categories` موجود (Foreign Key)

### 2. البيانات الحالية:
```sql
SELECT id, title, title_ar, subtitle, subtitle_ar, category_id, is_active, sort_order 
FROM promo_notifications 
ORDER BY sort_order;
```

**النتيجة:**
- **ID: 7** - Price Compare (قارن الأسعار) - `category_id: NULL` (عام)
- **ID: 8** - Pay Less (ادفع أقل) - `category_id: NULL` (عام)

### 3. Backend API ✅
- ✅ Entity: `PromoNotification` موجود
- ✅ Service: `PromoNotificationsService` موجود
- ✅ Controller: `PromoNotificationsController` موجود
- ✅ Module: `PromoNotificationsModule` موجود ومُسجل في `app.module.ts`

### 4. Flutter ✅
- ✅ Service: `PromoNotificationService` موجود
- ✅ API Endpoints: موجودة في `api_endpoints.dart`
- ✅ Service Manager: موجود في `service_manager.dart`
- ✅ Home Page: يتم تحميل الإشعارات من API

## 🔗 الربط مع الفلاتر (Categories)

### كيفية الربط:

#### 1. إشعار عام (يظهر في كل الصفحات):
```sql
INSERT INTO promo_notifications (title, title_ar, subtitle, subtitle_ar, category_id, ...)
VALUES ('General Offer', 'عرض عام', 'Description', 'الوصف', NULL, ...);
```
- `category_id = NULL` → يظهر في الصفحة الرئيسية وكل الصفحات

#### 2. إشعار لفئة محددة (يظهر فقط عند اختيار هذه الفئة):
```sql
INSERT INTO promo_notifications (title, title_ar, subtitle, subtitle_ar, category_id, ...)
VALUES ('Fashion Offer', 'عرض الأزياء', 'Description', 'الوصف', 1, ...);
```
- `category_id = 1` → يظهر فقط عند اختيار فئة Fashion

### API Endpoints:

#### جلب جميع الإشعارات (عامة):
```bash
GET /api/v1/promo-notifications
```

#### جلب إشعارات فئة محددة:
```bash
GET /api/v1/promo-notifications?categoryId=1
```
- يعرض: إشعارات الفئة المحددة + الإشعارات العامة (category_id = NULL)

## 📝 إضافة إشعار جديد

### عبر SQL:
```sql
INSERT INTO promo_notifications (
  title, 
  title_ar, 
  subtitle, 
  subtitle_ar, 
  category_id,
  link_type,
  link_id,
  is_active, 
  sort_order,
  background_color,
  text_color
) VALUES (
  'New Offer',
  'عرض جديد',
  'Description',
  'الوصف',
  1,  -- category_id (NULL for general, or specific category ID)
  'category',  -- link_type: 'category', 'store', 'product', 'external', 'none'
  1,  -- link_id (category_id if link_type = 'category')
  TRUE,
  3,
  '#10B981',  -- background_color
  '#FFFFFF'   -- text_color
);
```

### عبر API:
```bash
curl -X POST http://localhost:3000/api/v1/promo-notifications \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Offer",
    "titleAr": "عرض جديد",
    "subtitle": "Description",
    "subtitleAr": "الوصف",
    "categoryId": 1,
    "linkType": "category",
    "linkId": 1,
    "isActive": true,
    "sortOrder": 3,
    "backgroundColor": "#10B981",
    "textColor": "#FFFFFF"
  }'
```

## 🔍 التحقق من البيانات

### التحقق من قاعدة البيانات:
```bash
docker exec -i bnpl-mysql mysql -uroot -proot_password bnpl_db -e \
  "SELECT id, title, title_ar, category_id, is_active, sort_order FROM promo_notifications ORDER BY sort_order;"
```

### التحقق من API:
```bash
curl http://localhost:3000/api/v1/promo-notifications
```

## 📍 مكان العرض

الإشعارات تظهر في:
- **الصفحة الرئيسية (Home Page)**: مباشرة بعد شريط البحث وقبل قسم "Pending Payments"
- يتم عرض أول إشعار من القائمة (حسب `sort_order`)

## 🎨 التخصيص

- **الألوان**: يمكن تخصيص `background_color` و `text_color`
- **الروابط**: يمكن ربط الإشعار بفئة، متجر، منتج، أو رابط خارجي
- **الفلاتر**: يمكن ربط الإشعار بفئة محددة عبر `category_id`

