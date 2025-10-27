import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/haptic_feedback_service.dart';
import '../components/images/profile_image_editor.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onCancel;

  const ProfileEditScreen({
    Key? key,
    required this.initialData,
    this.onSave,
    this.onCancel,
  }) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _educationController = TextEditingController();

  String _selectedGender = '';
  String _selectedOrientation = '';
  String _selectedRelationshipStatus = '';
  List<String> _selectedInterests = [];
  String? _profileImagePath;

  bool _isLoading = false;
  int _currentStep = 0;
  final int _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  void _initializeData() {
    _nameController.text = widget.initialData['name'] ?? '';
    _ageController.text = widget.initialData['age']?.toString() ?? '';
    _bioController.text = widget.initialData['bio'] ?? '';
    _locationController.text = widget.initialData['location'] ?? '';
    _occupationController.text = widget.initialData['occupation'] ?? '';
    _educationController.text = widget.initialData['education'] ?? '';
    
    _selectedGender = widget.initialData['gender'] ?? '';
    _selectedOrientation = widget.initialData['orientation'] ?? '';
    _selectedRelationshipStatus = widget.initialData['relationshipStatus'] ?? '';
    _selectedInterests = List<String>.from(widget.initialData['interests'] ?? []);
    _profileImagePath = widget.initialData['profileImagePath'];
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  _buildProgressIndicator(),
                  Expanded(
                    child: _buildStepContent(),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.navbarBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textPrimaryDark),
        onPressed: () {
          HapticFeedbackService.selection();
          widget.onCancel?.call();
        },
      ),
      title: const Text(
        'Edit Profile',
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_currentStep == _totalSteps - 1)
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                    ),
                  )
                : const Text(
                    'Save',
                    style: AppTypography.button.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const Spacer(),
              Text(
                _getStepTitle(_currentStep),
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: AppColors.surfaceSecondary,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildInterestsStep();
      case 3:
        return _buildPhotosStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImageSection(),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Enter your name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              hint: 'Enter your age',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Age is required';
                }
                final age = int.tryParse(value);
                if (age == null || age < 18 || age > 100) {
                  return 'Please enter a valid age (18-100)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              hint: 'Tell us about yourself',
              maxLines: 4,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField(
            label: 'Gender',
            value: _selectedGender,
            items: const [
              'Male',
              'Female',
              'Non-binary',
              'Transgender',
              'Genderfluid',
              'Agender',
              'Other',
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value ?? '';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Sexual Orientation',
            value: _selectedOrientation,
            items: const [
              'Straight',
              'Gay',
              'Lesbian',
              'Bisexual',
              'Pansexual',
              'Asexual',
              'Demisexual',
              'Queer',
              'Other',
            ],
            onChanged: (value) {
              setState(() {
                _selectedOrientation = value ?? '';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Relationship Status',
            value: _selectedRelationshipStatus,
            items: const [
              'Single',
              'In a relationship',
              'Married',
              'Divorced',
              'Widowed',
              'It\'s complicated',
            ],
            onChanged: (value) {
              setState(() {
                _selectedRelationshipStatus = value ?? '';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'City, Country',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _occupationController,
            label: 'Occupation',
            hint: 'What do you do?',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _educationController,
            label: 'Education',
            hint: 'Your educational background',
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsStep() {
    final interests = [
      'Music', 'Movies', 'Sports', 'Travel', 'Food', 'Art', 'Photography',
      'Reading', 'Gaming', 'Fitness', 'Dancing', 'Cooking', 'Nature',
      'Technology', 'Fashion', 'Animals', 'Volunteering', 'Politics',
      'Religion', 'Philosophy', 'Science', 'History', 'Languages',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your interests',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose up to 10 interests that describe you',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest);
                    } else if (_selectedInterests.length < 10) {
                      _selectedInterests.add(interest);
                    }
                  });
                  HapticFeedbackService.selection();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryLight 
                        : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primaryLight 
                          : AppColors.borderDefault,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected 
                          ? Colors.white 
                          : AppColors.textPrimaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '${_selectedInterests.length}/10 selected',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Photos',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add photos to make your profile more attractive',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 20),
          ProfileImageEditor(
            currentImageUrl: widget.initialData['profileImageUrl'] ?? '',
            onImageChanged: (imagePath) {
              setState(() {
                _profileImagePath = imagePath;
              });
            },
            size: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          ProfileImageEditor(
            currentImageUrl: widget.initialData['profileImageUrl'] ?? '',
            onImageChanged: (imagePath) {
              setState(() {
                _profileImagePath = imagePath;
              });
            },
            size: 120,
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap to change profile photo',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
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
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < _totalSteps - 1 ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_currentStep < _totalSteps - 1 ? 'Next' : 'Complete'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _currentStep++;
    });
    HapticFeedbackService.selection();
  }

  void _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = {
        'name': _nameController.text,
        'age': int.tryParse(_ageController.text),
        'bio': _bioController.text,
        'gender': _selectedGender,
        'orientation': _selectedOrientation,
        'relationshipStatus': _selectedRelationshipStatus,
        'location': _locationController.text,
        'occupation': _occupationController.text,
        'education': _educationController.text,
        'interests': _selectedInterests,
        'profileImagePath': _profileImagePath,
      };

      await Future.delayed(const Duration(milliseconds: 1000)); // Simulate API call

      widget.onSave?.call(profileData);
      HapticFeedbackService.success();
    } catch (e) {
      HapticFeedbackService.error();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Personal Details';
      case 2:
        return 'Interests';
      case 3:
        return 'Photos';
      default:
        return '';
    }
  }
}
