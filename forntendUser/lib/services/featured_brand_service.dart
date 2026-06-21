import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class FeaturedBrandService {
  final ApiService _apiService = ApiService();

  // Get all active featured brands
  Future<Map<String, dynamic>> getActiveFeaturedBrands() async {
    return await _apiService.get(ApiEndpoints.featuredBrands);
  }
}
