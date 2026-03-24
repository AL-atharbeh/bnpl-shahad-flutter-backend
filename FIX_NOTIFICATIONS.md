# 🔔 دليل إصلاح الإشعارات - خطوة بخطوة

## المشكلة الحالية
- FCM Token = `null` في قاعدة البيانات
- Firebase لم يتم تهيئته بشكل صحيح
- الإشعارات لا تصل إلى التطبيق

## الحل - خطوة بخطوة

### الخطوة 1: تنظيف المشروع
```bash
cd /Users/ahmadal-atharbeh/project/bnpl/forntendUser
flutter clean
```

### الخطوة 2: إعادة تثبيت Dependencies
```bash
flutter pub get
```

### الخطوة 3: إعادة بناء iOS (مهم جداً!)
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### الخطوة 4: إعادة تشغيل التطبيق
```bash
flutter run
```

### الخطوة 5: راقب الـ Logs
يجب أن ترى:
```
🔥 Starting Firebase initialization...
🔥 Step 1: Initializing Firebase Core...
✅ Firebase Core initialized
🔥 Step 2: Getting FirebaseMessaging instance...
✅ FirebaseMessaging instance obtained
🔥 Step 3: Requesting notification permissions...
✅ Permission status: authorized
🔥 Step 4: Getting FCM token...
✅ FCM Token obtained successfully!
```

### الخطوة 6: سجّل الدخول في التطبيق
- أدخل رقم الهاتف: `+962792380449`
- أدخل رمز OTP
- بعد تسجيل الدخول، يجب أن ترى:
```
🔐 User logged in successfully, updating FCM token...
📤 Attempting to update FCM token on server...
✅ FCM token updated on server successfully!
```

### الخطوة 7: تحقق من FCM Token
```bash
curl -s http://localhost:3000/api/v1/users/4 | grep fcmToken
```
يجب أن يظهر FCM token (وليس `null`)

### الخطوة 8: أرسل إشعار تجريبي
```bash
curl -X POST http://localhost:3000/api/v1/notifications/send \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "4",
    "title": "تجربة إشعار",
    "body": "مرحباً! هذا إشعار تجريبي"
  }'
```

## ملاحظات مهمة

1. **iOS Simulator**: FCM قد لا يعمل بشكل كامل على Simulator. الأفضل اختبار على جهاز فعلي.

2. **Bundle ID**: تم تحديثه من `com.example.bnpl` إلى `com.shifracode.shahad` - يجب أن يطابق `GoogleService-Info.plist`

3. **Firebase Setup**: تأكد من أن `GoogleService-Info.plist` موجود في `ios/Runner/` ومضاف إلى Xcode project

4. **Permissions**: تأكد من أن التطبيق طلب صلاحيات الإشعارات وتم الموافقة عليها

## إذا استمرت المشكلة

1. افتح Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. في Xcode:
   - Clean Build Folder: `Product` → `Clean Build Folder` (Shift+Cmd+K)
   - تأكد من أن `GoogleService-Info.plist` مضاف إلى Target "Runner"
   - Build: `Product` → `Build` (Cmd+B)

3. تحقق من Bundle ID في Xcode:
   - افتح `Runner` target
   - General → Bundle Identifier
   - يجب أن يكون: `com.shifracode.shahad`

## اختبار على جهاز فعلي

إذا كنت تستخدم iOS Simulator، جرب على جهاز فعلي:
1. ربط iPhone بالكمبيوتر
2. `flutter run` (سيختار الجهاز تلقائياً)
3. تأكد من أن iPhone و Mac على نفس الشبكة

