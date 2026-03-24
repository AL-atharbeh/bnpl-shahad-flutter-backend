import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class ContactService {
  final ApiService _apiService = ApiService();

  // Get contact settings (email, phone, WhatsApp)
  Future<Map<String, dynamic>> getContactSettings() async {
    return await _apiService.get(ApiEndpoints.contactSettings);
  }

  // Send contact message
  Future<Map<String, dynamic>> sendContactMessage({
    required String fullName,
    required String email,
    required String phone,
    required String message,
    String? category,
  }) async {
    final data = {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'message': message,
      if (category != null) 'category': category,
    };

    return await _apiService.post(ApiEndpoints.contactMessage, data);
  }

  // Update contact settings (admin only - requires auth)
  Future<Map<String, dynamic>> updateContactSettings({
    String? contactEmail,
    String? contactPhone,
    String? whatsappNumber,
  }) async {
    final data = <String, dynamic>{};
    if (contactEmail != null) data['contactEmail'] = contactEmail;
    if (contactPhone != null) data['contactPhone'] = contactPhone;
    if (whatsappNumber != null) data['whatsappNumber'] = whatsappNumber;

    return await _apiService.put(ApiEndpoints.contactUpdateSettings, data);
  }
}

