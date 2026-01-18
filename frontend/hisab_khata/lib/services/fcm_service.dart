import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hisab_khata/core/constants/api_base_url.dart';
import 'package:hisab_khata/core/constants/routes.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static String? _fcmToken;
  static String? _authToken;
  static String? _baseUrl;

  // Initialize FCM service
  static Future<void> initialize({String? authToken}) async {
    _authToken = authToken;
    _baseUrl = ApiBaseUrl.baseUrl;

    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        _fcmToken = await _firebaseMessaging.getToken();
        print('FCM Token: $_fcmToken');

        // Send token to backend
        if (_fcmToken != null) {
          await _sendTokenToServer(_fcmToken!);
        }

        // Listen to token refresh
        _firebaseMessaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          print('FCM Token refreshed: $token');
          _sendTokenToServer(token);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle message when app is opened from background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Handle initial message (when app is opened from terminated state)
        RemoteMessage? initialMessage = await _firebaseMessaging
            .getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

        print('FCM initialized successfully');
      } else {
        print('FCM permission denied');
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'hisab_khata_notifications',
      'Hisab Khata Notifications',
      description: 'Notifications for connection requests and updates',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // Send FCM token to backend
  static Future<void> _sendTokenToServer(String token) async {
    if (_authToken == null || _baseUrl == null) {
      print('No auth token or base URL available, skipping FCM token upload');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/fcm-token/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode({'fcm_token': token}),
      );

      if (response.statusCode == 200) {
        print('FCM token sent to server successfully');
      } else {
        print(
          'Failed to send FCM token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error sending FCM token to server: $e');
    }
  }

  // Clear FCM token on logout
  static Future<void> clearTokenOnLogout() async {
    if (_authToken == null || _baseUrl == null) return;

    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}auth/fcm-token/'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      if (response.statusCode == 200) {
        print('FCM token cleared successfully');
      } else {
        print('Failed to clear FCM token: ${response.statusCode}');
      }

      _fcmToken = null;
      _authToken = null;
    } catch (e) {
      print('Error clearing FCM token: $e');
    }
  }

  // Update auth token
  static void updateAuthToken(String? authToken) {
    _authToken = authToken;
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification
    await _showLocalNotification(message);
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    print('📱 Showing local notification...');
    print('Notification exists: ${notification != null}');

    if (notification != null) {
      print('Notification title: ${notification.title}');
      print('Notification body: ${notification.body}');

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hisab_khata_notifications',
            'Hisab Khata Notifications',
            channelDescription:
                'Notifications for connection requests and updates',
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: _encodePayload(message.data),
      );
      print('Local notification shown successfully!');
    } else {
      print('No notification data in message');
    }
  }

  // Handle notification tap (when app is in background)
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.notification?.title}');
    _navigateBasedOnType(message.data);
  }

  // Handle local notification response
  static void _onNotificationResponse(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      final data = _decodePayload(response.payload!);
      _navigateBasedOnType(data);
    }
  }

  // Navigate based on notification type
  static void _navigateBasedOnType(Map<String, dynamic> data) {
    final BuildContext? context = _getNavigatorContext();
    if (context == null) return;

    final String? type = data['type'];

    switch (type) {
      case 'connection_request':
        // Navigate to connection requests screen
        Navigator.pushNamed(context, AppRoutes.connectionRequests);
        break;
      case 'request_accepted':
        // Navigate to home screen to see connections
        Navigator.pushNamed(context, AppRoutes.customerHome);
        break;
      case 'request_rejected':
        // Navigate to connection requests screen
        Navigator.pushNamed(context, AppRoutes.connectionRequests);
        break;
      default:
        // Navigate to notifications screen
        Navigator.pushNamed(context, AppRoutes.notifications);
    }
  }

  // Get navigator context
  static BuildContext? _getNavigatorContext() {
    return NavigationService.navigatorKey.currentContext;
  }

  // Encode payload for local notifications
  static String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  // Decode payload from local notifications
  static Map<String, dynamic> _decodePayload(String payload) {
    final Map<String, dynamic> data = {};
    for (String pair in payload.split('&')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        data[parts[0]] = parts[1];
      }
    }
    return data;
  }
}

// Navigation service to handle global navigation
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('\n🔔 ===== BACKGROUND MESSAGE RECEIVED =====');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
  print('==========================================\n');
}
