import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/haptic_feedback_service.dart';

class VerificationBadge extends StatelessWidget {
  final VerificationType type;
  final VerificationStatus status;
  final double size;
  final bool showTooltip;
  final VoidCallback? onTap;

  const VerificationBadge({
    Key? key,
    required this.type,
    required this.status,
    this.size = 24.0,
    this.showTooltip = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeData = _getBadgeData();
    
    Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: badgeData.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: badgeData.borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeData.backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        badgeData.icon,
        color: badgeData.iconColor,
        size: size * 0.6,
      ),
    );

    if (onTap != null) {
      badge = GestureDetector(
        onTap: () {
          HapticFeedbackService.selection();
          onTap!();
        },
        child: badge,
      );
    }

    if (showTooltip) {
      return Tooltip(
        message: badgeData.tooltip,
        child: badge,
      );
    }

    return badge;
  }

  BadgeData _getBadgeData() {
    switch (status) {
      case VerificationStatus.verified:
        return BadgeData(
          icon: Icons.verified,
          backgroundColor: AppColors.feedbackSuccess,
          borderColor: AppColors.feedbackSuccess,
          iconColor: Colors.white,
          tooltip: _getVerifiedTooltip(),
        );
      case VerificationStatus.pending:
        return BadgeData(
          icon: Icons.schedule,
          backgroundColor: AppColors.feedbackWarning,
          borderColor: AppColors.feedbackWarning,
          iconColor: Colors.white,
          tooltip: _getPendingTooltip(),
        );
      case VerificationStatus.rejected:
        return BadgeData(
          icon: Icons.close,
          backgroundColor: AppColors.feedbackError,
          borderColor: AppColors.feedbackError,
          iconColor: Colors.white,
          tooltip: _getRejectedTooltip(),
        );
      case VerificationStatus.notVerified:
        return BadgeData(
          icon: Icons.help_outline,
          backgroundColor: AppColors.surfaceSecondary,
          borderColor: AppColors.borderDefault,
          iconColor: AppColors.textSecondaryDark,
          tooltip: _getNotVerifiedTooltip(),
        );
    }
  }

  String _getVerifiedTooltip() {
    switch (type) {
      case VerificationType.email:
        return 'Email verified';
      case VerificationType.phone:
        return 'Phone number verified';
      case VerificationType.identity:
        return 'Identity verified';
      case VerificationType.photo:
        return 'Photo verified';
      case VerificationType.social:
        return 'Social media verified';
      case VerificationType.premium:
        return 'Premium member';
    }
  }

  String _getPendingTooltip() {
    switch (type) {
      case VerificationType.email:
        return 'Email verification pending';
      case VerificationType.phone:
        return 'Phone verification pending';
      case VerificationType.identity:
        return 'Identity verification pending';
      case VerificationType.photo:
        return 'Photo verification pending';
      case VerificationType.social:
        return 'Social media verification pending';
      case VerificationType.premium:
        return 'Premium verification pending';
    }
  }

  String _getRejectedTooltip() {
    switch (type) {
      case VerificationType.email:
        return 'Email verification rejected';
      case VerificationType.phone:
        return 'Phone verification rejected';
      case VerificationType.identity:
        return 'Identity verification rejected';
      case VerificationType.photo:
        return 'Photo verification rejected';
      case VerificationType.social:
        return 'Social media verification rejected';
      case VerificationType.premium:
        return 'Premium verification rejected';
    }
  }

  String _getNotVerifiedTooltip() {
    switch (type) {
      case VerificationType.email:
        return 'Email not verified';
      case VerificationType.phone:
        return 'Phone not verified';
      case VerificationType.identity:
        return 'Identity not verified';
      case VerificationType.photo:
        return 'Photo not verified';
      case VerificationType.social:
        return 'Social media not verified';
      case VerificationType.premium:
        return 'Not a premium member';
    }
  }
}

enum VerificationType {
  email,
  phone,
  identity,
  photo,
  social,
  premium,
}

enum VerificationStatus {
  verified,
  pending,
  rejected,
  notVerified,
}

class BadgeData {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final String tooltip;

  const BadgeData({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.tooltip,
  });
}

class VerificationBadgeList extends StatelessWidget {
  final Map<VerificationType, VerificationStatus> verifications;
  final double badgeSize;
  final double spacing;
  final bool showTooltips;
  final Function(VerificationType type)? onBadgeTap;

  const VerificationBadgeList({
    Key? key,
    required this.verifications,
    this.badgeSize = 24.0,
    this.spacing = 8.0,
    this.showTooltips = true,
    this.onBadgeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final verifiedCount = verifications.values.where((status) => status == VerificationStatus.verified).length;
    final totalCount = verifications.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Verification Status',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$verifiedCount/$totalCount',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: verifications.entries.map((entry) {
            return VerificationBadge(
              type: entry.key,
              status: entry.value,
              size: badgeSize,
              showTooltip: showTooltips,
              onTap: onBadgeTap != null ? () => onBadgeTap!(entry.key) : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class VerificationProgress extends StatelessWidget {
  final Map<VerificationType, VerificationStatus> verifications;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;

  const VerificationProgress({
    Key? key,
    required this.verifications,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final verifiedCount = verifications.values.where((status) => status == VerificationStatus.verified).length;
    final totalCount = verifications.length;
    final progress = totalCount > 0 ? verifiedCount / totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Verification Progress',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor ?? AppColors.feedbackSuccess,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class VerificationCard extends StatelessWidget {
  final VerificationType type;
  final VerificationStatus status;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isEnabled;

  const VerificationCard({
    Key? key,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    this.onTap,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeData = _getBadgeData();
    
    return GestureDetector(
      onTap: isEnabled ? () {
        HapticFeedbackService.selection();
        onTap?.call();
      } : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: status == VerificationStatus.verified 
                ? AppColors.feedbackSuccess 
                : AppColors.borderDefault,
            width: status == VerificationStatus.verified ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            VerificationBadge(
              type: type,
              status: status,
              size: 32,
              showTooltip: false,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
            if (isEnabled)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondaryDark,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  BadgeData _getBadgeData() {
    switch (status) {
      case VerificationStatus.verified:
        return BadgeData(
          icon: Icons.verified,
          backgroundColor: AppColors.feedbackSuccess,
          borderColor: AppColors.feedbackSuccess,
          iconColor: Colors.white,
          tooltip: 'Verified',
        );
      case VerificationStatus.pending:
        return BadgeData(
          icon: Icons.schedule,
          backgroundColor: AppColors.feedbackWarning,
          borderColor: AppColors.feedbackWarning,
          iconColor: Colors.white,
          tooltip: 'Pending',
        );
      case VerificationStatus.rejected:
        return BadgeData(
          icon: Icons.close,
          backgroundColor: AppColors.feedbackError,
          borderColor: AppColors.feedbackError,
          iconColor: Colors.white,
          tooltip: 'Rejected',
        );
      case VerificationStatus.notVerified:
        return BadgeData(
          icon: Icons.help_outline,
          backgroundColor: AppColors.surfaceSecondary,
          borderColor: AppColors.borderDefault,
          iconColor: AppColors.textSecondaryDark,
          tooltip: 'Not verified',
        );
    }
  }
}

class VerificationStatusIndicator extends StatelessWidget {
  final VerificationStatus status;
  final String label;
  final double size;

  const VerificationStatusIndicator({
    Key? key,
    required this.status,
    required this.label,
    this.size = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case VerificationStatus.verified:
        return AppColors.feedbackSuccess;
      case VerificationStatus.pending:
        return AppColors.feedbackWarning;
      case VerificationStatus.rejected:
        return AppColors.feedbackError;
      case VerificationStatus.notVerified:
        return AppColors.textSecondaryDark;
    }
  }
}
