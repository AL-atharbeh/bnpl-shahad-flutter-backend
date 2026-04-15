import 'api_service.dart';

class SavedCardsService {
  final ApiService _apiService = ApiService();

  /// Get list of saved cards
  Future<Map<String, dynamic>> getCards() async {
    const endpoint = '/api/v1/saved-cards';
    final response = await _apiService.get(endpoint);
    
    if (response['success']) {
      final List<dynamic> cards = response['data'] ?? [];
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
    const endpoint = '/api/v1/saved-cards/setup-intent';
    final response = await _apiService.post(endpoint, {});
    
    if (response['success']) {
      return {
        'success': true,
        'clientSecret': response['data']['clientSecret'],
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
    const endpoint = '/api/v1/saved-cards/confirm';
    final response = await _apiService.post(endpoint, {
      'paymentMethodId': paymentMethodId,
    });
    
    if (response['success']) {
      return {
        'success': true,
        'card': response['data'],
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
    final endpoint = '/api/v1/saved-cards/$cardId';
    final response = await _apiService.delete(endpoint);
    
    if (response['success']) {
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
    final endpoint = '/api/v1/saved-cards/$cardId/default';
    final response = await _apiService.put(endpoint, {});
    
    if (response['success']) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'error': response['error'] ?? 'فشل تعيين البطاقة كافتراضية',
      };
    }
  }
}
