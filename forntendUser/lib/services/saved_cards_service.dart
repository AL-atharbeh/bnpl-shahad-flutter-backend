import 'api_service.dart';

class SavedCardsService {
  final ApiService _apiService = ApiService();

  // Simple static cache to make cards appear instantly
  static List<dynamic>? _cachedCards;
  static DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  /// Get list of saved cards (uses cache if available and fresh)
  Future<Map<String, dynamic>> getCards({bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh && _cachedCards != null && _lastFetch != null) {
      if (DateTime.now().difference(_lastFetch!) < _cacheDuration) {
        return {
          'success': true,
          'cards': _cachedCards,
          'fromCache': true,
        };
      }
    }

    const endpoint = '/saved-cards';
    final response = await _apiService.get(endpoint);
    
    if (response['success']) {
      final data = response['data'];
      // Handle both direct array and wrapped response
      List<dynamic> cards;
      if (data is List) {
        cards = data;
      } else if (data is Map && data.containsKey('data')) {
        cards = data['data'] ?? [];
      } else {
        cards = [];
      }

      // Update cache
      _cachedCards = cards;
      _lastFetch = DateTime.now();

      return {
        'success': true,
        'cards': cards,
      };
    } else {
      return {
        'success': false,
        'error': response['error'] ?? 'فشل تحميل البطاقات',
      };
    }
  }

  /// Create a SetupIntent on backend
  Future<Map<String, dynamic>> createSetupIntent() async {
    const endpoint = '/saved-cards/setup-intent';
    final response = await _apiService.post(endpoint, {});
    
    if (response['success']) {
      final data = response['data'];
      // Handle both direct and wrapped response
      final clientSecret = data is Map && data.containsKey('clientSecret')
          ? data['clientSecret']
          : (data is Map && data.containsKey('data') ? data['data']['clientSecret'] : null);
      
      if (clientSecret == null) {
        return {
          'success': false,
          'error': 'لم يتم استلام مفتاح الإعداد من الخادم',
        };
      }
      return {
        'success': true,
        'clientSecret': clientSecret,
      };
    } else {
      return {
        'success': false,
        'error': response['error'] ?? 'فشل إعداد إضافة البطاقة',
      };
    }
  }

  /// Confirm payment method after Stripe SDK confirmation
  Future<Map<String, dynamic>> confirmCard(String paymentMethodId) async {
    const endpoint = '/saved-cards/confirm';
    final response = await _apiService.post(endpoint, {
      'paymentMethodId': paymentMethodId,
    });
    
    if (response['success']) {
      final data = response['data'];
      _cachedCards = null; // Clear cache so next fetch gets latest
      return {
        'success': true,
        'card': data is Map && data.containsKey('data') ? data['data'] : data,
      };
    } else {
      return {
        'success': false,
        'error': response['error'] ?? 'فشل حفظ البطاقة في النظام',
      };
    }
  }

  /// Delete a saved card
  Future<Map<String, dynamic>> deleteCard(int cardId) async {
    final endpoint = '/saved-cards/$cardId';
    final response = await _apiService.delete(endpoint);
    
    if (response['success']) {
      _cachedCards = null; // Clear cache
      return {'success': true};
    } else {
      return {
        'success': false,
        'error': response['error'] ?? 'فشل حذف البطاقة',
      };
    }
  }

  /// Set a card as default
  Future<Map<String, dynamic>> setDefaultCard(int cardId) async {
    final endpoint = '/saved-cards/$cardId/default';
    final response = await _apiService.put(endpoint, {});
    
    if (response['success']) {
      _cachedCards = null; // Clear cache
      return {'success': true};
    } else {
      return {
        'success': false,
        'error': response['error'] ?? 'فشل تعيين البطاقة كافتراضية',
      };
    }
  }
}
