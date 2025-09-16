import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/api_error_handler.dart';

class JWTTokenService {
  static final JWTTokenService _instance = JWTTokenService._internal();
  factory JWTTokenService() => _instance;
  JWTTokenService._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _refreshTokenExpiryKey = 'refresh_token_expiry';
  
  // Token refresh timer
  Timer? _tokenRefreshTimer;
  
  // Token refresh callback
  Function(String newAccessToken, String newRefreshToken)? _onTokenRefreshed;
  Function()? _onTokenRefreshFailed;

  /// Initialize token service
  Future<void> initialize({
    Function(String newAccessToken, String newRefreshToken)? onTokenRefreshed,
    Function()? onTokenRefreshFailed,
  }) async {
    _onTokenRefreshed = onTokenRefreshed;
    _onTokenRefreshFailed = onTokenRefreshFailed;
    
    // Start automatic token refresh timer
    _startTokenRefreshTimer();
    
    debugPrint('JWT Token Service initialized');
  }

  /// Store tokens securely
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    int? accessTokenExpiresIn,
    int? refreshTokenExpiresIn,
  }) async {
    try {
      // Calculate expiry times
      final now = DateTime.now();
      final accessExpiry = accessTokenExpiresIn != null 
          ? now.add(Duration(seconds: accessTokenExpiresIn))
          : now.add(const Duration(hours: 1)); // Default 1 hour
      
      final refreshExpiry = refreshTokenExpiresIn != null
          ? now.add(Duration(seconds: refreshTokenExpiresIn))
          : now.add(const Duration(days: 30)); // Default 30 days

      // Store tokens and expiry times
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
        _secureStorage.write(key: _tokenExpiryKey, value: accessExpiry.toIso8601String()),
        _secureStorage.write(key: _refreshTokenExpiryKey, value: refreshExpiry.toIso8601String()),
      ]);

      debugPrint('Tokens stored successfully');
    } catch (e) {
      debugPrint('Failed to store tokens: $e');
      throw TokenStorageException('Failed to store tokens: $e');
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      debugPrint('Failed to get access token: $e');
      return null;
    }
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('Failed to get refresh token: $e');
      return null;
    }
  }

  /// Get token expiry
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = await _secureStorage.read(key: _tokenExpiryKey);
      if (expiryString != null) {
        return DateTime.parse(expiryString);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get token expiry: $e');
      return null;
    }
  }

  /// Get refresh token expiry
  Future<DateTime?> getRefreshTokenExpiry() async {
    try {
      final expiryString = await _secureStorage.read(key: _refreshTokenExpiryKey);
      if (expiryString != null) {
        return DateTime.parse(expiryString);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get refresh token expiry: $e');
      return null;
    }
  }

  /// Check if access token is expired or will expire soon
  Future<bool> isAccessTokenExpired({Duration buffer = const Duration(minutes: 5)}) async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;
      
      return DateTime.now().isAfter(expiry.subtract(buffer));
    } catch (e) {
      debugPrint('Failed to check token expiry: $e');
      return true;
    }
  }

  /// Check if refresh token is expired
  Future<bool> isRefreshTokenExpired() async {
    try {
      final expiry = await getRefreshTokenExpiry();
      if (expiry == null) return true;
      
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      debugPrint('Failed to check refresh token expiry: $e');
      return true;
    }
  }

  /// Get valid access token (refresh if needed)
  Future<String?> getValidAccessToken() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return null;

      // Check if token is expired
      if (await isAccessTokenExpired()) {
        debugPrint('Access token expired, attempting refresh');
        
        // Try to refresh the token
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getAccessToken();
        } else {
          debugPrint('Token refresh failed');
          return null;
        }
      }

      return accessToken;
    } catch (e) {
      debugPrint('Failed to get valid access token: $e');
      return null;
    }
  }

  /// Refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        debugPrint('No refresh token available');
        return false;
      }

      // Check if refresh token is expired
      if (await isRefreshTokenExpired()) {
        debugPrint('Refresh token expired');
        await clearTokens();
        _onTokenRefreshFailed?.call();
        return false;
      }

      debugPrint('Refreshing access token...');
      
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.refreshToken)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;
        final accessTokenExpiresIn = data['expires_in'] as int?;
        final refreshTokenExpiresIn = data['refresh_expires_in'] as int?;

        if (newAccessToken != null) {
          // Store new tokens
          await storeTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
            accessTokenExpiresIn: accessTokenExpiresIn,
            refreshTokenExpiresIn: refreshTokenExpiresIn,
          );

          // Notify listeners
          _onTokenRefreshed?.call(newAccessToken, newRefreshToken ?? refreshToken);
          
          debugPrint('Access token refreshed successfully');
          return true;
        } else {
          debugPrint('Invalid refresh response: missing access_token');
          return false;
        }
      } else if (response.statusCode == 401) {
        debugPrint('Refresh token invalid or expired');
        await clearTokens();
        _onTokenRefreshFailed?.call();
        return false;
      } else {
        debugPrint('Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return false;
    }
  }

  /// Start automatic token refresh timer
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    
    // Check token every 5 minutes
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      try {
        final accessToken = await getAccessToken();
        if (accessToken != null && await isAccessTokenExpired()) {
          debugPrint('Automatic token refresh triggered');
          await refreshAccessToken();
        }
      } catch (e) {
        debugPrint('Automatic token refresh error: $e');
      }
    });
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _tokenExpiryKey),
        _secureStorage.delete(key: _refreshTokenExpiryKey),
      ]);
      
      debugPrint('Tokens cleared successfully');
    } catch (e) {
      debugPrint('Failed to clear tokens: $e');
    }
  }

  /// Decode JWT token payload (without verification)
  Map<String, dynamic>? decodeTokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      
      return jsonDecode(resp) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to decode token payload: $e');
      return null;
    }
  }

  /// Get token claims
  Map<String, dynamic>? getTokenClaims(String token) {
    return decodeTokenPayload(token);
  }

  /// Check if token has specific claim
  bool hasTokenClaim(String token, String claim) {
    final claims = getTokenClaims(token);
    return claims?.containsKey(claim) ?? false;
  }

  /// Get token expiration from payload
  DateTime? getTokenExpiration(String token) {
    final claims = getTokenClaims(token);
    if (claims != null && claims.containsKey('exp')) {
      final exp = claims['exp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    }
    return null;
  }

  /// Get token issued at time
  DateTime? getTokenIssuedAt(String token) {
    final claims = getTokenClaims(token);
    if (claims != null && claims.containsKey('iat')) {
      final iat = claims['iat'] as int;
      return DateTime.fromMillisecondsSinceEpoch(iat * 1000);
    }
    return null;
  }

  /// Get user ID from token
  String? getUserIdFromToken(String token) {
    final claims = getTokenClaims(token);
    return claims?['user_id'] as String? ?? claims?['sub'] as String?;
  }

  /// Get user email from token
  String? getUserEmailFromToken(String token) {
    final claims = getTokenClaims(token);
    return claims?['email'] as String?;
  }

  /// Check if token is valid (not expired and has required claims)
  bool isTokenValid(String token, {List<String>? requiredClaims}) {
    try {
      final claims = getTokenClaims(token);
      if (claims == null) return false;

      // Check expiration
      final exp = getTokenExpiration(token);
      if (exp != null && DateTime.now().isAfter(exp)) {
        return false;
      }

      // Check required claims
      if (requiredClaims != null) {
        for (final claim in requiredClaims) {
          if (!claims.containsKey(claim)) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }

  /// Dispose service
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    debugPrint('JWT Token Service disposed');
  }
}

class TokenStorageException implements Exception {
  final String message;
  TokenStorageException(this.message);
  
  @override
  String toString() => 'TokenStorageException: $message';
}

class TokenRefreshException implements Exception {
  final String message;
  TokenRefreshException(this.message);
  
  @override
  String toString() => 'TokenRefreshException: $message';
}

class TokenValidationException implements Exception {
  final String message;
  TokenValidationException(this.message);
  
  @override
  String toString() => 'TokenValidationException: $message';
}
