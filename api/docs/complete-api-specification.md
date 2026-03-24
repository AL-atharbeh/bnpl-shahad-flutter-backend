# BNPL Complete API Specification

## نظرة عامة

هذا الملف يحتوي على جميع الـ API endpoints المطلوبة لتطبيق BNPL (Buy Now Pay Later).

## Base URL

```
http://localhost:3000/api/v1
```

## Authentication

جميع الـ endpoints تتطلب Bearer Token في الـ header:

```
Authorization: Bearer <token>
```

## 1. Authentication & User Management

### POST /auth/login
تسجيل الدخول

### POST /auth/register
إنشاء حساب جديد

### POST /auth/logout
تسجيل الخروج

### POST /auth/forgot-password
نسيت كلمة المرور

### POST /auth/reset-password
إعادة تعيين كلمة المرور

### POST /auth/verify-email
تأكيد البريد الإلكتروني

### POST /auth/resend-verification
إعادة إرسال رمز التأكيد

## 2. User Profile

### GET /profile
جلب معلومات المستخدم

### PUT /profile
تحديث معلومات المستخدم

### PUT /profile/avatar
تحديث صورة الملف الشخصي

### GET /profile/orders
جلب طلبات المستخدم

### GET /profile/wishlist
جلب قائمة الأمنيات

### POST /profile/wishlist
إضافة منتج لقائمة الأمنيات

### DELETE /profile/wishlist/{productId}
إزالة منتج من قائمة الأمنيات

## 3. Stores

### GET /stores
جلب قائمة المتاجر

### GET /stores/{id}
جلب تفاصيل متجر معين

### GET /stores/{id}/reviews
جلب تقييمات متجر معين

### POST /stores/{id}/reviews
إضافة تقييم لمتجر

### GET /stores/search
البحث في المتاجر

### GET /stores/categories
جلب فئات المتاجر

## 4. Products

### GET /stores/{storeId}/products
جلب منتجات متجر معين

### GET /products/{id}
جلب تفاصيل منتج معين

### GET /products/search
البحث في المنتجات

### GET /products/categories
جلب فئات المنتجات

### GET /products/trending
جلب المنتجات الرائجة

### GET /products/new
جلب المنتجات الجديدة

### GET /products/offers
جلب المنتجات المعروضة

### GET /products/{id}/reviews
جلب تقييمات منتج معين

### POST /products/{id}/reviews
إضافة تقييم لمنتج

## 5. Shopping Cart

### GET /cart
جلب محتويات السلة

### POST /cart/add
إضافة منتج للسلة

### PUT /cart/update
تحديث كمية منتج في السلة

### DELETE /cart/remove/{productId}
إزالة منتج من السلة

### DELETE /cart/clear
تفريغ السلة

### POST /cart/apply-coupon
تطبيق كوبون خصم

### DELETE /cart/remove-coupon
إزالة كوبون الخصم

## 6. Orders

### POST /orders
إنشاء طلب جديد

### GET /orders
جلب طلبات المستخدم

### GET /orders/{id}
جلب تفاصيل طلب معين

### PUT /orders/{id}/cancel
إلغاء طلب

### GET /orders/{id}/tracking
تتبع الطلب

### POST /orders/{id}/review
إضافة تقييم للطلب

## 7. Payments

### POST /payments/initiate
بدء عملية الدفع

### POST /payments/confirm
تأكيد الدفع

### POST /payments/cancel
إلغاء الدفع

### GET /payments/methods
جلب طرق الدفع المتاحة

### POST /payments/methods
إضافة طريقة دفع جديدة

### DELETE /payments/methods/{id}
حذف طريقة دفع

### GET /payments/history
سجل المدفوعات

## 8. BNPL (Buy Now Pay Later)

### POST /bnpl/check-eligibility
فحص الأهلية للتقسيط

### POST /bnpl/apply
التقدم بطلب تقسيط

### GET /bnpl/plans
جلب خطط التقسيط المتاحة

### GET /bnpl/installments
جلب أقساط المستخدم

### POST /bnpl/installments/{id}/pay
دفع قسط

### GET /bnpl/credit-score
جلب درجة الائتمان

## 9. Offers & Promotions

### GET /offers
جلب العروض المتاحة

### GET /offers/{id}
جلب تفاصيل عرض معين

### POST /offers/{id}/claim
المطالبة بعرض

### GET /offers/my
جلب عروضي

### GET /offers/categories
جلب فئات العروض

## 10. Notifications

### GET /notifications
جلب الإشعارات

### PUT /notifications/{id}/read
تحديد إشعار كمقروء

### PUT /notifications/read-all
تحديد جميع الإشعارات كمقروءة

### DELETE /notifications/{id}
حذف إشعار

### GET /notifications/settings
جلب إعدادات الإشعارات

### PUT /notifications/settings
تحديث إعدادات الإشعارات

## 11. Addresses

### GET /addresses
جلب عناوين المستخدم

### POST /addresses
إضافة عنوان جديد

### PUT /addresses/{id}
تحديث عنوان

### DELETE /addresses/{id}
حذف عنوان

### PUT /addresses/{id}/default
تعيين عنوان كافتراضي

## 12. Categories & Filters

### GET /categories
جلب جميع الفئات

### GET /categories/{id}
جلب فئة معينة

### GET /categories/{id}/products
جلب منتجات فئة معينة

### GET /filters
جلب الفلاتر المتاحة

### POST /filters/apply
تطبيق فلاتر

## 13. Search

### GET /search
البحث العام

### GET /search/suggestions
اقتراحات البحث

### GET /search/history
سجل البحث

### DELETE /search/history
حذف سجل البحث

## 14. Reviews & Ratings

### GET /reviews
جلب التقييمات

### POST /reviews
إضافة تقييم

### PUT /reviews/{id}
تحديث تقييم

### DELETE /reviews/{id}
حذف تقييم

### POST /reviews/{id}/like
إعجاب بتقييم

### DELETE /reviews/{id}/like
إلغاء الإعجاب بتقييم

## 15. Support & Help

### GET /support/faq
الأسئلة الشائعة

### POST /support/ticket
إنشاء تذكرة دعم

### GET /support/tickets
جلب تذاكر الدعم

### GET /support/tickets/{id}
جلب تفاصيل تذكرة

### POST /support/tickets/{id}/reply
الرد على تذكرة

## 16. Analytics & Tracking

### POST /analytics/event
تتبع الأحداث

### GET /analytics/dashboard
لوحة التحكم التحليلية

## Error Responses

جميع الأخطاء تتبع نفس التنسيق:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "رسالة الخطأ",
    "details": {
      "field": "تفاصيل إضافية"
    }
  }
}
```

## Status Codes

- `200` - نجح الطلب
- `201` - تم الإنشاء بنجاح
- `400` - خطأ في البيانات
- `401` - غير مصرح
- `403` - محظور
- `404` - غير موجود
- `409` - تعارض
- `422` - بيانات غير صحيحة
- `429` - طلبات كثيرة جداً
- `500` - خطأ في الخادم

## Pagination

للـ endpoints التي تدعم الصفحات:

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}
```

## Filtering & Sorting

```json
{
  "filters": {
    "category": "electronics",
    "price_min": 100,
    "price_max": 1000,
    "rating": 4
  },
  "sort": {
    "field": "price",
    "order": "asc"
  }
}
```
