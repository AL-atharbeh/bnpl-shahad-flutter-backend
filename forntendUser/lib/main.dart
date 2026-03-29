import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'routing/app_router.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'services/points_service.dart';
import 'services/postpone_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/theme/index.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hide debug messages in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  
  // Hide system UI for splash screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  
  // Initialize Firebase
  print('🚀 Starting app initialization...');
  final firebaseService = FirebaseService();
  try {
    await firebaseService.initialize();
    print('✅ Firebase service initialized');
  } catch (e) {
    print('❌ Failed to initialize Firebase: $e');
    // Continue anyway - app can work without Firebase, but notifications won't work
  }
  
  // Initialize notification service
  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
    print('✅ Notification service initialized');
  } catch (e) {
    print('❌ Failed to initialize notification service: $e');
  }
  
  // Setup Firebase message handlers
  firebaseService.setupMessageHandlers(
    onMessageReceived: (message) {
      if (kDebugMode) {
        print('🔥 Received foreground message: ${message.messageId}');
        print('🔥 Message Data: ${message.data}');
        print('🔥 Message Type: ${message.data['type']}');
      }
      
      // Show notification when app is in foreground
      notificationService.showNotification(message);

      // If it's a POS OTP, show a dialog as well
      if (message.data['type'] == 'pos_otp' && message.data['otp'] != null) {
        final otp = message.data['otp'] as String;
        final context = navigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('رمز التحقق - Verification Code', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('قم بإعطاء هذا الرمز للتاجر لإتمام العملية:', textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      otp,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق - Close'),
                ),
              ],
            ),
          );
        }
      }

      // If it's a POS Session Payment, show a confirmation dialog
      if (message.data['type'] == 'pos_session' && message.data['sessionId'] != null) {
        final sessionId = message.data['sessionId'] as String;
        final context = navigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('طلب دفع جديد - Payment Request', textAlign: TextAlign.center),
              content: const Text(
                'لديك طلب دفع جاري. هل تريد الانتقال لصفحة الدفع الآن؟',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('لاحقاً - Later'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    navigatorKey.currentState?.pushNamed(
                      AppRouter.sessionConfirmation,
                      arguments: {'sessionId': sessionId},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ادفع الآن - Pay Now'),
                ),
              ],
            ),
          );
        }
      }
    },
    onMessageOpenedApp: (message) {
      // Handle notification tap
      if (kDebugMode) {
        print('🔥 Notification tapped: ${message.data}');
        print('🔥 Notification Type: ${message.data['type']}');
        print('🔥 Session ID: ${message.data['sessionId']}');
      }

      if (message.data['type'] == 'pos_session' && message.data['sessionId'] != null) {
        final sessionId = message.data['sessionId'] as String;
        navigatorKey.currentState?.pushNamed(
          AppRouter.sessionConfirmation,
          arguments: {'sessionId': sessionId},
        );
      } else if (message.data['type'] == 'pos_otp') {
        // Just open the app
      }
    },
  );
  
  // Initialize language service and load saved language
  final languageService = LanguageService();
  await languageService.initializeLanguage();
  
  // Check if user is already logged in
  final authService = AuthService();
  final isLoggedIn = await authService.autoLogin();
  print('🚀 App starting - isLoggedIn: $isLoggedIn');
  
  // Update FCM token on server if logged in
  if (isLoggedIn) {
    print('🔐 User is logged in, updating FCM token...');
    // Don't await this, let it happen in background
    firebaseService.updateTokenOnServer(null).catchError((e) => print('❌ Error in background FCM update: $e'));
  } else {
    print('⚠️ User is not logged in, FCM token will be sent after login');
  }
  
  // Initialize points service - don't block main startup if it hangs
  final pointsService = PointsService();
  pointsService.initialize().catchError((e) => print('❌ Error initializing PointsService: $e'));
  
  // Initialize postpone service - don't block
  final postponeService = PostponeService();
  postponeService.initialize().catchError((e) => print('❌ Error initializing PostponeService: $e'));
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
        Provider.value(value: authService),
        ChangeNotifierProvider.value(value: pointsService),
        ChangeNotifierProvider.value(value: postponeService),
        Provider.value(value: firebaseService),
        Provider.value(value: notificationService),
      ],
      child: BNPLApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class BNPLApp extends StatefulWidget {
  final bool isLoggedIn;
  
  const BNPLApp({super.key, required this.isLoggedIn});

  @override
  State<BNPLApp> createState() => _BNPLAppState();
}

class _BNPLAppState extends State<BNPLApp> {
  final _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    // Initialize deep linking after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkService.initialize(navigatorKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'BNPL',
          debugShowCheckedModeBanner: false,
          
          // Localization support
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('ar', ''), // Arabic
          ],
          locale: languageService.currentLocale, // Use dynamic locale
          
          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
      
          // Routes configuration - Always start with splash to check PIN
          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
