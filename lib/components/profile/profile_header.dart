import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../avatar/animated_avatar.dart';

class ProfileStats {
  final int matches;
  final int likes;
  final int views;
  final int superLikes;

  const ProfileStats({
    required this.matches,
    required this.likes,
    required this.views,
    required this.superLikes,
  });
}

class ProfileHeader extends StatelessWidget {
  final String name;
  final int age;
  final String imageUrl;
  final String? location;
  final bool isVerified;
  final bool isOnline;
  final ProfileStats stats;
  final VoidCallback onEdit;
  final VoidCallback onSettings;
  final VoidCallback onShare;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.age,
    required this.imageUrl,
    this.location,
    required this.isVerified,
    required this.isOnline,
    required this.stats,
    required this.onEdit,
    required this.onSettings,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AnimatedAvatar(
                    imageUrl: imageUrl,
                    size: 120,
                  ),
                  if (isVerified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$name, $age',
                          style: AppTypography.titleLargeStyle,
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: AppColors.successLight,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    if (location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location!,
                            style: AppTypography.bodyMediumStyle.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ActionButton(
                          icon: Icons.edit,
                          label: 'Edit',
                          onTap: onEdit,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.settings,
                          label: 'Settings',
                          onTap: onSettings,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          onTap: onShare,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                value: stats.matches,
                label: 'Matches',
                icon: Icons.favorite,
              ),
              _StatItem(
                value: stats.likes,
                label: 'Likes',
                icon: Icons.thumb_up,
              ),
              _StatItem(
                value: stats.views,
                label: 'Views',
                icon: Icons.visibility,
              ),
              _StatItem(
                value: stats.superLikes,
                label: 'Super Likes',
                icon: Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primaryLight,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.bodySmallStyle.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryLight,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: AppTypography.titleMediumStyle,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmallStyle.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
} 