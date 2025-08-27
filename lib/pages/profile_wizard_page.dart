import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/profile_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/profile/edit/form_inputs.dart';
import '../utils/validation.dart';
import '../utils/error_handler.dart';
import '../utils/success_feedback.dart';

class ProfileWizardPage extends StatefulWidget {
  const ProfileWizardPage({Key? key}) : super(key: key);

  @override
  State<ProfileWizardPage> createState() => _ProfileWizardPageState();
}

class _ProfileWizardPageState extends State<ProfileWizardPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Form data
  late User _wizardUser;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _jobController = TextEditingController();
  final _companyController = TextEditingController();
  final _schoolController = TextEditingController();
  final _locationController = TextEditingController();

  // Wizard steps
  final List<WizardStep> _steps = [
    WizardStep(
      title: 'Basic Information',
      subtitle: 'Tell us about yourself',
      icon: Icons.person,
      isRequired: true,
    ),
    WizardStep(
      title: 'Photos',
      subtitle: 'Add your best photos',
      icon: Icons.photo_camera,
      isRequired: true,
    ),
    WizardStep(
      title: 'Preferences',
      subtitle: 'What are you looking for?',
      icon: Icons.favorite,
      isRequired: true,
    ),
    WizardStep(
      title: 'About You',
      subtitle: 'Share more about yourself',
      icon: Icons.info,
      isRequired: false,
    ),
    WizardStep(
      title: 'Privacy',
      subtitle: 'Control your privacy settings',
      icon: Icons.security,
      isRequired: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeWizard();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _jobController.dispose();
    _companyController.dispose();
    _schoolController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initializeWizard() {
    final profileProvider = context.read<ProfileProvider>();
    _wizardUser = profileProvider.user?.copyWith() ?? User.empty();
    
    // Initialize form controllers with existing data
    _nameController.text = _wizardUser.name ?? '';
    _bioController.text = _wizardUser.bio ?? '';
    _jobController.text = _wizardUser.job ?? '';
    _companyController.text = _wizardUser.company ?? '';
    _schoolController.text = _wizardUser.school ?? '';
    _locationController.text = _wizardUser.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Progress indicator
            _buildProgressIndicator(),
            
            // Content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildBasicInfoStep(),
                    _buildPhotosStep(),
                    _buildPreferencesStep(),
                    _buildAboutStep(),
                    _buildPrivacyStep(),
                  ],
                ),
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Create Your Profile',
                  style: AppTypography.headline6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of ${_steps.length}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_currentStep > 0)
            TextButton(
              onPressed: _skipWizard,
              child: Text(
                'Skip',
                style: AppTypography.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${((_currentStep + 1) / _steps.length * 100).round()}%',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: AppColors.greyLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(_steps[0]),
          const SizedBox(height: 24),
          
          ProfileTextInput(
            label: 'Full Name',
            value: _nameController.text,
            onChanged: (value) {
              _nameController.text = value;
              _updateWizardUser();
            },
            isRequired: true,
            maxLength: 50,
            hint: 'Enter your full name',
          ),
          
          const SizedBox(height: 16),
          
          ProfileDatePicker(
            label: 'Birth Date',
            selectedDate: _wizardUser.birthDate,
            isRequired: true,
            onDateSelected: (date) {
              setState(() {
                _wizardUser = _wizardUser.copyWith(birthDate: date);
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          ProfileDropdownInput<Gender>(
            label: 'Gender',
            selectedValue: _wizardUser.gender != null 
                ? _getMockGenders().firstWhere(
                    (g) => g.title == _wizardUser.gender,
                    orElse: () => _getMockGenders().first,
                  )
                : null,
            options: _getMockGenders(),
            isRequired: true,
            onChanged: (gender) {
              setState(() {
                _wizardUser = _wizardUser.copyWith(gender: gender?.title);
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          ProfileTextInput(
            label: 'Location',
            value: _locationController.text,
            onChanged: (value) {
              _locationController.text = value;
              _updateWizardUser();
            },
            maxLength: 100,
            hint: 'City, Country',
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(_steps[1]),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_camera,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Add Your Photos',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add at least 3 photos to get better matches',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _addPhotos,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Photo tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Photo Tips',
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Use clear, well-lit photos\n'
                  '• Show your face clearly in the first photo\n'
                  '• Include photos that show your interests\n'
                  '• Avoid group photos or heavily filtered images',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(_steps[2]),
          const SizedBox(height: 24),
          
          ProfileMultiSelectInput<Gender>(
            label: 'Interested In',
            selectedValues: _wizardUser.interestedIn ?? [],
            options: _getMockGenders(),
            isRequired: true,
            onChanged: (genders) {
              setState(() {
                _wizardUser = _wizardUser.copyWith(interestedIn: genders);
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          ProfileDropdownInput<RelationshipGoal>(
            label: 'Looking for',
            selectedValue: _wizardUser.relationshipGoal,
            options: _getMockRelationshipGoals(),
            onChanged: (goal) {
              setState(() {
                _wizardUser = _wizardUser.copyWith(relationshipGoal: goal);
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Age Range',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          ProfileRangeSlider(
            label: 'Age Range',
            value: RangeValues(
              (_wizardUser.preferences?.minAge ?? 18).toDouble(),
              (_wizardUser.preferences?.maxAge ?? 50).toDouble(),
            ),
            min: 18,
            max: 100,
            divisions: 82,
            displayText: (value) => '${value.round()} years',
            onChanged: (range) {
              setState(() {
                _wizardUser = _wizardUser.copyWith(
                  preferences: (_wizardUser.preferences ?? UserPreferences.empty()).copyWith(
                    minAge: range.start.round(),
                    maxAge: range.end.round(),
                  ),
                );
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          ProfileRangeSlider(
            label: 'Distance Range (km)',
            value: RangeValues(
              (_wizardUser.preferences?.maxDistance ?? 50).toDouble(),
              (_wizardUser.preferences?.maxDistance ?? 100).toDouble(),
            ),
            min: 1,
            max: 500,
            divisions: 499,
            displayText: (value) => '${value.round()} km',
            onChanged: (range) {
              setState(() {
                _wizardUser = _wizardUser.copyWith(
                  preferences: (_wizardUser.preferences ?? UserPreferences.empty()).copyWith(
                    maxDistance: range.end.round().toDouble(),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(_steps[3]),
          const SizedBox(height: 24),
          
          ProfileTextInput(
            label: 'Bio',
            value: _bioController.text,
            onChanged: (value) {
              _bioController.text = value;
              _updateWizardUser();
            },
            maxLines: 4,
            maxLength: 500,
            hint: 'Tell others about yourself, your interests, and what you\'re looking for...',
          ),
          
          const SizedBox(height: 16),
          
          ProfileTextInput(
            label: 'Job Title',
            value: _jobController.text,
            onChanged: (value) {
              _jobController.text = value;
              _updateWizardUser();
            },
            maxLength: 100,
            hint: 'What do you do?',
          ),
          
          const SizedBox(height: 16),
          
          ProfileTextInput(
            label: 'Company',
            value: _companyController.text,
            onChanged: (value) {
              _companyController.text = value;
              _updateWizardUser();
            },
            maxLength: 100,
            hint: 'Where do you work?',
          ),
          
          const SizedBox(height: 16),
          
          ProfileTextInput(
            label: 'School',
            value: _schoolController.text,
            onChanged: (value) {
              _schoolController.text = value;
              _updateWizardUser();
            },
            maxLength: 100,
            hint: 'Where did you study?',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(_steps[4]),
          const SizedBox(height: 24),
          
          ProfileToggleSwitch(
            label: 'Show my age',
            description: 'Other users will see your exact age',
            value: _wizardUser.settings?.showAge ?? true,
            onChanged: (value) {
              setState(() {
                _wizardUser = _wizardUser.copyWith(
                  settings: (_wizardUser.settings ?? UserSettings.empty()).copyWith(
                    showAge: value,
                  ),
                );
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          ProfileToggleSwitch(
            label: 'Show my distance',
            description: 'Other users will see your approximate distance',
            value: _wizardUser.settings?.showDistance ?? true,
            onChanged: (value) {
              setState(() {
                _wizardUser = _wizardUser.copyWith(
                  settings: (_wizardUser.settings ?? UserSettings.empty()).copyWith(
                    showDistance: value,
                  ),
                );
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Privacy & Safety',
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your privacy is important to us. You can change these settings anytime in your profile.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(WizardStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                step.icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTypography.h6.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    step.subtitle,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (step.isRequired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: AppTypography.button.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == _steps.length - 1 ? 'Complete Profile' : 'Next',
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateWizardUser() {
    setState(() {
      _wizardUser = _wizardUser.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        job: _jobController.text.trim(),
        company: _companyController.text.trim(),
        school: _schoolController.text.trim(),
        location: _locationController.text.trim(),
      );
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() async {
    // Validate current step
    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete profile
      await _completeProfile();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Info
        final nameError = ValidationUtils.validateName(_nameController.text.trim(), 'Name');
        if (nameError != null) {
          _showValidationError(nameError);
          return false;
        }
        
        final birthDateError = ValidationUtils.validateAge(_wizardUser.birthDate);
        if (birthDateError != null) {
          _showValidationError(birthDateError);
          return false;
        }
        
        final genderError = ValidationUtils.validateGender(_wizardUser.gender);
        if (genderError != null) {
          _showValidationError(genderError);
          return false;
        }
        break;
        
      case 1: // Photos
        final photoError = ValidationUtils.validatePhotoCount(_wizardUser.images, minCount: 1);
        if (photoError != null) {
          _showValidationError(photoError);
          return false;
        }
        break;
        
      case 2: // Preferences
        final interestedInError = ValidationUtils.validateInterestedIn(_wizardUser.interestedIn);
        if (interestedInError != null) {
          _showValidationError(interestedInError);
          return false;
        }
        
        final ageRangeError = ValidationUtils.validateAgeRange(
          _wizardUser.preferences?.minAge,
          _wizardUser.preferences?.maxAge,
        );
        if (ageRangeError != null) {
          _showValidationError(ageRangeError);
          return false;
        }
        
        final distanceError = ValidationUtils.validateDistanceRange(_wizardUser.preferences?.maxDistance);
        if (distanceError != null) {
          _showValidationError(distanceError);
          return false;
        }
        break;
    }
    return true;
  }

  void _showValidationError(String message) {
    ErrorHandler.showErrorSnackBar(
      context,
      message: message,
    );
  }

  void _addPhotos() {
    // TODO: Implement photo upload functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo upload feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _completeProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update user data from form controllers
      _updateWizardUser();

      // Validate complete profile
      final validationErrors = ValidationUtils.validateProfile(
        name: _wizardUser.name,
        birthDate: _wizardUser.birthDate,
        gender: _wizardUser.gender,
        location: _wizardUser.location,
        bio: _wizardUser.bio,
        jobTitle: _wizardUser.job,
        company: _wizardUser.company,
        school: _wizardUser.school,
        photos: _wizardUser.images,
        interestedIn: _wizardUser.interestedIn,
        minAge: _wizardUser.preferences?.minAge,
        maxAge: _wizardUser.preferences?.maxAge,
        maxDistance: _wizardUser.preferences?.maxDistance,
      );

      if (validationErrors.isNotEmpty) {
        final firstError = validationErrors.values.first;
        if (firstError != null) {
          ErrorHandler.showErrorSnackBar(
            context,
            message: firstError,
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Show loading indicator
      SuccessFeedback.showLoadingIndicator(
        context,
        message: 'Creating your profile...',
      );

      final profileProvider = context.read<ProfileProvider>();
      
      // Use retry mechanism for API call
      await ErrorHandler.retryOperation(
        operation: () => profileProvider.updateProfile(_wizardUser.toJson()),
        maxRetries: 3,
        shouldRetry: ErrorHandler.isRetryableError,
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      if (mounted) {
        // Show completion celebration
        await SuccessFeedback.showProfileCompletionCelebration(
          context,
          completionPercentage: 100,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        // Show error with retry option
        final errorMessage = ErrorHandler.getErrorMessage(e);
        final shouldRetry = await ErrorHandler.showRetryDialog(
          context,
          message: errorMessage,
          title: 'Profile Creation Failed',
        );

        if (shouldRetry) {
          _completeProfile();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipWizard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Profile Creation'),
        content: const Text(
          'Are you sure you want to skip profile creation? You can always complete your profile later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  // Mock data methods
  List<Gender> _getMockGenders() {
    return [
      Gender(id: 1, title: 'Man'),
      Gender(id: 2, title: 'Woman'),
      Gender(id: 3, title: 'Non-binary'),
      Gender(id: 4, title: 'Gender fluid'),
      Gender(id: 5, title: 'Trans man'),
      Gender(id: 6, title: 'Trans woman'),
      Gender(id: 7, title: 'Other'),
    ];
  }

  List<RelationshipGoal> _getMockRelationshipGoals() {
    return [
      RelationshipGoal(id: 1, title: 'Long-term relationship'),
      RelationshipGoal(id: 2, title: 'Short-term relationship'),
      RelationshipGoal(id: 3, title: 'Casual dating'),
      RelationshipGoal(id: 4, title: 'Friendship'),
      RelationshipGoal(id: 5, title: 'Marriage'),
    ];
  }
}

class WizardStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isRequired;

  WizardStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isRequired = false,
  });
}
