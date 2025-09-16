import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/jwt_token_service.dart';
import '../utils/api_error_handler.dart';

class EnhancedHttpInterceptor {
  static final EnhancedHttpInterceptor _instance = EnhancedHttpInterceptor._internal();
  factory EnhancedHttpInterceptor() => _instance;
  EnhancedHttpInterceptor._internal();

  final JWTTokenService _tokenService = JWTTokenService();
  
  // Request timeout
  static const Duration _timeout = Duration(seconds: 30);
  
  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  /// Initialize the interceptor
  Future<void> initialize() async {
    await _tokenService.initialize(
      onTokenRefreshed: _onTokenRefreshed,
      onTokenRefreshFailed: _onTokenRefreshFailed,
    );
    debugPrint('Enhanced HTTP Interceptor initialized');
  }

  /// Handle token refresh success
  void _onTokenRefreshed(String newAccessToken, String newRefreshToken) {
    debugPrint('Token refreshed successfully');
    // Additional logic can be added here if needed
  }

  /// Handle token refresh failure
  void _onTokenRefreshFailed() {
    debugPrint('Token refresh failed - user needs to re-authenticate');
    // Additional logic can be added here if needed
  }

  /// Make authenticated GET request
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    bool requireAuth = true,
    int retryCount = 0,
  }) async {
    return await _makeRequest(
      () => http.get(
        Uri.parse(url),
        headers: await _buildHeaders(headers, requireAuth),
      ).timeout(_timeout),
      retryCount: retryCount,
    );
  }

  /// Make authenticated POST request
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requireAuth = true,
    int retryCount = 0,
  }) async {
    return await _makeRequest(
      () => http.post(
        Uri.parse(url),
        headers: await _buildHeaders(headers, requireAuth),
        body: body is String ? body : jsonEncode(body),
      ).timeout(_timeout),
      retryCount: retryCount,
    );
  }

  /// Make authenticated PUT request
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requireAuth = true,
    int retryCount = 0,
  }) async {
    return await _makeRequest(
      () => http.put(
        Uri.parse(url),
        headers: await _buildHeaders(headers, requireAuth),
        body: body is String ? body : jsonEncode(body),
      ).timeout(_timeout),
      retryCount: retryCount,
    );
  }

  /// Make authenticated DELETE request
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    bool requireAuth = true,
    int retryCount = 0,
  }) async {
    return await _makeRequest(
      () => http.delete(
        Uri.parse(url),
        headers: await _buildHeaders(headers, requireAuth),
      ).timeout(_timeout),
      retryCount: retryCount,
    );
  }

  /// Make authenticated PATCH request
  Future<http.Response> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requireAuth = true,
    int retryCount = 0,
  }) async {
    return await _makeRequest(
      () => http.patch(
        Uri.parse(url),
        headers: await _buildHeaders(headers, requireAuth),
        body: body is String ? body : jsonEncode(body),
      ).timeout(_timeout),
      retryCount: retryCount,
    );
  }

  /// Build headers with authentication
  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? headers,
    bool requireAuth,
  ) async {
    final defaultHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authentication header if required
    if (requireAuth) {
      final accessToken = await _tokenService.getValidAccessToken();
      if (accessToken != null) {
        defaultHeaders['Authorization'] = 'Bearer $accessToken';
      }
    }

    // Merge with provided headers
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return defaultHeaders;
  }

  /// Make request with retry logic and error handling
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
    {required int retryCount},
  ) async {
    try {
      final response = await request();
      
      // Handle 401 Unauthorized - token might be expired
      if (response.statusCode == 401 && retryCount < _maxRetries) {
        debugPrint('Received 401, attempting token refresh...');
        
        final refreshed = await _tokenService.refreshAccessToken();
        if (refreshed) {
          debugPrint('Token refreshed, retrying request...');
          return await _makeRequest(request, retryCount: retryCount + 1);
        } else {
          debugPrint('Token refresh failed');
          throw AuthException('Authentication failed');
        }
      }
      
      // Handle other HTTP errors
      if (response.statusCode >= 400) {
        _handleHttpError(response);
      }
      
      return response;
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      if (retryCount < _maxRetries) {
        debugPrint('Request failed, retrying... (${retryCount + 1}/$_maxRetries)');
        await Future.delayed(_retryDelay);
        return await _makeRequest(request, retryCount: retryCount + 1);
      }
      
      debugPrint('Request failed after $_maxRetries retries: $e');
      throw NetworkException('Network error: $e');
    }
  }

  /// Handle HTTP error responses
  void _handleHttpError(http.Response response) {
    final statusCode = response.statusCode;
    String message;
    
    try {
      final errorData = jsonDecode(response.body);
      message = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
    } catch (e) {
      message = 'HTTP $statusCode error';
    }

    switch (statusCode) {
      case 400:
        throw ValidationException(message);
      case 401:
        throw AuthException(message);
      case 403:
        throw AuthException('Access forbidden: $message');
      case 404:
        throw ApiException('Resource not found: $message');
      case 422:
        throw ValidationException(message);
      case 429:
        throw RateLimitException('Rate limit exceeded: $message');
      case 500:
        throw ApiException('Server error: $message');
      case 502:
      case 503:
      case 504:
        throw NetworkException('Service unavailable: $message');
      default:
        throw ApiException('HTTP $statusCode: $message');
    }
  }

  /// Upload file with authentication
  Future<http.Response> uploadFile(
    String url,
    String filePath, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    String fieldName = 'file',
    bool requireAuth = true,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Add headers
      final authHeaders = await _buildHeaders(headers, requireAuth);
      request.headers.addAll(authHeaders);
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      
      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 400) {
        _handleHttpError(response);
      }
      
      return response;
    } catch (e) {
      debugPrint('File upload error: $e');
      throw NetworkException('File upload failed: $e');
    }
  }

  /// Download file with authentication
  Future<List<int>> downloadFile(
    String url, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    try {
      final response = await get(url, headers: headers, requireAuth: requireAuth);
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        _handleHttpError(response);
        return [];
      }
    } catch (e) {
      debugPrint('File download error: $e');
      throw NetworkException('File download failed: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await _tokenService.getAccessToken();
    return accessToken != null && !(await _tokenService.isAccessTokenExpired());
  }

  /// Get current access token
  Future<String?> getCurrentToken() async {
    return await _tokenService.getValidAccessToken();
  }

  /// Clear authentication
  Future<void> clearAuth() async {
    await _tokenService.clearTokens();
  }

  /// Dispose interceptor
  void dispose() {
    _tokenService.dispose();
  }
}

// Global instance for easy access
final httpInterceptor = EnhancedHttpInterceptor();
