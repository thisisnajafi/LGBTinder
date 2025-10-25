import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../../config/api_config.dart';
import '../../models/api_models/auth_models.dart';

/// Login Password API Service
/// 
/// This service handles password-based login API calls including:
/// - Password login with email and password
/// - Device name detection
/// - Profile completion status handling
class LoginPasswordApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // PASSWORD LOGIN
  // ============================================================================

  /// Login with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// Returns [LoginPasswordResponse] with login result and profile completion status
  static Future<LoginPasswordResponse> loginWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Get device name
      final deviceName = await _getDeviceName();
      
      // Create request
      final request = LoginPasswordRequest(
        email: email,
        password: password,
        deviceName: deviceName,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.loginPassword}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LoginPasswordResponse.fromJson(responseData);
      } else {
        // Handle error response
        return LoginPasswordResponse(
          status: false,
          message: responseData['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return LoginPasswordResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Login with email and password with detailed error handling
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// Returns [Map<String, dynamic>] with result and error information
  static Future<Map<String, dynamic>> loginWithPasswordWithErrorHandling({
    required String email,
    required String password,
  }) async {
    try {
      // Get device name
      final deviceName = await _getDeviceName();
      
      // Create request
      final request = LoginPasswordRequest(
        email: email,
        password: password,
        deviceName: deviceName,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.loginPassword}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': LoginPasswordResponse.fromJson(responseData),
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'error': {
            'code': response.statusCode,
            'message': responseData['message'] ?? 'Login failed',
            'details': responseData,
          },
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error': {
          'code': 0,
          'message': 'Network error: ${e.toString()}',
          'details': e.toString(),
        },
      };
    }
  }

  // ============================================================================
  // DEVICE INFORMATION
  // ============================================================================

  /// Get device name for API requests
  static Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      // Try to get device name based on platform
      if (await deviceInfo.androidInfo.then((androidInfo) => true).catchError((_) => false)) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.model} (${androidInfo.brand})';
      } else if (await deviceInfo.iosInfo.then((iosInfo) => true).catchError((_) => false)) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.model} (${iosInfo.name})';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if user needs profile completion
  static bool needsProfileCompletion(LoginPasswordResponse response) {
    if (response.data?.userState == 'profile_completion_required') {
      return true;
    }
    
    if (response.data?.profileCompletionStatus?.isComplete == false) {
      return true;
    }
    
    return false;
  }

  /// Get missing profile fields
  static List<String> getMissingProfileFields(LoginPasswordResponse response) {
    return response.data?.profileCompletionStatus?.missingFields ?? [];
  }

  /// Check if login was successful
  static bool isLoginSuccessful(LoginPasswordResponse response) {
    return response.status && response.data != null;
  }

  /// Get authentication token
  static String? getAuthToken(LoginPasswordResponse response) {
    return response.data?.token;
  }

  /// Get token type
  static String? getTokenType(LoginPasswordResponse response) {
    return response.data?.tokenType;
  }

  /// Get user ID
  static int? getUserId(LoginPasswordResponse response) {
    return response.data?.userId;
  }

  /// Get user email
  static String? getUserEmail(LoginPasswordResponse response) {
    return response.data?.email;
  }
}
