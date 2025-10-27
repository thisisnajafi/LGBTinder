import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/gamification_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../buttons/animated_button.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    Key? key,
    required this.achievement,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: achievement.isUnlocked 
              ? AppColors.feedbackSuccess.withOpacity(0.1)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.isUnlocked 
                ? AppColors.feedbackSuccess
                : AppColors.borderDefault,
            width: achievement.isUnlocked ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Achievement Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: achievement.isUnlocked 
                    ? AppColors.feedbackSuccess
                    : AppColors.textSecondaryDark,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getIconData(achievement.icon),
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Achievement Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: AppTypography.subtitle2.copyWith(
                            color: achievement.isUnlocked 
                                ? AppColors.textPrimaryDark
                                : AppColors.textSecondaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (achievement.isUnlocked)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.feedbackSuccess,
                          size: 20,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    achievement.description,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.feedbackWarning,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${achievement.points} pts',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.feedbackWarning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(achievement.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          achievement.category.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: _getCategoryColor(achievement.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (achievement.reward != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Reward: ${achievement.reward}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.feedbackInfo,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'photo_camera':
        return Icons.photo_camera;
      case 'collections':
        return Icons.collections;
      case 'edit':
        return Icons.edit;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'people':
        return Icons.people;
      case 'chat':
        return Icons.chat;
      case 'today':
        return Icons.today;
      case 'explore':
        return Icons.explore;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'profile':
        return AppColors.primaryLight;
      case 'social':
        return AppColors.feedbackSuccess;
      case 'activity':
        return AppColors.feedbackInfo;
      default:
        return AppColors.textSecondaryDark;
    }
  }
}

class GamificationBadgeCard extends StatelessWidget {
  final GamificationBadge badge;
  final VoidCallback? onTap;

  const GamificationBadgeCard({
    Key? key,
    required this.badge,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: badge.isEarned 
              ? Color(int.parse(badge.color)).withOpacity(0.1)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badge.isEarned 
                ? Color(int.parse(badge.color))
                : AppColors.borderDefault,
            width: badge.isEarned ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // GamificationBadge Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: badge.isEarned 
                    ? Color(int.parse(badge.color))
                    : AppColors.textSecondaryDark,
                borderRadius: BorderRadius.circular(32), // Keep 32 - standard value
                boxShadow: badge.isEarned ? [
                  BoxShadow(
                    color: Color(int.parse(badge.color)).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                _getIconData(badge.icon),
                color: Colors.white,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // GamificationBadge Name
            Text(
              badge.name,
              style: AppTypography.subtitle2.copyWith(
                color: badge.isEarned 
                    ? AppColors.textPrimaryDark
                    : AppColors.textSecondaryDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // GamificationBadge Description
            Text(
              badge.description,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Rarity GamificationBadge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRarityColor(badge.rarity).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge.rarity.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: _getRarityColor(badge.rarity),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            if (badge.isEarned) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: AppColors.feedbackSuccess,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
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

class ProfileCompletionProgressCard extends StatelessWidget {
  final ProfileCompletionProgress progress;
  final VoidCallback? onTap;

  const ProfileCompletionProgressCard({
    Key? key,
    required this.progress,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryLight.withOpacity(0.1),
              AppColors.feedbackInfo.withOpacity(0.05),
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
                Icon(
                  Icons.trending_up,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile Completion',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${progress.completionPercentage.round()}%',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress.completionPercentage / 100,
              backgroundColor: AppColors.surfaceSecondary,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
              minHeight: 8,
            ),
            
            const SizedBox(height: 12),
            
            // Progress Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.completedSteps}/${progress.totalSteps} sections',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                Text(
                  '${progress.earnedPoints}/${progress.totalPoints} points',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.feedbackWarning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Level and Experience
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.feedbackSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.feedbackSuccess,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Level ${progress.level}',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.feedbackSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Experience',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: progress.experiencePoints / progress.nextLevelExperience,
                        backgroundColor: AppColors.surfaceSecondary,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.feedbackSuccess),
                        minHeight: 4,
                      ),
                      Text(
                        '${progress.experiencePoints}/${progress.nextLevelExperience} XP',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.feedbackSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (progress.remainingSections.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Complete these sections to earn more points:',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: progress.remainingSections.map((section) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getSectionDisplayName(section),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
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
}

class GamificationDashboard extends StatefulWidget {
  const GamificationDashboard({Key? key}) : super(key: key);

  @override
  State<GamificationDashboard> createState() => _GamificationDashboardState();
}

class _GamificationDashboardState extends State<GamificationDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Achievement> _achievements = [];
  List<GamificationBadge> _badges = [];
  ProfileCompletionProgress? _progress;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGamificationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGamificationData() async {
    try {
      final achievements = await GamificationService.instance.getUserAchievements();
      final badges = await GamificationService.instance.getUserBadges();
      final progress = await GamificationService.instance.getProfileCompletionProgress();
      final stats = await GamificationService.instance.getGamificationStats();
      
      if (mounted) {
        setState(() {
          _achievements = achievements;
          _badges = badges;
          _progress = progress;
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        title: Text(
          'Achievements & Progress',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryDark,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Progress'),
            Tab(text: 'Achievements'),
            Tab(text: 'GamificationBadges'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgressTab(),
          _buildAchievementsTab(),
          _buildGamificationBadgesTab(),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_progress == null) return const Center(child: Text('No progress data'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ProfileCompletionProgressCard(
            progress: _progress!,
            onTap: () {
              // Show detailed progress
            },
          ),
          
          const SizedBox(height: 24),
          
          if (_stats != null) _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ..._achievements.map((achievement) {
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

  Widget _buildGamificationBadgesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _badges.length,
        itemBuilder: (context, index) {
          return GamificationBadgeCard(
            badge: _badges[index],
            onTap: () {
              _showGamificationBadgeDetails(_badges[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
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
            'Your Stats',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Level',
                  '${_stats!['level']}',
                  Icons.star,
                  AppColors.feedbackSuccess,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Achievements',
                  '${_stats!['unlockedAchievements']}/${_stats!['totalAchievements']}',
                  Icons.emoji_events,
                  AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'GamificationBadges',
                  '${_stats!['earnedGamificationBadges']}/${_stats!['totalGamificationBadges']}',
                  Icons.military_tech,
                  AppColors.feedbackWarning,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Points',
                  '${_stats!['earnedPoints']}',
                  Icons.stars,
                  AppColors.feedbackInfo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
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
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: AppColors.feedbackWarning, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${achievement.points} points',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.feedbackWarning),
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
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.feedbackInfo),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showGamificationBadgeDetails(GamificationBadge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          badge.name,
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(int.parse(badge.color)),
                borderRadius: BorderRadius.circular(40), // Keep 40 - standard value
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
              style: TextStyle(color: AppColors.textSecondaryDark),
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
                style: AppTypography.bodySmall.copyWith(
                  color: _getRarityColor(badge.rarity),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
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
