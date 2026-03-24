import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

/// Service to handle deep links for BNPL sessions
/// 
/// Supports the following URL scheme:
/// - bnpl://session?id=SESSION_ID
/// 
/// Example: bnpl://session?id=sess_abc123
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  bool _isInitialized = false;

  /// Initialize deep link handling
  /// 
  /// This should be called once in main.dart after the app is built
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_isInitialized) {
      debugPrint('⚠️ Deep link service already initialized');
      return;
    }
    _isInitialized = true;

    debugPrint('🚀 Initializing deep link service...');

    try {
      // Handle initial link (app opened from link while closed)
      final initialLink = await _appLinks.getInitialLink();
      debugPrint('🔍 Initial link: $initialLink');
      
      if (initialLink != null) {
        _handleDeepLink(initialLink, navigatorKey);
      }

      // Handle links while app is running or in background
      _appLinks.uriLinkStream.listen((uri) {
        debugPrint('📨 Received link from stream: $uri');
        _handleDeepLink(uri, navigatorKey);
      });
      
      debugPrint('✅ Deep link service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing deep links: $e');
    }
  }

  /// Handle incoming deep link
  void _handleDeepLink(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    debugPrint('🔗 Received deep link: $uri');
    debugPrint('🔍 Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    debugPrint('🔍 Query params: ${uri.queryParameters}');

    // Check if it's a BNPL link (scheme must be 'bnpl')
    if (uri.scheme == 'bnpl') {
      // Support both formats:
      // 1. bnpl://session?id=xxx (host = 'session')
      // 2. bnpl://?id=xxx (host = '', path = '/')
      final sessionId = uri.queryParameters['id'];
      
      if (sessionId != null && sessionId.isNotEmpty) {
        debugPrint('✅ Navigating to session: $sessionId');
        
        // Navigate to session confirmation page using navigator key
        navigatorKey.currentState?.pushNamed(
          '/session-confirmation',
          arguments: {'sessionId': sessionId},
        );
      } else {
        debugPrint('❌ Session ID is missing in deep link');
        final context = navigatorKey.currentContext;
        if (context != null) {
          _showError(context, 'رابط غير صالح: معرف الجلسة مفقود');
        }
      }
    } else {
      debugPrint('❌ Unknown deep link scheme: ${uri.scheme}');
    }
  }

  /// Show error message to user
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
