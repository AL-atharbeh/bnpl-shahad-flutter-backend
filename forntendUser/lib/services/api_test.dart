import 'api_service.dart';
import 'api_endpoints.dart';

class ApiTest {
  static final ApiService _apiService = ApiService();

  /// اختبار الاتصال الأساسي
  static Future<bool> testConnection() async {
    try {
      final response = await _apiService.get('/stores');
      
      if (response['success']) {
        print('✅ Connected to Mock Server successfully!');
        print('📊 Found ${response['data']['data'].length} stores');
        return true;
      } else {
        print('❌ Connection failed: ${response['error']}');
        return false;
      }
    } catch (e) {
      print('❌ Connection error: $e');
      return false;
    }
  }

  /// اختبار تسجيل الدخول
  static Future<bool> testLogin() async {
    try {
      final response = await _apiService.post(ApiEndpoints.login, {
        'email': 'ahmed@example.com',
        'password': 'password123'
      });

      if (response['success']) {
        final userData = response['data']['data']['user'];
        final token = response['data']['data']['token'];
        
        print('✅ Login successful!');
        print('👤 User: ${userData['name']}');
        print('📧 Email: ${userData['email']}');
        print('🔑 Token: ${token.substring(0, 20)}...');
        
        // حفظ token للمصادقة
        _apiService.setAuthToken(token);
        
        return true;
      } else {
        print('❌ Login failed: ${response['error']}');
        return false;
      }
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    }
  }

  /// اختبار التسجيل
  static Future<bool> testRegister() async {
    try {
      final response = await _apiService.post(ApiEndpoints.register, {
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'password123',
        'phone': '+962791234567'
      });

      if (response['success']) {
        final userData = response['data']['data']['user'];
        final token = response['data']['data']['token'];
        
        print('✅ Registration successful!');
        print('👤 User: ${userData['name']}');
        print('📧 Email: ${userData['email']}');
        print('🔑 Token: ${token.substring(0, 20)}...');
        
        return true;
      } else {
        print('❌ Registration failed: ${response['error']}');
        return false;
      }
    } catch (e) {
      print('❌ Registration error: $e');
      return false;
    }
  }

  /// اختبار جلب المتاجر
  static Future<bool> testGetStores() async {
    try {
      final response = await _apiService.get(ApiEndpoints.stores);

      if (response['success']) {
        final stores = response['data']['data'] as List;
        
        print('✅ Stores fetched successfully!');
        print('🏪 Found ${stores.length} stores:');
        
        for (int i = 0; i < stores.length && i < 3; i++) {
          final store = stores[i];
          print('  ${i + 1}. ${store['name']} (Rating: ${store['rating']})');
        }
        
        return true;
      } else {
        print('❌ Failed to fetch stores: ${response['error']}');
        return false;
      }
    } catch (e) {
      print('❌ Get stores error: $e');
      return false;
    }
  }

  /// اختبار جلب المنتجات
  static Future<bool> testGetProducts() async {
    try {
      final response = await _apiService.get(ApiEndpoints.products);

      if (response['success']) {
        final products = response['data']['data'] as List;
        
        print('✅ Products fetched successfully!');
        print('🛍️ Found ${products.length} products:');
        
        for (int i = 0; i < products.length && i < 3; i++) {
          final product = products[i];
          print('  ${i + 1}. ${product['name']} (${product['price']} ${product['currency']})');
        }
        
        return true;
      } else {
        print('❌ Failed to fetch products: ${response['error']}');
        return false;
      }
    } catch (e) {
      print('❌ Get products error: $e');
      return false;
    }
  }

  /// اختبار إنشاء جلسة دفع
  static Future<bool> testCreatePaymentSession() async {
    try {
      final response = await _apiService.post(ApiEndpoints.createPaymentSession, {
        'storeId': 1,
        'orderId': 'test_order_${DateTime.now().millisecondsSinceEpoch}',
        'amount': 150.00,
        'currency': 'JOD',
        'items': [
          {
            'productId': 'test_product_123',
            'name': 'فستان أسود',
            'quantity': 1,
            'price': 150.00
          }
        ],
        'userCountry': 'JO',
        'userCurrency': 'JOD'
      });

      if (response['success']) {
        final sessionData = response['data']['data'];
        
        print('✅ Payment session created successfully!');
        print('🆔 Session ID: ${sessionData['sessionId']}');
        print('💰 Amount: ${sessionData['amount']} ${sessionData['currency']}');
        print('⏰ Expires: ${sessionData['expiresAt']}');
        
        return true;
      } else {
        print('❌ Failed to create payment session: ${response['error']}');
        return false;
      }
    } catch (e) {
      print('❌ Create payment session error: $e');
      return false;
    }
  }

  /// اختبار شامل لجميع الـ endpoints
  static Future<void> runAllTests() async {
    print('🚀 Starting API Tests...\n');

    // اختبار الاتصال
    print('1️⃣ Testing Connection...');
    final connectionTest = await testConnection();
    print('');

    if (!connectionTest) {
      print('❌ Connection test failed. Stopping other tests.');
      return;
    }

    // اختبار تسجيل الدخول
    print('2️⃣ Testing Login...');
    await testLogin();
    print('');

    // اختبار التسجيل
    print('3️⃣ Testing Registration...');
    await testRegister();
    print('');

    // اختبار جلب المتاجر
    print('4️⃣ Testing Get Stores...');
    await testGetStores();
    print('');

    // اختبار جلب المنتجات
    print('5️⃣ Testing Get Products...');
    await testGetProducts();
    print('');

    // اختبار إنشاء جلسة دفع
    print('6️⃣ Testing Create Payment Session...');
    await testCreatePaymentSession();
    print('');

    print('🎉 All API tests completed!');
  }

  /// اختبار سريع للاتصال
  static Future<void> quickTest() async {
    print('🔍 Quick API Test...');
    
    final connectionTest = await testConnection();
    if (connectionTest) {
      print('✅ Mock Server is running and accessible!');
    } else {
      print('❌ Mock Server is not accessible. Please check:');
      print('   1. Mock Server is running on port 3000');
      print('   2. Android Emulator is using 10.0.2.2');
      print('   3. Network connection is stable');
    }
  }
}
  