import 'api_service.dart';
import 'api_endpoints.dart';

class DealService {
  final ApiService _apiService = ApiService();

  // Get all deals with optional filters
  Future<Map<String, dynamic>> getAllDeals({
    bool? isActive,
    int? storeId,
    int? productId,
    bool? includeExpired,
  }) async {
    List<String> params = [];
    
    if (isActive != null) {
      params.add('isActive=${isActive ? 'true' : 'false'}');
    }
    if (storeId != null) {
      params.add('storeId=$storeId');
    }
    if (productId != null) {
      params.add('productId=$productId');
    }
    if (includeExpired == true) {
      params.add('includeExpired=true');
    }
    
    String endpoint = ApiEndpoints.deals;
    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }
    
    return await _apiService.get(endpoint);
  }

  // Get active deals for home page
  Future<Map<String, dynamic>> getActiveDeals({int? limit}) async {
    String endpoint = ApiEndpoints.dealsActive;
    if (limit != null) {
      endpoint += '?limit=$limit';
    }
    return await _apiService.get(endpoint);
  }

  // Get deal by ID
  Future<Map<String, dynamic>> getDealById(int id) async {
    return await _apiService.get('${ApiEndpoints.deals}/$id');
  }
}

