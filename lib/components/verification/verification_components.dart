import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/profile_verification_service.dart';
import '../services/haptic_feedback_service.dart';
import '../components/buttons/animated_button.dart';

class VerificationStatusCard extends StatelessWidget {
  final VerificationResult result;
  final VoidCallback? onTap;

  const VerificationStatusCard({
    Key? key,
    required this.result,
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
            colors: result.isVerified
                ? [
                    AppColors.feedbackSuccess.withOpacity(0.1),
                    AppColors.feedbackSuccess.withOpacity(0.05),
                  ]
                : [
                    AppColors.feedbackWarning.withOpacity(0.1),
                    AppColors.feedbackWarning.withOpacity(0.05),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: result.isVerified
                ? AppColors.feedbackSuccess
                : AppColors.feedbackWarning,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: result.isVerified
                        ? AppColors.feedbackSuccess
                        : AppColors.feedbackWarning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    result.isVerified ? Icons.verified : Icons.pending,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isVerified ? 'Profile Verified' : 'Verification Pending',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.isVerified
                            ? 'Your profile has been verified'
                            : 'Complete verification to build trust',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (result.verificationBadge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: result.isVerified
                          ? AppColors.feedbackSuccess
                          : AppColors.feedbackWarning,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result.verificationBadge!,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Verification Score
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Score',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: result.verificationScore / 100,
                        backgroundColor: AppColors.surfaceSecondary,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          result.isVerified
                              ? AppColors.feedbackSuccess
                              : AppColors.feedbackWarning,
                        ),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.verificationScore.round()}%',
                        style: AppTypography.body2.copyWith(
                          color: result.isVerified
                              ? AppColors.feedbackSuccess
                              : AppColors.feedbackWarning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Verified Types',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.verifiedTypes.length}',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            if (result.verifiedTypes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.verifiedTypes.map((type) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.feedbackSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getVerificationTypeDisplayName(type),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.feedbackSuccess,
                        fontWeight: FontWeight.w600,
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

  String _getVerificationTypeDisplayName(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return 'Photo';
      case VerificationType.identity:
        return 'ID';
      case VerificationType.phone:
        return 'Phone';
      case VerificationType.email:
        return 'Email';
      case VerificationType.social:
        return 'Social';
      case VerificationType.video:
        return 'Video';
    }
  }
}

class VerificationDocumentCard extends StatelessWidget {
  final VerificationDocument document;
  final VoidCallback? onTap;
  final VoidCallback? onResubmit;
  final VoidCallback? onDelete;

  const VerificationDocumentCard({
    Key? key,
    required this.document,
    this.onTap,
    this.onResubmit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(document.status),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(document.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(document.type),
                  color: _getStatusColor(document.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTypeDisplayName(document.type),
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getStatusDisplayName(document.status),
                      style: AppTypography.caption.copyWith(
                        color: _getStatusColor(document.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(document.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  document.status.name.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: _getStatusColor(document.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Submitted: ${_formatDate(document.submittedAt)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          
          if (document.reviewedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Reviewed: ${_formatDate(document.reviewedAt!)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
          
          if (document.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.feedbackError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.feedbackError,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.rejectionReason!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.feedbackError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (document.status == VerificationStatus.rejected) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedbackService.selection();
                      onResubmit?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryLight),
                      foregroundColor: AppColors.primaryLight,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Resubmit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedbackService.selection();
                      onDelete?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.feedbackError),
                      foregroundColor: AppColors.feedbackError,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getTypeIcon(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return Icons.photo_camera;
      case VerificationType.identity:
        return Icons.badge;
      case VerificationType.phone:
        return Icons.phone;
      case VerificationType.email:
        return Icons.email;
      case VerificationType.social:
        return Icons.share;
      case VerificationType.video:
        return Icons.videocam;
    }
  }

  String _getTypeDisplayName(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return 'Photo Verification';
      case VerificationType.identity:
        return 'Identity Verification';
      case VerificationType.phone:
        return 'Phone Verification';
      case VerificationType.email:
        return 'Email Verification';
      case VerificationType.social:
        return 'Social Media Verification';
      case VerificationType.video:
        return 'Video Verification';
    }
  }

  String _getStatusDisplayName(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Under Review';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.expired:
        return 'Expired';
      case VerificationStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return AppColors.feedbackWarning;
      case VerificationStatus.approved:
        return AppColors.feedbackSuccess;
      case VerificationStatus.rejected:
        return AppColors.feedbackError;
      case VerificationStatus.expired:
        return AppColors.textSecondaryDark;
      case VerificationStatus.cancelled:
        return AppColors.textSecondaryDark;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class VerificationProgressCard extends StatelessWidget {
  final Map<String, dynamic> progress;
  final VoidCallback? onTap;

  const VerificationProgressCard({
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
                  Icons.security,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Verification Progress',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${progress['completionPercentage'].round()}%',
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
              value: progress['completionPercentage'] / 100,
              backgroundColor: AppColors.surfaceSecondary,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
              minHeight: 8,
            ),
            
            const SizedBox(height: 16),
            
            // Progress Details
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'Required',
                    '${progress['completedRequired']}/${progress['totalRequired']}',
                    AppColors.feedbackSuccess,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Optional',
                    '${progress['completedOptional']}/${progress['totalOptional']}',
                    AppColors.feedbackInfo,
                  ),
                ),
                Expanded(
                  child: _buildProgressItem(
                    'Points',
                    '${progress['earnedPoints']}/${progress['totalPoints']}',
                    AppColors.feedbackWarning,
                  ),
                ),
              ],
            ),
            
            if (progress['isFullyVerified'] == false) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.feedbackWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.feedbackWarning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete required verifications to get verified badge',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.feedbackWarning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, Color color) {
    return Column(
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
        ),
      ],
    );
  }
}

class VerificationRequirementCard extends StatelessWidget {
  final VerificationType type;
  final Map<String, dynamic> requirement;
  final bool isCompleted;
  final VoidCallback? onTap;

  const VerificationRequirementCard({
    Key? key,
    required this.type,
    required this.requirement,
    this.isCompleted = false,
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
          color: isCompleted
              ? AppColors.feedbackSuccess.withOpacity(0.1)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.feedbackSuccess
                : AppColors.borderDefault,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.feedbackSuccess
                        : AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    color: isCompleted
                        ? Colors.white
                        : AppColors.primaryLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requirement['title'],
                        style: AppTypography.subtitle2.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        requirement['description'],
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.feedbackSuccess,
                    size: 24,
                  ),
                if (!isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.feedbackWarning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${requirement['points']} pts',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.feedbackWarning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (requirement['required'] == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.feedbackError.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'REQUIRED',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.feedbackError,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return Icons.photo_camera;
      case VerificationType.identity:
        return Icons.badge;
      case VerificationType.phone:
        return Icons.phone;
      case VerificationType.email:
        return Icons.email;
      case VerificationType.social:
        return Icons.share;
      case VerificationType.video:
        return Icons.videocam;
    }
  }
}
