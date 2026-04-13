import 'api_service.dart';
import 'api_endpoints.dart';

class StoreService {
  final ApiService _apiService = ApiService();

  // Get all stores
  Future<Map<String, dynamic>> getAllStores({int? categoryId, bool? topStore, int? genderCategoryId}) async {
    String endpoint = ApiEndpoints.stores;
    List<String> params = [];
    
    if (categoryId != null) {
      params.add('categoryId=$categoryId');
    }
    
    if (topStore == true) {
      params.add('topStore=1');
    }
    
    if (genderCategoryId != null) {
      params.add('genderCategoryId=$genderCategoryId');
    }
    
    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }
    
    return await _apiService.get(endpoint);
  }

  // Get stores with deals
  Future<Map<String, dynamic>> getStoresWithDeals({int? categoryId}) async {
    String endpoint = ApiEndpoints.storesDeals;
    if (categoryId != null) {
      endpoint += '?categoryId=$categoryId';
    }
    return await _apiService.get(endpoint);
  }

  // Search stores
  Future<Map<String, dynamic>> searchStores(String query, {int? categoryId}) async {
    String endpoint = '${ApiEndpoints.storesSearch}?q=$query';
    if (categoryId != null) {
      endpoint += '&categoryId=$categoryId';
    }
    return await _apiService.get(endpoint);
  }

  // Get stores by category
  Future<Map<String, dynamic>> getStoresByCategory(int categoryId) async {
    return await _apiService.get(ApiEndpoints.storesByCategory(categoryId));
  }

  // Get store by ID
  Future<Map<String, dynamic>> getStoreById(int id) async {
    return await _apiService.get(ApiEndpoints.getStoreDetails(id));
  }

  // Get store products
  Future<Map<String, dynamic>> getStoreProducts(int storeId, {int? categoryId}) async {
    String endpoint = ApiEndpoints.getStoreProducts(storeId);
    if (categoryId != null) {
      endpoint += '?categoryId=$categoryId';
    }
    return await _apiService.get(endpoint);
  }

  // Get store reviews
  Future<Map<String, dynamic>> getStoreReviews(int storeId) async {
    return await _apiService.get(ApiEndpoints.getStoreReviews(storeId));
  }
}
