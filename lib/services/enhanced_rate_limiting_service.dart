import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import 'package:flutter/foundation.dart';

/// Enhanced rate limiting service implementing progressive restrictions
class EnhancedRateLimitingService {
  static final EnhancedRateLimitingService _instance = EnhancedRateLimitingService._internal();
  factory EnhancedRateLimitingService() => _instance;
  EnhancedRateLimitingService._internal();

  // Simplified rate limiting - just track basic limits
  final Map<String, int> _requestCounts = {};
  final Map<String, DateTime> _lastRequestTime = {};

  /// Check if a request is allowed for the given user and operation
  Future<bool> isRequestAllowed(String userId, String operation) async {
    final key = '${userId}_$operation';
    final now = DateTime.now();
    final lastRequest = _lastRequestTime[key];
    
    if (lastRequest == null) {
      _requestCounts[key] = 1;
      _lastRequestTime[key] = now;
      return true;
    }
    
    final timeDifference = now.difference(lastRequestTime).inMinutes;
    if (timeDifference >= 2) { // 2 minute cool down
      _requestCounts[key] = 1;
      _lastRequestTime[key] = now;
      return true;
    }
    
    return false;
  }

  /// Make a rate-limited request
  Future<http.Response> makeRateLimitedRequest(
    String userId, 
    String operation, 
    Future<http.Response> Function() request,
  ) async {
    if (!await isRequestAllowed(userId, operation)) {
      throw RateLimitException('Rate limit exceeded for $operation');
    }
    
    return await request();
  }

  /// Clear rate limits for a user
  void clearRateLimit(String userId) {
    _requestCounts.removeWhere((key, value) => key.startsWith(userId));
    _lastRequestTime.removeWhere((key, value) => key.startsWith(userId));
  }
}

/// Simple rate limit exception
class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
  
  @override
  String toString() => 'RateLimitException: $message';
}