import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/api_models/user_models.dart';
import '../providers/profile_state_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/profile/edit/edit_header.dart';
import '../components/profile/edit/form_inputs.dart';
import '../components/profile/edit/photo_management.dart';
import '../components/error_handling/error_snackbar.dart';
import '../components/loading/loading_widgets.dart';
import '../components/offline/offline_wrapper.dart';
import '../services/validation_service.dart';
import '../services/analytics_service.dart';
import '../services/error_monitoring_service.dart';
import '../services/media_picker_service.dart';
import '../services/profile_api_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late User _editingUser;
  bool _hasChanges = false;
  bool _isSaving = false;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final profileProvider = context.read<ProfileStateProvider>();
    _editingUser = profileProvider.currentUser ?? User.empty();
    
    _firstNameController.text = _editingUser.firstName ?? '';
    _lastNameController.text = _editingUser.lastName ?? '';
    _bioController.text = _editingUser.bio ?? '';
    _heightController.text = _editingUser.height?.toString() ?? '';
    _weightController.text = _editingUser.weight?.toString() ?? '';
    _locationController.text = _editingUser.location ?? '';
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onImagesChanged(List<String> images) {
    setState(() {
      _editingUser = _editingUser.copyWith(profilePictures: images);
      _hasChanges = true;
    });
  }

  Future<void> _saveProfile() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      ErrorSnackBar.show(
        context,
        error: Exception('Please fix the errors in the form before saving.'),
        context: 'profile_edit_validation',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AnalyticsService.trackEvent(
        action: 'profile_save_attempt',
        category: 'profile',
      );

      final profileProvider = context.read<ProfileStateProvider>();
      
      // Create updated user object
      final updatedUser = _editingUser.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        bio: _bioController.text.trim(),
        height: int.tryParse(_heightController.text.trim()),
        weight: int.tryParse(_weightController.text.trim()),
        location: _locationController.text.trim(),
      );

      // Update profile
      await profileProvider.updateProfile(updatedUser);

      if (mounted) {
        await AnalyticsService.trackEvent(
          action: 'profile_save_success',
          category: 'profile',
        );

        ErrorSnackBar.showSuccess(
          context,
          message: 'Profile updated successfully!',
        );

        Navigator.pop(context);
      }
    } catch (e) {
      await AnalyticsService.trackEvent(
        action: 'profile_save_failed',
        category: 'profile',
      );

      await ErrorMonitoringService.logError(
        error: e,
        context: 'ProfileEditPage._saveProfile',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'profile_save',
          onAction: _saveProfile,
          actionText: 'Try Again',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _addPhoto() {
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
                  color: AppColors.textSecondary,
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
      final image = await mediaPickerService.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image != null) {
        await _uploadProfilePicture(image);
      }
    } catch (e) {
      await ErrorMonitoringService.logError(
        error: e,
        context: 'ProfileEditPage._pickImage',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'pick_image',
        );
      }
    }
  }

  Future<void> _uploadProfilePicture(File image) async {
    final profileProvider = context.read<ProfileStateProvider>();
    
    try {
      await AnalyticsService.trackEvent(
        action: 'profile_picture_upload',
        category: 'profile',
      );

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
                color: AppColors.primary,
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

      // Upload the image
      final success = await profileProvider.uploadProfilePicture(image);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          // Update local user data
          setState(() {
            _editingUser = profileProvider.currentUser!;
            _hasChanges = true;
          });
          
          ErrorSnackBar.showInfo(
            context,
            message: 'Photo uploaded successfully!',
          );
        } else {
          ErrorSnackBar.show(
            context,
            error: Exception('Failed to upload photo'),
            context: 'upload_photo',
            onAction: () => _uploadProfilePicture(image),
            actionText: 'Retry',
          );
        }
      }
    } catch (e) {
      await AnalyticsService.trackEvent(
        action: 'profile_picture_upload_failed',
        category: 'profile',
      );

      await ErrorMonitoringService.logError(
        error: e,
        context: 'ProfileEditPage._uploadProfilePicture',
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'upload_photo',
          onAction: () => _uploadProfilePicture(image),
          actionText: 'Retry',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? LoadingWidgets.button(
                      text: 'Saving...',
                      color: AppColors.primary,
                    )
                  : Text(
                      'Save',
                      style: AppTypography.button.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
            ),
        ],
      ),
      body: OfflineWrapper(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo Section
                _buildPhotoSection(),
                const SizedBox(height: 24),
                
                // Basic Information Section
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                
                // Physical Information Section
                _buildPhysicalInfoSection(),
                const SizedBox(height: 24),
                
                // Location Section
                _buildLocationSection(),
                const SizedBox(height: 24),
                
                // Bio Section
                _buildBioSection(),
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? LoadingWidgets.button(
                            text: 'Saving Profile...',
                            color: Colors.white,
                          )
                        : Text(
                            'Save Profile',
                            style: AppTypography.button.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Photos',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add Photos',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                onChanged: (_) => _onFieldChanged(),
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                onChanged: (_) => _onFieldChanged(),
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Physical Information',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _heightController,
                onChanged: (_) => _onFieldChanged(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final height = int.tryParse(value);
                    if (height == null || height < 100 || height > 250) {
                      return 'Please enter a valid height';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                onChanged: (_) => _onFieldChanged(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final weight = int.tryParse(value);
                    if (weight == null || weight < 30 || weight > 200) {
                      return 'Please enter a valid weight';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _locationController,
          onChanged: (_) => _onFieldChanged(),
          decoration: InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: AppTypography.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bioController,
          onChanged: (_) => _onFieldChanged(),
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Tell us about yourself',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Bio must be less than 500 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
