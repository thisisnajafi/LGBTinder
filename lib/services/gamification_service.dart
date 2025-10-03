import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final String category;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final Map<String, dynamic> requirements;
  final String? reward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
    this.requirements = const {},
    this.reward,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? points,
    String? category,
    bool? isUnlocked,
    DateTime? unlockedAt,
    Map<String, dynamic>? requirements,
    String? reward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      requirements: requirements ?? this.requirements,
      reward: reward ?? this.reward,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'category': category,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'requirements': requirements,
      'reward': reward,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      points: json['points'],
      category: json['category'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      requirements: Map<String, dynamic>.from(json['requirements'] ?? {}),
      reward: json['reward'],
    );
  }
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final String rarity; // common, rare, epic, legendary
  final bool isEarned;
  final DateTime? earnedAt;
  final Map<String, dynamic> criteria;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.rarity,
    this.isEarned = false,
    this.earnedAt,
    this.criteria = const {},
  });

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    String? rarity,
    bool? isEarned,
    DateTime? earnedAt,
    Map<String, dynamic>? criteria,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      rarity: rarity ?? this.rarity,
      isEarned: isEarned ?? this.isEarned,
      earnedAt: earnedAt ?? this.earnedAt,
      criteria: criteria ?? this.criteria,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'rarity': rarity,
      'isEarned': isEarned,
      'earnedAt': earnedAt?.toIso8601String(),
      'criteria': criteria,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      rarity: json['rarity'],
      isEarned: json['isEarned'] ?? false,
      earnedAt: json['earnedAt'] != null ? DateTime.parse(json['earnedAt']) : null,
      criteria: Map<String, dynamic>.from(json['criteria'] ?? {}),
    );
  }
}

class ProfileCompletionProgress {
  final int totalSteps;
  final int completedSteps;
  final double completionPercentage;
  final List<String> completedSections;
  final List<String> remainingSections;
  final int totalPoints;
  final int earnedPoints;
  final int level;
  final int experiencePoints;
  final int nextLevelExperience;

  const ProfileCompletionProgress({
    required this.totalSteps,
    required this.completedSteps,
    required this.completionPercentage,
    required this.completedSections,
    required this.remainingSections,
    required this.totalPoints,
    required this.earnedPoints,
    required this.level,
    required this.experiencePoints,
    required this.nextLevelExperience,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalSteps': totalSteps,
      'completedSteps': completedSteps,
      'completionPercentage': completionPercentage,
      'completedSections': completedSections,
      'remainingSections': remainingSections,
      'totalPoints': totalPoints,
      'earnedPoints': earnedPoints,
      'level': level,
      'experiencePoints': experiencePoints,
      'nextLevelExperience': nextLevelExperience,
    };
  }

  factory ProfileCompletionProgress.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionProgress(
      totalSteps: json['totalSteps'],
      completedSteps: json['completedSteps'],
      completionPercentage: json['completionPercentage'],
      completedSections: List<String>.from(json['completedSections']),
      remainingSections: List<String>.from(json['remainingSections']),
      totalPoints: json['totalPoints'],
      earnedPoints: json['earnedPoints'],
      level: json['level'],
      experiencePoints: json['experiencePoints'],
      nextLevelExperience: json['nextLevelExperience'],
    );
  }
}

class GamificationService {
  static const String _achievementsKey = 'user_achievements';
  static const String _badgesKey = 'user_badges';
  static const String _progressKey = 'profile_completion_progress';
  static const String _experienceKey = 'user_experience';
  static const String _levelKey = 'user_level';
  
  static GamificationService? _instance;
  static GamificationService get instance {
    _instance ??= GamificationService._();
    return _instance!;
  }

  GamificationService._();

  /// Get all available achievements
  List<Achievement> getAvailableAchievements() {
    return [
      // Profile Completion Achievements
      Achievement(
        id: 'first_photo',
        title: 'First Photo',
        description: 'Add your first profile photo',
        icon: 'photo_camera',
        points: 50,
        category: 'profile',
        requirements: {'photos': 1},
        reward: 'Profile visibility boost',
      ),
      Achievement(
        id: 'photo_collection',
        title: 'Photo Collection',
        description: 'Add 5 profile photos',
        icon: 'collections',
        points: 100,
        category: 'profile',
        requirements: {'photos': 5},
        reward: 'Premium photo filters',
      ),
      Achievement(
        id: 'bio_master',
        title: 'Bio Master',
        description: 'Write a compelling bio',
        icon: 'edit',
        points: 75,
        category: 'profile',
        requirements: {'bio_length': 100},
        reward: 'Bio writing tips',
      ),
      Achievement(
        id: 'interest_explorer',
        title: 'Interest Explorer',
        description: 'Add 10 interests to your profile',
        icon: 'favorite',
        points: 80,
        category: 'profile',
        requirements: {'interests': 10},
        reward: 'Interest-based matching',
      ),
      Achievement(
        id: 'profile_perfect',
        title: 'Profile Perfect',
        description: 'Complete 100% of your profile',
        icon: 'star',
        points: 200,
        category: 'profile',
        requirements: {'completion': 100},
        reward: 'Premium profile badge',
      ),

      // Social Achievements
      Achievement(
        id: 'first_match',
        title: 'First Match',
        description: 'Get your first match',
        icon: 'favorite',
        points: 100,
        category: 'social',
        requirements: {'matches': 1},
        reward: 'Match celebration animation',
      ),
      Achievement(
        id: 'match_maker',
        title: 'Match Maker',
        description: 'Get 10 matches',
        icon: 'people',
        points: 250,
        category: 'social',
        requirements: {'matches': 10},
        reward: 'Super like boost',
      ),
      Achievement(
        id: 'conversation_starter',
        title: 'Conversation Starter',
        description: 'Start 5 conversations',
        icon: 'chat',
        points: 150,
        category: 'social',
        requirements: {'conversations': 5},
        reward: 'Conversation starters',
      ),
      Achievement(
        id: 'super_liker',
        title: 'Super Liker',
        description: 'Use 10 super likes',
        icon: 'star',
        points: 200,
        category: 'social',
        requirements: {'super_likes': 10},
        reward: 'Extra super likes',
      ),

      // Activity Achievements
      Achievement(
        id: 'daily_user',
        title: 'Daily User',
        description: 'Use the app for 7 consecutive days',
        icon: 'today',
        points: 150,
        category: 'activity',
        requirements: {'consecutive_days': 7},
        reward: 'Daily bonus rewards',
      ),
      Achievement(
        id: 'explorer',
        title: 'Explorer',
        description: 'Discover 50 profiles',
        icon: 'explore',
        points: 120,
        category: 'activity',
        requirements: {'profiles_viewed': 50},
        reward: 'Advanced search filters',
      ),
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Complete profile within 24 hours of joining',
        icon: 'schedule',
        points: 100,
        category: 'activity',
        requirements: {'profile_completion_time': 24},
        reward: 'Priority in discovery',
      ),
    ];
  }

  /// Get all available badges
  List<Badge> getAvailableBadges() {
    return [
      // Profile Badges
      Badge(
        id: 'verified_profile',
        name: 'Verified',
        description: 'Profile verified by our team',
        icon: 'verified',
        color: '0xFF4CAF50',
        rarity: 'rare',
        criteria: {'verification_status': 'verified'},
      ),
      Badge(
        id: 'premium_member',
        name: 'Premium',
        description: 'Premium member',
        icon: 'diamond',
        color: '0xFFFFD700',
        rarity: 'epic',
        criteria: {'membership': 'premium'},
      ),
      Badge(
        id: 'new_member',
        name: 'New Member',
        description: 'Recently joined',
        icon: 'new_releases',
        color: '0xFF2196F3',
        rarity: 'common',
        criteria: {'days_since_join': 7},
      ),
      Badge(
        id: 'profile_complete',
        name: 'Complete',
        description: 'Profile 100% complete',
        icon: 'check_circle',
        color: '0xFF4CAF50',
        rarity: 'rare',
        criteria: {'completion_percentage': 100},
      ),
      Badge(
        id: 'photo_pro',
        name: 'Photo Pro',
        description: 'Has 5+ high-quality photos',
        icon: 'photo_library',
        color: '0xFF9C27B0',
        rarity: 'rare',
        criteria: {'photos_count': 5, 'photo_quality': 'high'},
      ),
      Badge(
        id: 'social_butterfly',
        name: 'Social Butterfly',
        description: 'Very active in conversations',
        icon: 'chat',
        color: '0xFFE91E63',
        rarity: 'epic',
        criteria: {'conversation_rate': 0.8},
      ),
      Badge(
        id: 'match_magnet',
        name: 'Match Magnet',
        description: 'Gets lots of matches',
        icon: 'favorite',
        color: '0xFFFF5722',
        rarity: 'legendary',
        criteria: {'match_rate': 0.7},
      ),
    ];
  }

  /// Get user achievements
  Future<List<Achievement>> getUserAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);
    
    if (achievementsJson != null) {
      try {
        final achievementsList = json.decode(achievementsJson) as List;
        return achievementsList.map((item) => Achievement.fromJson(item)).toList();
      } catch (e) {
        return getAvailableAchievements();
      }
    }
    
    return getAvailableAchievements();
  }

  /// Get user badges
  Future<List<Badge>> getUserBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final badgesJson = prefs.getString(_badgesKey);
    
    if (badgesJson != null) {
      try {
        final badgesList = json.decode(badgesJson) as List;
        return badgesList.map((item) => Badge.fromJson(item)).toList();
      } catch (e) {
        return getAvailableBadges();
      }
    }
    
    return getAvailableBadges();
  }

  /// Get profile completion progress
  Future<ProfileCompletionProgress> getProfileCompletionProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    
    if (progressJson != null) {
      try {
        final progressMap = json.decode(progressJson);
        return ProfileCompletionProgress.fromJson(progressMap);
      } catch (e) {
        return _calculateDefaultProgress();
      }
    }
    
    return _calculateDefaultProgress();
  }

  /// Update profile completion progress
  Future<void> updateProfileProgress(Map<String, dynamic> profileData) async {
    final progress = await _calculateProgress(profileData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, json.encode(progress.toJson()));
    
    // Check for achievements
    await _checkAchievements(profileData);
    
    // Check for badges
    await _checkBadges(profileData);
  }

  /// Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    final achievements = await getUserAchievements();
    final achievementIndex = achievements.indexWhere((a) => a.id == achievementId);
    
    if (achievementIndex != -1 && !achievements[achievementIndex].isUnlocked) {
      achievements[achievementIndex] = achievements[achievementIndex].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_achievementsKey, json.encode(achievements.map((a) => a.toJson()).toList()));
      
      // Add experience points
      await _addExperience(achievements[achievementIndex].points);
    }
  }

  /// Earn badge
  Future<void> earnBadge(String badgeId) async {
    final badges = await getUserBadges();
    final badgeIndex = badges.indexWhere((b) => b.id == badgeId);
    
    if (badgeIndex != -1 && !badges[badgeIndex].isEarned) {
      badges[badgeIndex] = badges[badgeIndex].copyWith(
        isEarned: true,
        earnedAt: DateTime.now(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_badgesKey, json.encode(badges.map((b) => b.toJson()).toList()));
    }
  }

  /// Get user level and experience
  Future<Map<String, int>> getUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final level = prefs.getInt(_levelKey) ?? 1;
    final experience = prefs.getInt(_experienceKey) ?? 0;
    
    return {
      'level': level,
      'experience': experience,
      'nextLevelExperience': _getNextLevelExperience(level),
    };
  }

  /// Add experience points
  Future<void> _addExperience(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentExperience = prefs.getInt(_experienceKey) ?? 0;
    final currentLevel = prefs.getInt(_levelKey) ?? 1;
    
    final newExperience = currentExperience + points;
    final newLevel = _calculateLevel(newExperience);
    
    await prefs.setInt(_experienceKey, newExperience);
    await prefs.setInt(_levelKey, newLevel);
    
    // Check for level up
    if (newLevel > currentLevel) {
      await _onLevelUp(newLevel);
    }
  }

  /// Get gamification statistics
  Future<Map<String, dynamic>> getGamificationStats() async {
    final achievements = await getUserAchievements();
    final badges = await getUserBadges();
    final progress = await getProfileCompletionProgress();
    final levelData = await getUserLevel();
    
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).length;
    final earnedBadges = badges.where((b) => b.isEarned).length;
    
    return {
      'totalAchievements': achievements.length,
      'unlockedAchievements': unlockedAchievements,
      'achievementProgress': unlockedAchievements / achievements.length,
      'totalBadges': badges.length,
      'earnedBadges': earnedBadges,
      'badgeProgress': earnedBadges / badges.length,
      'profileCompletion': progress.completionPercentage,
      'level': levelData['level'],
      'experience': levelData['experience'],
      'nextLevelExperience': levelData['nextLevelExperience'],
      'totalPoints': progress.totalPoints,
      'earnedPoints': progress.earnedPoints,
    };
  }

  /// Private helper methods
  ProfileCompletionProgress _calculateDefaultProgress() {
    return const ProfileCompletionProgress(
      totalSteps: 10,
      completedSteps: 0,
      completionPercentage: 0.0,
      completedSections: [],
      remainingSections: ['photos', 'bio', 'interests', 'location', 'age', 'gender', 'preferences', 'verification', 'social_links', 'premium'],
      totalPoints: 1000,
      earnedPoints: 0,
      level: 1,
      experiencePoints: 0,
      nextLevelExperience: 100,
    );
  }

  Future<ProfileCompletionProgress> _calculateProgress(Map<String, dynamic> profileData) async {
    final sections = ['photos', 'bio', 'interests', 'location', 'age', 'gender', 'preferences', 'verification', 'social_links', 'premium'];
    final completedSections = <String>[];
    final remainingSections = <String>[];
    
    int earnedPoints = 0;
    
    // Check each section
    for (final section in sections) {
      bool isCompleted = false;
      
      switch (section) {
        case 'photos':
          isCompleted = (profileData['photos'] as List?)?.isNotEmpty ?? false;
          if (isCompleted) earnedPoints += 50;
          break;
        case 'bio':
          isCompleted = (profileData['bio'] as String?)?.isNotEmpty ?? false;
          if (isCompleted) earnedPoints += 75;
          break;
        case 'interests':
          isCompleted = (profileData['interests'] as List?)?.isNotEmpty ?? false;
          if (isCompleted) earnedPoints += 80;
          break;
        case 'location':
          isCompleted = (profileData['location'] as String?)?.isNotEmpty ?? false;
          if (isCompleted) earnedPoints += 60;
          break;
        case 'age':
          isCompleted = profileData['age'] != null;
          if (isCompleted) earnedPoints += 40;
          break;
        case 'gender':
          isCompleted = (profileData['gender'] as String?)?.isNotEmpty ?? false;
          if (isCompleted) earnedPoints += 40;
          break;
        case 'preferences':
          isCompleted = profileData['preferences'] != null;
          if (isCompleted) earnedPoints += 70;
          break;
        case 'verification':
          isCompleted = profileData['isVerified'] == true;
          if (isCompleted) earnedPoints += 100;
          break;
        case 'social_links':
          isCompleted = (profileData['socialLinks'] as List?)?.isNotEmpty ?? false;
          if (isCompleted) earnedPoints += 50;
          break;
        case 'premium':
          isCompleted = profileData['isPremium'] == true;
          if (isCompleted) earnedPoints += 200;
          break;
      }
      
      if (isCompleted) {
        completedSections.add(section);
      } else {
        remainingSections.add(section);
      }
    }
    
    final completionPercentage = (completedSections.length / sections.length) * 100;
    final levelData = await getUserLevel();
    
    return ProfileCompletionProgress(
      totalSteps: sections.length,
      completedSteps: completedSections.length,
      completionPercentage: completionPercentage,
      completedSections: completedSections,
      remainingSections: remainingSections,
      totalPoints: 1000,
      earnedPoints: earnedPoints,
      level: levelData['level']!,
      experiencePoints: levelData['experience']!,
      nextLevelExperience: levelData['nextLevelExperience']!,
    );
  }

  Future<void> _checkAchievements(Map<String, dynamic> profileData) async {
    final achievements = await getUserAchievements();
    
    for (final achievement in achievements) {
      if (!achievement.isUnlocked && _isAchievementUnlocked(achievement, profileData)) {
        await unlockAchievement(achievement.id);
      }
    }
  }

  Future<void> _checkBadges(Map<String, dynamic> profileData) async {
    final badges = await getUserBadges();
    
    for (final badge in badges) {
      if (!badge.isEarned && _isBadgeEarned(badge, profileData)) {
        await earnBadge(badge.id);
      }
    }
  }

  bool _isAchievementUnlocked(Achievement achievement, Map<String, dynamic> profileData) {
    final requirements = achievement.requirements;
    
    for (final key in requirements.keys) {
      final requiredValue = requirements[key];
      final actualValue = profileData[key];
      
      if (actualValue == null) return false;
      
      if (actualValue is int && actualValue < requiredValue) return false;
      if (actualValue is String && actualValue.length < requiredValue) return false;
      if (actualValue is List && actualValue.length < requiredValue) return false;
    }
    
    return true;
  }

  bool _isBadgeEarned(Badge badge, Map<String, dynamic> profileData) {
    final criteria = badge.criteria;
    
    for (final key in criteria.keys) {
      final requiredValue = criteria[key];
      final actualValue = profileData[key];
      
      if (actualValue == null) return false;
      
      if (actualValue != requiredValue) return false;
    }
    
    return true;
  }

  int _calculateLevel(int experience) {
    // Level formula: level = sqrt(experience / 100) + 1
    return (experience / 100).sqrt().floor() + 1;
  }

  int _getNextLevelExperience(int currentLevel) {
    // Next level experience = (level^2) * 100
    return (currentLevel * currentLevel) * 100;
  }

  Future<void> _onLevelUp(int newLevel) async {
    // Handle level up rewards
    // This could trigger notifications, unlock new features, etc.
  }
}
