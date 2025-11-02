import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/user.dart';
import '../components/stories/stories_header.dart';
import '../components/feed/feed_post_card.dart';
import '../services/feeds_service.dart';
import '../providers/auth_provider.dart';
import '../utils/api_error_handler.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Map<String, dynamic>> _feedPosts = [];
  List<User> _usersWithStories = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMorePosts = true;

  @override
  void initState() {
    super.initState();
    _loadFeedData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _loadFeedData() async {
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

      // Load feed posts and stories in parallel
      final results = await Future.wait([
        FeedsService.getFeedPosts(
          accessToken: accessToken,
          page: 1,
          limit: 10,
        ),
        FeedsService.getUsersWithStories(
          accessToken: accessToken,
        ),
      ]);

      setState(() {
        _feedPosts = results[0] as List<Map<String, dynamic>>;
        _usersWithStories = results[1] as List<User>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load feed data';
      });

      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Unable to load feed. Please try again.',
        onRetry: _loadFeedData,
      );
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_hasMorePosts || _isLoading) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;

      if (accessToken == null) return;

      final nextPage = _currentPage + 1;
      final newPosts = await FeedsService.getFeedPosts(
        accessToken: accessToken,
        page: nextPage,
        limit: 10,
      );

      if (newPosts.isEmpty) {
        setState(() {
          _hasMorePosts = false;
        });
      } else {
        setState(() {
          _feedPosts.addAll(newPosts);
          _currentPage = nextPage;
        });
      }
    } catch (e) {
      print('Error loading more posts: $e');
    }
  }

  Future<void> _refreshFeed() async {
    setState(() {
      _currentPage = 1;
      _hasMorePosts = true;
    });
    await _loadFeedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFeed,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _feedPosts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null && _feedPosts.isEmpty) {
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
              onPressed: _loadFeedData,
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

    return RefreshIndicator(
      onRefresh: _refreshFeed,
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Stories header
          if (_usersWithStories.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: StoriesHeader(
                  usersWithStories: _usersWithStories,
                  onCreateStory: () {
                    Navigator.pushNamed(context, '/story-creation');
                  },
                ),
              ),
            ),

          // Feed posts
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < _feedPosts.length) {
                  return FeedPostCard(
                    post: _feedPosts[index],
                    onLike: () => _handlePostLike(index),
                    onComment: () => _handlePostComment(index),
                    onShare: () => _handlePostShare(index),
                    onUserTap: () => _handleUserTap(_feedPosts[index]),
                  );
                } else if (_hasMorePosts) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No more posts to load',
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ),
                  );
                }
              },
              childCount: _feedPosts.length + (_hasMorePosts ? 1 : 1),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePostLike(int index) {
    setState(() {
      final post = _feedPosts[index];
      final isLiked = post['is_liked'] ?? false;
      post['is_liked'] = !isLiked;
      post['likes_count'] = (post['likes_count'] ?? 0) + (isLiked ? -1 : 1);
    });

    // TODO: Send like request to API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_feedPosts[index]['is_liked'] ? 'Post liked!' : 'Post unliked!'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handlePostComment(int index) {
    // TODO: Navigate to comments screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comments feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handlePostShare(int index) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleUserTap(Map<String, dynamic> post) {
    // TODO: Navigate to user profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User profile coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
