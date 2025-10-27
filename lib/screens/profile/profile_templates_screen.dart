import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_template_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../../components/templates/template_components.dart';
import '../../components/buttons/animated_button.dart';

class ProfileTemplatesScreen extends StatefulWidget {
  const ProfileTemplatesScreen({Key? key}) : super(key: key);

  @override
  State<ProfileTemplatesScreen> createState() => _ProfileTemplatesScreenState();
}

class _ProfileTemplatesScreenState extends State<ProfileTemplatesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<ProfileTemplate> _allTemplates = [];
  List<ProfileTemplate> _filteredTemplates = [];
  List<Map<String, dynamic>> _categories = [];
  List<String> _favoriteTemplateIds = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String _searchQuery = '';
  TemplateCategory? _selectedCategory;
  String _userId = 'current_user'; // In a real app, this would come from user session

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadTemplateData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplateData() async {
    try {
      final templates = ProfileTemplateService.instance.getAllTemplates();
      final categories = ProfileTemplateService.instance.getAvailableCategories();
      final favorites = await ProfileTemplateService.instance.getUserFavorites(_userId);
      final statistics = await ProfileTemplateService.instance.getTemplateStatistics();
      
      if (mounted) {
        setState(() {
          _allTemplates = templates;
          _filteredTemplates = templates;
          _categories = categories;
          _favoriteTemplateIds = favorites;
          _statistics = statistics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterTemplates() {
    List<ProfileTemplate> filtered = _allTemplates;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((template) {
        return template.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               template.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               template.features.any((feature) => feature.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered.where((template) => template.category == _selectedCategory).toList();
    }

    setState(() {
      _filteredTemplates = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryLight,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () {
            HapticFeedbackService.selection();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Profile Templates',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimaryDark),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimaryDark),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryDark,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Templates'),
            Tab(text: 'Favorites'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTemplatesTab(),
                  _buildFavoritesTab(),
                  _buildStatsTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return Column(
      children: [
        // Search and Filters
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search templates...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryDark),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSecondaryDark),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            _filterTemplates();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _filterTemplates();
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryFilterCard(
                      category: {
                        'category': null,
                        'name': 'All',
                        'icon': 'all',
                        'color': 0xFF6B7280,
                      },
                      isSelected: _selectedCategory == null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                        _filterTemplates();
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryFilterCard(
                          category: category,
                          isSelected: _selectedCategory == category['category'],
                          onTap: () {
                            setState(() {
                              _selectedCategory = category['category'];
                            });
                            _filterTemplates();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Templates Grid
        Expanded(
          child: _filteredTemplates.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = _filteredTemplates[index];
                    return TemplateCard(
                      template: template,
                      isFavorite: _favoriteTemplateIds.contains(template.id),
                      onTap: () => _applyTemplate(template),
                      onFavorite: () => _toggleFavorite(template.id),
                      onPreview: () => _previewTemplate(template),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    final favoriteTemplates = _allTemplates
        .where((template) => _favoriteTemplateIds.contains(template.id))
        .toList();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color: AppColors.feedbackError,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Favorite Templates',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${favoriteTemplates.length}',
                style: AppTypography.h3.copyWith(
                  color: AppColors.feedbackError,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        // Favorites Grid
        Expanded(
          child: favoriteTemplates.isEmpty
              ? _buildEmptyFavoritesState()
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: favoriteTemplates.length,
                  itemBuilder: (context, index) {
                    final template = favoriteTemplates[index];
                    return TemplateCard(
                      template: template,
                      isFavorite: true,
                      onTap: () => _applyTemplate(template),
                      onFavorite: () => _toggleFavorite(template.id),
                      onPreview: () => _previewTemplate(template),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_statistics != null)
            TemplateStatisticsCard(
              statistics: _statistics!,
              onTap: _showDetailedStats,
            ),
          
          const SizedBox(height: 24),
          
          // Category Distribution
          _buildCategoryDistribution(),
          
          const SizedBox(height: 24),
          
          // Style Distribution
          _buildStyleDistribution(),
          
          const SizedBox(height: 24),
          
          // Layout Distribution
          _buildLayoutDistribution(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'No Templates Found',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFavoritesState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'No Favorite Templates',
              style: AppTypography.h3.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on templates to add them to your favorites',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    final categoryCounts = _statistics!['categoryCounts'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Distribution',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryCounts.entries.map((entry) {
            final category = TemplateCategory.values.firstWhere((c) => c.name == entry.key);
            final count = entry.value as int;
            final total = _statistics!['totalTemplates'] as int;
            final percentage = total > 0 ? (count / total) * 100 : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name.toUpperCase(),
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$count (${percentage.toStringAsFixed(1)}%)',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStyleDistribution() {
    final styleCounts = _statistics!['styleCounts'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Style Distribution',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...styleCounts.entries.map((entry) {
            final style = TemplateStyle.values.firstWhere((s) => s.name == entry.key);
            final count = entry.value as int;
            final total = _statistics!['totalTemplates'] as int;
            final percentage = total > 0 ? (count / total) * 100 : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      style.name.toUpperCase(),
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$count (${percentage.toStringAsFixed(1)}%)',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLayoutDistribution() {
    final layoutCounts = _statistics!['layoutCounts'] as Map<String, dynamic>;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layout Distribution',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...layoutCounts.entries.map((entry) {
            final layout = TemplateLayout.values.firstWhere((l) => l.name == entry.key);
            final count = entry.value as int;
            final total = _statistics!['totalTemplates'] as int;
            final percentage = total > 0 ? (count / total) * 100 : 0.0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      layout.name.toUpperCase(),
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '$count (${percentage.toStringAsFixed(1)}%)',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Action methods
  void _applyTemplate(ProfileTemplate template) {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Apply Template',
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Are you sure you want to apply "${template.name}" to your profile? This will change your current profile layout.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ProfileTemplateService.instance.applyTemplate(
                templateId: template.id,
                userId: _userId,
              ).then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Template "${template.name}" applied successfully!'),
                      backgroundColor: AppColors.feedbackSuccess,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to apply template'),
                      backgroundColor: AppColors.feedbackError,
                    ),
                  );
                }
              });
            },
            child: const Text(
              'Apply',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String templateId) {
    HapticFeedbackService.selection();
    
    if (_favoriteTemplateIds.contains(templateId)) {
      ProfileTemplateService.instance.removeFromFavorites(templateId, _userId);
      setState(() {
        _favoriteTemplateIds.remove(templateId);
      });
    } else {
      ProfileTemplateService.instance.addToFavorites(templateId, _userId);
      setState(() {
        _favoriteTemplateIds.add(templateId);
      });
    }
  }

  void _previewTemplate(ProfileTemplate template) {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => TemplatePreviewModal(
        template: template,
        onApply: () {
          Navigator.pop(context);
          _applyTemplate(template);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showSearchDialog() {
    HapticFeedbackService.selection();
    // Search is already available in the templates tab
  }

  void _refreshData() {
    HapticFeedbackService.selection();
    setState(() {
      _isLoading = true;
    });
    _loadTemplateData();
  }

  void _showDetailedStats() {
    HapticFeedbackService.selection();
    // TODO: Show detailed statistics
  }
}
