# 🔍 دليل تصحيح مشاكل رفع صورة الملف الشخصي

## الأخطاء الشائعة وحلولها

### 1. خطأ في تحويل الصورة إلى Base64

**الخطأ**: `Error converting image to base64`

**الحل**:
- تأكد من أن الصورة موجودة في المسار المحدد
- تحقق من الصلاحيات (Permissions) للكاميرا والمعرض
- تأكد من أن الصورة ليست كبيرة جداً (>2MB)

### 2. خطأ في إرسال البيانات إلى Backend

**الخطأ**: `خطأ في الاتصال` أو `Request failed`

**الحل**:
- تحقق من أن Backend يعمل: `docker-compose ps`
- تحقق من الـ Token في الـ Request
- تحقق من حجم البيانات المرسلة (Base64 قد يكون كبير)

### 3. Backend لا يحفظ الصورة

**الخطأ**: الصورة لا تظهر بعد الحفظ

**الحل**:
- تحقق من أن `avatarUrl` موجود في `User` entity
- تحقق من الـ logs في Backend
- تأكد من أن البيانات تصل بشكل صحيح

## خطوات التشخيص

### 1. تحقق من Flutter Logs

```bash
cd forntendUser
flutter run
# ابحث عن:
# - 📸 Converting avatar image to base64...
# - ✅ Avatar converted successfully
# - 📤 Sending update profile request...
# - 📥 Response received
```

### 2. تحقق من Backend Logs

```bash
cd backend
docker-compose logs app --tail=50
# ابحث عن:
# - PUT /users/profile
# - أي أخطاء في الـ validation
```

### 3. تحقق من قاعدة البيانات

```sql
SELECT id, name, phone, avatar_url FROM users WHERE id = YOUR_USER_ID;
```

## الحلول السريعة

### إذا كانت الصورة كبيرة جداً:

```dart
// في personal_data_page.dart
final XFile? image = await _imagePicker.pickImage(
  source: source,
  imageQuality: 60, // قلل من 80 إلى 60
  maxWidth: 600,    // قلل من 800 إلى 600
  maxHeight: 600,  // قلل من 800 إلى 600
);
```

### إذا كان Backend لا يستقبل البيانات:

```typescript
// في users.controller.ts
async updateProfile(@Request() req, @Body() updateData: any) {
  console.log('Received update data:', updateData); // أضف هذا
  const user = await this.usersService.updateProfile(req.user.id, updateData);
  // ...
}
```

## دعم الصور الكبيرة

إذا كانت الصور كبيرة جداً، يمكن:
1. تقليل جودة الصورة (imageQuality: 60)
2. تقليل حجم الصورة (maxWidth/maxHeight: 600)
3. استخدام ضغط الصورة قبل الإرسال
4. رفع الصورة إلى S3 أو Cloudinary بدلاً من Base64

