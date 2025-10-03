import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/api_models/auth_models.dart';

/// Authentication API Service
/// 
/// This service handles all authentication-related API calls including:
/// - User registration
/// - User state checking
/// - Email verification
/// - Profile completion
class AuthApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // REGISTRATION
  // ============================================================================

  /// Register a new user
  /// 
  /// [request] - Registration request data
  /// Returns [RegisterResponse] with registration result
  static Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return RegisterResponse.fromJson(responseData);
      } else {
        // Handle error response
        return RegisterResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network or parsing errors
      return RegisterResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ============================================================================
  // USER STATE CHECKING
  // ============================================================================

  /// Check user's current authentication state
  /// 
  /// [request] - User state check request data
  /// Returns [CheckUserStateResponse] with user state information
  static Future<CheckUserStateResponse> checkUserState(CheckUserStateRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/check-user-state'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 403) {
        return CheckUserStateResponse.fromJson(responseData);
      } else {
        // Handle error response
        return CheckUserStateResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network or parsing errors
      return CheckUserStateResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ============================================================================
  // EMAIL VERIFICATION
  // ============================================================================

  /// Verify email with verification code
  /// 
  /// [request] - Email verification request data
  /// Returns [VerifyEmailResponse] with verification result
  static Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/send-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return VerifyEmailResponse.fromJson(responseData);
      } else {
        // Handle error response
        return VerifyEmailResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network or parsing errors
      return VerifyEmailResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ============================================================================
  // PROFILE COMPLETION
  // ============================================================================

  /// Complete user profile registration
  /// 
  /// [request] - Profile completion request data
  /// [token] - Profile completion token for authentication
  /// Returns [CompleteProfileResponse] with completion result
  static Future<CompleteProfileResponse> completeProfile(
    CompleteProfileRequest request,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/complete-registration'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CompleteProfileResponse.fromJson(responseData);
      } else {
        // Handle error response
        return CompleteProfileResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network or parsing errors
      return CompleteProfileResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if response indicates success
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if response indicates client error
  static bool isClientErrorResponse(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Check if response indicates server error
  static bool isServerErrorResponse(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Get error message from response
  static String getErrorMessage(Map<String, dynamic> responseData) {
    if (responseData.containsKey('message')) {
      return responseData['message'] as String;
    }
    return 'Unknown error occurred';
  }

  /// Get validation errors from response
  static Map<String, List<String>>? getValidationErrors(Map<String, dynamic> responseData) {
    if (responseData.containsKey('errors') && responseData['errors'] != null) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      return errors.map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      );
    }
    return null;
  }
}
