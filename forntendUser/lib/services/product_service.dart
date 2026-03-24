import 'api_service.dart';
import 'api_endpoints.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // Get product by ID
  Future<Map<String, dynamic>> getProductById(int id) async {
    return await _apiService.get(ApiEndpoints.getProductDetails(id));
  }

  // Get all products, optionally filtered by category
  Future<Map<String, dynamic>> getAllProducts({int? categoryId}) async {
    if (categoryId != null) {
      return await _apiService.get(ApiEndpoints.productsByCategory(categoryId));
    }
    return await _apiService.get(ApiEndpoints.productsAll);
  }

  // Get products by category
  Future<Map<String, dynamic>> getProductsByCategory(int categoryId) async {
    return await _apiService.get(ApiEndpoints.productsByCategory(categoryId));
  }
}

