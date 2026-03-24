# نظام الإشعارات داخل التطبيق (In-App Notifications)

## نظرة عامة

تم إنشاء جدول جديد `in_app_notifications` مرتبط بجدول `notifications` الأساسي. هذا الجدول مخصص لتتبع الإشعارات داخل التطبيق بشكل منفصل عن الإشعارات العامة.

## البنية

### جدول `in_app_notifications`

- **`id`**: المعرف الفريد
- **`notification_id`**: معرف الإشعار الأساسي (مرتبط بجدول `notifications`)
- **`user_id`**: معرف المستخدم
- **`is_displayed`**: هل تم عرض الإشعار
- **`displayed_at`**: وقت العرض
- **`is_clicked`**: هل تم الضغط على الإشعار
- **`clicked_at`**: وقت الضغط
- **`priority`**: الأولوية (low, medium, high, urgent)
- **`category`**: الفئة
- **`action_button_text`**: نص زر الإجراء (اختياري)
- **`action_url`**: رابط الإجراء (اختياري)
- **`expires_at`**: تاريخ انتهاء الصلاحية (اختياري)
- **`metadata`**: بيانات إضافية (JSON)
- **`created_at`**: تاريخ الإنشاء
- **`updated_at`**: تاريخ التحديث

## العلاقات

- **One-to-One** مع `notifications`: كل إشعار داخل التطبيق مرتبط بإشعار واحد أساسي
- **Many-to-One** مع `users`: كل مستخدم يمكن أن يكون له عدة إشعارات داخل التطبيق

## API Endpoints

### 1. الحصول على جميع الإشعارات داخل التطبيق
```
GET /api/v1/in-app-notifications
Authorization: Bearer {token}
```

### 2. الحصول على الإشعارات غير المقروءة
```
GET /api/v1/in-app-notifications/unread
Authorization: Bearer {token}
```

### 3. الحصول على إحصائيات الإشعارات
```
GET /api/v1/in-app-notifications/stats
Authorization: Bearer {token}
```

### 4. إنشاء إشعار داخل التطبيق
```
POST /api/v1/in-app-notifications
Authorization: Bearer {token}
Body: {
  "notificationId": 1,
  "priority": "high",
  "category": "payment",
  "actionButtonText": "عرض التفاصيل",
  "actionUrl": "/payments/123",
  "expiresAt": "2025-12-31T23:59:59Z",
  "metadata": {}
}
```

### 5. تحديد الإشعار كمعروض
```
PUT /api/v1/in-app-notifications/:id/displayed
Authorization: Bearer {token}
```

### 6. تحديد الإشعار كمضغوط
```
PUT /api/v1/in-app-notifications/:id/clicked
Authorization: Bearer {token}
```

### 7. حذف إشعار داخل التطبيق
```
DELETE /api/v1/in-app-notifications/:id
Authorization: Bearer {token}
```

## التكامل التلقائي

عند إنشاء إشعار جديد عبر `NotificationsService.sendToUser()`، يتم إنشاء إشعار داخل التطبيق تلقائياً.

## خطوات التنفيذ

### 1. تشغيل Migration

```bash
# داخل Docker container
docker exec -i bnpl-db mysql -u bnpl_user -pbnpl_password bnpl_db < backend/src/database/migrations/create-in-app-notifications-table.sql

# أو يدوياً عبر phpMyAdmin أو MySQL client
```

### 2. إعادة تشغيل Backend

```bash
cd backend
npm run start:dev
```

## الاستخدام في Flutter

يمكن استخدام الـ API endpoints أعلاه في تطبيق Flutter لعرض وتتبع الإشعارات داخل التطبيق.

## ملاحظات

- الجدول مرتبط بجدول `notifications` عبر `CASCADE DELETE` - عند حذف إشعار أساسي، يتم حذف الإشعار داخل التطبيق تلقائياً
- يمكن تتبع تفاعل المستخدم مع الإشعارات (عرض، ضغط)
- يدعم الأولويات والفئات لتنظيم الإشعارات
- يدعم أزرار الإجراءات والروابط المخصصة

