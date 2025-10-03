/// Profile-related API models

/// User profile model
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? profileBio;
  final DateTime? birthDate;
  final int? gender;
  final int? countryId;
  final int? cityId;
  final int? height;
  final int? weight;
  final bool? smoke;
  final bool? drink;
  final bool? gym;
  final int? minAgePreference;
  final int? maxAgePreference;
  final List<String> profileImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.profileBio,
    this.birthDate,
    this.gender,
    this.countryId,
    this.cityId,
    this.height,
    this.weight,
    this.smoke,
    this.drink,
    this.gym,
    this.minAgePreference,
    this.maxAgePreference,
    required this.profileImages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      profileBio: json['profile_bio'] as String?,
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date'] as String) 
          : null,
      gender: json['gender'] as int?,
      countryId: json['country_id'] as int?,
      cityId: json['city_id'] as int?,
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      smoke: json['smoke'] as bool?,
      drink: json['drink'] as bool?,
      gym: json['gym'] as bool?,
      minAgePreference: json['min_age_preference'] as int?,
      maxAgePreference: json['max_age_preference'] as int?,
      profileImages: List<String>.from(json['profile_images'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_bio': profileBio,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'country_id': countryId,
      'city_id': cityId,
      'height': height,
      'weight': weight,
      'smoke': smoke,
      'drink': drink,
      'gym': gym,
      'min_age_preference': minAgePreference,
      'max_age_preference': maxAgePreference,
      'profile_images': profileImages,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Profile picture upload request
class ProfilePictureUploadRequest {
  final String imageData;
  final String fileName;
  final bool isPrimary;

  const ProfilePictureUploadRequest({
    required this.imageData,
    required this.fileName,
    this.isPrimary = false,
  });

  factory ProfilePictureUploadRequest.fromJson(Map<String, dynamic> json) {
    return ProfilePictureUploadRequest(
      imageData: json['image_data'] as String,
      fileName: json['file_name'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_data': imageData,
      'file_name': fileName,
      'is_primary': isPrimary,
    };
  }
}

/// Profile picture upload response
class ProfilePictureUploadResponse {
  final int pictureId;
  final String pictureUrl;
  final bool isPrimary;

  const ProfilePictureUploadResponse({
    required this.pictureId,
    required this.pictureUrl,
    required this.isPrimary,
  });

  factory ProfilePictureUploadResponse.fromJson(Map<String, dynamic> json) {
    return ProfilePictureUploadResponse(
      pictureId: json['picture_id'] as int,
      pictureUrl: json['picture_url'] as String,
      isPrimary: json['is_primary'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'picture_id': pictureId,
      'picture_url': pictureUrl,
      'is_primary': isPrimary,
    };
  }
}

/// Update profile request model
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
    return {
      'profile_bio': profileBio,
      'height': height,
      'weight': weight,
      'smoke': smoke,
      'drink': drink,

      'gym': gym,
      'min_age_preference': minAgePreference,
      'max_age_preference': maxAgePreference,
    };
  }
}

/// Update profile response model
class UpdateProfileResponse {
  final bool success;
  final String message;
  final bool status; // Added for compatibility
  final UserProfile? data;

  const UpdateProfileResponse({
    required this.success,
    required this.message,
    required this.status,
    this.data,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      status: json['status'] != null ? json['status'] as bool : json['success'] as bool,
      data: json['data'] != null 
          ? UserProfile.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

/// Upload profile picture request model
class UploadProfilePictureRequest {
  final String imagePath;
  final bool isPrimary;

  const UploadProfilePictureRequest({
    required this.imagePath,
    this.isPrimary = false,
  });

  factory UploadProfilePictureRequest.fromJson(Map<String, dynamic> json) {
    return UploadProfilePictureRequest(
      imagePath: json['image_path'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_path': imagePath,
      'is_primary': isPrimary,
    };
  }
}

/// Upload profile picture response model
class UploadProfilePictureResponse {
  final bool success;
  final String message;
  final bool status; // Added for compatibility  
  final ProfilePictureResponseData? data;

  const UploadProfilePictureResponse({
    required this.success,
    required this.message,
    required this.status,
    this.data,
  });

  factory UploadProfilePictureResponse.fromJson(Map<String, dynamic> json) {
    return UploadProfilePictureResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      status: json['status'] != null ? json['status'] as bool : json['success'] as bool,
      data: json['data'] != null
          ? ProfilePictureResponseData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

/// Profile picture response data
class ProfilePictureResponseData {
  final int id;
  final String url;
  final bool isPrimary;

  const ProfilePictureResponseData({
    required this.id,
    required this.url,
    required this.isPrimary,
  });

  factory ProfilePictureResponseData.fromJson(Map<String, dynamic> json) {
    return ProfilePictureResponseData(
      id: json['id'] as int,
      url: json['url'] as String,
      isPrimary: json['is_primary'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'is_primary': isPrimary,
    };
  }
}

/// Profile visibility settings
class ProfileVisibilitySettings {
  final bool showAge;
  final bool showLocation;
  final bool showInterests;
  final bool showPhotos;
  final bool showSocialLinks;

  const ProfileVisibilitySettings({
    this.showAge = true,
    this.showLocation = true,
    this.showInterests = true,
    this.showPhotos = true,
    this.showSocialLinks = false,
  });

  factory ProfileVisibilitySettings.fromJson(Map<String, dynamic> json) {
    return ProfileVisibilitySettings(
      showAge: json['show_age'] as bool? ?? true,
      showLocation: json['show_location'] as bool? ?? true,
      showInterests: json['show_interests'] as bool? ?? true,
      showPhotos: json['show_photos'] as bool? ?? true,
      showSocialLinks: json['show_social_links'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_age': showAge,
      'show_location': showLocation,
      'show_interests': showInterests,
      'show_photos': showPhotos,
      'show_social_links': showSocialLinks,
    };
  }
}