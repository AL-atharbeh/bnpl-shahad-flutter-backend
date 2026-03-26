class ApiPaths {
  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String changePassword = '/user/change-password';
  
  // BNPL specific endpoints
  static const String products = '/products';
  static const String productDetails = '/products/{id}';
  static const String categories = '/categories';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/{id}';
  static const String createOrder = '/orders/create';
  static const String paymentMethods = '/payment-methods';
  static const String processPayment = '/payments/process';
  static const String paymentHistory = '/payments/history';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/{id}/read';
  
  // In-App Notifications
  static const String inAppNotifications = '/in-app-notifications';
  static const String inAppNotificationsUnread = '/in-app-notifications/unread';
  static const String inAppNotificationsStats = '/in-app-notifications/stats';
  static const String markInAppNotificationDisplayed = '/in-app-notifications/{id}/displayed';
  static const String markInAppNotificationClicked = '/in-app-notifications/{id}/clicked';
  static const String markAllInAppNotificationsRead = '/notifications/read-all';
  
  // Settings
  static const String appSettings = '/settings';
  static const String updateSettings = '/settings/update';
  
  // Support
  static const String contactSupport = '/support/contact';
  static const String faq = '/support/faq';
  
  // Helper method to replace path parameters
  static String replacePathParams(String path, Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
