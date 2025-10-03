import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_models/common_models.dart';

/// Rate Limiting Service
/// 
/// This service handles rate limiting for API requests, including:
/// - Tracking request counts per endpoint
/// - Implementing exponential backoff
/// - Managing rate limit headers
/// - Providing retry mechanisms
class RateLimitingService {
  static final Map<String, List<DateTime>> _requestHistory = {};
  static final Map<String, int> _rateLimits = {
    'auth': 10, // 10 requests per minute for auth endpoints
    'likes': 30, // 30 requests per minute for like endpoints
    'default': 60, // 60 requests per minute for other endpoints
  };
  
  static const int _windowSizeMinutes = 1;
  static const int _maxRetries = 3;
  static const int _baseDelayMs = 1000;

  // ============================================================================
  // RATE LIMIT TRACKING
  // ============================================================================

  /// Get rate limit for endpoint category
  static int getRateLimit(String endpointCategory) {
    return _rateLimits[endpointCategory] ?? _rateLimits['default']!;
  }

  /// Check if request is within rate limit
  static bool isWithinRateLimit(String endpointCategory) {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(minutes: _windowSizeMinutes));
    
    // Get request history for this endpoint category
    final requests = _requestHistory[endpointCategory] ?? [];
    
    // Remove old requests outside the window
    requests.removeWhere((requestTime) => requestTime.isBefore(windowStart));
    
    // Update the request history
    _requestHistory[endpointCategory] = requests;
    
    // Check if we're within the rate limit
    return requests.length < getRateLimit(endpointCategory);
  }

  /// Record a request for rate limiting
  static void recordRequest(String endpointCategory) {
    final now = DateTime.now();
    final requests = _requestHistory[endpointCategory] ?? [];
    requests.add(now);
    _requestHistory[endpointCategory] = requests;
  }

  /// Check rate limit for endpoint category - async method that can block if needed
  static Future<void> checkRateLimit(String endpointCategory) async {
    if (!isWithinRateLimit(endpointCategory)) {
      final retryAfter = Duration(minutes: _windowSizeMinutes);
      await Future.delayed(retryAfter);
      recordRequest(endpointCategory);
    } else {
      recordRequest(endpointCategory);
    }
  }

  /// Get remaining requests for endpoint category
  static int getRemainingRequests(String endpointCategory) {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(minutes: _windowSizeMinutes));
    
    final requests = _requestHistory[endpointCategory] ?? [];
    final recentRequests = requests.where((requestTime) => 
        requestTime.isAfter(windowStart)).length;
    
    return getRateLimit(endpointCategory) - recentRequests;
  }

  /// Get time until rate limit resets
  static Duration getTimeUntilReset(String endpointCategory) {
    final now = DateTime.now();
    final requests = _requestHistory[endpointCategory] ?? [];
    
    if (requests.isEmpty) return Duration.zero;
    
    final oldestRequest = requests.reduce((a, b) => a.isBefore(b) ? a : b);
    final resetTime = oldestRequest.add(Duration(minutes: _windowSizeMinutes));
    
    if (resetTime.isAfter(now)) {
      return resetTime.difference(now);
    }
    
    return Duration.zero;
  }

  // ============================================================================
  // RATE LIMIT HEADERS
  // ============================================================================

  /// Parse rate limit headers from response
  static RateLimitInfo? parseRateLimitHeaders(http.Response response) {
    final limit = response.headers['x-ratelimit-limit'];
    final remaining = response.headers['x-ratelimit-remaining'];
    final reset = response.headers['x-ratelimit-reset'];
    final retryAfter = response.headers['retry-after'];

    if (limit != null || remaining != null || reset != null || retryAfter != null) {
      return RateLimitInfo(
        limit: limit != null ? int.tryParse(limit) : null,
        remaining: remaining != null ? int.tryParse(remaining) : null,
        reset: reset != null ? int.tryParse(reset) : null,
        retryAfter: retryAfter != null ? int.tryParse(retryAfter) : null,
      );
    }

    return null;
  }

  /// Check if response indicates rate limiting
  static bool isRateLimited(http.Response response) {
    return response.statusCode == 429;
  }

  /// Get retry after duration from response
  static Duration getRetryAfterDuration(http.Response response) {
    final retryAfter = response.headers['retry-after'];
    if (retryAfter != null) {
      final seconds = int.tryParse(retryAfter);
      if (seconds != null) {
        return Duration(seconds: seconds);
      }
    }
    return Duration(seconds: 60); // Default 60 seconds
  }

  // ============================================================================
  // EXPONENTIAL BACKOFF
  // ============================================================================

  /// Calculate exponential backoff delay
  static Duration calculateBackoffDelay(int attempt) {
    final delayMs = _baseDelayMs * (1 << (attempt - 1)); // 1, 2, 4, 8 seconds
    return Duration(milliseconds: delayMs);
  }

  /// Wait for exponential backoff delay
  static Future<void> waitForBackoff(int attempt) async {
    final delay = calculateBackoffDelay(attempt);
    await Future.delayed(delay);
  }

  // ============================================================================
  // REQUEST WITH RATE LIMITING
  // ============================================================================

  /// Make HTTP request with rate limiting and retry logic
  static Future<http.Response> makeRequestWithRateLimit(
    Future<http.Response> Function() requestFunction,
    String endpointCategory, {
    int maxRetries = _maxRetries,
    bool enableRetry = true,
  }) async {
    // Check rate limit before making request
    if (!isWithinRateLimit(endpointCategory)) {
      final timeUntilReset = getTimeUntilReset(endpointCategory);
      throw RateLimitExceededException(
        'Rate limit exceeded for $endpointCategory. Try again in ${timeUntilReset.inSeconds} seconds.',
        timeUntilReset,
      );
    }

    int attempt = 1;
    while (attempt <= maxRetries) {
      try {
        // Record the request
        recordRequest(endpointCategory);
        
        // Make the request
        final response = await requestFunction();
        
        // Check if rate limited
        if (isRateLimited(response)) {
          if (enableRetry && attempt < maxRetries) {
            final retryAfter = getRetryAfterDuration(response);
            await Future.delayed(retryAfter);
            attempt++;
            continue;
          } else {
            throw RateLimitExceededException(
              'Rate limit exceeded. Server requested retry after ${getRetryAfterDuration(response).inSeconds} seconds.',
              getRetryAfterDuration(response),
            );
          }
        }
        
        return response;
      } catch (e) {
        if (e is RateLimitExceededException) {
          rethrow;
        }
        
        if (enableRetry && attempt < maxRetries) {
          await waitForBackoff(attempt);
          attempt++;
        } else {
          rethrow;
        }
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  // ============================================================================
  // ENDPOINT CATEGORIZATION
  // ============================================================================

  /// Get endpoint category from URL
  static String getEndpointCategory(String url) {
    if (url.contains('/auth/')) return 'auth';
    if (url.contains('/likes/')) return 'likes';
    return 'default';
  }

  /// Get endpoint category from endpoint path
  static String getEndpointCategoryFromPath(String endpoint) {
    if (endpoint.startsWith('/auth/')) return 'auth';
    if (endpoint.startsWith('/likes/')) return 'likes';
    return 'default';
  }

  // ============================================================================
  // RATE LIMIT STATUS
  // ============================================================================

  /// Get rate limit status for all endpoint categories
  static Map<String, RateLimitStatus> getAllRateLimitStatus() {
    final status = <String, RateLimitStatus>{};
    
    for (final category in _rateLimits.keys) {
      status[category] = RateLimitStatus(
        category: category,
        limit: getRateLimit(category),
        remaining: getRemainingRequests(category),
        resetTime: getTimeUntilReset(category),
        isWithinLimit: isWithinRateLimit(category),
      );
    }
    
    return status;
  }

  /// Clear rate limit history for endpoint category
  static void clearRateLimitHistory(String endpointCategory) {
    _requestHistory.remove(endpointCategory);
  }

  /// Clear all rate limit history
  static void clearAllRateLimitHistory() {
    _requestHistory.clear();
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if we should wait before making request
  static bool shouldWait(String endpointCategory) {
    return !isWithinRateLimit(endpointCategory);
  }

  /// Get wait time before making request
  static Duration getWaitTime(String endpointCategory) {
    return getTimeUntilReset(endpointCategory);
  }

  /// Format rate limit status for display
  static String formatRateLimitStatus(String endpointCategory) {
    final remaining = getRemainingRequests(endpointCategory);
    final limit = getRateLimit(endpointCategory);
    final resetTime = getTimeUntilReset(endpointCategory);
    
    if (resetTime.inSeconds > 0) {
      return '$remaining/$limit requests remaining (resets in ${resetTime.inSeconds}s)';
    } else {
      return '$remaining/$limit requests remaining';
    }
  }
}

// ============================================================================
// RATE LIMIT DATA MODELS
// ============================================================================

/// Rate limit information from response headers
class RateLimitInfo {
  final int? limit;
  final int? remaining;
  final int? reset;
  final int? retryAfter;

  const RateLimitInfo({
    this.limit,
    this.remaining,
    this.reset,
    this.retryAfter,
  });

  /// Get reset time as DateTime
  DateTime? get resetTime {
    if (reset != null) {
      return DateTime.fromMillisecondsSinceEpoch(reset! * 1000);
    }
    return null;
  }

  /// Get retry after duration
  Duration? get retryAfterDuration {
    if (retryAfter != null) {
      return Duration(seconds: retryAfter!);
    }
    return null;
  }
}

/// Rate limit status for endpoint category
class RateLimitStatus {
  final String category;
  final int limit;
  final int remaining;
  final Duration resetTime;
  final bool isWithinLimit;

  const RateLimitStatus({
    required this.category,
    required this.limit,
    required this.remaining,
    required this.resetTime,
    required this.isWithinLimit,
  });

  /// Get usage percentage
  double get usagePercentage {
    return ((limit - remaining) / limit) * 100;
  }

  /// Check if rate limit is critical (90%+ usage)
  bool get isCritical {
    return usagePercentage >= 90;
  }

  /// Check if rate limit is warning (75%+ usage)
  bool get isWarning {
    return usagePercentage >= 75;
  }
}

/// Rate limit exceeded exception
class RateLimitExceededException implements Exception {
  final String message;
  final Duration retryAfter;

  const RateLimitExceededException(this.message, this.retryAfter);

  @override
  String toString() => 'RateLimitExceededException: $message';
}