import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/gamification_service.dart';
import '../services/haptic_feedback_service.dart';
import '../components/gamification/gamification_components.dart';
import '../components/buttons/animated_button.dart';

class ProfileCompletionIncentivesScreen extends StatefulWidget {
  const ProfileCompletionIncentivesScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionIncentivesScreen> createState() => _ProfileCompletionIncentivesScreenState();
}

class _ProfileCompletionIncentivesScreenState extends State<ProfileCompletionIncentivesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  ProfileCompletionProgress? _progress;
  List<Achievement> _achievements = [];
  List<Badge> _badges = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGamificationData();
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadGamificationData() async {
    try {
      final progress = await GamificationService.instance.getProfileCompletionProgress();
      final achievements = await GamificationService.instance.getUserAchievements();
      final badges = await GamificationService.instance.getUserBadges();
      final stats = await GamificationService.instance.getGamificationStats();
      
      if (mounted) {
        setState(() {
          _progress = progress;
          _achievements = achievements;
          _badges = badges;
          _stats = stats;
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
          'Complete Your Profile',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: AppColors.textPrimaryDark),
            onPressed: _showAchievementsDashboard,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (_progress != null) _buildProgressSection(),
                    const SizedBox(height: 24),
                    _buildIncentivesSection(),
                    const SizedBox(height: 24),
                    _buildQuickActionsSection(),
                    const SizedBox(height: 24),
                    _buildRecentAchievements(),
                    const SizedBox(height: 24),
                    _buildBadgesPreview(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            AppColors.feedbackSuccess.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Earn points, unlock achievements, and get more matches!',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return ProfileCompletionProgressCard(
      progress: _progress!,
      onTap: () {
        HapticFeedbackService.selection();
        _showDetailedProgress();
      },
    );
  }

  Widget _buildIncentivesSection() {
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
            'Why Complete Your Profile?',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildIncentiveItem(
            Icons.favorite,
            'More Matches',
            'Complete profiles get 3x more matches',
            AppColors.feedbackError,
          ),
          const SizedBox(height: 12),
          _buildIncentiveItem(
            Icons.visibility,
            'Better Visibility',
            'Appear higher in discovery results',
            AppColors.feedbackInfo,
          ),
          const SizedBox(height: 12),
          _buildIncentiveItem(
            Icons.star,
            'Earn Rewards',
            'Unlock achievements and earn points',
            AppColors.feedbackWarning,
          ),
          const SizedBox(height: 12),
          _buildIncentiveItem(
            Icons.verified,
            'Build Trust',
            'Verified profiles get more responses',
            AppColors.feedbackSuccess,
          ),
        ],
      ),
    );
  }

  Widget _buildIncentiveItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
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
            'Quick Actions',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addPhotos,
                  icon: const Icon(Icons.photo_camera, size: 18),
                  label: const Text('Add Photos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _editBio,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Bio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackInfo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _addInterests,
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text('Add Interests'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackSuccess,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _verifyProfile,
                  icon: const Icon(Icons.verified, size: 18),
                  label: const Text('Verify'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackWarning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    final recentAchievements = _achievements.where((a) => a.isUnlocked).take(3).toList();
    
    if (recentAchievements.isEmpty) {
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
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: 12),
            Text(
              'No achievements yet',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete profile sections to unlock achievements!',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Achievements',
                style: AppTypography.subtitle1.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _showAchievementsDashboard,
                child: Text(
                  'View All',
                  style: AppTypography.button.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentAchievements.map((achievement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AchievementCard(
                achievement: achievement,
                onTap: () {
                  _showAchievementDetails(achievement);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBadgesPreview() {
    final earnedBadges = _badges.where((b) => b.isEarned).take(4).toList();
    
    if (earnedBadges.isEmpty) {
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
          children: [
            Icon(
              Icons.military_tech_outlined,
              size: 48,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: 12),
            Text(
              'No badges yet',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Earn badges by completing achievements!',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Badges',
                style: AppTypography.subtitle1.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _showBadgesDashboard,
                child: Text(
                  'View All',
                  style: AppTypography.button.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: earnedBadges.length,
            itemBuilder: (context, index) {
              return BadgeCard(
                badge: earnedBadges[index],
                onTap: () {
                  _showBadgeDetails(earnedBadges[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDetailedProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Profile Completion Details',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_progress != null) ...[
                Text(
                  'Completed Sections:',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._progress!.completedSections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.feedbackSuccess,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getSectionDisplayName(section),
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  'Remaining Sections:',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._progress!.remainingSections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          color: AppColors.textSecondaryDark,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getSectionDisplayName(section),
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementsDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GamificationDashboard(),
      ),
    );
  }

  void _showBadgesDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GamificationDashboard(),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          achievement.title,
          style: const TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: const TextStyle(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: AppColors.feedbackWarning, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${achievement.points} points',
                  style: const TextStyle(color: AppColors.feedbackWarning),
                ),
              ],
            ),
            if (achievement.reward != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.card_giftcard, color: AppColors.feedbackInfo, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Reward: ${achievement.reward}',
                    style: const TextStyle(color: AppColors.feedbackInfo),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(Badge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          badge.name,
          style: const TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(int.parse(badge.color)),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _getIconData(badge.icon),
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.description,
              style: const TextStyle(color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRarityColor(badge.rarity).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${badge.rarity.toUpperCase()} BADGE',
                style: TextStyle(
                  color: _getRarityColor(badge.rarity),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _addPhotos() {
    HapticFeedbackService.selection();
    // TODO: Navigate to photo upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo upload coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _editBio() {
    HapticFeedbackService.selection();
    // TODO: Navigate to bio editor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bio editor coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _addInterests() {
    HapticFeedbackService.selection();
    // TODO: Navigate to interests selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Interests selection coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _verifyProfile() {
    HapticFeedbackService.selection();
    // TODO: Navigate to verification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile verification coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  String _getSectionDisplayName(String section) {
    switch (section) {
      case 'photos':
        return 'Photos';
      case 'bio':
        return 'Bio';
      case 'interests':
        return 'Interests';
      case 'location':
        return 'Location';
      case 'age':
        return 'Age';
      case 'gender':
        return 'Gender';
      case 'preferences':
        return 'Preferences';
      case 'verification':
        return 'Verification';
      case 'social_links':
        return 'Social Links';
      case 'premium':
        return 'Premium';
      default:
        return section;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'verified':
        return Icons.verified;
      case 'diamond':
        return Icons.diamond;
      case 'new_releases':
        return Icons.new_releases;
      case 'check_circle':
        return Icons.check_circle;
      case 'photo_library':
        return Icons.photo_library;
      case 'chat':
        return Icons.chat;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return AppColors.textSecondaryDark;
      case 'rare':
        return AppColors.feedbackInfo;
      case 'epic':
        return AppColors.feedbackWarning;
      case 'legendary':
        return AppColors.feedbackError;
      default:
        return AppColors.textSecondaryDark;
    }
  }
}
