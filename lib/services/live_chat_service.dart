import 'package:flutter/foundation.dart';

/// Service for managing live chat support (Intercom/Zendesk)
/// 
/// To enable:
/// 1. Add intercom_flutter or zendesk_messaging packages to pubspec.yaml
/// 2. Configure API keys in environment variables
/// 3. Uncomment implementation code below
/// 4. Update help_support_screen.dart to use this service
class LiveChatService {
  static final LiveChatService _instance = LiveChatService._internal();
  factory LiveChatService() => _instance;
  LiveChatService._internal();

  bool _isInitialized = false;
  String _provider = 'none'; // 'intercom', 'zendesk', or 'none'

  /// Initialize live chat service
  /// 
  /// Example for Intercom:
  /// ```dart
  /// await LiveChatService().initialize(
  ///   provider: 'intercom',
  ///   apiKey: 'YOUR_INTERCOM_APP_ID',
  /// );
  /// ```
  /// 
  /// Example for Zendesk:
  /// ```dart
  /// await LiveChatService().initialize(
  ///   provider: 'zendesk',
  ///   apiKey: 'YOUR_ZENDESK_ACCOUNT_KEY',
  /// );
  /// ```
  Future<void> initialize({
    required String provider,
    required String apiKey,
    String? androidApiKey,
    String? iosApiKey,
  }) async {
    try {
      _provider = provider.toLowerCase();
      
      switch (_provider) {
        case 'intercom':
          await _initializeIntercom(
            apiKey: apiKey,
            androidApiKey: androidApiKey,
            iosApiKey: iosApiKey,
          );
          break;
        case 'zendesk':
          await _initializeZendesk(
            apiKey: apiKey,
            androidApiKey: androidApiKey,
            iosApiKey: iosApiKey,
          );
          break;
        default:
          debugPrint('⚠️ Unknown chat provider: $provider');
          return;
      }
      
      _isInitialized = true;
      debugPrint('✅ Live Chat Service initialized: $_provider');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize Live Chat: $e');
      _isInitialized = false;
    }
  }

  /// Initialize Intercom
  Future<void> _initializeIntercom({
    required String apiKey,
    String? androidApiKey,
    String? iosApiKey,
  }) async {
    // TODO: Uncomment when intercom_flutter package is added
    
    // import 'package:intercom_flutter/intercom_flutter.dart';
    
    // await Intercom.instance.initialize(
    //   apiKey,
    //   iosApiKey: iosApiKey ?? apiKey,
    //   androidApiKey: androidApiKey ?? apiKey,
    // );
    
    debugPrint('📞 Intercom would be initialized here (package not installed)');
  }

  /// Initialize Zendesk
  Future<void> _initializeZendesk({
    required String apiKey,
    String? androidApiKey,
    String? iosApiKey,
  }) async {
    // TODO: Uncomment when zendesk_messaging package is added
    
    // import 'package:zendesk_messaging/zendesk_messaging.dart';
    
    // await ZendeskMessaging.initialize(
    //   channelKey: apiKey,
    // );
    
    debugPrint('📞 Zendesk would be initialized here (package not installed)');
  }

  /// Open live chat window
  Future<void> openChat() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Live chat not initialized');
      return;
    }

    try {
      switch (_provider) {
        case 'intercom':
          await _openIntercom();
          break;
        case 'zendesk':
          await _openZendesk();
          break;
        default:
          debugPrint('⚠️ No chat provider configured');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to open chat: $e');
    }
  }

  /// Open Intercom messenger
  Future<void> _openIntercom() async {
    // TODO: Uncomment when intercom_flutter package is added
    // await Intercom.instance.displayMessenger();
    debugPrint('📱 Intercom chat would open here');
  }

  /// Open Zendesk messaging
  Future<void> _openZendesk() async {
    // TODO: Uncomment when zendesk_messaging package is added
    // await ZendeskMessaging.show();
    debugPrint('📱 Zendesk chat would open here');
  }

  /// Register user with live chat
  Future<void> registerUser({
    required String userId,
    required String email,
    String? name,
    Map<String, dynamic>? customAttributes,
  }) async {
    if (!_isInitialized) return;

    try {
      switch (_provider) {
        case 'intercom':
          await _registerIntercomUser(
            userId: userId,
            email: email,
            name: name,
            customAttributes: customAttributes,
          );
          break;
        case 'zendesk':
          await _registerZendeskUser(
            userId: userId,
            email: email,
            name: name,
            customAttributes: customAttributes,
          );
          break;
      }
      debugPrint('✅ User registered with live chat: $email');
    } catch (e) {
      debugPrint('⚠️ Failed to register user: $e');
    }
  }

  /// Register user with Intercom
  Future<void> _registerIntercomUser({
    required String userId,
    required String email,
    String? name,
    Map<String, dynamic>? customAttributes,
  }) async {
    // TODO: Uncomment when intercom_flutter package is added
    // await Intercom.instance.loginIdentifiedUser(
    //   userId: userId,
    //   email: email,
    //   name: name,
    // );
    // 
    // if (customAttributes != null) {
    //   await Intercom.instance.updateUser(
    //     customAttributes: customAttributes,
    //   );
    // }
  }

  /// Register user with Zendesk
  Future<void> _registerZendeskUser({
    required String userId,
    required String email,
    String? name,
    Map<String, dynamic>? customAttributes,
  }) async {
    // TODO: Uncomment when zendesk_messaging package is added
    // await ZendeskMessaging.loginUser(
    //   jwt: generateJWT(userId, email), // You'll need to implement JWT generation
    // );
  }

  /// Logout user from live chat
  Future<void> logoutUser() async {
    if (!_isInitialized) return;

    try {
      switch (_provider) {
        case 'intercom':
          // await Intercom.instance.logout();
          break;
        case 'zendesk':
          // await ZendeskMessaging.logoutUser();
          break;
      }
      debugPrint('✅ User logged out from live chat');
    } catch (e) {
      debugPrint('⚠️ Failed to logout: $e');
    }
  }

  /// Send custom event to live chat
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) return;

    try {
      switch (_provider) {
        case 'intercom':
          // await Intercom.instance.logEvent(eventName, metadata);
          break;
        case 'zendesk':
          // Zendesk doesn't have direct event logging
          break;
      }
      debugPrint('📊 Event logged: $eventName');
    } catch (e) {
      debugPrint('⚠️ Failed to log event: $e');
    }
  }

  /// Get unread message count
  Future<int> getUnreadCount() async {
    if (!_isInitialized) return 0;

    try {
      switch (_provider) {
        case 'intercom':
          // return await Intercom.instance.unreadConversationCount();
          return 0;
        case 'zendesk':
          // return await ZendeskMessaging.getUnreadMessageCount();
          return 0;
        default:
          return 0;
      }
    } catch (e) {
      debugPrint('⚠️ Failed to get unread count: $e');
      return 0;
    }
  }

  /// Check if chat is available
  bool get isAvailable => _isInitialized;

  /// Get current provider name
  String get provider => _provider;
}

/// Configuration class for live chat
class LiveChatConfig {
  final String provider; // 'intercom' or 'zendesk'
  final String apiKey;
  final String? androidApiKey;
  final String? iosApiKey;

  const LiveChatConfig({
    required this.provider,
    required this.apiKey,
    this.androidApiKey,
    this.iosApiKey,
  });

  /// Create from environment variables
  factory LiveChatConfig.fromEnvironment() {
    const provider = String.fromEnvironment(
      'CHAT_PROVIDER',
      defaultValue: 'none',
    );
    const apiKey = String.fromEnvironment(
      'CHAT_API_KEY',
      defaultValue: '',
    );
    const androidApiKey = String.fromEnvironment(
      'CHAT_ANDROID_API_KEY',
      defaultValue: '',
    );
    const iosApiKey = String.fromEnvironment(
      'CHAT_IOS_API_KEY',
      defaultValue: '',
    );

    return LiveChatConfig(
      provider: provider,
      apiKey: apiKey,
      androidApiKey: androidApiKey.isEmpty ? null : androidApiKey,
      iosApiKey: iosApiKey.isEmpty ? null : iosApiKey,
    );
  }
}

