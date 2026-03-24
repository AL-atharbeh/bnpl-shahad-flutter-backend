# دليل تشغيل الباك اند باستخدام Docker

## 🐳 المتطلبات

- Docker Desktop مثبت ويعمل
- Docker Compose (يأتي مع Docker Desktop)

---

## 🚀 التشغيل السريع

### 1. تشغيل جميع الخدمات (MySQL + Backend + phpMyAdmin)

```bash
cd backend
docker-compose up -d
```

**الخدمات المتاحة**:
- **Backend API**: `http://localhost:3000`
- **Swagger Docs**: `http://localhost:3000/api/docs`
- **phpMyAdmin**: `http://localhost:8080`
- **MySQL**: `localhost:3306` 

### 2. عرض السجلات (Logs)

```bash
# جميع السجلات
docker-compose logs -f

# سجلات Backend فقط
docker-compose logs -f app

# سجلات MySQL فقط
docker-compose logs -f mysql
```

### 3. إيقاف الخدمات

```bash
docker-compose down
```

### 4. إيقاف وحذف البيانات

```bash
docker-compose down -v
```

---

## 📊 إدارة قاعدة البيانات

### الوصول إلى phpMyAdmin

1. افتح: `http://localhost:8080`
2. **Username**: `bnpl_user`
3. **Password**: `bnpl_password`
4. **Server**: `mysql`

### الوصول المباشر إلى MySQL

```bash
# من داخل الـ container
docker exec -it bnpl-mysql mysql -u bnpl_user -pbnpl_password bnpl_db

# أو من خارج الـ container
mysql -h localhost -P 3306 -u bnpl_user -pbnpl_password bnpl_db
```

### تشغيل Seed Script (إضافة بيانات تجريبية)

```bash
# تشغيل الـ seed script داخل الـ container
docker exec -it bnpl-backend npm run seed
```

---

## 🔧 إعدادات Docker

### معلومات الاتصال

**MySQL**:
- Host: `mysql` (داخل Docker network) أو `localhost` (من خارج Docker)
- Port: `3306`
- Database: `bnpl_db`
- Username: `bnpl_user`
- Password: `bnpl_password`
- Root Password: `root_password`

**Backend**:
- Port: `3000`
- API Prefix: `/api/v1`
- Environment: `development`

---

## 🔗 ربط Flutter بالباك اند

### للـ Android Emulator

```dart
// forntendUser/lib/config/env/env_dev.dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

**ملاحظة**: `10.0.2.2` هو IP الخاص الذي يستخدمه Android Emulator للوصول إلى `localhost` على الكمبيوتر المضيف.

### للـ iOS Simulator

```dart
static const String baseUrl = 'http://localhost:3000';
```

### للجهاز الحقيقي (Android/iOS)

```dart
// استبدل YOUR_COMPUTER_IP بـ IP الكمبيوتر
static const String baseUrl = 'http://192.168.1.100:3000';
```

**كيفية معرفة IP الكمبيوتر**:

**macOS/Linux**:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Windows**:
```bash
ipconfig
```

ابحث عن `IPv4 Address` في قسم `Wireless LAN adapter` أو `Ethernet adapter`.

---

## ✅ التحقق من الربط

### 1. التحقق من Backend

```bash
# فتح المتصفح
open http://localhost:3000

# يجب أن ترى:
{
  "message": "Welcome to BNPL API",
  "version": "1.0",
  "documentation": "/api/docs",
  "apiPrefix": "/api/v1"
}
```

### 2. التحقق من Swagger

```bash
open http://localhost:3000/api/docs
```

### 3. التحقق من قاعدة البيانات

```bash
# من داخل الـ container
docker exec -it bnpl-mysql mysql -u bnpl_user -pbnpl_password -e "SHOW DATABASES;"

# يجب أن ترى:
# +--------------------+
# | Database           |
# +--------------------+
# | information_schema |
# | bnpl_db            |
# +--------------------+
```

### 4. التحقق من الجداول

```bash
docker exec -it bnpl-mysql mysql -u bnpl_user -pbnpl_password bnpl_db -e "SHOW TABLES;"
```

### 5. اختبار API من Flutter

```dart
import 'package:bnpl/services/api_service.dart';

final apiService = ApiService();

// اختبار الاتصال
final response = await apiService.get('/');
print('Response: $response');
```

---

## 🐛 حل المشاكل

### المشكلة 1: Port 3000 مستخدم بالفعل

**الحل**:
```bash
# تغيير Port في docker-compose.yml
ports:
  - '3001:3000'  # استخدم 3001 بدلاً من 3000

# ثم حدث Flutter
static const String baseUrl = 'http://10.0.2.2:3001';
```

### المشكلة 2: MySQL لا يبدأ

**الحل**:
```bash
# تحقق من السجلات
docker-compose logs mysql

# أعد تشغيل الـ container
docker-compose restart mysql

# أو احذف وأعد الإنشاء
docker-compose down -v
docker-compose up -d
```

### المشكلة 3: Backend لا يتصل بقاعدة البيانات

**الحل**:
```bash
# تحقق من أن MySQL يعمل
docker-compose ps

# تحقق من السجلات
docker-compose logs app

# تأكد من أن DB_HOST=mysql في docker-compose.yml
```

### المشكلة 4: Flutter لا يتصل بالباك اند

**الحل**:
1. تأكد من أن Backend يعمل: `http://localhost:3000`
2. للـ Android Emulator: استخدم `10.0.2.2:3000`
3. للـ iOS Simulator: استخدم `localhost:3000`
4. للجهاز الحقيقي: استخدم IP الكمبيوتر
5. تأكد من أن CORS مفعّل في Backend (مفعّل بالفعل)

### المشكلة 5: CORS Error

**الحل**: CORS مفعّل بالفعل في `backend/src/main.ts`:
```typescript
app.enableCors({
  origin: '*',
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
  credentials: true,
});
```

---

## 📝 أوامر مفيدة

### إعادة بناء الـ Images

```bash
docker-compose build --no-cache
docker-compose up -d
```

### إعادة تشغيل خدمة معينة

```bash
# إعادة تشغيل Backend فقط
docker-compose restart app

# إعادة تشغيل MySQL فقط
docker-compose restart mysql
```

### عرض حالة الخدمات

```bash
docker-compose ps
```

### الدخول إلى الـ Container

```bash
# Backend container
docker exec -it bnpl-backend sh

# MySQL container
docker exec -it bnpl-mysql bash
```

### حذف كل شيء والبدء من جديد

```bash
# إيقاف وحذف الـ containers والـ volumes
docker-compose down -v

# حذف الـ images
docker-compose rm -f

# إعادة البناء والتشغيل
docker-compose build --no-cache
docker-compose up -d
```

---

## 🔄 سير العمل الموصى به

### 1. أول مرة

```bash
cd backend
docker-compose up -d
docker-compose logs -f app  # انتظر حتى يبدأ Backend
```

### 2. إضافة بيانات تجريبية

```bash
docker exec -it bnpl-backend npm run seed
```

### 3. تطوير Flutter

```bash
cd forntendUser
flutter run
```

### 4. عند التغيير في Backend

```bash
# Backend يعمل في watch mode، سيتم إعادة التشغيل تلقائياً
# لكن إذا احتجت إعادة بناء:
docker-compose restart app
```

---

## 📊 مراقبة الأداء

### استخدام Docker Stats

```bash
docker stats
```

### عرض استخدام الموارد

```bash
docker-compose top
```

---

## 🔐 الأمان

**ملاحظة مهمة**: الإعدادات الحالية للـ development فقط!

**للإنتاج**:
1. غيّر جميع كلمات المرور
2. استخدم `.env` file بدلاً من hardcode
3. عطّل `synchronize: true` في TypeORM
4. استخدم HTTPS
5. قيّد CORS origins

---

## ✅ Checklist

- [ ] Docker Desktop يعمل
- [ ] `docker-compose up -d` تم بنجاح
- [ ] Backend يعمل على `http://localhost:3000`
- [ ] Swagger يعمل على `http://localhost:3000/api/docs`
- [ ] phpMyAdmin يعمل على `http://localhost:8080`
- [ ] قاعدة البيانات متصلة
- [ ] Flutter `baseUrl` محدث بشكل صحيح
- [ ] اختبار API من Flutter نجح

---

**آخر تحديث**: $(date)

