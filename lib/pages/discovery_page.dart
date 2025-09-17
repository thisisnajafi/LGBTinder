import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/user.dart';
import '../components/profile_cards/swipeable_profile_card.dart';
import '../services/matching_service.dart';
import '../services/haptic_feedback_service.dart';
import '../services/pull_to_refresh_service.dart';
import '../services/skeleton_loader_service.dart';
import '../providers/auth_provider.dart';
import '../utils/api_error_handler.dart';

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
  String? _errorMessage;
  
  // Swipe directions
  double _dragStartX = 0;
  double _dragStartY = 0;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPotentialMatches();
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
      _errorMessage = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) {
        throw Exception('No access token available');
      }
      
      // Load potential matches from API
      final matches = await MatchingService.getPotentialMatches(
        accessToken: accessToken,
        limit: 10,
      );
      
      setState(() {
        _potentialMatches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load potential matches';
      });
      
      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Unable to load potential matches. Please try again.',
        onRetry: _loadPotentialMatches,
      );
    }
  }
  
  void _handleSwipe(SwipeDirection direction) {
    if (_currentIndex >= _potentialMatches.length) return;
    
    final currentUser = _potentialMatches[_currentIndex];
    final hapticService = HapticFeedbackService();
    
    switch (direction) {
      case SwipeDirection.left:
        hapticService.swipeLeft();
        _handleDislike(currentUser);
        break;
      case SwipeDirection.right:
        hapticService.swipeRight();
        _handleLike(currentUser);
        break;
      case SwipeDirection.up:
        hapticService.swipeUp();
        _handleSuperLike(currentUser);
        break;
      case SwipeDirection.down:
        hapticService.swipeDown();
        _showProfileDetails(currentUser);
        break;
    }
    
    _moveToNextCard();
  }
  
  Future<void> _handleLike(User user) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) return;
      
      await MatchingService.likeUser(
        userId: user.id.toString(),
        accessToken: accessToken,
      );
      
      // Haptic feedback for successful like
      await HapticFeedbackService().like();
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You liked ${user.firstName}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Haptic feedback for error
      await HapticFeedbackService().error();
      
      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Failed to like user. Please try again.',
      );
    }
  }
  
  Future<void> _handleDislike(User user) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) return;
      
      await MatchingService.dislikeUser(
        userId: user.id.toString(),
        accessToken: accessToken,
      );
      
      // No feedback needed for dislikes
    } catch (e) {
      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Failed to dislike user. Please try again.',
      );
    }
  }
  
  Future<void> _handleSuperLike(User user) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;
      
      if (accessToken == null) return;
      
      await MatchingService.superLikeUser(
        userId: user.id.toString(),
        accessToken: accessToken,
      );
      
      // Haptic feedback for successful super like
      await HapticFeedbackService().superLike();
      
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You super liked ${user.firstName}! ⭐'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Haptic feedback for error
      await HapticFeedbackService().error();
      
      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Failed to super like user. Please try again.',
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
          decoration: const BoxDecoration(
            color: AppColors.navbarBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Profile details content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: AppTypography.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (user.profileBio != null) ...[
                        Text(
                          user.profileBio!,
                          style: AppTypography.body1.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Add more profile details here
                      _buildProfileSection('Age', '${_calculateAge(user.birthDate)}'),
                      _buildProfileSection('Location', user.location ?? 'Not specified'),
                      _buildProfileSection('Job', user.job ?? 'Not specified'),
                      if (user.interests.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Interests',
                          style: AppTypography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests.take(5).map((interest) =>
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                interest.name,
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ).toList(),
                        ),
                      ],
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
  
  Widget _buildProfileSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body2.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
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
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPotentialMatches,
          ),
        ],
      ),
      body: PullToRefreshService().createRefreshIndicator(
        onRefresh: _loadPotentialMatches,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonLoaderService().createSkeletonProfileCard(
            width: 300,
            height: 400,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkeletonLoaderService().createSkeletonBox(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(30),
              ),
              const SizedBox(width: 20),
              SkeletonLoaderService().createSkeletonBox(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(30),
              ),
              const SizedBox(width: 20),
              SkeletonLoaderService().createSkeletonBox(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.circular(30),
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
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTypography.body1.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPotentialMatches,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
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
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No more matches',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new potential matches!',
              style: AppTypography.body1.copyWith(
                color: Colors.white70,
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
        
        // Action buttons
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: _buildActionButtons(),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Dislike button
        _buildActionButton(
          icon: Icons.close,
          color: Colors.red,
          onTap: () => _handleSwipe(SwipeDirection.left),
        ),
        
        // Super like button
        _buildActionButton(
          icon: Icons.star,
          color: Colors.blue,
          onTap: () => _handleSwipe(SwipeDirection.up),
        ),
        
        // Like button
        _buildActionButton(
          icon: Icons.favorite,
          color: Colors.green,
          onTap: () => _handleSwipe(SwipeDirection.right),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 2,
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
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

enum SwipeDirection {
  left,
  right,
  up,
  down,
}
