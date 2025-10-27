import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/user.dart';
import '../models/discovery_filters.dart';
import '../components/profile_cards/swipeable_profile_card.dart';
import '../components/error_handling/error_display_widget.dart';
import '../components/loading/loading_widgets.dart';
import '../components/loading/skeleton_loader.dart';
import '../components/offline/offline_wrapper.dart';
import '../components/real_time/real_time_listener.dart';
import '../providers/matching_state_provider.dart';
import '../services/analytics_service.dart';
import '../services/error_monitoring_service.dart';
import '../services/sound_effects_service.dart';
import '../services/match_sharing_service.dart';
import '../services/cache_service.dart';
import '../screens/discovery/filter_screen.dart';
import '../screens/discovery/search_screen.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  List<User> _potentialMatches = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  dynamic _error;
  DiscoveryFilters _filters = DiscoveryFilters.defaultFilters;
  
  // Swipe directions
  double _dragStartX = 0;
  double _dragStartY = 0;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedFilters();
    _loadPotentialMatches();
  }
  
  Future<void> _loadSavedFilters() async {
    final savedFilters = await CacheService.getData('discovery_filters');
    if (savedFilters != null && savedFilters is Map<String, dynamic>) {
      setState(() {
        _filters = DiscoveryFilters.fromJson(savedFilters);
      });
    }
  }
  
  void _openFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          initialFilters: _filters,
          onApply: (newFilters) {
            setState(() {
              _filters = newFilters;
            });
            _loadPotentialMatches();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  Future<void> _loadPotentialMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await AnalyticsService.trackEvent(
        name: 'discovery_load_matches',
        parameters: {'action': 'discovery_load_matches', 'category': 'matching'},
      );

      final matchingProvider = context.read<MatchingStateProvider>();
      await matchingProvider.loadPotentialMatches(
        filters: _filters.toApiParams(),
      );
      
      setState(() {
        _potentialMatches = matchingProvider.potentialMatches;
        _isLoading = false;
      });
    } catch (e) {
      await AnalyticsService.trackEvent(
        name: 'discovery_load_matches_failed',
        parameters: {'action': 'discovery_load_matches_failed', 'category': 'matching'},
      );

      await ErrorMonitoringService.logError(
        message: 'Failed to load discovery matches',
        errorType: 'API_ERROR',
        stackTrace: StackTrace.current,
        context: {'context': 'DiscoveryPage._loadPotentialMatches'},
      );

      setState(() {
        _isLoading = false;
        _error = e;
      });
    }
  }
  
  void _handleSwipe(SwipeDirection direction) {
    if (_currentIndex >= _potentialMatches.length) return;
    
    final currentUser = _potentialMatches[_currentIndex];
    
    switch (direction) {
      case SwipeDirection.left:
        _handleDislike(currentUser);
        break;
      case SwipeDirection.right:
        _handleLike(currentUser);
        break;
      case SwipeDirection.up:
        _handleSuperLike(currentUser);
        break;
      case SwipeDirection.down:
        _showProfileDetails(currentUser);
        break;
    }
    
    _moveToNextCard();
  }
  
  Future<void> _handleLike(User user) async {
    try {
      // Play swipe right sound
      SoundEffectsService().playSwipeRightSound();
      
      await AnalyticsService.trackEvent(
        name: 'user_like',
        parameters: {'action': 'user_like', 'category': 'matching', 'target_user_id': user.id},
      );

      final matchingProvider = context.read<MatchingStateProvider>();
      final result = await matchingProvider.likeUser(user.id);
      
      if (result) { // result is boolean indicating if match occurred
        _showMatchDialog(user);
      }
    } catch (e) {
      await AnalyticsService.trackEvent(
        name: 'user_like_failed',
        parameters: {'action': 'user_like_failed', 'category': 'matching'},
      );

      await ErrorMonitoringService.logError(
        message: 'Failed to like user',
        errorType: 'API_ERROR',
        stackTrace: StackTrace.current,
        context: {'context': 'DiscoveryPage._handleLike'},
      );
    }
  }
  
  Future<void> _handleDislike(User user) async {
    try {
      // Play swipe left sound
      SoundEffectsService().playSwipeLeftSound();
      
      await AnalyticsService.trackEvent(
        name: 'user_dislike',
        parameters: {'action': 'user_dislike', 'category': 'matching', 'target_user_id': user.id},
      );

      final matchingProvider = context.read<MatchingStateProvider>();
      await matchingProvider.dislikeUser(user.id);
    } catch (e) {
      await AnalyticsService.trackEvent(
        name: 'user_dislike_failed',
        parameters: {'action': 'user_dislike_failed', 'category': 'matching'},
      );

      await ErrorMonitoringService.logError(
        message: 'Failed to dislike user',
        errorType: 'API_ERROR',
        stackTrace: StackTrace.current,
        context: {'context': 'DiscoveryPage._handleDislike'},
      );
    }
  }

  Future<void> _handleSuperLike(User user) async {
    try {
      // Play super like sound
      SoundEffectsService().playSuperLikeSound();
      
      await AnalyticsService.trackEvent(
        name: 'user_super_like',
        parameters: {'action': 'user_super_like', 'category': 'matching', 'target_user_id': user.id},
      );

      final matchingProvider = context.read<MatchingStateProvider>();
      final result = await matchingProvider.superLikeUser(user.id);
      
      if (result) { // result is boolean indicating if match occurred
        _showMatchDialog(user);
      }
    } catch (e) {
      await AnalyticsService.trackEvent(
        name: 'user_super_like_failed',
        parameters: {'action': 'user_super_like_failed', 'category': 'matching'},
      );

      await ErrorMonitoringService.logError(
        message: 'Failed to super like user',
        errorType: 'API_ERROR',
        stackTrace: StackTrace.current,
        context: {'context': 'DiscoveryPage._handleSuperLike'},
      );
    }
  }

  void _showProfileDetails(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.textSecondary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: AppTypography.heading2.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${user.age} years old',
                            style: AppTypography.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (user.location != null)
                            Text(
                              user.location!,
                              style: AppTypography.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bio Section
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        _buildProfileSection(
                          'About ${user.firstName}',
                          user.bio!,
                          Icons.info_outline,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Basic Info Section
                      _buildProfileSection(
                        'Basic Info',
                        _buildBasicInfo(user),
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 24),
                      
                      // Interests Section
                      if (user.interests.isNotEmpty) ...[
                        _buildProfileSection(
                          'Interests',
                          user.interests.join(', '),
                          Icons.favorite_outline,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Music Genres Section
                      if (user.musicGenres.isNotEmpty) ...[
                        _buildProfileSection(
                          'Music Genres',
                          user.musicGenres.join(', '),
                          Icons.music_note_outlined,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Languages Section
                      if (user.languages.isNotEmpty) ...[
                        _buildProfileSection(
                          'Languages',
                          user.languages.join(', '),
                          Icons.language_outlined,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Relationship Goals Section
                      if (user.relationshipGoals.isNotEmpty) ...[
                        _buildProfileSection(
                          'Relationship Goals',
                          user.relationshipGoals.join(', '),
                          Icons.favorite_border,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Photos Section
                      if (user.avatarUrl != null) ...[
                        _buildPhotosSection(user),
                        const SizedBox(height: 24),
                      ],
                      
                      // Action Buttons
                      _buildActionButtons(user),
                      const SizedBox(height: 32),
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

  Widget _buildProfileSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.navbarBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _buildBasicInfo(User user) {
    final info = <String>[];
    
    if (user.job != null && user.job!.isNotEmpty) {
      info.add('Job: ${user.job}');
    }
    
    if (user.education != null && user.education!.isNotEmpty) {
      info.add('Education: ${user.education}');
    }
    
    if (user.height != null) {
      info.add('Height: ${user.height} cm');
    }
    
    if (user.weight != null) {
      info.add('Weight: ${user.weight} kg');
    }
    
    if (user.gender != null && user.gender!.isNotEmpty) {
      info.add('Gender: ${user.gender}');
    }
    
    if (info.isEmpty) {
      return 'No additional information available';
    }
    
    return info.join('\n');
  }

  Widget _buildPhotosSection(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Photos',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: user.avatarUrl != null ? 1 : 0,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    user.avatarUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: AppColors.navbarBackground,
                        child: Icon(
                          Icons.person,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(User user) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _likeUser(user);
            },
            icon: const Icon(Icons.favorite),
            label: const Text('Like'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _superLikeUser(user);
            },
            icon: const Icon(Icons.star),
            label: const Text('Super Like'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showMatchDialog(User user) {
    // Play match celebration sound
    SoundEffectsService().playMatchSound();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              'It\'s a Match!',
              style: AppTypography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You and ${user.firstName ?? user.name ?? "someone special"} liked each other!',
              style: AppTypography.body1.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Current user avatar placeholder
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(width: 20),
                Icon(Icons.favorite, color: Colors.red, size: 32),
                SizedBox(width: 20),
                // Matched user avatar
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.images?.isNotEmpty == true
                      ? NetworkImage(user.images!.first.url)
                      : null,
                  backgroundColor: AppColors.secondary,
                  child: user.images?.isEmpty ?? true
                      ? Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Share button
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await MatchSharingService.shareMatchText(
                      matchedUser: user,
                    );
                    
                    await AnalyticsService.trackEvent(
                      name: 'match_shared',
                      parameters: {
                        'action': 'match_shared',
                        'category': 'social',
                        'matched_user_id': user.id,
                      },
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to share: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.share, color: AppColors.primary),
                label: Text(
                  'Share',
                  style: AppTypography.button.copyWith(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              SizedBox(height: 8),
              
              // Send Message button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to chat with user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening chat with ${user.firstName ?? "match"}...'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: Icon(Icons.message, color: Colors.white),
                label: Text(
                  'Send Message',
                  style: AppTypography.button.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              SizedBox(height: 8),
              
              // Keep Swiping button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Keep Swiping',
                  style: AppTypography.body1.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _moveToNextCard() {
    setState(() {
      _currentIndex++;
    });
    
    // Load more matches if we're running low
    if (_currentIndex >= _potentialMatches.length - 2) {
      _loadPotentialMatches();
    }
  }
  
  void _onPanStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
    _dragStartY = details.globalPosition.dy;
    _isDragging = true;
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final deltaX = details.globalPosition.dx - _dragStartX;
    final deltaY = details.globalPosition.dy - _dragStartY;
    
    // Calculate swipe direction based on movement
    if (deltaX.abs() > deltaY.abs()) {
      // Horizontal swipe
      if (deltaX > 50) {
        // Right swipe (like)
        _animationController.forward();
      } else if (deltaX < -50) {
        // Left swipe (dislike)
        _animationController.forward();
      }
    } else {
      // Vertical swipe
      if (deltaY < -50) {
        // Up swipe (super like)
        _animationController.forward();
      }
    }
  }
  
  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    final deltaX = details.velocity.pixelsPerSecond.dx;
    final deltaY = details.velocity.pixelsPerSecond.dy;
    
    if (deltaX.abs() > deltaY.abs()) {
      // Horizontal swipe
      if (deltaX > 500) {
        _handleSwipe(SwipeDirection.right);
      } else if (deltaX < -500) {
        _handleSwipe(SwipeDirection.left);
      }
    } else {
      // Vertical swipe
      if (deltaY < -500) {
        _handleSwipe(SwipeDirection.up);
      } else if (deltaY > 500) {
        _handleSwipe(SwipeDirection.down);
      }
    }
    
    _animationController.reverse();
    _isDragging = false;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Discover',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          // Search button
          IconButton(
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          // Filter button with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.tune,
                  color: AppColors.textPrimary,
                ),
                onPressed: _openFilters,
              ),
              if (_filters.activeFilterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_filters.activeFilterCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppColors.textPrimary,
            ),
            onPressed: _loadPotentialMatches,
          ),
        ],
      ),
      body: OfflineWrapper(
        child: RealTimeListener(
          eventTypes: ['match', 'like'],
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonLoaderService.createSkeletonProfileCard(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonLoaderService.createSkeletonBox(
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 20),
              SkeletonLoaderService.createSkeletonBox(
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 20),
              SkeletonLoaderService.createSkeletonBox(
                width: 60,
                height: 60,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }
    
    if (_error != null) {
      return ErrorDisplayWidget(
        error: _error,
        context: 'load_potential_matches',
        onRetry: _loadPotentialMatches,
        isFullScreen: true,
      );
    }
    
    if (_potentialMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No more matches',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new potential matches!',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPotentialMatches,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        // Background cards
        if (_currentIndex + 1 < _potentialMatches.length)
          Positioned.fill(
            child: Transform.scale(
              scale: 0.95,
              child: SwipeableProfileCard(
                user: _potentialMatches[_currentIndex + 1],
                onSwipe: _handleSwipe,
              ),
            ),
          ),
        
        // Current card
        if (_currentIndex < _potentialMatches.length)
          Positioned.fill(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: SwipeableProfileCard(
                        user: _potentialMatches[_currentIndex],
                        onSwipe: _handleSwipe,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        
        // Action buttons removed from skeleton loading state
      ],
    );
  }

  void _likeUser(User user) {
    _handleLike(user);
    _moveToNextCard();
  }

  void _superLikeUser(User user) {
    _handleSuperLike(user);
    _moveToNextCard();
  }
  
}

enum SwipeDirection {
  left,
  right,
  up,
  down,
}
