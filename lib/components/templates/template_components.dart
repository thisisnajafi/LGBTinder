import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_template_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../buttons/animated_button.dart';

class TemplateCard extends StatelessWidget {
  final ProfileTemplate template;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onPreview;

  const TemplateCard({
    Key? key,
    required this.template,
    this.isSelected = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.onPreview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primaryLight
                : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: AppColors.backgroundDark,
                image: DecorationImage(
                  image: NetworkImage(template.previewImage),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Fallback to placeholder
                  },
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder if image fails to load
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        colors: [
                          _getCategoryColor(template.category).withOpacity(0.3),
                          _getCategoryColor(template.category).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(template.category),
                        size: 48,
                        color: _getCategoryColor(template.category),
                      ),
                    ),
                  ),
                  
                  // Overlay with actions
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        if (template.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.feedbackWarning.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'PREMIUM',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticFeedbackService.selection();
                            onFavorite?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.feedbackError : AppColors.textSecondaryDark,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Preview button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedbackService.selection();
                        onPreview?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Template Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: AppTypography.subtitle2.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    template.description,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category and Style
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(template.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          template.category.name.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: _getCategoryColor(template.category),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.feedbackInfo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          template.style.name.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.feedbackInfo,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Features
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: template.features.take(3).map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.borderDefault,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          feature,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondaryDark,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rating and Usage
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.feedbackWarning,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        template.rating.toString(),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.people,
                        color: AppColors.feedbackInfo,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${template.usageCount}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (template.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.feedbackSuccess.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'POPULAR',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.feedbackSuccess,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.minimalist:
        return AppColors.info; // Indigo-like blue
      case TemplateCategory.creative:
        return AppColors.secondary; // Purple
      case TemplateCategory.professional:
        return AppColors.info; // Blue
      case TemplateCategory.casual:
        return AppColors.successLight; // Green
      case TemplateCategory.artistic:
        return AppColors.warning; // Amber
      case TemplateCategory.adventurous:
        return AppColors.errorLight; // Red
      case TemplateCategory.romantic:
        return AppColors.primaryLight; // Pink
      case TemplateCategory.quirky:
        return const Color(0xFF84CC16); // Lime (no exact match in AppColors)
      case TemplateCategory.elegant:
        return AppColors.textSecondaryLight; // Gray
      case TemplateCategory.modern:
        return AppColors.textPrimaryLight; // Dark gray
    }
  }

  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.minimalist:
        return Icons.minimize;
      case TemplateCategory.creative:
        return Icons.palette;
      case TemplateCategory.professional:
        return Icons.business;
      case TemplateCategory.casual:
        return Icons.person;
      case TemplateCategory.artistic:
        return Icons.brush;
      case TemplateCategory.adventurous:
        return Icons.hiking;
      case TemplateCategory.romantic:
        return Icons.favorite;
      case TemplateCategory.quirky:
        return Icons.emoji_emotions;
      case TemplateCategory.elegant:
        return Icons.diamond;
      case TemplateCategory.modern:
        return Icons.trending_up;
    }
  }
}

class CategoryFilterCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryFilterCard({
    Key? key,
    required this.category,
    this.isSelected = false,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Color(category['color']).withOpacity(0.1)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Color(category['color'])
                : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category['icon']),
              color: Color(category['color']),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              category['name'],
              style: AppTypography.body2.copyWith(
                color: isSelected 
                    ? Color(category['color'])
                    : AppColors.textPrimaryDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'minimize':
        return Icons.minimize;
      case 'palette':
        return Icons.palette;
      case 'business':
        return Icons.business;
      case 'casual':
        return Icons.person;
      case 'brush':
        return Icons.brush;
      case 'hiking':
        return Icons.hiking;
      case 'favorite':
        return Icons.favorite;
      case 'emoji_emotions':
        return Icons.emoji_emotions;
      case 'diamond':
        return Icons.diamond;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
}

class TemplatePreviewModal extends StatelessWidget {
  final ProfileTemplate template;
  final VoidCallback? onApply;
  final VoidCallback? onClose;

  const TemplatePreviewModal({
    Key? key,
    required this.template,
    this.onApply,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.navbarBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.description,
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedbackService.selection();
                      onClose?.call();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
            
            // Preview Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Preview Image
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.backgroundDark,
                        image: DecorationImage(
                          image: NetworkImage(template.previewImage),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Fallback to placeholder
                          },
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(template.category).withOpacity(0.3),
                              _getCategoryColor(template.category).withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(template.category),
                            size: 64,
                            color: _getCategoryColor(template.category),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Template Details
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Features
                            Text(
                              'Features',
                              style: AppTypography.subtitle1.copyWith(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: template.features.map((feature) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSecondary,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.borderDefault,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    feature,
                                    style: AppTypography.body2.copyWith(
                                      color: AppColors.textPrimaryDark,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Configuration
                            Text(
                              'Configuration',
                              style: AppTypography.subtitle1.copyWith(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderDefault,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: template.configuration.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: AppTypography.body2.copyWith(
                                            color: AppColors.textSecondaryDark,
                                          ),
                                        ),
                                        Text(
                                          entry.value.toString(),
                                          style: AppTypography.body2.copyWith(
                                            color: AppColors.textPrimaryDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedbackService.selection();
                        onClose?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderDefault),
                        foregroundColor: AppColors.textPrimaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedbackService.selection();
                        onApply?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Apply Template'),
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

  Color _getCategoryColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.minimalist:
        return AppColors.info; // Indigo-like blue
      case TemplateCategory.creative:
        return AppColors.secondary; // Purple
      case TemplateCategory.professional:
        return AppColors.info; // Blue
      case TemplateCategory.casual:
        return AppColors.successLight; // Green
      case TemplateCategory.artistic:
        return AppColors.warning; // Amber
      case TemplateCategory.adventurous:
        return AppColors.errorLight; // Red
      case TemplateCategory.romantic:
        return AppColors.primaryLight; // Pink
      case TemplateCategory.quirky:
        return const Color(0xFF84CC16); // Lime (no exact match in AppColors)
      case TemplateCategory.elegant:
        return AppColors.textSecondaryLight; // Gray
      case TemplateCategory.modern:
        return AppColors.textPrimaryLight; // Dark gray
    }
  }

  IconData _getCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.minimalist:
        return Icons.minimize;
      case TemplateCategory.creative:
        return Icons.palette;
      case TemplateCategory.professional:
        return Icons.business;
      case TemplateCategory.casual:
        return Icons.person;
      case TemplateCategory.artistic:
        return Icons.brush;
      case TemplateCategory.adventurous:
        return Icons.hiking;
      case TemplateCategory.romantic:
        return Icons.favorite;
      case TemplateCategory.quirky:
        return Icons.emoji_emotions;
      case TemplateCategory.elegant:
        return Icons.diamond;
      case TemplateCategory.modern:
        return Icons.trending_up;
    }
  }
}

class TemplateStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final VoidCallback? onTap;

  const TemplateStatisticsCard({
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
                  Icons.dashboard,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Template Statistics',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${statistics['totalTemplates']}',
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
                    'Free',
                    '${statistics['freeTemplates']}',
                    Icons.free_breakfast,
                    AppColors.feedbackSuccess,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Premium',
                    '${statistics['premiumTemplates']}',
                    Icons.star,
                    AppColors.feedbackWarning,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Popular',
                    '${statistics['popularTemplates']}',
                    Icons.trending_up,
                    AppColors.feedbackInfo,
                  ),
                ),
              ],
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
