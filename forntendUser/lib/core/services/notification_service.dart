import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../routing/app_router.dart';
import '../../main.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default', // id
      'Default Notifications', // name
      description: 'This channel is used for default notifications',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;

    if (kDebugMode) {
      print('Notification service initialized');
    }
  }

  /// Show notification from Firebase message
  Future<void> showNotification(RemoteMessage message) async {
    if (!_initialized) await initialize();

    final notification = message.notification;
    if (notification == null) return;

    final imageUrl = notification.android?.imageUrl ?? 
                     message.data['imageUrl'] ?? 
                     message.data['image'];

    AndroidNotificationDetails androidDetails;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final bigPicturePath = await _downloadAndSaveFile(imageUrl, 'notification_picture');
      if (bigPicturePath != null) {
        androidDetails = AndroidNotificationDetails(
          'default',
          'Default Notifications',
          channelDescription: 'This channel is used for default notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          styleInformation: BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            largeIcon: const DrawableResourceAndroidBitmap('launcher_icon'),
          ),
        );
      } else {
        androidDetails = const AndroidNotificationDetails(
          'default',
          'Default Notifications',
          channelDescription: 'This channel is used for default notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        );
      }
    } else {
      androidDetails = const AndroidNotificationDetails(
        'default',
        'Default Notifications',
        channelDescription: 'This channel is used for default notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );
    }

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: json.encode(message.data),
    );

    if (kDebugMode) {
      print('Notification shown: ${notification.title}');
    }
  }

  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading image for notification: $e');
      }
      return null;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = json.decode(response.payload!);
        
        if (data['type'] == 'pos_session' && data['sessionId'] != null) {
          final sessionId = data['sessionId'] as String;
          navigatorKey.currentState?.pushNamed(
            AppRouter.sessionConfirmation,
            arguments: {'sessionId': sessionId},
          );
        }
      } catch (e) {
        print('Error handling notification tap: $e');
      }
    }
  }

  /// Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
