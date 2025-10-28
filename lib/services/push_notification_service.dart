import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Push Notification Service
/// 
/// Handles all push notifications:
/// - Foreground notifications
/// - Background notifications
/// - Notification tap handling
/// - Custom notification channels
/// - Rich notifications (images, actions)
/// - Deep linking from notifications
class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Stream controllers
  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _notificationTapStreamController =
      StreamController<String>.broadcast();

  // Public streams
  Stream<RemoteMessage> get messageStream => _messageStreamController.stream;
  Stream<String> get notificationTapStream =>
      _notificationTapStreamController.stream;

  String? _fcmToken;
  bool _isInitialized = false;

  /// Initialize push notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint('FCM Token refreshed: $token');
        // TODO: Send token to backend
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      debugPrint('Push Notification Service initialized');
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('Notification permission status: ${settings.authorizationStatus}');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS notification tap
        if (payload != null) {
          _notificationTapStreamController.add(payload);
        }
      },
    );

    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          _notificationTapStreamController.add(response.payload!);
        }
      },
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create notification channels
  Future<void> _createNotificationChannels() async {
    // Match notification channel
    const matchChannel = AndroidNotificationChannel(
      'matches',
      'Matches',
      description: 'Notifications for new matches',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );

    // Message notification channel
    const messageChannel = AndroidNotificationChannel(
      'messages',
      'Messages',
      description: 'Notifications for new messages',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );

    // Like notification channel
    const likeChannel = AndroidNotificationChannel(
      'likes',
      'Likes',
      description: 'Notifications for likes and superlikes',
      importance: Importance.defaultImportance,
      playSound: true,
      showBadge: true,
    );

    // Call notification channel
    const callChannel = AndroidNotificationChannel(
      'calls',
      'Calls',
      description: 'Notifications for incoming calls',
      importance: Importance.max,
      playSound: true,
      showBadge: true,
      enableVibration: true,
    );

    // General notification channel
    const generalChannel = AndroidNotificationChannel(
      'general',
      'General',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
      playSound: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(matchChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(messageChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(likeChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(callChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);

    debugPrint('Notification channels created');
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    
    _messageStreamController.add(message);

    // Show local notification for foreground messages
    _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final ios = message.notification?.apple;

    if (notification != null) {
      // Determine channel based on message data
      final channelId = _getChannelId(message.data['type']);
      
      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(channelId),
        channelDescription: _getChannelDescription(channelId),
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        styleInformation: _getNotificationStyle(message),
        actions: _getNotificationActions(message),
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: json.encode(message.data),
      );
    }
  }

  /// Get notification channel ID based on type
  String _getChannelId(String? type) {
    switch (type) {
      case 'match':
        return 'matches';
      case 'message':
        return 'messages';
      case 'like':
      case 'superlike':
        return 'likes';
      case 'call':
        return 'calls';
      default:
        return 'general';
    }
  }

  /// Get channel name
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'matches':
        return 'Matches';
      case 'messages':
        return 'Messages';
      case 'likes':
        return 'Likes';
      case 'calls':
        return 'Calls';
      default:
        return 'General';
    }
  }

  /// Get channel description
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'matches':
        return 'Notifications for new matches';
      case 'messages':
        return 'Notifications for new messages';
      case 'likes':
        return 'Notifications for likes and superlikes';
      case 'calls':
        return 'Notifications for incoming calls';
      default:
        return 'General app notifications';
    }
  }

  /// Get notification style (big picture, big text, etc.)
  StyleInformation? _getNotificationStyle(RemoteMessage message) {
    final imageUrl = message.data['image_url'];
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return BigPictureStyleInformation(
        FilePathAndroidBitmap(imageUrl),
        largeIcon: FilePathAndroidBitmap(imageUrl),
        contentTitle: message.notification?.title,
        summaryText: message.notification?.body,
      );
    } else if (message.notification?.body != null) {
      return BigTextStyleInformation(
        message.notification!.body!,
        contentTitle: message.notification?.title,
      );
    }
    
    return null;
  }

  /// Get notification actions
  List<AndroidNotificationAction>? _getNotificationActions(
      RemoteMessage message) {
    final type = message.data['type'];

    switch (type) {
      case 'message':
        return [
          const AndroidNotificationAction(
            'reply',
            'Reply',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'mark_read',
            'Mark as Read',
          ),
        ];
      case 'match':
        return [
          const AndroidNotificationAction(
            'chat',
            'Say Hi',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'view_profile',
            'View Profile',
            showsUserInterface: true,
          ),
        ];
      case 'call':
        return [
          const AndroidNotificationAction(
            'answer',
            'Answer',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'decline',
            'Decline',
          ),
        ];
      default:
        return null;
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    
    final payload = json.encode(message.data);
    _notificationTapStreamController.add(payload);
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Dispose service
  void dispose() {
    _messageStreamController.close();
    _notificationTapStreamController.close();
    debugPrint('Push Notification Service disposed');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  // Handle background message
}

