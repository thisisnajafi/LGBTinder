import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/accessibility_service.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  final AccessibilityService _accessibilityService = AccessibilityService();
  
  bool _screenReaderEnabled = false;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _keyboardNavigationEnabled = false;
  bool _voiceOverEnabled = false;
  bool _reduceMotionEnabled = false;
  double _textScaleFactor = 1.0;
  double _contrastLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _loadAccessibilitySettings();
  }

  Future<void> _loadAccessibilitySettings() async {
    await _accessibilityService.initialize();
    
    setState(() {
      _screenReaderEnabled = _accessibilityService.isScreenReaderEnabled;
      _highContrastEnabled = _accessibilityService.isHighContrastEnabled;
      _largeTextEnabled = _accessibilityService.isLargeTextEnabled;
      _keyboardNavigationEnabled = _accessibilityService.isKeyboardNavigationEnabled;
      _textScaleFactor = _accessibilityService.textScaleFactor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
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
            _buildScreenReaderSettings(),
            const SizedBox(height: 24),
            _buildVisualSettings(),
            const SizedBox(height: 24),
            _buildInteractionSettings(),
            const SizedBox(height: 24),
            _buildAdvancedSettings(),
            const SizedBox(height: 24),
            _buildPreviewSection(),
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
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.accessibility_new,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Accessibility Settings',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your app experience for better accessibility',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScreenReaderSettings() {
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
            'Screen Reader',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Screen Reader Support',
            subtitle: 'Enable support for screen readers like TalkBack and VoiceOver',
            value: _screenReaderEnabled,
            onChanged: (value) {
              setState(() {
                _screenReaderEnabled = value;
              });
              _announceChange('Screen reader support ${value ? 'enabled' : 'disabled'}');
            },
            icon: Icons.screen_reader_desktop,
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Voice Over',
            subtitle: 'Enable voice descriptions for UI elements',
            value: _voiceOverEnabled,
            onChanged: (value) {
              setState(() {
                _voiceOverEnabled = value;
              });
              _announceChange('Voice over ${value ? 'enabled' : 'disabled'}');
            },
            icon: Icons.record_voice_over,
          ),
        ],
      ),
    );
  }

  Widget _buildVisualSettings() {
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
            'Visual Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'High Contrast',
            subtitle: 'Increase contrast for better visibility',
            value: _highContrastEnabled,
            onChanged: (value) {
              setState(() {
                _highContrastEnabled = value;
              });
              _announceChange('High contrast ${value ? 'enabled' : 'disabled'}');
            },
            icon: Icons.contrast,
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Large Text',
            subtitle: 'Increase text size for better readability',
            value: _largeTextEnabled,
            onChanged: (value) {
              setState(() {
                _largeTextEnabled = value;
              });
              _announceChange('Large text ${value ? 'enabled' : 'disabled'}');
            },
            icon: Icons.text_fields,
          ),
          const SizedBox(height: 16),
          Text(
            'Text Scale Factor: ${_textScaleFactor.toStringAsFixed(1)}x',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _textScaleFactor,
            min: 0.8,
            max: 2.0,
            divisions: 12,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _textScaleFactor = value;
              });
              _announceChange('Text scale factor set to ${value.toStringAsFixed(1)}x');
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Contrast Level: ${(_contrastLevel * 100).toInt()}%',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _contrastLevel,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _contrastLevel = value;
              });
              _announceChange('Contrast level set to ${(value * 100).toInt()}%');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionSettings() {
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
            'Interaction Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Keyboard Navigation',
            subtitle: 'Enable keyboard navigation support',
            value: _keyboardNavigationEnabled,
            onChanged: (value) {
              setState(() {
                _keyboardNavigationEnabled = value;
              });
              _announceChange('Keyboard navigation ${value ? 'enabled' : 'disabled'}');
            },
            icon: Icons.keyboard,
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Reduce Motion',
            subtitle: 'Reduce animations and motion effects',
            value: _reduceMotionEnabled,
            onChanged: (value) {
              setState(() {
                _reduceMotionEnabled = value;
              });
              _announceChange('Reduce motion ${value ? 'enabled' : 'disabled'}');
            },
            icon: Icons.motion_photos_off,
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
            subtitle: 'Reset all accessibility settings to default values',
            icon: Icons.restore,
            onTap: _resetToDefault,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Test Screen Reader',
            subtitle: 'Test screen reader functionality',
            icon: Icons.hearing,
            onTap: _testScreenReader,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Accessibility Help',
            subtitle: 'Learn more about accessibility features',
            icon: Icons.help_outline,
            onTap: _showAccessibilityHelp,
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
            'This is how text will appear with your current settings.',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
              fontSize: 16 * _textScaleFactor,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _announceChange('This is a sample button');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _highContrastEnabled ? Colors.white : AppColors.primary,
              foregroundColor: _highContrastEnabled ? Colors.black : Colors.white,
            ),
            child: Text(
              'Sample Button',
              style: TextStyle(
                fontSize: 16 * _textScaleFactor,
              ),
            ),
          ),
        ],
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

  void _announceChange(String message) {
    if (_screenReaderEnabled || _voiceOverEnabled) {
      AccessibilityService.announce(message);
    }
  }

  void _resetToDefault() {
    setState(() {
      _screenReaderEnabled = false;
      _highContrastEnabled = false;
      _largeTextEnabled = false;
      _keyboardNavigationEnabled = false;
      _voiceOverEnabled = false;
      _reduceMotionEnabled = false;
      _textScaleFactor = 1.0;
      _contrastLevel = 1.0;
    });
    _announceChange('Accessibility settings reset to default');
  }

  void _testScreenReader() {
    _announceChange('Screen reader test: This is a test of the screen reader functionality. You can hear this text being read aloud.');
  }

  void _showAccessibilityHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Accessibility Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Accessibility features help make the app usable for everyone:\n\n'
          '• Screen Reader: Reads text aloud for visually impaired users\n'
          '• High Contrast: Increases contrast for better visibility\n'
          '• Large Text: Increases text size for better readability\n'
          '• Keyboard Navigation: Enables keyboard-only navigation\n'
          '• Voice Over: Provides voice descriptions for UI elements\n'
          '• Reduce Motion: Reduces animations for motion-sensitive users',
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
