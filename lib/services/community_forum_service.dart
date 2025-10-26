import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Service for managing community forum integration
/// 
/// Supports:
/// - Discourse forums
/// - Custom forum URLs
/// - WebView integration
/// - Single Sign-On (SSO)
/// 
/// To enable:
/// 1. Set up Discourse forum at https://www.discourse.org
/// 2. Configure SSO on your forum
/// 3. Update forumUrl below
/// 4. Test authentication flow
class CommunityForumService {
  static final CommunityForumService _instance = CommunityForumService._internal();
  factory CommunityForumService() => _instance;
  CommunityForumService._internal();

  // Forum configuration
  String _forumUrl = 'https://forum.lgbtinder.com'; // Update with your forum URL
  String _ssoSecret = ''; // Set from environment variable
  bool _isConfigured = false;

  /// Initialize forum service
  Future<void> initialize({
    required String forumUrl,
    String? ssoSecret,
  }) async {
    _forumUrl = forumUrl;
    _ssoSecret = ssoSecret ?? '';
    _isConfigured = forumUrl.isNotEmpty;

    if (_isConfigured) {
      debugPrint('✅ Community Forum Service initialized: $_forumUrl');
    } else {
      debugPrint('⚠️ Forum URL not configured');
    }
  }

  /// Get forum URL
  String get forumUrl => _forumUrl;

  /// Check if forum is configured
  bool get isConfigured => _isConfigured;

  /// Generate SSO payload for Discourse
  /// 
  /// Discourse requires:
  /// 1. nonce - provided by Discourse
  /// 2. payload - Base64 encoded user data
  /// 3. signature - HMAC-SHA256 of payload
  String generateSSOPayload({
    required String nonce,
    required String email,
    required String userId,
    required String username,
    String? name,
    String? avatarUrl,
  }) {
    // TODO: Implement proper SSO payload generation
    // This requires crypto package and proper HMAC-SHA256 implementation
    
    // Example payload structure:
    // nonce=NONCE&email=USER_EMAIL&external_id=USER_ID&username=USERNAME&name=FULL_NAME&avatar_url=AVATAR_URL
    
    final payload = 'nonce=$nonce'
        '&email=$email'
        '&external_id=$userId'
        '&username=$username'
        '${name != null ? '&name=$name' : ''}'
        '${avatarUrl != null ? '&avatar_url=$avatarUrl' : ''}';

    // In production, you should:
    // 1. Base64 encode the payload
    // 2. Generate HMAC-SHA256 signature
    // 3. URL encode the result
    
    debugPrint('📝 SSO Payload generated (not implemented)');
    return payload;
  }

  /// Get forum URL with authentication
  String getAuthenticatedForumUrl({
    required String email,
    required String userId,
    required String username,
    String? name,
    String? avatarUrl,
  }) {
    if (!_isConfigured) {
      return _forumUrl;
    }

    // For Discourse SSO, you need to:
    // 1. Get SSO request from forum
    // 2. Parse nonce
    // 3. Generate signed payload
    // 4. Return to forum with payload

    // For now, return basic forum URL
    // In production, implement proper SSO flow
    return _forumUrl;
  }

  /// Open forum in WebView
  /// Returns a Widget that can be displayed in the app
  Widget buildForumWebView({
    String? userId,
    String? userEmail,
    String? username,
  }) {
    if (!_isConfigured) {
      return _buildErrorWidget('Forum not configured');
    }

    return WebViewWidget(
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('Forum loading: $progress%');
            },
            onPageStarted: (String url) {
              debugPrint('Forum page started: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Forum page finished: $url');
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('Forum error: ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              // Handle external links
              if (request.url.startsWith('http') && 
                  !request.url.contains(_forumUrl)) {
                // Open external links in browser
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(_forumUrl)),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Forum coming soon!',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Create new topic in forum
  /// This would typically open a deep link or WebView to the new topic page
  String getNewTopicUrl({
    String? category,
    String? title,
    String? body,
  }) {
    if (!_isConfigured) return '';

    var url = '$_forumUrl/new-topic';
    
    if (category != null) {
      url += '?category=$category';
    }
    if (title != null) {
      url += '${category != null ? '&' : '?'}title=${Uri.encodeComponent(title)}';
    }
    if (body != null) {
      url += '&body=${Uri.encodeComponent(body)}';
    }

    return url;
  }

  /// Get category URL
  String getCategoryUrl(String categorySlug) {
    return '$_forumUrl/c/$categorySlug';
  }

  /// Get topic URL
  String getTopicUrl(int topicId) {
    return '$_forumUrl/t/$topicId';
  }

  /// Get user profile URL
  String getUserProfileUrl(String username) {
    return '$_forumUrl/u/$username';
  }

  /// Check if forum is reachable
  Future<bool> checkForumAvailability() async {
    if (!_isConfigured) return false;

    try {
      // In production, ping the forum to check availability
      // For now, return true if URL is configured
      return true;
    } catch (e) {
      debugPrint('⚠️ Forum unavailable: $e');
      return false;
    }
  }
}

/// Forum configuration class
class ForumConfig {
  final String forumUrl;
  final String? ssoSecret;
  final String? apiKey;

  const ForumConfig({
    required this.forumUrl,
    this.ssoSecret,
    this.apiKey,
  });

  /// Create from environment variables
  factory ForumConfig.fromEnvironment() {
    const forumUrl = String.fromEnvironment(
      'FORUM_URL',
      defaultValue: 'https://forum.lgbtinder.com',
    );
    const ssoSecret = String.fromEnvironment(
      'FORUM_SSO_SECRET',
      defaultValue: '',
    );
    const apiKey = String.fromEnvironment(
      'FORUM_API_KEY',
      defaultValue: '',
    );

    return ForumConfig(
      forumUrl: forumUrl,
      ssoSecret: ssoSecret.isEmpty ? null : ssoSecret,
      apiKey: apiKey.isEmpty ? null : apiKey,
    );
  }
}

/// Pre-defined forum categories for LGBTinder
class ForumCategories {
  static const String general = 'general';
  static const String introductions = 'introductions';
  static const String datingAdvice = 'dating-advice';
  static const String success = 'success-stories';
  static const String feedback = 'feedback';
  static const String support = 'support';
  static const String lgbtq = 'lgbtq-topics';
  static const String events = 'events';
  static const String offtopic = 'off-topic';
}

