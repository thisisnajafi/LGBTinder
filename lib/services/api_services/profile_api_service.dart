import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/api_models/profile_models.dart';

/// Profile Management API Service
/// 
/// This service handles all profile management API calls including:
/// - Updating user profile information
/// - Uploading profile pictures
/// - Profile management utilities
class ProfileApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // PROFILE UPDATE
  // ============================================================================

  /// Update user profile information
  /// 
  /// [request] - Profile update request data
  /// [token] - Full access token for authentication
  /// Returns [UpdateProfileResponse] with update result
  static Future<UpdateProfileResponse> updateProfile(UpdateProfileRequest request, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return UpdateProfileResponse.fromJson(responseData);
      } else {
        // Handle error response
        return UpdateProfileResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network or parsing errors
      return UpdateProfileResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update profile with error handling
  /// 
  /// [request] - Profile update request data
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result and error information
  static Future<Map<String, dynamic>> updateProfileWithErrorHandling(
    UpdateProfileRequest request,
    String token,
  ) async {
    try {
      final response = await updateProfile(request, token);

      if (response.status) {
        return {
          'success': true,
          'data': response.data,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'error': response.message,
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
  // PROFILE PICTURE UPLOAD
  // ============================================================================

  /// Upload a new profile picture
  /// 
  /// [request] - Profile picture upload request data
  /// [token] - Full access token for authentication
  /// Returns [UploadProfilePictureResponse] with upload result
  static Future<UploadProfilePictureResponse> uploadProfilePicture(
    UploadProfilePictureRequest request,
    String token,
  ) async {
    try {
      final multipartRequest = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/profile-pictures/upload'),
      );

      // Add headers
      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add fields
      multipartRequest.fields.addAll(request.fields);

      // Add files
      for (final entry in request.files.entries) {
        multipartRequest.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return UploadProfilePictureResponse.fromJson(responseData);
      } else {
        // Handle error response
        return UploadProfilePictureResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network or parsing errors
      return UploadProfilePictureResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Upload profile picture with error handling
  /// 
  /// [imageFile] - Image file to upload
  /// [isPrimary] - Whether to set as primary picture
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result and error information
  static Future<Map<String, dynamic>> uploadProfilePictureWithErrorHandling(
    File imageFile,
    bool isPrimary,
    String token,
  ) async {
    try {
      final request = UploadProfilePictureRequest(
        image: imageFile,
        isPrimary: isPrimary,
      );
      final response = await uploadProfilePicture(request, token);

      if (response.status) {
        return {
          'success': true,
          'data': response.data,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'error': response.message,
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
  // PROFILE UTILITIES
  // ============================================================================

  /// Validate profile update request
  /// 
  /// [request] - Profile update request to validate
  /// Returns [Map<String, String>] with validation errors
  static Map<String, String> validateProfileUpdateRequest(UpdateProfileRequest request) {
    final Map<String, String> errors = {};

    // Validate profile bio
    if (request.profileBio != null && !ProfileHelper.isValidProfileBio(request.profileBio)) {
      errors['profile_bio'] = 'Profile bio must be between 1 and 500 characters';
    }

    // Validate height
    if (request.height != null && !ProfileHelper.isValidHeight(request.height)) {
      errors['height'] = 'Height must be between 100cm and 250cm';
    }

    // Validate weight
    if (request.weight != null && !ProfileHelper.isValidWeight(request.weight)) {
      errors['weight'] = 'Weight must be between 30kg and 200kg';
    }

    // Validate age preference
    if (!ProfileHelper.isValidAgePreference(request.minAgePreference, request.maxAgePreference)) {
      errors['age_preference'] = 'Age preference must be between 18 and 100, with min age <= max age';
    }

    return errors;
  }

  /// Validate profile picture file
  /// 
  /// [file] - File to validate
  /// Returns [Map<String, String>] with validation errors
  static Map<String, String> validateProfilePictureFile(File file) {
    final Map<String, String> errors = {};

    // Check if file exists
    if (!file.existsSync()) {
      errors['file'] = 'File does not exist';
      return errors;
    }

    // Check file size
    if (ProfileHelper.isProfilePictureFileTooLarge(file)) {
      errors['file'] = ProfileHelper.getProfilePictureFileSizeErrorMessage(file);
    }

    // Check file extension
    final extension = ProfileHelper.getProfilePictureFileExtension(file);
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    if (!allowedExtensions.contains(extension)) {
      errors['file'] = ProfileHelper.getProfilePictureFileExtensionErrorMessage(file);
    }

    return errors;
  }

  /// Check if profile update request is valid
  /// 
  /// [request] - Profile update request to check
  /// Returns [bool] indicating if request is valid
  static bool isValidProfileUpdateRequest(UpdateProfileRequest request) {
    return validateProfileUpdateRequest(request).isEmpty;
  }

  /// Check if profile picture file is valid
  /// 
  /// [file] - File to check
  /// Returns [bool] indicating if file is valid
  static bool isValidProfilePictureFile(File file) {
    return validateProfilePictureFile(file).isEmpty;
  }

  /// Get profile update request validation errors
  /// 
  /// [request] - Profile update request to validate
  /// Returns [String] with validation error message
  static String getProfileUpdateValidationErrors(UpdateProfileRequest request) {
    final errors = validateProfileUpdateRequest(request);
    if (errors.isEmpty) return '';
    
    return errors.values.join(', ');
  }

  /// Get profile picture file validation errors
  /// 
  /// [file] - File to validate
  /// Returns [String] with validation error message
  static String getProfilePictureFileValidationErrors(File file) {
    final errors = validateProfilePictureFile(file);
    if (errors.isEmpty) return '';
    
    return errors.values.join(', ');
  }

  /// Check if user can update profile
  /// 
  /// [token] - User's authentication token
  /// Returns [bool] indicating if user can update profile
  static bool canUpdateProfile(String? token) {
    return isAuthenticated(token);
  }

  /// Check if user can upload profile picture
  /// 
  /// [token] - User's authentication token
  /// Returns [bool] indicating if user can upload profile picture
  static bool canUploadProfilePicture(String? token) {
    return isAuthenticated(token);
  }

  /// Get profile bio character count
  /// 
  /// [bio] - Profile bio text
  /// Returns [int] with character count
  static int getProfileBioCharacterCount(String? bio) {
    return ProfileHelper.getProfileBioCharacterCount(bio);
  }

  /// Get remaining characters for profile bio
  /// 
  /// [bio] - Profile bio text
  /// [maxLength] - Maximum allowed length
  /// Returns [int] with remaining characters
  static int getRemainingBioCharacters(String? bio, {int maxLength = 500}) {
    return ProfileHelper.getRemainingBioCharacters(bio, maxLength: maxLength);
  }

  /// Check if profile bio is too long
  /// 
  /// [bio] - Profile bio text
  /// [maxLength] - Maximum allowed length
  /// Returns [bool] indicating if bio is too long
  static bool isProfileBioTooLong(String? bio, {int maxLength = 500}) {
    return ProfileHelper.isProfileBioTooLong(bio, maxLength: maxLength);
  }

  /// Format height for display
  /// 
  /// [height] - Height in cm
  /// Returns [String] with formatted height
  static String formatHeight(int? height) {
    return ProfileHelper.formatHeight(height);
  }

  /// Format weight for display
  /// 
  /// [weight] - Weight in kg
  /// Returns [String] with formatted weight
  static String formatWeight(int? weight) {
    return ProfileHelper.formatWeight(weight);
  }

  /// Format age preference for display
  /// 
  /// [minAge] - Minimum age preference
  /// [maxAge] - Maximum age preference
  /// Returns [String] with formatted age preference
  static String formatAgePreference(int? minAge, int? maxAge) {
    return ProfileHelper.formatAgePreference(minAge, maxAge);
  }

  /// Get lifestyle preferences string
  /// 
  /// [smoke] - Smoking preference
  /// [drink] - Drinking preference
  /// [gym] - Gym preference
  /// Returns [String] with lifestyle preferences
  static String getLifestyleString(bool? smoke, bool? drink, bool? gym) {
    return ProfileHelper.getLifestyleString(smoke, drink, gym);
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

  /// Check if user is authenticated
  static bool isAuthenticated(String? token) {
    return token != null && token.isNotEmpty;
  }

  /// Validate token format
  static bool isValidTokenFormat(String token) {
    // Basic token validation - should be non-empty and contain typical JWT structure
    return token.isNotEmpty && token.contains('.');
  }

  /// Validate user ID
  static bool isValidUserId(int userId) {
    return userId > 0;
  }

  /// Validate file
  static bool isValidFile(File file) {
    return file.existsSync();
  }

  /// Get file size in MB
  static double getFileSizeMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Check if file is too large
  static bool isFileTooLarge(File file, {double maxSizeMB = 10.0}) {
    return getFileSizeMB(file) > maxSizeMB;
  }
}
