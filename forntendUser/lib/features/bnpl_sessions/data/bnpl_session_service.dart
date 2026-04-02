import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bnpl_session.dart';
import '../../../config/env/env_dev.dart';

class BnplSessionService {
  static const String baseUrl = EnvDev.baseUrl;

  Future<BnplSession> getSession(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/$sessionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BnplSession.fromJson(data);
      } else {
        throw Exception('فشل في جلب تفاصيل الجلسة');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> approveSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      if (token == null) {
        throw Exception('يجب تسجيل الدخول أولاً للموافقة على الطلب');
      }

      print('Approving session: $sessionId');
      print('Token: ${token.substring(0, 20)}...');

      final response = await http.post(
        Uri.parse('$baseUrl/sessions/$sessionId/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Approve session response: ${response.statusCode}');
      print('Approve session body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorBody = response.body;
        print('❌ Approve session failed: $errorBody');
        throw Exception('فشل في الموافقة على الطلب: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Approve session error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> completeSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      if (token == null) {
        throw Exception('يجب تسجيل الدخول أولاً لإتمام الطلب');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/sessions/$sessionId/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Complete session response: ${response.statusCode}');
      print('Complete session body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorBody = response.body;
        print('❌ Complete session failed: $errorBody');
        throw Exception('فشل في إتمام الطلب: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Complete session error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiateStripePayment({
    required String sessionId,
    required double amount,
    String currency = 'JOD',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');

      if (token == null) {
        throw Exception('يجب تسجيل الدخول أولاً لإتمام الطلب');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payments/stripe/create-checkout-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'sessionId': sessionId,
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في بدء عملية الدفع عبر Stripe');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rejectSession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/$sessionId/reject'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل في رفض الطلب');
      }
    } catch (e) {
      rethrow;
    }
  }
}
