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

  /// Uploads a merchant document: commercial-registration, trade-license or
  /// owner-id.
  Future<void> uploadDocument(int storeId, String type, String filePath) =>
      client.upload('/stores/$storeId/documents/$type', filePath);

  /// Sends the completed application, with the terms accepted, for review.
  Future<void> submitApplication(int storeId) => client.post(
    '/stores/$storeId/application/submit',
    {'termsAccepted': true},
  );

  /// The signed-in vendor and their store's review status.
  Future<Map<String, dynamic>> me() async =>
      _map(_data(await client.get('/auth/vendor/me')));

  /// Saves the signed-in vendor's name, email or phone; returns the vendor.
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async =>
      _map(_data(await client.put('/auth/vendor/me', data)));

  Future<void> changePassword(String current, String next) => client.put(
    '/auth/vendor/password',
    {'currentPassword': current, 'newPassword': next},
  );

  /// Newest first, with the unread count: `{items, unread}`.
  Future<Map<String, dynamic>> notifications() async => _map(
    _data(await client.get('/auth/vendor/notifications', query: {'limit': 50})),
  );

  /// Marks one notification read, or all of them without an id.
  Future<void> markNotificationsRead([int? id]) => client.post(
    '/auth/vendor/notifications/read',
    id == null ? <String, dynamic>{} : {'id': id},
  );

  /// New API keys; the old ones stop working at once.
  Future<Map<String, dynamic>> regenerateApiKeys(int storeId) async =>
      _map(_data(await client.post('/stores/$storeId/api-keys/regenerate')));

  /// The store's own settlements: `{settlements, total, page, totalPages}`.
  Future<Map<String, dynamic>> mySettlements({int page = 1}) async => _map(
    _data(
      await client.get('/settlements/mine', query: {'page': page, 'limit': 20}),
    ),
  );

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
