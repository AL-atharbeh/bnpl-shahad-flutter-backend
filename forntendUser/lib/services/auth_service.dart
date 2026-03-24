import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'api_endpoints.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userTokenKey = 'user_token';
  static const String _userIdKey = 'user_id';

  // ==================== OLD METHODS (DEPRECATED) ====================
  // هذه الوظائف قديمة ولا تطابق Backend API الحالي
  // استخدم checkIfUserExists, sendOTPToPhone, verifyOTPCode, createAccountWithProfile بدلاً منها

  // Register new user (DEPRECATED - use createAccountWithProfile instead)
  // Future<Map<String, dynamic>> register({...}) async {...}

  // Login user (DEPRECATED - use verifyOTPCode instead)
  // Future<Map<String, dynamic>> login({...}) async {...}

  // Send OTP (DEPRECATED - use sendOTPToPhone instead)
  // Future<Map<String, dynamic>> sendOtp({...}) async {...}

  // Verify OTP (DEPRECATED - use verifyOTPCode instead)
  // Future<Map<String, dynamic>> verifyOtp({...}) async {...}

  // Forgot password (NOT IMPLEMENTED IN BACKEND)
  // Future<Map<String, dynamic>> forgotPassword({...}) async {...}

  // Reset password (NOT IMPLEMENTED IN BACKEND)
  // Future<Map<String, dynamic>> resetPassword({...}) async {...}

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    return await _apiService.get(ApiEndpoints.getProfile);
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (avatar != null) data['avatarUrl'] = avatar; // Backend يتوقع avatarUrl

    return await _apiService.put(ApiEndpoints.updateProfile, data);
  }

  // Logout user (NOT IMPLEMENTED IN BACKEND - just clear local state)
  Future<void> logout() async {
    // Clear auth token on logout
    _apiService.clearAuthToken();
    
    // Clear saved login state
    await clearLoginState();
  }

  // Check if user exists by phone number (for new auth flow)
  Future<Map<String, dynamic>> checkIfUserExists(String phoneNumber) async {
    try {
      print('📞 Checking if user exists: $phoneNumber');
      final response = await _apiService.post(ApiEndpoints.checkPhone, {
        'phone': phoneNumber,
      });
      
      print('📞 Response: $response');
      
      if (response['success']) {
        final data = response['data'];
        return {
          'success': true,
          'exists': data['exists'] ?? false,
          'data': data,
        };
      }
      
      return {
        'success': false,
        'exists': false,
        'error': response['error'] ?? 'فشل التحقق من رقم الهاتف',
      };
    } catch (e) {
      print('❌ Error checking user existence: $e');
      String errorMsg = 'فشل التحقق من رقم الهاتف';
      if (e.toString().contains('TimeoutException')) {
        errorMsg = 'انتهت مهلة الاتصال. تأكد من أن Backend يعمل';
      } else if (e.toString().contains('SocketException')) {
        errorMsg = 'لا يمكن الاتصال بالخادم';
      }
      return {
        'success': false,
        'exists': false,
        'error': errorMsg,
      };
    }
  }

  // Send OTP to phone number (for new auth flow)
  Future<Map<String, dynamic>> sendOTPToPhone(String phoneNumber) async {
    try {
      final response = await _apiService.post(ApiEndpoints.sendOtp, {
        'phone': phoneNumber,
      });
      
      if (response['success']) {
        return {
          'success': true,
          'message': response['data']['message'] ?? 'تم إرسال رمز التحقق',
          'data': response['data'],
        };
      }
      
      return {
        'success': false,
        'error': response['error'] ?? 'فشل إرسال رمز التحقق',
      };
    } catch (e) {
      print('❌ Error sending OTP: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Verify OTP code (for new auth flow)
  Future<Map<String, dynamic>> verifyOTPCode(String phoneNumber, String otp) async {
    try {
      final response = await _apiService.post(ApiEndpoints.verifyOtp, {
        'phone': phoneNumber,
        'code': otp,
      });
      
      if (response['success']) {
        // Backend يعيد: { success: true, message: "...", data: { userExists: true/false, token: "...", user: {...} } }
        // api_service يضع الكل في response['data']
        final backendResponse = response['data'];
        final innerData = backendResponse?['data'] ?? backendResponse; // البيانات الداخلية
        
        // إذا كان المستخدم موجود وله token، احفظه
        if (innerData['userExists'] == true && innerData['token'] != null) {
          final token = innerData['token'].toString();
          final userId = innerData['user']?['id']?.toString() ?? '';
          
          _apiService.setAuthToken(token);
          await saveLoginState(token, userId);
        }
        
        return {
          'success': true,
          'userExists': innerData['userExists'] ?? false,
          'token': innerData['token'],
          'user': innerData['user'],
          'requiresProfileCompletion': innerData['requiresProfileCompletion'] ?? false,
          'data': innerData,
        };
      }
      
      return {
        'success': false,
        'error': response['error'] ?? 'رمز التحقق غير صحيح',
      };
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Create new account with full profile (for new auth flow)
  Future<Map<String, dynamic>> createAccountWithProfile({
    required String phoneNumber,
    required String fullName,
    required String civilId,
    required String frontIdPath,
    required String backIdPath,
    required String dateOfBirth,
    required String address,
    required String monthlyIncome,
    required String employer,
    String? email,
  }) async {
    try {
      // قراءة الصور وتحويلها إلى base64
      String? frontIdBase64;
      String? backIdBase64;
      
      try {
        // إذا كانت المسارات base64 بالفعل، استخدمها مباشرة
        if (frontIdPath.startsWith('data:')) {
          frontIdBase64 = frontIdPath;
        } else if (frontIdPath.isNotEmpty) {
          // قراءة من ملف محلي
          final frontFile = File(frontIdPath);
          if (await frontFile.exists()) {
            final frontBytes = await frontFile.readAsBytes();
            frontIdBase64 = base64Encode(frontBytes);
            frontIdBase64 = 'data:image/jpeg;base64,$frontIdBase64';
          }
        }
        
        if (backIdPath.startsWith('data:')) {
          backIdBase64 = backIdPath;
        } else if (backIdPath.isNotEmpty) {
          // قراءة من ملف محلي
          final backFile = File(backIdPath);
          if (await backFile.exists()) {
            final backBytes = await backFile.readAsBytes();
            backIdBase64 = base64Encode(backBytes);
            backIdBase64 = 'data:image/jpeg;base64,$backIdBase64';
          }
        }
      } catch (e) {
        print('⚠️ Warning: Could not read images: $e');
        // إذا فشل، استخدم المسارات كما هي (قد تكون base64 بالفعل)
        frontIdBase64 = frontIdPath;
        backIdBase64 = backIdPath;
      }
      
      final response = await _apiService.post(ApiEndpoints.createAccount, {
        'phone': phoneNumber,
        'fullName': fullName,
        'civilIdNumber': civilId,
        'civilIdFront': frontIdBase64 ?? frontIdPath,
        'civilIdBack': backIdBase64 ?? backIdPath,
        'dateOfBirth': dateOfBirth,
        'address': address,
        'monthlyIncome': double.tryParse(monthlyIncome) ?? 0.0,
        'employer': employer,
        if (email != null && email.isNotEmpty) 'email': email,
      });
      
      if (response['success']) {
        // Backend يعيد: { success: true, message: "...", data: { token: "...", user: {...} } }
        // api_service يضع الكل في response['data']
        final backendResponse = response['data'];
        final innerData = backendResponse?['data']; // البيانات الداخلية (token و user)
        
        final token = innerData?['token'];
        final user = innerData?['user'];
        final userId = user?['id']?.toString() ?? '';
        
        print('🔑 Token from response: ${token != null ? "exists" : "null"}');
        print('👤 User from response: ${user != null ? "exists" : "null"}');
        
        // التحقق من وجود token
        if (token == null || token.toString().isEmpty) {
          print('❌ Token is null or empty');
          print('📦 Full response: $response');
          return {
            'success': false,
            'error': 'فشل إنشاء الحساب: لم يتم استلام token',
          };
        }
        
        // حفظ token وتسجيل الدخول
        _apiService.setAuthToken(token.toString());
        await saveLoginState(token.toString(), userId);
        
        return {
          'success': true,
          'message': backendResponse?['message'] ?? 'تم إنشاء الحساب بنجاح',
          'token': token.toString(),
          'user': user,
          'data': innerData,
        };
      }
      
      // معالجة الأخطاء
      String errorMessage = response['error'] ?? 'فشل إنشاء الحساب';
      
      // إذا كان الخطأ 409 (Conflict) - رقم الهاتف مستخدم
      if (response['statusCode'] == 409) {
        errorMessage = 'رقم الهاتف مستخدم بالفعل. يرجى تسجيل الدخول بدلاً من إنشاء حساب جديد';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': response['statusCode'],
      };
    } catch (e) {
      print('❌ Error creating account: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Save login state to SharedPreferences
  Future<void> saveLoginState(String token, [String? userId]) async {
    print('💾 Saving login state...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userTokenKey, token);
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
    print('✅ Login state saved successfully');
  }

  // Clear login state from SharedPreferences
  Future<void> clearLoginState() async {
    print('🗑️ Clearing login state...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userTokenKey);
    await prefs.remove(_userIdKey);
    print('✅ Login state cleared successfully');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool(_isLoggedInKey) ?? false;
    print('🔍 Checking isLoggedIn: $result');
    return result;
  }

  // Get saved user token
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_userTokenKey);
    print('🔑 Getting saved token: ${token != null ? "exists" : "null"}');
    return token;
  }

  // Get saved user ID
  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Set auth token in API service
  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }

  // Auto login with saved credentials
  Future<bool> autoLogin() async {
    print('🔍 Checking auto login...');
    
    final isLoggedIn = await this.isLoggedIn();
    print('📱 Is logged in: $isLoggedIn');
    
    if (!isLoggedIn) {
      print('❌ User not logged in');
      return false;
    }

    final token = await getSavedToken();
    print('🔑 Token exists: ${token != null}');
    
    if (token == null) {
      print('❌ No token found');
      return false;
    }

    // Set the token in API service
    _apiService.setAuthToken(token);
    
    print('✅ Auto login successful');
    return true;
  }
}
