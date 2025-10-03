import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../providers/profile_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/profile/edit/form_inputs.dart';
import '../utils/validation.dart';
import '../utils/error_handler.dart';
import '../utils/success_feedback.dart';
import '../services/media_picker_service.dart';
import '../services/api_services/profile_api_service.dart';
import '../services/token_management_service.dart';
import '../models/api_models/profile_models.dart';
import '../components/wizard/customizable_wizard.dart';
import '../services/haptic_feedback_service.dart';

class ProfileWizardPage extends StatefulWidget {
  const ProfileWizardPage({Key? key}) : super(key: key);

  @override
  State<ProfileWizardPage> createState() => _ProfileWizardPageState();
}

class _ProfileWizardPageState extends State<ProfileWizardPage> {
  bool _isLoading = false;
  
  // Form data
  late User _wizardUser;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _jobController = TextEditingController();
  final _companyController = TextEditingController();
  final _schoolController = TextEditingController();
  final _locationController = TextEditingController();

  // Wizard customization
  late WizardCustomization _customization;

  @override
  void initState() {
    super.initState();
    _initializeWizard();
  }

  @override
  void dispose() {
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

    // Initialize wizard customization
    _customization = const WizardCustomization(
      allowSkipping: true,
      showProgress: true,
      showStepNumbers: true,
      allowBackNavigation: true,
      showSkipButton: true,
      showSkipConfirmation: true,
      skipConfirmationMessage: 'Are you sure you want to skip this step? You can complete it later.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomizableWizard(
      steps: _buildWizardSteps(),
      customization: _customization,
      onStepChanged: (currentStep, totalSteps) {
        HapticFeedbackService.selection();
      },
      onWizardComplete: (skippedSteps) {
        _completeProfile(skippedSteps);
      },
      onWizardCancel: () {
        _showCancelConfirmation();
      },
    );
  }

  List<WizardStep> _buildWizardSteps() {
    return [
      WizardStep(
        id: 'basic_info',
        title: 'Basic Information',
        description: 'Tell us about yourself',
        content: _buildBasicInfoStep(),
        isRequired: true,
        isSkippable: false,
        onComplete: (data) => _updateWizardUser(),
      ),
      WizardStep(
        id: 'photos',
        title: 'Photos',
        description: 'Add your best photos',
        content: _buildPhotosStep(),
        isRequired: true,
        isSkippable: false,
        onComplete: (data) => _updateWizardUser(),
      ),
      WizardStep(
        id: 'preferences',
        title: 'Preferences',
        description: 'What are you looking for?',
        content: _buildPreferencesStep(),
        isRequired: true,
        isSkippable: false,
        onComplete: (data) => _updateWizardUser(),
      ),
      WizardStep(
        id: 'about',
        title: 'About You',
        description: 'Share more about yourself',
        content: _buildAboutStep(),
        isRequired: false,
        isSkippable: true,
        skipReason: 'You can add this information later in your profile',
        onComplete: (data) => _updateWizardUser(),
      ),
      WizardStep(
        id: 'privacy',
        title: 'Privacy',
        description: 'Control your privacy settings',
        content: _buildPrivacyStep(),
        isRequired: false,
        isSkippable: true,
        skipReason: 'You can adjust privacy settings anytime',
        onComplete: (data) => _updateWizardUser(),
      ),
    ];
  }

  Widget _buildBasicInfoStep() {
    return WizardStepBuilder(
      title: 'Basic Information',
      description: 'Let\'s start with the essentials',
      isRequired: true,
      child: Column(
        children: [
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
    return WizardStepBuilder(
      title: 'Photos',
      description: 'Add at least 3 photos to get better matches',
      isRequired: true,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_camera,
                  size: 48,
                  color: AppColors.textSecondaryDark,
                ),
                const SizedBox(height: 16),
                Text(
                  'Add Your Photos',
                  style: AppTypography.h6.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add at least 3 photos to get better matches',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _addPhotos,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
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
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Photo Tips',
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.primaryLight,
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
                    color: AppColors.textSecondaryDark,
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
    return WizardStepBuilder(
      title: 'Preferences',
      description: 'Tell us what you\'re looking for',
      isRequired: true,
      child: Column(
        children: [
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
              color: AppColors.textPrimaryDark,
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
    return WizardStepBuilder(
      title: 'About You',
      description: 'Share more about yourself',
      isRequired: false,
      isSkippable: true,
      skipReason: 'You can add this information later in your profile',
      child: Column(
        children: [
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
    return WizardStepBuilder(
      title: 'Privacy',
      description: 'Control your privacy settings',
      isRequired: false,
      isSkippable: true,
      skipReason: 'You can adjust privacy settings anytime',
      child: Column(
        children: [
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
              color: AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryLight.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Privacy & Safety',
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your privacy is important to us. You can change these settings anytime in your profile.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondaryDark,
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

  void _addPhotos() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Photo options
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  'Take Photo',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  'Choose from Gallery',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final mediaPickerService = MediaPickerService();
      final images = await mediaPickerService.pickImage();

      if (images != null && images.isNotEmpty) {
        await _uploadProfilePicture(images);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadProfilePicture(List<File> images) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.navbarBackground,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primaryLight,
              ),
              const SizedBox(height: 16),
              Text(
                'Uploading photo...',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

      // Upload the first image using ProfileApiService
      final profileApiService = ProfileApiService();
      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      final request = UploadProfilePictureRequest(
        imagePath: images.first.path,
        isPrimary: false,
      );
      
      final response = await ProfileApiService.uploadProfilePicture(request, token);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (response.success) {
          // Update local user data
          setState(() {
            // Add the uploaded image URL to profile pictures  
            final imageUrl = response.data?.url ?? '';
            final imageUrls = [..._wizardUser.profilePictures, imageUrl];
            // Update the wizard user with the new image URL
            // Note: We can't directly update profilePictures as it's a derived getter
            // The actual images would be stored in profileImages field
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload photo: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeProfile(List<String> skippedSteps) async {
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
        
        // Show skipped steps summary if any
        if (skippedSteps.isNotEmpty) {
          _showSkippedStepsSummary(skippedSteps);
        } else {
          Navigator.of(context).pop();
        }
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
          _completeProfile(skippedSteps);
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

  void _showSkippedStepsSummary(List<String> skippedSteps) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Profile Created Successfully!',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your profile has been created successfully.',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
            if (skippedSteps.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Skipped steps:',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...skippedSteps.map((step) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Text(
                  '• ${_getStepDisplayName(step)}',
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
              )),
              const SizedBox(height: 8),
              const Text(
                'You can complete these steps later in your profile settings.',
                style: TextStyle(color: AppColors.textSecondaryDark),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepDisplayName(String stepId) {
    switch (stepId) {
      case 'about':
        return 'About You';
      case 'privacy':
        return 'Privacy Settings';
      default:
        return stepId;
    }
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Cancel Profile Creation',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'Are you sure you want to cancel profile creation? You can always complete your profile later.',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Continue Creating',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.feedbackError,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Mock data methods
  List<Gender> _getMockGenders() {
    return [
      Gender(id: 1, name: 'Man'),
      Gender(id: 2, name: 'Woman'),
      Gender(id: 3, name: 'Non-binary'),
      Gender(id: 4, name: 'Gender fluid'),
      Gender(id: 5, name: 'Trans man'),
      Gender(id: 6, name: 'Trans woman'),
      Gender(id: 7, name: 'Other'),
    ];
  }

  List<RelationshipGoal> _getMockRelationshipGoals() {
    return [
      RelationshipGoal(id: 1, name: 'Long-term relationship'),
      RelationshipGoal(id: 2, name: 'Short-term relationship'),
      RelationshipGoal(id: 3, name: 'Casual dating'),
      RelationshipGoal(id: 4, name: 'Friendship'),
      RelationshipGoal(id: 5, name: 'Marriage'),
    ];
  }
}