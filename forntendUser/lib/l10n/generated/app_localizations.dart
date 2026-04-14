import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'BNPL'**
  String get appName;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Text shown when a store has no reviews
  ///
  /// In en, this message translates to:
  /// **'No reviews for this store yet.'**
  String get noReviewsYet;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email action text
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Reset password button text
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Phone number label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Home category name
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Search tab label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Cart tab label
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Notifications option
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Products section title
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// Categories section title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Orders section title
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// Payments tab label
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// Add to cart button text
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// Buy now button text
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// Checkout button text
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Subtotal amount label
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// Tax amount label
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// Shipping cost label
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// Discount amount label
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// Payment methods section title
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// Credit card payment method
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// Debit card payment method
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get debitCard;

  /// PayPal payment method
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// Apple Pay payment method
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get applePay;

  /// Google Pay payment method
  ///
  /// In en, this message translates to:
  /// **'Google Pay'**
  String get googlePay;

  /// Order confirmation title
  ///
  /// In en, this message translates to:
  /// **'Order Confirmation'**
  String get orderConfirmation;

  /// Order number label
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// Order date label
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// Order status label
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Processing status
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// Shipped status
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// Delivered status
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// Cancelled status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// First onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'أهلا وسهلا… يلا نبلّش'**
  String get onboardingTitle1;

  /// First onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'اشتري اللي بدّك ياه هسّا… والدفع بعدين، ع رواق.'**
  String get onboardingDescription1;

  /// Second onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'رتّب مصروفك على كيفك'**
  String get onboardingTitle2;

  /// Second onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'قسّط دفعاتك على أشهر، وخلي بالك فاضي.'**
  String get onboardingDescription2;

  /// Third onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'تعامل مضمون ١٠٠٪'**
  String get onboardingTitle3;

  /// Third onboarding screen description
  ///
  /// In en, this message translates to:
  /// **'دفعك آمن ومحمي… وانت مطمّن بكل خطوة.'**
  String get onboardingDescription3;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Start shopping button text
  ///
  /// In en, this message translates to:
  /// **'Start Shopping'**
  String get startShopping;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning title
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Information title
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No internet connection message
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetConnection;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Empty cart message
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCart;

  /// Empty orders message
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get emptyOrders;

  /// Empty products message
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get emptyProducts;

  /// Empty notifications message
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get emptyNotifications;

  /// Mark all notifications as read button
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// Notifications enabled status
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// All filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Unread notifications filter
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// Payment notifications filter
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payment;

  /// Offer notifications filter
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offer;

  /// Security section title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Today text
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday text
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// This week text
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Earlier section label
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// Minutes ago text
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// Hours ago text
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(int count);

  /// Days ago text
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String daysAgo(int count);

  /// Mark notification as read
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// Mark notification as unread
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// Mute notification type
  ///
  /// In en, this message translates to:
  /// **'Mute this type'**
  String get muteThisType;

  /// Success message when marking all as read
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// Success message when deleting notification
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// Success message when muting notification type
  ///
  /// In en, this message translates to:
  /// **'This notification type has been muted'**
  String get notificationTypeMuted;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get noNewNotifications;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'New notifications will appear here'**
  String get newNotificationsWillAppearHere;

  /// Payment reminder notification title
  ///
  /// In en, this message translates to:
  /// **'Payment Reminder'**
  String get paymentReminder;

  /// Payment due message
  ///
  /// In en, this message translates to:
  /// **'Payment of {amount} JD due tomorrow'**
  String paymentDueTomorrow(String amount);

  /// New offer badge
  ///
  /// In en, this message translates to:
  /// **'New Offer'**
  String get newOffer;

  /// Electronics discount message
  ///
  /// In en, this message translates to:
  /// **'20% discount on all electronics'**
  String get electronicsDiscount;

  /// Payment completed notification title
  ///
  /// In en, this message translates to:
  /// **'Payment Completed'**
  String get paymentCompleted;

  /// Payment success message
  ///
  /// In en, this message translates to:
  /// **'Payment of {amount} JD successfully processed'**
  String paymentSuccessfullyProcessed(String amount);

  /// Security update notification title
  ///
  /// In en, this message translates to:
  /// **'Security Update'**
  String get securityUpdate;

  /// Security settings updated message
  ///
  /// In en, this message translates to:
  /// **'Your account security settings have been updated'**
  String get securitySettingsUpdated;

  /// Special offer message
  ///
  /// In en, this message translates to:
  /// **'Special Offer - Get 5% Off!'**
  String get specialOffer;

  /// Clothing discount message
  ///
  /// In en, this message translates to:
  /// **'15% discount on clothing for limited time'**
  String get clothingDiscount;

  /// General alert notification title
  ///
  /// In en, this message translates to:
  /// **'General Alert'**
  String get generalAlert;

  /// New feature released message
  ///
  /// In en, this message translates to:
  /// **'A new feature has been released in the app'**
  String get newFeatureReleased;

  /// Toggle all notifications setting
  ///
  /// In en, this message translates to:
  /// **'Enable/Disable All Notifications'**
  String get toggleAllNotifications;

  /// Notifications disabled status
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// Email notifications setting
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// Email notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Important updates and offers'**
  String get emailNotificationsSubtitle;

  /// SMS notifications setting
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// SMS notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Short messages for important activity'**
  String get smsNotificationsSubtitle;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Push notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'In-app alerts'**
  String get pushNotificationsSubtitle;

  /// Data management section
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Download data option
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get downloadMyData;

  /// Download data subtitle
  ///
  /// In en, this message translates to:
  /// **'Send me a download link for my data'**
  String get downloadMyDataSubtitle;

  /// Delete account option
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account subtitle
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get deleteAccountSubtitle;

  /// Policies section
  ///
  /// In en, this message translates to:
  /// **'Policies'**
  String get policies;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Privacy policy subtitle
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get privacyPolicySubtitle;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Terms of service subtitle
  ///
  /// In en, this message translates to:
  /// **'What we expect from you'**
  String get termsOfServiceSubtitle;

  /// Biometric authentication setting
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// Biometric authentication subtitle
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint/face to unlock the app'**
  String get biometricAuthenticationSubtitle;

  /// Two-factor authentication setting
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication (2FA)'**
  String get twoFactorAuthentication;

  /// Enabled status
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled status
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Change password option
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Change password subtitle
  ///
  /// In en, this message translates to:
  /// **'Create a strong and unique password'**
  String get changePasswordSubtitle;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Location services setting
  ///
  /// In en, this message translates to:
  /// **'Location Services'**
  String get locationServices;

  /// Location services subtitle
  ///
  /// In en, this message translates to:
  /// **'Allow app to access your location'**
  String get locationServicesSubtitle;

  /// Usage analytics setting
  ///
  /// In en, this message translates to:
  /// **'Usage Analytics'**
  String get usageAnalytics;

  /// Usage analytics subtitle
  ///
  /// In en, this message translates to:
  /// **'Help improve the app by sharing usage data'**
  String get usageAnalyticsSubtitle;

  /// Two-factor disabled message
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication disabled'**
  String get twoFactorDisabled;

  /// Choose 2FA method dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Two-Factor Authentication Method'**
  String get chooseTwoFactorMethod;

  /// Password reset link sent message
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent'**
  String get passwordResetLinkSent;

  /// Password reset email sent message
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a password reset link to your email.'**
  String get passwordResetEmailSent;

  /// Opening privacy policy message
  ///
  /// In en, this message translates to:
  /// **'Opening privacy policy'**
  String get openingPrivacyPolicy;

  /// Opening terms of service message
  ///
  /// In en, this message translates to:
  /// **'Opening terms of service'**
  String get openingTermsOfService;

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// SMS message option
  ///
  /// In en, this message translates to:
  /// **'SMS Message'**
  String get smsMessage;

  /// Authenticator app option
  ///
  /// In en, this message translates to:
  /// **'Authenticator App'**
  String get authenticatorApp;

  /// Download link sent message
  ///
  /// In en, this message translates to:
  /// **'Download link sent'**
  String get downloadLinkSent;

  /// Authenticator app OTP option
  ///
  /// In en, this message translates to:
  /// **'Authenticator App (OTP)'**
  String get authenticatorAppOtp;

  /// Two-factor enabled message
  ///
  /// In en, this message translates to:
  /// **'2FA enabled via {method}'**
  String twoFactorEnabled(String method);

  /// Download data dialog title
  ///
  /// In en, this message translates to:
  /// **'Download Data'**
  String get downloadData;

  /// Download data email sent message
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a download link for your data to your email.'**
  String get downloadDataEmailSent;

  /// Delete account dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// Account deleted message
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// Show connected sessions message
  ///
  /// In en, this message translates to:
  /// **'Show connected sessions'**
  String get showConnectedSessions;

  /// Login sessions title
  ///
  /// In en, this message translates to:
  /// **'Login Sessions'**
  String get loginSessions;

  /// Manage connected devices subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage devices connected to your account'**
  String get manageConnectedDevices;

  /// Search products placeholder
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// Filter button text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @shareStore.
  ///
  /// In en, this message translates to:
  /// **'Store shared'**
  String get shareStore;

  /// Reviews count text
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviews;

  /// Offers section title
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @discountUpTo90.
  ///
  /// In en, this message translates to:
  /// **'Up to 90% off'**
  String get discountUpTo90;

  /// Enjoy best offers message
  ///
  /// In en, this message translates to:
  /// **'Enjoy the best offers and discounts'**
  String get enjoyBestOffers;

  /// No description provided for @visitOnlineStore.
  ///
  /// In en, this message translates to:
  /// **'Visit Online Store'**
  String get visitOnlineStore;

  /// No description provided for @visitingStore.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to store...'**
  String get visitingStore;

  /// Sort button text
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Price label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Size label
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// Color attribute
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Rating label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Write review button text
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// See more button text
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// See less button text
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// Language option in profile
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode setting
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Auto mode setting
  ///
  /// In en, this message translates to:
  /// **'Auto Mode'**
  String get autoMode;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Contact us option in profile
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Help link
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// FAQ link
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Support link
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Build number label
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// Search bar placeholder text
  ///
  /// In en, this message translates to:
  /// **'Search for stores or products'**
  String get searchPlaceholder;

  /// Search bar subtitle
  ///
  /// In en, this message translates to:
  /// **'Find the best deals and products'**
  String get searchSubtitle;

  /// Pending payments section title
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// View all payments button
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllPayments;

  /// Days left text
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysLeft;

  /// Due in text
  ///
  /// In en, this message translates to:
  /// **'Due in'**
  String get dueIn;

  /// Top stores section title
  ///
  /// In en, this message translates to:
  /// **'Top Stores'**
  String get topStores;

  /// View all stores button
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get viewAllStores;

  /// Best offers section title
  ///
  /// In en, this message translates to:
  /// **'Best Offers'**
  String get bestOffers;

  /// View all offers button
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get viewAllOffers;

  /// Visit store button
  ///
  /// In en, this message translates to:
  /// **'Visit Store'**
  String get visitStore;

  /// Extend due date action
  ///
  /// In en, this message translates to:
  /// **'Extend due date'**
  String get extendDueDate;

  /// Extension period text
  ///
  /// In en, this message translates to:
  /// **'For up to 21 days'**
  String get forUpTo;

  /// Extension requested message
  ///
  /// In en, this message translates to:
  /// **'Extension requested'**
  String get extensionRequested;

  /// Payment redirect message
  ///
  /// In en, this message translates to:
  /// **'Redirecting to payment page'**
  String get redirectingToPayment;

  /// Pay amount button text
  ///
  /// In en, this message translates to:
  /// **'Pay JD {amount}'**
  String payAmount(String amount);

  /// Entering store message
  ///
  /// In en, this message translates to:
  /// **'Entering {storeName}'**
  String enteringStore(String storeName);

  /// Page indicator text
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(int current, int total);

  /// Total stores count
  ///
  /// In en, this message translates to:
  /// **'{count} stores'**
  String totalStores(int count);

  /// Favorites tab label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Wallet tab label
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Price comparison banner title
  ///
  /// In en, this message translates to:
  /// **'Price compare. Pay less.'**
  String get priceCompare;

  /// Price comparison banner subtitle
  ///
  /// In en, this message translates to:
  /// **'Compare price and get best deals with Flixpay.'**
  String get comparePrice;

  /// Urgent notification text
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// New notification text
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newItem;

  /// Tomorrow text
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Day after tomorrow text
  ///
  /// In en, this message translates to:
  /// **'Day After Tomorrow'**
  String get dayAfterTomorrow;

  /// Shopping tab label
  ///
  /// In en, this message translates to:
  /// **'Shop & Pay Later'**
  String get shopping;

  /// Featured offers section title
  ///
  /// In en, this message translates to:
  /// **'Featured Offers'**
  String get featuredOffers;

  /// Search bar placeholder for products or brands
  ///
  /// In en, this message translates to:
  /// **'Search product or brand…'**
  String get searchProductOrBrand;

  /// Product text
  ///
  /// In en, this message translates to:
  /// **'product'**
  String get product;

  /// Pay later purchases title
  ///
  /// In en, this message translates to:
  /// **'Pay Later Purchases'**
  String get payLaterPurchases;

  /// Due in 30 days text
  ///
  /// In en, this message translates to:
  /// **'Due in 30 days'**
  String get dueIn30Days;

  /// Total amount due text
  ///
  /// In en, this message translates to:
  /// **'Total Amount Due'**
  String get totalAmountDue;

  /// Due in 7 days text
  ///
  /// In en, this message translates to:
  /// **'Due in 7 days'**
  String get dueIn7Days;

  /// Pay dues page title
  ///
  /// In en, this message translates to:
  /// **'Pay Dues'**
  String get payDues;

  /// View history button text
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// Due soon text
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get dueSoon;

  /// Pay button text
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// Extend button text
  ///
  /// In en, this message translates to:
  /// **'Extend'**
  String get extend;

  /// Due tomorrow text
  ///
  /// In en, this message translates to:
  /// **'Due Tomorrow'**
  String get dueTomorrow;

  /// Due in days text
  ///
  /// In en, this message translates to:
  /// **'Due in {days} days'**
  String dueInDays(int days);

  /// Installment text
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} Installment'**
  String installmentOf(int current, int total);

  /// Edit profile option
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Security and privacy option
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityAndPrivacy;

  /// Help and support option
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// About app option
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutMessage;

  /// Open profile button text
  ///
  /// In en, this message translates to:
  /// **'Open Profile'**
  String get openProfile;

  /// Click to go to profile text
  ///
  /// In en, this message translates to:
  /// **'Click to go to profile'**
  String get clickToGoToProfile;

  /// Personal data option in profile
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// Privacy and security option in profile
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// BNPL for business option in profile
  ///
  /// In en, this message translates to:
  /// **'BNPL for Business'**
  String get bnplForBusiness;

  /// Choose language dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Arabic language text
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// English language text
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Thank you message title
  ///
  /// In en, this message translates to:
  /// **'You Honored Us'**
  String get youHonoredUs;

  /// Join date message
  ///
  /// In en, this message translates to:
  /// **'You joined us on {date}'**
  String joinedOn(String date);

  /// Thank you message content
  ///
  /// In en, this message translates to:
  /// **'Thank you for your trust in us and we hope to always meet your expectations. We are here to serve you and provide the best possible experience.'**
  String get thankYouMessage;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// August 2025 date
  ///
  /// In en, this message translates to:
  /// **'August 2025'**
  String get august2025;

  /// Payments history page title
  ///
  /// In en, this message translates to:
  /// **'Payments History'**
  String get paymentsHistory;

  /// Date filter section title
  ///
  /// In en, this message translates to:
  /// **'Date Filter'**
  String get dateFilter;

  /// Select time range placeholder
  ///
  /// In en, this message translates to:
  /// **'Select time range'**
  String get selectTimeRange;

  /// No paid transactions message
  ///
  /// In en, this message translates to:
  /// **'No paid transactions'**
  String get noPaidTransactions;

  /// This month text
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Transaction text
  ///
  /// In en, this message translates to:
  /// **'transaction'**
  String get transaction;

  /// Transactions text
  ///
  /// In en, this message translates to:
  /// **'transactions'**
  String get transactions;

  /// Paid status text
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Next 7 days filter
  ///
  /// In en, this message translates to:
  /// **'Next 7 Days'**
  String get next7Days;

  /// Next 30 days filter
  ///
  /// In en, this message translates to:
  /// **'Next 30 Days'**
  String get next30Days;

  /// Installment cycle text
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} Installment'**
  String installmentOfCycle(int current, int total);

  /// Payment successful message
  ///
  /// In en, this message translates to:
  /// **'Payment successful JD {amount}'**
  String paymentSuccessful(String amount);

  /// Current balance text
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// Cardholder text
  ///
  /// In en, this message translates to:
  /// **'Cardholder'**
  String get cardholder;

  /// Valid thru text
  ///
  /// In en, this message translates to:
  /// **'VALID THRU'**
  String get validThru;

  /// Primary card text
  ///
  /// In en, this message translates to:
  /// **'Primary Card'**
  String get primaryCard;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Add new card title
  ///
  /// In en, this message translates to:
  /// **'Add New Card'**
  String get addNewCard;

  /// Cardholder name field label
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// Card number field label
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// Expiry date field label
  ///
  /// In en, this message translates to:
  /// **'Expiry Date (MM/YY)'**
  String get expiryDate;

  /// Error message for empty expiry date
  ///
  /// In en, this message translates to:
  /// **'Please enter expiry date'**
  String get enterExpiryDate;

  /// Error message for invalid month
  ///
  /// In en, this message translates to:
  /// **'Invalid month (01-12)'**
  String get invalidMonth;

  /// Error message for invalid year
  ///
  /// In en, this message translates to:
  /// **'Year must be current year or later'**
  String get invalidYear;

  /// Create account
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Join us subtitle
  ///
  /// In en, this message translates to:
  /// **'Join us and start your journey!'**
  String get joinUsAndStart;

  /// Full name
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// I agree to text
  ///
  /// In en, this message translates to:
  /// **'I agree to '**
  String get iAgreeTo;

  /// Terms and conditions text
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// Or continue with text
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Login here text
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// Error message for empty full name
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// Error message for empty email
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// Error message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Error message for empty phone
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// Error message for phone format
  ///
  /// In en, this message translates to:
  /// **'Phone must contain numbers only'**
  String get phoneMustContainNumbersOnly;

  /// Error message for phone length
  ///
  /// In en, this message translates to:
  /// **'Phone must be 9 digits'**
  String get phoneMustBe9Digits;

  /// Error message for empty password
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// Error message for password requirements
  ///
  /// In en, this message translates to:
  /// **'Password does not meet all requirements'**
  String get passwordDoesNotMeetRequirements;

  /// Error message for empty confirm password
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get pleaseConfirmPassword;

  /// Error message for password mismatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Error message for terms agreement
  ///
  /// In en, this message translates to:
  /// **'Please agree to terms and conditions'**
  String get pleaseAgreeToTerms;

  /// Initial balance field label
  ///
  /// In en, this message translates to:
  /// **'Initial Balance (Optional)'**
  String get initialBalance;

  /// Save card button text
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// Enter name validation message
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// Invalid number validation message
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// Invalid format validation message
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidFormat;

  /// Delete card button text
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCard;

  /// Choose payment method title
  ///
  /// In en, this message translates to:
  /// **'Choose Payment Method'**
  String get choosePaymentMethod;

  /// Card added successfully message
  ///
  /// In en, this message translates to:
  /// **'Card added successfully'**
  String get cardAddedSuccessfully;

  /// Payment successful via Apple Pay message
  ///
  /// In en, this message translates to:
  /// **'Payment successful via Apple Pay'**
  String get paymentSuccessfulApplePay;

  /// Invalid card number error message
  ///
  /// In en, this message translates to:
  /// **'Invalid card number'**
  String get invalidCardNumber;

  /// Invalid CVV error message
  ///
  /// In en, this message translates to:
  /// **'Invalid CVV'**
  String get invalidCvv;

  /// Delete card confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Card'**
  String get deleteCardConfirmation;

  /// Delete card confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this card?'**
  String get deleteCardMessage;

  /// National ID field label
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// Contact information section title
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// Address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Update your data message
  ///
  /// In en, this message translates to:
  /// **'Update your data for a better experience'**
  String get updateYourData;

  /// Enter national ID validation message
  ///
  /// In en, this message translates to:
  /// **'Enter national ID'**
  String get enterNationalId;

  /// National ID too short validation message
  ///
  /// In en, this message translates to:
  /// **'National ID is too short'**
  String get nationalIdTooShort;

  /// Enter email validation message
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// Invalid email validation message
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// Enter phone validation message
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// Data saved successfully message
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully'**
  String get dataSavedSuccessfully;

  /// Email field hint text
  ///
  /// In en, this message translates to:
  /// **'name@domain.com'**
  String get emailHint;

  /// Phone field hint text
  ///
  /// In en, this message translates to:
  /// **'+962 79 000 0000'**
  String get phoneHint;

  /// Address field hint text
  ///
  /// In en, this message translates to:
  /// **'City, Street, Building Number...'**
  String get addressHint;

  /// Message type section title
  ///
  /// In en, this message translates to:
  /// **'Message Type'**
  String get messageType;

  /// General inquiry category
  ///
  /// In en, this message translates to:
  /// **'General Inquiry'**
  String get generalInquiry;

  /// Technical issue category
  ///
  /// In en, this message translates to:
  /// **'Technical Issue'**
  String get technicalIssue;

  /// Payment and billing category
  ///
  /// In en, this message translates to:
  /// **'Payment & Billing'**
  String get paymentBilling;

  /// Suggestion category
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get suggestion;

  /// Complaint category
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// Name field example
  ///
  /// In en, this message translates to:
  /// **'Example: John Doe'**
  String get nameExample;

  /// Enter your name validation message
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Enter your email validation message
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Phone number optional field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get phoneOptional;

  /// Message field label
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Message field hint
  ///
  /// In en, this message translates to:
  /// **'Write your message briefly and clearly...'**
  String get messageHint;

  /// Enter your message validation
  ///
  /// In en, this message translates to:
  /// **'Enter your message'**
  String get enterYourMessage;

  /// Message too short validation
  ///
  /// In en, this message translates to:
  /// **'Message is too short'**
  String get messageTooShort;

  /// Message sent successfully
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent successfully'**
  String get messageSentSuccessfully;

  /// Customer support header
  ///
  /// In en, this message translates to:
  /// **'Customer Support — We\'re happy to serve you'**
  String get customerSupport;

  /// Call action text
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// WhatsApp action text
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// WhatsApp error message
  ///
  /// In en, this message translates to:
  /// **'Failed to open WhatsApp'**
  String get whatsappError;

  /// Call error message
  ///
  /// In en, this message translates to:
  /// **'Failed to make call'**
  String get callError;

  /// Email error message
  ///
  /// In en, this message translates to:
  /// **'Failed to open email'**
  String get emailError;

  /// Due text for extend sheet
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// Get extra days to pay title
  ///
  /// In en, this message translates to:
  /// **'Get Extra Days to Pay'**
  String get getExtraDaysToPay;

  /// Extend due date description
  ///
  /// In en, this message translates to:
  /// **'Extend your due date to enjoy more payment flexibility'**
  String get extendDueDateDescription;

  /// Days text
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Most popular badge text
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// Search field hint text
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// Stores tab label
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// Online only label
  ///
  /// In en, this message translates to:
  /// **'Online Only'**
  String get onlineOnly;

  /// Entering to store message
  ///
  /// In en, this message translates to:
  /// **'Entering to'**
  String get enteringTo;

  /// No stores found message
  ///
  /// In en, this message translates to:
  /// **'No stores found'**
  String get noStoresFound;

  /// No products found message
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No offers found message
  ///
  /// In en, this message translates to:
  /// **'No offers found'**
  String get noOffersFound;

  /// No payments found message
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get noPaymentsFound;

  /// Products coming soon message
  ///
  /// In en, this message translates to:
  /// **'Products coming soon'**
  String get productsComingSoon;

  /// Most requested badge
  ///
  /// In en, this message translates to:
  /// **'Most Requested'**
  String get mostRequested;

  /// Million reviews count
  ///
  /// In en, this message translates to:
  /// **'{count}M reviews'**
  String millionReviews(String count);

  /// Thousand reviews count
  ///
  /// In en, this message translates to:
  /// **'{count}K reviews'**
  String thousandReviews(String count);

  /// Up to discount text
  ///
  /// In en, this message translates to:
  /// **'Up to'**
  String get upTo;

  /// Excellent rating label
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// Good rating label
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// Poor rating label
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// Visit e-commerce store button text
  ///
  /// In en, this message translates to:
  /// **'Visit E-commerce Store'**
  String get visitEcommerceStore;

  /// Message when store URL is not available
  ///
  /// In en, this message translates to:
  /// **'Store URL is not available'**
  String get noStoreUrlAvailable;

  /// Message when URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Cannot open URL'**
  String get cannotOpenUrl;

  /// Error message when opening URL fails
  ///
  /// In en, this message translates to:
  /// **'Error opening URL'**
  String get errorOpeningUrl;

  /// Share button tooltip
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Current offers section title
  ///
  /// In en, this message translates to:
  /// **'Current Offers'**
  String get currentOffers;

  /// Shop button text
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// Starting from text
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get startingFrom;

  /// Monthly text
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get monthly;

  /// Installment options text
  ///
  /// In en, this message translates to:
  /// **'or in 4 installments without interest. More options.'**
  String get orIn4Installments;

  /// Product type attribute
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get productType;

  /// One size option
  ///
  /// In en, this message translates to:
  /// **'One Size'**
  String get oneSize;

  /// EU size option
  ///
  /// In en, this message translates to:
  /// **'EU'**
  String get eu;

  /// Excellent review rating
  ///
  /// In en, this message translates to:
  /// **'Excellent 😍'**
  String get excellentReview;

  /// Dalal's review text
  ///
  /// In en, this message translates to:
  /// **'Shein is truly the most beautiful app! ❤️‍🔥 A diverse and beautiful world, easy to use, everything I need in one place.'**
  String get dalalReview;

  /// Mai's review text
  ///
  /// In en, this message translates to:
  /// **'My experience is excellent in terms of product diversity, fast delivery, and payment options.'**
  String get maiReview;

  /// Dalal name
  ///
  /// In en, this message translates to:
  /// **'Dalal'**
  String get dalal;

  /// Mai name
  ///
  /// In en, this message translates to:
  /// **'Mai'**
  String get mai;

  /// May 2025 date
  ///
  /// In en, this message translates to:
  /// **'May 2025'**
  String get may2025;

  /// Shein store name
  ///
  /// In en, this message translates to:
  /// **'Shein'**
  String get shein;

  /// Tabby payment service name
  ///
  /// In en, this message translates to:
  /// **'tabby'**
  String get tabby;

  /// Product subtitle template
  ///
  /// In en, this message translates to:
  /// **'{productName} high quality from the best materials'**
  String highQualityFromBestMaterials(String productName);

  /// Street 6 store name
  ///
  /// In en, this message translates to:
  /// **'Street 6'**
  String get street6;

  /// Dress product type
  ///
  /// In en, this message translates to:
  /// **'Dress'**
  String get dress;

  /// Material attribute
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// 100% cotton material
  ///
  /// In en, this message translates to:
  /// **'100% Cotton'**
  String get cotton100;

  /// Multi color option
  ///
  /// In en, this message translates to:
  /// **'Multi Color'**
  String get multiColor;

  /// Available sizes attribute
  ///
  /// In en, this message translates to:
  /// **'Available Sizes'**
  String get availableSizes;

  /// List of available sizes
  ///
  /// In en, this message translates to:
  /// **'XS, S, M, L, XL, XXL'**
  String get sizesList;

  /// Warranty attribute
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get warranty;

  /// 30 days period
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get days30;

  /// Delivery attribute
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// Free delivery
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Return attribute
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get productReturn;

  /// 14 days period
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get days14;

  /// Trial images comment
  ///
  /// In en, this message translates to:
  /// **'Trial images'**
  String get trialImages;

  /// Store description template
  ///
  /// In en, this message translates to:
  /// **'{storeName} store offers the best products at the best prices. We excel in high quality and excellent customer service.'**
  String storeDescription(String storeName);

  /// Black plain dress product name
  ///
  /// In en, this message translates to:
  /// **'Black Plain Dress'**
  String get blackDress;

  /// Summer polka dot dress product name
  ///
  /// In en, this message translates to:
  /// **'Summer Polka Dot Dress'**
  String get summerPolkaDress;

  /// Formal dress product name
  ///
  /// In en, this message translates to:
  /// **'Formal Dress'**
  String get formalDress;

  /// Casual dress product name
  ///
  /// In en, this message translates to:
  /// **'Casual Dress'**
  String get casualDress;

  /// Pleated dress product name
  ///
  /// In en, this message translates to:
  /// **'Pleated Dress'**
  String get pleatedDress;

  /// Chiffon dress product name
  ///
  /// In en, this message translates to:
  /// **'Chiffon Dress'**
  String get chiffonDress;

  /// Embroidered dress product name
  ///
  /// In en, this message translates to:
  /// **'Embroidered Dress'**
  String get embroideredDress;

  /// Short dress product name
  ///
  /// In en, this message translates to:
  /// **'Short Dress'**
  String get shortDress;

  /// New product badge
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newProduct;

  /// Shein store name
  ///
  /// In en, this message translates to:
  /// **'Shein'**
  String get sheinStore;

  /// Annas store name
  ///
  /// In en, this message translates to:
  /// **'Annas'**
  String get annasStore;

  /// Namshi store name
  ///
  /// In en, this message translates to:
  /// **'Namshi'**
  String get namshiStore;

  /// Bloomingdale's store name
  ///
  /// In en, this message translates to:
  /// **'Bloomingdale\'s'**
  String get bloomingdalesStore;

  /// All stores page title
  ///
  /// In en, this message translates to:
  /// **'All Stores'**
  String get allStores;

  /// Search stores placeholder
  ///
  /// In en, this message translates to:
  /// **'Search stores...'**
  String get searchStores;

  /// Unnas store name
  ///
  /// In en, this message translates to:
  /// **'Unnas'**
  String get unnas;

  /// Namshi store name
  ///
  /// In en, this message translates to:
  /// **'Namshi'**
  String get namshi;

  /// Electron store name
  ///
  /// In en, this message translates to:
  /// **'Electron'**
  String get electron;

  /// Home Style store name
  ///
  /// In en, this message translates to:
  /// **'Home Style'**
  String get homestyle;

  /// Kids category name
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kids;

  /// Fashion category name
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get fashion;

  /// Electronics category name
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// Beauty category name
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beauty;

  /// Search offers placeholder
  ///
  /// In en, this message translates to:
  /// **'Search offers...'**
  String get searchOffers;

  /// Message shown when pull-to-refresh completes
  ///
  /// In en, this message translates to:
  /// **'Refreshed successfully'**
  String get refreshComplete;

  /// Rewards points title
  ///
  /// In en, this message translates to:
  /// **'Rewards Points'**
  String get rewardsPoints;

  /// Your points label
  ///
  /// In en, this message translates to:
  /// **'Your Points'**
  String get yourPoints;

  /// Points text
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// Earn points with payments message
  ///
  /// In en, this message translates to:
  /// **'Earn points with every payment!'**
  String get earnPointsWithPayments;

  /// Points history title
  ///
  /// In en, this message translates to:
  /// **'Points History'**
  String get pointsHistory;

  /// Earned points label
  ///
  /// In en, this message translates to:
  /// **'Earned Points'**
  String get earnedPoints;

  /// Redeemed points label
  ///
  /// In en, this message translates to:
  /// **'Redeemed Points'**
  String get redeemedPoints;

  /// Points earned from payment
  ///
  /// In en, this message translates to:
  /// **'+{points} points from payment'**
  String pointsEarnedFromPayment(int points);

  /// Redeem points button text
  ///
  /// In en, this message translates to:
  /// **'Redeem Points'**
  String get redeemPoints;

  /// Points value conversion
  ///
  /// In en, this message translates to:
  /// **'{points} points = JD {amount}'**
  String pointsValue(int points, String amount);

  /// Total earned points label
  ///
  /// In en, this message translates to:
  /// **'Total Earned Points'**
  String get totalEarnedPoints;

  /// Available to redeem label
  ///
  /// In en, this message translates to:
  /// **'Available to Redeem'**
  String get availableToRedeem;

  /// Payment success message
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccess;

  /// Earned points success message
  ///
  /// In en, this message translates to:
  /// **'You earned {points} reward points!'**
  String earnedPointsMessage(int points);

  /// Free postpone badge text
  ///
  /// In en, this message translates to:
  /// **'Free Postpone Available'**
  String get freePostponeAvailable;

  /// Postpone for free button text
  ///
  /// In en, this message translates to:
  /// **'Postpone for Free'**
  String get postponeForFree;

  /// Postpone installment title
  ///
  /// In en, this message translates to:
  /// **'Postpone Installment'**
  String get postponeInstallment;

  /// Free postpone title
  ///
  /// In en, this message translates to:
  /// **'Postpone Installment for Free'**
  String get freePostponeTitle;

  /// Free postpone description
  ///
  /// In en, this message translates to:
  /// **'You can postpone any installment for free once per month. It will be postponed for 10 additional days without fees.'**
  String get freePostponeDescription;

  /// Current due date label
  ///
  /// In en, this message translates to:
  /// **'Current Due Date'**
  String get currentDueDate;

  /// New due date label
  ///
  /// In en, this message translates to:
  /// **'New Due Date'**
  String get newDueDate;

  /// Confirm postpone button
  ///
  /// In en, this message translates to:
  /// **'Confirm Postpone'**
  String get confirmPostpone;

  /// Postpone success message
  ///
  /// In en, this message translates to:
  /// **'Installment postponed successfully'**
  String get postponeSuccess;

  /// Free postpone already used message
  ///
  /// In en, this message translates to:
  /// **'You\'ve used your free postpone this month'**
  String get freePostponeUsed;

  /// Free postpone used with days remaining
  ///
  /// In en, this message translates to:
  /// **'You can use free postpone again after {days} days'**
  String freePostponeUsedWithDays(int days);

  /// Postpone note text
  ///
  /// In en, this message translates to:
  /// **'Note: You can use this feature once per month for any installment.'**
  String get postponeNote;

  /// One time free postpone badge
  ///
  /// In en, this message translates to:
  /// **'Free Postpone • Monthly'**
  String get oneTimeFreePostpone;

  /// Postpone days label
  ///
  /// In en, this message translates to:
  /// **'Postpone 10 Days'**
  String get postponeDays;

  /// Enter phone number prompt
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// Phone number hint
  ///
  /// In en, this message translates to:
  /// **'7XXXXXXXX'**
  String get phoneNumberHint;

  /// Welcome back message
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Welcome to message
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get welcomeTo;

  /// Enter phone to start message
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to get started'**
  String get enterPhoneToStart;

  /// Verification code
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// Enter code sent to message
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to'**
  String get enterCodeSentTo;

  /// Did not receive code
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didNotReceiveCode;

  /// Resend code
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendCode;

  /// Resend in
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// Seconds
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Verify button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Verifying message
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// Civil ID verification
  ///
  /// In en, this message translates to:
  /// **'Civil ID Verification'**
  String get civilIdVerification;

  /// Take civil ID photo
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your Civil ID'**
  String get takeCivilIdPhoto;

  /// Front side
  ///
  /// In en, this message translates to:
  /// **'Front Side'**
  String get frontSide;

  /// Back side
  ///
  /// In en, this message translates to:
  /// **'Back Side'**
  String get backSide;

  /// Take photo
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Retake photo
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retakePhoto;

  /// Upload from gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get uploadFromGallery;

  /// Photo taken
  ///
  /// In en, this message translates to:
  /// **'Photo Captured'**
  String get photoTaken;

  /// Please capture both sides message
  ///
  /// In en, this message translates to:
  /// **'Please capture clear photos of both sides'**
  String get pleaseCaptureBothSides;

  /// Complete your profile
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completYourProfile;

  /// Almost there message
  ///
  /// In en, this message translates to:
  /// **'Almost There!'**
  String get almostThere;

  /// Civil ID number
  ///
  /// In en, this message translates to:
  /// **'Civil ID Number'**
  String get civilIdNumber;

  /// Date of birth
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// Monthly income
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// Employer
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get employer;

  /// Please enter valid phone
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhone;

  /// Phone number must be 9 digits
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 9 digits'**
  String get phoneNumberMustBe8Digits;

  /// Please enter verification code
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get pleaseEnterVerificationCode;

  /// Invalid verification code
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidVerificationCode;

  /// Please upload both sides
  ///
  /// In en, this message translates to:
  /// **'Please upload photos of both sides'**
  String get pleaseUploadBothSides;

  /// Account created successfully
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccessfully;

  /// Secure and fast
  ///
  /// In en, this message translates to:
  /// **'Secure & Fast'**
  String get secureAndFast;

  /// Buy now pay later tagline
  ///
  /// In en, this message translates to:
  /// **'Buy Now, Pay Later'**
  String get buyNowPayLater;

  /// Enter password title
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// Enter 4 digits to login subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter 4 digits to log in to your account'**
  String get enter4DigitsToLogin;

  /// Incorrect password error message
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPassword;

  /// Error verifying password
  ///
  /// In en, this message translates to:
  /// **'Error verifying password'**
  String get errorVerifyingPassword;

  /// Login with phone number button
  ///
  /// In en, this message translates to:
  /// **'Log in with phone number'**
  String get loginWithPhoneNumber;

  /// PIN for account login
  ///
  /// In en, this message translates to:
  /// **'PIN for Account Login'**
  String get pinForAccountLogin;

  /// Enabled - 4 digits
  ///
  /// In en, this message translates to:
  /// **'Enabled - 4 digits'**
  String get enabled4Digits;

  /// Disabled - tap to enable
  ///
  /// In en, this message translates to:
  /// **'Disabled - Tap to enable'**
  String get disabledTapToEnable;

  /// Face ID
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// Enabled - use Face ID to login
  ///
  /// In en, this message translates to:
  /// **'Enabled - Use Face ID to log in'**
  String get enabledUseFaceIdToLogin;

  /// Disabled - requires PIN activation first
  ///
  /// In en, this message translates to:
  /// **'Disabled - Requires PIN activation first'**
  String get disabledRequiresPinFirst;

  /// Account management
  ///
  /// In en, this message translates to:
  /// **'Account Management'**
  String get accountManagement;

  /// Delete account permanently - cannot be undone
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently - Cannot be undone'**
  String get deleteAccountPermanently;

  /// Set PIN for login
  ///
  /// In en, this message translates to:
  /// **'Set PIN for Login'**
  String get setPinForLogin;

  /// Confirm PIN
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// Enter 4 digits as PIN for account login
  ///
  /// In en, this message translates to:
  /// **'Enter 4 digits as PIN for account login'**
  String get enter4DigitsAsPin;

  /// Re-enter PIN to confirm
  ///
  /// In en, this message translates to:
  /// **'Re-enter PIN to confirm'**
  String get reEnterPinToConfirm;

  /// PINs do not match, please try again
  ///
  /// In en, this message translates to:
  /// **'PINs do not match, please try again'**
  String get pinsDoNotMatch;

  /// Change PIN
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// Do you want to change the current PIN?
  ///
  /// In en, this message translates to:
  /// **'Do you want to change the current PIN?'**
  String get doYouWantToChangeCurrentPin;

  /// Enter current PIN
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get enterCurrentPin;

  /// Change button
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
