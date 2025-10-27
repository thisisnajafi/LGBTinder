import 'package:flutter/foundation.dart';

/// Discovery Filters Model
/// 
/// Contains all filter options for the discovery/matching system
class DiscoveryFilters {
  // Basic filters
  final int minAge;
  final int maxAge;
  final double maxDistance; // in km
  final List<String> genderPreferences;
  
  // Privacy settings
  final bool showMyAge;
  final bool showMyDistance;
  
  // Advanced filters
  final List<String> educationLevels;
  final List<String> jobs;
  final int? minHeight; // in cm
  final int? maxHeight; // in cm
  final List<String> bodyTypes;
  final List<String> smokingHabits;
  final List<String> drinkingHabits;
  final List<String> exerciseFrequencies;
  final List<String> relationshipGoals;
  final List<String> languages;
  final List<String> interests;
  
  // Additional filters
  final bool verifiedOnly;
  final bool recentlyActiveOnly;
  
  const DiscoveryFilters({
    this.minAge = 18,
    this.maxAge = 80,
    this.maxDistance = 50.0,
    this.genderPreferences = const [],
    this.showMyAge = true,
    this.showMyDistance = true,
    this.educationLevels = const [],
    this.jobs = const [],
    this.minHeight,
    this.maxHeight,
    this.bodyTypes = const [],
    this.smokingHabits = const [],
    this.drinkingHabits = const [],
    this.exerciseFrequencies = const [],
    this.relationshipGoals = const [],
    this.languages = const [],
    this.interests = const [],
    this.verifiedOnly = false,
    this.recentlyActiveOnly = false,
  });

  /// Create filters from JSON
  factory DiscoveryFilters.fromJson(Map<String, dynamic> json) {
    return DiscoveryFilters(
      minAge: json['minAge'] as int? ?? 18,
      maxAge: json['maxAge'] as int? ?? 80,
      maxDistance: (json['maxDistance'] as num?)?.toDouble() ?? 50.0,
      genderPreferences: (json['genderPreferences'] as List?)?.cast<String>() ?? [],
      showMyAge: json['showMyAge'] as bool? ?? true,
      showMyDistance: json['showMyDistance'] as bool? ?? true,
      educationLevels: (json['educationLevels'] as List?)?.cast<String>() ?? [],
      jobs: (json['jobs'] as List?)?.cast<String>() ?? [],
      minHeight: json['minHeight'] as int?,
      maxHeight: json['maxHeight'] as int?,
      bodyTypes: (json['bodyTypes'] as List?)?.cast<String>() ?? [],
      smokingHabits: (json['smokingHabits'] as List?)?.cast<String>() ?? [],
      drinkingHabits: (json['drinkingHabits'] as List?)?.cast<String>() ?? [],
      exerciseFrequencies: (json['exerciseFrequencies'] as List?)?.cast<String>() ?? [],
      relationshipGoals: (json['relationshipGoals'] as List?)?.cast<String>() ?? [],
      languages: (json['languages'] as List?)?.cast<String>() ?? [],
      interests: (json['interests'] as List?)?.cast<String>() ?? [],
      verifiedOnly: json['verifiedOnly'] as bool? ?? false,
      recentlyActiveOnly: json['recentlyActiveOnly'] as bool? ?? false,
    );
  }

  /// Convert filters to JSON
  Map<String, dynamic> toJson() {
    return {
      'minAge': minAge,
      'maxAge': maxAge,
      'maxDistance': maxDistance,
      'genderPreferences': genderPreferences,
      'showMyAge': showMyAge,
      'showMyDistance': showMyDistance,
      'educationLevels': educationLevels,
      'jobs': jobs,
      'minHeight': minHeight,
      'maxHeight': maxHeight,
      'bodyTypes': bodyTypes,
      'smokingHabits': smokingHabits,
      'drinkingHabits': drinkingHabits,
      'exerciseFrequencies': exerciseFrequencies,
      'relationshipGoals': relationshipGoals,
      'languages': languages,
      'interests': interests,
      'verifiedOnly': verifiedOnly,
      'recentlyActiveOnly': recentlyActiveOnly,
    };
  }

  /// Convert filters to API query parameters
  Map<String, dynamic> toApiParams() {
    final params = <String, dynamic>{
      'minAge': minAge,
      'maxAge': maxAge,
      'distance': maxDistance,
    };

    if (genderPreferences.isNotEmpty) {
      params['gender'] = genderPreferences.join(',');
    }
    if (educationLevels.isNotEmpty) {
      params['education'] = educationLevels.join(',');
    }
    if (jobs.isNotEmpty) {
      params['job'] = jobs.join(',');
    }
    if (minHeight != null) {
      params['minHeight'] = minHeight;
    }
    if (maxHeight != null) {
      params['maxHeight'] = maxHeight;
    }
    if (bodyTypes.isNotEmpty) {
      params['bodyType'] = bodyTypes.join(',');
    }
    if (smokingHabits.isNotEmpty) {
      params['smoking'] = smokingHabits.join(',');
    }
    if (drinkingHabits.isNotEmpty) {
      params['drinking'] = drinkingHabits.join(',');
    }
    if (exerciseFrequencies.isNotEmpty) {
      params['exercise'] = exerciseFrequencies.join(',');
    }
    if (relationshipGoals.isNotEmpty) {
      params['relationshipGoal'] = relationshipGoals.join(',');
    }
    if (languages.isNotEmpty) {
      params['languages'] = languages.join(',');
    }
    if (interests.isNotEmpty) {
      params['interests'] = interests.join(',');
    }
    if (verifiedOnly) {
      params['verified'] = true;
    }
    if (recentlyActiveOnly) {
      params['recentlyActive'] = true;
    }

    return params;
  }

  /// Copy with new values
  DiscoveryFilters copyWith({
    int? minAge,
    int? maxAge,
    double? maxDistance,
    List<String>? genderPreferences,
    bool? showMyAge,
    bool? showMyDistance,
    List<String>? educationLevels,
    List<String>? jobs,
    int? minHeight,
    int? maxHeight,
    List<String>? bodyTypes,
    List<String>? smokingHabits,
    List<String>? drinkingHabits,
    List<String>? exerciseFrequencies,
    List<String>? relationshipGoals,
    List<String>? languages,
    List<String>? interests,
    bool? verifiedOnly,
    bool? recentlyActiveOnly,
  }) {
    return DiscoveryFilters(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      genderPreferences: genderPreferences ?? this.genderPreferences,
      showMyAge: showMyAge ?? this.showMyAge,
      showMyDistance: showMyDistance ?? this.showMyDistance,
      educationLevels: educationLevels ?? this.educationLevels,
      jobs: jobs ?? this.jobs,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      bodyTypes: bodyTypes ?? this.bodyTypes,
      smokingHabits: smokingHabits ?? this.smokingHabits,
      drinkingHabits: drinkingHabits ?? this.drinkingHabits,
      exerciseFrequencies: exerciseFrequencies ?? this.exerciseFrequencies,
      relationshipGoals: relationshipGoals ?? this.relationshipGoals,
      languages: languages ?? this.languages,
      interests: interests ?? this.interests,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      recentlyActiveOnly: recentlyActiveOnly ?? this.recentlyActiveOnly,
    );
  }

  /// Check if filters are default (no custom filters applied)
  bool get isDefault {
    return minAge == 18 &&
        maxAge == 80 &&
        maxDistance == 50.0 &&
        genderPreferences.isEmpty &&
        showMyAge == true &&
        showMyDistance == true &&
        educationLevels.isEmpty &&
        jobs.isEmpty &&
        minHeight == null &&
        maxHeight == null &&
        bodyTypes.isEmpty &&
        smokingHabits.isEmpty &&
        drinkingHabits.isEmpty &&
        exerciseFrequencies.isEmpty &&
        relationshipGoals.isEmpty &&
        languages.isEmpty &&
        interests.isEmpty &&
        !verifiedOnly &&
        !recentlyActiveOnly;
  }

  /// Count active filters (non-default)
  int get activeFilterCount {
    int count = 0;
    
    // Basic filters
    if (minAge != 18 || maxAge != 80) count++;
    if (maxDistance != 50.0) count++;
    if (genderPreferences.isNotEmpty) count++;
    
    // Advanced filters
    if (educationLevels.isNotEmpty) count++;
    if (jobs.isNotEmpty) count++;
    if (minHeight != null || maxHeight != null) count++;
    if (bodyTypes.isNotEmpty) count++;
    if (smokingHabits.isNotEmpty) count++;
    if (drinkingHabits.isNotEmpty) count++;
    if (exerciseFrequencies.isNotEmpty) count++;
    if (relationshipGoals.isNotEmpty) count++;
    if (languages.isNotEmpty) count++;
    if (interests.isNotEmpty) count++;
    if (verifiedOnly) count++;
    if (recentlyActiveOnly) count++;
    
    return count;
  }

  /// Reset to default filters
  static DiscoveryFilters get defaultFilters => const DiscoveryFilters();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is DiscoveryFilters &&
        other.minAge == minAge &&
        other.maxAge == maxAge &&
        other.maxDistance == maxDistance &&
        listEquals(other.genderPreferences, genderPreferences) &&
        other.showMyAge == showMyAge &&
        other.showMyDistance == showMyDistance &&
        listEquals(other.educationLevels, educationLevels) &&
        listEquals(other.jobs, jobs) &&
        other.minHeight == minHeight &&
        other.maxHeight == maxHeight &&
        listEquals(other.bodyTypes, bodyTypes) &&
        listEquals(other.smokingHabits, smokingHabits) &&
        listEquals(other.drinkingHabits, drinkingHabits) &&
        listEquals(other.exerciseFrequencies, exerciseFrequencies) &&
        listEquals(other.relationshipGoals, relationshipGoals) &&
        listEquals(other.languages, languages) &&
        listEquals(other.interests, interests) &&
        other.verifiedOnly == verifiedOnly &&
        other.recentlyActiveOnly == recentlyActiveOnly;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      minAge,
      maxAge,
      maxDistance,
      Object.hashAll(genderPreferences),
      showMyAge,
      showMyDistance,
      Object.hashAll(educationLevels),
      Object.hashAll(jobs),
      minHeight,
      maxHeight,
      Object.hashAll(bodyTypes),
      Object.hashAll(smokingHabits),
      Object.hashAll(drinkingHabits),
      Object.hashAll(exerciseFrequencies),
      Object.hashAll(relationshipGoals),
      Object.hashAll(languages),
      Object.hashAll(interests),
      verifiedOnly,
      recentlyActiveOnly,
    ]);
  }

  @override
  String toString() {
    return 'DiscoveryFilters(minAge: $minAge, maxAge: $maxAge, maxDistance: $maxDistance, activeFilters: $activeFilterCount)';
  }
}

