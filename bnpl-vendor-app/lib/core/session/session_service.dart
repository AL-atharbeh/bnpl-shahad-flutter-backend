import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/merchant_api.dart';

/// The signed-in vendor. Stored the same way the portal keeps
/// `vendor_token` and `vendor_user`, so the two behave alike.
class SessionService extends ChangeNotifier {
  SessionService(this.api) {
    api.client.onUnauthorized = () => logout();
  }

  static const _tokenKey = 'vendor_token';
  static const _userKey = 'vendor_user';

  final MerchantApi api;

  Map<String, dynamic>? _vendor;
  Map<String, dynamic>? get vendor => _vendor;
  bool get isSignedIn => api.client.token != null && _vendor != null;

  int get storeId =>
      int.tryParse('${_vendor?['storeId'] ?? _vendor?['store_id'] ?? ''}') ?? 0;
  String get name => _vendor?['name']?.toString() ?? '';

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token == null || userJson == null) return;
    try {
      _vendor = Map<String, dynamic>.from(jsonDecode(userJson));
      api.client.token = token;
    } catch (_) {
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    }
  }

  Future<void> login(String email, String password) async {
    await _store(await api.login(email.trim(), password));
  }

  Future<void> register(Map<String, dynamic> data) async {
    await _store(await api.register(data));
  }

  Future<void> _store(Map<String, dynamic> data) async {
    final token = data['token']?.toString();
    final user = data['user'];
    if (token == null || user is! Map) throw ApiException('error');

    api.client.token = token;
    _vendor = Map<String, dynamic>.from(user);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(_vendor));
    notifyListeners();
  }

  /// Keeps the saved vendor in step after they edit their own details.
  Future<void> updateVendor(Map<String, dynamic> user) async {
    if (_vendor == null) return;
    _vendor = {..._vendor!, ...user};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(_vendor));
    notifyListeners();
  }

  Future<void> logout() async {
    if (_vendor == null && api.client.token == null) return;
    api.client.token = null;
    _vendor = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }
}
