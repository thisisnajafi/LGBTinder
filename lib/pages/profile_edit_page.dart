import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/profile_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/profile/edit/edit_header.dart';
import '../components/profile/edit/form_inputs.dart';
import '../components/profile/edit/photo_management.dart';

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
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _jobController = TextEditingController();
  final _companyController = TextEditingController();
  final _schoolController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
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

  void _initializeForm() {
    final profileProvider = context.read<ProfileProvider>();
    _editingUser = profileProvider.user?.copyWith() ?? User.empty();
    
    _nameController.text = _editingUser.name ?? '';
    _bioController.text = _editingUser.bio ?? '';
    _jobController.text = _editingUser.job ?? '';
    _companyController.text = _editingUser.company ?? '';
    _schoolController.text = _editingUser.school ?? '';
    _locationController.text = _editingUser.location ?? '';
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onImagesChanged(List<UserImage> images) {
    setState(() {
      _editingUser = _editingUser.copyWith(images: images);
      _hasChanges = true;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update user data from form controllers
      _editingUser = _editingUser.copyWith(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        job: _jobController.text.trim(),
        company: _companyController.text.trim(),
        school: _schoolController.text.trim(),
        location: _locationController.text.trim(),
      );

      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.updateProfile(_editingUser.toJson());

      setState(() {
        _hasChanges = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addPhoto() {
    // TODO: Implement photo upload functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo upload feature coming soon!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            EditHeader(
              title: 'Edit Profile',
              onBackPressed: () => Navigator.pop(context),
              onSavePressed: _hasChanges ? _saveProfile : null,
              isSaveEnabled: _hasChanges,
              isSaving: _isSaving,
              completionPercentage: _calculateCompletionPercentage(),
            ),
            
            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photos section
                      PhotoManagement(
                        images: _editingUser.images ?? [],
                        onImagesChanged: _onImagesChanged,
                        onAddPhoto: _addPhoto,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Basic Information
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 16),
                      
                      ProfileTextInput(
                        label: 'Name',
                        value: _nameController.text,
                        onChanged: (value) {
                          _nameController.text = value;
                          _onFieldChanged();
                        },
                        isRequired: true,
                        maxLength: 50,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ProfileDatePicker(
                        label: 'Birth Date',
                        selectedDate: _editingUser.birthDate,
                        isRequired: true,
                        onDateSelected: (date) {
                          setState(() {
                            _editingUser = _editingUser.copyWith(birthDate: date);
                            _onFieldChanged();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ProfileDropdownInput<Gender>(
                        label: 'Gender',
                        selectedValue: _editingUser.gender != null 
                            ? _getMockGenders().firstWhere(
                                (g) => g.title == _editingUser.gender,
                                orElse: () => _getMockGenders().first,
                              )
                            : null,
                        options: _getMockGenders(),
                        isRequired: true,
                        onChanged: (gender) {
                          setState(() {
                            _editingUser = _editingUser.copyWith(gender: gender?.title);
                            _onFieldChanged();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ProfileMultiSelectInput<Gender>(
                        label: 'Interested In',
                        selectedValues: _editingUser.interestedIn ?? [],
                        options: _getMockGenders(),
                        isRequired: true,
                        onChanged: (genders) {
                          setState(() {
                            _editingUser = _editingUser.copyWith(interestedIn: genders);
                            _onFieldChanged();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // About Me
                      _buildSectionHeader('About Me'),
                      const SizedBox(height: 16),
                      
                      ProfileTextInput(
                        label: 'Bio',
                        value: _bioController.text,
                        onChanged: (value) {
                          _bioController.text = value;
                          _onFieldChanged();
                        },
                        maxLines: 4,
                        maxLength: 500,
                        hint: 'Tell others about yourself...',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ProfileDropdownInput<RelationshipGoal>(
                        label: 'Looking for',
                        selectedValue: _editingUser.relationshipGoal,
                        options: _getMockRelationshipGoals(),
                        onChanged: (goal) {
                          setState(() {
                            _editingUser = _editingUser.copyWith(relationshipGoal: goal);
                            _onFieldChanged();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Work & Education
                      _buildSectionHeader('Work & Education'),
                      const SizedBox(height: 16),
                      
                      ProfileTextInput(
                        label: 'Job Title',
                        value: _jobController.text,
                        onChanged: (value) {
                          _jobController.text = value;
                          _onFieldChanged();
                        },
                        maxLength: 100,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ProfileTextInput(
                        label: 'Company',
                        value: _companyController.text,
                        onChanged: (value) {
                          _companyController.text = value;
                          _onFieldChanged();
                        },
                        maxLength: 100,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ProfileTextInput(
                        label: 'School',
                        value: _schoolController.text,
                        onChanged: (value) {
                          _schoolController.text = value;
                          _onFieldChanged();
                        },
                        maxLength: 100,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Location
                      _buildSectionHeader('Location'),
                      const SizedBox(height: 16),
                      
                      ProfileTextInput(
                        label: 'Location',
                        value: _locationController.text,
                        onChanged: (value) {
                          _locationController.text = value;
                          _onFieldChanged();
                        },
                        maxLength: 100,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ProfileRangeSlider(
                        label: 'Distance Range (km)',
                        value: RangeValues(
                          (_editingUser.preferences?.maxDistance ?? 50).toDouble(),
                          (_editingUser.preferences?.maxDistance ?? 100).toDouble(),
                        ),
                        min: 1,
                        max: 500,
                        divisions: 499,
                        displayText: (value) => '${value.round()} km',
                        onChanged: (range) {
                          setState(() {
                            _editingUser = _editingUser.copyWith(
                              preferences: (_editingUser.preferences ?? UserPreferences.empty()).copyWith(
                                maxDistance: range.end.round().toDouble(),
                              ),
                            );
                            _onFieldChanged();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Age Preferences
                      _buildSectionHeader('Age Preferences'),
                      const SizedBox(height: 16),
                      
                      ProfileRangeSlider(
                        label: 'Age Range',
                        value: RangeValues(
                          _editingUser.preferences?.minAge?.toDouble() ?? 18,
                          _editingUser.preferences?.maxAge?.toDouble() ?? 50,
                        ),
                        min: 18,
                        max: 100,
                        divisions: 82,
                        displayText: (value) => '${value.round()} years',
                        onChanged: (range) {
                          setState(() {
                            _editingUser = _editingUser.copyWith(
                              preferences: (_editingUser.preferences ?? UserPreferences.empty()).copyWith(
                                minAge: range.start.round(),
                                maxAge: range.end.round(),
                              ),
                            );
                            _onFieldChanged();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Privacy Settings
                      _buildSectionHeader('Privacy Settings'),
                      const SizedBox(height: 16),
                      
                      ProfileToggleSwitch(
                        label: 'Show my age',
                        description: 'Other users will see your exact age',
                        value: _editingUser.settings?.showAge ?? true,
                        onChanged: (value) {
                          setState(() {
                            _editingUser = _editingUser.copyWith(
                              settings: (_editingUser.settings ?? UserSettings.empty()).copyWith(
                                showAge: value,
                              ),
                            );
                            _onFieldChanged();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      ProfileToggleSwitch(
                        label: 'Show my distance',
                        description: 'Other users will see your approximate distance',
                        value: _editingUser.settings?.showDistance ?? true,
                        onChanged: (value) {
                          setState(() {
                            _editingUser = _editingUser.copyWith(
                              settings: (_editingUser.settings ?? UserSettings.empty()).copyWith(
                                showDistance: value,
                              ),
                            );
                            _onFieldChanged();
                          });
                        },
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.h6.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  int _calculateCompletionPercentage() {
    int completedFields = 0;
    int totalFields = 0;

    // Basic Information (4 required fields)
    totalFields += 4;
    if (_editingUser.name?.isNotEmpty == true) completedFields++;
    if (_editingUser.birthDate != null) completedFields++;
    if (_editingUser.gender != null) completedFields++;
    if (_editingUser.interestedIn?.isNotEmpty == true) completedFields++;

    // About Me (1 optional field)
    totalFields += 1;
    if (_editingUser.bio?.isNotEmpty == true) completedFields++;

    // Photos (at least 1 required)
    totalFields += 1;
    if (_editingUser.images?.isNotEmpty == true) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }

  // Mock data methods - these would be replaced with actual API calls
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
