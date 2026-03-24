# 🌱 Database Seed Data Guide

## 📋 Overview

Seed script لإضافة بيانات تجريبية للـ Database لتسهيل الاختبار والتطوير.

---

## 🚀 **كيفية التشغيل**

### الطريقة 1: استخدام npm script
```bash
cd backend
npm run seed
```

### الطريقة 2: مباشرة
```bash
cd backend
npx ts-node -r tsconfig-paths/register src/database/seed.ts
```

---

## 📦 **البيانات المضافة**

### 1️⃣ **Stores (15 متجر)** ✅
- **Zara** - Fashion (عرض 10%)
- **H&M** - Fashion (عرض 15%)
- **Nike** - Sports (عرض 20%)
- **Adidas** - Sports
- **Apple Store** - Electronics (عرض 5%)
- **Samsung** - Electronics (عرض 12%)
- **Amazon** - Shopping (عرض شحن مجاني)
- **IKEA** - Furniture
- **Virgin Megastore** - Books (عرض 25%)
- **Jarir Bookstore** - Books (عرض 15%)
- **Carrefour** - Groceries (عرض اشتري 2 احصل 1)
- **Nike Outlet** - Sports (عرض حتى 40%)
- **Sephora** - Beauty (عرض 20%)
- **Home Center** - Home & Garden
- **Toys R Us** - Toys (عرض 30%)

### 2️⃣ **Products (50-90 منتج)** ✅
- **Fashion Stores**: 6 منتجات لكل متجر (T-Shirts, Jeans, Shoes, etc.)
- **Sports Stores**: 5 منتجات لكل متجر (Running Shoes, Basketball, etc.)
- **Electronics Stores**: 5 منتجات لكل متجر (iPhone, Samsung Galaxy, etc.)
- **Books Stores**: 4 منتجات لكل متجر
- **Other Categories**: 2-3 منتجات لكل متجر

**إجمالي**: ~80 منتج

### 3️⃣ **Test User** ✅
- **Name**: Test User
- **Phone**: +962799999999
- **Email**: test@example.com
- **Password**: password123 (hashed)
- **Status**: Phone verified, Active

### 4️⃣ **Sample Payments (4 payments)** ✅
- **Payment 1**: 150 JOD - Zara - Pending (due in 3 days)
- **Payment 2**: 250 JOD - Nike - Pending (due in 7 days)
- **Payment 3**: 1200 JOD - Apple Store - Pending (due in 14 days)
- **Payment 4**: 89.99 JOD - H&M - Completed (paid 4 days ago)

### 5️⃣ **Sample Notifications (5 notifications)** ✅
- **Notification 1**: Payment Due Soon (unread)
- **Notification 2**: New Offer Available (unread)
- **Notification 3**: Payment Completed (read)
- **Notification 4**: Reward Points Earned (unread)
- **Notification 5**: Welcome to BNPL (read)

### 6️⃣ **Reward Points (2 transactions)** ✅
- **Transaction 1**: 89 points earned (from completed payment)
- **Transaction 2**: 150 points earned (from pending payment)

---

## 🔧 **Configuration**

### Environment Variables
الـ seed script يستخدم نفس إعدادات `.env`:
- `DB_HOST` (default: localhost)
- `DB_PORT` (default: 3306)
- `DB_USERNAME` (default: bnpl_user)
- `DB_PASSWORD` (default: bnpl_password)
- `DB_DATABASE` (default: bnpl_db)

---

## ⚠️ **ملاحظات مهمة**

### Data Clearing
- ✅ الـ script يحذف البيانات الموجودة قبل إضافة جديدة
- ⚠️ **Stores**: لا يتم حذفها (comment out if needed)
- ✅ **Products, Payments, Notifications, Rewards**: يتم حذفها

### Test User
- ✅ يتم إنشاء test user تلقائياً
- ✅ Phone: `+962799999999`
- ✅ يمكن استخدامه للاختبار والتسجيل الدخول

### Payments
- ✅ بعض Payments `pending` (لاختبار postpone feature)
- ✅ واحد `completed` (لاختبار history)
- ✅ Due dates متنوعة (3, 7, 14 days)

---

## 🧪 **الاختبار بعد Seed**

### 1. Test Login
```bash
# في Flutter أو Postman
Phone: +962799999999
OTP: (check Backend console - OTP service logs it)
```

### 2. Check Home Data
```
GET /api/v1/home
- يجب أن يعيد: 15 stores, offers, pending payments
```

### 3. Check Payments
```
GET /api/v1/payments/pending
- يجب أن يعيد: 3 pending payments
```

### 4. Check Notifications
```
GET /api/v1/notifications
- يجب أن يعيد: 5 notifications (3 unread)
```

### 5. Check Rewards
```
GET /api/v1/rewards/points
- يجب أن يعيد: 239 points (89 + 150)
```

---

## 🔄 **Re-seeding**

إذا أردت إعادة تشغيل الـ seed:
```bash
npm run seed
```

⚠️ **تحذير**: سيقوم بحذف البيانات الموجودة!

---

## 📊 **الخلاصة**

✅ **15 Stores**  
✅ **~80 Products**  
✅ **1 Test User**  
✅ **4 Sample Payments**  
✅ **5 Sample Notifications**  
✅ **2 Reward Point Transactions**  

**الحالة**: جاهز للاستخدام! 🚀
