import '../services/api_service.dart';
import '../services/api_endpoints.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  // Get all active categories
  Future<Map<String, dynamic>> getAllCategories({String? genderType}) async {
    String endpoint = ApiEndpoints.categories;
    if (genderType != null && genderType.isNotEmpty) {
      endpoint += '?genderType=$genderType';
    }
    return await _apiService.get(endpoint);
  }

  // Get categories with store counts
  Future<Map<String, dynamic>> getCategoriesWithCounts() async {
    return await _apiService.get('${ApiEndpoints.categories}/with-counts');
  }

  // Get category by ID
  Future<Map<String, dynamic>> getCategoryById(int id) async {
    return await _apiService.get('${ApiEndpoints.categories}/$id');
  }
}

