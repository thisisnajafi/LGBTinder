import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCustomizationSettings {
  final String profileTheme;
  final String profileLayout;
  final List<String> enabledSections;
  final String profileVisibility;
  final List<String> profileHighlights;
  final bool enableAnimations;
  final bool enableParallaxEffects;
  final List<String> enabledWidgets;
  final Map<String, bool> socialIntegrations;
  final Map<String, dynamic> customSettings;

  const ProfileCustomizationSettings({
    this.profileTheme = 'default',
    this.profileLayout = 'grid',
    this.enabledSections = const ['about', 'interests', 'photos'],
    this.profileVisibility = 'public',
    this.profileHighlights = const [],
    this.enableAnimations = true,
    this.enableParallaxEffects = false,
    this.enabledWidgets = const [],
    this.socialIntegrations = const {},
    this.customSettings = const {},
  });

  ProfileCustomizationSettings copyWith({
    String? profileTheme,
    String? profileLayout,
    List<String>? enabledSections,
    String? profileVisibility,
    List<String>? profileHighlights,
    bool? enableAnimations,
    bool? enableParallaxEffects,
    List<String>? enabledWidgets,
    Map<String, bool>? socialIntegrations,
    Map<String, dynamic>? customSettings,
  }) {
    return ProfileCustomizationSettings(
      profileTheme: profileTheme ?? this.profileTheme,
      profileLayout: profileLayout ?? this.profileLayout,
      enabledSections: enabledSections ?? this.enabledSections,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      profileHighlights: profileHighlights ?? this.profileHighlights,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableParallaxEffects: enableParallaxEffects ?? this.enableParallaxEffects,
      enabledWidgets: enabledWidgets ?? this.enabledWidgets,
      socialIntegrations: socialIntegrations ?? this.socialIntegrations,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileTheme': profileTheme,
      'profileLayout': profileLayout,
      'enabledSections': enabledSections,
      'profileVisibility': profileVisibility,
      'profileHighlights': profileHighlights,
      'enableAnimations': enableAnimations,
      'enableParallaxEffects': enableParallaxEffects,
      'enabledWidgets': enabledWidgets,
      'socialIntegrations': socialIntegrations,
      'customSettings': customSettings,
    };
  }

  factory ProfileCustomizationSettings.fromJson(Map<String, dynamic> json) {
    return ProfileCustomizationSettings(
      profileTheme: json['profileTheme'] ?? 'default',
      profileLayout: json['profileLayout'] ?? 'grid',
      enabledSections: List<String>.from(json['enabledSections'] ?? ['about', 'interests', 'photos']),
      profileVisibility: json['profileVisibility'] ?? 'public',
      profileHighlights: List<String>.from(json['profileHighlights'] ?? []),
      enableAnimations: json['enableAnimations'] ?? true,
      enableParallaxEffects: json['enableParallaxEffects'] ?? false,
      enabledWidgets: List<String>.from(json['enabledWidgets'] ?? []),
      socialIntegrations: Map<String, bool>.from(json['socialIntegrations'] ?? {}),
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
    );
  }
}

class ProfileCustomizationService {
  static const String _settingsKey = 'profile_customization_settings';
  static const String _customizationHistoryKey = 'profile_customization_history';
  
  static ProfileCustomizationService? _instance;
  static ProfileCustomizationService get instance {
    _instance ??= ProfileCustomizationService._();
    return _instance!;
  }

  ProfileCustomizationService._();

  /// Get current customization settings
  Future<ProfileCustomizationSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      try {
        final settingsMap = json.decode(settingsJson);
        return ProfileCustomizationSettings.fromJson(settingsMap);
      } catch (e) {
        return const ProfileCustomizationSettings();
      }
    }
    
    return const ProfileCustomizationSettings();
  }

  /// Save customization settings
  Future<void> saveSettings(ProfileCustomizationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings.toJson()));
    
    // Add to history
    await _addToHistory(settings);
  }

  /// Update specific setting
  Future<void> updateSetting(String key, dynamic value) async {
    final currentSettings = await getSettings();
    final updatedSettings = _updateSettingByKey(currentSettings, key, value);
    await saveSettings(updatedSettings);
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }

  /// Get customization history
  Future<List<ProfileCustomizationSettings>> getCustomizationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_customizationHistoryKey);
    
    if (historyJson != null) {
      try {
        final historyList = json.decode(historyJson) as List;
        return historyList.map((item) => ProfileCustomizationSettings.fromJson(item)).toList();
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  /// Get available themes
  List<Map<String, dynamic>> getAvailableThemes() {
    return [
      {
        'id': 'default',
        'name': 'Default',
        'primaryColor': 0xFF6C5CE7,
        'secondaryColor': 0xFFA29BFE,
        'description': 'Clean and modern default theme',
      },
      {
        'id': 'ocean',
        'name': 'Ocean',
        'primaryColor': 0xFF0984E3,
        'secondaryColor': 0xFF74B9FF,
        'description': 'Calming ocean blue theme',
      },
      {
        'id': 'sunset',
        'name': 'Sunset',
        'primaryColor': 0xFFE17055,
        'secondaryColor': 0xFFFDCB6E,
        'description': 'Warm sunset orange theme',
      },
      {
        'id': 'forest',
        'name': 'Forest',
        'primaryColor': 0xFF00B894,
        'secondaryColor': 0xFF55EFC4,
        'description': 'Natural forest green theme',
      },
      {
        'id': 'purple',
        'name': 'Purple',
        'primaryColor': 0xFF6C5CE7,
        'secondaryColor': 0xFFA29BFE,
        'description': 'Rich purple theme',
      },
      {
        'id': 'rainbow',
        'name': 'Rainbow',
        'primaryColor': 0xFFE84393,
        'secondaryColor': 0xFFFD79A8,
        'description': 'LGBT pride rainbow theme',
      },
    ];
  }

  /// Get available layouts
  List<Map<String, dynamic>> getAvailableLayouts() {
    return [
      {
        'id': 'grid',
        'name': 'Grid Layout',
        'description': 'Organized grid format',
        'icon': 'grid_view',
      },
      {
        'id': 'card',
        'name': 'Card Layout',
        'description': 'Card-based design',
        'icon': 'view_agenda',
      },
      {
        'id': 'timeline',
        'name': 'Timeline Layout',
        'description': 'Chronological view',
        'icon': 'timeline',
      },
      {
        'id': 'minimal',
        'name': 'Minimal Layout',
        'description': 'Clean and simple',
        'icon': 'view_quilt',
      },
    ];
  }

  /// Get available sections
  List<Map<String, dynamic>> getAvailableSections() {
    return [
      {
        'id': 'about',
        'name': 'About Me',
        'description': 'Personal information and bio',
        'required': true,
      },
      {
        'id': 'interests',
        'name': 'Interests',
        'description': 'Hobbies and interests',
        'required': true,
      },
      {
        'id': 'photos',
        'name': 'Photos',
        'description': 'Profile pictures and gallery',
        'required': true,
      },
      {
        'id': 'music',
        'name': 'Music',
        'description': 'Favorite music and artists',
        'required': false,
      },
      {
        'id': 'movies',
        'name': 'Movies',
        'description': 'Favorite movies and shows',
        'required': false,
      },
      {
        'id': 'books',
        'name': 'Books',
        'description': 'Favorite books and authors',
        'required': false,
      },
      {
        'id': 'travel',
        'name': 'Travel',
        'description': 'Travel experiences and destinations',
        'required': false,
      },
      {
        'id': 'sports',
        'name': 'Sports',
        'description': 'Sports and fitness activities',
        'required': false,
      },
    ];
  }

  /// Get available highlights
  List<Map<String, dynamic>> getAvailableHighlights() {
    return [
      {
        'id': 'verified',
        'name': 'Verified Badge',
        'description': 'Show verification status',
        'premium': false,
      },
      {
        'id': 'premium',
        'name': 'Premium Badge',
        'description': 'Show premium membership',
        'premium': true,
      },
      {
        'id': 'new_member',
        'name': 'New Member',
        'description': 'Highlight new members',
        'premium': false,
      },
      {
        'id': 'top_match',
        'name': 'Top Match',
        'description': 'Highlight top matches',
        'premium': true,
      },
      {
        'id': 'local_guide',
        'name': 'Local Guide',
        'description': 'Show local expertise',
        'premium': true,
      },
    ];
  }

  /// Get available widgets
  List<Map<String, dynamic>> getAvailableWidgets() {
    return [
      {
        'id': 'music_player',
        'name': 'Music Player',
        'description': 'Embedded music player',
        'premium': true,
      },
      {
        'id': 'photo_carousel',
        'name': 'Photo Carousel',
        'description': 'Interactive photo gallery',
        'premium': false,
      },
      {
        'id': 'mood_tracker',
        'name': 'Mood Tracker',
        'description': 'Track and share your mood',
        'premium': true,
      },
      {
        'id': 'activity_feed',
        'name': 'Activity Feed',
        'description': 'Recent activity updates',
        'premium': true,
      },
      {
        'id': 'location_map',
        'name': 'Location Map',
        'description': 'Show your location',
        'premium': false,
      },
    ];
  }

  /// Get available social integrations
  List<Map<String, dynamic>> getAvailableIntegrations() {
    return [
      {
        'id': 'instagram',
        'name': 'Instagram',
        'description': 'Connect Instagram account',
        'icon': 'camera_alt',
      },
      {
        'id': 'spotify',
        'name': 'Spotify',
        'description': 'Connect Spotify account',
        'icon': 'music_note',
      },
      {
        'id': 'twitter',
        'name': 'Twitter',
        'description': 'Connect Twitter account',
        'icon': 'alternate_email',
      },
      {
        'id': 'linkedin',
        'name': 'LinkedIn',
        'description': 'Connect LinkedIn account',
        'icon': 'business',
      },
      {
        'id': 'tiktok',
        'name': 'TikTok',
        'description': 'Connect TikTok account',
        'icon': 'video_library',
      },
    ];
  }

  /// Export customization settings
  Future<Map<String, dynamic>> exportSettings() async {
    final settings = await getSettings();
    final history = await getCustomizationHistory();
    
    return {
      'settings': settings.toJson(),
      'history': history.map((s) => s.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  /// Import customization settings
  Future<void> importSettings(Map<String, dynamic> data) async {
    if (data.containsKey('settings')) {
      final settings = ProfileCustomizationSettings.fromJson(data['settings']);
      await saveSettings(settings);
    }
  }

  /// Get customization statistics
  Future<Map<String, dynamic>> getCustomizationStats() async {
    final settings = await getSettings();
    final history = await getCustomizationHistory();
    
    return {
      'totalCustomizations': history.length,
      'currentTheme': settings.profileTheme,
      'currentLayout': settings.profileLayout,
      'enabledSections': settings.enabledSections.length,
      'enabledHighlights': settings.profileHighlights.length,
      'enabledWidgets': settings.enabledWidgets.length,
      'connectedIntegrations': settings.socialIntegrations.values.where((v) => v).length,
      'hasAnimations': settings.enableAnimations,
      'hasParallax': settings.enableParallaxEffects,
    };
  }

  /// Private helper methods
  ProfileCustomizationSettings _updateSettingByKey(
    ProfileCustomizationSettings settings,
    String key,
    dynamic value,
  ) {
    switch (key) {
      case 'profileTheme':
        return settings.copyWith(profileTheme: value as String);
      case 'profileLayout':
        return settings.copyWith(profileLayout: value as String);
      case 'enabledSections':
        return settings.copyWith(enabledSections: value as List<String>);
      case 'profileVisibility':
        return settings.copyWith(profileVisibility: value as String);
      case 'profileHighlights':
        return settings.copyWith(profileHighlights: value as List<String>);
      case 'enableAnimations':
        return settings.copyWith(enableAnimations: value as bool);
      case 'enableParallaxEffects':
        return settings.copyWith(enableParallaxEffects: value as bool);
      case 'enabledWidgets':
        return settings.copyWith(enabledWidgets: value as List<String>);
      case 'socialIntegrations':
        return settings.copyWith(socialIntegrations: value as Map<String, bool>);
      default:
        return settings;
    }
  }

  Future<void> _addToHistory(ProfileCustomizationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getCustomizationHistory();
    
    // Add new settings to history (limit to 50 entries)
    history.insert(0, settings);
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    await prefs.setString(
      _customizationHistoryKey,
      json.encode(history.map((s) => s.toJson()).toList()),
    );
  }
}
