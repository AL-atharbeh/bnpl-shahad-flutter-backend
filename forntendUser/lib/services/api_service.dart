import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env/env_dev.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl = EnvDev.baseUrl;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(_headers);
    
    // Always try to load the latest token from SharedPreferences
    // This ensures we use the most up-to-date token, even if it was updated elsewhere
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      
      if (EnvDev.enableLogging) {
        print('🔑 Loading token from SharedPreferences...');
        print('   Token exists: ${token != null}');
        if (token != null) {
          print('   Token length: ${token.length}');
          print('   Token preview: ${token.length > 20 ? token.substring(0, 20) + "..." : token}');
        }
      }
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        // Also update _headers to cache it
        _headers['Authorization'] = 'Bearer $token';
        if (EnvDev.enableLogging) {
          print('✅ Token loaded and added to headers');
        }
      } else {
        // Remove Authorization header if token is null or empty
        headers.remove('Authorization');
        _headers.remove('Authorization');
        if (EnvDev.enableLogging) {
          print('⚠️ No token found in SharedPreferences - removed Authorization header');
        }
      }
    } catch (e) {
      if (EnvDev.enableLogging) {
        print('⚠️ Could not auto-load token: $e');
      }
    }
    
    if (EnvDev.enableLogging) {
      print('📤 Final request headers: ${headers.keys.toList()}');
      if (headers.containsKey('Authorization') && headers['Authorization'] != null) {
        final authHeader = headers['Authorization']!;
        print('   Authorization header: ${authHeader.length > 30 ? authHeader.substring(0, 30) + "..." : authHeader}');
      } else {
        print('   ⚠️ No Authorization header in final headers');
      }
    }
    
    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = '$_baseUrl$endpoint';
      if (EnvDev.enableLogging) {
        print('🌐 GET Request: $url');
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse(url);
      
      if (EnvDev.enableLogging) {
        print('   Parsed URI: ${uri.toString()}');
        print('   Host: ${uri.host}, Port: ${uri.port}, Path: ${uri.path}');
      }
      
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(Duration(milliseconds: EnvDev.timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError('GET $endpoint', e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = '$_baseUrl$endpoint';
      if (EnvDev.enableLogging) {
        print('🌐 POST Request: $url');
        print('📦 Data: ${jsonEncode(data)}');
      }
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(Duration(milliseconds: EnvDev.timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError('POST $endpoint', e);
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(Duration(milliseconds: EnvDev.timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError('PUT $endpoint', e);
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
      ).timeout(Duration(milliseconds: EnvDev.timeoutDuration));

      return _handleResponse(response);
    } catch (e) {
      return _handleError('DELETE $endpoint', e);
    }
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (EnvDev.enableLogging) {
      print('API Response: ${response.statusCode} - ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Invalid JSON response',
          'statusCode': response.statusCode,
        };
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        // استخدام message إذا كان موجوداً، وإلا error، وإلا رسالة افتراضية
        final errorMessage = errorData['message'] ?? 
                            errorData['error'] ?? 
                            'Request failed';
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
          'data': errorData, // إرجاع errorData أيضاً للمعلومات الإضافية
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Request failed with status ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    }
  }

  // Handle network errors
  Map<String, dynamic> _handleError(String operation, dynamic error) {
    if (EnvDev.enableLogging) {
      print('API Error in $operation: $error');
    }

    return {
      'success': false,
      'error': 'Network error: ${error.toString()}',
      'statusCode': 0,
    };
  }

  // Add authentication token to headers
  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  // Remove authentication token from headers
  void clearAuthToken() {
    _headers.remove('Authorization');
  }
}
