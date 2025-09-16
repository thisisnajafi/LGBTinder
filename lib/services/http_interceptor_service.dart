import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import 'rate_limiting_service.dart';
import 'package:flutter/foundation.dart';

class HttpInterceptorService {
  static final HttpInterceptorService _instance = HttpInterceptorService._internal();
  factory HttpInterceptorService() => _instance;
  HttpInterceptorService._internal();

  final RateLimitingService _rateLimitingService = RateLimitingService();
  
  // Request timeout configuration
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration _shortTimeout = Duration(seconds: 10);
  static const Duration _longTimeout = Duration(seconds: 60);

  /// Intercept and handle HTTP GET requests
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Duration? timeout,
    String? userId,
    bool enableRateLimiting = true,
  }) async {
    return _makeRequest(
      () => _performGet(endpoint, headers, queryParams, timeout ?? _defaultTimeout),
      endpoint,
      userId: userId,
      enableRateLimiting: enableRateLimiting,
    );
  }

  /// Intercept and handle HTTP POST requests
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    String? userId,
    bool enableRateLimiting = true,
  }) async {
    return _makeRequest(
      () => _performPost(endpoint, headers, body, timeout ?? _defaultTimeout),
      endpoint,
      userId: userId,
      enableRateLimiting: enableRateLimiting,
    );
  }

  /// Intercept and handle HTTP PUT requests
  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    String? userId,
    bool enableRateLimiting = true,
  }) async {
    return _makeRequest(
      () => _performPut(endpoint, headers, body, timeout ?? _defaultTimeout),
      endpoint,
      userId: userId,
      enableRateLimiting: enableRateLimiting,
    );
  }

  /// Intercept and handle HTTP DELETE requests
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
    String? userId,
    bool enableRateLimiting = true,
  }) async {
    return _makeRequest(
      () => _performDelete(endpoint, headers, timeout ?? _defaultTimeout),
      endpoint,
      userId: userId,
      enableRateLimiting: enableRateLimiting,
    );
  }

  /// Intercept and handle HTTP PATCH requests
  Future<http.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration? timeout,
    String? userId,
    bool enableRateLimiting = true,
  }) async {
    return _makeRequest(
      () => _performPatch(endpoint, headers, body, timeout ?? _defaultTimeout),
      endpoint,
      userId: userId,
      enableRateLimiting: enableRateLimiting,
    );
  }

  /// Intercept and handle multipart requests
  Future<http.StreamedResponse> multipartRequest(
    String endpoint,
    http.MultipartRequest request, {
    Duration? timeout,
    String? userId,
    bool enableRateLimiting = true,
  }) async {
    return _makeStreamedRequest(
      () => _performMultipartRequest(endpoint, request, timeout ?? _longTimeout),
      endpoint,
      userId: userId,
      enableRateLimiting: enableRateLimiting,
    );
  }

  /// Make a request with rate limiting and error handling
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFunction,
    String endpoint, {
    String? userId,
    bool enableRateLimiting = true,
  }) async {
    try {
      if (enableRateLimiting) {
        return await _rateLimitingService.makeRateLimitedRequest(
          endpoint,
          requestFunction,
          userId: userId,
        );
      } else {
        return await requestFunction();
      }
    } catch (e) {
      debugPrint('HTTP request failed for $endpoint: $e');
      _handleRequestError(e, endpoint);
      rethrow;
    }
  }

  /// Make a streamed request with rate limiting and error handling
  Future<http.StreamedResponse> _makeStreamedRequest(
    Future<http.StreamedResponse> Function() requestFunction,
    String endpoint, {
    String? userId,
    bool enableRateLimiting = true,
  }) async {
    try {
      if (enableRateLimiting) {
        // For streamed requests, we need to check rate limiting first
        if (!await _rateLimitingService.isRequestAllowed(endpoint, userId: userId)) {
          await _rateLimitingService.waitForRateLimitReset(endpoint, userId: userId);
        }
        
        _rateLimitingService.recordRequest(endpoint, userId: userId);
        return await requestFunction();
      } else {
        return await requestFunction();
      }
    } catch (e) {
      debugPrint('HTTP streamed request failed for $endpoint: $e');
      _handleRequestError(e, endpoint);
      rethrow;
    }
  }

  /// Perform GET request
  Future<http.Response> _performGet(
    String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    Duration timeout,
  ) async {
    var uri = Uri.parse(ApiConfig.getUrl(endpoint));
    
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
    }

    return await http.get(
      uri,
      headers: _buildHeaders(headers),
    ).timeout(timeout);
  }

  /// Perform POST request
  Future<http.Response> _performPost(
    String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration timeout,
  ) async {
    final requestHeaders = _buildHeaders(headers);
    requestHeaders['Content-Type'] = 'application/json';

    return await http.post(
      Uri.parse(ApiConfig.getUrl(endpoint)),
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
  }

  /// Perform PUT request
  Future<http.Response> _performPut(
    String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration timeout,
  ) async {
    final requestHeaders = _buildHeaders(headers);
    requestHeaders['Content-Type'] = 'application/json';

    return await http.put(
      Uri.parse(ApiConfig.getUrl(endpoint)),
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
  }

  /// Perform DELETE request
  Future<http.Response> _performDelete(
    String endpoint,
    Map<String, String>? headers,
    Duration timeout,
  ) async {
    return await http.delete(
      Uri.parse(ApiConfig.getUrl(endpoint)),
      headers: _buildHeaders(headers),
    ).timeout(timeout);
  }

  /// Perform PATCH request
  Future<http.Response> _performPatch(
    String endpoint,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    Duration timeout,
  ) async {
    final requestHeaders = _buildHeaders(headers);
    requestHeaders['Content-Type'] = 'application/json';

    return await http.patch(
      Uri.parse(ApiConfig.getUrl(endpoint)),
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
  }

  /// Perform multipart request
  Future<http.StreamedResponse> _performMultipartRequest(
    String endpoint,
    http.MultipartRequest request,
    Duration timeout,
  ) async {
    request.url = Uri.parse(ApiConfig.getUrl(endpoint));
    
    // Add default headers
    final defaultHeaders = _buildHeaders(null);
    request.headers.addAll(defaultHeaders);

    return await request.send().timeout(timeout);
  }

  /// Build headers with defaults
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'User-Agent': 'LGBTinder-Flutter/1.0.0',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Handle request errors
  void _handleRequestError(dynamic error, String endpoint) {
    if (error is RateLimitException) {
      debugPrint('Rate limit exceeded for $endpoint: ${error.message}');
    } else if (error is TimeoutException) {
      debugPrint('Request timeout for $endpoint: ${error.message}');
    } else if (error is SocketException) {
      debugPrint('Network error for $endpoint: ${error.message}');
    } else {
      debugPrint('Unknown error for $endpoint: $error');
    }
  }

  /// Get rate limit status for an endpoint
  Map<String, dynamic> getRateLimitStatus(String endpoint, {String? userId}) {
    return {
      'endpoint': endpoint,
      'remaining_requests': _rateLimitingService.getRemainingRequests(endpoint, userId: userId),
      'time_until_reset': _rateLimitingService.getTimeUntilReset(endpoint, userId: userId).inSeconds,
      'is_allowed': _rateLimitingService.isRequestAllowed(endpoint, userId: userId),
    };
  }

  /// Clear rate limit for an endpoint
  void clearRateLimit(String endpoint, {String? userId}) {
    _rateLimitingService.clearRateLimit(endpoint, userId: userId);
  }

  /// Get all rate limit statistics
  Map<String, dynamic> getAllRateLimitStatistics() {
    return _rateLimitingService.getRateLimitStatistics();
  }

  /// Set custom rate limit for an endpoint
  void setCustomRateLimit(String endpoint, int requests, int windowMinutes) {
    _rateLimitingService.setCustomRateLimit(endpoint, requests, windowMinutes);
  }

  /// Check if endpoint is currently rate limited
  bool isRateLimited(String endpoint, {String? userId}) {
    return _rateLimitingService.isRateLimited(endpoint, userId: userId);
  }

  /// Get next allowed request time for an endpoint
  DateTime getNextAllowedRequestTime(String endpoint, {String? userId}) {
    return _rateLimitingService.getNextAllowedRequestTime(endpoint, userId: userId);
  }

  /// Wait for rate limit to reset
  Future<void> waitForRateLimitReset(String endpoint, {String? userId}) async {
    await _rateLimitingService.waitForRateLimitReset(endpoint, userId: userId);
  }

  /// Reset all rate limits (for testing)
  void resetAllRateLimits() {
    _rateLimitingService.clearAllRateLimits();
  }

  /// Get timeout duration based on endpoint type
  Duration getTimeoutForEndpoint(String endpoint) {
    if (endpoint.contains('upload') || endpoint.contains('media')) {
      return _longTimeout;
    } else if (endpoint.contains('auth') || endpoint.contains('login')) {
      return _shortTimeout;
    } else {
      return _defaultTimeout;
    }
  }

  /// Validate response and handle common errors
  void validateResponse(http.Response response, String endpoint) {
    if (response.statusCode >= 400) {
      if (response.statusCode == 429) {
        // Handle rate limit response
        try {
          final responseData = jsonDecode(response.body);
          _rateLimitingService.handleServerRateLimit(endpoint, responseData);
        } catch (e) {
          debugPrint('Failed to parse rate limit response: $e');
        }
      }
      
      throw ApiException(
        ErrorHandler.handleApiError(response.statusCode),
        statusCode: response.statusCode,
        responseData: response.body.isNotEmpty ? jsonDecode(response.body) : null,
      );
    }
  }

  /// Parse rate limit headers from response
  void parseRateLimitHeaders(http.Response response, String endpoint) {
    final rateLimitInfo = _rateLimitingService.parseRateLimitHeaders(response.headers);
    if (rateLimitInfo != null) {
      _rateLimitingService.applyServerRateLimitInfo(endpoint, rateLimitInfo);
    }
  }
}
