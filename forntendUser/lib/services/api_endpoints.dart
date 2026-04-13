// API Endpoints for BNPL App
// جميع الـ endpoints تطابق Backend API
class ApiEndpoints {
  // ==================== AUTHENTICATION ENDPOINTS ====================
  static const String checkPhone = '/auth/check-phone';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String createAccount = '/auth/create-account';
  static const String getProfile = '/auth/profile';

  // ==================== USERS ENDPOINTS ====================
  static const String userMe = '/users/me';
  static const String updateProfile = '/users/profile';

  // ==================== PAYMENTS ENDPOINTS ====================
  static const String payments = '/payments';
  static const String pendingPayments = '/payments/pending';
  static const String paymentHistory = '/payments/history';
  static String getPaymentById(int id) => '/payments/$id';
  static String getPaymentsByOrderId(String orderId) => '/payments/order/$orderId';
  static String payPayment(int id) => '/payments/$id/pay';
  static String payPaymentStripe(int id) => '/payments/$id/stripe-session';
  static String extendPayment(int id) => '/payments/$id/extend';
  static String postponePayment(int id) => '/payments/$id/postpone';

  // ==================== HOME PAGE ENDPOINTS ====================
  static const String homeData = '/home';
  static const String homePublic = '/home/public';

  // ==================== NOTIFICATIONS ENDPOINTS ====================
  static const String notifications = '/notifications';
  static String markNotificationRead(int id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static String deleteNotification(int id) => '/notifications/$id';

  // ==================== STORES ENDPOINTS ====================
  static const String stores = '/stores';
  static const String storesDeals = '/stores/deals';
  static const String storesSearch = '/stores/search';
  static String storesByCategory(int categoryId) => '/stores/category/$categoryId';
  static String getStoreDetails(int id) => '/stores/$id';
  static String getStoreProducts(int id) => '/stores/$id/products';

  // ==================== PRODUCTS ENDPOINTS ====================
  static const String productsAll = '/products';
  static String productsByStore(int storeId) => '/products/store/$storeId';
  static String productsByCategory(int categoryId) => '/products/category/$categoryId';
  static const String productsSearch = '/products/search';
  static String getProductDetails(int id) => '/products/$id';

  // ==================== REWARDS ENDPOINTS ====================
  static const String rewardsPoints = '/rewards/points';
  static const String rewardsHistory = '/rewards/history';
  static const String rewardsRedeem = '/rewards/redeem';

  // ==================== POSTPONEMENTS ENDPOINTS ====================
  static const String postponementsCanPostpone = '/postponements/can-postpone';
  static const String postponementsPostponeFree = '/postponements/postpone-free';
  static const String postponementsHistory = '/postponements/history';
  static const String extensionOptions = '/postponements/extension-options';
  static String initiateExtension(int paymentId) => '/postponements/$paymentId/initiate-extension';

  // ==================== CATEGORIES ENDPOINTS ====================
  static const String categories = '/categories';

  // ==================== BANNERS ENDPOINTS ====================
  static const String banners = '/banners';

  // ==================== DEALS ENDPOINTS ====================
  static const String deals = '/deals';
  static const String dealsActive = '/deals/active';
  static const String dealsFeatured = '/deals/featured';

  // ==================== CONTACT ENDPOINTS ====================
  static const String contactSettings = '/contact/settings';
  static const String contactMessage = '/contact/message';
  static const String contactUpdateSettings = '/contact/settings';

  // ==================== PROMO NOTIFICATIONS ENDPOINTS ====================
  static const String promoNotifications = '/promo-notifications';

  // ==================== SECURITY ENDPOINTS ====================
  static const String securitySettings = '/security/settings';
  static const String securitySetPin = '/security/pin';
  static const String securityVerifyPin = '/security/pin/verify';
  static const String securityDisablePin = '/security/pin';
  static const String securityEnableBiometric = '/security/biometric/enable';
  static const String securityDisableBiometric = '/security/biometric/disable';
  static const String securityDeleteAccount = '/security/account';
}
