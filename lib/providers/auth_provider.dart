import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_user.dart';
import '../models/auth_requests.dart';
import '../models/auth_responses.dart';
import '../services/auth_service.dart';
import '../services/email_verification_service.dart';
import '../services/jwt_token_service.dart';
import '../services/social_auth_service.dart';
import '../utils/error_handler.dart';

class AuthProvider extends ChangeNotifier {
  // Enhanced JWT token service
  final JWTTokenService _tokenService = JWTTokenService();
  
  // Secure storage for user data
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Storage keys
  static const String _userKey = 'user_data';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  
  // Authentication state
  bool _isAuthenticated = false;
  bool _isLoading = false;
  AuthUser? _user;
  String? _authError;
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  Timer? _tokenRefreshTimer;
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  AuthUser? get user => _user;
  String? get authError => _authError;
  
  // Token getters using JWT service
  Future<String?> get accessToken => _tokenService.getAccessToken();
  Future<String?> get refreshToken => _tokenService.getRefreshToken();
  Future<DateTime?> get tokenExpiry => _tokenService.getTokenExpiry();
  
  // Synchronous token getter for immediate use
  Future<String?> getAccessToken() async => await _tokenService.getAccessToken();
  
  // Check if token is expired
  Future<bool> get isTokenExpired => _tokenService.isAccessTokenExpired();
  
  // Check if user profile is completed
  bool get isProfileCompleted => _user?.profileCompleted ?? false;
  
  // Check if email is verified
  bool get isEmailVerified => _user?.emailVerified ?? false;
  
  // Check if phone is verified
  bool get isPhoneVerified => _user?.phoneVerified ?? false;

  AuthProvider() {
    // Initialize auth state asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
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
        if (await isTokenExpired) {
          // Try to refresh token
          // await _refreshAccessToken(); // Not implemented in backend
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
      print('🏁 AuthProvider.login() started');
      _setLoading(true);
      _clearError();
      
      print('📡 Calling AuthService.login()...');
      final response = await AuthService.login(request);
      print('📡 AuthService.login() response received');
      
      // Store authentication data
      await storeAuthData(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
        expiresIn: response.expiresIn,
      );
      
      _isAuthenticated = true;
      
      print('✅ Login successful in AuthProvider');
      notifyListeners();
      return true;
    } on AppException catch (e) {
      print('💥 AuthProvider login AppException: ${e.message}');
      _setError('Invalid email or password. Please try again.');
      return false;
    } catch (e) {
      print('💥 AuthProvider login Exception: $e');
      _setError('Network error. Please check your internet connection.');
      return false;
    } finally {
      print('🏁 AuthProvider.login() completed');
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
        await storeAuthData(
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
      print('🏁 AuthProvider.register() started');
      _setLoading(true);
      _clearError();
      
      print('📡 Calling AuthService.register()...');
      final response = await AuthService.register(request);
      print('📡 AuthService.register() response: $response');
      
      if (response.isSuccess) {
        print('✅ Registration successful in AuthProvider');
        _clearError();
        return true;
      } else if (response.hasErrors) {
        // Handle validation errors
        print('❌ Registration validation errors: ${response.errors}');
        final errorMessages = response.errors!.entries
            .map((e) => e.value.join(', '))
            .join('\n');
        print('📋 Detailed validation errors: $errorMessages');
        
        // Set user-friendly error message instead of technical details
        _setError('Please check your information and try again.');
        return false;
      } else if (response.isServerError) {
        print('❌ Registration server error: ${response.message}');
        _setError('Our servers are experiencing issues. Please try again later.');
        return false;
      } else {
        print('❌ Registration failed: ${response.message}');
        _setError('Unable to create account. Please try again.');
        return false;
      }
    } on AppException catch (e) {
      print('💥 AuthProvider registration AppException: ${e.message}');
      _setError('Unable to create account. Please try again.');
      return false;
    } catch (e) {
      print('💥 AuthProvider registration Exception: $e');
      _setError('Network error. Please check your internet connection.');
      return false;
    } finally {
      print('🏁 AuthProvider.register() completed');
      _setLoading(false);
    }
  }

  /// Send verification code to email
  Future<bool> sendVerification(String email) async {
    try {
      print('🏁 AuthProvider.sendVerification() started');
      print('📧 Email: $email');
      _setLoading(true);
      _clearError();
      
      print('📡 Calling AuthService.sendVerification()...');
      final success = await AuthService.sendVerification(email);
      print('📡 AuthService.sendVerification() result: $success');
      
      if (success) {
        print('✅ Send verification successful in AuthProvider');
        _clearError();
        return true;
      } else {
        print('❌ Send verification failed but no exception thrown');
        _setError('Unable to send verification code. Please try again.');
        return false;
      }
    } on AppException catch (e) {
      print('💥 AuthProvider sendVerification AppException: ${e.message}');
      _setError('Unable to send verification code. Please try again.');
      return false;
    } catch (e) {
      print('💥 AuthProvider sendVerification Exception: $e');
      _setError('Network error. Please check your internet connection.');
      return false;
    } finally {
      print('🏁 AuthProvider.sendVerification() completed');
      _setLoading(false);
    }
  }

  /// Verify email verification code
  Future<VerificationResponse> verifyCode(VerificationRequest request) async {
    try {
      print('🏁 AuthProvider.verifyCode() started');
      print('📧 Email: ${request.email}');
      print('🔢 Code: ${request.code}');
      _setLoading(true);
      _clearError();
      
      print('📡 Calling AuthService.verifyCode()...');
      final response = await AuthService.verifyCode(request);
      print('📡 AuthService.verifyCode() response: $response');
      
      if (response.status) {
        print('✅ Verification successful in AuthProvider');
        // Store the profile completion token if available
        if (response.data?.token != null) {
          await storeAuthData(
            accessToken: response.data!.token!,
            refreshToken: response.data!.token!, // Use same token for now
            user: null, // User data not available in this response
            expiresIn: 3600, // Default 1 hour
          );
          
          _isAuthenticated = true;
          _startTokenRefreshTimer();
          print('🔑 Profile completion token stored');
        }
        
        print('📋 Profile completion needed: ${response.data?.needsProfileCompletion}');
        
        notifyListeners();
        return response;
      } else {
        print('❌ Verification failed: ${response.message}');
        _setError(response.message);
        return response;
      }
    } on AppException catch (e) {
      print('💥 AuthProvider verifyCode AppException: ${e.message}');
      _setError(e.message);
      rethrow;
    } catch (e) {
      print('💥 AuthProvider verifyCode Exception: $e');
      _setError('Network error. Please check your internet connection.');
      rethrow;
    } finally {
      print('🏁 AuthProvider.verifyCode() completed');
      _setLoading(false);
    }
  }

  /// Send login code to email
  Future<EmailVerificationResponse> sendLoginCode(String email) async {
    try {
      print('🏁 AuthProvider.sendLoginCode() started');
      print('📧 Email: $email');
      _setLoading(true);
      _clearError();
      
      print('📡 Calling EmailVerificationService.sendLoginCode()...');
      final response = await EmailVerificationService.sendLoginCode(email);
      print('📡 EmailVerificationService.sendLoginCode() response: $response');
      
      if (response.status) {
        print('✅ Login code sent successfully in AuthProvider');
        notifyListeners();
        return response;
      } else {
        print('❌ Failed to send login code: ${response.message}');
        _setError(response.message);
        return response;
      }
    } on AppException catch (e) {
      print('💥 AuthProvider sendLoginCode AppException: ${e.message}');
      _setError(e.message);
      rethrow;
    } catch (e) {
      print('💥 AuthProvider sendLoginCode Exception: $e');
      _setError('Network error. Please check your internet connection.');
      rethrow;
    } finally {
      print('🏁 AuthProvider.sendLoginCode() completed');
      _setLoading(false);
    }
  }

  /// Verify login code
  Future<LoginCodeResponse> verifyLoginCode(String email, String code) async {
    try {
      print('🏁 AuthProvider.verifyLoginCode() started');
      print('📧 Email: $email');
      print('🔢 Code: $code');
      _setLoading(true);
      _clearError();
      
      print('📡 Calling EmailVerificationService.verifyLoginCode()...');
      final response = await EmailVerificationService.verifyLoginCode(email, code);
      print('📡 EmailVerificationService.verifyLoginCode() response: $response');
      
      if (response.status && response.data != null) {
        print('✅ Login code verification successful in AuthProvider');
        // Store authentication data
        await storeAuthData(
          accessToken: response.data!.token,
          refreshToken: response.data!.token, // Use same token for now
          user: response.data!.user,
          expiresIn: response.data!.expiresIn,
        );
        
        _isAuthenticated = true;
        _startTokenRefreshTimer();
        notifyListeners();
        return response;
      } else {
        print('❌ Login code verification failed: ${response.message}');
        _setError(response.message);
        return response;
      }
    } on AppException catch (e) {
      print('💥 AuthProvider verifyLoginCode AppException: ${e.message}');
      _setError(e.message);
      rethrow;
    } catch (e) {
      print('💥 AuthProvider verifyLoginCode Exception: $e');
      _setError('Network error. Please check your internet connection.');
      rethrow;
    } finally {
      print('🏁 AuthProvider.verifyLoginCode() completed');
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

  /// Refresh access token - Not implemented in backend
  // Future<bool> _refreshAccessToken() async {
  //   try {
  //     if (_refreshToken == null) {
  //       throw AuthException('No refresh token available');
  //     }
  //     
  //     final response = await AuthService.refreshToken(_refreshToken!);
  //     
  //     // Update tokens
  //     _accessToken = response.accessToken;
  //     _refreshToken = response.refreshToken;
  //     _tokenExpiry = DateTime.now().add(Duration(seconds: response.expiresIn));
  //     
  //     // Store updated tokens
  //     await _secureStorage.write(key: _accessTokenKey, value: _accessToken);
  //     await _secureStorage.write(key: _refreshTokenKey, value: _refreshToken);
  //     await _secureStorage.write(key: _tokenExpiryKey, value: _tokenExpiry!.toIso8601String());
  //     
  //     _startTokenRefreshTimer();
  //     return true;
  //   } catch (e) {
  //     // Refresh failed, user needs to login again
  //     await logout();
  //     return false;
  //     }
  //   }
  // }

  /// Login with Google
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      print('🔵 AuthProvider.loginWithGoogle() started');
      _setLoading(true);
      _clearError();
      
      final result = await SocialAuthService.signInWithGoogle();
      
      if (result == null) {
        // User cancelled
        print('❌ Google Sign-In cancelled');
        _setLoading(false);
        return null;
      }
      
      if (result['success'] == true) {
        // Store authentication data
        await storeAuthData(
          accessToken: result['token'] ?? '',
          refreshToken: result['refresh_token'] ?? result['token'] ?? '',
          user: result['user'] != null ? AuthUser.fromJson(result['user']) : null,
          expiresIn: result['expires_in'] ?? 3600,
        );
        
        _isAuthenticated = true;
        _startTokenRefreshTimer();
        
        print('✅ Google Sign-In successful in AuthProvider');
        notifyListeners();
        return result;
      } else {
        _setError('Google Sign-In failed');
        return result;
      }
    } on AppException catch (e) {
      print('💥 AuthProvider loginWithGoogle AppException: ${e.message}');
      _setError(e.message);
      return {'success': false, 'error': e.message};
    } catch (e) {
      print('💥 AuthProvider loginWithGoogle Exception: $e');
      _setError('Google Sign-In failed: ${e.toString()}');
      return {'success': false, 'error': e.toString()};
    } finally {
      print('🏁 AuthProvider.loginWithGoogle() completed');
      _setLoading(false);
    }
  }

  /// Login with Apple
  Future<Map<String, dynamic>?> loginWithApple() async {
    try {
      print('🍎 AuthProvider.loginWithApple() started');
      _setLoading(true);
      _clearError();
      
      final result = await SocialAuthService.signInWithApple();
      
      if (result == null) {
        // User cancelled
        print('❌ Apple Sign-In cancelled');
        _setLoading(false);
        return null;
      }
      
      if (result['success'] == true) {
        // Store authentication data
        await storeAuthData(
          accessToken: result['token'] ?? '',
          refreshToken: result['refresh_token'] ?? result['token'] ?? '',
          user: result['user'] != null ? AuthUser.fromJson(result['user']) : null,
          expiresIn: result['expires_in'] ?? 3600,
        );
        
        _isAuthenticated = true;
        _startTokenRefreshTimer();
        
        print('✅ Apple Sign-In successful in AuthProvider');
        notifyListeners();
        return result;
      } else {
        _setError('Apple Sign-In failed');
        return result;
      }
    } on AppException catch (e) {
      print('💥 AuthProvider loginWithApple AppException: ${e.message}');
      _setError(e.message);
      return {'success': false, 'error': e.message};
    } catch (e) {
      print('💥 AuthProvider loginWithApple Exception: $e');
      _setError('Apple Sign-In failed: ${e.toString()}');
      return {'success': false, 'error': e.toString()};
    } finally {
      print('🏁 AuthProvider.loginWithApple() completed');
      _setLoading(false);
    }
  }

  /// Login with Facebook
  Future<Map<String, dynamic>?> loginWithFacebook() async {
    try {
      print('🔵 AuthProvider.loginWithFacebook() started');
      _setLoading(true);
      _clearError();
      
      final result = await SocialAuthService.signInWithFacebook();
      
      if (result == null) {
        // User cancelled
        print('❌ Facebook Sign-In cancelled');
        _setLoading(false);
        return null;
      }
      
      if (result['success'] == true) {
        // Store authentication data
        await storeAuthData(
          accessToken: result['token'] ?? '',
          refreshToken: result['refresh_token'] ?? result['token'] ?? '',
          user: result['user'] != null ? AuthUser.fromJson(result['user']) : null,
          expiresIn: result['expires_in'] ?? 3600,
        );
        
        _isAuthenticated = true;
        _startTokenRefreshTimer();
        
        print('✅ Facebook Sign-In successful in AuthProvider');
        notifyListeners();
        return result;
      } else {
        _setError('Facebook Sign-In failed');
        return result;
      }
    } on AppException catch (e) {
      print('💥 AuthProvider loginWithFacebook AppException: ${e.message}');
      _setError(e.message);
      return {'success': false, 'error': e.message};
    } catch (e) {
      print('💥 AuthProvider loginWithFacebook Exception: $e');
      _setError('Facebook Sign-In failed: ${e.toString()}');
      return {'success': false, 'error': e.toString()};
    } finally {
      print('🏁 AuthProvider.loginWithFacebook() completed');
      _setLoading(false);
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
  Future<void> storeAuthData({
    required String accessToken,
    required String refreshToken,
    required AuthUser? user,
    required int expiresIn,
  }) async {
    _user = user;
    
    // Store tokens using JWT service
    await _tokenService.storeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresIn: expiresIn,
    );
    
    // Store user data
    if (user != null) {
      await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
    }
  }

  /// Clear all authentication data from secure storage
  Future<void> _clearAuthData() async {
    await _tokenService.clearTokens();
    await _secureStorage.delete(key: _userKey);
  }

  /// Initialize token service
  Future<void> initializeTokenService() async {
    await _tokenService.initialize(
      onTokenRefreshed: (newAccessToken, newRefreshToken) {
        debugPrint('Token refreshed successfully');
        notifyListeners();
      },
      onTokenRefreshFailed: () {
        debugPrint('Token refresh failed - user needs to re-authenticate');
        logout();
      },
    );
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

  /// Start token refresh timer
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    // Set timer to refresh token 5 minutes before expiry
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
        // Token refresh logic would go here if implemented in backend
        timer.cancel();
      }
    });
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
    return await _tokenService.getValidAccessToken();
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await AuthService.sendPasswordResetEmail(email);
      
      if (success) {
        return true;
      } else {
        _setError('Failed to send password reset email');
        return false;
      }
    } catch (e) {
      _setError('Failed to send password reset email: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _tokenService.dispose();
    super.dispose();
  }
} 