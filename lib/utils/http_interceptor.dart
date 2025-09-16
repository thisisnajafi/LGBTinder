import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class HttpInterceptor {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  
  /// Make authenticated HTTP request with automatic token handling
  static Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParameters,
  }) async {
    try {
      // Get current access token
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      
      if (accessToken == null) {
        throw AuthException('No access token available. Please log in again.');
      }
      
      // Check if token is expired
      if (await _isTokenExpired()) {
        // Try to refresh token
        final refreshed = await _refreshTokenIfNeeded();
        if (!refreshed) {
          throw AuthException('Token expired and refresh failed. Please log in again.');
        }
      }
      
      // Get updated token after potential refresh
      final currentToken = await _secureStorage.read(key: _accessTokenKey);
      
      // Prepare headers
      final requestHeaders = <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $currentToken',
        ...?headers,
      };
      
      // Add content type for POST/PUT requests
      if (body != null && (method == 'POST' || method == 'PUT' || method == 'PATCH')) {
        if (body is String) {
          requestHeaders['Content-Type'] = 'application/json';
        } else if (body is Map) {
          requestHeaders['Content-Type'] = 'application/json';
        }
      }
      
      // Build URL
      var url = ApiConfig.getUrl(endpoint);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParameters).toString();
      }
      
      // Make request
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: requestHeaders,
            body: body is String ? body : jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: requestHeaders,
            body: body is String ? body : jsonEncode(body),
          );
          break;
        case 'PATCH':
          response = await http.patch(
            Uri.parse(url),
            headers: requestHeaders,
            body: body is String ? body : jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: requestHeaders);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      
      // Handle 401 responses (token expired)
      if (response.statusCode == 401) {
        // Try to refresh token once more
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          // Retry the request with new token
          final newToken = await _secureStorage.read(key: _accessTokenKey);
          requestHeaders['Authorization'] = 'Bearer $newToken';
          
          switch (method.toUpperCase()) {
            case 'GET':
              response = await http.get(Uri.parse(url), headers: requestHeaders);
              break;
            case 'POST':
              response = await http.post(
                Uri.parse(url),
                headers: requestHeaders,
                body: body is String ? body : jsonEncode(body),
              );
              break;
            case 'PUT':
              response = await http.put(
                Uri.parse(url),
                headers: requestHeaders,
                body: body is String ? body : jsonEncode(body),
              );
              break;
            case 'PATCH':
              response = await http.patch(
                Uri.parse(url),
                headers: requestHeaders,
                body: body is String ? body : jsonEncode(body),
              );
              break;
            case 'DELETE':
              response = await http.delete(Uri.parse(url), headers: requestHeaders);
              break;
          }
        } else {
          throw AuthException('Authentication failed. Please log in again.');
        }
      }
      
      return response;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }
  
  /// Check if current token is expired
  static Future<bool> _isTokenExpired() async {
    try {
      final tokenExpiryStr = await _secureStorage.read(key: _tokenExpiryKey);
      if (tokenExpiryStr == null) return true;
      
      final tokenExpiry = DateTime.parse(tokenExpiryStr);
      // Consider token expired if it expires within 5 minutes
      return DateTime.now().isAfter(tokenExpiry.subtract(const Duration(minutes: 5)));
    } catch (e) {
      return true;
    }
  }
  
  /// Refresh token if needed
  static Future<bool> _refreshTokenIfNeeded() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;
      
      // For now, we'll just return false since refresh endpoint is not implemented
      // In a real implementation, you would call the refresh endpoint here
      print('⚠️ Token refresh not implemented in backend');
      return false;
      
      // TODO: Implement when backend supports token refresh
      // final response = await http.post(
      //   Uri.parse(ApiConfig.getUrl(ApiConfig.refreshToken)),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Accept': 'application/json',
      //     'Authorization': 'Bearer $refreshToken',
      //   },
      // );
      // 
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   await _secureStorage.write(key: _accessTokenKey, value: data['access_token']);
      //   await _secureStorage.write(key: _refreshTokenKey, value: data['refresh_token']);
      //   await _secureStorage.write(key: _tokenExpiryKey, value: DateTime.now().add(Duration(seconds: data['expires_in'])).toIso8601String());
      //   return true;
      // }
      // 
      // return false;
    } catch (e) {
      print('💥 Token refresh failed: $e');
      return false;
    }
  }
  
  /// Clear all stored tokens
  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
  }
  
  /// Get current access token
  static Future<String?> getCurrentToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
  
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    if (token == null) return false;
    
    return !(await _isTokenExpired());
  }
}
