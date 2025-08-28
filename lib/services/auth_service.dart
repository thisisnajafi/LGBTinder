import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_requests.dart';
import '../models/auth_responses.dart';
import '../models/auth_user.dart';
import '../utils/error_handler.dart';

class AuthService {
  static const String _baseUrl = 'https://api.lgbtinder.com/api'; // Replace with your actual API base URL
  
  // Authentication endpoints
  static const String _loginEndpoint = '/auth/login';
  static const String _registerEndpoint = '/auth/register';
  static const String _sendVerificationEndpoint = '/auth/send-verification';
  static const String _verifyCodeEndpoint = '/auth/verify-registration-code';
  static const String _sendOtpEndpoint = '/auth/send-otp';
  static const String _verifyOtpEndpoint = '/auth/verify-otp';
  static const String _resendVerificationEndpoint = '/auth/resend-verification';
  static const String _refreshTokenEndpoint = '/auth/refresh-token';
  static const String _logoutEndpoint = '/auth/logout';

  /// Login with email and password
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_loginEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
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
        Uri.parse('$_baseUrl$_sendOtpEndpoint'),
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
        Uri.parse('$_baseUrl$_verifyOtpEndpoint'),
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
      final response = await http.post(
        Uri.parse('$_baseUrl$_registerEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 409) {
        throw AuthException('User already exists with this email or phone number');
      } else {
        throw ApiException('Registration failed: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error during registration: $e');
    }
  }

  /// Send verification code to email
  static Future<bool> sendVerification(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_sendVerificationEndpoint'),
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
        Uri.parse('$_baseUrl$_verifyCodeEndpoint'),
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
        Uri.parse('$_baseUrl$_resendVerificationEndpoint'),
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
        Uri.parse('$_baseUrl$_refreshTokenEndpoint'),
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
        Uri.parse('$_baseUrl$_logoutEndpoint'),
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
        Uri.parse('$_baseUrl/user/profile'),
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
        Uri.parse('$_baseUrl/user/profile'),
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
        Uri.parse('$_baseUrl/auth/check-email?email=${Uri.encodeComponent(email)}'),
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
        Uri.parse('$_baseUrl/auth/check-phone?phone_number=${Uri.encodeComponent(phoneNumber)}&country_code=${Uri.encodeComponent(countryCode)}'),
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
} 