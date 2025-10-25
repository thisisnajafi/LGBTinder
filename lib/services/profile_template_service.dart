import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum TemplateCategory {
  minimalist,
  creative,
  professional,
  casual,
  artistic,
  adventurous,
  romantic,
  quirky,
  elegant,
  modern,
}

enum TemplateStyle {
  clean,
  colorful,
  gradient,
  dark,
  light,
  vibrant,
  subtle,
  bold,
  classic,
  contemporary,
  elegant,
  modern,
}

enum TemplateLayout {
  singleColumn,
  twoColumn,
  grid,
  card,
  timeline,
  magazine,
  portfolio,
  gallery,
  list,
  mixed,
}

class ProfileTemplate {
  final String id;
  final String name;
  final String description;
  final TemplateCategory category;
  final TemplateStyle style;
  final TemplateLayout layout;
  final String previewImage;
  final List<String> features;
  final Map<String, dynamic> configuration;
  final bool isPremium;
  final bool isPopular;
  final double rating;
  final int usageCount;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final Map<String, dynamic> metadata;

  const ProfileTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.style,
    required this.layout,
    required this.previewImage,
    required this.features,
    required this.configuration,
    this.isPremium = false,
    this.isPopular = false,
    this.rating = 0.0,
    this.usageCount = 0,
    required this.createdAt,
    this.lastUpdated,
    this.metadata = const {},
  });

  ProfileTemplate copyWith({
    String? id,
    String? name,
    String? description,
    TemplateCategory? category,
    TemplateStyle? style,
    TemplateLayout? layout,
    String? previewImage,
    List<String>? features,
    Map<String, dynamic>? configuration,
    bool? isPremium,
    bool? isPopular,
    double? rating,
    int? usageCount,
    DateTime? createdAt,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return ProfileTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      style: style ?? this.style,
      layout: layout ?? this.layout,
      previewImage: previewImage ?? this.previewImage,
      features: features ?? this.features,
      configuration: configuration ?? this.configuration,
      isPremium: isPremium ?? this.isPremium,
      isPopular: isPopular ?? this.isPopular,
      rating: rating ?? this.rating,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'style': style.name,
      'layout': layout.name,
      'previewImage': previewImage,
      'features': features,
      'configuration': configuration,
      'isPremium': isPremium,
      'isPopular': isPopular,
      'rating': rating,
      'usageCount': usageCount,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ProfileTemplate.fromJson(Map<String, dynamic> json) {
    return ProfileTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: TemplateCategory.values.firstWhere((e) => e.name == json['category']),
      style: TemplateStyle.values.firstWhere((e) => e.name == json['style']),
      layout: TemplateLayout.values.firstWhere((e) => e.name == json['layout']),
      previewImage: json['previewImage'],
      features: List<String>.from(json['features']),
      configuration: Map<String, dynamic>.from(json['configuration']),
      isPremium: json['isPremium'] ?? false,
      isPopular: json['isPopular'] ?? false,
      rating: json['rating']?.toDouble() ?? 0.0,
      usageCount: json['usageCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class TemplateUsage {
  final String id;
  final String templateId;
  final String userId;
  final DateTime usedAt;
  final bool isActive;
  final Map<String, dynamic> customizations;
  final Map<String, dynamic> metadata;

  const TemplateUsage({
    required this.id,
    required this.templateId,
    required this.userId,
    required this.usedAt,
    this.isActive = true,
    this.customizations = const {},
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'userId': userId,
      'usedAt': usedAt.toIso8601String(),
      'isActive': isActive,
      'customizations': customizations,
      'metadata': metadata,
    };
  }

  factory TemplateUsage.fromJson(Map<String, dynamic> json) {
    return TemplateUsage(
      id: json['id'],
      templateId: json['templateId'],
      userId: json['userId'],
      usedAt: DateTime.parse(json['usedAt']),
      isActive: json['isActive'] ?? true,
      customizations: Map<String, dynamic>.from(json['customizations'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class ProfileTemplateService {
  static const String _templatesKey = 'profile_templates';
  static const String _usageKey = 'template_usage';
  static const String _favoritesKey = 'template_favorites';
  
  static ProfileTemplateService? _instance;
  static ProfileTemplateService get instance {
    _instance ??= ProfileTemplateService._();
    return _instance!;
  }

  ProfileTemplateService._();

  /// Get all available templates
  List<ProfileTemplate> getAllTemplates() {
    return _getDefaultTemplates();
  }

  /// Get templates by category
  List<ProfileTemplate> getTemplatesByCategory(TemplateCategory category) {
    return getAllTemplates().where((template) => template.category == category).toList();
  }

  /// Get templates by style
  List<ProfileTemplate> getTemplatesByStyle(TemplateStyle style) {
    return getAllTemplates().where((template) => template.style == style).toList();
  }

  /// Get templates by layout
  List<ProfileTemplate> getTemplatesByLayout(TemplateLayout layout) {
    return getAllTemplates().where((template) => template.layout == layout).toList();
  }

  /// Get popular templates
  List<ProfileTemplate> getPopularTemplates() {
    return getAllTemplates().where((template) => template.isPopular).toList();
  }

  /// Get premium templates
  List<ProfileTemplate> getPremiumTemplates() {
    return getAllTemplates().where((template) => template.isPremium).toList();
  }

  /// Get free templates
  List<ProfileTemplate> getFreeTemplates() {
    return getAllTemplates().where((template) => !template.isPremium).toList();
  }

  /// Get template by ID
  ProfileTemplate? getTemplateById(String id) {
    try {
      return getAllTemplates().firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search templates
  List<ProfileTemplate> searchTemplates(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllTemplates().where((template) {
      return template.name.toLowerCase().contains(lowercaseQuery) ||
             template.description.toLowerCase().contains(lowercaseQuery) ||
             template.features.any((feature) => feature.toLowerCase().contains(lowercaseQuery)) ||
             template.category.name.toLowerCase().contains(lowercaseQuery) ||
             template.style.name.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Apply template to profile
  Future<bool> applyTemplate({
    required String templateId,
    required String userId,
    Map<String, dynamic>? customizations,
  }) async {
    try {
      final template = getTemplateById(templateId);
      if (template == null) return false;

      final usage = TemplateUsage(
        id: _generateUsageId(),
        templateId: templateId,
        userId: userId,
        usedAt: DateTime.now(),
        customizations: customizations ?? {},
      );

      await _saveTemplateUsage(usage);
      await _incrementTemplateUsageCount(templateId);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's template usage history
  Future<List<TemplateUsage>> getUserTemplateUsage(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final usageJson = prefs.getString(_usageKey);
    
    if (usageJson != null) {
      try {
        final usageList = json.decode(usageJson) as List;
        return usageList
            .map((item) => TemplateUsage.fromJson(item))
            .where((usage) => usage.userId == userId)
            .toList();
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  /// Get user's current template
  Future<ProfileTemplate?> getUserCurrentTemplate(String userId) async {
    final usageHistory = await getUserTemplateUsage(userId);
    final activeUsage = usageHistory.where((usage) => usage.isActive).toList();
    
    if (activeUsage.isNotEmpty) {
      return getTemplateById(activeUsage.first.templateId);
    }
    
    return null;
  }

  /// Add template to favorites
  Future<void> addToFavorites(String templateId, String userId) async {
    final favorites = await getUserFavorites(userId);
    if (!favorites.contains(templateId)) {
      favorites.add(templateId);
      await _saveUserFavorites(userId, favorites);
    }
  }

  /// Remove template from favorites
  Future<void> removeFromFavorites(String templateId, String userId) async {
    final favorites = await getUserFavorites(userId);
    favorites.remove(templateId);
    await _saveUserFavorites(userId, favorites);
  }

  /// Get user's favorite templates
  Future<List<String>> getUserFavorites(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('${_favoritesKey}_$userId');
    
    if (favoritesJson != null) {
      try {
        return List<String>.from(json.decode(favoritesJson));
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  /// Get favorite templates
  Future<List<ProfileTemplate>> getFavoriteTemplates(String userId) async {
    final favoriteIds = await getUserFavorites(userId);
    return favoriteIds
        .map((id) => getTemplateById(id))
        .where((template) => template != null)
        .cast<ProfileTemplate>()
        .toList();
  }

  /// Rate template
  Future<void> rateTemplate(String templateId, double rating) async {
    // In a real app, this would update the template rating
    // For now, we'll just simulate it
  }

  /// Get template statistics
  Future<Map<String, dynamic>> getTemplateStatistics() async {
    final templates = getAllTemplates();
    final totalTemplates = templates.length;
    final premiumTemplates = templates.where((t) => t.isPremium).length;
    final freeTemplates = templates.where((t) => !t.isPremium).length;
    final popularTemplates = templates.where((t) => t.isPopular).length;
    
    final categoryCounts = <TemplateCategory, int>{};
    final styleCounts = <TemplateStyle, int>{};
    final layoutCounts = <TemplateLayout, int>{};
    
    for (final template in templates) {
      categoryCounts[template.category] = (categoryCounts[template.category] ?? 0) + 1;
      styleCounts[template.style] = (styleCounts[template.style] ?? 0) + 1;
      layoutCounts[template.layout] = (layoutCounts[template.layout] ?? 0) + 1;
    }
    
    return {
      'totalTemplates': totalTemplates,
      'premiumTemplates': premiumTemplates,
      'freeTemplates': freeTemplates,
      'popularTemplates': popularTemplates,
      'categoryCounts': categoryCounts.map((k, v) => MapEntry(k.name, v)),
      'styleCounts': styleCounts.map((k, v) => MapEntry(k.name, v)),
      'layoutCounts': layoutCounts.map((k, v) => MapEntry(k.name, v)),
    };
  }

  /// Get available categories
  List<Map<String, dynamic>> getAvailableCategories() {
    return [
      {
        'category': TemplateCategory.minimalist,
        'name': 'Minimalist',
        'icon': 'minimize',
        'color': 0xFF6366F1,
        'description': 'Clean and simple designs',
      },
      {
        'category': TemplateCategory.creative,
        'name': 'Creative',
        'icon': 'palette',
        'color': 0xFF8B5CF6,
        'description': 'Artistic and unique layouts',
      },
      {
        'category': TemplateCategory.professional,
        'name': 'Professional',
        'icon': 'business',
        'color': 0xFF3B82F6,
        'description': 'Business-focused designs',
      },
      {
        'category': TemplateCategory.casual,
        'name': 'Casual',
        'icon': 'casual',
        'color': 0xFF10B981,
        'description': 'Relaxed and friendly styles',
      },
      {
        'category': TemplateCategory.artistic,
        'name': 'Artistic',
        'icon': 'brush',
        'color': 0xFFF59E0B,
        'description': 'Creative and expressive designs',
      },
      {
        'category': TemplateCategory.adventurous,
        'name': 'Adventurous',
        'icon': 'hiking',
        'color': 0xFFEF4444,
        'description': 'Bold and exciting layouts',
      },
      {
        'category': TemplateCategory.romantic,
        'name': 'Romantic',
        'icon': 'favorite',
        'color': 0xFFEC4899,
        'description': 'Sweet and romantic themes',
      },
      {
        'category': TemplateCategory.quirky,
        'name': 'Quirky',
        'icon': 'emoji_emotions',
        'color': 0xFF84CC16,
        'description': 'Fun and unique designs',
      },
      {
        'category': TemplateCategory.elegant,
        'name': 'Elegant',
        'icon': 'diamond',
        'color': 0xFF6B7280,
        'description': 'Sophisticated and refined',
      },
      {
        'category': TemplateCategory.modern,
        'name': 'Modern',
        'icon': 'trending_up',
        'color': 0xFF1F2937,
        'description': 'Contemporary and trendy',
      },
    ];
  }

  /// Private helper methods
  List<ProfileTemplate> _getDefaultTemplates() {
    return [
      // Minimalist Templates
      ProfileTemplate(
        id: 'minimalist_clean',
        name: 'Clean Minimalist',
        description: 'A simple, clean design with focus on content',
        category: TemplateCategory.minimalist,
        style: TemplateStyle.clean,
        layout: TemplateLayout.singleColumn,
        previewImage: 'assets/templates/minimalist_clean.png',
        features: ['Clean typography', 'Minimal colors', 'Focus on content'],
        configuration: {
          'backgroundColor': '#FFFFFF',
          'textColor': '#000000',
          'accentColor': '#6366F1',
          'fontFamily': 'Inter',
          'spacing': 'comfortable',
        },
        isPopular: true,
        rating: 4.8,
        usageCount: 1250,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      
      ProfileTemplate(
        id: 'minimalist_dark',
        name: 'Dark Minimalist',
        description: 'Minimalist design with dark theme',
        category: TemplateCategory.minimalist,
        style: TemplateStyle.dark,
        layout: TemplateLayout.singleColumn,
        previewImage: 'assets/templates/minimalist_dark.png',
        features: ['Dark theme', 'Minimal design', 'Easy to read'],
        configuration: {
          'backgroundColor': '#1F2937',
          'textColor': '#FFFFFF',
          'accentColor': '#6366F1',
          'fontFamily': 'Inter',
          'spacing': 'comfortable',
        },
        isPremium: true,
        rating: 4.6,
        usageCount: 890,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),

      // Creative Templates
      ProfileTemplate(
        id: 'creative_colorful',
        name: 'Colorful Creative',
        description: 'Vibrant and creative design with bold colors',
        category: TemplateCategory.creative,
        style: TemplateStyle.colorful,
        layout: TemplateLayout.grid,
        previewImage: 'assets/templates/creative_colorful.png',
        features: ['Bold colors', 'Creative layout', 'Eye-catching design'],
        configuration: {
          'backgroundColor': '#F8FAFC',
          'textColor': '#1E293B',
          'accentColor': '#8B5CF6',
          'fontFamily': 'Poppins',
          'spacing': 'creative',
        },
        isPopular: true,
        rating: 4.7,
        usageCount: 980,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),

      ProfileTemplate(
        id: 'creative_gradient',
        name: 'Gradient Creative',
        description: 'Creative design with beautiful gradients',
        category: TemplateCategory.creative,
        style: TemplateStyle.gradient,
        layout: TemplateLayout.card,
        previewImage: 'assets/templates/creative_gradient.png',
        features: ['Gradient backgrounds', 'Modern design', 'Visual appeal'],
        configuration: {
          'backgroundColor': 'gradient',
          'textColor': '#FFFFFF',
          'accentColor': '#8B5CF6',
          'fontFamily': 'Poppins',
          'spacing': 'modern',
        },
        isPremium: true,
        rating: 4.9,
        usageCount: 750,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),

      // Professional Templates
      ProfileTemplate(
        id: 'professional_business',
        name: 'Business Professional',
        description: 'Professional design for business profiles',
        category: TemplateCategory.professional,
        style: TemplateStyle.clean,
        layout: TemplateLayout.twoColumn,
        previewImage: 'assets/templates/professional_business.png',
        features: ['Professional look', 'Business focused', 'Clean layout'],
        configuration: {
          'backgroundColor': '#FFFFFF',
          'textColor': '#1E293B',
          'accentColor': '#3B82F6',
          'fontFamily': 'Inter',
          'spacing': 'professional',
        },
        isPopular: true,
        rating: 4.5,
        usageCount: 1100,
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
      ),

      ProfileTemplate(
        id: 'professional_corporate',
        name: 'Corporate Professional',
        description: 'Corporate-style professional template',
        category: TemplateCategory.professional,
        style: TemplateStyle.classic,
        layout: TemplateLayout.singleColumn,
        previewImage: 'assets/templates/professional_corporate.png',
        features: ['Corporate style', 'Formal design', 'Professional image'],
        configuration: {
          'backgroundColor': '#F8FAFC',
          'textColor': '#1E293B',
          'accentColor': '#3B82F6',
          'fontFamily': 'Inter',
          'spacing': 'formal',
        },
        isPremium: true,
        rating: 4.4,
        usageCount: 650,
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
      ),

      // Casual Templates
      ProfileTemplate(
        id: 'casual_friendly',
        name: 'Friendly Casual',
        description: 'Casual and friendly design',
        category: TemplateCategory.casual,
        style: TemplateStyle.light,
        layout: TemplateLayout.card,
        previewImage: 'assets/templates/casual_friendly.png',
        features: ['Friendly design', 'Casual style', 'Approachable look'],
        configuration: {
          'backgroundColor': '#F0F9FF',
          'textColor': '#1E293B',
          'accentColor': '#10B981',
          'fontFamily': 'Nunito',
          'spacing': 'relaxed',
        },
        isPopular: true,
        rating: 4.6,
        usageCount: 1200,
        createdAt: DateTime.now().subtract(const Duration(days: 22)),
      ),

      ProfileTemplate(
        id: 'casual_relaxed',
        name: 'Relaxed Casual',
        description: 'Relaxed and comfortable design',
        category: TemplateCategory.casual,
        style: TemplateStyle.subtle,
        layout: TemplateLayout.timeline,
        previewImage: 'assets/templates/casual_relaxed.png',
        features: ['Relaxed design', 'Comfortable feel', 'Easy going'],
        configuration: {
          'backgroundColor': '#FEFEFE',
          'textColor': '#374151',
          'accentColor': '#10B981',
          'fontFamily': 'Nunito',
          'spacing': 'comfortable',
        },
        rating: 4.3,
        usageCount: 800,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
      ),

      // Artistic Templates
      ProfileTemplate(
        id: 'artistic_creative',
        name: 'Artistic Creative',
        description: 'Artistic and creative design',
        category: TemplateCategory.artistic,
        style: TemplateStyle.vibrant,
        layout: TemplateLayout.portfolio,
        previewImage: 'assets/templates/artistic_creative.png',
        features: ['Artistic design', 'Creative layout', 'Visual impact'],
        configuration: {
          'backgroundColor': '#FEF3C7',
          'textColor': '#1F2937',
          'accentColor': '#F59E0B',
          'fontFamily': 'Urbanist',
          'spacing': 'artistic',
        },
        isPremium: true,
        rating: 4.8,
        usageCount: 920,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),

      ProfileTemplate(
        id: 'artistic_modern',
        name: 'Modern Artistic',
        description: 'Modern artistic design',
        category: TemplateCategory.artistic,
        style: TemplateStyle.contemporary,
        layout: TemplateLayout.gallery,
        previewImage: 'assets/templates/artistic_modern.png',
        features: ['Modern art style', 'Contemporary design', 'Creative flair'],
        configuration: {
          'backgroundColor': '#F3F4F6',
          'textColor': '#1F2937',
          'accentColor': '#F59E0B',
          'fontFamily': 'Urbanist',
          'spacing': 'modern',
        },
        rating: 4.7,
        usageCount: 780,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),

      // Adventurous Templates
      ProfileTemplate(
        id: 'adventurous_bold',
        name: 'Bold Adventurous',
        description: 'Bold and adventurous design',
        category: TemplateCategory.adventurous,
        style: TemplateStyle.bold,
        layout: TemplateLayout.mixed,
        previewImage: 'assets/templates/adventurous_bold.png',
        features: ['Bold design', 'Adventurous spirit', 'Eye-catching'],
        configuration: {
          'backgroundColor': '#FEF2F2',
          'textColor': '#1F2937',
          'accentColor': '#EF4444',
          'fontFamily': 'Poppins',
          'spacing': 'bold',
        },
        isPopular: true,
        rating: 4.9,
        usageCount: 1050,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),

      ProfileTemplate(
        id: 'adventurous_dynamic',
        name: 'Dynamic Adventurous',
        description: 'Dynamic and energetic design',
        category: TemplateCategory.adventurous,
        style: TemplateStyle.vibrant,
        layout: TemplateLayout.grid,
        previewImage: 'assets/templates/adventurous_dynamic.png',
        features: ['Dynamic layout', 'Energetic design', 'Adventure theme'],
        configuration: {
          'backgroundColor': '#F0FDF4',
          'textColor': '#1F2937',
          'accentColor': '#EF4444',
          'fontFamily': 'Poppins',
          'spacing': 'dynamic',
        },
        isPremium: true,
        rating: 4.6,
        usageCount: 680,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),

      // Romantic Templates
      ProfileTemplate(
        id: 'romantic_sweet',
        name: 'Sweet Romantic',
        description: 'Sweet and romantic design',
        category: TemplateCategory.romantic,
        style: TemplateStyle.subtle,
        layout: TemplateLayout.card,
        previewImage: 'assets/templates/romantic_sweet.png',
        features: ['Sweet design', 'Romantic theme', 'Soft colors'],
        configuration: {
          'backgroundColor': '#FDF2F8',
          'textColor': '#1F2937',
          'accentColor': '#EC4899',
          'fontFamily': 'Nunito',
          'spacing': 'romantic',
        },
        isPopular: true,
        rating: 4.7,
        usageCount: 1150,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),

      ProfileTemplate(
        id: 'romantic_elegant',
        name: 'Elegant Romantic',
        description: 'Elegant romantic design',
        category: TemplateCategory.romantic,
        style: TemplateStyle.elegant,
        layout: TemplateLayout.singleColumn,
        previewImage: 'assets/templates/romantic_elegant.png',
        features: ['Elegant design', 'Romantic feel', 'Sophisticated'],
        configuration: {
          'backgroundColor': '#FFFFFF',
          'textColor': '#1F2937',
          'accentColor': '#EC4899',
          'fontFamily': 'Inter',
          'spacing': 'elegant',
        },
        isPremium: true,
        rating: 4.8,
        usageCount: 850,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),

      // Quirky Templates
      ProfileTemplate(
        id: 'quirky_fun',
        name: 'Fun Quirky',
        description: 'Fun and quirky design',
        category: TemplateCategory.quirky,
        style: TemplateStyle.colorful,
        layout: TemplateLayout.mixed,
        previewImage: 'assets/templates/quirky_fun.png',
        features: ['Fun design', 'Quirky style', 'Playful elements'],
        configuration: {
          'backgroundColor': '#F0FDF4',
          'textColor': '#1F2937',
          'accentColor': '#84CC16',
          'fontFamily': 'Poppins',
          'spacing': 'playful',
        },
        rating: 4.5,
        usageCount: 950,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),

      ProfileTemplate(
        id: 'quirky_unique',
        name: 'Unique Quirky',
        description: 'Unique and quirky design',
        category: TemplateCategory.quirky,
        style: TemplateStyle.bold,
        layout: TemplateLayout.portfolio,
        previewImage: 'assets/templates/quirky_unique.png',
        features: ['Unique design', 'Quirky elements', 'Stand out'],
        configuration: {
          'backgroundColor': '#FEF3C7',
          'textColor': '#1F2937',
          'accentColor': '#84CC16',
          'fontFamily': 'Poppins',
          'spacing': 'unique',
        },
        isPremium: true,
        rating: 4.6,
        usageCount: 720,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),

      // Elegant Templates
      ProfileTemplate(
        id: 'elegant_sophisticated',
        name: 'Sophisticated Elegant',
        description: 'Sophisticated and elegant design',
        category: TemplateCategory.elegant,
        style: TemplateStyle.elegant,
        layout: TemplateLayout.singleColumn,
        previewImage: 'assets/templates/elegant_sophisticated.png',
        features: ['Sophisticated design', 'Elegant style', 'Refined look'],
        configuration: {
          'backgroundColor': '#F9FAFB',
          'textColor': '#1F2937',
          'accentColor': '#6B7280',
          'fontFamily': 'Inter',
          'spacing': 'refined',
        },
        isPopular: true,
        rating: 4.8,
        usageCount: 980,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),

      ProfileTemplate(
        id: 'elegant_luxury',
        name: 'Luxury Elegant',
        description: 'Luxury elegant design',
        category: TemplateCategory.elegant,
        style: TemplateStyle.classic,
        layout: TemplateLayout.twoColumn,
        previewImage: 'assets/templates/elegant_luxury.png',
        features: ['Luxury design', 'Elegant feel', 'Premium look'],
        configuration: {
          'backgroundColor': '#FFFFFF',
          'textColor': '#1F2937',
          'accentColor': '#6B7280',
          'fontFamily': 'Inter',
          'spacing': 'luxury',
        },
        isPremium: true,
        rating: 4.9,
        usageCount: 650,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),

      // Modern Templates
      ProfileTemplate(
        id: 'modern_contemporary',
        name: 'Contemporary Modern',
        description: 'Contemporary modern design',
        category: TemplateCategory.modern,
        style: TemplateStyle.contemporary,
        layout: TemplateLayout.grid,
        previewImage: 'assets/templates/modern_contemporary.png',
        features: ['Contemporary design', 'Modern style', 'Trendy look'],
        configuration: {
          'backgroundColor': '#F8FAFC',
          'textColor': '#1F2937',
          'accentColor': '#1F2937',
          'fontFamily': 'Inter',
          'spacing': 'modern',
        },
        isPopular: true,
        rating: 4.7,
        usageCount: 1100,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),

      ProfileTemplate(
        id: 'modern_trendy',
        name: 'Trendy Modern',
        description: 'Trendy modern design',
        category: TemplateCategory.modern,
        style: TemplateStyle.modern,
        layout: TemplateLayout.card,
        previewImage: 'assets/templates/modern_trendy.png',
        features: ['Trendy design', 'Modern feel', 'Current style'],
        configuration: {
          'backgroundColor': '#F1F5F9',
          'textColor': '#1F2937',
          'accentColor': '#1F2937',
          'fontFamily': 'Inter',
          'spacing': 'trendy',
        },
        isPremium: true,
        rating: 4.6,
        usageCount: 780,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  String _generateUsageId() {
    return 'usage_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  Future<void> _saveTemplateUsage(TemplateUsage usage) async {
    final prefs = await SharedPreferences.getInstance();
    final usageJson = prefs.getString(_usageKey);
    
    List<TemplateUsage> usageList = [];
    if (usageJson != null) {
      try {
        final usageData = json.decode(usageJson) as List;
        usageList = usageData.map((item) => TemplateUsage.fromJson(item)).toList();
      } catch (e) {
        usageList = [];
      }
    }
    
    usageList.add(usage);
    
    // Keep only last 1000 usages to prevent storage bloat
    if (usageList.length > 1000) {
      usageList = usageList.skip(usageList.length - 1000).toList();
    }
    
    await prefs.setString(
      _usageKey,
      json.encode(usageList.map((u) => u.toJson()).toList()),
    );
  }

  Future<void> _incrementTemplateUsageCount(String templateId) async {
    // In a real app, this would increment the usage count
    // For now, we'll just simulate it
  }

  Future<void> _saveUserFavorites(String userId, List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_favoritesKey}_$userId', json.encode(favorites));
  }
}
