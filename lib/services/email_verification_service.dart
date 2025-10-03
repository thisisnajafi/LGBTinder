import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_responses.dart';
import '../models/auth_requests.dart';
import '../utils/error_handler.dart';

/// Comprehensive email verification service implementing all API endpoints
/// from the email verification API documentation
class EmailVerificationService {
  
  /// Send login code to email
  /// POST /api/send-login-code
  static Future<EmailVerificationResponse> sendLoginCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.sendLoginCode)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EmailVerificationResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid email address',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        throw RateLimitException(
          data['message'] ?? 'Too many login code requests. Please wait before trying again.',
          cooldownSeconds: data['data']?['retry_after'] ?? 60,
        );
      } else {
        throw ApiException('Failed to send login code: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending login code: $e');
    }
  }

  /// Verify login code
  /// POST /api/verify-login-code
  static Future<LoginCodeResponse> verifyLoginCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.verifyLoginCode)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LoginCodeResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid verification code',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid or expired verification code');
      } else {
        throw ApiException('Failed to verify login code: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error during login code verification: $e');
    }
  }

  /// Resend verification for new users
  /// POST /api/resend-verification
  static Future<EmailVerificationResponse> resendVerification(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.resendVerification)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EmailVerificationResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid email address',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        throw RateLimitException(
          data['message'] ?? 'Too many verification requests. Please wait before trying again.',
          cooldownSeconds: data['data']?['retry_after'] ?? 60,
        );
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

  /// Resend verification for existing users
  /// POST /api/resend-verification-existing
  static Future<EmailVerificationResponse> resendVerificationExisting(String email, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.resendVerificationExisting)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EmailVerificationResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid email address',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        throw RateLimitException(
          data['message'] ?? 'Too many verification requests. Please wait before trying again.',
          cooldownSeconds: data['data']?['retry_after'] ?? 60,
        );
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

  /// Verify registration code
  /// POST /api/send-verification
  static Future<VerificationResponse> verifyRegistrationCode(String email, String code) async {
    try {
      final request = VerificationRequest(email: email, code: code);
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.sendVerification)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
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
        throw ApiException('Failed to verify registration code: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error during registration verification: $e');
    }
  }

  /// Send password reset OTP
  /// POST /api/send-otp
  static Future<EmailVerificationResponse> sendPasswordResetOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.sendOtp)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EmailVerificationResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid email address',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        throw RateLimitException(
          data['message'] ?? 'Too many OTP requests. Please wait before trying again.',
          cooldownSeconds: data['data']?['retry_after'] ?? 60,
        );
      } else {
        throw ApiException('Failed to send password reset OTP: ${response.statusCode}');
      }
    } on ValidationException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending password reset OTP: $e');
    }
  }

  /// Verify password reset OTP
  /// POST /api/verify-otp
  static Future<PasswordResetOtpResponse> verifyPasswordResetOtp(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.verifyOtp)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PasswordResetOtpResponse.fromJson(data);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid or expired OTP',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 401) {
        throw AuthException('Invalid or expired OTP');
      } else {
        throw ApiException('Failed to verify password reset OTP: ${response.statusCode}');
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

  /// Reset password with reset token
  /// POST /api/reset-password
  static Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.resetPassword)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          'email': email,
          'reset_token': resetToken,
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

  /// Check if email exists in system
  static Future<bool> checkEmailExists(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.checkEmail)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({'email': email}),
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

  /// Get rate limit information for an endpoint
  static Map<String, dynamic> parseRateLimitInfo(Map<String, dynamic> responseData) {
    final data = responseData['data'] as Map<String, dynamic>?;
    if (data == null) return {};

    return {
      'retry_after': data['retry_after'] as int?,
      'remaining_attempts': data['remaining_attempts'] as Map<String, int>?,
      'restriction_tier': data['restriction_tier'] as String?,
      'next_available_at': data['next_available_at'] as String?,
      'seconds_remaining': data['seconds_remaining'] as int?,
      'hourly_attempts_remaining': data['hourly_attempts_remaining'] as int?,
      'daily_attempts_remaining': data['daily_attempts_remaining'] as int?,
    };
  }

  /// Check if user is rate limited based on response
  static bool isRateLimited(Map<String, dynamic> responseData) {
    final data = responseData['data'] as Map<String, dynamic>?;
    if (data == null) return false;

    final restrictionTier = data['restriction_tier'] as String?;
    return restrictionTier != null && restrictionTier != 'normal';
  }

  /// Get time until next attempt is allowed
  static int getRetryAfterSeconds(Map<String, dynamic> responseData) {
    final data = responseData['data'] as Map<String, dynamic>?;
    return data?['retry_after'] as int? ?? 60;
  }
}
