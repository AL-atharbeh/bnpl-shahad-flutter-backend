# ⚡ اختبار سريع - Quick Test

## 🚀 البدء في 3 دقائق

### 1️⃣ تشغيل Backend
```bash
cd backend
docker compose up -d
```

### 2️⃣ Seed Database
```bash
docker compose exec backend npm run seed
```

### 3️⃣ تشغيل Flutter
```bash
cd forntendUser
flutter run
```

---

## ✅ Checklist سريع

### Authentication
- [ ] Phone: `799999999`
- [ ] OTP: من Backend console
- [ ] Verify → Home

### Home Page
- [ ] Stores تظهر
- [ ] Payments تظهر
- [ ] Navigation يعمل

### Stores
- [ ] All Stores → Grid يظهر
- [ ] Store Details → Products Grid
- [ ] Product Details → Data يظهر

### Payments
- [ ] List يظهر
- [ ] Free Postpone button موجود

---

## 🔍 Backend URL
- Android Emulator: `http://10.0.2.2:3000`
- iOS Simulator: `http://localhost:3000`
- Physical Device: `http://YOUR_IP:3000`

---

📖 **للدليل الكامل**: راجع `TESTING_GUIDE.md`
