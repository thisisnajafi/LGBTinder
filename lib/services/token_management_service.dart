import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_models/auth_models.dart';

/// Token Management Service
/// 
/// This service handles secure token storage, validation, and management including:
/// - Bearer token storage and retrieval
/// - Refresh token management
/// - Token expiration checking
/// - Automatic token refresh
/// - Secure token cleanup
class TokenManagementService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresAtKey = 'expires_at';
  static const String _userIdKey = 'user_id';
  static const String _isAuthenticatedKey = 'is_authenticated';

  // Token types
  static const String _bearerTokenType = 'Bearer';
  static const String _profileCompletionTokenType = 'ProfileCompletion';

  // ============================================================================
  // TOKEN STORAGE
  // ============================================================================

  /// Store access token securely
  static Future<void> storeAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
    await _setIsAuthenticated(true);
  }

  /// Store refresh token securely
  static Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Store token type
  static Future<void> storeTokenType(String tokenType) async {
    await _secureStorage.write(key: _tokenTypeKey, value: tokenType);
  }

  /// Store token expiration time
  static Future<void> storeTokenExpiration(DateTime expiresAt) async {
    await _secureStorage.write(
      key: _expiresAtKey,
      value: expiresAt.toIso8601String(),
    );
  }

  /// Store user ID
  static Future<void> storeUserId(int userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId.toString());
  }

  /// Store complete token data
  static Future<void> storeTokenData({
    required String accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? expiresAt,
    int? userId,
  }) async {
    await Future.wait([
      storeAccessToken(accessToken),
      if (refreshToken != null) storeRefreshToken(refreshToken),
      if (tokenType != null) storeTokenType(tokenType),
      if (expiresAt != null) storeTokenExpiration(expiresAt),
      if (userId != null) storeUserId(userId),
    ]);
  }

  // ============================================================================
  // TOKEN RETRIEVAL
  // ============================================================================

  /// Get access token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Get token type
  static Future<String?> getTokenType() async {
    return await _secureStorage.read(key: _tokenTypeKey);
  }

  /// Get token expiration time
  static Future<DateTime?> getTokenExpiration() async {
    final expiresAtString = await _secureStorage.read(key: _expiresAtKey);
    if (expiresAtString != null) {
      try {
        return DateTime.parse(expiresAtString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Get user ID
  static Future<int?> getUserId() async {
    final userIdString = await _secureStorage.read(key: _userIdKey);
    if (userIdString != null) {
      return int.tryParse(userIdString);
    }
    return null;
  }

  /// Get all token data
  static Future<TokenData?> getAllTokenData() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    return TokenData(
      accessToken: accessToken,
      refreshToken: await getRefreshToken(),
      tokenType: await getTokenType(),
      expiresAt: await getTokenExpiration(),
      userId: await getUserId(),
    );
  }

  // ============================================================================
  // TOKEN VALIDATION
  // ============================================================================

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final isAuth = await _getIsAuthenticated();
    if (!isAuth) return false;

    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    return !isTokenExpired(accessToken);
  }

  /// Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true; // If we can't decode, consider it expired
    }
  }

  /// Check if token will expire soon (within 5 minutes)
  static bool isTokenExpiringSoon(String token) {
    try {
      final expirationDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final fiveMinutesFromNow = now.add(const Duration(minutes: 5));
      return expirationDate.isBefore(fiveMinutesFromNow);
    } catch (e) {
      return true; // If we can't decode, consider it expiring soon
    }
  }

  /// Get token expiration date
  static DateTime? getTokenExpirationDate(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      return null;
    }
  }

  /// Get token payload
  static Map<String, dynamic>? getTokenPayload(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  /// Validate token format
  static bool isValidTokenFormat(String token) {
    if (token.isEmpty) return false;
    
    // Check if it's a JWT token (has 3 parts separated by dots)
    final parts = token.split('.');
    if (parts.length != 3) return false;
    
    // Check if each part is base64 encoded
    try {
      for (final part in parts) {
        base64Url.decode(part);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // TOKEN REFRESH
  // ============================================================================

  /// Check if token needs refresh
  static Future<bool> needsRefresh() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    return isTokenExpiringSoon(accessToken);
  }

  /// Refresh access token using refresh token
  static Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/refresh'),
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
        
        if (data['success'] == true && data['data'] != null) {
          final authResult = AuthResult.fromJson(data['data']);
          
          // Store the new tokens
          await storeTokens(
            accessToken: authResult.token,
            refreshToken: authResult.refreshToken,
            tokenType: 'Bearer',
            expiresIn: 3600, // Default 1 hour
          );
          
          return authResult.token;
        }
      }
      
      // If refresh fails, clear tokens and return null
      await clearTokens();
      return null;
    } catch (e) {
      // If refresh fails, clear tokens and return null
      await clearTokens();
      return null;
    }
  }

  /// Get valid access token (refresh if needed)
  static Future<String?> getValidAccessToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    if (isTokenExpired(accessToken)) {
      // Token is expired, try to refresh
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        await storeAccessToken(newToken);
        return newToken;
      } else {
        // Refresh failed, clear tokens
        await clearAllTokens();
        return null;
      }
    }

    return accessToken;
  }

  // ============================================================================
  // TOKEN CLEANUP
  // ============================================================================

  /// Clear access token
  static Future<void> clearAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }

  /// Clear refresh token
  static Future<void> clearRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Clear token type
  static Future<void> clearTokenType() async {
    await _secureStorage.delete(key: _tokenTypeKey);
  }

  /// Clear token expiration
  static Future<void> clearTokenExpiration() async {
    await _secureStorage.delete(key: _expiresAtKey);
  }

  /// Clear user ID
  static Future<void> clearUserId() async {
    await _secureStorage.delete(key: _userIdKey);
  }

  /// Clear all tokens and authentication data
  static Future<void> clearAllTokens() async {
    await Future.wait([
      clearAccessToken(),
      clearRefreshToken(),
      clearTokenType(),
      clearTokenExpiration(),
      clearUserId(),
      _setIsAuthenticated(false),
    ]);
  }

  /// Logout user (clear all tokens)
  static Future<void> logout() async {
    await clearAllTokens();
  }

  // ============================================================================
  // TOKEN TYPES
  // ============================================================================

  /// Check if token is Bearer token
  static Future<bool> isBearerToken() async {
    final tokenType = await getTokenType();
    return tokenType == _bearerTokenType;
  }

  /// Check if token is profile completion token
  static Future<bool> isProfileCompletionToken() async {
    final tokenType = await getTokenType();
    return tokenType == _profileCompletionTokenType;
  }

  /// Get authorization header value
  static Future<String?> getAuthorizationHeader() async {
    final accessToken = await getValidAccessToken();
    if (accessToken == null) return null;

    final tokenType = await getTokenType();
    return '${tokenType ?? _bearerTokenType} $accessToken';
  }

  // ============================================================================
  // TOKEN SECURITY
  // ============================================================================

  /// Check if token is secure (not expired and valid format)
  static Future<bool> isTokenSecure() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    return isValidTokenFormat(accessToken) && !isTokenExpired(accessToken);
  }

  /// Get token security status
  static Future<TokenSecurityStatus> getTokenSecurityStatus() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      return TokenSecurityStatus.noToken;
    }

    if (!isValidTokenFormat(accessToken)) {
      return TokenSecurityStatus.invalidFormat;
    }

    if (isTokenExpired(accessToken)) {
      return TokenSecurityStatus.expired;
    }

    if (isTokenExpiringSoon(accessToken)) {
      return TokenSecurityStatus.expiringSoon;
    }

    return TokenSecurityStatus.secure;
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get time until token expires
  static Duration? getTimeUntilExpiration(String token) {
    final expirationDate = getTokenExpirationDate(token);
    if (expirationDate == null) return null;

    final now = DateTime.now();
    if (expirationDate.isBefore(now)) return Duration.zero;

    return expirationDate.difference(now);
  }

  /// Format token expiration time
  static String formatTokenExpiration(String token) {
    final timeUntilExpiration = getTimeUntilExpiration(token);
    if (timeUntilExpiration == null) return 'Unknown';

    if (timeUntilExpiration.inDays > 0) {
      return '${timeUntilExpiration.inDays} day${timeUntilExpiration.inDays == 1 ? '' : 's'}';
    } else if (timeUntilExpiration.inHours > 0) {
      return '${timeUntilExpiration.inHours} hour${timeUntilExpiration.inHours == 1 ? '' : 's'}';
    } else if (timeUntilExpiration.inMinutes > 0) {
      return '${timeUntilExpiration.inMinutes} minute${timeUntilExpiration.inMinutes == 1 ? '' : 's'}';
    } else {
      return '${timeUntilExpiration.inSeconds} second${timeUntilExpiration.inSeconds == 1 ? '' : 's'}';
    }
  }

  /// Get token info for debugging
  static Future<TokenInfo?> getTokenInfo() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    final payload = getTokenPayload(accessToken);
    final expirationDate = getTokenExpirationDate(accessToken);
    final timeUntilExpiration = getTimeUntilExpiration(accessToken);

    return TokenInfo(
      isValid: isValidTokenFormat(accessToken),
      isExpired: isTokenExpired(accessToken),
      isExpiringSoon: isTokenExpiringSoon(accessToken),
      expirationDate: expirationDate,
      timeUntilExpiration: timeUntilExpiration,
      payload: payload,
    );
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  /// Set authentication status
  static Future<void> _setIsAuthenticated(bool isAuthenticated) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAuthenticatedKey, isAuthenticated);
  }

  /// Get authentication status
  static Future<bool> _getIsAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }
}

// ============================================================================
// TOKEN DATA MODELS
// ============================================================================

/// Complete token data
class TokenData {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;
  final DateTime? expiresAt;
  final int? userId;

  const TokenData({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresAt,
    this.userId,
  });

  /// Check if token data is complete
  bool get isComplete {
    return accessToken.isNotEmpty && tokenType != null;
  }

  /// Check if token has refresh capability
  bool get hasRefreshToken {
    return refreshToken != null && refreshToken!.isNotEmpty;
  }

  /// Get authorization header value
  String get authorizationHeader {
    return '${tokenType ?? 'Bearer'} $accessToken';
  }
}

/// Token security status enumeration
enum TokenSecurityStatus {
  noToken,
  invalidFormat,
  expired,
  expiringSoon,
  secure,
}

/// Token security status extension
extension TokenSecurityStatusExtension on TokenSecurityStatus {
  String get description {
    switch (this) {
      case TokenSecurityStatus.noToken:
        return 'No token available';
      case TokenSecurityStatus.invalidFormat:
        return 'Invalid token format';
      case TokenSecurityStatus.expired:
        return 'Token has expired';
      case TokenSecurityStatus.expiringSoon:
        return 'Token expires soon';
      case TokenSecurityStatus.secure:
        return 'Token is secure';
    }
  }

  bool get isSecure {
    return this == TokenSecurityStatus.secure;
  }

  bool get needsRefresh {
    return this == TokenSecurityStatus.expiringSoon;
  }

  bool get isExpired {
    return this == TokenSecurityStatus.expired;
  }
}

/// Token information for debugging
class TokenInfo {
  final bool isValid;
  final bool isExpired;
  final bool isExpiringSoon;
  final DateTime? expirationDate;
  final Duration? timeUntilExpiration;
  final Map<String, dynamic>? payload;

  const TokenInfo({
    required this.isValid,
    required this.isExpired,
    required this.isExpiringSoon,
    this.expirationDate,
    this.timeUntilExpiration,
    this.payload,
  });

  /// Get security status
  TokenSecurityStatus get securityStatus {
    if (!isValid) return TokenSecurityStatus.invalidFormat;
    if (isExpired) return TokenSecurityStatus.expired;
    if (isExpiringSoon) return TokenSecurityStatus.expiringSoon;
    return TokenSecurityStatus.secure;
  }

  /// Format expiration time
  String get formattedExpiration {
    if (timeUntilExpiration == null) return 'Unknown';
    
    final duration = timeUntilExpiration!;
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds == 1 ? '' : 's'}';
    }
  }
}
