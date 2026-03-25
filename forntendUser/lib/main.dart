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
      // Show notification when app is in foreground
      notificationService.showNotification(message);
    },
    onMessageOpenedApp: (message) {
      // Handle notification tap
      print('Notification tapped: ${message.data}');
      if (message.data['type'] == 'pos_session' && message.data['sessionId'] != null) {
        final sessionId = message.data['sessionId'] as String;
        navigatorKey.currentState?.pushNamed(
          AppRouter.sessionConfirmation,
          arguments: {'sessionId': sessionId},
        );
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
    await firebaseService.updateTokenOnServer(null);
  } else {
    print('⚠️ User is not logged in, FCM token will be sent after login');
  }
  
  // Initialize points service
  final pointsService = PointsService();
  await pointsService.initialize();
  
  // Initialize postpone service
  final postponeService = PostponeService();
  await postponeService.initialize();
  
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
