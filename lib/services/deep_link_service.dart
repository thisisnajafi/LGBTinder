import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Deep Link Service
/// 
/// Handles deep linking for the LGBTinder app.
/// Supports both custom scheme (lgbtinder://) and universal links (https://lgbtinder.com)
/// 
/// Supported deep link routes:
/// - lgbtinder://discovery - Open discovery page
/// - lgbtinder://profile/{user_id} - Open specific user profile
/// - lgbtinder://match/{match_id} - Open match celebration
/// - lgbtinder://discovery/filters - Open filter screen
/// - lgbtinder://discovery/likes - Open likes received (premium)
/// - lgbtinder://chat - Open chat list
/// - lgbtinder://chat/{user_id} - Open specific chat
/// - lgbtinder://chat/{user_id}/message/{message_id} - Scroll to specific message
/// - lgbtinder://stories - Open stories feed
/// - lgbtinder://stories/{user_id} - View user's stories
/// - lgbtinder://feed - Open social feed
/// - lgbtinder://feed/post/{post_id} - View specific post
/// - lgbtinder://premium - Open premium plans
/// - lgbtinder://settings - Open settings
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static const MethodChannel _channel = MethodChannel('lgbtinder/deeplink');
  
  final StreamController<Uri> _deepLinkController = StreamController<Uri>.broadcast();
  Stream<Uri> get deepLinkStream => _deepLinkController.stream;

  String? _pendingDeepLink;
  bool _isInitialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initialize the deep link service
  Future<void> initialize({required GlobalKey<NavigatorState> navigatorKey}) async {
    if (_isInitialized) return;
    
    _navigatorKey = navigatorKey;
    _isInitialized = true;

    // Handle incoming deep links
    _channel.setMethodCallHandler(_handleMethod);

    // Get initial deep link (app opened from deep link)
    try {
      final String? initialLink = await _channel.invokeMethod('getInitialLink');
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }
  }

  /// Handle method calls from platform
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onDeepLink':
        final String link = call.arguments as String;
        _handleDeepLink(link);
        break;
      default:
        throw MissingPluginException('Not implemented: ${call.method}');
    }
  }

  /// Handle deep link URL
  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      _deepLinkController.add(uri);

      if (_navigatorKey?.currentContext != null) {
        navigateFromDeepLink(uri);
      } else {
        // Store pending deep link if navigator is not ready
        _pendingDeepLink = link;
      }
    } catch (e) {
      debugPrint('Error parsing deep link: $e');
    }
  }

  /// Process pending deep link if any
  void processPendingDeepLink() {
    if (_pendingDeepLink != null) {
      final link = _pendingDeepLink!;
      _pendingDeepLink = null;
      _handleDeepLink(link);
    }
  }

  /// Navigate based on deep link URI
  Future<void> navigateFromDeepLink(Uri uri) async {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('Navigator context not available');
      return;
    }

    // Extract path segments
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) {
      debugPrint('Empty path segments in deep link');
      return;
    }

    final route = pathSegments[0];

    try {
      switch (route) {
        case 'discovery':
          await _handleDiscoveryRoute(context, pathSegments, uri.queryParameters);
          break;
        
        case 'profile':
          if (pathSegments.length > 1) {
            await _handleProfileRoute(context, pathSegments[1]);
          }
          break;
        
        case 'match':
          if (pathSegments.length > 1) {
            await _handleMatchRoute(context, pathSegments[1]);
          }
          break;
        
        case 'chat':
          await _handleChatRoute(context, pathSegments);
          break;
        
        case 'stories':
          await _handleStoriesRoute(context, pathSegments);
          break;
        
        case 'feed':
          await _handleFeedRoute(context, pathSegments);
          break;
        
        case 'premium':
          await _handlePremiumRoute(context, pathSegments);
          break;
        
        case 'settings':
          await _handleSettingsRoute(context, pathSegments);
          break;
        
        case 'call':
          await _handleCallRoute(context, pathSegments);
          break;
        
        case 'safety':
          await _handleSafetyRoute(context, pathSegments);
          break;
        
        default:
          debugPrint('Unknown deep link route: $route');
      }
    } catch (e) {
      debugPrint('Error navigating from deep link: $e');
    }
  }

  /// Handle discovery routes
  Future<void> _handleDiscoveryRoute(
    BuildContext context,
    List<String> pathSegments,
    Map<String, String> queryParams,
  ) async {
    if (pathSegments.length == 1) {
      // lgbtinder://discovery
      Navigator.pushNamed(context, '/discovery');
    } else if (pathSegments.length > 1) {
      final subRoute = pathSegments[1];
      
      if (subRoute == 'filters') {
        // lgbtinder://discovery/filters
        // Navigate to discovery with filters open
        Navigator.pushNamed(context, '/discovery', arguments: {'openFilters': true});
      } else if (subRoute == 'likes') {
        // lgbtinder://discovery/likes (premium feature)
        Navigator.pushNamed(context, '/discovery', arguments: {'openLikesReceived': true});
      }
    }
  }

  /// Handle profile routes
  Future<void> _handleProfileRoute(BuildContext context, String userId) async {
    // lgbtinder://profile/{user_id}
    Navigator.pushNamed(
      context,
      '/profile-detail',
      arguments: {'userId': userId},
    );
  }

  /// Handle match routes
  Future<void> _handleMatchRoute(BuildContext context, String matchId) async {
    // lgbtinder://match/{match_id}
    Navigator.pushNamed(
      context,
      '/match-celebration',
      arguments: {'matchId': matchId},
    );
  }

  /// Handle chat routes
  Future<void> _handleChatRoute(BuildContext context, List<String> pathSegments) async {
    if (pathSegments.length == 1) {
      // lgbtinder://chat
      Navigator.pushNamed(context, '/chat');
    } else if (pathSegments.length >= 2) {
      final userId = pathSegments[1];
      
      if (pathSegments.length > 2 && pathSegments[2] == 'message' && pathSegments.length > 3) {
        // lgbtinder://chat/{user_id}/message/{message_id}
        final messageId = pathSegments[3];
        Navigator.pushNamed(
          context,
          '/chat-detail',
          arguments: {
            'userId': userId,
            'scrollToMessageId': messageId,
          },
        );
      } else {
        // lgbtinder://chat/{user_id}
        Navigator.pushNamed(
          context,
          '/chat-detail',
          arguments: {'userId': userId},
        );
      }
    }
  }

  /// Handle stories routes
  Future<void> _handleStoriesRoute(BuildContext context, List<String> pathSegments) async {
    if (pathSegments.length == 1) {
      // lgbtinder://stories
      Navigator.pushNamed(context, '/stories');
    } else if (pathSegments.length > 1) {
      final userIdOrStoryId = pathSegments[1];
      // lgbtinder://stories/{user_id} or lgbtinder://stories/{story_id}
      Navigator.pushNamed(
        context,
        '/story-viewer',
        arguments: {'id': userIdOrStoryId},
      );
    }
  }

  /// Handle feed routes
  Future<void> _handleFeedRoute(BuildContext context, List<String> pathSegments) async {
    if (pathSegments.length == 1) {
      // lgbtinder://feed
      Navigator.pushNamed(context, '/feed');
    } else if (pathSegments.length > 1) {
      final subRoute = pathSegments[1];
      
      if (subRoute == 'post' && pathSegments.length > 2) {
        // lgbtinder://feed/post/{post_id}
        final postId = pathSegments[2];
        Navigator.pushNamed(
          context,
          '/post-detail',
          arguments: {'postId': postId},
        );
      } else if (subRoute == 'user' && pathSegments.length > 2) {
        // lgbtinder://feed/user/{user_id}
        final userId = pathSegments[2];
        Navigator.pushNamed(
          context,
          '/user-posts',
          arguments: {'userId': userId},
        );
      } else if (subRoute == 'create') {
        // lgbtinder://feed/create
        Navigator.pushNamed(context, '/create-post');
      }
    }
  }

  /// Handle premium routes
  Future<void> _handlePremiumRoute(BuildContext context, List<String> pathSegments) async {
    if (pathSegments.length == 1) {
      // lgbtinder://premium
      Navigator.pushNamed(context, '/premium-features');
    } else if (pathSegments.length > 1) {
      final subRoute = pathSegments[1];
      
      if (subRoute == 'plans') {
        // lgbtinder://premium/plans
        Navigator.pushNamed(context, '/premium-features');
      } else if (subRoute == 'subscribe' && pathSegments.length > 2) {
        // lgbtinder://premium/subscribe/{plan_id}
        final planId = pathSegments[2];
        Navigator.pushNamed(
          context,
          '/subscription-management',
          arguments: {'planId': planId, 'action': 'subscribe'},
        );
      } else if (subRoute == 'manage') {
        // lgbtinder://premium/manage
        Navigator.pushNamed(context, '/subscription-management');
      } else if (subRoute == 'superlikes') {
        // lgbtinder://premium/superlikes
        Navigator.pushNamed(context, '/superlike-packs');
      }
    }
  }

  /// Handle settings routes
  Future<void> _handleSettingsRoute(BuildContext context, List<String> pathSegments) async {
    if (pathSegments.length == 1) {
      // lgbtinder://settings
      Navigator.pushNamed(context, '/settings');
    } else if (pathSegments.length > 1) {
      final subRoute = pathSegments[1];
      
      if (subRoute == 'account') {
        Navigator.pushNamed(context, '/settings', arguments: {'tab': 'account'});
      } else if (subRoute == 'privacy') {
        Navigator.pushNamed(context, '/privacy-settings');
      } else if (subRoute == 'notifications') {
        Navigator.pushNamed(context, '/notification-settings');
      } else if (subRoute == 'help') {
        Navigator.pushNamed(context, '/help-support');
      }
    }
  }

  /// Handle call routes
  Future<void> _handleCallRoute(BuildContext context, List<String> pathSegments) async {
    if (pathSegments.length > 1) {
      final callType = pathSegments[1];
      
      if (callType == 'video' && pathSegments.length > 2) {
        // lgbtinder://call/video/{user_id}
        final userId = pathSegments[2];
        Navigator.pushNamed(
          context,
          '/video-call',
          arguments: {'userId': userId, 'isIncoming': false},
        );
      } else if (callType == 'voice' && pathSegments.length > 2) {
        // lgbtinder://call/voice/{user_id}
        final userId = pathSegments[2];
        Navigator.pushNamed(
          context,
          '/voice-call',
          arguments: {'userId': userId, 'isIncoming': false},
        );
      } else if (callType == 'incoming' && pathSegments.length > 2) {
        // lgbtinder://call/incoming/{call_id}
        final callId = pathSegments[2];
        Navigator.pushNamed(
          context,
          '/incoming-call',
          arguments: {'callId': callId},
        );
      } else if (callType == 'history') {
        // lgbtinder://call/history
        Navigator.pushNamed(context, '/call-history');
      }
    }
  }

  /// Handle safety routes
  Future<void> _handleSafetyRoute(BuildContext context, List<String> pathSegments) async {
    if (pathSegments.length == 1) {
      // lgbtinder://safety
      Navigator.pushNamed(context, '/safety-settings');
    } else if (pathSegments.length > 1) {
      final subRoute = pathSegments[1];
      
      if (subRoute == 'report') {
        Navigator.pushNamed(context, '/report');
      } else if (subRoute == 'blocked') {
        Navigator.pushNamed(context, '/blocked-users');
      } else if (subRoute == 'emergency') {
        Navigator.pushNamed(context, '/emergency-contacts');
      } else if (subRoute == 'verify') {
        Navigator.pushNamed(context, '/profile-verification');
      }
    }
  }

  /// Dispose the service
  void dispose() {
    _deepLinkController.close();
  }
}

/// Deep link helper methods
class DeepLinkHelper {
  /// Create a deep link URL for a user profile
  static String profileLink(String userId) => 'lgbtinder://profile/$userId';

  /// Create a deep link URL for a match
  static String matchLink(String matchId) => 'lgbtinder://match/$matchId';

  /// Create a deep link URL for a chat
  static String chatLink(String userId) => 'lgbtinder://chat/$userId';

  /// Create a deep link URL for a specific message
  static String messageLink(String userId, String messageId) =>
      'lgbtinder://chat/$userId/message/$messageId';

  /// Create a deep link URL for stories
  static String storiesLink([String? userId]) =>
      userId != null ? 'lgbtinder://stories/$userId' : 'lgbtinder://stories';

  /// Create a deep link URL for a post
  static String postLink(String postId) => 'lgbtinder://feed/post/$postId';

  /// Create a deep link URL for discovery
  static String discoveryLink() => 'lgbtinder://discovery';

  /// Create a deep link URL for premium plans
  static String premiumLink() => 'lgbtinder://premium';

  /// Parse deep link and extract parameters
  static Map<String, dynamic> parseDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      return {
        'scheme': uri.scheme,
        'host': uri.host,
        'path': uri.path,
        'pathSegments': uri.pathSegments,
        'queryParameters': uri.queryParameters,
      };
    } catch (e) {
      return {};
    }
  }

  /// Check if a string is a valid deep link
  static bool isValidDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      return uri.scheme == 'lgbtinder' || 
             (uri.scheme == 'https' && uri.host == 'lgbtinder.com');
    } catch (e) {
      return false;
    }
  }
}

