# الـ Endpoints الناقصة في Mock Server

## نظرة عامة

هذا الملف يوثق الـ endpoints التي لم نغطيها في الـ Mock Server الحالي ويحتاج إلى إضافتها.

## الـ Endpoints المطلوبة

### 1. Authentication (إضافية)
- `POST /auth/logout`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `POST /auth/verify-email`
- `POST /auth/resend-verification`

### 2. User Profile (إضافية)
- `PUT /profile/avatar`
- `GET /profile/orders`
- `GET /profile/wishlist`
- `POST /profile/wishlist`
- `DELETE /profile/wishlist/{productId}`

### 3. Stores (إضافية)
- `GET /stores/{id}/reviews`
- `POST /stores/{id}/reviews`
- `GET /stores/search`
- `GET /stores/categories`

### 4. Products (إضافية)
- `GET /products/search`
- `GET /products/categories`
- `GET /products/trending`
- `GET /products/new`
- `GET /products/offers`
- `GET /products/{id}/reviews`
- `POST /products/{id}/reviews`

### 5. Shopping Cart (كاملة)
- `GET /cart`
- `POST /cart/add`
- `PUT /cart/update`
- `DELETE /cart/remove/{productId}`
- `DELETE /cart/clear`
- `POST /cart/apply-coupon`
- `DELETE /cart/remove-coupon`

### 6. Orders (كاملة)
- `POST /orders`
- `GET /orders`
- `GET /orders/{id}`
- `PUT /orders/{id}/cancel`
- `GET /orders/{id}/tracking`
- `POST /orders/{id}/review`

### 7. Payments (كاملة)
- `POST /payments/initiate`
- `POST /payments/confirm`
- `POST /payments/cancel`
- `GET /payments/methods`
- `POST /payments/methods`
- `DELETE /payments/methods/{id}`
- `GET /payments/history`

### 8. BNPL (كاملة)
- `POST /bnpl/check-eligibility`
- `POST /bnpl/apply`
- `GET /bnpl/plans`
- `GET /bnpl/installments`
- `POST /bnpl/installments/{id}/pay`
- `GET /bnpl/credit-score`

### 9. Offers & Promotions (كاملة)
- `GET /offers`
- `GET /offers/{id}`
- `POST /offers/{id}/claim`
- `GET /offers/my`
- `GET /offers/categories`

### 10. Notifications (إضافية)
- `PUT /notifications/read-all`
- `DELETE /notifications/{id}`
- `GET /notifications/settings`
- `PUT /notifications/settings`

### 11. Addresses (كاملة)
- `GET /addresses`
- `POST /addresses`
- `PUT /addresses/{id}`
- `DELETE /addresses/{id}`
- `PUT /addresses/{id}/default`

### 12. Categories & Filters (كاملة)
- `GET /categories`
- `GET /categories/{id}`
- `GET /categories/{id}/products`
- `GET /filters`
- `POST /filters/apply`

### 13. Search (كاملة)
- `GET /search`
- `GET /search/suggestions`
- `GET /search/history`
- `DELETE /search/history`

### 14. Reviews & Ratings (إضافية)
- `PUT /reviews/{id}`
- `DELETE /reviews/{id}`
- `POST /reviews/{id}/like`
- `DELETE /reviews/{id}/like`

### 15. Support & Help (كاملة)
- `GET /support/faq`
- `POST /support/ticket`
- `GET /support/tickets`
- `GET /support/tickets/{id}`
- `POST /support/tickets/{id}/reply`

### 16. Analytics & Tracking (كاملة)
- `POST /analytics/event`
- `GET /analytics/dashboard`

## أولويات التنفيذ

### المرحلة الأولى (الأولوية العالية)
1. **Shopping Cart** - أساسي للتجارة الإلكترونية
2. **Orders** - أساسي للطلبات
3. **Payments** - أساسي للمدفوعات
4. **BNPL** - أساسي للميزة الرئيسية

### المرحلة الثانية (الأولوية المتوسطة)
1. **User Profile** - إدارة الملف الشخصي
2. **Addresses** - إدارة العناوين
3. **Categories & Filters** - تصفية المنتجات
4. **Search** - البحث في المنتجات

### المرحلة الثالثة (الأولوية المنخفضة)
1. **Offers & Promotions** - العروض
2. **Reviews & Ratings** - التقييمات
3. **Support & Help** - الدعم
4. **Analytics & Tracking** - التحليلات

## خطة التنفيذ

### الأسبوع الأول
- إضافة Shopping Cart endpoints
- إضافة Orders endpoints
- اختبار الـ endpoints الأساسية

### الأسبوع الثاني
- إضافة Payments endpoints
- إضافة BNPL endpoints
- اختبار تدفق الشراء الكامل

### الأسبوع الثالث
- إضافة User Profile endpoints
- إضافة Addresses endpoints
- تحسين الـ error handling

### الأسبوع الرابع
- إضافة باقي الـ endpoints
- اختبار شامل
- توثيق نهائي

## ملاحظات مهمة

1. **Authentication**: جميع الـ endpoints تحتاج authentication
2. **Validation**: إضافة validation للبيانات المدخلة
3. **Error Handling**: تحسين رسائل الأخطاء
4. **Pagination**: إضافة pagination للقوائم الطويلة
5. **Rate Limiting**: إضافة rate limiting للحماية
6. **Logging**: إضافة logging شامل
7. **Testing**: كتابة tests للـ endpoints
