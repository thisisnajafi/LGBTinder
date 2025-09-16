import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import 'package:flutter/foundation.dart';

class RateLimitingService {
  static final RateLimitingService _instance = RateLimitingService._internal();
  factory RateLimitingService() => _instance;
  RateLimitingService._internal();

  // Rate limit tracking
  final Map<String, RateLimitInfo> _rateLimits = {};
  final Map<String, List<DateTime>> _requestHistory = {};
  
  // Default rate limits (requests per time window)
  static const Map<String, RateLimitConfig> _defaultLimits = {
    'auth': RateLimitConfig(requests: 5, windowMinutes: 1),
    'profile': RateLimitConfig(requests: 10, windowMinutes: 1),
    'matching': RateLimitConfig(requests: 20, windowMinutes: 1),
    'likes': RateLimitConfig(requests: 50, windowMinutes: 1),
    'chat': RateLimitConfig(requests: 30, windowMinutes: 1),
    'calls': RateLimitConfig(requests: 10, windowMinutes: 1),
    'stories': RateLimitConfig(requests: 10, windowMinutes: 1),
    'feeds': RateLimitConfig(requests: 15, windowMinutes: 1),
    'notifications': RateLimitConfig(requests: 20, windowMinutes: 1),
    'reports': RateLimitConfig(requests: 5, windowMinutes: 1),
    'verification': RateLimitConfig(requests: 3, windowMinutes: 1),
    'analytics': RateLimitConfig(requests: 10, windowMinutes: 1),
    'safety': RateLimitConfig(requests: 5, windowMinutes: 1),
    'reference_data': RateLimitConfig(requests: 50, windowMinutes: 1),
    'profile_wizard': RateLimitConfig(requests: 10, windowMinutes: 1),
    'subscription': RateLimitConfig(requests: 5, windowMinutes: 1),
    'payment': RateLimitConfig(requests: 3, windowMinutes: 1),
    'superlike_packs': RateLimitConfig(requests: 5, windowMinutes: 1),
    'user_management': RateLimitConfig(requests: 10, windowMinutes: 1),
    'general': RateLimitConfig(requests: 100, windowMinutes: 1),
  };

  /// Rate limit configuration
  static class RateLimitConfig {
    final int requests;
    final int windowMinutes;
    
    const RateLimitConfig({
      required this.requests,
      required this.windowMinutes,
    });
  }

  /// Rate limit information
  static class RateLimitInfo {
    final int limit;
    final int remaining;
    final DateTime resetTime;
    final int retryAfter;
    
    RateLimitInfo({
      required this.limit,
      required this.remaining,
      required this.resetTime,
      this.retryAfter = 0,
    });
  }

  /// Check if a request is allowed for the given endpoint
  Future<bool> isRequestAllowed(String endpoint, {String? userId}) async {
    final key = _getRateLimitKey(endpoint, userId);
    final config = _getRateLimitConfig(endpoint);
    
    // Clean old requests
    _cleanOldRequests(key, config.windowMinutes);
    
    // Check if we're within the limit
    final requestCount = _requestHistory[key]?.length ?? 0;
    if (requestCount >= config.requests) {
      debugPrint('Rate limit exceeded for $endpoint: $requestCount/${config.requests}');
      return false;
    }
    
    return true;
  }

  /// Record a request for rate limiting
  void recordRequest(String endpoint, {String? userId}) {
    final key = _getRateLimitKey(endpoint, userId);
    final now = DateTime.now();
    
    _requestHistory[key] ??= [];
    _requestHistory[key]!.add(now);
    
    debugPrint('Recorded request for $endpoint. Total requests: ${_requestHistory[key]!.length}');
  }

  /// Get remaining requests for an endpoint
  int getRemainingRequests(String endpoint, {String? userId}) {
    final key = _getRateLimitKey(endpoint, userId);
    final config = _getRateLimitConfig(endpoint);
    
    _cleanOldRequests(key, config.windowMinutes);
    final requestCount = _requestHistory[key]?.length ?? 0;
    
    return (config.requests - requestCount).clamp(0, config.requests);
  }

  /// Get time until rate limit resets
  Duration getTimeUntilReset(String endpoint, {String? userId}) {
    final key = _getRateLimitKey(endpoint, userId);
    final config = _getRateLimitConfig(endpoint);
    
    _cleanOldRequests(key, config.windowMinutes);
    final requests = _requestHistory[key];
    
    if (requests == null || requests.isEmpty) {
      return Duration.zero;
    }
    
    final oldestRequest = requests.first;
    final resetTime = oldestRequest.add(Duration(minutes: config.windowMinutes));
    final now = DateTime.now();
    
    if (resetTime.isAfter(now)) {
      return resetTime.difference(now);
    }
    
    return Duration.zero;
  }

  /// Handle rate limit response from server
  void handleServerRateLimit(String endpoint, Map<String, dynamic> response, {String? userId}) {
    final key = _getRateLimitKey(endpoint, userId);
    
    // Extract rate limit info from response headers or body
    final limit = response['limit'] as int? ?? 100;
    final remaining = response['remaining'] as int? ?? 0;
    final resetTime = response['reset_time'] != null 
        ? DateTime.parse(response['reset_time']) 
        : DateTime.now().add(Duration(minutes: 1));
    final retryAfter = response['retry_after'] as int? ?? 60;
    
    _rateLimits[key] = RateLimitInfo(
      limit: limit,
      remaining: remaining,
      resetTime: resetTime,
      retryAfter: retryAfter,
    );
    
    debugPrint('Server rate limit info for $endpoint: $remaining/$limit remaining, resets at $resetTime');
  }

  /// Wait for rate limit to reset
  Future<void> waitForRateLimitReset(String endpoint, {String? userId}) async {
    final timeUntilReset = getTimeUntilReset(endpoint, userId: userId);
    if (timeUntilReset > Duration.zero) {
      debugPrint('Waiting ${timeUntilReset.inSeconds} seconds for rate limit reset on $endpoint');
      await Future.delayed(timeUntilReset);
    }
  }

  /// Clear rate limit data for an endpoint
  void clearRateLimit(String endpoint, {String? userId}) {
    final key = _getRateLimitKey(endpoint, userId);
    _requestHistory.remove(key);
    _rateLimits.remove(key);
    debugPrint('Cleared rate limit data for $endpoint');
  }

  /// Clear all rate limit data
  void clearAllRateLimits() {
    _requestHistory.clear();
    _rateLimits.clear();
    debugPrint('Cleared all rate limit data');
  }

  /// Get rate limit status for all endpoints
  Map<String, Map<String, dynamic>> getAllRateLimitStatus() {
    final status = <String, Map<String, dynamic>>{};
    
    for (final endpoint in _defaultLimits.keys) {
      final config = _getRateLimitConfig(endpoint);
      final remaining = getRemainingRequests(endpoint);
      final timeUntilReset = getTimeUntilReset(endpoint);
      
      status[endpoint] = {
        'limit': config.requests,
        'remaining': remaining,
        'window_minutes': config.windowMinutes,
        'time_until_reset_seconds': timeUntilReset.inSeconds,
        'is_allowed': remaining > 0,
      };
    }
    
    return status;
  }

  /// Make an HTTP request with rate limiting
  Future<http.Response> makeRateLimitedRequest(
    String endpoint,
    Future<http.Response> Function() requestFunction, {
    String? userId,
    bool retryOnRateLimit = true,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      // Check if request is allowed
      if (!await isRequestAllowed(endpoint, userId: userId)) {
        if (retryOnRateLimit) {
          final waitTime = getTimeUntilReset(endpoint, userId: userId);
          debugPrint('Rate limit exceeded for $endpoint, waiting ${waitTime.inSeconds} seconds');
          await Future.delayed(waitTime);
          attempts++;
          continue;
        } else {
          throw RateLimitException(
            'Rate limit exceeded for $endpoint',
            cooldownSeconds: getTimeUntilReset(endpoint, userId: userId).inSeconds,
          );
        }
      }
      
      try {
        // Record the request
        recordRequest(endpoint, userId: userId);
        
        // Make the request
        final response = await requestFunction();
        
        // Handle rate limit response
        if (response.statusCode == 429) {
          final responseData = jsonDecode(response.body);
          handleServerRateLimit(endpoint, responseData, userId: userId);
          
          if (retryOnRateLimit && attempts < maxRetries - 1) {
            final retryAfter = responseData['retry_after'] as int? ?? 60;
            debugPrint('Server rate limit hit, waiting $retryAfter seconds');
            await Future.delayed(Duration(seconds: retryAfter));
            attempts++;
            continue;
          } else {
            throw RateLimitException(
              'Server rate limit exceeded for $endpoint',
              cooldownSeconds: responseData['retry_after'] as int? ?? 60,
            );
          }
        }
        
        return response;
      } catch (e) {
        if (e is RateLimitException) {
          rethrow;
        }
        
        // For other errors, don't retry
        rethrow;
      }
    }
    
    throw RateLimitException('Max retries exceeded for $endpoint');
  }

  /// Get rate limit key for tracking
  String _getRateLimitKey(String endpoint, String? userId) {
    return userId != null ? '${endpoint}_$userId' : endpoint;
  }

  /// Get rate limit configuration for endpoint
  RateLimitConfig _getRateLimitConfig(String endpoint) {
    // Try to find specific endpoint config
    for (final key in _defaultLimits.keys) {
      if (endpoint.contains(key)) {
        return _defaultLimits[key]!;
      }
    }
    
    // Default to general config
    return _defaultLimits['general']!;
  }

  /// Clean old requests outside the time window
  void _cleanOldRequests(String key, int windowMinutes) {
    final requests = _requestHistory[key];
    if (requests == null) return;
    
    final cutoff = DateTime.now().subtract(Duration(minutes: windowMinutes));
    _requestHistory[key] = requests.where((time) => time.isAfter(cutoff)).toList();
  }

  /// Set custom rate limit for an endpoint
  void setCustomRateLimit(String endpoint, int requests, int windowMinutes) {
    _defaultLimits[endpoint] = RateLimitConfig(
      requests: requests,
      windowMinutes: windowMinutes,
    );
    debugPrint('Set custom rate limit for $endpoint: $requests requests per $windowMinutes minutes');
  }

  /// Get rate limit statistics
  Map<String, dynamic> getRateLimitStatistics() {
    final stats = <String, dynamic>{};
    
    for (final endpoint in _defaultLimits.keys) {
      final config = _getRateLimitConfig(endpoint);
      final remaining = getRemainingRequests(endpoint);
      final timeUntilReset = getTimeUntilReset(endpoint);
      
      stats[endpoint] = {
        'config': {
          'requests': config.requests,
          'window_minutes': config.windowMinutes,
        },
        'current': {
          'remaining': remaining,
          'time_until_reset_seconds': timeUntilReset.inSeconds,
          'is_allowed': remaining > 0,
        },
      };
    }
    
    return stats;
  }

  /// Check if endpoint is rate limited
  bool isRateLimited(String endpoint, {String? userId}) {
    return getRemainingRequests(endpoint, userId: userId) <= 0;
  }

  /// Get next allowed request time
  DateTime getNextAllowedRequestTime(String endpoint, {String? userId}) {
    final timeUntilReset = getTimeUntilReset(endpoint, userId: userId);
    return DateTime.now().add(timeUntilReset);
  }

  /// Reset rate limit for testing
  void resetRateLimit(String endpoint, {String? userId}) {
    final key = _getRateLimitKey(endpoint, userId);
    _requestHistory.remove(key);
    _rateLimits.remove(key);
  }

  /// Get rate limit info from server response headers
  RateLimitInfo? parseRateLimitHeaders(Map<String, String> headers) {
    final limit = headers['x-ratelimit-limit'];
    final remaining = headers['x-ratelimit-remaining'];
    final reset = headers['x-ratelimit-reset'];
    final retryAfter = headers['retry-after'];
    
    if (limit != null && remaining != null && reset != null) {
      return RateLimitInfo(
        limit: int.parse(limit),
        remaining: int.parse(remaining),
        resetTime: DateTime.fromMillisecondsSinceEpoch(int.parse(reset) * 1000),
        retryAfter: retryAfter != null ? int.parse(retryAfter) : 0,
      );
    }
    
    return null;
  }

  /// Apply rate limit info from server
  void applyServerRateLimitInfo(String endpoint, RateLimitInfo info, {String? userId}) {
    final key = _getRateLimitKey(endpoint, userId);
    _rateLimits[key] = info;
    debugPrint('Applied server rate limit info for $endpoint: ${info.remaining}/${info.limit} remaining');
  }
}
