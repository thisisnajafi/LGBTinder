import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/profile_customization_service.dart';
import '../services/haptic_feedback_service.dart';

class CustomizableProfileWidget extends StatefulWidget {
  final Widget child;
  final String? customTheme;
  final String? customLayout;
  final bool enableAnimations;
  final bool enableParallax;
  final Map<String, dynamic>? customSettings;

  const CustomizableProfileWidget({
    Key? key,
    required this.child,
    this.customTheme,
    this.customLayout,
    this.enableAnimations = true,
    this.enableParallax = false,
    this.customSettings,
  }) : super(key: key);

  @override
  State<CustomizableProfileWidget> createState() => _CustomizableProfileWidgetState();
}

class _CustomizableProfileWidgetState extends State<CustomizableProfileWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _parallaxController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  ProfileCustomizationSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ProfileCustomizationService.instance.getSettings();
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
        
        if (settings.enableAnimations) {
          _animationController.forward();
        }
        
        if (settings.enableParallaxEffects) {
          _parallaxController.repeat(reverse: true);
        }
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
  void dispose() {
    _animationController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    final settings = _settings ?? const ProfileCustomizationSettings();
    final theme = _getThemeColors(settings.profileTheme);
    final layout = _getLayoutStyle(settings.profileLayout);

    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: theme['primaryColor'],
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: theme['primaryColor'],
          secondary: theme['secondaryColor'],
        ),
      ),
      child: _buildCustomizedContent(settings, theme, layout),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryLight,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading profile customization...',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizedContent(
    ProfileCustomizationSettings settings,
    Map<String, dynamic> theme,
    Map<String, dynamic> layout,
  ) {
    Widget content = widget.child;

    // Apply animations if enabled
    if (settings.enableAnimations) {
      content = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child!,
              ),
            ),
          );
        },
        child: content,
      );
    }

    // Apply parallax effects if enabled
    if (settings.enableParallaxEffects) {
      content = AnimatedBuilder(
        animation: _parallaxController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _parallaxController.value * 10),
            child: child!,
          );
        },
        child: content,
      );
    }

    // Apply layout-specific styling
    content = _applyLayoutStyling(content, layout);

    // Apply theme-specific styling
    content = _applyThemeStyling(content, theme);

    return content;
  }

  Widget _applyLayoutStyling(Widget content, Map<String, dynamic> layout) {
    switch (layout['id']) {
      case 'grid':
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderDefault,
              width: 1,
            ),
          ),
          child: content,
        );
      case 'card':
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: content,
        );
      case 'timeline':
        return Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppColors.primaryLight,
                width: 3,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: content,
          ),
        );
      case 'minimal':
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: content,
        );
      default:
        return content;
    }
  }

  Widget _applyThemeStyling(Widget content, Map<String, dynamic> theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(theme['primaryColor']).withOpacity(0.05),
            Color(theme['secondaryColor']).withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: content,
    );
  }

  Map<String, dynamic> _getThemeColors(String themeId) {
    final themes = ProfileCustomizationService.instance.getAvailableThemes();
    final theme = themes.firstWhere(
      (t) => t['id'] == themeId,
      orElse: () => themes.first,
    );
    
    return {
      'primaryColor': Color(theme['primaryColor']),
      'secondaryColor': Color(theme['secondaryColor']),
    };
  }

  Map<String, dynamic> _getLayoutStyle(String layoutId) {
    final layouts = ProfileCustomizationService.instance.getAvailableLayouts();
    return layouts.firstWhere(
      (l) => l['id'] == layoutId,
      orElse: () => layouts.first,
    );
  }
}

class ProfileCustomizationPreview extends StatelessWidget {
  final ProfileCustomizationSettings settings;
  final VoidCallback? onCustomize;

  const ProfileCustomizationPreview({
    Key? key,
    required this.settings,
    this.onCustomize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Preview',
                style: AppTypography.subtitle1.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onCustomize != null)
                TextButton(
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onCustomize!();
                  },
                  child: Text(
                    'Customize',
                    style: AppTypography.button.copyWith(
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewContent(),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Profile Theme: ${settings.profileTheme}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Layout: ${settings.profileLayout}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            Text(
              'Sections: ${settings.enabledSections.length}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            if (settings.enableAnimations)
              Text(
                'Animations: Enabled',
                style: AppTypography.caption.copyWith(
                  color: AppColors.feedbackSuccess,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileCustomizationQuickActions extends StatelessWidget {
  final VoidCallback? onCustomize;
  final VoidCallback? onReset;
  final VoidCallback? onPreview;

  const ProfileCustomizationQuickActions({
    Key? key,
    this.onCustomize,
    this.onReset,
    this.onPreview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onCustomize != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedbackService.selection();
                      onCustomize!();
                    },
                    icon: const Icon(Icons.tune, size: 16),
                    label: const Text('Customize'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (onCustomize != null) const SizedBox(width: 8),
              if (onPreview != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedbackService.selection();
                      onPreview!();
                    },
                    icon: const Icon(Icons.preview, size: 16),
                    label: const Text('Preview'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderDefault),
                      foregroundColor: AppColors.textPrimaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (onReset != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedbackService.selection();
                  onReset!();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset to Defaults'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.feedbackError,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
