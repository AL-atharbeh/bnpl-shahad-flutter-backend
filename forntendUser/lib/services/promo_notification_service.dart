import 'api_service.dart';
import 'api_endpoints.dart';

class PromoNotificationService {
  final ApiService _apiService = ApiService();

  // Get all active promo notifications (for home page - global only)
  Future<Map<String, dynamic>> getPromoNotifications({int? categoryId}) async {
    String endpoint = ApiEndpoints.promoNotifications;
    if (categoryId != null) {
      endpoint = '$endpoint?categoryId=$categoryId';
    }
    return await _apiService.get(endpoint);
  }

  // Increment click count for a promo notification
  Future<Map<String, dynamic>> incrementClick(int id) async {
    return await _apiService.post('${ApiEndpoints.promoNotifications}/$id/click', {});
  }
}

