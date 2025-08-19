import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ProfileBio extends StatelessWidget {
  final String bio;
  final List<String> interests;
  final Map<String, String> personalInfo;
  final VoidCallback onEdit;
  final bool isEditable;

  const ProfileBio({
    Key? key,
    required this.bio,
    required this.interests,
    required this.personalInfo,
    required this.onEdit,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'About Me',
                style: AppTypography.titleMediumStyle,
              ),
              if (isEditable)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: AppTypography.bodyMediumStyle,
          ),
          const SizedBox(height: 24),
          Text(
            'Interests',
            style: AppTypography.titleMediumStyle,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  interest,
                  style: AppTypography.bodySmallStyle.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Personal Info',
            style: AppTypography.titleMediumStyle,
          ),
          const SizedBox(height: 8),
          ...personalInfo.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    _getIconForInfo(entry.key),
                    size: 20,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatInfoKey(entry.key),
                          style: AppTypography.bodySmallStyle.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.value,
                          style: AppTypography.bodyMediumStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getIconForInfo(String key) {
    switch (key.toLowerCase()) {
      case 'gender':
        return Icons.person;
      case 'orientation':
        return Icons.favorite;
      case 'relationship':
        return Icons.favorite_border;
      case 'height':
        return Icons.height;
      case 'education':
        return Icons.school;
      case 'occupation':
        return Icons.work;
      case 'languages':
        return Icons.language;
      case 'religion':
        return Icons.church;
      case 'zodiac':
        return Icons.star;
      default:
        return Icons.info;
    }
  }

  String _formatInfoKey(String key) {
    return key[0].toUpperCase() + key.substring(1).replaceAll('_', ' ');
  }
} 