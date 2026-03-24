# 🧪 دليل الاختبار الشامل - BNPL Project

دليل كامل لاختبار جميع ميزات المشروع بعد ربط Flutter مع Backend.

---

## 📋 **متطلبات ما قبل الاختبار**

### ✅ **التحقق من الجاهزية**:
```bash
# 1. تحقق من Docker
docker --version

# 2. تحقق من Node.js
node --version

# 3. تحقق من Flutter
flutter --version

# 4. تحقق من MySQL (اختياري - إذا لم تستخدم Docker)
mysql --version
```

---

## 🚀 **الخطوة 1: تشغيل Backend**

### **الطريقة 1: استخدام Docker (مُوصى به)**

```bash
cd backend

# 1. تحقق من ملف .env موجود
ls -la .env

# 2. ابدأ Docker Compose
docker compose up -d

# 3. تحقق من الحالة
docker compose ps

# 4. شاهد السجلات
docker compose logs -f backend
```

**ملاحظات**:
- ✅ Backend سيبدأ على: `http://localhost:3000`
- ✅ MySQL سيبدأ على: `localhost:3306`
- ✅ API prefix: `/api/v1`

### **الطريقة 2: بدون Docker**

```bash
cd backend

# 1. تثبيت Dependencies
npm install

# 2. تأكد من MySQL يعمل
brew services start mysql  # macOS
# أو
sudo systemctl start mysql  # Linux

# 3. شغل Backend
npm run start:dev

# أو للـ build أولاً:
npm run build
npm run start:prod
```

---

## 🌱 **الخطوة 2: تهيئة قاعدة البيانات**

### **تشغيل Seed Script**:

```bash
cd backend

# إذا استخدمت Docker:
docker compose exec backend npm run seed

# أو بدون Docker:
npm run seed
```

**ما سيتم إنشاؤه**:
- ✅ 15 متجر (stores)
- ✅ ~80 منتج (products)
- ✅ مستخدم تجريبي: `+962799999999` / `password123`
- ✅ 4 دفعات (payments) - 3 pending, 1 completed
- ✅ 5 إشعارات (notifications)
- ✅ 2 معاملات نقاط (reward points)

**تحقق من Seed**:
```bash
# في MySQL أو TablePlus
SELECT COUNT(*) FROM stores;  -- يجب أن يكون 15
SELECT COUNT(*) FROM products;  -- يجب أن يكون ~80
```

---

## 📱 **الخطوة 3: تشغيل Flutter App**

```bash
cd forntendUser

# 1. تثبيت Dependencies
flutter pub get

# 2. تحقق من Configuration
# تأكد من ملف lib/config/env/env_dev.dart يحتوي على:
# baseUrl: 'http://10.0.2.2:3000'  (Android Emulator)
# أو 'http://localhost:3000'  (iOS Simulator/Web)

# 3. شغل التطبيق
flutter run

# أو لجهاز محدد:
flutter run -d android
flutter run -d ios
flutter run -d chrome  # للويب
```

**ملاحظات**:
- 📱 **Android Emulator**: استخدم `http://10.0.2.2:3000`
- 🍎 **iOS Simulator**: استخدم `http://localhost:3000`
- 🌐 **Web**: استخدم `http://localhost:3000`
- 📲 **Physical Device**: استخدم IP جهازك (مثل `http://192.168.1.100:3000`)

---

## 🔐 **الاختبار 1: Authentication Flow**

### **1.1. Phone Input**:
1. ✅ افتح التطبيق
2. ✅ اكتب رقم: `799999999` (9 أرقام)
3. ✅ اضغط "Continue"

**النتيجة المتوقعة**:
- ✅ Backend يطبع OTP في Console
- ✅ الانتقال إلى صفحة OTP

### **1.2. OTP Verification**:
1. ✅ افتح Backend console
2. ✅ انسخ OTP من السجلات
3. ✅ أدخل OTP (6 أرقام)
4. ✅ اضغط "Verify"

**النتيجة المتوقعة**:
- ✅ إذا المستخدم موجود: الانتقال إلى Home
- ✅ إذا مستخدم جديد: الانتقال إلى Civil ID Capture

### **1.3. Civil ID Capture (مستخدم جديد)**:
1. ✅ اضغط "Take Photo" للجهة الأمامية
2. ✅ التقط صورة أو اختر من المعرض
3. ✅ اضغط "Take Photo" للجهة الخلفية
4. ✅ اضغط "Continue"

**النتيجة المتوقعة**:
- ✅ الانتقال إلى Complete Profile

### **1.4. Complete Profile**:
1. ✅ املأ البيانات:
   - Full Name
   - Civil ID Number
   - Date of Birth
   - Address
   - Monthly Income
   - Employer
2. ✅ اضغط "Create Account"

**النتيجة المتوقعة**:
- ✅ إنشاء حساب بنجاح
- ✅ حفظ JWT Token
- ✅ الانتقال إلى Home Page

---

## 🏠 **الاختبار 2: Home Page**

### **التحقق من**:
1. ✅ **Top Stores**: عرض المتاجر الأعلى تقييمًا
2. ✅ **Offers**: عرض المتاجر التي لديها عروض
3. ✅ **Featured Stores**: عرض المتاجر المميزة
4. ✅ **Pending Payments**: عرض الدفعات المستحقة
5. ✅ **Unread Notifications**: عدد الإشعارات غير المقروءة
6. ✅ **Categories**: عرض الفئات
7. ✅ **Banners**: عرض البانرات

**Test Navigation**:
- ✅ اضغط على Store → الانتقال إلى Store Details
- ✅ اضغط على Category → الانتقال إلى Category Browse
- ✅ اضغط على Payment → الانتقال إلى Payments Page

---

## 🏪 **الاختبار 3: Stores Pages**

### **3.1. All Stores Page**:
1. ✅ من Home → اضغط "All Stores"
2. ✅ **التحقق من**:
   - عرض جميع المتاجر في Grid
   - الشعارات تظهر (Network images)
   - الأسماء تظهر بالعربية/الإنجليزية

3. ✅ **Search Test**:
   - ابحث عن متجر (مثل "Zara")
   - النتيجة: عرض المتاجر المطابقة

4. ✅ **Filter Test**:
   - اختر فئة (Fashion, Electronics, etc.)
   - النتيجة: عرض المتاجر في هذه الفئة

5. ✅ **Navigation Test**:
   - اضغط على متجر
   - النتيجة: الانتقال إلى Store Details

### **3.2. Category Browse Page**:
1. ✅ من Home → اضغط على Category
2. ✅ **Stores Tab**:
   - عرض المتاجر في الفئة المحددة
   - Search يعمل
   - Navigation إلى Store Details

3. ✅ **Products Tab**:
   - اضغط على Products tab
   - عرض المنتجات في Grid
   - Search يعمل
   - Navigation إلى Product Details

### **3.3. Store Details Page**:
1. ✅ من أي صفحة → افتح Store Details
2. ✅ **التحقق من**:
   - Store banner يظهر
   - Store logo يظهر
   - Rating & Reviews
   - Description
   - Deal banner (إذا كان hasDeal = true)

3. ✅ **Products Section**:
   - عرض Products Grid
   - Loading state يظهر أثناء التحميل
   - Empty state إذا لا يوجد منتجات
   - Network images للمنتجات

4. ✅ **Navigation Test**:
   - اضغط على منتج
   - الانتقال إلى Product Details

### **3.4. Product Details Page**:
1. ✅ من Store Details → اضغط على منتج
2. ✅ **التحقق من**:
   - Product images في PageView
   - Product title بالعربية/الإنجليزية
   - Product description
   - Price يظهر (JD X.XX)
   - Store name & logo
   - Attributes table (Category, Currency, In Stock)
   - Installment banner

3. ✅ **Navigation Test**:
   - Back button يعمل
   - Shop button موجود

---

## 💳 **الاختبار 4: Payments & Postponements**

### **4.1. Payments Page**:
1. ✅ من Bottom Navigation → اضغط "Payments"
2. ✅ **التحقق من**:
   - عرض جميع الدفعات (Pending + Completed)
   - Pending Payments في الأعلى
   - Bill cards تظهر بشكل صحيح

### **4.2. Free Postpone Feature**:
1. ✅ ابحث عن Pending Payment
2. ✅ **التحقق من Badge**:
   - Badge "Free Postpone Available" يظهر (إذا متاح)
   - أو "Used this month" (إذا تم الاستخدام)

3. ✅ **Test Postpone**:
   - اضغط "Postpone for Free"
   - تأكيد في Bottom Sheet
   - **النتيجة المتوقعة**:
     - Due Date يزيد 10 أيام
     - Badge يختفي أو يتغير
     - رسالة نجاح

4. ✅ **Test Once Per Month**:
   - استخدم Free Postpone مرة أخرى
   - **النتيجة المتوقعة**:
     - رسالة "Already used this month"
     - أو Badge يختفي

### **4.3. Extend Due Date (Paid)**:
1. ✅ اضغط على "Extend Due Date" (دفعة مدفوعة)
2. ✅ اختر عدد الأيام
3. ✅ **النتيجة المتوقعة**:
   - Due Date يتحدث
   - رسالة نجاح

### **4.4. Payment History**:
1. ✅ افتح Payments History
2. ✅ **التحقق من**:
   - Completed Payments تظهر
   - التاريخ والمبلغ صحيح

---

## 🎁 **الاختبار 5: Rewards**

### **5.1. Rewards Points**:
1. ✅ من Profile → Rewards (إذا كان موجود)
2. ✅ **التحقق من**:
   - Current Points تظهر
   - Points History يعرض المعاملات
   - Earned Points صحيح

### **5.2. Redeem Points**:
1. ✅ اضغط "Redeem"
2. ✅ أدخل عدد النقاط
3. ✅ **النتيجة المتوقعة**:
   - Points تقل
   - رسالة نجاح
   - History يُحدث

---

## 🔔 **الاختبار 6: Notifications**

### **6.1. Notifications Page**:
1. ✅ من Bottom Navigation → Notifications
2. ✅ **التحقق من**:
   - عرض جميع الإشعارات
   - Unread/Read status
   - التاريخ والوقت

### **6.2. Mark as Read**:
1. ✅ اضغط على إشعار
2. ✅ **النتيجة المتوقعة**:
   - الإشعار يصبح "Read"
   - Counter في Home يقل

### **6.3. Delete Notification**:
1. ✅ اضغط Delete على إشعار
2. ✅ **النتيجة المتوقعة**:
   - الإشعار يُحذف
   - القائمة تُحدث

---

## 👤 **الاختبار 7: Profile**

### **7.1. Profile Page**:
1. ✅ من Bottom Navigation → Profile
2. ✅ **التحقق من**:
   - User name يظهر
   - Phone number يظهر
   - Personal Data
   - Settings options

### **7.2. Personal Data**:
1. ✅ افتح Personal Data
2. ✅ **التحقق من**:
   - جميع البيانات تظهر
   - Civil ID images (إذا كانت محفوظة)

---

## 🐛 **استكشاف الأخطاء**

### **مشكلة: Backend لا يعمل**

```bash
# تحقق من Docker
docker compose ps

# أعد التشغيل
docker compose restart backend

# شاهد السجلات
docker compose logs backend

# تحقق من Database connection
docker compose exec backend npm run start:dev
```

### **مشكلة: Flutter لا يتصل بالBackend**

1. ✅ **تحقق من IP Address**:
   ```dart
   // Android Emulator: http://10.0.2.2:3000
   // iOS Simulator: http://localhost:3000
   // Physical Device: http://YOUR_IP:3000
   ```

2. ✅ **تحقق من CORS**:
   - Backend يجب أن يكون `app.enableCors()` في `main.ts`

3. ✅ **تحقق من Network**:
   ```bash
   # Test Backend
   curl http://localhost:3000/api/v1/home/public
   ```

### **مشكلة: OTP لا يصل**

- ✅ حالياً OTP يُطبع في Backend console
- ✅ افتح `backend` terminal
- ✅ ابحث عن: `🔐 OTP Code: XXXXXX`

### **مشكلة: Database فارغة**

```bash
# شغل Seed Script
cd backend
npm run seed

# أو
docker compose exec backend npm run seed
```

### **مشكلة: Images لا تظهر**

1. ✅ تحقق من URL صحيح
2. ✅ تحقق من Network connectivity
3. ✅ تحقق من CORS في Backend
4. ✅ شاهد Network tab في DevTools

---

## ✅ **Checklist الاختبار النهائي**

### **Authentication** ✅
- [ ] Phone input
- [ ] OTP verification
- [ ] Civil ID capture
- [ ] Profile completion
- [ ] Auto login

### **Home Page** ✅
- [ ] Top Stores
- [ ] Offers
- [ ] Featured Stores
- [ ] Pending Payments
- [ ] Notifications counter
- [ ] Categories
- [ ] Banners
- [ ] Navigation

### **Stores** ✅
- [ ] All Stores page
- [ ] Category Browse (Stores tab)
- [ ] Category Browse (Products tab)
- [ ] Store Details
- [ ] Products Grid in Store Details
- [ ] Search & Filter
- [ ] Network images

### **Products** ✅
- [ ] Product Details page
- [ ] Images PageView
- [ ] Product info
- [ ] Store info in Product Details
- [ ] Navigation

### **Payments** ✅
- [ ] Payments list
- [ ] Free Postpone badge
- [ ] Free Postpone action
- [ ] Once per month restriction
- [ ] Extend Due Date
- [ ] Payment History

### **Rewards** ✅
- [ ] Current Points
- [ ] Points History
- [ ] Redeem Points

### **Notifications** ✅
- [ ] Notifications list
- [ ] Mark as Read
- [ ] Delete Notification
- [ ] Counter in Home

### **Profile** ✅
- [ ] Profile info
- [ ] Personal Data
- [ ] Settings

---

## 📊 **اختبار الأداء**

### **Network Requests**:
- ✅ استخدام DevTools → Network tab
- ✅ تحقق من Request time < 2 seconds
- ✅ تحقق من Response size معقول

### **UI Performance**:
- ✅ No lag عند Scroll
- ✅ Images load smoothly
- ✅ Loading states تظهر

### **Error Handling**:
- ✅ Network errors تظهر رسالة
- ✅ Empty states تظهر
- ✅ Retry buttons تعمل

---

## 🎯 **الخلاصة**

بعد إتمام جميع الاختبارات أعلاه، يجب أن يكون:
- ✅ Authentication flow يعمل بالكامل
- ✅ جميع الصفحات مربوطة مع Backend
- ✅ البيانات تظهر بشكل صحيح
- ✅ Navigation يعمل
- ✅ Network images تظهر
- ✅ Error handling يعمل

**المشروع جاهز للاختبار! 🚀**

