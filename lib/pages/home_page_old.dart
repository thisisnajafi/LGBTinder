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
import '../services/audio_service.dart';
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
            style: AppTypography.bodyMedium.copyWith(
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
              style: AppTypography.bodyLarge.copyWith(
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
                              style: AppTypography.titleMedium.copyWith(
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
                              style: AppTypography.titleMedium.copyWith(
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
                        style: AppTypography.bodyLarge.copyWith(
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
                            style: AppTypography.bodyMedium.copyWith(
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
                                style: AppTypography.bodySmall.copyWith(
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
                              style: AppTypography.bodySmall.copyWith(
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
                    color: const AppColors.superLikeGold.withValues(alpha: 0.4),
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
    AudioService.playSound('pass');
    _nextCard();
  }

  void _handleLike() {
    HapticFeedbackService.selection();
    AudioService.playSound('like');
    
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
    AudioService.playSound('super_like');
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
                style: AppTypography.bodyLarge.copyWith(
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
                            style: AppTypography.titleMedium.copyWith(
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
                            style: AppTypography.titleMedium.copyWith(
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
                style: AppTypography.bodyLarge.copyWith(
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
                            style: AppTypography.titleMedium.copyWith(
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
                            style: AppTypography.titleMedium.copyWith(
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
         // Simulate 30% chance of match for demo purposes
         if (currentProfile['name'] == 'Jessica Parker' || currentProfile['name'] == 'Alex Johnson') {
           _showMatchCelebration = true;
           _matchedProfile = currentProfile;
         }
       }
       
       if (_topCardIndex < _sampleProfiles.length - 1) {
         _topCardIndex++;
         
         // Reset image progress for new card
         _imageProgress = 0.0;
         _currentImageIndex = 0;
         
         // Lazy load next card image if not already loaded
         int nextCardToLoad = _topCardIndex + 2; // Load 2 cards ahead
         if (nextCardToLoad < _sampleProfiles.length && !_loadedCardIndices.contains(nextCardToLoad)) {
           _loadedCardIndices.add(nextCardToLoad);
         }
         
         // Start smooth animation for next card
         _cardAnimationController.forward(from: 0);
       } else {
         // Stack is finished
         _isStackEmpty = true;
       }
       _swipeRight = false;
       _swipeLeft = false;
     });
   }

  void _handleLike() {
    setState(() {
      _swipeRight = true;
    });
    
    // Process the card swipe
    _onCardSwiped(true);
  }

  void _handleSkip() {
    setState(() {
      _swipeLeft = true;
    });
    _showSnackBar('Skipped', const AppColors.textSecondaryLight);
    // Process the card swipe
    _onCardSwiped(false);
  }

  void _handleSuperLike() {
    setState(() {
      _showSuperLikeSheet = true;
      _superLikedProfile = _sampleProfiles[_topCardIndex];
    });
  }

  void _upgradePlan() {
    _showSnackBar('Upgrade feature coming soon! 🚀', AppColors.primaryLight);
    // Here you would typically navigate to upgrade screen
  }

     void _startImageTimer() {
     _imageTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
       if (mounted && !_isStackEmpty && _topCardIndex < _sampleProfiles.length) {
         setState(() {
           _imageProgress += 0.033; // Increment for 3 seconds total
           if (_imageProgress >= 1.0) {
             _imageProgress = 0.0;
             _currentImageIndex = (_currentImageIndex + 1) % (_sampleProfiles[_topCardIndex]['images'] as List).length;
           }
         });
       }
     });
   }

   void _onCardTap() {
     if (!_isStackEmpty && _topCardIndex < _sampleProfiles.length) {
       setState(() {
         _imageProgress = 0.0;
         _currentImageIndex = (_currentImageIndex + 1) % (_sampleProfiles[_topCardIndex]['images'] as List).length;
       });
     }
   }

     @override
   void dispose() {
     _particleController.dispose();
     _cardAnimationController.dispose();
     _lineAnimationController.dispose();
     _superLikeBorderController.dispose();
     _imageTimer?.cancel();
     super.dispose();
   }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double logoHeight = 40 + 20 + 30; // logo + top/bottom padding
    final double actionButtonsHeight = 70 + 40; // button size + vertical padding
    final double navbarHeight = 62 + 18; // navbar height + bottom padding

    return Scaffold(
      backgroundColor: AppColors.navbarBackground, // Dark navy background
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/audio-recorder-settings');
            },
            backgroundColor: AppColors.warning,
            heroTag: "audio_recorder",
            child: const Icon(
              Icons.mic,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/media-picker-settings');
            },
            backgroundColor: AppColors.success,
            heroTag: "media_picker",
            child: const Icon(
              Icons.add_photo_alternate,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/image-compression-settings');
            },
            backgroundColor: AppColors.accent,
            heroTag: "image_compression",
            child: const Icon(
              Icons.compress,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/skeleton-loader-settings');
            },
            backgroundColor: AppColors.info,
            heroTag: "skeleton_loader",
            child: const Icon(
              Icons.view_stream,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/pull-to-refresh-settings');
            },
            backgroundColor: AppColors.error,
            heroTag: "pull_to_refresh",
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/animation-settings');
            },
            backgroundColor: AppColors.warning,
            heroTag: "animation_settings",
            child: const Icon(
              Icons.animation,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/haptic-feedback-settings');
            },
            backgroundColor: AppColors.success,
            heroTag: "haptic_feedback",
            child: const Icon(
              Icons.vibration,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/rainbow-theme-settings');
            },
            backgroundColor: AppColors.secondaryLight,
            heroTag: "rainbow_theme",
            child: const Icon(
              Icons.palette,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/discovery');
            },
            backgroundColor: AppColors.primary,
            heroTag: "discovery",
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background lines
          _buildAnimatedBackgroundLines(),
          
                     // Main content
           SafeArea(
             child: LayoutBuilder(
               builder: (context, constraints) {
                 final availableHeight = constraints.maxHeight;
                 final cardHeight = availableHeight - (logoHeight + actionButtonsHeight + navbarHeight);

                 return Column(
                   children: [
                     // App title
                     _buildAppTitle(context),
                     
                     // Profile card area
                     SizedBox(
                       height: cardHeight > 0 ? cardHeight : 0,
                       child: Center(
                         child: _isStackEmpty 
                           ? _buildEmptyStackMessage(context)
                           : AnimatedBuilder(
                               animation: _cardAnimationController,
                               builder: (context, child) {
                                 return Stack(
                                   alignment: Alignment.center,
                                   children: List.generate(3, (i) { // Only show 3 cards max
                                     int reverseI = 2 - i;
                                     int cardIndex = _topCardIndex + reverseI;
                                     if (cardIndex >= _sampleProfiles.length) return const SizedBox.shrink();
                                     
                                     // Calculate animation offset for smooth transition
                                     double animationOffset = 0;
                                     if (reverseI == 0) {
                                       animationOffset = (1 - _cardAnimationController.value) * 20;
                                     }
                                     
                                     // Only show card if it's loaded
                                     if (!_loadedCardIndices.contains(cardIndex)) {
                                       return const SizedBox.shrink();
                                     }
                                     
                                     // Top card is swipeable
                                     if (reverseI == 0) {
                                       return Transform.translate(
                                         offset: Offset(0, animationOffset),
                                         child: _ModernSwipeableCard(
                                           key: ValueKey(_topCardIndex),
                                           profile: _sampleProfiles[cardIndex],
                                           width: screenWidth * 0.9,
                                           height: cardHeight,
                                           onSwiped: _onCardSwiped,
                                           onTap: _onCardTap,
                                           onShowProfile: (profile) => _showProfileSheet(context, profile),
                                           swipeRight: _swipeRight,
                                           swipeLeft: _swipeLeft,
                                           currentImageIndex: _currentImageIndex,
                                           imageProgress: _imageProgress,
                                         ),
                                       );
                                     } else {
                                       // Background cards - completely hidden behind top card
                                       return const SizedBox.shrink(); // Don't show background cards at all
                                     }
                                   }),
                                 );
                               },
                             ),
                       ),
                     ),
                     
                     // Action buttons (only show if stack is not empty and sheet is not open)
                     if (!_isStackEmpty && !_isProfileSheetOpen)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        child: _buildModernActionButtons(context),
                      ),
                   ],
                 );
               },
             ),
           ),
           
                                   // Match celebration overlay
             if (_showMatchCelebration)
               _buildMatchCelebration(context),
             
             // Super like sheet overlay
             if (_showSuperLikeSheet)
               _buildSuperLikeSheet(context),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackgroundLines() {
    return AnimatedBuilder(
      animation: _lineAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: AnimatedLinesPainter(_lineAnimationController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildModernActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pass button with gradient
        _buildGradientActionButton(
          context: context,
          icon: Icons.close,
          gradient: const LinearGradient(
            colors: [AppColors.textSecondaryLight, AppColors.textSecondaryDark], // Gray gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
                     onTap: _handleSkip,
        ),
        
                 // Super like button with gradient and animation
         _buildSuperLikeButton(context),
        
        // Like button with gradient
        _buildGradientActionButton(
          context: context,
          icon: Icons.favorite,
          gradient: const LinearGradient(
            colors: [AppColors.errorLight, AppColors.errorDark], // Red gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
                     onTap: _handleLike,
        ),
      ],
    );
  }

     Widget _buildGradientActionButton({
     required BuildContext context,
     required IconData icon,
     required Gradient gradient,
     required VoidCallback onTap,
   }) {
     return GestureDetector(
       onTap: onTap,
       child: Container(
         width: 60,
         height: 60,
         decoration: BoxDecoration(
           shape: BoxShape.circle,
           gradient: gradient,
           boxShadow: [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.3),
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

   Widget _buildSuperLikeButton(BuildContext context) {
     return AnimatedBuilder(
       animation: _superLikeBorderController,
       builder: (context, child) {
         return GestureDetector(
                       onTap: _handleSuperLike,
           child: Container(
             width: 75, // Bigger than other buttons
             height: 75,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               gradient: const LinearGradient(
                 colors: [AppColors.superLikeGold, AppColors.warningLight, AppColors.lgbtOrange], // Yellow gradient
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
               ),
               boxShadow: [
                 BoxShadow(
                   color: const AppColors.superLikeGold.withValues(alpha: 0.4),
                   blurRadius: 20,
                   offset: const Offset(0, 8),
                 ),
               ],
             ),
             child: Container(
               margin: const EdgeInsets.all(3),
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 border: Border.all(
                   color: Colors.white.withValues(alpha: 0.8),
                   width: 2,
                 ),
               ),
               child: Icon(
                 Icons.star,
                 color: Colors.white,
                 size: 32, // Bigger icon
               ),
             ),
           ),
         );
       },
     );
   }

  Widget _buildEmptyStackMessage(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Message
          Text(
            'Your Daily Matches are Finished',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'You\'ve seen all your matches for today.\nUpgrade your plan to see more profiles!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Upgrade button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: AppColors.lgbtGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _upgradePlan,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Upgrade Plan to See More',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }

  Widget _buildAppTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LGBTinderLogo(height: 30),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 32,
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientInfo,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

     void _showSnackBar(String message, Color color) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         backgroundColor: color,
         duration: const Duration(seconds: 1),
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       ),
     );
   }

               void _showProfileSheet(BuildContext context, Map<String, dynamic> profile) {
       setState(() {
         _isProfileSheetOpen = true;
       });
       
       showModalBottomSheet(
         context: context,
         isScrollControlled: true,
         backgroundColor: Colors.transparent,
         isDismissible: true,
         enableDrag: true,
         builder: (context) => _ProfileDetailSheet(
           profile: profile,
           currentImageIndex: _currentImageIndex,
           imageProgress: _imageProgress,
           onTap: _onCardTap,
                       onSwipeRight: () {
              _handleLike();
              Navigator.of(context).pop();
            },
            onSwipeLeft: () {
              _handleSkip();
              Navigator.of(context).pop();
            },
            onSuperLike: () {
              _handleSuperLike();
              Navigator.of(context).pop();
            },
           onClose: () {
             Navigator.of(context).pop();
           },
         ),
       ).then((_) {
         setState(() {
           _isProfileSheetOpen = false;
         });
       });
     }
     
           Widget _buildMatchCelebration(BuildContext context) {
        final theme = Theme.of(context);
        final screenSize = MediaQuery.of(context).size;
        
        return Stack(
          children: [
            // Semi-transparent background that allows card interactions to pass through
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ),
            // Modal content that captures its own interactions
            Center(
              child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.navbarBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Match images with overlap - bigger and rectangular
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Logged in user image (right side, rotated clockwise)
                        Positioned(
                          right: 20,
                          child: Transform.rotate(
                            angle: 0.1, // Small clockwise rotation
                            child: Container(
                              width: 140,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                                                 child: Container(
                                   decoration: BoxDecoration(
                                     gradient: LinearGradient(
                                       colors: [Colors.blue[400]!, Colors.purple[400]!],
                                       begin: Alignment.topLeft,
                                       end: Alignment.bottomRight,
                                     ),
                                   ),
                                   child: Icon(
                                     Icons.person,
                                     size: 60,
                                     color: Colors.white,
                                   ),
                                 ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Matched user image (left side, overlapping 20%, rotated counter-clockwise)
                        Positioned(
                          left: 20,
                          child: Transform.rotate(
                            angle: -0.1, // Small counter-clockwise rotation
                            child: Container(
                              width: 140,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                                                 child: Container(
                                   decoration: BoxDecoration(
                                     gradient: LinearGradient(
                                       colors: [Colors.pink[400]!, Colors.red[400]!],
                                       begin: Alignment.topLeft,
                                       end: Alignment.bottomRight,
                                     ),
                                   ),
                                   child: Icon(
                                     Icons.person,
                                     size: 60,
                                     color: Colors.white,
                                   ),
                                 ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                 
                 const SizedBox(height: 24),
                 
                 // Congratulations text
                 Text(
                   'Congratulations!',
                   style: theme.textTheme.headlineMedium?.copyWith(
                     fontWeight: FontWeight.bold,
                     color: Colors.white,
                   ),
                   textAlign: TextAlign.center,
                 ),
                 
                 const SizedBox(height: 8),
                 
                 Text(
                   'It\'s a new match!',
                   style: theme.textTheme.bodyLarge?.copyWith(
                     color: Colors.white.withValues(alpha: 0.8),
                   ),
                   textAlign: TextAlign.center,
                 ),
                 
                 const SizedBox(height: 32),
                 
                 // Start Chat button
                 Container(
                   width: double.infinity,
                   height: 56,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(28),
                     gradient: LinearGradient(
                       colors: AppColors.lgbtGradient,
                       begin: Alignment.centerLeft,
                       end: Alignment.centerRight,
                     ),
                     boxShadow: [
                       BoxShadow(
                         color: AppColors.primaryLight.withValues(alpha: 0.3),
                         blurRadius: 15,
                         offset: const Offset(0, 8),
                       ),
                     ],
                   ),
                   child: Material(
                     color: Colors.transparent,
                     child: InkWell(
                       borderRadius: BorderRadius.circular(28),
                       onTap: () {
                         setState(() {
                           _showMatchCelebration = false;
                           _matchedProfile = null;
                         });
                         _showSnackBar('Chat feature coming soon! 💬', AppColors.primaryLight);
                       },
                       child: Center(
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(
                               Icons.chat_bubble,
                               color: Colors.white,
                               size: 24,
                             ),
                             const SizedBox(width: 12),
                             Text(
                               'Start Chat',
                               style: theme.textTheme.titleLarge?.copyWith(
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                   ),
                 ),
                 
                 const SizedBox(height: 16),
                 
                 // Continue button
                 TextButton(
                   onPressed: () {
                     setState(() {
                       _showMatchCelebration = false;
                       _matchedProfile = null;
                     });
                   },
                   child: Text(
                     'Continue Swiping',
                     style: theme.textTheme.bodyLarge?.copyWith(
                       color: Colors.white.withValues(alpha: 0.7),
                       fontWeight: FontWeight.w500,
                     ),
                   ),
                 ),
                                ],
                                                  ),
                ),
              ),
            ],
          );
        }
        
        Widget _buildSuperLikeSheet(BuildContext context) {
          final theme = Theme.of(context);
          final screenSize = MediaQuery.of(context).size;
          
          return Stack(
            children: [
              // Semi-transparent background that allows card interactions to pass through
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ),
              ),
              // Modal content that captures its own interactions
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.navbarBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Super like icon and title
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.superLikeGold, AppColors.warningLight, AppColors.lgbtOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Super Like!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Send a message to ${_superLikedProfile?['name'] ?? 'them'}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Emoji options
                      Text(
                        'Quick Messages',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                                             Wrap(
                         spacing: 12,
                         runSpacing: 12,
                         children: [
                           _buildEmojiButton('😍'),
                           _buildEmojiButton('🔥'),
                           _buildEmojiButton('💫'),
                           _buildEmojiButton('🎉'),
                           _buildEmojiButton('💖'),
                           _buildEmojiButton('✨'),
                           _buildEmojiButton('🌟'),
                           _buildEmojiButton('💕'),
                         ],
                       ),
                      
                      const SizedBox(height: 24),
                      
                      // Custom message input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Or type your own message...',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          maxLines: 3,
                          maxLength: 100,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Send button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [AppColors.superLikeGold, AppColors.warningLight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const AppColors.superLikeGold.withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              setState(() {
                                _showSuperLikeSheet = false;
                                _superLikedProfile = null;
                              });
                              _showSnackBar('Super like sent! ⭐', const AppColors.superLikeGold);
                            },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Send Super Like',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Cancel button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showSuperLikeSheet = false;
                            _superLikedProfile = null;
                          });
                        },
                        child: Text(
                          'Cancel',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        
                 Widget _buildEmojiButton(String emoji) {
           return GestureDetector(
             onTap: () {
               // Close modal and show snackbar
               setState(() {
                 _showSuperLikeSheet = false;
                 _superLikedProfile = null;
               });
               _showSnackBar('Super like sent! ⭐', const AppColors.superLikeGold);
             },
             child: Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: Colors.white.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(20),
                 border: Border.all(
                   color: Colors.white.withValues(alpha: 0.2),
                 ),
               ),
               child: Text(
                 emoji,
                 style: TextStyle(),
               ),
             ),
           );
         }
}

// Animated background lines painter
class AnimatedLinesPainter extends CustomPainter {
  final double animationValue;

  AnimatedLinesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

         // Draw animated lines
     for (int i = 0; i < 8; i++) {
       final startX = (size.width * 0.1 * i + animationValue * 100) % size.width;
       final startY = (size.height * 0.1 * i + animationValue * 50) % size.height;
       final endX = startX + 100.0;
       final endY = startY + 50.0;
       
       canvas.drawLine(
         Offset(startX, startY),
         Offset(endX, endY),
         paint,
       );
     }

         // Draw diagonal lines
     for (int i = 0; i < 5; i++) {
       final startX = (size.width * 0.2 * i - animationValue * 80) % size.width;
       final startY = size.height;
       final endX = startX + 150.0;
       final endY = 0.0;
       
       canvas.drawLine(
         Offset(startX, startY),
         Offset(endX, endY),
         paint,
       );
     }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * 0.1 * i + animationValue * 100) % size.width;
      final y = (size.height * 0.1 * i + animationValue * 50) % size.height;
      final radius = 2.0 + (i % 3);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Modern swipeable card wrapper
 class _ModernSwipeableCard extends StatefulWidget {
   final Map<String, dynamic> profile;
   final double width;
   final double height;
   final void Function(bool isRight) onSwiped;
   final VoidCallback? onTap;
   final void Function(Map<String, dynamic> profile)? onShowProfile;
   final bool swipeRight;
   final bool swipeLeft;
   final int currentImageIndex;
   final double imageProgress;

   const _ModernSwipeableCard({
     Key? key,
     required this.profile,
     required this.width,
     required this.height,
     required this.onSwiped,
     this.onTap,
     this.onShowProfile,
     this.swipeRight = false,
     this.swipeLeft = false,
     required this.currentImageIndex,
     required this.imageProgress,
   }) : super(key: key);

  @override
  State<_ModernSwipeableCard> createState() => _ModernSwipeableCardState();
}

class _ModernSwipeableCardState extends State<_ModernSwipeableCard> with SingleTickerProviderStateMixin {
  late Offset _offset;
  late AnimationController _controller;
  late Animation<Offset> _animation;


  @override
  void initState() {
    super.initState();
    _offset = Offset.zero;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
    _controller.addListener(() {
      setState(() {
        _offset = _animation.value;
      });
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_offset.dx.abs() > 100) {
          widget.onSwiped(_offset.dx > 0);
        } else {
          setState(() {
            _offset = Offset.zero;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant _ModernSwipeableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.swipeRight && !oldWidget.swipeRight) {
      _animateSwipe(Offset(500, 0));
    } else if (widget.swipeLeft && !oldWidget.swipeLeft) {
      _animateSwipe(Offset(-500, 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_offset.dx.abs() > 100) {
      _animateSwipe(Offset(_offset.dx > 0 ? 500 : -500, _offset.dy));
    } else {
      _animateSwipe(Offset.zero);
    }
  }

  void _animateSwipe(Offset endOffset) {
    _animation = Tween<Offset>(
      begin: _offset,
      end: endOffset,
    ).animate(_controller);
    _controller.forward(from: 0);
  }

           @override
    Widget build(BuildContext context) {
      return Transform.translate(
        offset: _offset,
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onTap: widget.onTap,
          child: _ModernCard(
            profile: widget.profile,
            width: widget.width,
            height: widget.height,
            currentImageIndex: widget.currentImageIndex,
            imageProgress: widget.imageProgress,
            onShowProfile: widget.onShowProfile,
          ),
        ),
      );
    }
}

// Modern card design with cached images and theme support
 class _ModernCard extends StatelessWidget {
   final Map<String, dynamic> profile;
   final double width;
   final double height;
   final int currentImageIndex;
   final double imageProgress;
   final void Function(Map<String, dynamic> profile)? onShowProfile;

   const _ModernCard({
     Key? key,
     required this.profile,
     required this.width,
     required this.height,
     required this.currentImageIndex,
     required this.imageProgress,
     this.onShowProfile,
   }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final images = profile['images'] as List;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
                         // Profile image with caching and fade animation - fills entire card
             Positioned.fill(
               child: AnimatedSwitcher(
                 duration: const Duration(milliseconds: 300),
                 transitionBuilder: (Widget child, Animation<double> animation) {
                   return FadeTransition(
                     opacity: animation,
                     child: child,
                   );
                 },
                 child: CachedNetworkImage(
                   key: ValueKey('${images[currentImageIndex % images.length]}_$currentImageIndex'),
                   imageUrl: images[currentImageIndex % images.length],
                   fit: BoxFit.cover,
                   width: double.infinity,
                   height: double.infinity,
                   placeholder: (context, url) => Container(
                     color: colorScheme.surface,
                     width: double.infinity,
                     height: double.infinity,
                     child: Center(
                       child: CircularProgressIndicator(
                         color: colorScheme.primary,
                       ),
                     ),
                   ),
                   errorWidget: (context, url, error) => Container(
                     color: colorScheme.surface,
                     width: double.infinity,
                     height: double.infinity,
                     child: Icon(
                       Icons.person,
                       size: 100,
                       color: colorScheme.outline,
                     ),
                   ),
                   memCacheWidth: 800, // Optimize memory usage
                   memCacheHeight: 1200,
                   maxWidthDiskCache: 800,
                   maxHeightDiskCache: 1200,
                 ),
               ),
             ),
            
                                                   // Progress bars at top
              if (images.length > 1)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: List.generate(images.length, (index) {
                      // Calculate fill progress for each bar
                      double fillProgress = 0.0;
                      
                      if (index < (currentImageIndex % images.length)) {
                        // Previous images: fully filled
                        fillProgress = 1.0;
                      } else if (index == (currentImageIndex % images.length)) {
                        // Current image: partial fill based on progress
                        fillProgress = imageProgress;
                      } else {
                        // Future images: empty
                        fillProgress = 0.0;
                      }
                      
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.white.withValues(alpha: 0.3), // Light gray background
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Stack(
                              children: [
                                // Background (empty progress bar)
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.transparent,
                                ),
                                // Fill animation with app colors
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: FractionallySizedBox(
                                    widthFactor: fillProgress,
                                    alignment: Alignment.centerLeft, // Fill from left to right
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: Colors.white, // Single white color
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
            
                                                   // User information and profile button at bottom
                                            Positioned(
                 bottom: 0,
                 left: 0,
                 right: 0,
                 child: Container(
                   padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
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
                     borderRadius: const BorderRadius.only(
                       bottomLeft: Radius.circular(20),
                       bottomRight: Radius.circular(20),
                     ),
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       // User info and profile button row
                       Row(
                         children: [
                           // User info
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 // Name and age
                                 Row(
                                   children: [
                                     Text(
                                       profile['name'] ?? 'Unknown',
                                       style: theme.textTheme.titleLarge?.copyWith(
                                         fontWeight: FontWeight.bold,
                                         color: Colors.white,
                                       ),
                                     ),
                                     const SizedBox(width: 8),
                                     Text(
                                       '${profile['age'] ?? 25}',
                                       style: theme.textTheme.titleMedium?.copyWith(
                                         fontWeight: FontWeight.w600,
                                         color: Colors.white,
                                       ),
                                     ),
                                   ],
                                 ),
                                 const SizedBox(height: 4),
                                 // Profession
                                 Text(
                                   profile['profession'] ?? 'Professional',
                                   style: theme.textTheme.bodyMedium?.copyWith(
                                     color: Colors.white.withValues(alpha: 0.9),
                                     fontWeight: FontWeight.w500,
                                   ),
                                 ),
                                 const SizedBox(height: 4),
                                 // Location and distance
                                 Row(
                                   children: [
                                     Icon(
                                       Icons.location_on,
                                       size: 16,
                                       color: Colors.white.withValues(alpha: 0.8),
                                     ),
                                     const SizedBox(width: 4),
                                     Text(
                                       profile['location'] ?? 'Chicago, IL',
                                       style: theme.textTheme.bodySmall?.copyWith(
                                         color: Colors.white.withValues(alpha: 0.8),
                                       ),
                                     ),
                                     const SizedBox(width: 12),
                                     Icon(
                                       Icons.straighten,
                                       size: 16,
                                       color: Colors.white.withValues(alpha: 0.8),
                                     ),
                                     const SizedBox(width: 4),
                                     Text(
                                       profile['distance'] ?? '1 km',
                                       style: theme.textTheme.bodySmall?.copyWith(
                                         color: Colors.white.withValues(alpha: 0.8),
                                       ),
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                           // Profile button (bigger and at bottom)
                           GestureDetector(
                             onTap: () {
                               onShowProfile?.call(profile);
                             },
                             child: Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.white.withValues(alpha: 0.9),
                                 shape: BoxShape.circle,
                                 boxShadow: [
                                   BoxShadow(
                                     color: Colors.black.withValues(alpha: 0.3),
                                     blurRadius: 8,
                                     offset: const Offset(0, 2),
                                   ),
                                 ],
                               ),
                               child: Icon(
                                 Icons.person,
                                 size: 28, // Bigger icon
                                 color: Colors.black87,
                               ),
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 8),
                       // Matching badge
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: AppColors.primaryLight.withValues(alpha: 0.9),
                           borderRadius: BorderRadius.circular(16),
                           border: Border.all(
                             color: Colors.white.withValues(alpha: 0.3),
                             width: 1,
                           ),
                         ),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Icon(
                               Icons.favorite,
                               size: 14,
                               color: Colors.white,
                             ),
                             const SizedBox(width: 4),
                             Text(
                               'Travel',
                               style: theme.textTheme.bodySmall?.copyWith(
                                 color: Colors.white,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }
}

// Profile Detail Sheet Widget
class _ProfileDetailSheet extends StatefulWidget {
  final Map<String, dynamic> profile;
  final int currentImageIndex;
  final double imageProgress;
  final VoidCallback onTap;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSuperLike;
  final VoidCallback onClose;

  const _ProfileDetailSheet({
    Key? key,
    required this.profile,
    required this.currentImageIndex,
    required this.imageProgress,
    required this.onTap,
    required this.onSwipeRight,
    required this.onSwipeLeft,
    required this.onSuperLike,
    required this.onClose,
  }) : super(key: key);

  @override
  State<_ProfileDetailSheet> createState() => _ProfileDetailSheetState();
}

class _ProfileDetailSheetState extends State<_ProfileDetailSheet> with TickerProviderStateMixin {
  late AnimationController _imageTimer;
  int _currentImageIndex = 0;
  double _imageProgress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentImageIndex = widget.currentImageIndex;
    _imageProgress = widget.imageProgress;
    _imageTimer = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _startImageTimer();
  }

  @override
  void dispose() {
    _imageTimer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startImageTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _imageProgress += 0.033; // Increment for 3 seconds total
          if (_imageProgress >= 1.0) {
            _imageProgress = 0.0;
            final images = widget.profile['images'] as List;
            _currentImageIndex = (_currentImageIndex + 1) % images.length;
          }
        });
      }
    });
  }

  void _onImageTap() {
    setState(() {
      _imageProgress = 0.0;
      final images = widget.profile['images'] as List;
      _currentImageIndex = (_currentImageIndex + 1) % images.length;
    });
    // Restart the timer after manual tap
    _timer?.cancel();
    _startImageTimer();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final images = widget.profile['images'] as List;
    final screenHeight = MediaQuery.of(context).size.height;
    
         return Container(
       height: screenHeight * 0.9,
       decoration: BoxDecoration(
         color: AppColors.navbarBackground,
         borderRadius: const BorderRadius.only(
           topLeft: Radius.circular(24),
           topRight: Radius.circular(24),
         ),
       ),
      child: Column(
        children: [
                     // Drag handle
           Container(
             margin: const EdgeInsets.only(top: 12, bottom: 8),
             width: 40,
             height: 4,
             decoration: BoxDecoration(
               color: Colors.white.withValues(alpha: 0.3),
               borderRadius: BorderRadius.circular(2),
             ),
           ),
          
                     // Close button
           Align(
             alignment: Alignment.topRight,
             child: GestureDetector(
               onTap: widget.onClose,
               child: Container(
                 margin: const EdgeInsets.only(right: 16, top: 8),
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: Colors.white.withValues(alpha: 0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   Icons.close,
                   size: 20,
                   color: Colors.white,
                 ),
               ),
             ),
           ),
          
          // Image section with progress bars
          Container(
            height: screenHeight * 0.4,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                                     // Image with fade animation and click effects
                   Positioned.fill(
                     child: Material(
                       color: Colors.transparent,
                                                child: InkWell(
                           borderRadius: BorderRadius.circular(16),
                           onTap: _onImageTap,
                           splashColor: Colors.white.withValues(alpha: 0.2),
                           highlightColor: Colors.white.withValues(alpha: 0.1),
                           child: AnimatedSwitcher(
                             duration: const Duration(milliseconds: 300),
                             transitionBuilder: (Widget child, Animation<double> animation) {
                               return FadeTransition(
                                 opacity: animation,
                                 child: child,
                               );
                             },
                             child: CachedNetworkImage(
                               key: ValueKey('${images[_currentImageIndex % images.length]}_$_currentImageIndex'),
                               imageUrl: images[_currentImageIndex % images.length],
                             fit: BoxFit.cover,
                             placeholder: (context, url) => Container(
                               color: colorScheme.surface,
                               child: Center(
                                 child: CircularProgressIndicator(
                                   color: colorScheme.primary,
                                 ),
                               ),
                             ),
                             errorWidget: (context, url, error) => Container(
                               color: colorScheme.surface,
                               child: Icon(
                                 Icons.person,
                                 size: 100,
                                 color: colorScheme.outline,
                               ),
                             ),
                           ),
                         ),
                       ),
                     ),
                   ),
                  
                  // Progress bars
                  if (images.length > 1)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                                                 children: List.generate(images.length, (index) {
                           double fillProgress = 0.0;
                           
                           if (index < (_currentImageIndex % images.length)) {
                             fillProgress = 1.0;
                           } else if (index == (_currentImageIndex % images.length)) {
                             fillProgress = _imageProgress;
                           } else {
                             fillProgress = 0.0;
                           }
                          
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.transparent,
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 100),
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: FractionallySizedBox(
                                        widthFactor: fillProgress,
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(2),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Profile information
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Create a mock User object for the ProfileHeader
                  ProfileHeader(
                    user: User(
                      id: 1,
                      firstName: widget.profile['name']?.split(' ').first ?? 'Unknown',
                      lastName: widget.profile['name']?.split(' ').last ?? '',
                      fullName: widget.profile['name'] ?? 'Unknown',
                      email: '',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      avatarUrl: images.isNotEmpty ? images[_currentImageIndex % images.length] : null,
                      city: widget.profile['location'] ?? 'Chicago, IL',
                      profileBio: widget.profile['bio'] ?? 'No bio available.',
                      isVerified: true,
                      isOnline: true,
                    ),
                    onEditPressed: null, // No edit for other users' profiles
                  ),
                  const SizedBox(height: 24),

                  // Profile Information Sections
                  ProfileInfoSections(
                    user: User(
                      id: 1,
                      firstName: widget.profile['name']?.split(' ').first ?? 'Unknown',
                      lastName: widget.profile['name']?.split(' ').last ?? '',
                      fullName: widget.profile['name'] ?? 'Unknown',
                      email: '',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      profileBio: widget.profile['bio'] ?? 'No bio available.',
                      gender: 'Not specified',
                      sexualOrientation: 'Not specified',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Photo Gallery
                  if (images.isNotEmpty)
                    PhotoGallery(
                      images: images.map((image) => UserImage(
                        id: 1,
                        url: image.toString(),
                        type: 'gallery',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      )).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Safety & Verification Section
                  SafetyVerificationSection(
                    verification: UserVerification(
                      id: 1,
                      userId: 1,
                      photoVerified: true,
                      idVerified: false,
                      videoVerified: false,
                      verificationScore: 33,
                      totalVerifications: 3,
                      pendingVerifications: 2,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                    onVerifyPressed: null, // No verification for other users
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  ProfileActionButtons(
                    onLike: widget.onSwipeRight,
                    onSuperlike: widget.onSuperLike,
                    onDislike: widget.onSwipeLeft,
                    onReport: () {
                      // TODO: Show report dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report feature coming soon!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    onBlock: () {
                      // TODO: Show block confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Block feature coming soon!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    isOwnProfile: false,
                  ),
                  
                  const SizedBox(height: 96), // Space for action buttons
                ],
              ),
            ),
          ),
          
                     // Action buttons
           Container(
             padding: const EdgeInsets.all(24),
             decoration: BoxDecoration(
               color: AppColors.navbarBackground,
               boxShadow: [
                 BoxShadow(
                   color: Colors.black.withValues(alpha: 0.3),
                   blurRadius: 10,
                   offset: const Offset(0, -2),
                 ),
               ],
             ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                                 // Pass button
                 _buildSheetActionButton(
                   icon: Icons.close,
                   gradient: const LinearGradient(
                     colors: [AppColors.textSecondaryLight, AppColors.textSecondaryDark],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   onTap: widget.onSwipeLeft,
                 ),
                 
                 // Super like button
                 _buildSheetSuperLikeButton(),
                 
                 // Like button
                 _buildSheetActionButton(
                   icon: Icons.favorite,
                   gradient: const LinearGradient(
                     colors: [AppColors.errorLight, AppColors.errorDark],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   onTap: widget.onSwipeRight,
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetActionButton({
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
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

     Widget _buildSheetSuperLikeButton() {
     return GestureDetector(
       onTap: widget.onSuperLike,
       child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.superLikeGold, AppColors.warningLight, AppColors.lgbtOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const AppColors.superLikeGold.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.star,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
} 