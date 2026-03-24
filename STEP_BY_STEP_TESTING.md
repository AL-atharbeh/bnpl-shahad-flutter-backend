# 📱 دليل الاختبار الكامل - خطوة بخطوة

دليل مفصل لاختبار المشروع من البداية للنهاية.

---

## ✅ **الخطوة 1: التحقق من Backend (مهم جداً!)**

### 1.1. افتح Terminal وقم بالتالي:

```bash
cd /Users/ahmadal-atharbeh/project/bnpl/backend
```

### 1.2. تحقق من أن Docker يعمل:

```bash
docker compose ps
```

**النتيجة المتوقعة**:
```
NAME           STATUS
bnpl-backend   Up X seconds
bnpl-mysql     Up X seconds (healthy)
```

✅ **إذا كان Status = "Up"** → ممتاز! انتقل للخطوة التالية  
❌ **إذا كان Status = "Restarting" أو "Exited"** → شاهد الأخطاء:
```bash
docker compose logs app
```

---

### 1.3. تحقق من أن Backend يستجيب:

```bash
curl http://localhost:3000/api/v1/home/public
```

**النتيجة المتوقعة**: JSON response مع البيانات

✅ **إذا ظهر JSON** → Backend يعمل!  
❌ **إذا ظهر error** → تحقق من logs:
```bash
docker compose logs app --tail 50
```

---

### 1.4. تحقق من Database (Seed):

```bash
docker compose exec app npm run seed
```

**النتيجة المتوقعة**:
```
✅ Database seeding completed successfully!
📊 Summary:
   - Stores: 15
   - Products: 59
   - Test User: 1
   - Payments: 4
   - Notifications: 5
```

✅ **إذا ظهر هذا** → Database جاهز!  
❌ **إذا ظهر error** → أعد المحاولة أو شاهد logs

---

## 📱 **الخطوة 2: تشغيل Flutter App**

### 2.1. افتح Terminal جديد (أو tab جديد)

```bash
cd /Users/ahmadal-atharbeh/project/bnpl/forntendUser
```

### 2.2. تأكد من Dependencies مثبتة:

```bash
flutter pub get
```

✅ **انتظر حتى ينتهي**

---

### 2.3. اختر جهاز للاختبار:

#### **الخيار 1: Android Emulator** (الأسهل)
```bash
# تأكد من وجود Android Emulator مفتوح
# ثم شغل:
flutter run -d android
```

#### **الخيار 2: iOS Simulator**
```bash
# أولاً: غيّر Backend URL في env_dev.dart إلى:
# baseUrl = 'http://localhost:3000'

# ثم شغل:
flutter run -d ios
```

#### **الخيار 3: Web (أسرع للاختبار)**
```bash
# أولاً: غيّر Backend URL في env_dev.dart إلى:
# baseUrl = 'http://localhost:3000'

# ثم شغل:
flutter run -d chrome
```

#### **الخيار 4: Physical Device (أصعب)**
1. تأكد أن الجهاز على نفس الشبكة
2. اعرف IP جهازك:
   ```bash
   # macOS/Linux:
   ifconfig | grep "inet "
   
   # أو في Terminal:
   ipconfig getifaddr en0
   ```
3. غيّر في `env_dev.dart`:
   ```dart
   baseUrl = 'http://YOUR_IP:3000'  // مثال: http://192.168.1.100:3000
   ```
4. شغل:
   ```bash
   flutter run
   ```

---

### 2.4. انتظر حتى التطبيق يفتح

✅ **يجب أن ترى**: Splash Screen → Onboarding → Phone Input

---

## 🔐 **الخطوة 3: اختبار Authentication (تسجيل الدخول)**

### 3.1. Phone Input Page:

1. ✅ ستجد حقل "رقم الهاتف"
2. ✅ اكتب: `799999999` (9 أرقام فقط، بدون 962+)
3. ✅ اضغط "Continue" أو "متابعة"

**ماذا يحدث؟**
- Flutter يرسل request إلى Backend
- Backend يرسل OTP (مؤقتاً يطبع في console)

---

### 3.2. الحصول على OTP:

**افتح Terminal للـ Backend** (Terminal الأول):
```bash
cd /Users/ahmadal-atharbeh/project/bnpl/backend
docker compose logs -f app
```

**سترى شيء مثل**:
```
📱 Sending OTP to +962799999999
🔐 OTP Code: 123456
⏰ OTP expires in 5 minutes
```

**انسخ OTP** (مثال: `123456`)

---

### 3.3. OTP Verification Page:

1. ✅ في التطبيق، ستجد 6 خانات للـ OTP
2. ✅ أدخل OTP الذي نسخته (مثال: `123456`)
3. ✅ اضغط "Verify" أو "تحقق"

**النتائج المحتملة**:

#### **الحالة 1: المستخدم موجود** (Test User)
- ✅ سيتم تسجيل الدخول مباشرة
- ✅ ستنتقل إلى **Home Page**
- ✅ **تهانينا! تسجيل الدخول نجح**

#### **الحالة 2: مستخدم جديد**
- ✅ ستنتقل إلى **Civil ID Capture Page**
- ✅ اتبع الخطوات التالية

---

## 📸 **الخطوة 4: Civil ID Capture (مستخدم جديد فقط)**

### 4.1. Front Side:

1. ✅ اضغط "Take Photo" أو "التقط صورة"
2. ✅ اختر:
   - **Camera**: لالتقاط صورة جديدة
   - **Gallery**: لاختيار صورة موجودة
3. ✅ التقط/اختر صورة للجهة الأمامية
4. ✅ ستظهر Preview

### 4.2. Back Side:

1. ✅ اضغط "Take Photo" للجهة الخلفية
2. ✅ التقط/اختر صورة للجهة الخلفية
3. ✅ ستظهر Preview

### 4.3. Continue:

1. ✅ تأكد من وجود صورة للجهتين
2. ✅ اضغط "Continue" أو "متابعة"

---

## 📝 **الخطوة 5: Complete Profile (مستخدم جديد فقط)**

### 5.1. املأ البيانات:

1. **Full Name**: اكتب اسمك (مثال: `أحمد العثري`)
2. **Civil ID Number**: رقم الهوية (مثال: `1234567890`)
3. **Date of Birth**: اضغط على التاريخ واختر تاريخ
4. **Address**: العنوان (مثال: `عمان، الأردن`)
5. **Monthly Income**: الدخل الشهري (مثال: `1500`)
6. **Employer**: جهة العمل (مثال: `شركة ABC`)

### 5.2. Submit:

1. ✅ تحقق من صحة جميع البيانات
2. ✅ اضغط "Create Account" أو "إنشاء الحساب"

**النتيجة المتوقعة**:
- ✅ رسالة نجاح
- ✅ الانتقال إلى **Home Page**

---

## 🏠 **الخطوة 6: اختبار Home Page**

### 6.1. تحقق من العناصر:

1. ✅ **Top Stores**: يجب أن ترى قائمة متاجر
2. ✅ **Offers**: متاجر مع عروض
3. ✅ **Featured Stores**: متاجر مميزة
4. ✅ **Pending Payments**: عدد الدفعات المستحقة
5. ✅ **Notifications Badge**: عدد الإشعارات غير المقروءة
6. ✅ **Categories**: الفئات (الإلكترونيات، الملابس، إلخ)
7. ✅ **Banners**: بانرات في الأعلى

### 6.2. Navigation Tests:

#### **اختبار 1: افتح Store**
1. ✅ اضغط على أي متجر
2. ✅ **النتيجة**: الانتقال إلى Store Details Page
3. ✅ اضغط Back للرجوع

#### **اختبار 2: افتح Category**
1. ✅ اضغط على أي فئة (مثل "الإلكترونيات")
2. ✅ **النتيجة**: الانتقال إلى Category Browse Page
3. ✅ جرب Tabs: Stores و Products
4. ✅ اضغط Back

#### **اختبار 3: افتح Payment**
1. ✅ اضغط على Pending Payment
2. ✅ **النتيجة**: الانتقال إلى Payments Page

---

## 🏪 **الخطوة 7: اختبار Stores Pages**

### 7.1. All Stores Page:

1. ✅ من Home → اضغط "All Stores" (أو أي مكان يؤدي للمتاجر)
2. ✅ **التحقق**:
   - Grid يظهر مع 15 متجر
   - الشعارات تظهر (Network images)
   - الأسماء تظهر

#### **Search Test**:
1. ✅ ابحث في Search Bar (مثال: "Zara")
2. ✅ **النتيجة**: عرض المتاجر المطابقة

#### **Filter Test**:
1. ✅ اختر فئة من الفلاتر (Fashion, Electronics, etc.)
2. ✅ **النتيجة**: عرض المتاجر في هذه الفئة

---

### 7.2. Store Details Page:

1. ✅ اضغط على أي متجر
2. ✅ **التحقق**:
   - Store banner يظهر
   - Store logo يظهر
   - Rating & Reviews
   - Description
   - Deal banner (إذا كان hasDeal = true)

#### **Products Section**:
1. ✅ Scroll للأسفل
2. ✅ **التحقق**:
   - Products Grid يظهر
   - Loading state (في البداية)
   - Products تظهر مع صور

3. ✅ اضغط على أي منتج
4. ✅ **النتيجة**: الانتقال إلى Product Details

---

### 7.3. Product Details Page:

1. ✅ **التحقق**:
   - Product images في PageView (يمكنك Scroll)
   - Product title (بالعربية/الإنجليزية)
   - Product description
   - Price يظهر (JD X.XX)
   - Store name & logo
   - Attributes table
   - Installment banner

2. ✅ اضغط Back للرجوع

---

## 💳 **الخطوة 8: اختبار Payments**

### 8.1. Payments Page:

1. ✅ من Bottom Navigation → اضغط "Payments" (أيقونة المال)
2. ✅ **التحقق**:
   - قائمة Payments تظهر
   - Pending Payments في الأعلى
   - Bill cards تظهر مع:
     - Store name
     - Amount
     - Due Date
     - Status

---

### 8.2. Free Postpone Feature:

#### **التحقق من Badge**:
1. ✅ ابحث عن Pending Payment
2. ✅ **التحقق**:
   - Badge "Free Postpone Available" يظهر (إذا متاح)
   - أو "Used this month" (إذا تم الاستخدام)

#### **Test Postpone**:
1. ✅ اضغط "Postpone for Free" أو "تأجيل مجاني"
2. ✅ ستظهر Bottom Sheet للتأكيد
3. ✅ اضغط "Confirm" أو "تأكيد"
4. ✅ **النتيجة المتوقعة**:
   - Due Date يزيد 10 أيام
   - Badge يختفي أو يتغير
   - رسالة نجاح

#### **Test Once Per Month**:
1. ✅ حاول استخدام Free Postpone مرة أخرى
2. ✅ **النتيجة المتوقعة**:
   - رسالة "Already used this month" أو
   - Badge يختفي

---

### 8.3. Extend Due Date (Paid Payment):

1. ✅ ابحث عن Completed Payment
2. ✅ اضغط "Extend Due Date"
3. ✅ اختر عدد الأيام
4. ✅ **النتيجة**: Due Date يتحدث

---

## 🎁 **الخطوة 9: اختبار Rewards**

### 9.1. Rewards Points:

1. ✅ من Profile → Rewards (إذا كان موجود)
2. ✅ **التحقق**:
   - Current Points تظهر
   - Points History يعرض المعاملات
   - Earned Points صحيح

### 9.2. Redeem Points:

1. ✅ اضغط "Redeem" أو "استبدال"
2. ✅ أدخل عدد النقاط
3. ✅ **النتيجة**:
   - Points تقل
   - رسالة نجاح
   - History يُحدث

---

## 🔔 **الخطوة 10: اختبار Notifications**

### 10.1. Notifications Page:

1. ✅ من Bottom Navigation → Notifications
2. ✅ **التحقق**:
   - قائمة الإشعارات تظهر
   - Unread/Read status
   - التاريخ والوقت

### 10.2. Mark as Read:

1. ✅ اضغط على إشعار غير مقروء
2. ✅ **النتيجة**:
   - الإشعار يصبح "Read"
   - Counter في Home يقل

### 10.3. Delete Notification:

1. ✅ اضغط Delete على إشعار
2. ✅ **النتيجة**:
   - الإشعار يُحذف
   - القائمة تُحدث

---

## 👤 **الخطوة 11: اختبار Profile**

### 11.1. Profile Page:

1. ✅ من Bottom Navigation → Profile
2. ✅ **التحقق**:
   - User name يظهر
   - Phone number يظهر
   - Personal Data
   - Settings options

### 11.2. Personal Data:

1. ✅ افتح Personal Data
2. ✅ **التحقق**:
   - جميع البيانات تظهر
   - Civil ID images (إذا كانت محفوظة)

---

## ✅ **Checklist النهائي**

### Authentication ✅
- [ ] Phone input
- [ ] OTP verification
- [ ] Civil ID capture (مستخدم جديد)
- [ ] Profile completion (مستخدم جديد)
- [ ] Auto login

### Home Page ✅
- [ ] Top Stores
- [ ] Offers
- [ ] Featured Stores
- [ ] Pending Payments
- [ ] Notifications counter
- [ ] Categories
- [ ] Banners
- [ ] Navigation

### Stores ✅
- [ ] All Stores page
- [ ] Category Browse (Stores tab)
- [ ] Category Browse (Products tab)
- [ ] Store Details
- [ ] Products Grid in Store Details
- [ ] Search & Filter
- [ ] Network images

### Products ✅
- [ ] Product Details page
- [ ] Images PageView
- [ ] Product info
- [ ] Store info in Product Details
- [ ] Navigation

### Payments ✅
- [ ] Payments list
- [ ] Free Postpone badge
- [ ] Free Postpone action
- [ ] Once per month restriction
- [ ] Extend Due Date
- [ ] Payment History

### Rewards ✅
- [ ] Current Points
- [ ] Points History
- [ ] Redeem Points

### Notifications ✅
- [ ] Notifications list
- [ ] Mark as Read
- [ ] Delete Notification
- [ ] Counter in Home

### Profile ✅
- [ ] Profile info
- [ ] Personal Data
- [ ] Settings

---

## 🐛 **مشاكل شائعة وحلولها**

### ❌ المشكلة: Backend لا يعمل

```bash
# حل 1: أعد التشغيل
cd backend
docker compose restart app

# حل 2: شاهد الأخطاء
docker compose logs app --tail 50

# حل 3: أعد البناء
docker compose down
docker compose build --no-cache app
docker compose up -d
```

---

### ❌ المشكلة: Flutter لا يتصل بالBackend

#### **للـ Android Emulator**:
- ✅ تأكد من `env_dev.dart`: `baseUrl = 'http://10.0.2.2:3000'`

#### **للـ iOS Simulator**:
- ✅ غيّر `env_dev.dart`: `baseUrl = 'http://localhost:3000'`

#### **للـ Physical Device**:
- ✅ استخدم IP جهازك (مثل `http://192.168.1.100:3000`)
- ✅ تأكد أن الجهاز والكمبيوتر على نفس الشبكة

---

### ❌ المشكلة: OTP لا يظهر

1. ✅ افتح Backend logs:
   ```bash
   cd backend
   docker compose logs -f app
   ```
2. ✅ أعد محاولة إرسال OTP
3. ✅ ابحث عن: `🔐 OTP Code: XXXXXX`

---

### ❌ المشكلة: Database فارغة

```bash
# شغل Seed Script
cd backend
docker compose exec app npm run seed
```

---

### ❌ المشكلة: Images لا تظهر

1. ✅ تحقق من Network connectivity
2. ✅ تحقق من Backend يعمل
3. ✅ افتح Browser: `http://localhost:3000/api/v1/stores`
4. ✅ تحقق من URLs صحيحة

---

## 🎉 **الخلاصة**

بعد إتمام جميع الخطوات أعلاه:

✅ **Authentication flow** يعمل بالكامل  
✅ **جميع الصفحات** مربوطة مع Backend  
✅ **البيانات** تظهر بشكل صحيح  
✅ **Navigation** يعمل  
✅ **Network images** تظهر  
✅ **Error handling** يعمل  

**المشروع جاهز للاختبار والاستخدام! 🚀**

---

## 📞 **المساعدة**

إذا واجهت أي مشكلة:
1. ✅ راجع قسم "مشاكل شائعة"
2. ✅ شاهد Backend logs: `docker compose logs app`
3. ✅ شاهد Flutter logs في Terminal
4. ✅ تحقق من Network requests في DevTools

**بالتوفيق! 🎯**

