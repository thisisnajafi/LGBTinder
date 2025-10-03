import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/api_models/user_models.dart';

/// User Management API Service
/// 
/// This service handles all user management API calls including:
/// - Getting current user profile
/// - User profile management
class UserApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // USER PROFILE
  // ============================================================================

  /// Get current authenticated user's profile
  /// 
  /// [token] - Full access token for authentication
  /// Returns [UserProfile] with complete user profile data
  static Future<UserProfile?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfile.fromJson(responseData);
      } else {
        // Handle error response
        return null;
      }
    } catch (e) {
      // Handle network or parsing errors
      return null;
    }
  }

  /// Get current user profile with error handling
  /// 
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result and error information
  static Future<Map<String, dynamic>> getCurrentUserWithErrorHandling(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': UserProfile.fromJson(responseData),
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'error': _getErrorMessage(responseData),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // USER PROFILE VALIDATION
  // ============================================================================

  /// Check if user profile is complete
  /// 
  /// [userProfile] - User profile to validate
  /// Returns [bool] indicating if profile is complete
  static bool isProfileComplete(UserProfile userProfile) {
    return userProfile.profileCompleted &&
           userProfile.profileBio.isNotEmpty &&
           userProfile.images.isNotEmpty &&
           userProfile.jobs.isNotEmpty &&
           userProfile.educations.isNotEmpty &&
           userProfile.musicGenres.isNotEmpty &&
           userProfile.languages.isNotEmpty &&
           userProfile.interests.isNotEmpty &&
           userProfile.preferredGenders.isNotEmpty &&
           userProfile.relationGoals.isNotEmpty;
  }

  /// Get missing profile fields
  /// 
  /// [userProfile] - User profile to check
  /// Returns [List<String>] with missing field names
  static List<String> getMissingProfileFields(UserProfile userProfile) {
    final List<String> missingFields = [];

    if (userProfile.profileBio.isEmpty) {
      missingFields.add('profile_bio');
    }

    if (userProfile.images.isEmpty) {
      missingFields.add('images');
    }

    if (userProfile.jobs.isEmpty) {
      missingFields.add('jobs');
    }

    if (userProfile.educations.isEmpty) {
      missingFields.add('educations');
    }

    if (userProfile.musicGenres.isEmpty) {
      missingFields.add('music_genres');
    }

    if (userProfile.languages.isEmpty) {
      missingFields.add('languages');
    }

    if (userProfile.interests.isEmpty) {
      missingFields.add('interests');
    }

    if (userProfile.preferredGenders.isEmpty) {
      missingFields.add('preferred_genders');
    }

    if (userProfile.relationGoals.isEmpty) {
      missingFields.add('relation_goals');
    }

    return missingFields;
  }

  // ============================================================================
  // USER PROFILE UTILITIES
  // ============================================================================

  /// Get user's display name
  /// 
  /// [userProfile] - User profile
  /// Returns [String] with display name
  static String getDisplayName(UserProfile userProfile) {
    return userProfile.fullName.isNotEmpty ? userProfile.fullName : '${userProfile.firstName} ${userProfile.lastName}';
  }

  /// Get user's location string
  /// 
  /// [userProfile] - User profile
  /// Returns [String] with location information
  static String getLocationString(UserProfile userProfile) {
    return '${userProfile.city}, ${userProfile.country}';
  }

  /// Get user's age range string
  /// 
  /// [userProfile] - User profile
  /// Returns [String] with age range information
  static String getAgeRangeString(UserProfile userProfile) {
    return '${userProfile.minAgePreference}-${userProfile.maxAgePreference} years old';
  }

  /// Get user's lifestyle preferences string
  /// 
  /// [userProfile] - User profile
  /// Returns [String] with lifestyle preferences
  static String getLifestyleString(UserProfile userProfile) {
    final List<String> preferences = [];
    
    if (userProfile.smoke) preferences.add('Smokes');
    if (userProfile.drink) preferences.add('Drinks');
    if (userProfile.gym) preferences.add('Gym');
    
    return preferences.isEmpty ? 'No lifestyle preferences set' : preferences.join(', ');
  }

  /// Get user's physical stats string
  /// 
  /// [userProfile] - User profile
  /// Returns [String] with physical stats
  static String getPhysicalStatsString(UserProfile userProfile) {
    return '${userProfile.height}cm, ${userProfile.weight}kg';
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

  /// Get error message from response (private method)
  static String _getErrorMessage(Map<String, dynamic> responseData) {
    return getErrorMessage(responseData);
  }

  /// Check if user is authenticated
  static bool isAuthenticated(String? token) {
    return token != null && token.isNotEmpty;
  }

  /// Validate token format
  static bool isValidTokenFormat(String token) {
    // Basic token validation - should be non-empty and contain typical JWT structure
    return token.isNotEmpty && token.contains('.');
  }
}
