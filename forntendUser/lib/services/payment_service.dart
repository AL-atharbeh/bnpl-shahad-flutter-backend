import 'api_service.dart';
import 'api_endpoints.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  // Get user payments
  Future<Map<String, dynamic>> getUserPayments({
    int? installmentNumber,
    int? installmentsCount,
  }) async {
    String endpoint = ApiEndpoints.payments;
    List<String> queryParams = [];
    
    if (installmentNumber != null) {
      queryParams.add('installmentNumber=$installmentNumber');
    }
    if (installmentsCount != null) {
      queryParams.add('installmentsCount=$installmentsCount');
    }
    
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }
    
    return await _apiService.get(endpoint);
  }

  // Get pending payments
  Future<Map<String, dynamic>> getPendingPayments({
    int? installmentNumber,
    int? installmentsCount,
    bool? nextOnly,
  }) async {
    String endpoint = ApiEndpoints.pendingPayments;
    List<String> queryParams = [];
    
    if (installmentNumber != null) {
      queryParams.add('installmentNumber=$installmentNumber');
    }
    if (installmentsCount != null) {
      queryParams.add('installmentsCount=$installmentsCount');
    }
    if (nextOnly != null) {
      queryParams.add('nextOnly=$nextOnly');
    }
    
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }
    
    return await _apiService.get(endpoint);
  }

  // Get payment history
  Future<Map<String, dynamic>> getPaymentHistory({
    String? startDate,
    String? endDate,
    String? status,
    int? installmentNumber,
    int? installmentsCount,
  }) async {
    String endpoint = ApiEndpoints.paymentHistory;
    List<String> queryParams = [];
    
    if (startDate != null) queryParams.add('startDate=$startDate');
    if (endDate != null) queryParams.add('endDate=$endDate');
    if (status != null) queryParams.add('status=$status');
    if (installmentNumber != null) queryParams.add('installmentNumber=$installmentNumber');
    if (installmentsCount != null) queryParams.add('installmentsCount=$installmentsCount');
    
    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }
    
    return await _apiService.get(endpoint);
  }

  // Get payment by ID
  Future<Map<String, dynamic>> getPaymentById(int id) async {
    return await _apiService.get(ApiEndpoints.getPaymentById(id));
  }

  // Get payments by order ID
  Future<Map<String, dynamic>> getPaymentsByOrderId(String orderId) async {
    return await _apiService.get(ApiEndpoints.getPaymentsByOrderId(orderId));
  }

  // Process payment (pay a payment)
  Future<Map<String, dynamic>> payPayment(int paymentId) async {
    return await _apiService.post(ApiEndpoints.payPayment(paymentId), {});
  }

  // Extend due date for a payment
  Future<Map<String, dynamic>> extendDueDate({
    required int paymentId,
    required int extensionDays,
  }) async {
    final data = {
      'extensionDays': extensionDays,
    };

    return await _apiService.put(ApiEndpoints.extendPayment(paymentId), data);
  }

  // Postpone payment
  Future<Map<String, dynamic>> postponePayment({
    required int paymentId,
    required int daysToPostpone,
  }) async {
    final data = {
      'daysToPostpone': daysToPostpone,
    };

    return await _apiService.post(ApiEndpoints.postponePayment(paymentId), data);
  }
}
