import 'dart:convert';

/// Authentication API Models
/// 
/// This file contains all data models for authentication endpoints
/// including registration, user state checking, email verification, and profile completion.

// ============================================================================
// LOGIN PASSWORD MODELS
// ============================================================================

/// Request model for password login
class LoginPasswordRequest {
  final String email;
  final String password;
  final String deviceName;

  const LoginPasswordRequest({
    required this.email,
    required this.password,
    required this.deviceName,
  });

  factory LoginPasswordRequest.fromJson(Map<String, dynamic> json) {
    return LoginPasswordRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      deviceName: json['device_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'device_name': deviceName,
    };
  }
}

/// Response data model for password login
class LoginPasswordResponseData {
  final String userState;
  final int userId;
  final String email;
  final String token;
  final String tokenType;
  final ProfileCompletionStatus? profileCompletionStatus;

  const LoginPasswordResponseData({
    required this.userState,
    required this.userId,
    required this.email,
    required this.token,
    required this.tokenType,
    this.profileCompletionStatus,
  });

  factory LoginPasswordResponseData.fromJson(Map<String, dynamic> json) {
    return LoginPasswordResponseData(
      userState: json['user_state'] as String,
      userId: json['user_id'] as int,
      email: json['email'] as String,
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      profileCompletionStatus: json['profile_completion_status'] != null
          ? ProfileCompletionStatus.fromJson(
              json['profile_completion_status'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_state': userState,
      'user_id': userId,
      'email': email,
      'token': token,
      'token_type': tokenType,
      if (profileCompletionStatus != null) 
          'profile_completion_status': profileCompletionStatus!.toJson(),
    };
  }
}

/// Response model for password login
class LoginPasswordResponse {
  final bool status;
  final String message;
  final LoginPasswordResponseData? data;

  const LoginPasswordResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory LoginPasswordResponse.fromJson(Map<String, dynamic> json) {
    return LoginPasswordResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? LoginPasswordResponseData.fromJson(json['data'] as Map<String, dynamic>)
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
// REGISTRATION MODELS
// ============================================================================

/// Request model for user registration
class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String? referralCode;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    this.referralCode,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
      referralCode: json['referral_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (referralCode != null) 'referral_code': referralCode,
    };
  }
}

/// Response data model for registration
class RegisterResponseData {
  final int userId;
  final String email;
  final bool emailSent;
  final String resendAvailableAt;
  final int hourlyAttemptsRemaining;

  const RegisterResponseData({
    required this.userId,
    required this.email,
    required this.emailSent,
    required this.resendAvailableAt,
    required this.hourlyAttemptsRemaining,
  });

  factory RegisterResponseData.fromJson(Map<String, dynamic> json) {
    return RegisterResponseData(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      emailSent: json['email_sent'] as bool,
      resendAvailableAt: json['resend_available_at'] as String,
      hourlyAttemptsRemaining: json['hourly_attempts_remaining'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'email_sent': emailSent,
      'resend_available_at': resendAvailableAt,
      'hourly_attempts_remaining': hourlyAttemptsRemaining,
    };
  }
}

/// Response model for registration
class RegisterResponse {
  final bool status;
  final String message;
  final RegisterResponseData? data;
  final Map<String, List<String>>? errors;

  const RegisterResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? RegisterResponseData.fromJson(json['data'] as Map<String, dynamic>)
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
// USER STATE CHECKING MODELS
// ============================================================================

/// Request model for checking user state
class CheckUserStateRequest {
  final String email;

  const CheckUserStateRequest({
    required this.email,
  });

  factory CheckUserStateRequest.fromJson(Map<String, dynamic> json) {
    return CheckUserStateRequest(
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

/// Profile completion status model
class ProfileCompletionStatus {
  final bool isComplete;
  final List<String> missingFields;

  const ProfileCompletionStatus({
    required this.isComplete,
    required this.missingFields,
  });

  factory ProfileCompletionStatus.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionStatus(
      isComplete: json['is_complete'] as bool,
      missingFields: List<String>.from(json['missing_fields'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_complete': isComplete,
      'missing_fields': missingFields,
    };
  }
}

/// Response data model for user state checking
class CheckUserStateResponseData {
  final String userState;
  final int userId;
  final String email;
  final bool? needsVerification;
  final String? token;
  final String? tokenType;
  final ProfileCompletionStatus? profileCompletionStatus;
  final bool? profileCompleted;

  const CheckUserStateResponseData({
    required this.userState,
    required this.userId,
    required this.email,
    this.needsVerification,
    this.token,
    this.tokenType,
    this.profileCompletionStatus,
    this.profileCompleted,
  });

  factory CheckUserStateResponseData.fromJson(Map<String, dynamic> json) {
    return CheckUserStateResponseData(
      userState: json['user_state'] as String,
      userId: json['user_id'] as int,
      email: json['email'] as String,
      needsVerification: json['needs_verification'] as bool?,
      token: json['token'] as String?,
      tokenType: json['token_type'] as String?,
      profileCompletionStatus: json['profile_completion_status'] != null
          ? ProfileCompletionStatus.fromJson(
              json['profile_completion_status'] as Map<String, dynamic>,
            )
          : null,
      profileCompleted: json['profile_completed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_state': userState,
      'user_id': userId,
      'email': email,
      if (needsVerification != null) 'needs_verification': needsVerification,
      if (token != null) 'token': token,
      if (tokenType != null) 'token_type': tokenType,
      if (profileCompletionStatus != null) 
          'profile_completion_status': profileCompletionStatus!.toJson(),
      if (profileCompleted != null) 'profile_completed': profileCompleted,
    };
  }
}

/// Response model for user state checking
class CheckUserStateResponse {
  final bool status;
  final String message;
  final CheckUserStateResponseData? data;

  const CheckUserStateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CheckUserStateResponse.fromJson(Map<String, dynamic> json) {
    return CheckUserStateResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? CheckUserStateResponseData.fromJson(json['data'] as Map<String, dynamic>)
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
// EMAIL VERIFICATION MODELS
// ============================================================================

/// Request model for email verification
class VerifyEmailRequest {
  final String email;
  final String code;

  const VerifyEmailRequest({
    required this.email,
    required this.code,
  });

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) {
    return VerifyEmailRequest(
      email: json['email'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}

/// Response data model for email verification
class VerifyEmailResponseData {
  final int userId;
  final String email;
  final String? token;
  final String? tokenType;
  final bool? profileCompletionRequired;

  const VerifyEmailResponseData({
    required this.userId,
    required this.email,
    this.token,
    this.tokenType,
    this.profileCompletionRequired,
  });

  factory VerifyEmailResponseData.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponseData(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      token: json['token'] as String?,
      tokenType: json['token_type'] as String?,
      profileCompletionRequired: json['profile_completion_required'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      if (token != null) 'token': token,
      if (tokenType != null) 'token_type': tokenType,
      if (profileCompletionRequired != null) 
          'profile_completion_required': profileCompletionRequired,
    };
  }
}

/// Response model for email verification
class VerifyEmailResponse {
  final bool status;
  final String message;
  final VerifyEmailResponseData? data;

  const VerifyEmailResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? VerifyEmailResponseData.fromJson(json['data'] as Map<String, dynamic>)
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
// PROFILE COMPLETION MODELS
// ============================================================================

/// Request model for profile completion
class CompleteProfileRequest {
  final String deviceName;
  final int countryId;
  final int cityId;
  final int gender;
  final String birthDate;
  final int minAgePreference;
  final int maxAgePreference;
  final String profileBio;
  final int height;
  final int weight;
  final bool smoke;
  final bool drink;
  final bool gym;
  final List<int> musicGenres;
  final List<int> educations;
  final List<int> jobs;
  final List<int> languages;
  final List<int> interests;
  final List<int> preferredGenders;
  final List<int> relationGoals;

  const CompleteProfileRequest({
    required this.deviceName,
    required this.countryId,
    required this.cityId,
    required this.gender,
    required this.birthDate,
    required this.minAgePreference,
    required this.maxAgePreference,
    required this.profileBio,
    required this.height,
    required this.weight,
    required this.smoke,
    required this.drink,
    required this.gym,
    required this.musicGenres,
    required this.educations,
    required this.jobs,
    required this.languages,
    required this.interests,
    required this.preferredGenders,
    required this.relationGoals,
  });

  factory CompleteProfileRequest.fromJson(Map<String, dynamic> json) {
    return CompleteProfileRequest(
      deviceName: json['device_name'] as String,
      countryId: json['country_id'] as int,
      cityId: json['city_id'] as int,
      gender: json['gender'] as int,
      birthDate: json['birth_date'] as String,
      minAgePreference: json['min_age_preference'] as int,
      maxAgePreference: json['max_age_preference'] as int,
      profileBio: json['profile_bio'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      smoke: json['smoke'] as bool,
      drink: json['drink'] as bool,
      gym: json['gym'] as bool,
      musicGenres: List<int>.from(json['music_genres'] as List),
      educations: List<int>.from(json['educations'] as List),
      jobs: List<int>.from(json['jobs'] as List),
      languages: List<int>.from(json['languages'] as List),
      interests: List<int>.from(json['interests'] as List),
      preferredGenders: List<int>.from(json['preferred_genders'] as List),
      relationGoals: List<int>.from(json['relation_goals'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_name': deviceName,
      'country_id': countryId,
      'city_id': cityId,
      'gender': gender,
      'birth_date': birthDate,
      'min_age_preference': minAgePreference,
      'max_age_preference': maxAgePreference,
      'profile_bio': profileBio,
      'height': height,
      'weight': weight,
      'smoke': smoke,
      'drink': drink,
      'gym': gym,
      'music_genres': musicGenres,
      'educations': educations,
      'jobs': jobs,
      'languages': languages,
      'interests': interests,
      'preferred_genders': preferredGenders,
      'relation_goals': relationGoals,
    };
  }
}

/// User data model for profile completion response
class CompleteProfileUserData {
  final int id;
  final String name;
  final String email;
  final int countryId;
  final int cityId;
  final String country;
  final String city;
  final int gender;
  final String birthDate;
  final String profileBio;
  final int height;
  final int weight;
  final bool smoke;
  final bool drink;
  final bool gym;
  final int minAgePreference;
  final int maxAgePreference;

  const CompleteProfileUserData({
    required this.id,
    required this.name,
    required this.email,
    required this.countryId,
    required this.cityId,
    required this.country,
    required this.city,
    required this.gender,
    required this.birthDate,
    required this.profileBio,
    required this.height,
    required this.weight,
    required this.smoke,
    required this.drink,
    required this.gym,
    required this.minAgePreference,
    required this.maxAgePreference,
  });

  factory CompleteProfileUserData.fromJson(Map<String, dynamic> json) {
    return CompleteProfileUserData(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      countryId: json['country_id'] as int,
      cityId: json['city_id'] as int,
      country: json['country'] as String,
      city: json['city'] as String,
      gender: json['gender'] as int,
      birthDate: json['birth_date'] as String,
      profileBio: json['profile_bio'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      smoke: json['smoke'] as bool,
      drink: json['drink'] as bool,
      gym: json['gym'] as bool,
      minAgePreference: json['min_age_preference'] as int,
      maxAgePreference: json['max_age_preference'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'country_id': countryId,
      'city_id': cityId,
      'country': country,
      'city': city,
      'gender': gender,
      'birth_date': birthDate,
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

/// Response data model for profile completion
class CompleteProfileResponseData {
  final CompleteProfileUserData user;
  final String token;
  final String tokenType;
  final bool profileCompleted;
  final bool needsProfileCompletion;
  final String userState;

  const CompleteProfileResponseData({
    required this.user,
    required this.token,
    required this.tokenType,
    required this.profileCompleted,
    required this.needsProfileCompletion,
    required this.userState,
  });

  factory CompleteProfileResponseData.fromJson(Map<String, dynamic> json) {
    return CompleteProfileResponseData(
      user: CompleteProfileUserData.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      profileCompleted: json['profile_completed'] as bool,
      needsProfileCompletion: json['needs_profile_completion'] as bool,
      userState: json['user_state'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'token_type': tokenType,
      'profile_completed': profileCompleted,
      'needs_profile_completion': needsProfileCompletion,
      'user_state': userState,
    };
  }
}

/// Response model for profile completion
class CompleteProfileResponse {
  final bool status;
  final String message;
  final CompleteProfileResponseData? data;
  final Map<String, List<String>>? errors;

  const CompleteProfileResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory CompleteProfileResponse.fromJson(Map<String, dynamic> json) {
    return CompleteProfileResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? CompleteProfileResponseData.fromJson(json['data'] as Map<String, dynamic>)
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
