import 'dart:math';
import 'package:flutter/material.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/phone_input_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/civil_id_capture_page.dart';
import '../../features/auth/presentation/pages/complete_profile_page.dart';
import '../../features/auth/presentation/pages/pin_login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/personal_data_page.dart';
import '../../features/profile/presentation/pages/contact_us_page.dart';
import '../../features/profile/presentation/pages/privacy_security_page.dart';
import '../../features/profile/presentation/pages/language_page.dart';
import '../../features/profile/presentation/pages/bnpl_business_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/add_card_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/shop/presentation/pages/stores_page.dart';
import '../../features/shop/presentation/pages/store_details_page.dart';
import '../../features/shop/presentation/pages/product_details_page.dart';
import '../../features/offers/presentation/pages/offers_page.dart';
import '../../features/stores/presentation/pages/all_stores_page.dart';
import '../../features/bnpl_sessions/presentation/pages/session_confirmation_page.dart';
import '../../features/home/presentation/pages/search_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String phoneInput = '/phone-input';
  static const String pinLogin = '/pin-login';
  static const String otpVerification = '/otp-verification';
  static const String civilIdCapture = '/civil-id-capture';
  static const String completeProfile = '/complete-profile';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String personalData = '/personal-data';
  static const String contactUs = '/contact-us';
  static const String privacySecurity = '/privacy-security';
  static const String language = '/language';
  static const String bnplBusiness = '/bnpl-business';
  static const String notifications = '/notifications';
  static const String stores = '/stores';
  static const String storeDetails = '/store-details';
  static const String productDetails = '/product-details';
  static const String offers = '/offers';
  static const String allStores = '/all-stores';
  static const String sessionConfirmation = '/session-confirmation';
  static const String search = '/search';
  static const String payments = '/payments';
  static const String addCard = '/add-card';

  static Route<dynamic> _createCinematicRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart);

        return ClipPath(
          clipper: _CircularRevealClipper(curvedAnimation.value),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 1000),
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('🛣️ Generating route: ${settings.name}');
    
    if (settings.name != null && settings.name!.startsWith('/?id=')) {
      final uri = Uri.parse(settings.name!);
      final sessionId = uri.queryParameters['id'];
      
      if (sessionId != null && sessionId.isNotEmpty) {
        debugPrint('🔗 Deep link detected! Session ID: $sessionId');
        return MaterialPageRoute(
          builder: (_) => SessionConfirmationPage(sessionId: sessionId),
          settings: RouteSettings(
            name: sessionConfirmation,
            arguments: {'sessionId': sessionId},
          ),
        );
      }
    }
    
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const WelcomePage(),
          settings: settings,
        );
      
      case phoneInput:
        return MaterialPageRoute(
          builder: (_) => const PhoneInputPage(),
          settings: settings,
        );
      case pinLogin:
        return MaterialPageRoute(
          builder: (_) => const PinLoginPage(),
          settings: settings,
        );
      
      case otpVerification: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OTPVerificationPage(
            phoneNumber: args?['phoneNumber'] as String? ?? '',
            userExists: args?['userExists'] as bool? ?? false,
          ),
          settings: settings,
        );
      }
      
      case civilIdCapture: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CivilIdCapturePage(
            phoneNumber: args?['phoneNumber'] as String? ?? '',
          ),
          settings: settings,
        );
      }
      
      case completeProfile: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CompleteProfilePage(
            phoneNumber: args?['phoneNumber'] as String? ?? '',
            frontIdPath: args?['frontIdPath'] as String? ?? '',
            backIdPath: args?['backIdPath'] as String? ?? '',
          ),
          settings: settings,
        );
      }
      
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      
      case personalData:
        return MaterialPageRoute(
          builder: (_) => const PersonalDataPage(),
          settings: settings,
        );
      
      case contactUs:
        return MaterialPageRoute(
          builder: (_) => const ContactUsPage(),
          settings: settings,
        );
      
      case privacySecurity:
        return MaterialPageRoute(
          builder: (_) => const PrivacySecurityPage(),
          settings: settings,
        );
      
      case language:
        return MaterialPageRoute(
          builder: (_) => const LanguagePage(),
          settings: settings,
        );
      
      case bnplBusiness:
        return MaterialPageRoute(
          builder: (_) => const BNPLBusinessPage(),
          settings: settings,
        );
      
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
          settings: settings,
        );
      
      case stores: {
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CategoryBrowsePage(
            title: args?['categoryName'] as String? ?? '',
            categoryId: args?['categoryId'] as int?,
          ),
          settings: settings,
        );
      }
       
       case storeDetails: {
         final args = settings.arguments as Map<String, dynamic>?;
         return MaterialPageRoute(
           builder: (_) => StoreDetailsPage(
             storeId: args?['storeId'] as int?,
             storeName:   args?['storeName']   as String? ?? '',
             logoImage:   args?['storeLogo']   as String? ?? '',
             bannerImage: args?['storeBanner'] as String? ?? '',
             rating:      (args?['rating']     as num?)?.toDouble() ?? 0.0,
             reviewsCount: args?['reviewsCount'] as int? ?? 0,
             description: args?['description']  as String? ?? '',
           ),
           settings: settings,
         );
       }
       
       case productDetails: {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args?['productId'] != null) {
            return MaterialPageRoute(
              builder: (_) => ProductDetailsPage(
                productId: args?['productId'] as int,
              ),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (_) => ProductDetailsPage(
              images: (args?['images'] as List<dynamic>?)?.cast<String>() ?? [],
              title: args?['title'] as String? ?? '',
              subtitle: args?['subtitle'] as String? ?? '',
              priceText: args?['priceText'] as String? ?? '',
              oldPriceText: args?['oldPriceText'] as String?,
              discountPercent: args?['discountPercent'] as int?,
              storeName: args?['storeName'] as String? ?? '',
              storeLogo: args?['storeLogo'] as String? ?? '',
              onlineOnly: args?['onlineOnly'] as bool? ?? true,
              attributes: Map<String, String>.from(args?['attributes'] as Map? ?? {}),
            ),
            settings: settings,
          );
        }
        case offers:
          return MaterialPageRoute(
            builder: (_) => const OffersPage(),
            settings: settings,
          );
        case allStores:
          return MaterialPageRoute(
            builder: (_) => const AllStoresPage(),
            settings: settings,
          );
        
        case sessionConfirmation: {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => SessionConfirmationPage(sessionId: args?['sessionId'] as String? ?? ''),
            settings: settings,
          );
        }
        
        case search:
          return MaterialPageRoute(
            builder: (_) => const SearchPage(),
            settings: settings,
          );
        
        case payments:
          return MaterialPageRoute(
            builder: (_) => const PaymentsPage(),
            settings: settings,
          );
        
        case addCard:
          return MaterialPageRoute(
            builder: (_) => const AddCardPage(),
            settings: settings,
          );
        
       default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }

  static void navigateToSplash(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, splash, (route) => false);
  }

  // --- Aliases for Backward Compatibility (using Cinematic by default) ---
  static void navigateToOnboarding(BuildContext context) => navigateToOnboardingCinematic(context);
  static void navigateToPhoneInput(BuildContext context) => navigateToPhoneInputCinematic(context);
  static void navigateToPinLogin(BuildContext context) => navigateToPinLoginCinematic(context);
  static void navigateToHome(BuildContext context) => navigateToHomeCinematic(context);

  static void navigateToOnboardingCinematic(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      _createCinematicRoute(const WelcomePage(), const RouteSettings(name: onboarding)),
      (route) => false,
    );
  }

  static void navigateToPhoneInputCinematic(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      _createCinematicRoute(const PhoneInputPage(), const RouteSettings(name: phoneInput)),
      (route) => false,
    );
  }

  static void navigateToPinLoginCinematic(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      _createCinematicRoute(const PinLoginPage(), const RouteSettings(name: pinLogin)),
      (route) => false,
    );
  }

  static void navigateToHomeCinematic(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      _createCinematicRoute(const HomePage(), const RouteSettings(name: home)),
      (route) => false,
    );
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void navigateToPersonalData(BuildContext context) {
    Navigator.pushNamed(context, personalData);
  }

  static void navigateToContactUs(BuildContext context) {
    Navigator.pushNamed(context, contactUs);
  }

  static void navigateToPrivacySecurity(BuildContext context) {
    Navigator.pushNamed(context, privacySecurity);
  }

  static void navigateToLanguage(BuildContext context) {
    Navigator.pushNamed(context, language);
  }

  static void navigateToBNPLBusiness(BuildContext context) {
    Navigator.pushNamed(context, bnplBusiness);
  }

  static void navigateToNotifications(BuildContext context) {
    Navigator.pushNamed(context, notifications);
  }

  static void navigateToCategoryBrowse(BuildContext context, {required String categoryName, int? categoryId}) {
    Navigator.pushNamed(context, stores, arguments: {'categoryName': categoryName, 'categoryId': categoryId});
  }

  static void navigateToStoreDetails(BuildContext context, {int? storeId, String? storeName, String? storeLogo, String? storeBanner, int? categoryId, double? rating, int? reviewsCount, String? description}) {
    Navigator.pushNamed(context, storeDetails, arguments: {
      if (storeId != null) 'storeId': storeId,
      if (storeName != null) 'storeName': storeName,
      if (storeLogo != null) 'storeLogo': storeLogo,
      if (storeBanner != null) 'storeBanner': storeBanner,
      if (categoryId != null) 'categoryId': categoryId,
      if (rating != null) 'rating': rating,
      if (reviewsCount != null) 'reviewsCount': reviewsCount,
      if (description != null) 'description': description,
    });
  }

  static void navigateToProductDetails(BuildContext context, {int? productId, List<String>? images, String? title, String? subtitle, String? priceText, String? oldPriceText, int? discountPercent, String? storeName, String? storeLogo, bool onlineOnly = true, Map<String, String>? attributes}) {
    Navigator.pushNamed(context, productDetails, arguments: {
      if (productId != null) 'productId': productId,
      if (images != null) 'images': images,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (priceText != null) 'priceText': priceText,
      if (oldPriceText != null) 'oldPriceText': oldPriceText,
      if (discountPercent != null) 'discountPercent': discountPercent,
      if (storeName != null) 'storeName': storeName,
      if (storeLogo != null) 'storeLogo': storeLogo,
      'onlineOnly': onlineOnly,
      if (attributes != null) 'attributes': attributes,
    });
  }

  static void navigateToOffers(BuildContext context) {
    Navigator.pushNamed(context, offers);
  }

  static void navigateToAllStores(BuildContext context) {
    Navigator.pushNamed(context, allStores);
  }

  static void navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, search);
  }

  static void navigateToAddCard(BuildContext context) {
    Navigator.pushNamed(context, addCard);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  _CircularRevealClipper(this.fraction);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    final radius = maxRadius * fraction;

    final path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(_CircularRevealClipper oldClipper) => oldClipper.fraction != fraction;
}
