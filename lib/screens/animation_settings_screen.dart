import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/animation_service.dart';
import '../components/animations/animated_components.dart' as custom;

class AnimationSettingsScreen extends StatefulWidget {
  const AnimationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AnimationSettingsScreen> createState() => _AnimationSettingsScreenState();
}

class _AnimationSettingsScreenState extends State<AnimationSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationService _animationService;
  late AnimationController _previewController;
  late Animation<double> _previewAnimation;

  @override
  void initState() {
    super.initState();
    _animationService = AnimationService();
    _animationService.initialize();
    
    _previewController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _previewAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationService.dispose();
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Animation Settings'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMainToggle(),
            const SizedBox(height: 24),
            _buildAnimationTypes(),
            const SizedBox(height: 24),
            _buildDurationSettings(),
            const SizedBox(height: 24),
            _buildPreviewSection(),
            const SizedBox(height: 24),
            _buildAdvancedSettings(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.animation,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Animation Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize animations and transitions for better user experience',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animations',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.animation,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Animations',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Enable smooth animations and transitions',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _animationService.animationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _animationService.setAnimationsEnabled(value);
                  });
                  if (value) {
                    _previewController.repeat();
                  } else {
                    _previewController.stop();
                  }
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.accessibility_new,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reduce Motion',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Reduce animations for motion-sensitive users',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _animationService.reduceMotionEnabled,
                onChanged: (value) {
                  setState(() {
                    _animationService.setReduceMotionEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationTypes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animation Types',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose your preferred animation style',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAnimationTypeButton('Scale', custom.AnimationType.scale),
              _buildAnimationTypeButton('Fade', custom.AnimationType.fade),
              _buildAnimationTypeButton('Bounce', custom.AnimationType.bounce),
              _buildAnimationTypeButton('Rotate', custom.AnimationType.rotate),
              _buildAnimationTypeButton('Slide', custom.AnimationType.slide),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duration Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Default Duration: ${_animationService.defaultDuration.inMilliseconds}ms',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _animationService.defaultDuration.inMilliseconds.toDouble(),
            min: 100,
            max: 1000,
            divisions: 9,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _animationService.setDefaultDuration(Duration(milliseconds: value.round()));
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Fast Duration: ${_animationService.fastDuration.inMilliseconds}ms',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _animationService.fastDuration.inMilliseconds.toDouble(),
            min: 50,
            max: 300,
            divisions: 5,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _animationService.setDefaultDuration(Duration(milliseconds: value.round()));
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Slow Duration: ${_animationService.slowDuration.inMilliseconds}ms',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _animationService.slowDuration.inMilliseconds.toDouble(),
            min: 500,
            max: 2000,
            divisions: 15,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _animationService.setDefaultDuration(Duration(milliseconds: value.round()));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'See how animations will look in your app',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _previewAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  // Animated Button Preview
                  custom.AnimatedButton(
                    onPressed: () {
                      _previewController.reset();
                      _previewController.forward();
                    },
                    animationType: custom.AnimationType.scale,
                    child: Text(
                      'Animated Button',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Animated Card Preview
                  custom.AnimatedCard(
                    animationType: custom.AnimationType.fade,
                    child: Column(
                      children: [
                        Text(
                          'Animated Card',
                          style: AppTypography.h5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This card has smooth animations',
                          style: AppTypography.body2.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Animated Icon Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      custom.AnimatedIcon(
                        Icons.favorite,
                        animationType: custom.AnimationType.bounce,
                        color: Colors.red,
                        size: 32,
                      ),
                      custom.AnimatedIcon(
                        Icons.star,
                        animationType: custom.AnimationType.rotate,
                        color: Colors.yellow,
                        size: 32,
                      ),
                      custom.AnimatedIcon(
                        Icons.thumb_up,
                        animationType: custom.AnimationType.scale,
                        color: Colors.green,
                        size: 32,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Reset to Default',
            subtitle: 'Reset all animation settings to default values',
            icon: Icons.restore,
            onTap: _resetToDefault,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Animation Help',
            subtitle: 'Learn more about animation features',
            icon: Icons.help_outline,
            onTap: _showAnimationHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationTypeButton(String label, custom.AnimationType type) {
    return custom.AnimatedButton(
      onPressed: () {
        _previewController.reset();
        _previewController.forward();
      },
      animationType: type,
      child: Text(
        label,
        style: AppTypography.body2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _animationService.setAnimationsEnabled(true);
      _animationService.setReduceMotionEnabled(false);
      _animationService.setDefaultDuration(const Duration(milliseconds: 300));
    });
  }

  void _showAnimationHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Animation Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Animation types:\n\n'
          '• Scale: Elements grow and shrink\n'
          '• Fade: Elements fade in and out\n'
          '• Bounce: Elements bounce up and down\n'
          '• Rotate: Elements rotate slightly\n'
          '• Slide: Elements slide in from the side\n\n'
          'Duration settings control how fast animations play. '
          'Reduce motion is recommended for users sensitive to motion.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
