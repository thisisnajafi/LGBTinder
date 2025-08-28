import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import 'profile_completion_welcome_screen.dart';

class ProfileWizardScreen extends StatefulWidget {
  const ProfileWizardScreen({super.key});

  @override
  State<ProfileWizardScreen> createState() => _ProfileWizardScreenState();
}

class _ProfileWizardScreenState extends State<ProfileWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;
  
  // Step data
  final Map<String, dynamic> _stepData = {};
  
  // Step titles
  final List<String> _stepTitles = [
    'Basic Information',
    'Identity & Preferences',
    'Physical & Lifestyle',
    'Background Information',
    'Matching Preferences',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveStepData(String stepKey, Map<String, dynamic> data) {
    _stepData[stepKey] = data;
    print('Saved data for $stepKey: $data'); // Debug print
  }

  double get _completionPercentage => (_currentStep / (_totalSteps - 1)) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Setup',
          style: AppTypography.h6.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Save progress and navigate to main app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress saved! You can continue later.'),
                ),
              );
              Navigator.pop(context);
            },
            child: Text(
              'Save & Exit',
              style: AppTypography.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of $_totalSteps',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${_completionPercentage.round()}% Complete',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Progress bar
                LinearProgressIndicator(
                  value: _completionPercentage / 100,
                  backgroundColor: AppColors.greyMedium,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                
                const SizedBox(height: 16),
                
                // Step title
                Text(
                  _stepTitles[_currentStep],
                  style: AppTypography.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildIdentityPreferencesStep(),
                _buildPhysicalLifestyleStep(),
                _buildBackgroundInfoStep(),
                _buildMatchingPreferencesStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Back button
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Back',
                        style: AppTypography.button.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                
                if (_currentStep > 0) const SizedBox(width: 16),
                
                // Next/Complete button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == _totalSteps - 1 ? _completeProfile : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1 ? 'Complete Profile' : 'Next',
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_outline,
            title: 'Basic Information',
            subtitle: 'Tell us about yourself',
          ),
          
          const SizedBox(height: 24),
          
          // Profile Photo
          _buildInputField(
            label: 'Profile Photo',
            hint: 'Upload a profile photo',
            icon: Icons.camera_alt_outlined,
            isRequired: true,
            onChanged: (value) {
              _saveStepData('basic_info', {'photo': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Bio
          _buildInputField(
            label: 'Bio',
            hint: 'Tell us about yourself (optional)',
            icon: Icons.edit_note_outlined,
            isRequired: false,
            maxLines: 4,
            onChanged: (value) {
              _saveStepData('basic_info', {'bio': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // City
          _buildInputField(
            label: 'City',
            hint: 'Enter your city',
            icon: Icons.location_city_outlined,
            isRequired: true,
            onChanged: (value) {
              _saveStepData('basic_info', {'city': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Country
          _buildInputField(
            label: 'Country',
            hint: 'Select your country',
            icon: Icons.public_outlined,
            isRequired: true,
            onChanged: (value) {
              _saveStepData('basic_info', {'country': value});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.favorite_outline,
            title: 'Identity & Preferences',
            subtitle: 'Help us understand your preferences',
          ),
          
          const SizedBox(height: 24),
          
          // Gender Identity
          _buildDropdownField(
            label: 'Gender Identity',
            hint: 'Select your gender identity',
            icon: Icons.person_outline,
            isRequired: true,
            options: ['Man', 'Woman', 'Non-binary', 'Gender fluid', 'Other'],
            onChanged: (value) {
              _saveStepData('identity_preferences', {'gender': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Sexual Orientation
          _buildDropdownField(
            label: 'Sexual Orientation',
            hint: 'Select your sexual orientation',
            icon: Icons.favorite_outline,
            isRequired: true,
            options: ['Gay', 'Lesbian', 'Bisexual', 'Pansexual', 'Asexual', 'Other'],
            onChanged: (value) {
              _saveStepData('identity_preferences', {'orientation': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Relationship Goals
          _buildMultiSelectField(
            label: 'Relationship Goals',
            hint: 'Select your relationship goals',
            icon: Icons.favorite_border,
            isRequired: true,
            options: [
              'Long-term relationship',
              'Casual dating',
              'Friendship',
              'Marriage',
              'Not sure yet'
            ],
            onChanged: (values) {
              _saveStepData('identity_preferences', {'goals': values});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalLifestyleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.fitness_center,
            title: 'Physical & Lifestyle',
            subtitle: 'Share your lifestyle preferences',
          ),
          
          const SizedBox(height: 24),
          
          // Height
          _buildInputField(
            label: 'Height',
            hint: 'Enter your height',
            icon: Icons.height,
            isRequired: false,
            onChanged: (value) {
              _saveStepData('physical_lifestyle', {'height': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Weight
          _buildInputField(
            label: 'Weight',
            hint: 'Enter your weight',
            icon: Icons.monitor_weight_outlined,
            isRequired: false,
            onChanged: (value) {
              _saveStepData('physical_lifestyle', {'weight': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Smoking
          _buildRadioField(
            label: 'Do you smoke?',
            icon: Icons.smoking_rooms_outlined,
            isRequired: true,
            options: ['Yes', 'No', 'Sometimes'],
            onChanged: (value) {
              _saveStepData('physical_lifestyle', {'smoking': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Gym
          _buildRadioField(
            label: 'Do you go to the gym?',
            icon: Icons.fitness_center,
            isRequired: true,
            options: ['Yes', 'No', 'Sometimes'],
            onChanged: (value) {
              _saveStepData('physical_lifestyle', {'gym': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Drinking
          _buildRadioField(
            label: 'Do you drink alcohol?',
            icon: Icons.local_bar_outlined,
            isRequired: true,
            options: ['Yes', 'No', 'Sometimes'],
            onChanged: (value) {
              _saveStepData('physical_lifestyle', {'drinking': value});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.school_outlined,
            title: 'Background Information',
            subtitle: 'Tell us about your background',
          ),
          
          const SizedBox(height: 24),
          
          // Education
          _buildMultiSelectField(
            label: 'Education',
            hint: 'Select your education level',
            icon: Icons.school_outlined,
            isRequired: false,
            options: [
              'High School',
              'Some College',
              'Bachelor\'s Degree',
              'Master\'s Degree',
              'PhD',
              'Other'
            ],
            onChanged: (values) {
              _saveStepData('background_info', {'education': values});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Job/Profession
          _buildMultiSelectField(
            label: 'Job/Profession',
            hint: 'Select your profession',
            icon: Icons.work_outline,
            isRequired: false,
            options: [
              'Student',
              'Technology',
              'Healthcare',
              'Education',
              'Finance',
              'Creative Arts',
              'Service Industry',
              'Other'
            ],
            onChanged: (values) {
              _saveStepData('background_info', {'profession': values});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Languages
          _buildMultiSelectField(
            label: 'Languages Spoken',
            hint: 'Select languages you speak',
            icon: Icons.language,
            isRequired: false,
            options: [
              'English',
              'Spanish',
              'French',
              'German',
              'Italian',
              'Portuguese',
              'Chinese',
              'Japanese',
              'Korean',
              'Other'
            ],
            onChanged: (values) {
              _saveStepData('background_info', {'languages': values});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Interests
          _buildMultiSelectField(
            label: 'Interests & Hobbies',
            hint: 'Select your interests',
            icon: Icons.interests_outlined,
            isRequired: false,
            options: [
              'Music',
              'Movies',
              'Reading',
              'Travel',
              'Cooking',
              'Sports',
              'Gaming',
              'Art',
              'Photography',
              'Dancing',
              'Other'
            ],
            onChanged: (values) {
              _saveStepData('background_info', {'interests': values});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.tune,
            title: 'Matching Preferences',
            subtitle: 'Set your matching criteria',
          ),
          
          const SizedBox(height: 24),
          
          // Age Range
          _buildRangeSliderField(
            label: 'Age Range',
            icon: Icons.cake_outlined,
            isRequired: true,
            minValue: 18,
            maxValue: 80,
            currentMin: 25,
            currentMax: 45,
            onChanged: (min, max) {
              _saveStepData('matching_preferences', {'ageRange': [min, max]});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Distance Range
          _buildSliderField(
            label: 'Maximum Distance',
            icon: Icons.location_on_outlined,
            isRequired: true,
            minValue: 1,
            maxValue: 100,
            currentValue: 25,
            unit: 'km',
            onChanged: (value) {
              _saveStepData('matching_preferences', {'maxDistance': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          // Privacy Settings
          _buildSwitchField(
            label: 'Show My Age',
            icon: Icons.visibility,
            isRequired: true,
            value: true,
            onChanged: (value) {
              _saveStepData('matching_preferences', {'showAge': value});
            },
          ),
          
          const SizedBox(height: 20),
          
          _buildSwitchField(
            label: 'Show My Distance',
            icon: Icons.location_on,
            isRequired: true,
            value: true,
            onChanged: (value) {
              _saveStepData('matching_preferences', {'showDistance': value});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 48,
          color: AppColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTypography.body1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required bool isRequired,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.body1.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.greyMedium),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.greyMedium),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.navbarBackground,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required bool isRequired,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.body1.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyMedium),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.navbarBackground,
          ),
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Select an option',
            ),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: AppColors.navbarBackground,
            icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required String hint,
    required IconData icon,
    required bool isRequired,
    required List<String> options,
    required Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.body1.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: false,
              onSelected: (selected) {
                // TODO: Implement multi-selection logic
                onChanged([option]);
              },
              backgroundColor: AppColors.navbarBackground,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadioField({
    required String label,
    required IconData icon,
    required bool isRequired,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.body1.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: null, // TODO: Implement state management
              onChanged: onChanged,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRangeSliderField({
    required String label,
    required IconData icon,
    required bool isRequired,
    required double minValue,
    required double maxValue,
    required double currentMin,
    required double currentMax,
    required Function(double, double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.body1.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: RangeValues(currentMin, currentMax),
          min: minValue,
          max: maxValue,
          divisions: (maxValue - minValue).round(),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.greyMedium,
          onChanged: (values) {
            onChanged(values.start, values.end);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${currentMin.round()} years',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${currentMax.round()} years',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliderField({
    required String label,
    required IconData icon,
    required bool isRequired,
    required double minValue,
    required double maxValue,
    required double currentValue,
    required String unit,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: AppTypography.body1.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: currentValue,
          min: minValue,
          max: maxValue,
          divisions: (maxValue - minValue).round(),
          activeColor: AppColors.primary,
          inactiveColor: AppColors.greyMedium,
          onChanged: onChanged,
        ),
        Text(
          '${currentValue.round()} $unit',
          style: AppTypography.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String label,
    required IconData icon,
    required bool isRequired,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
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

  void _completeProfile() {
    // TODO: Implement profile completion logic
    print('Profile data: $_stepData'); // Debug print
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile completed successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
    
    // Navigate to main app
    Navigator.pop(context);
  }
}
