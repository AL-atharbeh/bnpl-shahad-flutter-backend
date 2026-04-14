import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class BannerService {
  final ApiService _apiService = ApiService();

  // Get all active banners
  Future<Map<String, dynamic>> getAllBanners({int? categoryId}) async {
    String endpoint = ApiEndpoints.banners;
    if (categoryId != null) {
      endpoint += '?categoryId=$categoryId';
    }
    return await _apiService.get(endpoint);
  }

  // Get banner by ID
  Future<Map<String, dynamic>> getBannerById(int id) async {
    return await _apiService.get('${ApiEndpoints.banners}/$id');
  }

  // Increment banner click count
  Future<Map<String, dynamic>> incrementClickCount(int id) async {
    return await _apiService.post('${ApiEndpoints.banners}/$id/click', {});
  }

  // Get banners by category
  Future<Map<String, dynamic>> getBannersByCategory(int categoryId) async {
    return await _apiService.get('${ApiEndpoints.banners}/category/$categoryId');
  }

  // Get active splash banner
  Future<Map<String, dynamic>> getSplashBanner() async {
    return await _apiService.get(ApiEndpoints.appConfigSplash);
  }
}

