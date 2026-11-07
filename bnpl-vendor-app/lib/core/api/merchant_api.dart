import 'api_client.dart';

/// The portal's endpoints, one for one. Methods return the `data` field where
/// the backend wraps responses in `{success, data}`.
class MerchantApi {
  MerchantApi(this.client);

  final ApiClient client;

  static dynamic _data(dynamic body) =>
      body is Map && body.containsKey('data') ? body['data'] : body;

  static List<Map<String, dynamic>> _list(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async =>
      _map(
        _data(
          await client.post('/auth/vendor/login', {
            'email': email,
            'password': password,
          }),
        ),
      );

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async =>
      _map(_data(await client.post('/auth/vendor/register', data)));

  /// The signed-in vendor and their store's review status.
  Future<Map<String, dynamic>> me() async =>
      _map(_data(await client.get('/auth/vendor/me')));

  // Dashboard & reports
  Future<Map<String, dynamic>> dashboardStats(int storeId) async => _map(
    _data(await client.get('/reports/stats', query: {'storeId': storeId})),
  );

  Future<List<Map<String, dynamic>>> performance(int storeId) async => _list(
    _data(
      await client.get('/reports/performance', query: {'storeId': storeId}),
    ),
  );

  Future<Map<String, dynamic>> salesDetailed(int storeId) async => _map(
    _data(
      await client.get('/reports/sales-detailed', query: {'storeId': storeId}),
    ),
  );

  Future<List<Map<String, dynamic>>> transactions(
    int storeId, {
    int page = 1,
    int limit = 50,
  }) async => _list(
    _data(
      await client.get(
        '/payments/admin/all',
        query: {'page': page, 'limit': limit, 'storeId': storeId},
      ),
    ),
  );

  // Settlements
  Future<void> requestSettlement(int storeId, String vendorName) => client.post(
    '/settlements/request',
    {'storeId': storeId, 'vendorName': vendorName},
  );

  // POS sessions
  Future<Map<String, dynamic>> createSession(
    Map<String, dynamic> payload,
  ) async => _map(_data(await client.post('/sessions/create', payload)));

  Future<Map<String, dynamic>> getSession(String sessionId) async =>
      _map(await client.get('/sessions/$sessionId'));

  Future<String?> verifySessionOtp(String sessionId, String otp) async {
    final body = await client.post('/sessions/$sessionId/verify-otp', {
      'otp': otp,
    });
    return body is Map ? body['message']?.toString() : null;
  }

  Future<List<Map<String, dynamic>>> recentSessions(int storeId) async =>
      _list(_data(await client.get('/sessions/store/$storeId/recent')));

  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    final body = await client.get(
      '/users/find-by-phone',
      query: {'phone': phone},
    );
    if (body is Map && body['success'] == true && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data']);
    }
    return null;
  }

  // Products
  Future<List<Map<String, dynamic>>> products(int storeId) async =>
      _list(_data(await client.get('/products/store/$storeId')));

  Future<void> createProduct(Map<String, dynamic> data) =>
      client.post('/products', data);

  Future<void> updateProduct(int id, Map<String, dynamic> data) =>
      client.put('/products/$id', data);

  Future<void> deleteProduct(int id) => client.delete('/products/$id');

  Future<String> uploadProductImage(String filePath) async {
    final data = _map(_data(await client.upload('/products/upload', filePath)));
    final url = data['url']?.toString();
    if (url == null || url.isEmpty) throw ApiException('upload');
    return url;
  }

  // Store
  Future<Map<String, dynamic>> store(int storeId) async =>
      _map(_data(await client.get('/stores/$storeId')));

  Future<void> updateStore(int storeId, Map<String, dynamic> data) =>
      client.put('/stores/$storeId', data);

  Future<Map<String, dynamic>> commissionSettings() async =>
      _map(_data(await client.get('/commission-settings/current')));

  Future<List<Map<String, dynamic>>> categories() async =>
      _list(_data(await client.get('/categories')));
}
