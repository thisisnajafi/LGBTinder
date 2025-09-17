import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/user.dart';
import '../components/stories/stories_header.dart';

class StoryViewingScreen extends StatefulWidget {
  final List<User> usersWithStories;
  final int initialUserIndex;

  const StoryViewingScreen({
    Key? key,
    required this.usersWithStories,
    this.initialUserIndex = 0,
  }) : super(key: key);

  @override
  State<StoryViewingScreen> createState() => _StoryViewingScreenState();
}

class _StoryViewingScreenState extends State<StoryViewingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;
  Timer? _storyTimer;
  bool _isPaused = false;
  
  // Mock story data - in real app, this would come from API
  final List<List<StoryPreview>> _userStories = [];

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _pageController = PageController(initialPage: _currentUserIndex);
    _progressController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_progressController);
    
    _initializeStories();
    _startStoryTimer();
  }

  void _initializeStories() {
    // Mock data - in real app, this would be fetched from API
    for (int i = 0; i < widget.usersWithStories.length; i++) {
      final user = widget.usersWithStories[i];
      _userStories.add([
        StoryPreview(
          id: '${user.id}_story_1',
          userId: user.id.toString(),
          userName: user.firstName,
          userAvatarUrl: user.avatarUrl,
          content: 'Just had an amazing day exploring the city! 🌆',
          type: StoryType.text,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        StoryPreview(
          id: '${user.id}_story_2',
          userId: user.id.toString(),
          userName: user.firstName,
          userAvatarUrl: user.avatarUrl,
          content: 'Beautiful sunset from my balcony 🌅',
          type: StoryType.image,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ]);
    }
  }

  void _startStoryTimer() {
    _storyTimer?.cancel();
    _progressController.reset();
    _progressController.forward();
    
    _storyTimer = Timer(const Duration(seconds: 5), () {
      _nextStory();
    });
  }

  void _nextStory() {
    if (_currentStoryIndex < _userStories[_currentUserIndex].length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _startStoryTimer();
    } else {
      _nextUser();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _startStoryTimer();
    } else {
      _previousUser();
    }
  }

  void _nextUser() {
    if (_currentUserIndex < widget.usersWithStories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousUser() {
    if (_currentUserIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _pauseStory() {
    setState(() {
      _isPaused = true;
    });
    _storyTimer?.cancel();
    _progressController.stop();
  }

  void _resumeStory() {
    setState(() {
      _isPaused = false;
    });
    _progressController.forward();
    _storyTimer = Timer(
      Duration(milliseconds: (5000 * (1 - _progressController.value)).round()),
      _nextStory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentUserIndex = index;
            _currentStoryIndex = 0;
          });
          _startStoryTimer();
        },
        itemCount: widget.usersWithStories.length,
        itemBuilder: (context, index) {
          return _buildUserStoryPage(index);
        },
      ),
    );
  }

  Widget _buildUserStoryPage(int userIndex) {
    final user = widget.usersWithStories[userIndex];
    final stories = _userStories[userIndex];
    
    if (stories.isEmpty) {
      return _buildEmptyStoryPage(user);
    }

    return Stack(
      children: [
        // Story content
        _buildStoryContent(stories[_currentStoryIndex]),
        
        // Progress indicators
        _buildProgressIndicators(stories.length),
        
        // User info header
        _buildUserHeader(user),
        
        // Story controls
        _buildStoryControls(),
        
        // Tap areas for navigation
        _buildTapAreas(),
      ],
    );
  }

  Widget _buildStoryContent(StoryPreview story) {
    switch (story.type) {
      case StoryType.text:
        return _buildTextStory(story);
      case StoryType.image:
        return _buildImageStory(story);
      case StoryType.video:
        return _buildVideoStory(story);
    }
  }

  Widget _buildTextStory(StoryPreview story) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondaryLight,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            story.content,
            style: AppTypography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildImageStory(StoryPreview story) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(story.content), // In real app, this would be image URL
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoStory(StoryPreview story) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Center(
        child: Icon(
          Icons.play_circle_outline,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProgressIndicators(int storyCount) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        children: List.generate(storyCount, (index) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < storyCount - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: index == _currentStoryIndex
                  ? AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          width: MediaQuery.of(context).size.width * _progressAnimation.value / storyCount,
                        );
                      },
                    )
                  : index < _currentStoryIndex
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Positioned(
      top: 70,
      left: 16,
      right: 16,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.firstName,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTimeAgo(_userStories[_currentUserIndex][_currentStoryIndex].createdAt),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showStoryOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryControls() {
    return Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _isPaused ? _resumeStory : _pauseStory,
          ),
          IconButton(
            icon: const Icon(Icons.reply, color: Colors.white, size: 32),
            onPressed: _replyToStory,
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white, size: 32),
            onPressed: _likeStory,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 32),
            onPressed: _shareStory,
          ),
        ],
      ),
    );
  }

  Widget _buildTapAreas() {
    return Row(
      children: [
        // Left tap area (previous story/user)
        Expanded(
          child: GestureDetector(
            onTap: _previousStory,
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
            ),
          ),
        ),
        // Right tap area (next story/user)
        Expanded(
          child: GestureDetector(
            onTap: _nextStory,
            child: Container(
              color: Colors.transparent,
              height: double.infinity,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStoryPage(User user) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.navbarBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.firstName,
              style: AppTypography.h2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No stories yet',
              style: AppTypography.body1.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showStoryOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _blockUser();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report Story', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _reportStory();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _replyToStory() {
    // Implement reply functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reply feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _likeStory() {
    // Implement like functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story liked!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _shareStory() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _blockUser() {
    // Implement block functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User blocked'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _reportStory() {
    // Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story reported'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}
