import 'dart:convert';
import 'dart:io';

/// Profile Management API Models
/// 
/// This file contains all data models for profile management endpoints
/// including updating profile information and uploading profile pictures.

// ============================================================================
// PROFILE UPDATE MODELS
// ============================================================================

/// Request model for updating user profile
class UpdateProfileRequest {
  final String? profileBio;
  final int? height;
  final int? weight;
  final bool? smoke;
  final bool? drink;
  final bool? gym;
  final int? minAgePreference;
  final int? maxAgePreference;

  const UpdateProfileRequest({
    this.profileBio,
    this.height,
    this.weight,
    this.smoke,
    this.drink,
    this.gym,
    this.minAgePreference,
    this.maxAgePreference,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequest(
      profileBio: json['profile_bio'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      smoke: json['smoke'] as bool?,
      drink: json['drink'] as bool?,
      gym: json['gym'] as bool?,
      minAgePreference: json['min_age_preference'] as int?,
      maxAgePreference: json['max_age_preference'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (profileBio != null) data['profile_bio'] = profileBio;
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (smoke != null) data['smoke'] = smoke;
    if (drink != null) data['drink'] = drink;
    if (gym != null) data['gym'] = gym;
    if (minAgePreference != null) data['min_age_preference'] = minAgePreference;
    if (maxAgePreference != null) data['max_age_preference'] = maxAgePreference;
    
    return data;
  }

  /// Check if request has any data to update
  bool get hasData {
    return profileBio != null ||
           height != null ||
           weight != null ||
           smoke != null ||
           drink != null ||
           gym != null ||
           minAgePreference != null ||
           maxAgePreference != null;
  }
}

/// Profile update response data model
class UpdateProfileResponseData {
  final int id;
  final String? profileBio;
  final int? height;
  final int? weight;
  final bool? smoke;
  final bool? drink;
  final bool? gym;
  final int? minAgePreference;
  final int? maxAgePreference;
  final String updatedAt;

  const UpdateProfileResponseData({
    required this.id,
    this.profileBio,
    this.height,
    this.weight,
    this.smoke,
    this.drink,
    this.gym,
    this.minAgePreference,
    this.maxAgePreference,
    required this.updatedAt,
  });

  factory UpdateProfileResponseData.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponseData(
      id: json['id'] as int,
      profileBio: json['profile_bio'] as String?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      smoke: json['smoke'] as bool?,
      drink: json['drink'] as bool?,
      gym: json['gym'] as bool?,
      minAgePreference: json['min_age_preference'] as int?,
      maxAgePreference: json['max_age_preference'] as int?,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (profileBio != null) 'profile_bio': profileBio,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (smoke != null) 'smoke': smoke,
      if (drink != null) 'drink': drink,
      if (gym != null) 'gym': gym,
      if (minAgePreference != null) 'min_age_preference': minAgePreference,
      if (maxAgePreference != null) 'max_age_preference': maxAgePreference,
      'updated_at': updatedAt,
    };
  }
}

/// Update profile response model
class UpdateProfileResponse {
  final bool status;
  final String message;
  final UpdateProfileResponseData? data;
  final Map<String, List<String>>? errors;

  const UpdateProfileResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? UpdateProfileResponseData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'] != null 
          ? Map<String, List<String>>.from(
              (json['errors'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, List<String>.from(value as List)),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
      if (errors != null) 'errors': errors,
    };
  }
}

// ============================================================================
// PROFILE PICTURE UPLOAD MODELS
// ============================================================================

/// Profile picture upload request model
class UploadProfilePictureRequest {
  final File image;
  final bool isPrimary;

  const UploadProfilePictureRequest({
    required this.image,
    this.isPrimary = false,
  });

  /// Get multipart fields for the request
  Map<String, String> get fields {
    return {
      'is_primary': isPrimary.toString(),
    };
  }

  /// Get multipart files for the request
  Map<String, File> get files {
    return {
      'image': image,
    };
  }
}

/// Profile picture upload response data model
class UploadProfilePictureResponseData {
  final int id;
  final String url;
  final bool isPrimary;
  final String createdAt;

  const UploadProfilePictureResponseData({
    required this.id,
    required this.url,
    required this.isPrimary,
    required this.createdAt,
  });

  factory UploadProfilePictureResponseData.fromJson(Map<String, dynamic> json) {
    return UploadProfilePictureResponseData(
      id: json['id'] as int,
      url: json['url'] as String,
      isPrimary: json['is_primary'] as bool,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'is_primary': isPrimary,
      'created_at': createdAt,
    };
  }
}

/// Upload profile picture response model
class UploadProfilePictureResponse {
  final bool status;
  final String message;
  final UploadProfilePictureResponseData? data;

  const UploadProfilePictureResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory UploadProfilePictureResponse.fromJson(Map<String, dynamic> json) {
    return UploadProfilePictureResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? UploadProfilePictureResponseData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

// ============================================================================
// PROFILE UTILITIES
// ============================================================================

/// Profile helper class
class ProfileHelper {
  /// Validate profile bio
  static bool isValidProfileBio(String? bio) {
    if (bio == null) return true; // Optional field
    return bio.trim().isNotEmpty && bio.length <= 500;
  }

  /// Validate height
  static bool isValidHeight(int? height) {
    if (height == null) return true; // Optional field
    return height >= 100 && height <= 250; // 100cm to 250cm
  }

  /// Validate weight
  static bool isValidWeight(int? weight) {
    if (weight == null) return true; // Optional field
    return weight >= 30 && weight <= 200; // 30kg to 200kg
  }

  /// Validate age preference
  static bool isValidAgePreference(int? minAge, int? maxAge) {
    if (minAge == null && maxAge == null) return true; // Both optional
    if (minAge == null || maxAge == null) return false; // Both must be provided
    
    return minAge >= 18 && 
           maxAge >= 18 && 
           minAge <= maxAge && 
           maxAge <= 100;
  }

  /// Get profile bio character count
  static int getProfileBioCharacterCount(String? bio) {
    return bio?.length ?? 0;
  }

  /// Get remaining characters for profile bio
  static int getRemainingBioCharacters(String? bio, {int maxLength = 500}) {
    return maxLength - getProfileBioCharacterCount(bio);
  }

  /// Check if profile bio is too long
  static bool isProfileBioTooLong(String? bio, {int maxLength = 500}) {
    return getProfileBioCharacterCount(bio) > maxLength;
  }

  /// Format height for display
  static String formatHeight(int? height) {
    if (height == null) return 'Not specified';
    return '${height}cm';
  }

  /// Format weight for display
  static String formatWeight(int? weight) {
    if (weight == null) return 'Not specified';
    return '${weight}kg';
  }

  /// Format age preference for display
  static String formatAgePreference(int? minAge, int? maxAge) {
    if (minAge == null || maxAge == null) return 'Not specified';
    return '$minAge-$maxAge years';
  }

  /// Get lifestyle preferences string
  static String getLifestyleString(bool? smoke, bool? drink, bool? gym) {
    final List<String> preferences = [];
    
    if (smoke == true) preferences.add('Smokes');
    if (drink == true) preferences.add('Drinks');
    if (gym == true) preferences.add('Gym');
    
    return preferences.isEmpty ? 'No lifestyle preferences set' : preferences.join(', ');
  }

  /// Check if profile has required fields
  static bool hasRequiredFields(UpdateProfileRequest request) {
    return request.profileBio != null ||
           request.height != null ||
           request.weight != null ||
           request.smoke != null ||
           request.drink != null ||
           request.gym != null ||
           request.minAgePreference != null ||
           request.maxAgePreference != null;
  }

  /// Get missing required fields
  static List<String> getMissingRequiredFields(UpdateProfileRequest request) {
    final List<String> missingFields = [];
    
    if (request.profileBio == null) missingFields.add('profile_bio');
    if (request.height == null) missingFields.add('height');
    if (request.weight == null) missingFields.add('weight');
    if (request.smoke == null) missingFields.add('smoke');
    if (request.drink == null) missingFields.add('drink');
    if (request.gym == null) missingFields.add('gym');
    if (request.minAgePreference == null) missingFields.add('min_age_preference');
    if (request.maxAgePreference == null) missingFields.add('max_age_preference');
    
    return missingFields;
  }

  /// Validate profile picture file
  static bool isValidProfilePictureFile(File file) {
    // Check if file exists
    if (!file.existsSync()) return false;
    
    // Check file size (max 10MB)
    final fileSize = file.lengthSync();
    if (fileSize > 10 * 1024 * 1024) return false;
    
    // Check file extension
    final extension = file.path.split('.').last.toLowerCase();
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    if (!allowedExtensions.contains(extension)) return false;
    
    return true;
  }

  /// Get profile picture file size in MB
  static double getProfilePictureFileSizeMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Get profile picture file extension
  static String getProfilePictureFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }

  /// Check if profile picture file is too large
  static bool isProfilePictureFileTooLarge(File file, {double maxSizeMB = 10.0}) {
    return getProfilePictureFileSizeMB(file) > maxSizeMB;
  }

  /// Get profile picture file size error message
  static String getProfilePictureFileSizeErrorMessage(File file, {double maxSizeMB = 10.0}) {
    final sizeMB = getProfilePictureFileSizeMB(file);
    return 'File size (${sizeMB.toStringAsFixed(2)}MB) exceeds maximum allowed size (${maxSizeMB}MB)';
  }

  /// Get profile picture file extension error message
  static String getProfilePictureFileExtensionErrorMessage(File file) {
    final extension = getProfilePictureFileExtension(file);
    return 'File extension (.$extension) is not supported. Allowed extensions: .jpg, .jpeg, .png, .gif, .webp';
  }
}
