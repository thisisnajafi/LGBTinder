import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_user.dart';
import '../models/auth_requests.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';

class AuthProvider extends ChangeNotifier {
  // Secure storage for tokens
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';
  
  // Authentication state
  bool _isAuthenticated = false;
  bool _isLoading = false;
  AuthUser? _user;
  String? _accessToken;
  String? _refreshToken;
  String? _authError;
  DateTime? _tokenExpiry;
  
  // Token refresh timer
  Timer? _tokenRefreshTimer;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  AuthUser? get user => _user;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get authError => _authError;
  DateTime? get tokenExpiry => _tokenExpiry;
  
  // Check if token is expired or will expire soon (within 5 minutes)
  bool get isTokenExpired {
    if (_tokenExpiry == null) return true;
    return DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 5)));
  }
  
  // Check if user profile is completed
  bool get isProfileCompleted => _user?.profileCompleted ?? false;
  
  // Check if email is verified
  bool get isEmailVerified => _user?.emailVerified ?? false;
  
  // Check if phone is verified
  bool get isPhoneVerified => _user?.phoneVerified ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state from secure storage
  Future<void> _initializeAuth() async {
    try {
      _setLoading(true);
      
      // Load tokens from secure storage
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      final userData = await _secureStorage.read(key: _userKey);
      final tokenExpiryStr = await _secureStorage.read(key: _tokenExpiryKey);
      
      if (accessToken != null && refreshToken != null && userData != null) {
        _accessToken = accessToken;
        _refreshToken = refreshToken;
        _user = AuthUser.fromJson(jsonDecode(userData));
        
        if (tokenExpiryStr != null) {
          _tokenExpiry = DateTime.parse(tokenExpiryStr);
        }
        
        // Check if token is expired
        if (isTokenExpired) {
          // Try to refresh token
          await _refreshAccessToken();
        } else {
          _isAuthenticated = true;
          _startTokenRefreshTimer();
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
      await _clearAuthData();
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password
  Future<bool> login(LoginRequest request) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await AuthService.login(request);
      
      // Store authentication data
      await _storeAuthData(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
        expiresIn: response.expiresIn,
      );
      
      _isAuthenticated = true;
      _startTokenRefreshTimer();
      
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with phone number (send OTP)
  Future<bool> sendOtp(PhoneLoginRequest request) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await AuthService.sendOtp(request);
      
      if (success) {
        _clearError();
        return true;
      } else {
        _setError('Failed to send OTP');
        return false;
      }
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to send OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify OTP and login with phone
  Future<bool> verifyOtp(OtpVerificationRequest request) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await AuthService.verifyOtp(request);
      
      if (response.success && response.accessToken != null && response.refreshToken != null) {
        // Store authentication data
        await _storeAuthData(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
          user: response.user,
          expiresIn: 3600, // Default 1 hour for OTP login
        );
        
        _isAuthenticated = true;
        _startTokenRefreshTimer();
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('OTP verification failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register new user
  Future<bool> register(RegisterRequest request) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await AuthService.register(request);
      
      // Store authentication data if verification is not required
      if (!response.requiresVerification) {
        // This would typically happen if email verification is disabled
        // For now, we'll require verification
        _setError('Email verification required. Please check your email.');
        return false;
      }
      
      _setError('Registration successful! Please check your email for verification.');
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Send verification code to email
  Future<bool> sendVerification(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await AuthService.sendVerification(email);
      
      if (success) {
        _clearError();
        return true;
      } else {
        _setError('Failed to send verification code');
        return false;
      }
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to send verification: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verify email verification code
  Future<bool> verifyCode(VerificationRequest request) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await AuthService.verifyCode(request);
      
      if (response.success && response.accessToken != null && response.refreshToken != null) {
        // Store authentication data
        await _storeAuthData(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
          user: response.user,
          expiresIn: 3600, // Default 1 hour
        );
        
        _isAuthenticated = true;
        _startTokenRefreshTimer();
        
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Verification failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resend verification code
  Future<bool> resendVerification(ResendVerificationRequest request) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await AuthService.resendVerification(request);
      
      if (response.success) {
        _clearError();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to resend verification: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh access token
  Future<bool> _refreshAccessToken() async {
    try {
      if (_refreshToken == null) {
        throw AuthException('No refresh token available');
      }
      
      final response = await AuthService.refreshToken(_refreshToken!);
      
      // Update tokens
      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;
      _tokenExpiry = DateTime.now().add(Duration(seconds: response.expiresIn));
      
      // Store updated tokens
      await _secureStorage.write(key: _accessTokenKey, value: _accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: _refreshToken);
      await _secureStorage.write(key: _tokenExpiryKey, value: _tokenExpiry!.toIso8601String());
      
      _startTokenRefreshTimer();
      return true;
    } catch (e) {
      // Refresh failed, user needs to login again
      await logout();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Call logout API if we have a token
      if (_accessToken != null) {
        await AuthService.logout(_accessToken!);
      }
    } catch (e) {
      // Ignore logout API errors
    }
    
    // Clear all authentication data
    await _clearAuthData();
    
    // Stop token refresh timer
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    
    // Reset state
    _isAuthenticated = false;
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    _clearError();
    
    notifyListeners();
  }

  /// Store authentication data in secure storage
  Future<void> _storeAuthData({
    required String accessToken,
    required String refreshToken,
    required AuthUser? user,
    required int expiresIn,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _user = user;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
    
    // Store in secure storage
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    if (user != null) {
      await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
    }
    await _secureStorage.write(key: _tokenExpiryKey, value: _tokenExpiry!.toIso8601String());
  }

  /// Clear all authentication data from secure storage
  Future<void> _clearAuthData() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userKey);
    await _secureStorage.delete(key: _tokenExpiryKey);
  }

  /// Start token refresh timer
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    
    if (_tokenExpiry != null) {
      final timeUntilRefresh = _tokenExpiry!.difference(DateTime.now()).inSeconds - 300; // 5 minutes before expiry
      
      if (timeUntilRefresh > 0) {
        _tokenRefreshTimer = Timer(Duration(seconds: timeUntilRefresh), () {
          _refreshAccessToken();
        });
      }
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _authError = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _authError = null;
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      if (_accessToken == null) {
        throw AuthException('No access token available');
      }
      
      final updatedUser = await AuthService.updateProfile(_accessToken!, profileData);
      _user = updatedUser;
      
      // Update stored user data
      if (_user != null) {
        await _secureStorage.write(key: _userKey, value: jsonEncode(_user!.toJson()));
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
    }
  }

  /// Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      return await AuthService.checkEmailExists(email);
    } catch (e) {
      return false;
    }
  }

  /// Check if phone number exists
  Future<bool> checkPhoneExists(String phoneNumber, String countryCode) async {
    try {
      return await AuthService.checkPhoneExists(phoneNumber, countryCode);
    } catch (e) {
      return false;
    }
  }

  /// Get valid access token (refresh if needed)
  Future<String?> getValidAccessToken() async {
    if (_accessToken == null) return null;
    
    if (isTokenExpired) {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) return null;
    }
    
    return _accessToken;
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }
} 