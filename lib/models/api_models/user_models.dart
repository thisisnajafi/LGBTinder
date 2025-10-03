import 'dart:convert';

/// User Management API Models
/// 
/// This file contains all data models for user management endpoints
/// including getting current user profile and related data.

// ============================================================================
// USER PROFILE MODELS
// ============================================================================

/// User image data model
class UserImage {
  final int id;
  final String url;
  final bool isPrimary;
  final int order;

  const UserImage({
    required this.id,
    required this.url,
    required this.isPrimary,
    required this.order,
  });

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      id: json['id'] as int,
      url: json['url'] as String,
      isPrimary: json['is_primary'] as bool,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'is_primary': isPrimary,
      'order': order,
    };
  }
}

/// User job data model
class UserJob {
  final int id;
  final String title;

  const UserJob({
    required this.id,
    required this.title,
  });

  factory UserJob.fromJson(Map<String, dynamic> json) {
    return UserJob(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

/// User education data model
class UserEducation {
  final int id;
  final String title;

  const UserEducation({
    required this.id,
    required this.title,
  });

  factory UserEducation.fromJson(Map<String, dynamic> json) {
    return UserEducation(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

/// User music genre data model
class UserMusicGenre {
  final int id;
  final String title;

  const UserMusicGenre({
    required this.id,
    required this.title,
  });

  factory UserMusicGenre.fromJson(Map<String, dynamic> json) {
    return UserMusicGenre(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

/// User language data model
class UserLanguage {
  final int id;
  final String title;

  const UserLanguage({
    required this.id,
    required this.title,
  });

  factory UserLanguage.fromJson(Map<String, dynamic> json) {
    return UserLanguage(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

/// User interest data model
class UserInterest {
  final int id;
  final String title;

  const UserInterest({
    required this.id,
    required this.title,
  });

  factory UserInterest.fromJson(Map<String, dynamic> json) {
    return UserInterest(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

/// User preferred gender data model
class UserPreferredGender {
  final int id;
  final String title;

  const UserPreferredGender({
    required this.id,
    required this.title,
  });

  factory UserPreferredGender.fromJson(Map<String, dynamic> json) {
    return UserPreferredGender(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

/// User relation goal data model
class UserRelationGoal {
  final int id;
  final String title;

  const UserRelationGoal({
    required this.id,
    required this.title,
  });

  factory UserRelationGoal.fromJson(Map<String, dynamic> json) {
    return UserRelationGoal(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

/// Complete user profile data model
class UserProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final int countryId;
  final int cityId;
  final String country;
  final String city;
  final String birthDate;
  final String profileBio;
  final String? avatarUrl;
  final int height;
  final int weight;
  final bool smoke;
  final bool drink;
  final bool gym;
  final int minAgePreference;
  final int maxAgePreference;
  final bool profileCompleted;
  final List<UserImage> images;
  final List<UserJob> jobs;
  final List<UserEducation> educations;
  final List<UserMusicGenre> musicGenres;
  final List<UserLanguage> languages;
  final List<UserInterest> interests;
  final List<UserPreferredGender> preferredGenders;
  final List<UserRelationGoal> relationGoals;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.countryId,
    required this.cityId,
    required this.country,
    required this.city,
    required this.birthDate,
    required this.profileBio,
    this.avatarUrl,
    required this.height,
    required this.weight,
    required this.smoke,
    required this.drink,
    required this.gym,
    required this.minAgePreference,
    required this.maxAgePreference,
    required this.profileCompleted,
    required this.images,
    required this.jobs,
    required this.educations,
    required this.musicGenres,
    required this.languages,
    required this.interests,
    required this.preferredGenders,
    required this.relationGoals,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      countryId: json['country_id'] as int,
      cityId: json['city_id'] as int,
      country: json['country'] as String,
      city: json['city'] as String,
      birthDate: json['birth_date'] as String,
      profileBio: json['profile_bio'] as String,
      avatarUrl: json['avatar_url'] as String?,
      height: json['height'] as int,
      weight: json['weight'] as int,
      smoke: json['smoke'] as bool,
      drink: json['drink'] as bool,
      gym: json['gym'] as bool,
      minAgePreference: json['min_age_preference'] as int,
      maxAgePreference: json['max_age_preference'] as int,
      profileCompleted: json['profile_completed'] as bool,
      images: (json['images'] as List).map((item) => UserImage.fromJson(item as Map<String, dynamic>)).toList(),
      jobs: (json['jobs'] as List).map((item) => UserJob.fromJson(item as Map<String, dynamic>)).toList(),
      educations: (json['educations'] as List).map((item) => UserEducation.fromJson(item as Map<String, dynamic>)).toList(),
      musicGenres: (json['music_genres'] as List).map((item) => UserMusicGenre.fromJson(item as Map<String, dynamic>)).toList(),
      languages: (json['languages'] as List).map((item) => UserLanguage.fromJson(item as Map<String, dynamic>)).toList(),
      interests: (json['interests'] as List).map((item) => UserInterest.fromJson(item as Map<String, dynamic>)).toList(),
      preferredGenders: (json['preferred_genders'] as List).map((item) => UserPreferredGender.fromJson(item as Map<String, dynamic>)).toList(),
      relationGoals: (json['relation_goals'] as List).map((item) => UserRelationGoal.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'country_id': countryId,
      'city_id': cityId,
      'country': country,
      'city': city,
      'birth_date': birthDate,
      'profile_bio': profileBio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'height': height,
      'weight': weight,
      'smoke': smoke,
      'drink': drink,
      'gym': gym,
      'min_age_preference': minAgePreference,
      'max_age_preference': maxAgePreference,
      'profile_completed': profileCompleted,
      'images': images.map((image) => image.toJson()).toList(),
      'jobs': jobs.map((job) => job.toJson()).toList(),
      'educations': educations.map((education) => education.toJson()).toList(),
      'music_genres': musicGenres.map((genre) => genre.toJson()).toList(),
      'languages': languages.map((language) => language.toJson()).toList(),
      'interests': interests.map((interest) => interest.toJson()).toList(),
      'preferred_genders': preferredGenders.map((gender) => gender.toJson()).toList(),
      'relation_goals': relationGoals.map((goal) => goal.toJson()).toList(),
    };
  }

  /// Get user's age from birth date
  int get age {
    final birthDate = DateTime.parse(this.birthDate);
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Get primary image URL
  String? get primaryImageUrl {
    try {
      return images.firstWhere((image) => image.isPrimary).url;
    } catch (e) {
      return images.isNotEmpty ? images.first.url : null;
    }
  }

  /// Get all image URLs
  List<String> get allImageUrls {
    return images.map((image) => image.url).toList();
  }

  /// Get job titles
  List<String> get jobTitles {
    return jobs.map((job) => job.title).toList();
  }

  /// Get education titles
  List<String> get educationTitles {
    return educations.map((education) => education.title).toList();
  }

  /// Get music genre titles
  List<String> get musicGenreTitles {
    return musicGenres.map((genre) => genre.title).toList();
  }

  /// Get language titles
  List<String> get languageTitles {
    return languages.map((language) => language.title).toList();
  }

  /// Get interest titles
  List<String> get interestTitles {
    return interests.map((interest) => interest.title).toList();
  }

  /// Get preferred gender titles
  List<String> get preferredGenderTitles {
    return preferredGenders.map((gender) => gender.title).toList();
  }

  /// Get relation goal titles
  List<String> get relationGoalTitles {
    return relationGoals.map((goal) => goal.title).toList();
  }
}
