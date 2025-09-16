import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/rainbow_theme_service.dart';

class RainbowThemeSettingsScreen extends StatefulWidget {
  const RainbowThemeSettingsScreen({Key? key}) : super(key: key);

  @override
  State<RainbowThemeSettingsScreen> createState() => _RainbowThemeSettingsScreenState();
}

class _RainbowThemeSettingsScreenState extends State<RainbowThemeSettingsScreen>
    with TickerProviderStateMixin {
  late RainbowThemeService _rainbowService;
  late AnimationController _previewController;
  late Animation<double> _previewAnimation;

  @override
  void initState() {
    super.initState();
    _rainbowService = RainbowThemeService();
    _rainbowService.initialize(this);
    
    _previewController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _previewAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _rainbowService.dispose();
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Rainbow Theme Settings'),
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
            _buildRainbowToggle(),
            const SizedBox(height: 24),
            _buildStyleSelection(),
            const SizedBox(height: 24),
            _buildAnimationSettings(),
            const SizedBox(height: 24),
            _buildPreviewSection(),
            const SizedBox(height: 24),
            _buildPrideFlagsSection(),
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
          colors: AppColors.lgbtGradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Rainbow Theme',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Celebrate diversity with beautiful rainbow themes',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRainbowToggle() {
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
            'Rainbow Theme',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.palette,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Rainbow Theme',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Apply beautiful rainbow gradients throughout the app',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _rainbowService.isRainbowEnabled,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _rainbowService.enableRainbow();
                      _previewController.repeat();
                    } else {
                      _rainbowService.disableRainbow();
                      _previewController.stop();
                    }
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

  Widget _buildStyleSelection() {
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
            'Rainbow Style',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...RainbowStyle.values.map((style) => _buildStyleOption(style)),
        ],
      ),
    );
  }

  Widget _buildStyleOption(RainbowStyle style) {
    final isSelected = _rainbowService.currentStyle == style;
    
    return InkWell(
      onTap: () {
        setState(() {
          _rainbowService.setRainbowStyle(style);
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                gradient: _getStyleGradient(style),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStyleName(style),
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _getStyleDescription(style),
                    style: AppTypography.body2.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationSettings() {
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
            'Animation Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Enable Animation',
            subtitle: 'Animate rainbow colors smoothly',
            value: _rainbowService.isAnimated,
            onChanged: (value) {
              setState(() {
                _rainbowService.toggleAnimation();
                if (value) {
                  _previewController.repeat();
                } else {
                  _previewController.stop();
                }
              });
            },
            icon: Icons.animation,
          ),
          const SizedBox(height: 16),
          Text(
            'Animation Speed: ${_rainbowService.animationSpeed.toStringAsFixed(1)}x',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _rainbowService.animationSpeed,
            min: 0.1,
            max: 3.0,
            divisions: 29,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _rainbowService.setAnimationSpeed(value);
                _previewController.duration = Duration(
                  milliseconds: (3000 / value).round(),
                );
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
          AnimatedBuilder(
            animation: _previewAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  // Preview button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: _rainbowService.getRainbowGradient(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Rainbow Button',
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Preview card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: _rainbowService.getRainbowGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Rainbow Card',
                          style: AppTypography.h5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is how rainbow elements will look in your app',
                          style: AppTypography.body2.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrideFlagsSection() {
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
            'Pride Flags',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose from different pride flag themes to represent various identities',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          _buildPrideFlagOption('LGBTQ+ Pride', RainbowStyle.fullRainbow),
          _buildPrideFlagOption('Transgender Pride', RainbowStyle.transPride),
          _buildPrideFlagOption('Bisexual Pride', RainbowStyle.biPride),
          _buildPrideFlagOption('Pansexual Pride', RainbowStyle.panPride),
          _buildPrideFlagOption('Asexual Pride', RainbowStyle.acePride),
        ],
      ),
    );
  }

  Widget _buildPrideFlagOption(String name, RainbowStyle style) {
    final isSelected = _rainbowService.currentStyle == style;
    
    return InkWell(
      onTap: () {
        setState(() {
          _rainbowService.setRainbowStyle(style);
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 30,
              decoration: BoxDecoration(
                gradient: _getStyleGradient(style),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Row(
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  LinearGradient _getStyleGradient(RainbowStyle style) {
    switch (style) {
      case RainbowStyle.fullRainbow:
        return LinearGradient(colors: AppColors.lgbtGradient);
      case RainbowStyle.pastelRainbow:
        return LinearGradient(colors: [
          const Color(0xFFFFB3BA),
          const Color(0xFFFFDFBA),
          const Color(0xFFFFFFBA),
          const Color(0xFFBAFFC9),
          const Color(0xFFBAE1FF),
          const Color(0xFFE1BAFF),
        ]);
      case RainbowStyle.vibrantRainbow:
        return LinearGradient(colors: [
          const Color(0xFFFF0000),
          const Color(0xFFFF8000),
          const Color(0xFFFFFF00),
          const Color(0xFF00FF00),
          const Color(0xFF0080FF),
          const Color(0xFF8000FF),
        ]);
      case RainbowStyle.subtleRainbow:
        return LinearGradient(colors: [
          const Color(0xFFE57373),
          const Color(0xFFFFB74D),
          const Color(0xFFFFF176),
          const Color(0xFF81C784),
          const Color(0xFF64B5F6),
          const Color(0xFFBA68C8),
        ]);
      case RainbowStyle.transPride:
        return LinearGradient(colors: [
          const Color(0xFF5BCEFA),
          const Color(0xFFF5A9B8),
          const Color(0xFFFFFFFF),
          const Color(0xFFF5A9B8),
          const Color(0xFF5BCEFA),
        ]);
      case RainbowStyle.biPride:
        return LinearGradient(colors: [
          const Color(0xFFD70071),
          const Color(0xFF9C4F96),
          const Color(0xFF0035AA),
        ]);
      case RainbowStyle.panPride:
        return LinearGradient(colors: [
          const Color(0xFFFF1B8D),
          const Color(0xFFFFD700),
          const Color(0xFF1BB3FF),
        ]);
      case RainbowStyle.acePride:
        return LinearGradient(colors: [
          const Color(0xFF000000),
          const Color(0xFFA3A3A3),
          const Color(0xFFFFFFFF),
          const Color(0xFF800080),
        ]);
    }
  }

  String _getStyleName(RainbowStyle style) {
    switch (style) {
      case RainbowStyle.fullRainbow:
        return 'Full Rainbow';
      case RainbowStyle.pastelRainbow:
        return 'Pastel Rainbow';
      case RainbowStyle.vibrantRainbow:
        return 'Vibrant Rainbow';
      case RainbowStyle.subtleRainbow:
        return 'Subtle Rainbow';
      case RainbowStyle.transPride:
        return 'Transgender Pride';
      case RainbowStyle.biPride:
        return 'Bisexual Pride';
      case RainbowStyle.panPride:
        return 'Pansexual Pride';
      case RainbowStyle.acePride:
        return 'Asexual Pride';
    }
  }

  String _getStyleDescription(RainbowStyle style) {
    switch (style) {
      case RainbowStyle.fullRainbow:
        return 'Classic LGBTQ+ pride flag colors';
      case RainbowStyle.pastelRainbow:
        return 'Soft, pastel rainbow colors';
      case RainbowStyle.vibrantRainbow:
        return 'Bright, vibrant rainbow colors';
      case RainbowStyle.subtleRainbow:
        return 'Muted rainbow colors';
      case RainbowStyle.transPride:
        return 'Transgender pride flag colors';
      case RainbowStyle.biPride:
        return 'Bisexual pride flag colors';
      case RainbowStyle.panPride:
        return 'Pansexual pride flag colors';
      case RainbowStyle.acePride:
        return 'Asexual pride flag colors';
    }
  }
}
