import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_sharing_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../buttons/animated_button.dart';

class SharePlatformCard extends StatelessWidget {
  final Map<String, dynamic> platform;
  final VoidCallback? onTap;
  final bool isEnabled;

  const SharePlatformCard({
    Key? key,
    required this.platform,
    this.onTap,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEnabled) {
          HapticFeedbackService.selection();
          onTap?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled 
              ? AppColors.surfaceSecondary
              : AppColors.surfaceSecondary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled 
                ? AppColors.borderDefault
                : AppColors.borderDefault.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(platform['color']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getPlatformIcon(platform['icon']),
                color: isEnabled 
                    ? Color(platform['color'])
                    : Color(platform['color']).withOpacity(0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    platform['name'],
                    style: AppTypography.subtitle2.copyWith(
                      color: isEnabled 
                          ? AppColors.textPrimaryDark
                          : AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    platform['description'],
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (!isEnabled)
              Icon(
                Icons.lock,
                color: AppColors.textSecondaryDark,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String iconName) {
    switch (iconName) {
      case 'whatsapp':
        return Icons.chat;
      case 'telegram':
        return Icons.send;
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.alternate_email;
      case 'snapchat':
        return Icons.camera_front;
      case 'tiktok':
        return Icons.video_call;
      case 'email':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      case 'link':
        return Icons.link;
      case 'qr_code':
        return Icons.qr_code;
      case 'save':
        return Icons.save;
      default:
        return Icons.share;
    }
  }
}

class ShareHistoryCard extends StatelessWidget {
  final ShareHistory history;
  final VoidCallback? onTap;

  const ShareHistoryCard({
    Key? key,
    required this.history,
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
            color: history.isSuccessful 
                ? AppColors.feedbackSuccess
                : AppColors.feedbackError,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: history.isSuccessful 
                    ? AppColors.feedbackSuccess.withOpacity(0.1)
                    : AppColors.feedbackError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                history.isSuccessful ? Icons.check_circle : Icons.error,
                color: history.isSuccessful 
                    ? AppColors.feedbackSuccess
                    : AppColors.feedbackError,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPlatformDisplayName(history.platform),
                    style: AppTypography.subtitle2.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(history.timestamp),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  if (history.recipientName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'To: ${history.recipientName}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: history.isSuccessful 
                    ? AppColors.feedbackSuccess.withOpacity(0.1)
                    : AppColors.feedbackError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                history.isSuccessful ? 'SUCCESS' : 'FAILED',
                style: AppTypography.caption.copyWith(
                  color: history.isSuccessful 
                      ? AppColors.feedbackSuccess
                      : AppColors.feedbackError,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPlatformDisplayName(SharePlatform platform) {
    switch (platform) {
      case SharePlatform.whatsapp:
        return 'WhatsApp';
      case SharePlatform.telegram:
        return 'Telegram';
      case SharePlatform.instagram:
        return 'Instagram';
      case SharePlatform.facebook:
        return 'Facebook';
      case SharePlatform.twitter:
        return 'Twitter';
      case SharePlatform.snapchat:
        return 'Snapchat';
      case SharePlatform.tiktok:
        return 'TikTok';
      case SharePlatform.email:
        return 'Email';
      case SharePlatform.sms:
        return 'SMS';
      case SharePlatform.link:
        return 'Copy Link';
      case SharePlatform.qrCode:
        return 'QR Code';
      case SharePlatform.copyLink:
        return 'Copy Link';
      case SharePlatform.saveImage:
        return 'Save Image';
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

class ShareStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final VoidCallback? onTap;

  const ShareStatisticsCard({
    Key? key,
    required this.statistics,
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
                  Icons.share,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Share Statistics',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${statistics['successRate'].toStringAsFixed(1)}%',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.feedbackSuccess,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Key Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Total Shares',
                    '${statistics['totalShares']}',
                    Icons.share,
                    AppColors.primaryLight,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Successful',
                    '${statistics['successfulShares']}',
                    Icons.check_circle,
                    AppColors.feedbackSuccess,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Failed',
                    '${statistics['failedShares']}',
                    Icons.error,
                    AppColors.feedbackError,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Success Rate
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
                          'Success Rate',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        Text(
                          '${statistics['successRate'].toStringAsFixed(1)}%',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.feedbackSuccess,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

class ShareContentPreview extends StatelessWidget {
  final ShareContent content;
  final VoidCallback? onTap;

  const ShareContentPreview({
    Key? key,
    required this.content,
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
              'Share Preview',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Content Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderDefault,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    content.title,
                    style: AppTypography.subtitle2.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Text(
                    content.description,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  
                  if (content.link != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: AppColors.primaryLight,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              content.link!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  if (content.imagePath != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(content.imagePath!),
                          fit: BoxFit.cover,
                        ),
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
}

class ShareQuickActions extends StatelessWidget {
  final VoidCallback? onShareAll;
  final VoidCallback? onShareLink;
  final VoidCallback? onShareQR;
  final VoidCallback? onShareImage;

  const ShareQuickActions({
    Key? key,
    this.onShareAll,
    this.onShareLink,
    this.onShareQR,
    this.onShareImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            'Quick Share',
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
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onShareAll?.call();
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share All'),
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
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onShareLink?.call();
                  },
                  icon: const Icon(Icons.link, size: 18),
                  label: const Text('Copy Link'),
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
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onShareQR?.call();
                  },
                  icon: const Icon(Icons.qr_code, size: 18),
                  label: const Text('QR Code'),
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
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onShareImage?.call();
                  },
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text('Save Image'),
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
}
