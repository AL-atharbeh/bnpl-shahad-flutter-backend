import '../models/in_app_notification.dart';
import '../services/api_service.dart';
import '../config/constants/api_paths.dart';

class InAppNotificationService {
  static final InAppNotificationService _instance = InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  final ApiService _apiService = ApiService();

  /// Get all in-app notifications for current user
  Future<List<InAppNotification>> getInAppNotifications() async {
    try {
      final response = await _apiService.get(ApiPaths.inAppNotifications);
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final notificationsList = data['data'] as List<dynamic>? ?? data as List<dynamic>;
        
        return notificationsList
            .map((item) => InAppNotification.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ Failed to get in-app notifications: ${response['error']}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting in-app notifications: $e');
      return [];
    }
  }

  /// Get unread in-app notifications
  Future<List<InAppNotification>> getUnreadInAppNotifications() async {
    try {
      final response = await _apiService.get(ApiPaths.inAppNotificationsUnread);
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final notificationsList = data['data'] as List<dynamic>? ?? data as List<dynamic>;
        
        return notificationsList
            .map((item) => InAppNotification.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ Failed to get unread in-app notifications: ${response['error']}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting unread in-app notifications: $e');
      return [];
    }
  }

  /// Get notification statistics
  Future<Map<String, int>> getNotificationStats() async {
    try {
      final response = await _apiService.get(ApiPaths.inAppNotificationsStats);
      
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final statsData = data['data'] as Map<String, dynamic>? ?? data;
        
        return {
          'total': statsData['total'] as int? ?? 0,
          'unread': statsData['unread'] as int? ?? 0,
          'displayed': statsData['displayed'] as int? ?? 0,
          'clicked': statsData['clicked'] as int? ?? 0,
        };
      } else {
        print('❌ Failed to get notification stats: ${response['error']}');
        return {'total': 0, 'unread': 0, 'displayed': 0, 'clicked': 0};
      }
    } catch (e) {
      print('❌ Error getting notification stats: $e');
      return {'total': 0, 'unread': 0, 'displayed': 0, 'clicked': 0};
    }
  }

  /// Mark notification as displayed
  Future<bool> markAsDisplayed(int id) async {
    try {
      final endpoint = ApiPaths.replacePathParams(
        ApiPaths.markInAppNotificationDisplayed,
        {'id': id.toString()},
      );
      final response = await _apiService.put(endpoint, {});
      
      return response['success'] == true;
    } catch (e) {
      print('❌ Error marking notification as displayed: $e');
      return false;
    }
  }

  /// Mark notification as clicked
  Future<bool> markAsClicked(int id) async {
    try {
      final endpoint = ApiPaths.replacePathParams(
        ApiPaths.markInAppNotificationClicked,
        {'id': id.toString()},
      );
      final response = await _apiService.put(endpoint, {});
      
      return response['success'] == true;
    } catch (e) {
      print('❌ Error marking notification as clicked: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.put(ApiPaths.markAllInAppNotificationsRead, {});
      return response['success'] == true;
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      return false;
    }
  }

  /// Delete in-app notification
  Future<bool> deleteNotification(int id) async {
    try {
      final endpoint = '${ApiPaths.inAppNotifications}/$id';
      final response = await _apiService.delete(endpoint);
      
      return response['success'] == true;
    } catch (e) {
      print('❌ Error deleting notification: $e');
      return false;
    }
  }

  /// Create in-app notification from existing notification
  Future<InAppNotification?> createInAppNotification({
    required int notificationId,
    String? priority,
    String? category,
    String? actionButtonText,
    String? actionUrl,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = <String, dynamic>{
        'notificationId': notificationId,
      };
      
      if (priority != null) data['priority'] = priority;
      if (category != null) data['category'] = category;
      if (actionButtonText != null) data['actionButtonText'] = actionButtonText;
      if (actionUrl != null) data['actionUrl'] = actionUrl;
      if (expiresAt != null) data['expiresAt'] = expiresAt.toIso8601String();
      if (metadata != null) data['metadata'] = metadata;

      final response = await _apiService.post(ApiPaths.inAppNotifications, data);
      
      if (response['success'] == true && response['data'] != null) {
        final responseData = response['data'] as Map<String, dynamic>;
        final notificationData = responseData['data'] as Map<String, dynamic>? ?? responseData;
        return InAppNotification.fromJson(notificationData);
      } else {
        print('❌ Failed to create in-app notification: ${response['error']}');
        return null;
      }
    } catch (e) {
      print('❌ Error creating in-app notification: $e');
      return null;
    }
  }
}

