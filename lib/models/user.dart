import 'user_image.dart';
import 'reference_data.dart';
import 'user_preferences.dart';
import 'user_settings.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? country;
  final String? city;
  final DateTime? birthDate;
  final String? profileBio;
  final String? bio; // Alias for profileBio
  final String? avatarUrl;
  final String? name; // Alias for fullName
  final String? job; // Current job title
  final String? company; // Current company
  final String? school; // Current school
  final String? location; // Current location
  final List<Job> jobs;
  final List<Education> educations;
  final List<MusicGenre> musicGenres;
  final List<Language> languages;
  final List<Interest> interests;
  final List<RelationGoal> relationGoals;
  final RelationshipGoal? relationshipGoal; // Current relationship goal
  final List<PreferredGender> preferredGenders;
  final List<Gender>? interestedIn; // Alias for preferredGenders
  final String? gender;
  final double? weight;
  final double? height;
  final String? sexualOrientation;
  final int? smoke; // 0: No, 1: Yes, 2: Sometimes
  final int? gym; // 0: No, 1: Yes, 2: Sometimes
  final int? drink; // 0: No, 1: Yes, 2: Sometimes
  final List<UserImage> profileImages;
  final List<UserImage> galleryImages;
  final List<UserImage>? images; // Combined images
  final UserImage? primaryProfileImage;
  final bool isOnline;
  final bool isVerified;
  final bool isPremium;
  final DateTime? lastSeen;
  final UserPreferences? preferences; // User preferences
  final UserSettings? settings; // User settings
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.country,
    this.city,
    this.birthDate,
    this.profileBio,
    this.bio,
    this.avatarUrl,
    this.name,
    this.job,
    this.company,
    this.school,
    this.location,
    this.jobs = const [],
    this.educations = const [],
    this.musicGenres = const [],
    this.languages = const [],
    this.interests = const [],
    this.relationGoals = const [],
    this.relationshipGoal,
    this.preferredGenders = const [],
    this.interestedIn,
    this.gender,
    this.weight,
    this.height,
    this.sexualOrientation,
    this.smoke,
    this.gym,
    this.drink,
    this.profileImages = const [],
    this.galleryImages = const [],
    this.images,
    this.primaryProfileImage,
    this.isOnline = false,
    this.isVerified = false,
    this.isPremium = false,
    this.lastSeen,
    this.preferences,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate age from birth date
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || 
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Check if user is 18+
  bool get isAdult {
    if (birthDate == null) return false;
    return age != null && age! >= 18;
  }

  // Get all images (profile + gallery)
  List<UserImage> get allImages {
    return [...profileImages, ...galleryImages];
  }

  // Get lifestyle preferences as string
  String? get smokingStatus {
    switch (smoke) {
      case 0: return 'No';
      case 1: return 'Yes';
      case 2: return 'Sometimes';
      default: return null;
    }
  }

  String? get gymStatus {
    switch (gym) {
      case 0: return 'No';
      case 1: return 'Yes';
      case 2: return 'Sometimes';
      default: return null;
    }
  }

  String? get drinkingStatus {
    switch (drink) {
      case 0: return 'No';
      case 1: return 'Yes';
      case 2: return 'Sometimes';
      default: return null;
    }
  }

  // Factory constructor from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'],
      country: json['country'],
      city: json['city'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      profileBio: json['profile_bio'],
      bio: json['bio'] ?? json['profile_bio'],
      avatarUrl: json['avatar_url'],
      name: json['name'] ?? json['full_name'],
      job: json['job'],
      company: json['company'],
      school: json['school'],
      location: json['location'],
      jobs: (json['jobs'] as List<dynamic>?)
          ?.map((job) => Job.fromJson(job))
          .toList() ?? [],
      educations: (json['educations'] as List<dynamic>?)
          ?.map((education) => Education.fromJson(education))
          .toList() ?? [],
      musicGenres: (json['music_genres'] as List<dynamic>?)
          ?.map((genre) => MusicGenre.fromJson(genre))
          .toList() ?? [],
      languages: (json['languages'] as List<dynamic>?)
          ?.map((language) => Language.fromJson(language))
          .toList() ?? [],
      interests: (json['interests'] as List<dynamic>?)
          ?.map((interest) => Interest.fromJson(interest))
          .toList() ?? [],
      relationGoals: (json['relation_goals'] as List<dynamic>?)
          ?.map((goal) => RelationGoal.fromJson(goal))
          .toList() ?? [],
      relationshipGoal: json['relationship_goal'] != null
          ? RelationshipGoal.fromJson(json['relationship_goal'])
          : null,
      preferredGenders: (json['preferred_genders'] as List<dynamic>?)
          ?.map((gender) => PreferredGender.fromJson(gender))
          .toList() ?? [],
      interestedIn: (json['interested_in'] as List<dynamic>?)
          ?.map((gender) => Gender.fromJson(gender))
          .toList() ?? [],
      gender: json['gender'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      sexualOrientation: json['sexual_orientation'],
      smoke: json['smoke'],
      gym: json['gym'],
      drink: json['drink'],
      profileImages: (json['profile_images'] as List<dynamic>?)
          ?.map((image) => UserImage.fromJson(image))
          .toList() ?? [],
      galleryImages: (json['gallery_images'] as List<dynamic>?)
          ?.map((image) => UserImage.fromJson(image))
          .toList() ?? [],
      images: (json['images'] as List<dynamic>?)
          ?.map((image) => UserImage.fromJson(image))
          .toList() ?? [],
      primaryProfileImage: json['primary_profile_image'] != null
          ? UserImage.fromJson(json['primary_profile_image'])
          : null,
      isOnline: json['is_online'] ?? false,
      isVerified: json['is_verified'] ?? false,
      isPremium: json['is_premium'] ?? false,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen']) 
          : null,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'country': country,
      'city': city,
      'birth_date': birthDate?.toIso8601String(),
      'profile_bio': profileBio,
      'avatar_url': avatarUrl,
      'jobs': jobs.map((job) => job.toJson()).toList(),
      'educations': educations.map((education) => education.toJson()).toList(),
      'music_genres': musicGenres.map((genre) => genre.toJson()).toList(),
      'languages': languages.map((language) => language.toJson()).toList(),
      'interests': interests.map((interest) => interest.toJson()).toList(),
      'relation_goals': relationGoals.map((goal) => goal.toJson()).toList(),
      'preferred_genders': preferredGenders.map((gender) => gender.toJson()).toList(),
      'gender': gender,
      'weight': weight,
      'height': height,
      'sexual_orientation': sexualOrientation,
      'smoke': smoke,
      'gym': gym,
      'drink': drink,
      'profile_images': profileImages.map((image) => image.toJson()).toList(),
      'gallery_images': galleryImages.map((image) => image.toJson()).toList(),
      'primary_profile_image': primaryProfileImage?.toJson(),
      'is_online': isOnline,
      'is_verified': isVerified,
      'is_premium': isPremium,
      'last_seen': lastSeen?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? country,
    String? city,
    DateTime? birthDate,
    String? profileBio,
    String? bio,
    String? avatarUrl,
    String? name,
    String? job,
    String? company,
    String? school,
    String? location,
    List<Job>? jobs,
    List<Education>? educations,
    List<MusicGenre>? musicGenres,
    List<Language>? languages,
    List<Interest>? interests,
    List<RelationGoal>? relationGoals,
    RelationshipGoal? relationshipGoal,
    List<PreferredGender>? preferredGenders,
    List<Gender>? interestedIn,
    String? gender,
    double? weight,
    double? height,
    String? sexualOrientation,
    int? smoke,
    int? gym,
    int? drink,
    List<UserImage>? profileImages,
    List<UserImage>? galleryImages,
    List<UserImage>? images,
    UserImage? primaryProfileImage,
    bool? isOnline,
    bool? isVerified,
    bool? isPremium,
    DateTime? lastSeen,
    UserPreferences? preferences,
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      country: country ?? this.country,
      city: city ?? this.city,
      birthDate: birthDate ?? this.birthDate,
      profileBio: profileBio ?? this.profileBio,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      name: name ?? this.name,
      job: job ?? this.job,
      company: company ?? this.company,
      school: school ?? this.school,
      location: location ?? this.location,
      jobs: jobs ?? this.jobs,
      educations: educations ?? this.educations,
      musicGenres: musicGenres ?? this.musicGenres,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      relationGoals: relationGoals ?? this.relationGoals,
      relationshipGoal: relationshipGoal ?? this.relationshipGoal,
      preferredGenders: preferredGenders ?? this.preferredGenders,
      interestedIn: interestedIn ?? this.interestedIn,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      smoke: smoke ?? this.smoke,
      gym: gym ?? this.gym,
      drink: drink ?? this.drink,
      profileImages: profileImages ?? this.profileImages,
      galleryImages: galleryImages ?? this.galleryImages,
      images: images ?? this.images,
      primaryProfileImage: primaryProfileImage ?? this.primaryProfileImage,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      lastSeen: lastSeen ?? this.lastSeen,
      preferences: preferences ?? this.preferences,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
  
  // Static method to create an empty user
  static User empty() {
    return User(
      id: 0,
      firstName: '',
      lastName: '',
      fullName: '',
      email: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
