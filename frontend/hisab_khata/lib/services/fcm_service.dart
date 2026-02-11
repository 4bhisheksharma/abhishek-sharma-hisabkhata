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
  static bool _isInitialized = false;
  static bool _listenersAttached = false;

  /// Initialize FCM service.
  /// Call this after login or when restoring an authenticated session.
  static Future<void> initialize({String? authToken}) async {
    _authToken = authToken;
    _baseUrl = ApiBaseUrl.baseUrl;

    debugPrint('\n===== INITIALIZING FCM SERVICE =====');
    debugPrint('Auth Token: ${authToken != null ? "Present" : "Missing"}');
    debugPrint('Base URL: $_baseUrl');

    try {
      // Request Firebase notification permissions
      debugPrint('Requesting notification permissions...');
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

      debugPrint('Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        _fcmToken = await _firebaseMessaging.getToken();
        debugPrint('FCM Token: $_fcmToken');

        // Send token to backend (always send on init to keep it fresh)
        if (_fcmToken != null && _authToken != null) {
          await _sendTokenToServer(_fcmToken!);
        }

        // Only attach listeners once to avoid duplicate callbacks
        if (!_listenersAttached) {
          _listenersAttached = true;

          // Listen to token refresh
          _firebaseMessaging.onTokenRefresh.listen((token) {
            _fcmToken = token;
            debugPrint('FCM Token refreshed: $token');
            _sendTokenToServer(token);
          });

          // Handle foreground messages
          FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

          // Handle message when app is opened from background
          FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        }

        // Handle initial message (when app is opened from terminated state)
        // Use a small delay to ensure navigator is ready
        RemoteMessage? initialMessage = await _firebaseMessaging
            .getInitialMessage();
        if (initialMessage != null) {
          // Delay navigation to ensure app is fully built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleNotificationTap(initialMessage);
          });
        }

        _isInitialized = true;
        debugPrint('FCM initialized successfully');
      } else {
        debugPrint('FCM permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  /// Whether FCM service has been initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize local notifications plugin and create Android channel
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

  /// Send FCM token to backend server
  static Future<void> _sendTokenToServer(String token) async {
    if (_authToken == null || _baseUrl == null) {
      debugPrint(
        'No auth token or base URL available, skipping FCM token upload',
      );
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
        debugPrint('FCM token sent to server successfully');
      } else {
        debugPrint(
          'Failed to send FCM token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }

  /// Clear FCM token on logout — removes from server and resets local state
  static Future<void> clearTokenOnLogout() async {
    // Try to clear from server if we have credentials
    if (_authToken != null && _baseUrl != null) {
      try {
        final response = await http.delete(
          Uri.parse('${_baseUrl}auth/fcm-token/'),
          headers: {'Authorization': 'Bearer $_authToken'},
        );

        if (response.statusCode == 200) {
          debugPrint('FCM token cleared from server successfully');
        } else {
          debugPrint('Failed to clear FCM token: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error clearing FCM token: $e');
      }
    }

    // Always clear local state regardless of server call success
    _fcmToken = null;
    _authToken = null;
    _isInitialized = false;
  }

  /// Update auth token (e.g., after token refresh)
  static void updateAuthToken(String? authToken) {
    _authToken = authToken;

    // If we already have an FCM token, re-send it with the new auth token
    if (authToken != null && _fcmToken != null) {
      _sendTokenToServer(_fcmToken!);
    }
  }

  /// Handle foreground messages — show a local notification
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('\n===== FOREGROUND MESSAGE RECEIVED =====');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
    debugPrint('========================================\n');

    // Show local notification (only in foreground since FCM doesn't auto-show)
    await _showLocalNotification(message);
  }

  /// Display a local notification from a RemoteMessage
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
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
      debugPrint('Local notification shown: ${notification.title}');
    }
  }

  /// Handle notification tap (when app is opened from background/terminated)
  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.notification?.title}');
    _navigateBasedOnType(message.data);
  }

  /// Handle local notification tap response
  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      final data = _decodePayload(response.payload!);
      _navigateBasedOnType(data);
    }
  }

  /// Navigate to appropriate screen based on notification type.
  /// Matches the `type` field sent from the backend's FirebaseService.
  static void _navigateBasedOnType(Map<String, dynamic> data) {
    final BuildContext? context = _getNavigatorContext();
    if (context == null) {
      debugPrint('Navigator context is null, cannot navigate');
      return;
    }

    final String? type = data['type'];
    debugPrint('Navigating for notification type: $type');

    switch (type) {
      case 'connection_request':
        Navigator.pushNamed(context, AppRoutes.connectionRequests);
        break;
      case 'request_accepted':
      case 'connection_request_accepted':
        Navigator.pushNamed(context, AppRoutes.customerHome);
        break;
      case 'request_rejected':
      case 'connection_request_rejected':
        Navigator.pushNamed(context, AppRoutes.connectionRequests);
        break;
      case 'connection_deleted':
        Navigator.pushNamed(context, AppRoutes.customerHome);
        break;
      default:
        Navigator.pushNamed(context, AppRoutes.notifications);
    }
  }

  /// Get navigator context from the global navigator key
  static BuildContext? _getNavigatorContext() {
    return NavigationService.navigatorKey.currentContext;
  }

  /// Encode notification data payload as JSON string (safe for special chars)
  static String _encodePayload(Map<String, dynamic> data) {
    try {
      return json.encode(data);
    } catch (e) {
      debugPrint('Error encoding payload: $e');
      return '{}';
    }
  }

  /// Decode notification data payload from JSON string
  static Map<String, dynamic> _decodePayload(String payload) {
    try {
      final decoded = json.decode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      debugPrint('Error decoding payload: $e');
      return {};
    }
  }
}

/// Navigation service to handle global navigation via a GlobalKey
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

/// Background message handler (must be top-level function).
/// NOTE: When the app is in background and a message with a `notification` payload
/// arrives, FCM automatically shows a system notification. We do NOT show a
/// duplicate local notification here. This handler is only for data processing.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('\n===== BACKGROUND MESSAGE RECEIVED =====');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
  debugPrint('==========================================\n');

  // FCM automatically displays the notification when the app is in background
  // and the message contains a `notification` payload. No need to show a
  // duplicate local notification here. This handler is for data-only processing.
}
