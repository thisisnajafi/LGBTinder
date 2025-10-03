import 'dart:convert';

/// Reference Data API Models
/// 
/// This file contains all data models for reference data endpoints
/// including countries, cities, genders, jobs, education, interests, languages, music genres, relation goals, and preferred genders.

// ============================================================================
// COMMON REFERENCE DATA MODELS
// ============================================================================

/// Base model for reference data items with id, title, and status
class ReferenceDataItem {
  final int id;
  final String title;
  final String status;
  final String? imageUrl;

  const ReferenceDataItem({
    required this.id,
    required this.title,
    required this.status,
    this.imageUrl,
  });

  factory ReferenceDataItem.fromJson(Map<String, dynamic> json) {
    return ReferenceDataItem(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}

/// Base response model for reference data endpoints
class ReferenceDataResponse<T> {
  final String status;
  final List<T> data;

  const ReferenceDataResponse({
    required this.status,
    required this.data,
  });

  factory ReferenceDataResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ReferenceDataResponse<T>(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data,
    };
  }
}

// ============================================================================
// COUNTRIES MODELS
// ============================================================================

/// Country data model
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

/// Countries response model
class CountriesResponse {
  final String status;
  final List<Country> data;

  const CountriesResponse({
    required this.status,
    required this.data,
  });

  factory CountriesResponse.fromJson(Map<String, dynamic> json) {
    return CountriesResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => Country.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((country) => country.toJson()).toList(),
    };
  }
}

// ============================================================================
// CITIES MODELS
// ============================================================================

/// City data model
class City {
  final int id;
  final String name;
  final String? stateProvince;
  final int countryId;

  const City({
    required this.id,
    required this.name,
    this.stateProvince,
    this.countryId = 0,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      stateProvince: json['state_province'] as String?,
      countryId: json['country_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (stateProvince != null) 'state_province': stateProvince,
    };
  }
}

/// Cities response model
class CitiesResponse {
  final String status;
  final List<City> data;

  const CitiesResponse({
    required this.status,
    required this.data,
  });

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    return CitiesResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => City.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((city) => city.toJson()).toList(),
    };
  }
}

// ============================================================================
// GENDERS MODELS
// ============================================================================

/// Gender data model
class Gender {
  final int id;
  final String title;
  final String status;

  const Gender({
    required this.id,
    required this.title,
    required this.status,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}

/// Genders response model
class GendersResponse {
  final String status;
  final List<Gender> data;

  const GendersResponse({
    required this.status,
    required this.data,
  });

  factory GendersResponse.fromJson(Map<String, dynamic> json) {
    return GendersResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => Gender.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((gender) => gender.toJson()).toList(),
    };
  }
}

// ============================================================================
// JOBS MODELS
// ============================================================================

/// Job data model
class Job {
  final int id;
  final String title;
  final String status;

  const Job({
    required this.id,
    required this.title,
    required this.status,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}

/// Jobs response model
class JobsResponse {
  final String status;
  final List<Job> data;

  const JobsResponse({
    required this.status,
    required this.data,
  });

  factory JobsResponse.fromJson(Map<String, dynamic> json) {
    return JobsResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => Job.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((job) => job.toJson()).toList(),
    };
  }
}

// ============================================================================
// EDUCATION MODELS
// ============================================================================

/// Education data model
class Education {
  final int id;
  final String title;
  final String status;

  const Education({
    required this.id,
    required this.title,
    required this.status,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}

/// Education response model
class EducationResponse {
  final String status;
  final List<Education> data;

  const EducationResponse({
    required this.status,
    required this.data,
  });

  factory EducationResponse.fromJson(Map<String, dynamic> json) {
    return EducationResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => Education.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((education) => education.toJson()).toList(),
    };
  }
}

// ============================================================================
// INTERESTS MODELS
// ============================================================================

/// Interest data model
class Interest {
  final int id;
  final String title;
  final String status;

  const Interest({
    required this.id,
    required this.title,
    required this.status,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}

/// Interests response model
class InterestsResponse {
  final String status;
  final List<Interest> data;

  const InterestsResponse({
    required this.status,
    required this.data,
  });

  factory InterestsResponse.fromJson(Map<String, dynamic> json) {
    return InterestsResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => Interest.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((interest) => interest.toJson()).toList(),
    };
  }
}

// ============================================================================
// LANGUAGES MODELS
// ============================================================================

/// Language data model
class Language {
  final int id;
  final String title;
  final String status;

  const Language({
    required this.id,
    required this.title,
    required this.status,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}

/// Languages response model
class LanguagesResponse {
  final String status;
  final List<Language> data;

  const LanguagesResponse({
    required this.status,
    required this.data,
  });

  factory LanguagesResponse.fromJson(Map<String, dynamic> json) {
    return LanguagesResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => Language.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((language) => language.toJson()).toList(),
    };
  }
}

// ============================================================================
// MUSIC GENRES MODELS
// ============================================================================

/// Music genre data model
class MusicGenre {
  final int id;
  final String title;
  final String status;

  const MusicGenre({
    required this.id,
    required this.title,
    required this.status,
  });

  factory MusicGenre.fromJson(Map<String, dynamic> json) {
    return MusicGenre(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}

/// Music genres response model
class MusicGenresResponse {
  final String status;
  final List<MusicGenre> data;

  const MusicGenresResponse({
    required this.status,
    required this.data,
  });

  factory MusicGenresResponse.fromJson(Map<String, dynamic> json) {
    return MusicGenresResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => MusicGenre.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((genre) => genre.toJson()).toList(),
    };
  }
}

// ============================================================================
// RELATION GOALS MODELS
// ============================================================================

/// Relation goal data model
class RelationGoal {
  final int id;
  final String title;
  final String? imageUrl;

  const RelationGoal({
    required this.id,
    required this.title,
    this.imageUrl,
  });

  factory RelationGoal.fromJson(Map<String, dynamic> json) {
    return RelationGoal(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}

/// Relation goals response model
class RelationGoalsResponse {
  final String status;
  final List<RelationGoal> data;

  const RelationGoalsResponse({
    required this.status,
    required this.data,
  });

  factory RelationGoalsResponse.fromJson(Map<String, dynamic> json) {
    return RelationGoalsResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => RelationGoal.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((goal) => goal.toJson()).toList(),
    };
  }
}

// ============================================================================
// PREFERRED GENDERS MODELS
// ============================================================================

/// Preferred gender data model
class PreferredGender {
  final int id;
  final String title;
  final String status;

  const PreferredGender({
    required this.id,
    required this.title,
    required this.status,
  });

  factory PreferredGender.fromJson(Map<String, dynamic> json) {
    return PreferredGender(
      id: json['id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
    };
  }
}

/// Preferred genders response model
class PreferredGendersResponse {
  final String status;
  final List<PreferredGender> data;

  const PreferredGendersResponse({
    required this.status,
    required this.data,
  });

  factory PreferredGendersResponse.fromJson(Map<String, dynamic> json) {
    return PreferredGendersResponse(
      status: json['status'] as String,
      data: (json['data'] as List).map((item) => PreferredGender.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((gender) => gender.toJson()).toList(),
    };
  }
}
