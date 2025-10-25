import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/haptic_feedback_service.dart';
import '../../components/buttons/animated_button.dart';

class OnboardingPreferences {
  final bool showAnimations;
  final bool enableHapticFeedback;
  final bool showProgressIndicator;
  final bool allowSkipping;
  final String preferredLanguage;
  final bool enableAccessibilityMode;
  final bool showDetailedFeatures;
  final bool enableAutoAdvance;

  const OnboardingPreferences({
    this.showAnimations = true,
    this.enableHapticFeedback = true,
    this.showProgressIndicator = true,
    this.allowSkipping = true,
    this.preferredLanguage = 'en',
    this.enableAccessibilityMode = false,
    this.showDetailedFeatures = true,
    this.enableAutoAdvance = false,
  });

  OnboardingPreferences copyWith({
    bool? showAnimations,
    bool? enableHapticFeedback,
    bool? showProgressIndicator,
    bool? allowSkipping,
    String? preferredLanguage,
    bool? enableAccessibilityMode,
    bool? showDetailedFeatures,
    bool? enableAutoAdvance,
  }) {
    return OnboardingPreferences(
      showAnimations: showAnimations ?? this.showAnimations,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      showProgressIndicator: showProgressIndicator ?? this.showProgressIndicator,
      allowSkipping: allowSkipping ?? this.allowSkipping,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      enableAccessibilityMode: enableAccessibilityMode ?? this.enableAccessibilityMode,
      showDetailedFeatures: showDetailedFeatures ?? this.showDetailedFeatures,
      enableAutoAdvance: enableAutoAdvance ?? this.enableAutoAdvance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showAnimations': showAnimations,
      'enableHapticFeedback': enableHapticFeedback,
      'showProgressIndicator': showProgressIndicator,
      'allowSkipping': allowSkipping,
      'preferredLanguage': preferredLanguage,
      'enableAccessibilityMode': enableAccessibilityMode,
      'showDetailedFeatures': showDetailedFeatures,
      'enableAutoAdvance': enableAutoAdvance,
    };
  }

  factory OnboardingPreferences.fromJson(Map<String, dynamic> json) {
    return OnboardingPreferences(
      showAnimations: json['showAnimations'] ?? true,
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
      showProgressIndicator: json['showProgressIndicator'] ?? true,
      allowSkipping: json['allowSkipping'] ?? true,
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      enableAccessibilityMode: json['enableAccessibilityMode'] ?? false,
      showDetailedFeatures: json['showDetailedFeatures'] ?? true,
      enableAutoAdvance: json['enableAutoAdvance'] ?? false,
    );
  }
}

class OnboardingPreferencesScreen extends StatefulWidget {
  final OnboardingPreferences initialPreferences;
  final Function(OnboardingPreferences)? onPreferencesChanged;

  const OnboardingPreferencesScreen({
    Key? key,
    required this.initialPreferences,
    this.onPreferencesChanged,
  }) : super(key: key);

  @override
  State<OnboardingPreferencesScreen> createState() => _OnboardingPreferencesScreenState();
}

class _OnboardingPreferencesScreenState extends State<OnboardingPreferencesScreen> {
  late OnboardingPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.initialPreferences;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () {
            HapticFeedbackService.selection();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Onboarding Preferences',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize your onboarding experience',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Display Options',
              children: [
                _buildSwitchTile(
                  title: 'Show Animations',
                  subtitle: 'Enable smooth animations and transitions',
                  value: _preferences.showAnimations,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(showAnimations: value);
                    });
                    HapticFeedbackService.selection();
                  },
                ),
                _buildSwitchTile(
                  title: 'Show Progress Indicator',
                  subtitle: 'Display progress bar and step numbers',
                  value: _preferences.showProgressIndicator,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(showProgressIndicator: value);
                    });
                    HapticFeedbackService.selection();
                  },
                ),
                _buildSwitchTile(
                  title: 'Show Detailed Features',
                  subtitle: 'Display feature lists on each step',
                  value: _preferences.showDetailedFeatures,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(showDetailedFeatures: value);
                    });
                    HapticFeedbackService.selection();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Interaction Options',
              children: [
                _buildSwitchTile(
                  title: 'Enable Haptic Feedback',
                  subtitle: 'Provide tactile feedback for interactions',
                  value: _preferences.enableHapticFeedback,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(enableHapticFeedback: value);
                    });
                    HapticFeedbackService.selection();
                  },
                ),
                _buildSwitchTile(
                  title: 'Allow Skipping Steps',
                  subtitle: 'Enable skip button on each step',
                  value: _preferences.allowSkipping,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(allowSkipping: value);
                    });
                    HapticFeedbackService.selection();
                  },
                ),
                _buildSwitchTile(
                  title: 'Auto Advance',
                  subtitle: 'Automatically advance to next step after delay',
                  value: _preferences.enableAutoAdvance,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(enableAutoAdvance: value);
                    });
                    HapticFeedbackService.selection();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Accessibility',
              children: [
                _buildSwitchTile(
                  title: 'Accessibility Mode',
                  subtitle: 'Enhanced accessibility features and larger text',
                  value: _preferences.enableAccessibilityMode,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(enableAccessibilityMode: value);
                    });
                    HapticFeedbackService.selection();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Language',
              children: [
                _buildLanguageSelector(),
              ],
            ),
            
            const SizedBox(height: 32),
            
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
            title,
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: AppTypography.body1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.body2.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryLight,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLanguageSelector() {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'it', 'name': 'Italiano'},
      {'code': 'pt', 'name': 'Português'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Language',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _preferences.preferredLanguage,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryLight),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          dropdownColor: AppColors.surfaceSecondary,
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          items: languages.map((language) {
            return DropdownMenuItem<String>(
              value: language['code'],
              child: Text(language['name']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _preferences = _preferences.copyWith(preferredLanguage: value);
              });
              HapticFeedbackService.selection();
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _preferences = widget.initialPreferences;
              });
              HapticFeedbackService.selection();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.borderDefault),
              foregroundColor: AppColors.textPrimaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onPreferencesChanged?.call(_preferences);
              HapticFeedbackService.success();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
