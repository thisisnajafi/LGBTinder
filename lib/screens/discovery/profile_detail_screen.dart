import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../providers/matching_state_provider.dart';
import '../../services/sound_effects_service.dart';
import '../../services/analytics_service.dart';
import '../../components/loading/loading_widgets.dart';

class ProfileDetailScreen extends StatefulWidget {
  final User? user;
  final String? userId;

  const ProfileDetailScreen({
    Key? key,
    this.user,
    this.userId,
  }) : super(key: key);

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late PageController _photoPageController;
  int _currentPhotoIndex = 0;
  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _photoPageController = PageController();
    _user = widget.user;
    
    if (_user == null && widget.userId != null) {
      _loadUserProfile();
    }
  }

  @override
  void dispose() {
    _photoPageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    // TODO: Implement profile loading by ID
    // This would call ProfileApiService.getUserProfile(userId)
    setState(() {
      _isLoading = true;
    });
    
    // Simulated delay
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  void _onPhotoPageChanged(int index) {
    setState(() {
      _currentPhotoIndex = index;
    });
  }

  Future<void> _handleLike() async {
    if (_user == null) return;
    
    SoundEffectsService().playSwipeRightSound();
    
    await AnalyticsService.trackEvent(
      name: 'profile_detail_like',
      parameters: {
        'action': 'like',
        'target_user_id': _user!.id,
        'source': 'profile_detail',
      },
    );

    final matchingProvider = context.read<MatchingStateProvider>();
    final isMatch = await matchingProvider.likeUser(_user!.id);
    
    if (isMatch) {
      _showMatchDialog();
    } else {
      Navigator.pop(context, 'liked');
    }
  }

  Future<void> _handleSuperLike() async {
    if (_user == null) return;
    
    SoundEffectsService().playSuperLikeSound();
    
    await AnalyticsService.trackEvent(
      name: 'profile_detail_superlike',
      parameters: {
        'action': 'superlike',
        'target_user_id': _user!.id,
        'source': 'profile_detail',
      },
    );

    final matchingProvider = context.read<MatchingStateProvider>();
    final isMatch = await matchingProvider.superLikeUser(_user!.id);
    
    if (isMatch) {
      _showMatchDialog();
    } else {
      Navigator.pop(context, 'superliked');
    }
  }

  Future<void> _handleDislike() async {
    if (_user == null) return;
    
    SoundEffectsService().playSwipeLeftSound();
    
    await AnalyticsService.trackEvent(
      name: 'profile_detail_dislike',
      parameters: {
        'action': 'dislike',
        'target_user_id': _user!.id,
        'source': 'profile_detail',
      },
    );

    final matchingProvider = context.read<MatchingStateProvider>();
    await matchingProvider.dislikeUser(_user!.id);
    
    Navigator.pop(context, 'disliked');
  }

  void _handleReport() {
    // TODO: Open report dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: const Text('Report functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleBlock() {
    // TODO: Open block confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${_user?.firstName ?? "this user"}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, 'blocked');
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showMatchDialog() {
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
        content: Text(
          'You and ${_user?.firstName ?? "someone special"} liked each other!',
          style: AppTypography.body1.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, 'matched');
                  // TODO: Navigate to chat
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Send Message'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, 'matched');
                },
                child: Text('Keep Swiping'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: const CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            'User not found',
            style: AppTypography.heading3.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Photo carousel
          _buildPhotoCarousel(),
          
          // Gradient overlay for readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // More options button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
              onPressed: () => _showOptionsMenu(),
            ),
          ),
          
          // Photo indicators
          if (_getPhotoUrls().length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 0,
              right: 0,
              child: _buildPhotoIndicators(),
            ),
          
          // Profile info section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildProfileInfo(),
          ),
        ],
      ),
      // Action buttons
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildPhotoCarousel() {
    final photos = _getPhotoUrls();
    
    if (photos.isEmpty) {
      return Container(
        color: AppColors.navbarBackground,
        child: Center(
          child: Icon(
            Icons.person,
            size: 120,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTapUp: (details) {
        // Tap right side to go next, left side to go previous
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx > screenWidth / 2) {
          if (_currentPhotoIndex < photos.length - 1) {
            _photoPageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          if (_currentPhotoIndex > 0) {
            _photoPageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      child: PageView.builder(
        controller: _photoPageController,
        onPageChanged: _onPhotoPageChanged,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Image.network(
            photos[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.navbarBackground,
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 120,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPhotoIndicators() {
    final photos = _getPhotoUrls();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(photos.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: index == _currentPhotoIndex
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.8),
          ],
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                // Name and age
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_user!.fullName}, ${_user!.age}',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_user!.isVerified ?? false)
                      Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 24,
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Location
                if (_user!.location != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _user!.location!,
                        style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 24),
                
                // Bio
                if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                  _buildSection('About', _user!.bio!),
                  const SizedBox(height: 24),
                ],
                
                // Interests
                if (_user!.interests.isNotEmpty) ...[
                  _buildChipSection('Interests', _user!.interests.map((i) => i.name ?? i.toString()).toList()),
                  const SizedBox(height: 24),
                ],
                
                // Languages
                if (_user!.languages.isNotEmpty) ...[
                  _buildChipSection('Languages', _user!.languages.map((l) => l.name ?? l.toString()).toList()),
                  const SizedBox(height: 24),
                ],
                
                // Relationship goals
                if (_user!.relationshipGoals.isNotEmpty) ...[
                  _buildChipSection('Looking for', _user!.relationshipGoals),
                  const SizedBox(height: 24),
                ],
                
                // Basic info
                _buildBasicInfo(),
                
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildChipSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Chip(
            label: Text(item),
            backgroundColor: AppColors.primary.withOpacity(0.2),
            labelStyle: AppTypography.body2.copyWith(color: AppColors.primary),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    final info = <MapEntry<String, String>>[];
    
    if (_user!.job != null && _user!.job!.isNotEmpty) {
      info.add(MapEntry('Job', _user!.job!));
    }
    if (_user!.education != null && _user!.education!.isNotEmpty) {
      info.add(MapEntry('Education', _user!.education!.join(', ')));
    }
    if (_user!.height != null) {
      info.add(MapEntry('Height', '${_user!.height} cm'));
    }
    
    if (info.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Info',
          style: AppTypography.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...info.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                '${entry.key}: ',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                entry.value,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Dislike button
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            size: 60,
            onTap: _handleDislike,
          ),
          
          // Superlike button
          _buildActionButton(
            icon: Icons.star,
            color: AppColors.accent,
            size: 70,
            onTap: _handleSuperLike,
          ),
          
          // Like button
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.green,
            size: 60,
            onTap: _handleLike,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                _handleReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block'),
              onTap: () {
                Navigator.pop(context);
                _handleBlock();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: AppColors.textSecondary),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getPhotoUrls() {
    final urls = <String>[];
    
    // Add avatar if available
    if (_user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty) {
      urls.add(_user!.avatarUrl!);
    }
    
    // Add other images if available
    if (_user?.images != null) {
      for (final image in _user!.images!) {
        if (image.url.isNotEmpty && !urls.contains(image.url)) {
          urls.add(image.url);
        }
      }
    }
    
    return urls;
  }
}

