import 'api_service.dart';
import 'api_endpoints.dart';

class HomeService {
  final ApiService _apiService = ApiService();

  // Get home page data
  Future<Map<String, dynamic>> getHomeData() async {
    return await _apiService.get(ApiEndpoints.homeData);
  }

  // Get all stores
  Future<Map<String, dynamic>> getAllStores() async {
    return await _apiService.get(ApiEndpoints.stores);
  }

  // Get store details
  Future<Map<String, dynamic>> getStoreDetails(int storeId) async {
    return await _apiService.get(ApiEndpoints.getStoreDetails(storeId));
  }

  // Get store products
  Future<Map<String, dynamic>> getStoreProducts(int storeId) async {
    return await _apiService.get(ApiEndpoints.getStoreProducts(storeId));
  }

  // Get all offers (deals)
  Future<Map<String, dynamic>> getAllOffers() async {
    return await _apiService.get(ApiEndpoints.deals);
  }

  // Get featured offers
  Future<Map<String, dynamic>> getFeaturedOffers() async {
    return await _apiService.get(ApiEndpoints.dealsFeatured);
  }

  // Search stores
  Future<Map<String, dynamic>> searchStores(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    return await _apiService.get('${ApiEndpoints.storesSearch}?q=$encodedQuery');
  }

  // Search products
  Future<Map<String, dynamic>> searchProducts(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    return await _apiService.get('${ApiEndpoints.productsSearch}?q=$encodedQuery');
  }
}
