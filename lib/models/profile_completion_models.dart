// Profile Completion Models based on API Documentation

class Country {
  final int id;
  final String name;
  final String code;
  final String phoneCode;

  const Country({
    required this.id,
    required this.name,
    required this.code,
    required this.phoneCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      phoneCode: json['phone_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'phone_code': phoneCode,
    };
  }
}

class City {
  final int id;
  final String name;
  final int countryId;
  final String? stateProvince;
  final Country? country;

  const City({
    required this.id,
    required this.name,
    required this.countryId,
    this.stateProvince,
    this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      countryId: json['country_id'] as int,
      stateProvince: json['state_province'] as String?,
      country: json['country'] != null ? Country.fromJson(json['country'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'state_province': stateProvince,
      'country': country?.toJson(),
    };
  }
}

class ReferenceDataItem {
  final int id;
  final String title;
  final String imageUrl;

  const ReferenceDataItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory ReferenceDataItem.fromJson(Map<String, dynamic> json) {
    return ReferenceDataItem(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
    };
  }
}

class ReferenceDataResponse {
  final String status;
  final List<ReferenceDataItem> data;

  const ReferenceDataResponse({
    required this.status,
    required this.data,
  });

  factory ReferenceDataResponse.fromJson(Map<String, dynamic> json) {
    return ReferenceDataResponse(
      status: json['status'] as String,
      data: (json['data'] as List)
          .map((item) => ReferenceDataItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProfileCompletionRequest {
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

  const ProfileCompletionRequest({
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

class ProfileCompletionData {
  final Map<String, dynamic> user;
  final String token;
  final String tokenType;
  final int expiresIn;
  final List<String> scopes;

  const ProfileCompletionData({
    required this.user,
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.scopes,
  });

  factory ProfileCompletionData.fromJson(Map<String, dynamic> json) {
    final tokenData = json['token'] as Map<String, dynamic>;
    return ProfileCompletionData(
      user: json['user'] as Map<String, dynamic>,
      token: tokenData['access_token'] as String,
      tokenType: tokenData['token_type'] as String,
      expiresIn: tokenData['expires_in'] as int,
      scopes: (tokenData['scopes'] as List<dynamic>).map((s) => s as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'token': {
        'access_token': token,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'scopes': scopes,
      },
    };
  }
}

class ProfileCompletionStatus {
  final bool isComplete;
  final bool profileCompleted;
  final bool needsProfileCompletion;
  final List<String> missingFields;

  const ProfileCompletionStatus({
    required this.isComplete,
    required this.profileCompleted,
    required this.needsProfileCompletion,
    required this.missingFields,
  });

  factory ProfileCompletionStatus.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionStatus(
      isComplete: json['is_complete'] as bool,
      profileCompleted: json['profile_completed'] as bool,
      needsProfileCompletion: json['needs_profile_completion'] as bool,
      missingFields: (json['missing_fields'] as List<dynamic>?)
          ?.map((field) => field as String)
          .toList() ?? [],
    );
  }
}

class ProfileCompletionResponse {
  final bool status;
  final String message;
  final ProfileCompletionData? data;

  const ProfileCompletionResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProfileCompletionResponse.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? ProfileCompletionData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
