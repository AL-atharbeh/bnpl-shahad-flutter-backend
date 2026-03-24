class InAppNotification {
  final int id;
  final int notificationId;
  final int userId;
  final bool isDisplayed;
  final DateTime? displayedAt;
  final bool isClicked;
  final DateTime? clickedAt;
  final String priority; // low, medium, high, urgent
  final String? category;
  final String? actionButtonText;
  final String? actionUrl;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related notification data
  final NotificationData? notification;

  InAppNotification({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.isDisplayed,
    this.displayedAt,
    required this.isClicked,
    this.clickedAt,
    required this.priority,
    this.category,
    this.actionButtonText,
    this.actionUrl,
    this.expiresAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.notification,
  });

  factory InAppNotification.fromJson(Map<String, dynamic> json) {
    return InAppNotification(
      id: json['id'] as int,
      notificationId: json['notification_id'] as int? ?? json['notificationId'] as int,
      userId: json['user_id'] as int? ?? json['userId'] as int,
      isDisplayed: json['is_displayed'] as bool? ?? json['isDisplayed'] as bool? ?? false,
      displayedAt: json['displayed_at'] != null 
          ? DateTime.parse(json['displayed_at'] as String)
          : json['displayedAt'] != null
              ? DateTime.parse(json['displayedAt'] as String)
              : null,
      isClicked: json['is_clicked'] as bool? ?? json['isClicked'] as bool? ?? false,
      clickedAt: json['clicked_at'] != null
          ? DateTime.parse(json['clicked_at'] as String)
          : json['clickedAt'] != null
              ? DateTime.parse(json['clickedAt'] as String)
              : null,
      priority: json['priority'] as String? ?? 'medium',
      category: json['category'] as String?,
      actionButtonText: json['action_button_text'] as String? ?? json['actionButtonText'] as String?,
      actionUrl: json['action_url'] as String? ?? json['actionUrl'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : json['expiresAt'] != null
              ? DateTime.parse(json['expiresAt'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? json['updatedAt'] as String),
      notification: json['notification'] != null
          ? NotificationData.fromJson(json['notification'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'user_id': userId,
      'is_displayed': isDisplayed,
      'displayed_at': displayedAt?.toIso8601String(),
      'is_clicked': isClicked,
      'clicked_at': clickedAt?.toIso8601String(),
      'priority': priority,
      'category': category,
      'action_button_text': actionButtonText,
      'action_url': actionUrl,
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'notification': notification?.toJson(),
    };
  }

  bool get isRead => notification?.isRead ?? false;
  String get title => notification?.title ?? '';
  String get message => notification?.message ?? '';
  String get type => notification?.type ?? 'system';
  DateTime get time => createdAt;
}

class NotificationData {
  final int id;
  final int userId;
  final String title;
  final String? titleAr;
  final String message;
  final String? messageAr;
  final String type;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  NotificationData({
    required this.id,
    required this.userId,
    required this.title,
    this.titleAr,
    required this.message,
    this.messageAr,
    required this.type,
    required this.isRead,
    this.readAt,
    this.metadata,
    required this.createdAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? json['userId'] as int,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String? ?? json['titleAr'] as String?,
      message: json['message'] as String,
      messageAr: json['message_ar'] as String? ?? json['messageAr'] as String?,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : json['readAt'] != null
              ? DateTime.parse(json['readAt'] as String)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'title_ar': titleAr,
      'message': message,
      'message_ar': messageAr,
      'type': type,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

