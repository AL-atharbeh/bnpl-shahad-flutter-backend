import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class SecurityService {
  final ApiService _apiService = ApiService();

  // Get security settings (PIN and Biometric status)
  Future<Map<String, dynamic>> getSecuritySettings() async {
    return await _apiService.get(ApiEndpoints.securitySettings);
  }

  // Set PIN code (4 digits)
  Future<Map<String, dynamic>> setPin(String pin) async {
    return await _apiService.post(ApiEndpoints.securitySetPin, {'pin': pin});
  }

  // Verify PIN code
  Future<Map<String, dynamic>> verifyPin(String pin) async {
    return await _apiService.post(ApiEndpoints.securityVerifyPin, {'pin': pin});
  }

  // Disable PIN code
  Future<Map<String, dynamic>> disablePin() async {
    return await _apiService.delete(ApiEndpoints.securityDisablePin);
  }

  // Enable biometric authentication
  Future<Map<String, dynamic>> enableBiometric() async {
    return await _apiService.put(ApiEndpoints.securityEnableBiometric, {});
  }

  // Disable biometric authentication
  Future<Map<String, dynamic>> disableBiometric() async {
    return await _apiService.put(ApiEndpoints.securityDisableBiometric, {});
  }

  // Delete user account
  /// What deleting the account would leave behind.
  ///
  /// The confirmation screen asks for this first, so an outstanding balance
  /// is shown before the person commits rather than after.
  Future<Map<String, dynamic>> deletionPreview() async {
    return await _apiService.get(ApiEndpoints.securityDeletionPreview);
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    return await _apiService.delete(ApiEndpoints.securityDeleteAccount);
  }
}

