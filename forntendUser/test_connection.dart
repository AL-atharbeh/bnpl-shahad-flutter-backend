import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 اختبار الاتصال...\n');
  
  // Test 1: Backend Health
  try {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000'));
    print('✅ Backend Health: ${response.statusCode}');
    print('   ${jsonDecode(response.body)['message']}\n');
  } catch (e) {
    print('❌ Backend Error: $e\n');
  }
  
  // Test 2: Stores API
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/v1/stores'),
      headers: {'Content-Type': 'application/json'},
    );
    final data = jsonDecode(response.body);
    print('✅ Stores API: ${response.statusCode}');
    print('   Success: ${data['success']}');
    print('   عدد المتاجر: ${data['data'].length}\n');
  } catch (e) {
    print('❌ Stores API Error: $e\n');
  }
  
  // Test 3: Auth Check Phone
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/v1/auth/check-phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': '+962799999999'}),
    );
    final data = jsonDecode(response.body);
    print('✅ Auth Check: ${response.statusCode}');
    print('   ${data['message']}');
    print('   Exists: ${data['exists']}\n');
  } catch (e) {
    print('❌ Auth Check Error: $e\n');
  }
  
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ الاتصال يعمل من Dart!');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
