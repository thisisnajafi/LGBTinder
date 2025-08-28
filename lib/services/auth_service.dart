import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_requests.dart';
import '../models/auth_responses.dart';
import '../models/auth_user.dart';
import '../utils/error_handler.dart';
import '../config/api_config.dart';

class AuthService {
  // Authentication endpoints
  static const String _loginEndpoint = ApiConfig.login;
  static const String _registerEndpoint = ApiConfig.register;
  static const String _sendVerificationEndpoint = ApiConfig.sendVerification;
  static const String _verifyCodeEndpoint = ApiConfig.verifyCode;
  static const String _sendOtpEndpoint = ApiConfig.sendOtp;
  static const String _verifyOtpEndpoint = ApiConfig.verifyOtp;
  static const String _resendVerificationEndpoint = ApiConfig.resendVerification;
  static const String _refreshTokenEndpoint = ApiConfig.refreshToken;
  static const String _logoutEndpoint = ApiConfig.logout;

  /// Login with email and password
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_loginEndpoint)),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: request.toFormData(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid email or password');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Login failed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error during login: $e');
    }
  }

  /// Login with phone number (send OTP)
  static Future<bool> sendOtp(PhoneLoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_sendOtpEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] as bool? ?? false;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid phone number',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        throw RateLimitException('Too many OTP requests. Please wait before trying again.');
      } else {
        throw ApiException('Failed to send OTP: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending OTP: $e');
    }
  }

  /// Verify OTP and login with phone
  static Future<OtpVerificationResponse> verifyOtp(OtpVerificationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_verifyOtpEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OtpVerificationResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid OTP',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid or expired OTP');
      } else {
        throw ApiException('OTP verification failed: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error during OTP verification: $e');
    }
  }

  /// Register new user
  static Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      print('🚀 AuthService.register() starting');
      print('🌐 Registration URL: ${ApiConfig.getUrl(_registerEndpoint)}');
      print('🔧 Base URL: ${ApiConfig.baseUrl}');
      print('🔧 Register Endpoint: $_registerEndpoint');
      print('📦 Request payload (JSON): ${jsonEncode(request.toJson())}');
      print('📦 Request payload (Form): ${request.toFormData()}');
      
      // Try form-urlencoded first since Postman works with this format
      http.Response response;
      try {
        response = await http.post(
          Uri.parse(ApiConfig.getUrl(_registerEndpoint)),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: request.toFormData(),
        );
        print('📋 Used form-urlencoded content type');
      } catch (e) {
        print('⚠️ Form-urlencoded failed, trying JSON: $e');
        // Fallback to JSON if form-urlencoded fails
        response = await http.post(
          Uri.parse(ApiConfig.getUrl(_registerEndpoint)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(request.toJson()),
        );
        print('📋 Used JSON content type as fallback');
      }
      
      print('📥 Registration response status: ${response.statusCode}');
      print('📥 Registration response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registration successful');
        final data = jsonDecode(response.body);
        print('📋 Parsed response data: $data');
        print('📋 Response data type: ${data.runtimeType}');
        if (data['data'] != null) {
          print('📋 Data section: ${data['data']}');
          print('📋 User ID type: ${data['data']['user_id'].runtimeType}');
        }
        return RegisterResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        print('❌ Registration validation error');
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 500) {
        print('❌ Registration server error');
        final data = jsonDecode(response.body);
        throw ApiException(data['message'] ?? 'Registration failed');
      } else {
        print('❌ Registration failed with status: ${response.statusCode}');
        throw ApiException('Registration failed: ${response.statusCode}');
      }
    } on ValidationException catch (e) {
      print('💥 AuthService registration ValidationException: ${e.message}');
      rethrow;
    } on AuthException catch (e) {
      print('💥 AuthService registration AuthException: ${e.message}');
      rethrow;
    } on ApiException catch (e) {
      print('💥 AuthService registration ApiException: ${e.message}');
      rethrow;
    } catch (e) {
      print('💥 AuthService registration NetworkException: $e');
      throw NetworkException('Network error during registration: $e');
    }
  }

  /// Send verification code to email
  static Future<bool> sendVerification(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_sendVerificationEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] as bool? ?? false;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid email address',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        throw RateLimitException('Too many verification requests. Please wait before trying again.');
      } else {
        throw ApiException('Failed to send verification: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending verification: $e');
    }
  }

  /// Verify email verification code
  static Future<VerificationResponse> verifyCode(VerificationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_verifyCodeEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VerificationResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid verification code',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid or expired verification code');
      } else {
        throw ApiException('Verification failed: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error during verification: $e');
    }
  }

  /// Resend verification code
  static Future<ResendVerificationResponse> resendVerification(ResendVerificationRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_resendVerificationEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ResendVerificationResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid email address',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        return ResendVerificationResponse(
          success: false,
          message: data['message'] ?? 'Too many requests',
          cooldownSeconds: data['cooldown_seconds'] ?? 60,
        );
      } else {
        throw ApiException('Failed to resend verification: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while resending verification: $e');
    }
  }

  /// Refresh access token
  static Future<TokenRefreshResponse> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_refreshTokenEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TokenRefreshResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid or expired refresh token');
      } else {
        throw ApiException('Token refresh failed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error during token refresh: $e');
    }
  }

  /// Logout user
  static Future<bool> logout(String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(_logoutEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      // Logout should not fail even if network is down
      // Just return true to indicate successful logout
      return true;
    }
  }

  /// Get current user profile (requires authentication)
  static Future<AuthUser> getCurrentUser(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profile)),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthUser.fromJson(data['user'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid or expired access token');
      } else {
        throw ApiException('Failed to get user profile: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while getting user profile: $e');
    }
  }

  /// Update user profile (requires authentication)
  static Future<AuthUser> updateProfile(String accessToken, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profile)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AuthUser.fromJson(data['user'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid or expired access token');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update profile: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating profile: $e');
    }
  }

  /// Check if email exists
  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.checkEmail)}?email=${Uri.encodeComponent(email)}'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] as bool? ?? false;
      } else {
        return false; // Assume email doesn't exist if check fails
      }
    } catch (e) {
      return false; // Assume email doesn't exist if check fails
    }
  }

  /// Check if phone number exists
  static Future<bool> checkPhoneExists(String phoneNumber, String countryCode) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getUrl(ApiConfig.checkPhone)}?phone_number=${Uri.encodeComponent(phoneNumber)}&country_code=${Uri.encodeComponent(countryCode)}'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] as bool? ?? false;
      } else {
        return false; // Assume phone doesn't exist if check fails
      }
    } catch (e) {
      return false; // Assume phone doesn't exist if check fails
    }
  }

  /// Send password reset email
  static Future<bool> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.forgotPassword)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] as bool? ?? false;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid email address',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        throw RateLimitException('Too many password reset requests. Please wait before trying again.');
      } else {
        throw ApiException('Failed to send password reset email: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending password reset email: $e');
    }
  }

  /// Verify login code (for 2FA or email verification during login)
  static Future<LoginResponse> verifyLoginCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.verifyLoginCode)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid verification code',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 404) {
        throw ApiException('Login session not found');
      } else {
        throw ApiException('Failed to verify login code: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while verifying login code: $e');
    }
  }

  /// Resend verification email for existing user
  static Future<bool> resendVerificationExisting(String email, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.resendVerificationExisting)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid email address',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        throw RateLimitException('Too many verification requests. Please wait before trying again.');
      } else {
        throw ApiException('Failed to resend verification: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while resending verification: $e');
    }
  }

  /// Reset password with reset token
  static Future<bool> resetPassword(String token, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.resetPassword)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid reset token or password',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 404) {
        throw ApiException('Invalid or expired reset token');
      } else {
        throw ApiException('Failed to reset password: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while resetting password: $e');
    }
  }

  /// Change password for authenticated user
  static Future<bool> changePassword(String currentPassword, String newPassword, String passwordConfirmation, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.changePassword)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid password',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to change password: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while changing password: $e');
    }
  }

  /// Delete user account
  static Future<bool> deleteAccount(String password, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.deleteAccount)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid password',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to delete account: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting account: $e');
    }
  }

  /// Complete user registration (additional profile information)
  static Future<bool> completeRegistration(Map<String, dynamic> profileData, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.completeRegistration)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to complete registration: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while completing registration: $e');
    }
  }
} 