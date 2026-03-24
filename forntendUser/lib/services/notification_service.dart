import 'api_service.dart';
import 'api_endpoints.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  // Get all notifications
  Future<Map<String, dynamic>> getAllNotifications() async {
    return await _apiService.get(ApiEndpoints.notifications);
  }

  // Mark notification as read
  Future<Map<String, dynamic>> markNotificationAsRead(int notificationId) async {
    return await _apiService.put(
      ApiEndpoints.markNotificationRead(notificationId),
      {},
    );
  }

  // Mark all notifications as read
  Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    return await _apiService.put(ApiEndpoints.markAllNotificationsRead, {});
  }

  // Delete notification
  Future<Map<String, dynamic>> deleteNotification(int notificationId) async {
    return await _apiService.delete(
      ApiEndpoints.deleteNotification(notificationId),
    );
  }
}
