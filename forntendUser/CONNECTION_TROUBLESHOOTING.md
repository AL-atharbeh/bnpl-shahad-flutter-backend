# 🔧 حل مشاكل الاتصال بالـ Backend

## المشكلة: TimeoutException عند الاتصال بالـ Backend

### الأعراض:
```
API Error in POST /auth/check-phone: TimeoutException after 0:00:30.000000: Future not completed
```

---

## ✅ الحلول

### 1️⃣ **إذا كنت تستخدم Android Emulator**

**الإعدادات الحالية:**
```dart
// lib/config/env/env_dev.dart
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

**التحقق:**
- ✅ تأكد من أن Backend يعمل: `docker compose ps`
- ✅ تأكد من أن Backend يستمع على المنفذ 3000
- ✅ جرب إعادة تشغيل المحاكي

---

### 2️⃣ **إذا كنت تستخدم iOS Simulator**

**غير الإعدادات إلى:**
```dart
// lib/config/env/env_dev.dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

**ثم:**
1. Hot Restart في Flutter
2. جرب مرة أخرى

---

### 3️⃣ **إذا كنت تستخدم جهاز فعلي (Physical Device)**

**الخطوات:**

1. **ابحث عن IP جهازك:**
   ```bash
   # Mac/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # Windows
   ipconfig
   # ابحث عن IPv4 Address
   ```

2. **غير الإعدادات:**
   ```dart
   // lib/config/env/env_dev.dart
   // استبدل YOUR_IP بـ IP جهازك
   static const String baseUrl = 'http://YOUR_IP:3000/api/v1';
   // مثال: static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
   ```

3. **تأكد من:**
   - ✅ الجهاز والكمبيوتر على نفس الشبكة (WiFi)
   - ✅ Firewall لا يحجب المنفذ 3000
   - ✅ Backend يعمل على `0.0.0.0:3000` (افتراضي في Docker)

4. **Hot Restart في Flutter**

---

## 🔍 خطوات التشخيص

### 1. تحقق من Backend:
```bash
cd backend
docker compose ps
# يجب أن ترى bnpl-backend في حالة "Up"
```

### 2. اختبر Backend مباشرة:
```bash
curl http://localhost:3000/api/v1/auth/check-phone \
  -H "Content-Type: application/json" \
  -d '{"phone":"+962799999999"}'
```

إذا نجح، Backend يعمل بشكل صحيح.

### 3. تحقق من Logs:
```bash
cd backend
docker compose logs app --tail 50
```

### 4. تحقق من Flutter Logs:
- افتح Flutter Console
- ابحث عن رسائل `🌐 POST Request:` و `📦 Data:`
- تحقق من رسائل الخطأ

---

## 🛠️ حلول إضافية

### إعادة تشغيل Backend:
```bash
cd backend
docker compose restart app
```

### إعادة تشغيل Docker:
```bash
cd backend
docker compose down
docker compose up -d
```

### إعادة تشغيل Flutter:
- Hot Restart: اضغط `R` في Terminal
- أو Full Restart: أعد تشغيل التطبيق

---

## 📱 اختبار الاتصال من Flutter

أضف هذا الكود في أي صفحة لاختبار الاتصال:

```dart
import '../services/api_service.dart';
import '../services/api_endpoints.dart';

void testConnection() async {
  final apiService = ApiService();
  
  try {
    final response = await apiService.post(ApiEndpoints.checkPhone, {
      'phone': '+962799999999',
    });
    
    print('✅ Connection test: ${response['success']}');
    if (response['success']) {
      print('✅ Connected successfully!');
    } else {
      print('❌ Connection failed: ${response['error']}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## 💡 نصائح

1. **استخدم Logging:**
   - تأكد من أن `enableLogging = true` في `env_dev.dart`
   - راقب Flutter Console للطلبات والاستجابات

2. **اختبر على localhost أولاً:**
   - إذا كان Backend يعمل على localhost، جرب iOS Simulator أولاً
   - ثم انتقل إلى Android Emulator أو الجهاز الفعلي

3. **تحقق من Firewall:**
   - تأكد من أن Firewall لا يحجب المنفذ 3000
   - على Mac: System Preferences → Security & Privacy → Firewall

4. **استخدم IP ثابت:**
   - إذا كنت تستخدم جهاز فعلي، استخدم IP ثابت للكمبيوتر
   - أو استخدم أدوات مثل `ngrok` للـ tunneling

---

## 🆘 إذا استمرت المشكلة

1. تحقق من أن Backend يعمل: `docker compose ps`
2. تحقق من Logs: `docker compose logs app`
3. جرب الاتصال من المتصفح: `http://localhost:3000/api/v1`
4. تحقق من إعدادات الشبكة
5. جرب إعادة تشغيل كل شيء

---

## 📞 معلومات مفيدة

- **Backend URL**: `http://localhost:3000`
- **API Prefix**: `/api/v1`
- **Full URL**: `http://localhost:3000/api/v1`
- **Android Emulator**: `http://10.0.2.2:3000/api/v1`
- **iOS Simulator**: `http://localhost:3000/api/v1`
- **Physical Device**: `http://YOUR_IP:3000/api/v1`

