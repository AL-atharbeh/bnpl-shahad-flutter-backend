import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/env/env_dev.dart';

/// Background message handler
/// Must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  }
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _messaging;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize Firebase and request permissions
  Future<void> initialize() async {
    if (kDebugMode) {
      print('🔥 Starting Firebase initialization...');
    }
    
    try {
      // Initialize Firebase
      if (kDebugMode) {
        print('🔥 Step 1: Initializing Firebase Core...');
      }
      await Firebase.initializeApp();
      if (kDebugMode) {
        print('✅ Firebase Core initialized successfully');
      }

      // Initialize messaging after Firebase is initialized
      if (kDebugMode) {
        print('🔥 Step 2: Getting FirebaseMessaging instance...');
      }
      _messaging = FirebaseMessaging.instance;
      if (kDebugMode) {
        print('✅ FirebaseMessaging instance obtained');
      }

      // Request permission for iOS
      if (kDebugMode) {
        print('🔥 Step 3: Requesting notification permissions...');
      }
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('✅ Permission status: ${settings.authorizationStatus}');
        print('   Alert: ${settings.alert}');
        print('   Badge: ${settings.badge}');
        print('   Sound: ${settings.sound}');
      }

      // Get FCM token
      if (kDebugMode) {
        print('🔥 Step 4: Getting FCM token...');
      }
      _fcmToken = await _messaging!.getToken();
      if (kDebugMode) {
        if (_fcmToken != null) {
          print('✅ FCM Token obtained successfully!');
          print('🔥 Token preview: ${_fcmToken!.substring(0, 30)}...');
          print('🔥 Full FCM Token: $_fcmToken');
        } else {
          print('❌ FCM Token is NULL - This is a problem!');
        }
      }

      // Save token locally
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
        if (kDebugMode) {
          print('💾 FCM Token saved locally');
        }
      }

      // Listen to token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
        _updateTokenOnServer(newToken);
      });

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      if (kDebugMode) {
        print('✅ Firebase initialization completed successfully!');
        print('   FCM Token available: ${_fcmToken != null}');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing Firebase: $e');
        print('   Stack trace: $stackTrace');
      }
      // Re-throw to let caller know initialization failed
      rethrow;
    }
  }

  /// Update FCM token on server
  Future<void> updateTokenOnServer(String? token) async {
    if (kDebugMode) {
      print('📤 Attempting to update FCM token on server...');
      print('   Token provided: ${token != null ? "✅" : "❌ (will use cached)"}');
      print('   Cached token: ${_fcmToken != null ? "✅" : "❌"}');
    }
    
    // If no token provided and no cached token, try to get it again
    if (token == null && _fcmToken == null && _messaging != null) {
      if (kDebugMode) {
        print('⚠️ No FCM token available, attempting to get it again...');
      }
      try {
        _fcmToken = await _messaging!.getToken();
        if (kDebugMode) {
          if (_fcmToken != null) {
            print('✅ Successfully obtained FCM token on retry');
            print('🔥 Token preview: ${_fcmToken!.substring(0, 30)}...');
          } else {
            print('❌ Still no FCM token after retry');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to get FCM token on retry: $e');
        }
      }
    }
    
    final tokenToSend = token ?? _fcmToken;
    
    if (tokenToSend == null) {
      if (kDebugMode) {
        print('❌ Cannot update FCM token: No token available');
        print('   This usually means:');
        print('   1. Firebase was not initialized properly');
        print('   2. Notification permissions were not granted');
        print('   3. App is running on iOS Simulator (FCM may not work on simulator)');
      }
      return;
    }

    await _updateTokenOnServer(tokenToSend);
  }

  Future<void> _updateTokenOnServer(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (kDebugMode) {
        print('🔐 Checking auth token...');
        print('   Auth token exists: ${authToken != null ? "✅" : "❌"}');
      }

      if (authToken == null) {
        if (kDebugMode) {
          print('⚠️ No auth token found, skipping FCM token update');
          print('   FCM token will be sent after user logs in');
        }
        return;
      }

      // Use baseUrl from EnvDev (already includes /api/v1)
      final url = '${EnvDev.baseUrl}/users/fcm-token';
      
      if (kDebugMode) {
        print('📡 Sending FCM token to server...');
        print('   URL: $url');
        print('   Token: ${token.substring(0, 20)}...');
      }
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ FCM token updated on server successfully!');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to update FCM token: ${response.statusCode}');
          print('   Response: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating FCM token on server: $e');
      }
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (_messaging == null) return;
      await _messaging!.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (_messaging == null) return;
      await _messaging!.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }

  /// Setup message handlers
  void setupMessageHandlers({
    required Function(RemoteMessage) onMessageReceived,
    required Function(RemoteMessage) onMessageOpenedApp,
  }) {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received foreground message: ${message.messageId}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
      }
      onMessageReceived(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notification opened app: ${message.messageId}');
      }
      onMessageOpenedApp(message);
    });

    // Check if app was opened from a terminated state
    _messaging?.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print('App opened from terminated state: ${message.messageId}');
        }
        onMessageOpenedApp(message);
      }
    });
  }
}
