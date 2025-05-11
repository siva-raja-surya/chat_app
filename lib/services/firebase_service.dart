import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chat_app/services/notification_service.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static String? _currentFcmToken;
  static String? get currentFcmToken => _currentFcmToken;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    print('Notification permission status: ${settings.authorizationStatus}');
    
    // Get and handle FCM token
    await _setupFcmTokenHandling();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Set up message handlers
    _setupMessageHandlers();
  }

  static Future<void> _setupFcmTokenHandling() async {
    // Get initial token
    _currentFcmToken = await _firebaseMessaging.getToken();
    print("Initial FCM Token: $_currentFcmToken");
    
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _currentFcmToken = newToken;
      print("Refreshed FCM Token: $newToken");
      // TODO: Send the new token to your server
      // _sendTokenToServer(newToken);
    });
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );
  }

  static void _setupMessageHandlers() {
    // Background message handler (must be top-level or static with @pragma)
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
    
    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // When app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print("Foreground message received: ${message.messageId}");
    await _showNotificationFromMessage(message);
    
    // TODO: Add your logic to update chat UI if needed
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
    print("Background message received: ${message.messageId}");
    await _showNotificationFromMessage(message);
    
    // TODO: Add your logic to handle background message (e.g., save to local DB)
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print("App opened from message: ${message.messageId}");
    // TODO: Add navigation to specific chat screen
  }

  static Future<void> _showNotificationFromMessage(RemoteMessage message) async {
    // Extract data from both notification and data payloads
    final title = message.notification?.title ?? 'New message';
    final body = message.notification?.body ?? message.data['content'] ?? '';
    
    await NotificationService.showNotification(
      title: title,
      body: body,
      // payload: jsonEncode(message.data), // Pass entire data payload
    );
  }

  // Call this when user logs in to register token with server
  static Future<void> registerTokenWithServer(String userId) async {
    if (_currentFcmToken == null) {
      await _setupFcmTokenHandling();
    }
    
    if (_currentFcmToken != null) {
      print("Registering FCM token with server for user $userId");
      // TODO: Implement API call to your server
      // await _sendTokenToServer(userId, _currentFcmToken!);
    }
  }

  // Call this when user logs out to unregister token
  static Future<void> unregisterTokenFromServer(String userId) async {
    print("Unregistering FCM token for user $userId");
    // TODO: Implement API call to your server
    // await _removeTokenFromServer(userId, _currentFcmToken);
  }
}