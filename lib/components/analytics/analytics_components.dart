import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_analytics_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../buttons/animated_button.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  final VoidCallback? onTap;

  const AnalyticsSummaryCard({
    Key? key,
    required this.summary,
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
                  Icons.analytics,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile Analytics',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  color: AppColors.feedbackSuccess,
                  size: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Key Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Views',
                    '${summary['totalViews']}',
                    Icons.visibility,
                    AppColors.feedbackInfo,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Likes',
                    '${summary['totalLikes']}',
                    Icons.favorite,
                    AppColors.feedbackError,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Messages',
                    '${summary['totalMessages']}',
                    Icons.chat,
                    AppColors.feedbackSuccess,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Engagement Rate
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppColors.feedbackSuccess,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Engagement Rate',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        Text(
                          '${summary['engagementRate'].toStringAsFixed(1)}%',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.feedbackSuccess,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${summary['recentActivity']} recent',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
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
}

class AnalyticsTrendsCard extends StatelessWidget {
  final Map<String, dynamic> trends;
  final VoidCallback? onTap;

  const AnalyticsTrendsCard({
    Key? key,
    required this.trends,
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
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.feedbackSuccess,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Trends (${trends['period']})',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Last 30 days',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Trend Metrics
            Row(
              children: [
                Expanded(
                  child: _buildTrendItem(
                    'Avg Views/Day',
                    '${trends['averageViewsPerDay'].toStringAsFixed(1)}',
                    AppColors.feedbackInfo,
                  ),
                ),
                Expanded(
                  child: _buildTrendItem(
                    'Avg Likes/Day',
                    '${trends['averageLikesPerDay'].toStringAsFixed(1)}',
                    AppColors.feedbackError,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildTrendItem(
                    'Avg Passes/Day',
                    '${trends['averagePassesPerDay'].toStringAsFixed(1)}',
                    AppColors.feedbackWarning,
                  ),
                ),
                Expanded(
                  child: _buildTrendItem(
                    'Avg Messages/Day',
                    '${trends['averageMessagesPerDay'].toStringAsFixed(1)}',
                    AppColors.feedbackSuccess,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Total Metrics
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTotalMetric('Views', trends['totalViews'], AppColors.feedbackInfo),
                  _buildTotalMetric('Likes', trends['totalLikes'], AppColors.feedbackError),
                  _buildTotalMetric('Passes', trends['totalPasses'], AppColors.feedbackWarning),
                  _buildTotalMetric('Messages', trends['totalMessages'], AppColors.feedbackSuccess),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalMetric(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$value',
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
    );
  }
}

class AnalyticsEventCard extends StatelessWidget {
  final AnalyticsEvent event;
  final VoidCallback? onTap;

  const AnalyticsEventCard({
    Key? key,
    required this.event,
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
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEventColor(event.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getEventIcon(event.type),
                color: _getEventColor(event.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getEventDisplayName(event.type),
                    style: AppTypography.subtitle2.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(event.timestamp),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (event.targetUserId != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'User',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getEventIcon(AnalyticsEventType type) {
    switch (type) {
      case AnalyticsEventType.profileView:
        return Icons.visibility;
      case AnalyticsEventType.profileLike:
        return Icons.favorite;
      case AnalyticsEventType.profileSuperLike:
        return Icons.star;
      case AnalyticsEventType.profilePass:
        return Icons.close;
      case AnalyticsEventType.profileMessage:
        return Icons.chat;
      case AnalyticsEventType.profileShare:
        return Icons.share;
      case AnalyticsEventType.profileReport:
        return Icons.report;
      case AnalyticsEventType.profileBlock:
        return Icons.block;
      case AnalyticsEventType.profileUnblock:
        return Icons.check_circle;
      case AnalyticsEventType.profileVisit:
        return Icons.visibility;
      case AnalyticsEventType.profileEdit:
        return Icons.edit;
      case AnalyticsEventType.profilePhotoAdd:
        return Icons.add_photo_alternate;
      case AnalyticsEventType.profilePhotoRemove:
        return Icons.remove_circle;
      case AnalyticsEventType.profileBioUpdate:
        return Icons.description;
      case AnalyticsEventType.profileInterestAdd:
        return Icons.add_circle;
      case AnalyticsEventType.profileInterestRemove:
        return Icons.remove_circle;
      case AnalyticsEventType.profileLocationUpdate:
        return Icons.location_on;
      case AnalyticsEventType.profileVerificationSubmit:
        return Icons.security;
      case AnalyticsEventType.profileVerificationComplete:
        return Icons.verified;
      case AnalyticsEventType.profileCustomization:
        return Icons.palette;
      case AnalyticsEventType.profilePrivacyChange:
        return Icons.privacy_tip;
      case AnalyticsEventType.profileVisibilityChange:
        return Icons.visibility_off;
    }
  }

  Color _getEventColor(AnalyticsEventType type) {
    switch (type) {
      case AnalyticsEventType.profileView:
        return AppColors.feedbackInfo;
      case AnalyticsEventType.profileLike:
        return AppColors.feedbackError;
      case AnalyticsEventType.profileSuperLike:
        return AppColors.feedbackWarning;
      case AnalyticsEventType.profilePass:
        return AppColors.textSecondaryDark;
      case AnalyticsEventType.profileMessage:
        return AppColors.feedbackSuccess;
      case AnalyticsEventType.profileShare:
        return AppColors.primaryLight;
      case AnalyticsEventType.profileReport:
        return AppColors.feedbackError;
      case AnalyticsEventType.profileBlock:
        return AppColors.feedbackError;
      case AnalyticsEventType.profileUnblock:
        return AppColors.feedbackSuccess;
      case AnalyticsEventType.profileVisit:
        return AppColors.feedbackInfo;
      case AnalyticsEventType.profileEdit:
        return AppColors.primaryLight;
      case AnalyticsEventType.profilePhotoAdd:
        return AppColors.feedbackSuccess;
      case AnalyticsEventType.profilePhotoRemove:
        return AppColors.feedbackError;
      case AnalyticsEventType.profileBioUpdate:
        return AppColors.feedbackInfo;
      case AnalyticsEventType.profileInterestAdd:
        return AppColors.feedbackSuccess;
      case AnalyticsEventType.profileInterestRemove:
        return AppColors.feedbackError;
      case AnalyticsEventType.profileLocationUpdate:
        return AppColors.feedbackInfo;
      case AnalyticsEventType.profileVerificationSubmit:
        return AppColors.feedbackWarning;
      case AnalyticsEventType.profileVerificationComplete:
        return AppColors.feedbackSuccess;
      case AnalyticsEventType.profileCustomization:
        return AppColors.primaryLight;
      case AnalyticsEventType.profilePrivacyChange:
        return AppColors.feedbackWarning;
      case AnalyticsEventType.profileVisibilityChange:
        return AppColors.feedbackInfo;
    }
  }

  String _getEventDisplayName(AnalyticsEventType type) {
    switch (type) {
      case AnalyticsEventType.profileView:
        return 'Profile Viewed';
      case AnalyticsEventType.profileLike:
        return 'Profile Liked';
      case AnalyticsEventType.profileSuperLike:
        return 'Profile Super Liked';
      case AnalyticsEventType.profilePass:
        return 'Profile Passed';
      case AnalyticsEventType.profileMessage:
        return 'Message Sent';
      case AnalyticsEventType.profileShare:
        return 'Profile Shared';
      case AnalyticsEventType.profileReport:
        return 'Profile Reported';
      case AnalyticsEventType.profileBlock:
        return 'User Blocked';
      case AnalyticsEventType.profileUnblock:
        return 'User Unblocked';
      case AnalyticsEventType.profileVisit:
        return 'Profile Visited';
      case AnalyticsEventType.profileEdit:
        return 'Profile Edited';
      case AnalyticsEventType.profilePhotoAdd:
        return 'Photo Added';
      case AnalyticsEventType.profilePhotoRemove:
        return 'Photo Removed';
      case AnalyticsEventType.profileBioUpdate:
        return 'Bio Updated';
      case AnalyticsEventType.profileInterestAdd:
        return 'Interest Added';
      case AnalyticsEventType.profileInterestRemove:
        return 'Interest Removed';
      case AnalyticsEventType.profileLocationUpdate:
        return 'Location Updated';
      case AnalyticsEventType.profileVerificationSubmit:
        return 'Verification Submitted';
      case AnalyticsEventType.profileVerificationComplete:
        return 'Verification Completed';
      case AnalyticsEventType.profileCustomization:
        return 'Profile Customized';
      case AnalyticsEventType.profilePrivacyChange:
        return 'Privacy Changed';
      case AnalyticsEventType.profileVisibilityChange:
        return 'Visibility Changed';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class AnalyticsChartCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final String xAxisLabel;
  final String yAxisLabel;
  final VoidCallback? onTap;

  const AnalyticsChartCard({
    Key? key,
    required this.title,
    required this.data,
    required this.xAxisLabel,
    required this.yAxisLabel,
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
              title,
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              _buildEmptyState()
            else
              _buildChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    // Simple bar chart implementation
    final maxValue = data.map((d) => d['value'] as int).reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.map((item) {
                final value = item['value'] as int;
                final height = maxValue > 0 ? (value / maxValue) * 150 : 0.0;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['label'],
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                xAxisLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              Text(
                yAxisLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
