import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import 'package:flutter/foundation.dart';

/// Enhanced rate limiting service implementing progressive restrictions
/// as described in the email verification API documentation
class EnhancedRateLimitingService {
  static final EnhancedRateLimitingService _instance = EnhancedRateLimitingService._internal();
  factory EnhancedRateLimitingService() => _instance;
  EnhancedRateLimitingService._internal();

  // Rate limit tracking
  final Map<String, RateLimitInfo> _rateLimits = {};
  final Map<String, List<DateTime>> _requestHistory = {};
  final Map<String, String> _restrictionTiers = {};
  
  // Progressive restriction configuration
  static const Map<String, RateLimitConfig> _emailVerificationLimits = {
    'registration_verification': RateLimitConfig(
      dailyLimit: 5,
      hourlyLimit: 3,
      resendCooldownMinutes: 2,
      tokenExpiryMinutes: 15,
    ),
    'login_code_verification': RateLimitConfig(
      dailyLimit: 10,
      hourlyLimit: 5,
      resendCooldownMinutes: 1,
      tokenExpiryMinutes: 5,
    ),
    'password_reset_otp': RateLimitConfig(
      dailyLimit: 5,
      hourlyLimit: 3,
      resendCooldownMinutes: 2,
      tokenExpiryMinutes: 15,
    ),
  };

  // IP-based limits
  static const Map<String, int> _ipLimits = {
    'daily': 50,
    'hourly': 20,
    'minute': 5,
  };

  // Progressive restriction tiers
  static const Map<String, ProgressiveRestriction> _progressiveRestrictions = {
    'normal': ProgressiveRestriction(
      cooldownMinutes: 2,
      hourlyLimit: 3,
      dailyLimit: 5,
    ),
    'warning': ProgressiveRestriction(
      cooldownMinutes: 5,
      hourlyLimit: 3,
      dailyLimit: 5,
    ),
    'restricted': ProgressiveRestriction(
      cooldownMinutes: 10,
      hourlyLimit: 2,
      dailyLimit: 3,
    ),
    'locked': ProgressiveRestriction(
      cooldownMinutes: 60,
      hourlyLimit: 1,
      dailyLimit: 1,
      lockoutHours: 1,
    ),
  };

  /// Rate limit configuration
  static class RateLimitConfig {
    final int dailyLimit;
    final int hourlyLimit;
    final int resendCooldownMinutes;
    final int tokenExpiryMinutes;
    
    const RateLimitConfig({
      required this.dailyLimit,
      required this.hourlyLimit,
      required this.resendCooldownMinutes,
      required this.tokenExpiryMinutes,
    });
  }

  /// Progressive restriction configuration
  static class ProgressiveRestriction {
    final int cooldownMinutes;
    final int hourlyLimit;
    final int dailyLimit;
    final int? lockoutHours;
    
    const ProgressiveRestriction({
      required this.cooldownMinutes,
      required this.hourlyLimit,
      required this.dailyLimit,
      this.lockoutHours,
    });
  }

  /// Rate limit information
  static class RateLimitInfo {
    final int limit;
    final int remaining;
    final DateTime resetTime;
    final int retryAfter;
    final String restrictionTier;
    final Map<String, int> remainingAttempts;
    
    RateLimitInfo({
      required this.limit,
      required this.remaining,
      required this.resetTime,
      this.retryAfter = 0,
      this.restrictionTier = 'normal',
      this.remainingAttempts = const {},
    });
  }

  /// Check if a request is allowed for email verification
  Future<bool> isEmailVerificationAllowed(String endpoint, String email, {String? ipAddress}) async {
    final config = _emailVerificationLimits[endpoint];
    if (config == null) return true;

    // Check IP limits first
    if (ipAddress != null && !await _isIpAllowed(ipAddress)) {
      debugPrint('IP rate limit exceeded for $ipAddress');
      return false;
    }

    // Check user limits
    final userKey = '${endpoint}_$email';
    final restrictionTier = _restrictionTiers[userKey] ?? 'normal';
    final restriction = _progressiveRestrictions[restrictionTier]!;

    // Clean old requests
    _cleanOldRequests(userKey, config.hourlyLimit);

    // Check if we're within the limit
    final requestCount = _requestHistory[userKey]?.length ?? 0;
    if (requestCount >= restriction.hourlyLimit) {
      debugPrint('User rate limit exceeded for $email: $requestCount/${restriction.hourlyLimit}');
      return false;
    }

    // Check daily limit
    final dailyCount = _getDailyRequestCount(userKey);
    if (dailyCount >= restriction.dailyLimit) {
      debugPrint('Daily rate limit exceeded for $email: $dailyCount/${restriction.dailyLimit}');
      return false;
    }

    return true;
  }

  /// Record a request for rate limiting
  void recordEmailVerificationRequest(String endpoint, String email, {String? ipAddress}) {
    final userKey = '${endpoint}_$email';
    final now = DateTime.now();
    
    _requestHistory[userKey] ??= [];
    _requestHistory[userKey]!.add(now);
    
    if (ipAddress != null) {
      final ipKey = 'ip_$ipAddress';
      _requestHistory[ipKey] ??= [];
      _requestHistory[ipKey]!.add(now);
    }
    
    debugPrint('Recorded email verification request for $email. Total requests: ${_requestHistory[userKey]!.length}');
  }

  /// Get remaining requests for an endpoint
  int getRemainingEmailVerificationRequests(String endpoint, String email) {
    final userKey = '${endpoint}_$email';
    final restrictionTier = _restrictionTiers[userKey] ?? 'normal';
    final restriction = _progressiveRestrictions[restrictionTier]!;
    
    _cleanOldRequests(userKey, 60); // 1 hour window
    final requestCount = _requestHistory[userKey]?.length ?? 0;
    
    return (restriction.hourlyLimit - requestCount).clamp(0, restriction.hourlyLimit);
  }

  /// Get time until rate limit resets
  Duration getTimeUntilReset(String endpoint, String email) {
    final userKey = '${endpoint}_$email';
    final restrictionTier = _restrictionTiers[userKey] ?? 'normal';
    final restriction = _progressiveRestrictions[restrictionTier]!;
    
    final requests = _requestHistory[userKey];
    if (requests == null || requests.isEmpty) {
      return Duration.zero;
    }
    
    final lastRequest = requests.last;
    final resetTime = lastRequest.add(Duration(minutes: restriction.cooldownMinutes));
    final now = DateTime.now();
    
    if (resetTime.isAfter(now)) {
      return resetTime.difference(now);
    }
    
    return Duration.zero;
  }

  /// Update restriction tier based on failed attempts
  void updateRestrictionTier(String endpoint, String email, bool isSuccess) {
    final userKey = '${endpoint}_$email';
    final currentTier = _restrictionTiers[userKey] ?? 'normal';
    
    if (isSuccess) {
      // Reset to normal on success
      _restrictionTiers[userKey] = 'normal';
    } else {
      // Escalate restriction tier on failure
      String newTier;
      switch (currentTier) {
        case 'normal':
          newTier = 'warning';
          break;
        case 'warning':
          newTier = 'restricted';
          break;
        case 'restricted':
          newTier = 'locked';
          break;
        case 'locked':
          newTier = 'locked'; // Stay locked
          break;
        default:
          newTier = 'normal';
      }
      _restrictionTiers[userKey] = newTier;
      debugPrint('Updated restriction tier for $email: $currentTier -> $newTier');
    }
  }

  /// Check if IP is allowed
  Future<bool> _isIpAllowed(String ipAddress) async {
    final ipKey = 'ip_$ipAddress';
    final now = DateTime.now();
    
    // Clean old requests
    _cleanOldRequests(ipKey, 60); // 1 hour window
    
    // Check minute limit
    final minuteRequests = _requestHistory[ipKey]?.where((time) => 
      now.difference(time).inMinutes < 1).length ?? 0;
    if (minuteRequests >= _ipLimits['minute']!) {
      return false;
    }
    
    // Check hourly limit
    final hourlyRequests = _requestHistory[ipKey]?.where((time) => 
      now.difference(time).inHours < 1).length ?? 0;
    if (hourlyRequests >= _ipLimits['hourly']!) {
      return false;
    }
    
    // Check daily limit
    final dailyRequests = _requestHistory[ipKey]?.where((time) => 
      now.difference(time).inDays < 1).length ?? 0;
    if (dailyRequests >= _ipLimits['daily']!) {
      return false;
    }
    
    return true;
  }

  /// Clean old requests from history
  void _cleanOldRequests(String key, int windowMinutes) {
    final requests = _requestHistory[key];
    if (requests == null) return;
    
    final cutoff = DateTime.now().subtract(Duration(minutes: windowMinutes));
    _requestHistory[key] = requests.where((time) => time.isAfter(cutoff)).toList();
  }

  /// Get daily request count
  int _getDailyRequestCount(String key) {
    final requests = _requestHistory[key];
    if (requests == null) return 0;
    
    final cutoff = DateTime.now().subtract(Duration(days: 1));
    return requests.where((time) => time.isAfter(cutoff)).length;
  }

  /// Handle server rate limit response
  void handleServerRateLimit(String endpoint, String email, Map<String, dynamic> responseData) {
    final data = responseData['data'] as Map<String, dynamic>?;
    if (data == null) return;

    final restrictionTier = data['restriction_tier'] as String? ?? 'normal';
    final retryAfter = data['retry_after'] as int? ?? 60;
    final remainingAttempts = data['remaining_attempts'] as Map<String, int>? ?? {};

    final userKey = '${endpoint}_$email';
    _restrictionTiers[userKey] = restrictionTier;

    debugPrint('Server rate limit for $email: tier=$restrictionTier, retry_after=${retryAfter}s');
  }

  /// Get rate limit status
  Map<String, dynamic> getRateLimitStatus(String endpoint, String email) {
    final userKey = '${endpoint}_$email';
    final restrictionTier = _restrictionTiers[userKey] ?? 'normal';
    final restriction = _progressiveRestrictions[restrictionTier]!;
    
    final remainingRequests = getRemainingEmailVerificationRequests(endpoint, email);
    final timeUntilReset = getTimeUntilReset(endpoint, email);
    
    return {
      'restriction_tier': restrictionTier,
      'remaining_attempts': {
        'hourly': remainingRequests,
        'daily': restriction.dailyLimit - _getDailyRequestCount(userKey),
      },
      'cooldown_minutes': restriction.cooldownMinutes,
      'time_until_reset_seconds': timeUntilReset.inSeconds,
      'is_allowed': remainingRequests > 0,
    };
  }

  /// Reset rate limits for testing
  void resetRateLimits() {
    _rateLimits.clear();
    _requestHistory.clear();
    _restrictionTiers.clear();
    debugPrint('Rate limits reset');
  }

  /// Make an HTTP request with enhanced rate limiting
  Future<http.Response> makeRateLimitedEmailVerificationRequest(
    String endpoint,
    String email,
    Future<http.Response> Function() requestFunction, {
    String? ipAddress,
    bool retryOnRateLimit = true,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      // Check if request is allowed
      if (!await isEmailVerificationAllowed(endpoint, email, ipAddress: ipAddress)) {
        if (retryOnRateLimit) {
          final waitTime = getTimeUntilReset(endpoint, email);
          debugPrint('Rate limit exceeded for $email, waiting ${waitTime.inSeconds} seconds');
          await Future.delayed(waitTime);
          attempts++;
          continue;
        } else {
          final status = getRateLimitStatus(endpoint, email);
          throw RateLimitException(
            'Rate limit exceeded for $email',
            cooldownSeconds: status['time_until_reset_seconds'] as int,
          );
        }
      }
      
      try {
        // Record the request
        recordEmailVerificationRequest(endpoint, email, ipAddress: ipAddress);
        
        // Make the request
        final response = await requestFunction();
        
        // Handle rate limit response
        if (response.statusCode == 429) {
          final responseData = jsonDecode(response.body);
          handleServerRateLimit(endpoint, email, responseData);
          
          if (retryOnRateLimit && attempts < maxRetries - 1) {
            final retryAfter = responseData['data']?['retry_after'] as int? ?? 60;
            debugPrint('Server rate limit hit, waiting $retryAfter seconds');
            await Future.delayed(Duration(seconds: retryAfter));
            attempts++;
            continue;
          } else {
            throw RateLimitException(
              'Server rate limit exceeded for $email',
              cooldownSeconds: responseData['data']?['retry_after'] as int? ?? 60,
            );
          }
        }
        
        // Update restriction tier based on success/failure
        updateRestrictionTier(endpoint, email, response.statusCode == 200);
        
        return response;
      } catch (e) {
        if (e is RateLimitException) {
          rethrow;
        }
        
        // Update restriction tier on error
        updateRestrictionTier(endpoint, email, false);
        
        if (attempts < maxRetries - 1) {
          attempts++;
          await Future.delayed(Duration(seconds: 2 * attempts)); // Exponential backoff
          continue;
        }
        
        rethrow;
      }
    }
    
    throw RateLimitException('Max retries exceeded for $email');
  }
}
