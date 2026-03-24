# ربط تطبيق Flutter مع Mock Server

## نظرة عامة

هذا الدليل يوضح كيفية ربط تطبيق Flutter مع الـ Mock Server.

## إعداد الـ Base URL

في تطبيق Flutter، قم بتعيين الـ base URL للـ API:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  // للاختبار على جهاز Android
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  
  // للاختبار على جهاز iOS
  // static const String baseUrl = 'http://127.0.0.1:3000/api/v1';
}
```

## إنشاء API Service

```dart
// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;
  
  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> _authHeaders(String token) => {
    ..._headers,
    'Authorization': 'Bearer $token',
  };
  
  // Authentication
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> register(String name, String email, String password, String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    
    return json.decode(response.body);
  }
  
  // Stores
  static Future<Map<String, dynamic>> getStores() async {
    final response = await http.get(
      Uri.parse('$baseUrl/stores'),
      headers: _headers,
    );
    
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> getStoreDetails(int storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stores/$storeId'),
      headers: _headers,
    );
    
    return json.decode(response.body);
  }
  
  // Products
  static Future<Map<String, dynamic>> getStoreProducts(int storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stores/$storeId/products'),
      headers: _headers,
    );
    
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> getProductDetails(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId'),
      headers: _headers,
    );
    
    return json.decode(response.body);
  }
  
  // Notifications
  static Future<Map<String, dynamic>> getNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: _authHeaders(token),
    );
    
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> markNotificationAsRead(int notificationId, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: _authHeaders(token),
    );
    
    return json.decode(response.body);
  }
}
```

## استخدام الـ API Service في الـ Pages

```dart
// lib/features/stores/presentation/pages/stores_page.dart
import '../../../services/api_service.dart';

class StoresPage extends StatefulWidget {
  @override
  _StoresPageState createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  List<Store> stores = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadStores();
  }
  
  Future<void> _loadStores() async {
    try {
      final response = await ApiService.getStores();
      if (response['success']) {
        setState(() {
          stores = (response['data'] as List)
              .map((json) => Store.fromJson(json))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stores: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return StoreCard(store: store);
      },
    );
  }
}
```

## إضافة Dependencies

أضف هذه الـ dependencies إلى `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

## اختبار الاتصال

1. تأكد من تشغيل الـ Mock Server:
   ```bash
   cd api/mock-server
   npm install
   npm run dev
   ```

2. تأكد من أن الـ base URL صحيح في `ApiConfig`

3. اختبر الاتصال في تطبيق Flutter

## استكشاف الأخطاء

### مشاكل الاتصال

1. **خطأ في الاتصال**: تأكد من تشغيل الـ Mock Server
2. **خطأ في الـ base URL**: تأكد من الـ IP address الصحيح
3. **خطأ CORS**: الـ Mock Server يدعم CORS تلقائياً

### مشاكل البيانات

1. **بيانات فارغة**: تحقق من ملف `db.json`
2. **خطأ في الـ JSON**: تحقق من صحة تنسيق البيانات

## الانتقال إلى Production

عند الانتقال إلى production، قم بتغيير الـ base URL إلى الـ server الحقيقي:

```dart
class ApiConfig {
  static const String baseUrl = 'https://api.bnpl.com/api/v1';
}
```
