import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/haptic_feedback_service.dart';

class HapticFeedbackSettingsScreen extends StatefulWidget {
  const HapticFeedbackSettingsScreen({Key? key}) : super(key: key);

  @override
  State<HapticFeedbackSettingsScreen> createState() => _HapticFeedbackSettingsScreenState();
}

class _HapticFeedbackSettingsScreenState extends State<HapticFeedbackSettingsScreen> {
  late HapticFeedbackService _hapticService;

  @override
  void initState() {
    super.initState();
    _hapticService = HapticFeedbackService();
    _hapticService.initialize();
  }

  @override
  void dispose() {
    _hapticService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Haptic Feedback Settings'),
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
            _buildHapticTypes(),
            const SizedBox(height: 24),
            _buildIntensitySettings(),
            const SizedBox(height: 24),
            _buildTestSection(),
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
            Icons.vibration,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Haptic Feedback',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize vibration feedback for better user experience',
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
            'Haptic Feedback',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.vibration,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Haptic Feedback',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Feel vibrations when interacting with the app',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              HapticSwitch(
                value: _hapticService.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _hapticService.setEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
                inactiveColor: Colors.white24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHapticTypes() {
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
            'Haptic Types',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildHapticTypeToggle(
            title: 'Light Haptic',
            subtitle: 'Subtle vibrations for gentle interactions',
            value: _hapticService.isLightEnabled,
            onChanged: (value) {
              setState(() {
                _hapticService.setLightEnabled(value);
              });
            },
            onTest: () => _hapticService.light(),
            icon: Icons.touch_app,
          ),
          const SizedBox(height: 12),
          _buildHapticTypeToggle(
            title: 'Medium Haptic',
            subtitle: 'Standard vibrations for normal interactions',
            value: _hapticService.isMediumEnabled,
            onChanged: (value) {
              setState(() {
                _hapticService.setMediumEnabled(value);
              });
            },
            onTest: () => _hapticService.medium(),
            icon: Icons.touch_app,
          ),
          const SizedBox(height: 12),
          _buildHapticTypeToggle(
            title: 'Heavy Haptic',
            subtitle: 'Strong vibrations for important interactions',
            value: _hapticService.isHeavyEnabled,
            onChanged: (value) {
              setState(() {
                _hapticService.setHeavyEnabled(value);
              });
            },
            onTest: () => _hapticService.heavy(),
            icon: Icons.touch_app,
          ),
          const SizedBox(height: 12),
          _buildHapticTypeToggle(
            title: 'Selection Haptic',
            subtitle: 'Vibrations for list selections and switches',
            value: _hapticService.isSelectionEnabled,
            onChanged: (value) {
              setState(() {
                _hapticService.setSelectionEnabled(value);
              });
            },
            onTest: () => _hapticService.selection(),
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 12),
          _buildHapticTypeToggle(
            title: 'Impact Haptic',
            subtitle: 'Vibrations for button presses and taps',
            value: _hapticService.isImpactEnabled,
            onChanged: (value) {
              setState(() {
                _hapticService.setImpactEnabled(value);
              });
            },
            onTest: () => _hapticService.impact(),
            icon: Icons.touch_app,
          ),
          const SizedBox(height: 12),
          _buildHapticTypeToggle(
            title: 'Notification Haptic',
            subtitle: 'Vibrations for alerts and notifications',
            value: _hapticService.isNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _hapticService.setNotificationEnabled(value);
              });
            },
            onTest: () => _hapticService.notification(),
            icon: Icons.notifications,
          ),
        ],
      ),
    );
  }

  Widget _buildIntensitySettings() {
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
            'Intensity Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Intensity: ${(_hapticService.intensity * 100).toInt()}%',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          HapticSlider(
            value: _hapticService.intensity,
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              setState(() {
                _hapticService.setIntensity(value);
              });
            },
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            'Duration: ${_hapticService.duration}ms',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          HapticSlider(
            value: _hapticService.duration.toDouble(),
            min: 10.0,
            max: 1000.0,
            onChanged: (value) {
              setState(() {
                _hapticService.setDuration(value.round());
              });
            },
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
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
            'Test Haptic Feedback',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Try different haptic patterns to find your preference',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTestButton('Light', () => _hapticService.light()),
              _buildTestButton('Medium', () => _hapticService.medium()),
              _buildTestButton('Heavy', () => _hapticService.heavy()),
              _buildTestButton('Success', () => _hapticService.success()),
              _buildTestButton('Error', () => _hapticService.error()),
              _buildTestButton('Warning', () => _hapticService.warning()),
              _buildTestButton('Like', () => _hapticService.like()),
              _buildTestButton('Super Like', () => _hapticService.superLike()),
              _buildTestButton('Match', () => _hapticService.match()),
              _buildTestButton('Message', () => _hapticService.messageSent()),
              _buildTestButton('Swipe', () => _hapticService.swipeLeft()),
              _buildTestButton('Refresh', () => _hapticService.refresh()),
            ],
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
            subtitle: 'Reset all haptic settings to default values',
            icon: Icons.restore,
            onTap: _resetToDefault,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Stop All Vibrations',
            subtitle: 'Stop any currently playing vibrations',
            icon: Icons.stop,
            onTap: () => _hapticService.stop(),
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Haptic Feedback Help',
            subtitle: 'Learn more about haptic feedback features',
            icon: Icons.help_outline,
            onTap: _showHapticHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildHapticTypeToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required VoidCallback onTest,
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
        HapticButton(
          onPressed: onTest,
          hapticType: HapticType.light,
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.play_arrow,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        HapticSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
        ),
      ],
    );
  }

  Widget _buildTestButton(String label, VoidCallback onPressed) {
    return HapticButton(
      onPressed: onPressed,
      hapticType: HapticType.buttonPress,
      backgroundColor: AppColors.primary.withOpacity(0.2),
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      _hapticService.setEnabled(true);
      _hapticService.setLightEnabled(true);
      _hapticService.setMediumEnabled(true);
      _hapticService.setHeavyEnabled(true);
      _hapticService.setSelectionEnabled(true);
      _hapticService.setImpactEnabled(true);
      _hapticService.setNotificationEnabled(true);
      _hapticService.setIntensity(1.0);
      _hapticService.setDuration(100);
    });
  }

  void _showHapticHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Haptic Feedback Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Haptic feedback provides tactile responses to your interactions:\n\n'
          '• Light: Subtle vibrations for gentle interactions\n'
          '• Medium: Standard vibrations for normal interactions\n'
          '• Heavy: Strong vibrations for important interactions\n'
          '• Selection: Vibrations for list selections and switches\n'
          '• Impact: Vibrations for button presses and taps\n'
          '• Notification: Vibrations for alerts and notifications\n\n'
          'Customize intensity and duration to match your preference.',
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
