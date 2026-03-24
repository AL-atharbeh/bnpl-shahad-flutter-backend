class Assets {
  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _animationsPath = 'assets/animations';
  
  // App logos and branding
  static const String appLogo = '$_imagesPath/app_logo.png';
  static const String appLogoWhite = '$_imagesPath/app_logo_white.png';
  static const String appIcon = '$_iconsPath/app_icon.png';
  
  // Onboarding images
  static const String onboarding1 = '$_imagesPath/onboarding_1.png';
  static const String onboarding2 = '$_imagesPath/onboarding_2.png';
  static const String onboarding3 = '$_imagesPath/onboarding_3.png';
  
  // Authentication images
  static const String loginBg = '$_imagesPath/login_background.png';
  static const String registerBg = '$_imagesPath/register_background.png';
  static const String forgotPasswordBg = '$_imagesPath/forgot_password_bg.png';
  
  // Home and dashboard images
  static const String homeBanner = '$_imagesPath/home_banner.png';
  static const String categoryPlaceholder = '$_imagesPath/category_placeholder.png';
  static const String productPlaceholder = '$_imagesPath/product_placeholder.png';
  static const String userAvatar = '$_imagesPath/user_avatar.png';
  
  // Product related images
  static const String productDefault = '$_imagesPath/product_default.png';
  static const String categoryIcon = '$_iconsPath/category_icon.png';
  
  // Payment and financial images
  static const String creditCard = '$_imagesPath/credit_card.png';
  static const String wallet = '$_imagesPath/wallet.png';
  static const String paymentSuccess = '$_imagesPath/payment_success.png';
  static const String paymentFailed = '$_imagesPath/payment_failed.png';
  
  // Icons
  static const String homeIcon = '$_iconsPath/home_icon.png';
  static const String searchIcon = '$_iconsPath/search_icon.png';
  static const String cartIcon = '$_iconsPath/cart_icon.png';
  static const String profileIcon = '$_iconsPath/profile_icon.png';
  static const String notificationIcon = '$_iconsPath/notification_icon.png';
  static const String settingsIcon = '$_iconsPath/settings_icon.png';
  static const String logoutIcon = '$_iconsPath/logout_icon.png';
  static const String backIcon = '$_iconsPath/back_icon.png';
  static const String closeIcon = '$_iconsPath/close_icon.png';
  static const String editIcon = '$_iconsPath/edit_icon.png';
  static const String deleteIcon = '$_iconsPath/delete_icon.png';
  static const String addIcon = '$_iconsPath/add_icon.png';
  static const String checkIcon = '$_iconsPath/check_icon.png';
  static const String errorIcon = '$_iconsPath/error_icon.png';
  static const String warningIcon = '$_iconsPath/warning_icon.png';
  static const String infoIcon = '$_iconsPath/info_icon.png';
  static const String successIcon = '$_iconsPath/success_icon.png';
  
  // Social media icons
  static const String facebookIcon = '$_iconsPath/facebook_icon.png';
  static const String googleIcon = '$_iconsPath/google_icon.png';
  static const String appleIcon = '$_iconsPath/apple_icon.png';
  static const String twitterIcon = '$_iconsPath/twitter_icon.png';
  static const String instagramIcon = '$_iconsPath/instagram_icon.png';
  
  // Payment method icons
  static const String visaIcon = '$_iconsPath/visa_icon.png';
  static const String mastercardIcon = '$_iconsPath/mastercard_icon.png';
  static const String paypalIcon = '$_iconsPath/paypal_icon.png';
  static const String applePayIcon = '$_iconsPath/apple_pay_icon.png';
  static const String googlePayIcon = '$_iconsPath/google_pay_icon.png';
  
  // Animations
  static const String loadingAnimation = '$_animationsPath/loading.json';
  static const String successAnimation = '$_animationsPath/success.json';
  static const String errorAnimation = '$_animationsPath/error.json';
  static const String emptyStateAnimation = '$_animationsPath/empty_state.json';
  static const String onboardingAnimation = '$_animationsPath/onboarding.json';
  
  // Helper method to get asset path with optional size suffix
  static String getImagePath(String basePath, {String? size}) {
    if (size != null) {
      final extension = basePath.split('.').last;
      final pathWithoutExtension = basePath.substring(0, basePath.lastIndexOf('.'));
      return '${pathWithoutExtension}_$size.$extension';
    }
    return basePath;
  }
}
