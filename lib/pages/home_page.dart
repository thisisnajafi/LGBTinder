import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/navbar/lgbtinder_logo.dart';
import '../components/navbar/bottom_navbar.dart';
import '../components/profile/profile_header.dart';
import '../components/profile/profile_info_sections.dart';
import '../components/profile/photo_gallery.dart';
import '../components/profile/safety_verification_section.dart';
import '../components/profile/profile_action_buttons.dart';
import '../components/loading/skeleton_loader.dart';
import '../components/error_handling/error_display_widget.dart';
import '../components/buttons/animated_button.dart';
import '../components/buttons/accessible_button.dart';
import '../components/badges/notification_badge.dart';
import '../components/modals/responsive_modal.dart';
import '../components/animations/match_celebration.dart';
import '../components/animations/super_like_animation.dart';
import '../services/haptic_feedback_service.dart';
import '../models/models.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _cardAnimationController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  // State variables
  int _currentCardIndex = 0;
  bool _isLoading = true;
  bool _isStackEmpty = false;
  bool _showMatchCelebration = false;
  bool _showSuperLikeSheet = false;
  bool _showFilterSheet = false;
  bool _showProfileSheet = false;
  Map<String, dynamic>? _matchedProfile;
  Map<String, dynamic>? _superLikedProfile;
  Timer? _imageTimer;
  int _currentImageIndex = 0;
  double _imageProgress = 0.0;
  
  // Sample data - will be replaced with API data
  final List<Map<String, dynamic>> _sampleProfiles = [
    {
      'id': 1,
      'name': 'Jessica Parker',
      'age': 28,
      'profession': 'Professional Model',
      'location': 'Chicago, IL',
      'distance': '1 km',
      'bio': 'Cinema enthusiast, animal lover, and adventurer at heart. Looking for meaningful connections.',
      'images': [
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
      ],
      'tags': ['Cinema', 'Vegan', 'Traveler', 'Art'],
      'interests': ['Photography', 'Hiking', 'Cooking', 'Music'],
      'verified': true,
      'online': true,
      'lastActive': '2 minutes ago',
    },
    {
      'id': 2,
      'name': 'Alex Johnson',
      'age': 25,
      'profession': 'Coffee Enthusiast',
      'location': 'Chicago, IL',
      'distance': '2 km',
      'bio': 'Coffee lover, bookworm, and aspiring chef. Always up for a good conversation.',
      'images': [
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
      ],
      'tags': ['Coffee', 'Books', 'Cooking', 'Music'],
      'interests': ['Reading', 'Baking', 'Coffee', 'Writing'],
      'verified': false,
      'online': true,
      'lastActive': '5 minutes ago',
    },
    {
      'id': 3,
      'name': 'Taylor Smith',
      'age': 30,
      'profession': 'Tech Enthusiast',
      'location': 'Chicago, IL',
      'distance': '3 km',
      'bio': 'Runner, gamer, and tech enthusiast. Love exploring new technologies.',
      'images': [
        'https://images.pexels.com/photos/14679012/pexels-photo-14679012.jpeg',
        'https://images.pexels.com/photos/17399454/pexels-photo-17399454.jpeg',
        'https://images.pexels.com/photos/17399454/pexels-photo-17399454.jpeg',
      ],
      'tags': ['Running', 'Gaming', 'Tech', 'Fitness'],
      'interests': ['Programming', 'Gaming', 'Running', 'Tech'],
      'verified': true,
      'online': false,
      'lastActive': '1 hour ago',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfiles();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    
    // Simulate API loading
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      _isStackEmpty = _sampleProfiles.isEmpty;
    });
    
    if (!_isStackEmpty) {
      _startImageTimer();
    }
  }

  void _startImageTimer() {
    _imageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && !_isStackEmpty && _currentCardIndex < _sampleProfiles.length) {
        setState(() {
          _imageProgress += 0.033; // 3 seconds per image
          if (_imageProgress >= 1.0) {
            _imageProgress = 0.0;
            final images = _sampleProfiles[_currentCardIndex]['images'] as List;
            _currentImageIndex = (_currentImageIndex + 1) % images.length;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode 
              ? AppColors.backgroundDark 
              : AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Modern Header with Search and Filters
                _buildModernHeader(context),
                
                // Main Content Area
                Expanded(
                  child: _isLoading 
                      ? _buildLoadingState()
                      : _isStackEmpty 
                          ? _buildEmptyState(context)
                          : _buildCardStack(context),
                ),
                
                // Action Buttons
                if (!_isStackEmpty && !_showProfileSheet)
                  _buildActionButtons(context),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavbar(
            currentIndex: 0,
            onTap: (index) {
              // Handle navigation
              HapticFeedbackService.selection();
            },
          ),
        );
      },
    );
  }

  // Modern Header with Search and Filters
  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Expanded(
            child: LGBTinderLogo(height: 32),
          ),
          
          // Search Button
          AnimatedButton(
            onPressed: () => _showSearchModal(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.search,
                color: AppColors.primaryLight,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Filter Button
          AnimatedButton(
            onPressed: () => _showFilterSheet = true,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondaryLight.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.tune,
                color: AppColors.secondaryLight,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Notifications
          Stack(
            children: [
              AnimatedButton(
                onPressed: () => _showNotifications(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: NotificationBadge(
                  count: 3,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: AppColors.lgbtGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Finding your perfect matches...',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'This may take a moment',
            style: AppTypography.bodyMediumStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Skeleton cards
          ...List.generate(2, (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SkeletonCard(),
          )),
        ],
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: AppColors.lgbtGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Colors.white,
                size: 60,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'No More Matches Today',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'You\'ve seen all available profiles in your area. Check back tomorrow for new matches!',
              style: AppTypography.bodyLargeStyle.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    onPressed: () => _loadProfiles(),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: AppColors.lgbtGradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Refresh',
                              style: AppTypography.titleMediumStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: AnimatedButton(
                    onPressed: () => _showUpgradeModal(context),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.primaryLight,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.primaryLight,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Upgrade',
                              style: AppTypography.titleMediumStyle.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card Stack
  Widget _buildCardStack(BuildContext context) {
    final currentProfile = _sampleProfiles[_currentCardIndex];
    
    return Stack(
      children: [
        // Background cards
        ...List.generate(2, (index) {
          if (_currentCardIndex + index + 1 >= _sampleProfiles.length) {
            return const SizedBox.shrink();
          }
          
          final profile = _sampleProfiles[_currentCardIndex + index + 1];
          return Positioned(
            top: (index + 1) * 8.0,
            left: (index + 1) * 4.0,
            right: (index + 1) * 4.0,
            bottom: (index + 1) * 8.0,
            child: Transform.scale(
              scale: 1.0 - (index + 1) * 0.05,
              child: _buildProfileCard(context, profile, false),
            ),
          );
        }),
        
        // Main card
        _buildProfileCard(context, currentProfile, true),
        
        // Match celebration overlay
        if (_showMatchCelebration)
          _buildMatchCelebrationOverlay(context),
        
        // Super like sheet overlay
        if (_showSuperLikeSheet)
          _buildSuperLikeSheet(context),
      ],
    );
  }

  // Profile Card
  Widget _buildProfileCard(BuildContext context, Map<String, dynamic> profile, bool isMain) {
    final images = profile['images'] as List;
    final currentImage = images[_currentImageIndex % images.length];
    
    return GestureDetector(
      onTap: () => _showProfileDetail(context, profile),
      onPanUpdate: isMain ? _onPanUpdate : null,
      onPanEnd: isMain ? _onPanEnd : null,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Profile Image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: currentImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.background,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.person,
                      size: 100,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              
              // Image Progress Indicators
              if (images.length > 1)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: List.generate(images.length, (index) {
                      double progress = 0.0;
                      if (index < _currentImageIndex) {
                        progress = 1.0;
                      } else if (index == _currentImageIndex) {
                        progress = _imageProgress;
                      }
                      
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              
              // Profile Info Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name and Age
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${profile['name']}, ${profile['age']}',
                              style: AppTypography.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (profile['verified'] == true)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Profession
                      Text(
                        profile['profession'],
                        style: AppTypography.bodyLargeStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Location and Distance
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile['location']} • ${profile['distance']}',
                            style: AppTypography.bodyMediumStyle.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const Spacer(),
                          if (profile['online'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Online',
                                style: AppTypography.bodySmallStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: (profile['tags'] as List).take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryLight.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.bodySmallStyle.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass Button
          _buildActionButton(
            icon: Icons.close,
            color: AppColors.textSecondary,
            onPressed: _handlePass,
          ),
          
          // Super Like Button
          _buildSuperLikeButton(),
          
          // Like Button
          _buildActionButton(
            icon: Icons.favorite,
            color: AppColors.error,
            onPressed: _handleLike,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedButton(
      onPressed: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSuperLikeButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.05),
          child: AnimatedButton(
            onPressed: _handleSuperLike,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.superLikeGold, AppColors.warningLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.superLikeGold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }

  // Event Handlers
  void _onPanUpdate(DragUpdateDetails details) {
    // Handle swipe gestures
  }

  void _onPanEnd(DragEndDetails details) {
    // Handle swipe end
  }

  void _handlePass() {
    HapticFeedbackService.selection();
    _nextCard();
  }

  void _handleLike() {
    HapticFeedbackService.selection();
    
    // Check for match
    final currentProfile = _sampleProfiles[_currentCardIndex];
    if (currentProfile['name'] == 'Jessica Parker' || currentProfile['name'] == 'Alex Johnson') {
      _showMatchCelebration = true;
      _matchedProfile = currentProfile;
    }
    
    _nextCard();
  }

  void _handleSuperLike() {
    HapticFeedbackService.selection();
    _showSuperLikeSheet = true;
    _superLikedProfile = _sampleProfiles[_currentCardIndex];
  }

  void _nextCard() {
    setState(() {
      if (_currentCardIndex < _sampleProfiles.length - 1) {
        _currentCardIndex++;
        _currentImageIndex = 0;
        _imageProgress = 0.0;
      } else {
        _isStackEmpty = true;
      }
    });
  }

  void _showProfileDetail(BuildContext context, Map<String, dynamic> profile) {
    // Show detailed profile modal
  }

  void _showSearchModal(BuildContext context) {
    // Show search modal
  }

  void _showNotifications(BuildContext context) {
    // Show notifications
  }

  void _showUpgradeModal(BuildContext context) {
    // Show upgrade modal
  }

  Widget _buildMatchCelebrationOverlay(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                color: AppColors.error,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'It\'s a Match!',
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You and ${_matchedProfile?['name']} liked each other',
                style: AppTypography.bodyLargeStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () {
                        setState(() => _showMatchCelebration = false);
                        // Navigate to chat
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: AppColors.lgbtGradient,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Send Message',
                            style: AppTypography.titleMediumStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () {
                        setState(() => _showMatchCelebration = false);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.textSecondary),
                        ),
                        child: Center(
                          child: Text(
                            'Keep Swiping',
                            style: AppTypography.titleMediumStyle.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuperLikeSheet(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: AppColors.superLikeGold,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Super Like!',
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send a message to ${_superLikedProfile?['name']}',
                style: AppTypography.bodyLargeStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () {
                        setState(() => _showSuperLikeSheet = false);
                        // Send super like
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [AppColors.superLikeGold, AppColors.warningLight],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Send Super Like',
                            style: AppTypography.titleMediumStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () {
                        setState(() => _showSuperLikeSheet = false);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.textSecondary),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: AppTypography.titleMediumStyle.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
