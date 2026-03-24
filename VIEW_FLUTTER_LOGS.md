# كيفية رؤية Flutter Console Logs

## 📱 طرق رؤية Logs في Flutter

### 1️⃣ **VS Code / Android Studio**

#### في VS Code:
1. افتح **Terminal** في VS Code (`` Ctrl+` `` أو `Cmd+` ``)
2. شغّل التطبيق باستخدام:
   ```bash
   cd forntendUser
   flutter run
   ```
3. ستظهر جميع الـ logs في Terminal مباشرة

#### في Android Studio:
1. افتح **Run** tab في الأسفل
2. أو **Logcat** tab (لـ Android)
3. ستظهر جميع الـ logs هناك

---

### 2️⃣ **Terminal مباشر**

```bash
cd forntendUser
flutter run
```

أو إذا كان التطبيق يعمل بالفعل:
```bash
flutter logs
```

---

### 3️⃣ **Flutter DevTools (مفيد جداً)**

```bash
cd forntendUser
flutter run
# ثم في terminal آخر:
flutter pub global run devtools
```

---

### 4️⃣ **Android Logcat (لـ Android فقط)**

```bash
adb logcat | grep flutter
```

أو لرؤية كل شيء:
```bash
adb logcat
```

---

### 5️⃣ **iOS Console (لـ iOS فقط)**

```bash
xcrun simctl spawn booted log stream --level=debug
```

أو استخدم **Console.app** في Mac:
1. افتح **Console.app**
2. اختر Simulator أو Device الخاص بك
3. ابحث عن "flutter" في البحث

---

## 🔍 Logs المتوقعة في Payments Page

عند فتح صفحة "المدفوعات المعلقة"، يجب أن ترى:

```
📊 [PaymentsPage] Received 3 payments from backend
  Payment 1: ID=15, Amount=75.25, Store=Fashion Store
  Payment 2: ID=13, Amount=150.50, Store=Test Store 1
  Payment 3: ID=14, Amount=250.00, Store=Electronics Store
📊 [PaymentsPage] Valid pending payments: 3 (from 3 total)
📊 [PaymentsPage] Formatted payments: 3
📊 [PaymentsPage] Total: 475.75 JOD, Due in 7 days: 225.75 JOD, Due in 30 days: 475.75 JOD
📊 [PaymentsPage] After removing duplicates: 3 payments
  Final Payment 1: ID=15, Amount=75.25, Merchant=Fashion Store
  Final Payment 2: ID=13, Amount=150.50, Merchant=Test Store 1
  Final Payment 3: ID=14, Amount=250.00, Merchant=Electronics Store
```

---

## 🐛 Backend Logs

لرؤية Backend logs:

```bash
cd backend
docker-compose logs app --tail=100 -f
```

أو للبحث عن payments فقط:
```bash
docker-compose logs app | grep -i "payment\|PaymentsService\|PaymentsController"
```

---

## ✅ التحقق من البيانات

### Backend يرجع 3 دفعات:
```
[PaymentsService] Found 3 pending payments for user 8
[PaymentsController] Returning 3 pending payments for user 8
```

### Flutter يجب أن يستقبل 3 دفعات:
```
📊 [PaymentsPage] Received 3 payments from backend
```

---

## 🔧 إذا لم تظهر Logs

1. **تأكد أن التطبيق يعمل**:
   ```bash
   flutter run
   ```

2. **افتح صفحة Payments** في التطبيق

3. **تحقق من Console/Terminal** - يجب أن تظهر الرسائل

4. **إذا لم تظهر**، جرب:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📊 ملخص

- **Backend**: يرجع 3 دفعات ✅
- **Flutter**: يجب أن يستقبل 3 دفعات ✅
- **UI**: يجب أن يعرض 3 دفعات ✅

إذا ظهرت 4 دفعات في UI، فهذا يعني أن هناك مشكلة في معالجة البيانات في Flutter.

