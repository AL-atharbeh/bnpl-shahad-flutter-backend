import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/env_dev.dart';

class PaymentService {
  final String baseUrl = EnvDev.baseUrl;

  Future<String?> initiatePayment(double amount, {String currency = 'KWD'}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('User not logged in');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payments/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // MyFatoorah returns PaymentURL in the data object
          // The structure depends on MyFatoorah response, but usually it's data.PaymentURL
          // Our backend returns { success: true, data: { ...MyFatoorahResponse } }
          // MyFatoorah InitiatePayment response has Data: { PaymentURL: "..." }
          
          final myFatoorahData = data['data'];
          if (myFatoorahData['Data'] != null && myFatoorahData['Data']['PaymentURL'] != null) {
            return myFatoorahData['Data']['PaymentURL'];
          }
        }
      }
      
      print('Failed to initiate payment: ${response.body}');
      return null;
    } catch (e) {
      print('Error initiating payment: $e');
      return null;
    }
  }
}
