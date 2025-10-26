import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/community_forum_service.dart';

/// Community Forum Screen
/// Displays the LGBTinder community forum using WebView
class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({Key? key}) : super(key: key);

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  final CommunityForumService _forumService = CommunityForumService();
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _checkForumAvailability();
  }

  Future<void> _checkForumAvailability() async {
    final isAvailable = await _forumService.checkForumAvailability();
    setState(() {
      _isLoading = false;
    });

    if (!isAvailable && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Community forum is currently unavailable'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _openCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Community Forum',
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _checkForumAvailability();
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'new_topic') {
                _showNewTopicDialog();
              } else if (value == 'categories') {
                _showCategoriesSheet();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_topic',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text('New Topic'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category, size: 20),
                    SizedBox(width: 8),
                    Text('Categories'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _forumService.isConfigured
              ? _buildForumView()
              : _buildPlaceholder(),
    );
  }

  Widget _buildForumView() {
    return _forumService.buildForumWebView();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Community Forum',
              style: AppTypography.h2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connect with other LGBTQ+ individuals, share stories, get advice, and build friendships!',
              style: AppTypography.body1.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildCategoryGrid(),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _showNewTopicDialog,
              icon: const Icon(Icons.add),
              label: const Text('Start a Discussion'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary, width: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Forum coming soon!',
              style: AppTypography.body2.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      _CategoryItem(
        icon: Icons.waving_hand,
        title: 'Introductions',
        subtitle: 'Say hello!',
        color: Colors.blue,
      ),
      _CategoryItem(
        icon: Icons.favorite,
        title: 'Dating Advice',
        subtitle: 'Get help',
        color: Colors.pink,
      ),
      _CategoryItem(
        icon: Icons.celebration,
        title: 'Success Stories',
        subtitle: 'Share joy',
        color: Colors.green,
      ),
      _CategoryItem(
        icon: Icons.event,
        title: 'Events',
        subtitle: 'Meetups',
        color: Colors.orange,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: categories
          .map((category) => _buildCategoryCard(category))
          .toList(),
    );
  }

  Widget _buildCategoryCard(_CategoryItem category) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color.withOpacity(0.7),
            category.color.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${category.title} - Coming Soon!'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  category.title,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  category.subtitle,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNewTopicDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'New Discussion',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Forum is coming soon! You\'ll be able to start discussions, share stories, and connect with the community.',
              style: AppTypography.body1.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: AppTypography.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoriesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forum Categories',
              style: AppTypography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildCategoryListItem(Icons.forum, 'General Discussion'),
            _buildCategoryListItem(Icons.waving_hand, 'Introductions'),
            _buildCategoryListItem(Icons.favorite, 'Dating Advice'),
            _buildCategoryListItem(Icons.celebration, 'Success Stories'),
            _buildCategoryListItem(Icons.feedback, 'Feedback'),
            _buildCategoryListItem(Icons.help, 'Support'),
            _buildCategoryListItem(Icons.event, 'Events'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryListItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTypography.body1.copyWith(color: Colors.white),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title - Coming Soon!')),
        );
      },
    );
  }
}

class _CategoryItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _CategoryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

