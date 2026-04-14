// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BNPL';

  @override
  String get welcome => 'Welcome';

  @override
  String get noReviewsYet => 'No reviews for this store yet.';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get products => 'Products';

  @override
  String get categories => 'Categories';

  @override
  String get orders => 'Orders';

  @override
  String get payments => 'Payments';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get checkout => 'Checkout';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tax => 'Tax';

  @override
  String get shipping => 'Shipping';

  @override
  String get discount => 'Discount';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get debitCard => 'Debit Card';

  @override
  String get paypal => 'PayPal';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get orderConfirmation => 'Order Confirmation';

  @override
  String get orderNumber => 'Order Number';

  @override
  String get orderDate => 'Order Date';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get pending => 'Pending';

  @override
  String get processing => 'Processing';

  @override
  String get shipped => 'Shipped';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get onboardingTitle1 => 'أهلا وسهلا… يلا نبلّش';

  @override
  String get onboardingDescription1 =>
      'اشتري اللي بدّك ياه هسّا… والدفع بعدين، ع رواق.';

  @override
  String get onboardingTitle2 => 'رتّب مصروفك على كيفك';

  @override
  String get onboardingDescription2 => 'قسّط دفعاتك على أشهر، وخلي بالك فاضي.';

  @override
  String get onboardingTitle3 => 'تعامل مضمون ١٠٠٪';

  @override
  String get onboardingDescription3 => 'دفعك آمن ومحمي… وانت مطمّن بكل خطوة.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get startShopping => 'Start Shopping';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get submit => 'Submit';

  @override
  String get continueButton => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get loading => 'Loading...';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get retry => 'Retry';

  @override
  String get refresh => 'Refresh';

  @override
  String get emptyCart => 'Your cart is empty';

  @override
  String get emptyOrders => 'No orders found';

  @override
  String get emptyProducts => 'No products found';

  @override
  String get emptyNotifications => 'No notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get all => 'All';

  @override
  String get unread => 'Unread';

  @override
  String get payment => 'Payments';

  @override
  String get offer => 'Offers';

  @override
  String get security => 'Security';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get earlier => 'Earlier';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    return '$count d ago';
  }

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get muteThisType => 'Mute this type';

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get notificationTypeMuted => 'This notification type has been muted';

  @override
  String get noNewNotifications => 'No new notifications';

  @override
  String get newNotificationsWillAppearHere =>
      'New notifications will appear here';

  @override
  String get paymentReminder => 'Payment Reminder';

  @override
  String paymentDueTomorrow(String amount) {
    return 'Payment of $amount JD due tomorrow';
  }

  @override
  String get newOffer => 'New Offer';

  @override
  String get electronicsDiscount => '20% discount on all electronics';

  @override
  String get paymentCompleted => 'Payment Completed';

  @override
  String paymentSuccessfullyProcessed(String amount) {
    return 'Payment of $amount JD successfully processed';
  }

  @override
  String get securityUpdate => 'Security Update';

  @override
  String get securitySettingsUpdated =>
      'Your account security settings have been updated';

  @override
  String get specialOffer => 'Special Offer - Get 5% Off!';

  @override
  String get clothingDiscount => '15% discount on clothing for limited time';

  @override
  String get generalAlert => 'General Alert';

  @override
  String get newFeatureReleased => 'A new feature has been released in the app';

  @override
  String get toggleAllNotifications => 'Enable/Disable All Notifications';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get emailNotificationsSubtitle => 'Important updates and offers';

  @override
  String get smsNotifications => 'SMS Notifications';

  @override
  String get smsNotificationsSubtitle =>
      'Short messages for important activity';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle => 'In-app alerts';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get downloadMyData => 'Download My Data';

  @override
  String get downloadMyDataSubtitle => 'Send me a download link for my data';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountSubtitle => 'This action cannot be undone';

  @override
  String get policies => 'Policies';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'How we handle your data';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle => 'What we expect from you';

  @override
  String get biometricAuthentication => 'Biometric Authentication';

  @override
  String get biometricAuthenticationSubtitle =>
      'Use fingerprint/face to unlock the app';

  @override
  String get twoFactorAuthentication => 'Two-Factor Authentication (2FA)';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordSubtitle => 'Create a strong and unique password';

  @override
  String get privacy => 'Privacy';

  @override
  String get locationServices => 'Location Services';

  @override
  String get locationServicesSubtitle => 'Allow app to access your location';

  @override
  String get usageAnalytics => 'Usage Analytics';

  @override
  String get usageAnalyticsSubtitle =>
      'Help improve the app by sharing usage data';

  @override
  String get twoFactorDisabled => 'Two-factor authentication disabled';

  @override
  String get chooseTwoFactorMethod => 'Choose Two-Factor Authentication Method';

  @override
  String get passwordResetLinkSent => 'Password reset link sent';

  @override
  String get passwordResetEmailSent =>
      'We\'ll send a password reset link to your email.';

  @override
  String get openingPrivacyPolicy => 'Opening privacy policy';

  @override
  String get openingTermsOfService => 'Opening terms of service';

  @override
  String get send => 'Send';

  @override
  String get smsMessage => 'SMS Message';

  @override
  String get authenticatorApp => 'Authenticator App';

  @override
  String get downloadLinkSent => 'Download link sent';

  @override
  String get authenticatorAppOtp => 'Authenticator App (OTP)';

  @override
  String twoFactorEnabled(String method) {
    return '2FA enabled via $method';
  }

  @override
  String get downloadData => 'Download Data';

  @override
  String get downloadDataEmailSent =>
      'We\'ll send a download link for your data to your email.';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure? This action cannot be undone.';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get showConnectedSessions => 'Show connected sessions';

  @override
  String get loginSessions => 'Login Sessions';

  @override
  String get manageConnectedDevices =>
      'Manage devices connected to your account';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get filter => 'Filter';

  @override
  String get shareStore => 'Store shared';

  @override
  String get reviews => 'reviews';

  @override
  String get offers => 'Offers';

  @override
  String get discountUpTo90 => 'Up to 90% off';

  @override
  String get enjoyBestOffers => 'Enjoy the best offers and discounts';

  @override
  String get visitOnlineStore => 'Visit Online Store';

  @override
  String get visitingStore => 'Redirecting to store...';

  @override
  String get sort => 'Sort';

  @override
  String get price => 'Price';

  @override
  String get quantity => 'Quantity';

  @override
  String get size => 'Size';

  @override
  String get color => 'Color';

  @override
  String get description => 'Description';

  @override
  String get rating => 'Rating';

  @override
  String get writeReview => 'Write a Review';

  @override
  String get viewAll => 'View All';

  @override
  String get seeMore => 'See More';

  @override
  String get seeLess => 'See Less';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get autoMode => 'Auto Mode';

  @override
  String get about => 'About';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get help => 'Help';

  @override
  String get faq => 'FAQ';

  @override
  String get support => 'Support';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get searchPlaceholder => 'Search for stores or products';

  @override
  String get searchSubtitle => 'Find the best deals and products';

  @override
  String get pendingPayments => 'Pending Payments';

  @override
  String get viewAllPayments => 'View All';

  @override
  String get daysLeft => 'days left';

  @override
  String get dueIn => 'Due in';

  @override
  String get topStores => 'Top Stores';

  @override
  String get viewAllStores => 'See All';

  @override
  String get bestOffers => 'Best Offers';

  @override
  String get viewAllOffers => 'See All';

  @override
  String get visitStore => 'Visit Store';

  @override
  String get extendDueDate => 'Extend due date';

  @override
  String get forUpTo => 'For up to 21 days';

  @override
  String get extensionRequested => 'Extension requested';

  @override
  String get redirectingToPayment => 'Redirecting to payment page';

  @override
  String payAmount(String amount) {
    return 'Pay JD $amount';
  }

  @override
  String enteringStore(String storeName) {
    return 'Entering $storeName';
  }

  @override
  String pageOf(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String totalStores(int count) {
    return '$count stores';
  }

  @override
  String get favorites => 'Favorites';

  @override
  String get wallet => 'Wallet';

  @override
  String get priceCompare => 'Price compare. Pay less.';

  @override
  String get comparePrice => 'Compare price and get best deals with Flixpay.';

  @override
  String get urgent => 'Urgent';

  @override
  String get newItem => 'New';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get dayAfterTomorrow => 'Day After Tomorrow';

  @override
  String get shopping => 'Shop & Pay Later';

  @override
  String get featuredOffers => 'Featured Offers';

  @override
  String get searchProductOrBrand => 'Search product or brand…';

  @override
  String get product => 'product';

  @override
  String get payLaterPurchases => 'Pay Later Purchases';

  @override
  String get dueIn30Days => 'Due in 30 days';

  @override
  String get totalAmountDue => 'Total Amount Due';

  @override
  String get dueIn7Days => 'Due in 7 days';

  @override
  String get payDues => 'Pay Dues';

  @override
  String get viewHistory => 'View History';

  @override
  String get dueSoon => 'Due Soon';

  @override
  String get pay => 'Pay';

  @override
  String get extend => 'Extend';

  @override
  String get dueTomorrow => 'Due Tomorrow';

  @override
  String dueInDays(int days) {
    return 'Due in $days days';
  }

  @override
  String installmentOf(int current, int total) {
    return '$current of $total Installment';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get securityAndPrivacy => 'Security & Privacy';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get aboutApp => 'About App';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get logoutMessage => 'Are you sure you want to logout?';

  @override
  String get openProfile => 'Open Profile';

  @override
  String get clickToGoToProfile => 'Click to go to profile';

  @override
  String get personalData => 'Personal Data';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get bnplForBusiness => 'BNPL for Business';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get youHonoredUs => 'You Honored Us';

  @override
  String joinedOn(String date) {
    return 'You joined us on $date';
  }

  @override
  String get thankYouMessage =>
      'Thank you for your trust in us and we hope to always meet your expectations. We are here to serve you and provide the best possible experience.';

  @override
  String get myAccount => 'My Account';

  @override
  String get august2025 => 'August 2025';

  @override
  String get paymentsHistory => 'Payments History';

  @override
  String get dateFilter => 'Date Filter';

  @override
  String get selectTimeRange => 'Select time range';

  @override
  String get noPaidTransactions => 'No paid transactions';

  @override
  String get thisMonth => 'This Month';

  @override
  String get transaction => 'transaction';

  @override
  String get transactions => 'transactions';

  @override
  String get paid => 'Paid';

  @override
  String get next7Days => 'Next 7 Days';

  @override
  String get next30Days => 'Next 30 Days';

  @override
  String installmentOfCycle(int current, int total) {
    return '$current of $total Installment';
  }

  @override
  String paymentSuccessful(String amount) {
    return 'Payment successful JD $amount';
  }

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get cardholder => 'Cardholder';

  @override
  String get validThru => 'VALID THRU';

  @override
  String get primaryCard => 'Primary Card';

  @override
  String get add => 'Add';

  @override
  String get addNewCard => 'Add New Card';

  @override
  String get cardholderName => 'Cardholder Name';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date (MM/YY)';

  @override
  String get enterExpiryDate => 'Please enter expiry date';

  @override
  String get invalidMonth => 'Invalid month (01-12)';

  @override
  String get invalidYear => 'Year must be current year or later';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinUsAndStart => 'Join us and start your journey!';

  @override
  String get fullName => 'Full Name';

  @override
  String get iAgreeTo => 'I agree to ';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginHere => 'Login here';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String get phoneMustContainNumbersOnly => 'Phone must contain numbers only';

  @override
  String get phoneMustBe9Digits => 'Phone must be 9 digits';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordDoesNotMeetRequirements =>
      'Password does not meet all requirements';

  @override
  String get pleaseConfirmPassword => 'Please confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseAgreeToTerms => 'Please agree to terms and conditions';

  @override
  String get initialBalance => 'Initial Balance (Optional)';

  @override
  String get saveCard => 'Save Card';

  @override
  String get enterName => 'Enter name';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get invalidFormat => 'Invalid format';

  @override
  String get deleteCard => 'Delete Card';

  @override
  String get choosePaymentMethod => 'Choose Payment Method';

  @override
  String get cardAddedSuccessfully => 'Card added successfully';

  @override
  String get paymentSuccessfulApplePay => 'Payment successful via Apple Pay';

  @override
  String get invalidCardNumber => 'Invalid card number';

  @override
  String get invalidCvv => 'Invalid CVV';

  @override
  String get deleteCardConfirmation => 'Delete Card';

  @override
  String get deleteCardMessage => 'Are you sure you want to delete this card?';

  @override
  String get nationalId => 'National ID';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get address => 'Address';

  @override
  String get updateYourData => 'Update your data for a better experience';

  @override
  String get enterNationalId => 'Enter national ID';

  @override
  String get nationalIdTooShort => 'National ID is too short';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get enterPhone => 'Enter phone number';

  @override
  String get dataSavedSuccessfully => 'Data saved successfully';

  @override
  String get emailHint => 'name@domain.com';

  @override
  String get phoneHint => '+962 79 000 0000';

  @override
  String get addressHint => 'City, Street, Building Number...';

  @override
  String get messageType => 'Message Type';

  @override
  String get generalInquiry => 'General Inquiry';

  @override
  String get technicalIssue => 'Technical Issue';

  @override
  String get paymentBilling => 'Payment & Billing';

  @override
  String get suggestion => 'Suggestion';

  @override
  String get complaint => 'Complaint';

  @override
  String get nameExample => 'Example: John Doe';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get phoneOptional => 'Phone Number (Optional)';

  @override
  String get message => 'Message';

  @override
  String get messageHint => 'Write your message briefly and clearly...';

  @override
  String get enterYourMessage => 'Enter your message';

  @override
  String get messageTooShort => 'Message is too short';

  @override
  String get messageSentSuccessfully =>
      'Your message has been sent successfully';

  @override
  String get customerSupport => 'Customer Support — We\'re happy to serve you';

  @override
  String get call => 'Call';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get whatsappError => 'Failed to open WhatsApp';

  @override
  String get callError => 'Failed to make call';

  @override
  String get emailError => 'Failed to open email';

  @override
  String get due => 'Due';

  @override
  String get getExtraDaysToPay => 'Get Extra Days to Pay';

  @override
  String get extendDueDateDescription =>
      'Extend your due date to enjoy more payment flexibility';

  @override
  String get days => 'days';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get whatAreYouLookingFor => 'What are you looking for?';

  @override
  String get stores => 'Stores';

  @override
  String get onlineOnly => 'Online Only';

  @override
  String get enteringTo => 'Entering to';

  @override
  String get noStoresFound => 'No stores found';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get noOffersFound => 'No offers found';

  @override
  String get noPaymentsFound => 'No payments found';

  @override
  String get productsComingSoon => 'Products coming soon';

  @override
  String get mostRequested => 'Most Requested';

  @override
  String millionReviews(String count) {
    return '${count}M reviews';
  }

  @override
  String thousandReviews(String count) {
    return '${count}K reviews';
  }

  @override
  String get upTo => 'Up to';

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get poor => 'Poor';

  @override
  String get visitEcommerceStore => 'Visit E-commerce Store';

  @override
  String get noStoreUrlAvailable => 'Store URL is not available';

  @override
  String get cannotOpenUrl => 'Cannot open URL';

  @override
  String get errorOpeningUrl => 'Error opening URL';

  @override
  String get share => 'Share';

  @override
  String get currentOffers => 'Current Offers';

  @override
  String get shop => 'Shop';

  @override
  String get startingFrom => 'Starting from';

  @override
  String get monthly => 'monthly';

  @override
  String get orIn4Installments =>
      'or in 4 installments without interest. More options.';

  @override
  String get productType => 'Product Type';

  @override
  String get oneSize => 'One Size';

  @override
  String get eu => 'EU';

  @override
  String get excellentReview => 'Excellent 😍';

  @override
  String get dalalReview =>
      'Shein is truly the most beautiful app! ❤️‍🔥 A diverse and beautiful world, easy to use, everything I need in one place.';

  @override
  String get maiReview =>
      'My experience is excellent in terms of product diversity, fast delivery, and payment options.';

  @override
  String get dalal => 'Dalal';

  @override
  String get mai => 'Mai';

  @override
  String get may2025 => 'May 2025';

  @override
  String get shein => 'Shein';

  @override
  String get tabby => 'tabby';

  @override
  String highQualityFromBestMaterials(String productName) {
    return '$productName high quality from the best materials';
  }

  @override
  String get street6 => 'Street 6';

  @override
  String get dress => 'Dress';

  @override
  String get material => 'Material';

  @override
  String get cotton100 => '100% Cotton';

  @override
  String get multiColor => 'Multi Color';

  @override
  String get availableSizes => 'Available Sizes';

  @override
  String get sizesList => 'XS, S, M, L, XL, XXL';

  @override
  String get warranty => 'Warranty';

  @override
  String get days30 => '30 days';

  @override
  String get delivery => 'Delivery';

  @override
  String get free => 'Free';

  @override
  String get productReturn => 'Return';

  @override
  String get days14 => '14 days';

  @override
  String get trialImages => 'Trial images';

  @override
  String storeDescription(String storeName) {
    return '$storeName store offers the best products at the best prices. We excel in high quality and excellent customer service.';
  }

  @override
  String get blackDress => 'Black Plain Dress';

  @override
  String get summerPolkaDress => 'Summer Polka Dot Dress';

  @override
  String get formalDress => 'Formal Dress';

  @override
  String get casualDress => 'Casual Dress';

  @override
  String get pleatedDress => 'Pleated Dress';

  @override
  String get chiffonDress => 'Chiffon Dress';

  @override
  String get embroideredDress => 'Embroidered Dress';

  @override
  String get shortDress => 'Short Dress';

  @override
  String get newProduct => 'New';

  @override
  String get sheinStore => 'Shein';

  @override
  String get annasStore => 'Annas';

  @override
  String get namshiStore => 'Namshi';

  @override
  String get bloomingdalesStore => 'Bloomingdale\'s';

  @override
  String get allStores => 'All Stores';

  @override
  String get searchStores => 'Search stores...';

  @override
  String get unnas => 'Unnas';

  @override
  String get namshi => 'Namshi';

  @override
  String get electron => 'Electron';

  @override
  String get homestyle => 'Home Style';

  @override
  String get kids => 'Kids';

  @override
  String get fashion => 'Fashion';

  @override
  String get electronics => 'Electronics';

  @override
  String get beauty => 'Beauty';

  @override
  String get searchOffers => 'Search offers...';

  @override
  String get refreshComplete => 'Refreshed successfully';

  @override
  String get rewardsPoints => 'Rewards Points';

  @override
  String get yourPoints => 'Your Points';

  @override
  String get points => 'points';

  @override
  String get earnPointsWithPayments => 'Earn points with every payment!';

  @override
  String get pointsHistory => 'Points History';

  @override
  String get earnedPoints => 'Earned Points';

  @override
  String get redeemedPoints => 'Redeemed Points';

  @override
  String pointsEarnedFromPayment(int points) {
    return '+$points points from payment';
  }

  @override
  String get redeemPoints => 'Redeem Points';

  @override
  String pointsValue(int points, String amount) {
    return '$points points = JD $amount';
  }

  @override
  String get totalEarnedPoints => 'Total Earned Points';

  @override
  String get availableToRedeem => 'Available to Redeem';

  @override
  String get paymentSuccess => 'Payment successful!';

  @override
  String earnedPointsMessage(int points) {
    return 'You earned $points reward points!';
  }

  @override
  String get freePostponeAvailable => 'Free Postpone Available';

  @override
  String get postponeForFree => 'Postpone for Free';

  @override
  String get postponeInstallment => 'Postpone Installment';

  @override
  String get freePostponeTitle => 'Postpone Installment for Free';

  @override
  String get freePostponeDescription =>
      'You can postpone any installment for free once per month. It will be postponed for 10 additional days without fees.';

  @override
  String get currentDueDate => 'Current Due Date';

  @override
  String get newDueDate => 'New Due Date';

  @override
  String get confirmPostpone => 'Confirm Postpone';

  @override
  String get postponeSuccess => 'Installment postponed successfully';

  @override
  String get freePostponeUsed => 'You\'ve used your free postpone this month';

  @override
  String freePostponeUsedWithDays(int days) {
    return 'You can use free postpone again after $days days';
  }

  @override
  String get postponeNote =>
      'Note: You can use this feature once per month for any installment.';

  @override
  String get oneTimeFreePostpone => 'Free Postpone • Monthly';

  @override
  String get postponeDays => 'Postpone 10 Days';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get phoneNumberHint => '7XXXXXXXX';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get welcomeTo => 'Welcome to';

  @override
  String get enterPhoneToStart => 'Enter your phone number to get started';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get enterCodeSentTo => 'Enter the code sent to';

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code?';

  @override
  String get resendCode => 'Resend';

  @override
  String get resendIn => 'Resend in';

  @override
  String get seconds => 'seconds';

  @override
  String get verify => 'Verify';

  @override
  String get verifying => 'Verifying...';

  @override
  String get civilIdVerification => 'Civil ID Verification';

  @override
  String get takeCivilIdPhoto => 'Take a photo of your Civil ID';

  @override
  String get frontSide => 'Front Side';

  @override
  String get backSide => 'Back Side';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get retakePhoto => 'Retake';

  @override
  String get uploadFromGallery => 'Choose from Gallery';

  @override
  String get photoTaken => 'Photo Captured';

  @override
  String get pleaseCaptureBothSides =>
      'Please capture clear photos of both sides';

  @override
  String get completYourProfile => 'Complete Your Profile';

  @override
  String get almostThere => 'Almost There!';

  @override
  String get civilIdNumber => 'Civil ID Number';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get monthlyIncome => 'Monthly Income';

  @override
  String get employer => 'Employer';

  @override
  String get pleaseEnterValidPhone => 'Please enter a valid phone number';

  @override
  String get phoneNumberMustBe8Digits => 'Phone number must be 9 digits';

  @override
  String get pleaseEnterVerificationCode =>
      'Please enter the verification code';

  @override
  String get invalidVerificationCode => 'Invalid verification code';

  @override
  String get pleaseUploadBothSides => 'Please upload photos of both sides';

  @override
  String get accountCreatedSuccessfully => 'Account created successfully!';

  @override
  String get secureAndFast => 'Secure & Fast';

  @override
  String get buyNowPayLater => 'Buy Now, Pay Later';

  @override
  String get enterPassword => 'Enter Password';

  @override
  String get enter4DigitsToLogin => 'Enter 4 digits to log in to your account';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get errorVerifyingPassword => 'Error verifying password';

  @override
  String get loginWithPhoneNumber => 'Log in with phone number';

  @override
  String get pinForAccountLogin => 'PIN for Account Login';

  @override
  String get enabled4Digits => 'Enabled - 4 digits';

  @override
  String get disabledTapToEnable => 'Disabled - Tap to enable';

  @override
  String get faceId => 'Face ID';

  @override
  String get enabledUseFaceIdToLogin => 'Enabled - Use Face ID to log in';

  @override
  String get disabledRequiresPinFirst =>
      'Disabled - Requires PIN activation first';

  @override
  String get accountManagement => 'Account Management';

  @override
  String get deleteAccountPermanently =>
      'Delete account permanently - Cannot be undone';

  @override
  String get setPinForLogin => 'Set PIN for Login';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get enter4DigitsAsPin => 'Enter 4 digits as PIN for account login';

  @override
  String get reEnterPinToConfirm => 'Re-enter PIN to confirm';

  @override
  String get pinsDoNotMatch => 'PINs do not match, please try again';

  @override
  String get changePin => 'Change PIN';

  @override
  String get doYouWantToChangeCurrentPin =>
      'Do you want to change the current PIN?';

  @override
  String get enterCurrentPin => 'Enter current PIN';

  @override
  String get change => 'Change';
}
