import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../models/api_models/reference_data_models.dart';
import '../../models/user_state_models.dart';
import '../../services/api_services/reference_data_api_service.dart';
import '../../services/validation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/error_monitoring_service.dart';
import '../../services/secure_error_handler.dart';
import '../../services/cache_service.dart';
import '../../providers/app_state_provider.dart';
import '../../components/error_handling/error_display_widget.dart';
import '../../components/error_handling/error_snackbar.dart';
import '../../components/loading/loading_widgets.dart';
import '../../components/loading/skeleton_loader.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingReferenceData = true;

  // Form controllers
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  
  // Age slider values
  double _minAgeSlider = 18.0;
  double _maxAgeSlider = 100.0;

  // Form data
  DateTime? _birthDate;
  int? _selectedGender;
  int? _selectedCountryId;
  int? _selectedCityId;
  List<int> _selectedMusicGenres = [];
  List<int> _selectedEducations = [];
  List<int> _selectedJobs = [];
  List<int> _selectedLanguages = [];
  List<int> _selectedInterests = [];
  List<int> _selectedPreferredGenders = [];
  List<int> _selectedRelationGoals = [];
  bool _smoke = false;
  bool _drink = false;
  bool _gym = false;

  // Reference data
  List<Country> _countries = [];
  List<City> _cities = [];
  List<ReferenceDataItem> _genders = [];
  List<ReferenceDataItem> _musicGenres = [];
  List<ReferenceDataItem> _educations = [];
  List<ReferenceDataItem> _jobs = [];
  List<ReferenceDataItem> _languages = [];
  List<ReferenceDataItem> _interests = [];
  List<ReferenceDataItem> _preferredGenders = [];
  List<ReferenceDataItem> _relationGoals = [];

  final List<String> _stepTitles = [
    'Basic Information',
    'Physical Information',
    'Preferences',
    'Music & Interests',
    'Education & Career',
    'Relationship Goals',
    'Review & Complete',
  ];

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    try {
      print('🔄 Loading reference data for profile completion...');
      
      // Load all reference data in parallel
      final results = await Future.wait([
        ReferenceDataApiService.getCountries(),
        ReferenceDataApiService.getGenders(),
        ReferenceDataApiService.getMusicGenres(),
        ReferenceDataApiService.loadAllReferenceData(),
        ReferenceDataApiService.getJobs(),
        ReferenceDataApiService.getLanguages(),
        ReferenceDataApiService.getInterests(),
        ReferenceDataApiService.getPreferredGenders(),
        ReferenceDataApiService.getRelationGoals(),
      ]);
      
      print('✅ Reference data loaded successfully');
      
      setState(() {
        _countries = results[0] as List<Country>;
        _genders = results[1] as List<ReferenceDataItem>;
        _musicGenres = results[2] as List<ReferenceDataItem>;
        _educations = results[3] as List<ReferenceDataItem>;
        _jobs = results[4] as List<ReferenceDataItem>;
        _languages = results[5] as List<ReferenceDataItem>;
        _interests = results[6] as List<ReferenceDataItem>;
        _preferredGenders = results[7] as List<ReferenceDataItem>;
        _relationGoals = results[8] as List<ReferenceDataItem>;
        _isLoadingReferenceData = false;
      });
      
      print('📊 Loaded data: ${_countries.length} countries, ${_genders.length} genders, ${_musicGenres.length} music genres, ${_educations.length} educations, ${_jobs.length} jobs, ${_languages.length} languages, ${_interests.length} interests, ${_preferredGenders.length} preferred genders, ${_relationGoals.length} relation goals');
    } catch (e) {
      print('❌ Failed to load reference data: $e');
      setState(() {
        _isLoadingReferenceData = false;
      });
      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'load_reference_data',
          onAction: _loadReferenceData,
          actionText: 'Retry',
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0: // Basic Information
        final isAgeValid = _birthDate != null && _calculateAge(_birthDate!) >= 18;
        return _selectedCountryId != null &&
               _selectedCityId != null &&
               _selectedGender != null &&
               _birthDate != null &&
               isAgeValid;
      case 1: // Physical Information
        return _heightController.text.isNotEmpty &&
               _weightController.text.isNotEmpty &&
               _bioController.text.isNotEmpty;
      case 2: // Preferences
        return _selectedPreferredGenders.isNotEmpty &&
               _minAgeSlider <= _maxAgeSlider;
      case 3: // Music & Interests
        return _selectedMusicGenres.isNotEmpty &&
               _selectedInterests.isNotEmpty;
      case 4: // Education & Career
        return _selectedEducations.isNotEmpty &&
               _selectedJobs.isNotEmpty &&
               _selectedLanguages.isNotEmpty;
      case 5: // Relationship Goals
        return _selectedRelationGoals.isNotEmpty;
      case 6: // Review
        return true;
      default:
        return false;
    }
  }

  Future<void> _completeProfile() async {
    if (!_canProceedToNextStep()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Starting profile completion process...');
      final appState = context.read<AppStateProvider>();
      
      print('🔑 Using app state provider for profile completion...');

      final profileData = {
        'device_name': 'Flutter App',
        'country_id': _selectedCountryId!,
        'city_id': _selectedCityId!,
        'gender': _selectedGender!,
        'birth_date': _birthDate!.toIso8601String().split('T')[0],
        'min_age_preference': _minAgeSlider.round(),
        'max_age_preference': _maxAgeSlider.round(),
        'profile_bio': _bioController.text,
        'height': int.parse(_heightController.text),
        'weight': int.parse(_weightController.text),
        'smoke': _smoke,
        'drink': _drink,
        'gym': _gym,
        'music_genres': _selectedMusicGenres,
        'educations': _selectedEducations,
        'jobs': _selectedJobs,
        'languages': _selectedLanguages,
        'interests': _selectedInterests,
        'preferred_genders': _selectedPreferredGenders,
        'relation_goals': _selectedRelationGoals,
      };

      final result = await appState.completeProfile(profileData);

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to main app
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        throw Exception(result.message);
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'complete_profile',
          onAction: _completeProfile,
          actionText: 'Try Again',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingReferenceData) {
      return LoadingWidgets.fullScreen(
        text: 'Loading profile options...',
      );
    }

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complete Your Profile',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimaryDark),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _stepTitles[_currentStep],
                  style: AppTypography.h2.copyWith(color: AppColors.textPrimaryDark),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _stepTitles.length,
                  backgroundColor: AppColors.cardBackgroundDark,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentStep + 1} of ${_stepTitles.length}',
                  style: AppTypography.body2.copyWith(color: AppColors.textSecondaryDark),
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
                _buildPhysicalInfoStep(),
                _buildPreferencesStep(),
                _buildMusicInterestsStep(),
                _buildEducationCareerStep(),
                _buildRelationshipGoalsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentStep > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _previousStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardBackgroundDark,
                          foregroundColor: AppColors.textPrimaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_currentStep == _stepTitles.length - 1 ? _completeProfile : _nextStep),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canProceedToNextStep() ? AppColors.primary : AppColors.cardBackgroundDark,
                      foregroundColor: _canProceedToNextStep() ? Colors.white : AppColors.textSecondaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? LoadingWidgets.button(
                            text: _currentStep == _stepTitles.length - 1 ? 'Completing Profile...' : 'Loading...',
                            color: Colors.white,
                          )
                        : Text(_currentStep == _stepTitles.length - 1 ? 'Complete Profile' : 'Next'),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCountrySelection(),
          const SizedBox(height: 20),
          _buildCitySelection(),
          const SizedBox(height: 20),
          _buildGenderSelection(),
          const SizedBox(height: 20),
          _buildBirthDateSelection(),
        ],
      ),
    );
  }

  Widget _buildPhysicalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'Enter your height',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _weightController,
            label: 'Weight (kg)',
            hint: 'Enter your weight',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _bioController,
            label: 'Bio',
            hint: 'Tell us about yourself...',
            maxLines: 4,
            maxLength: 500,
          ),
          const SizedBox(height: 20),
          _buildLifestylePreferences(),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAgeRangeSlider(),
          const SizedBox(height: 20),
          _buildPreferredGendersSelection(),
        ],
      ),
    );
  }

  Widget _buildMusicInterestsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMultiSelection(
            title: 'Music Genres',
            items: _musicGenres,
            selectedItems: _selectedMusicGenres,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedMusicGenres = selected;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildMultiSelection(
            title: 'Interests',
            items: _interests,
            selectedItems: _selectedInterests,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedInterests = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEducationCareerStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMultiSelection(
            title: 'Education',
            items: _educations,
            selectedItems: _selectedEducations,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedEducations = selected;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildMultiSelection(
            title: 'Jobs',
            items: _jobs,
            selectedItems: _selectedJobs,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedJobs = selected;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildMultiSelection(
            title: 'Languages',
            items: _languages,
            selectedItems: _selectedLanguages,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedLanguages = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipGoalsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMultiSelection(
            title: 'Relationship Goals',
            items: _relationGoals,
            selectedItems: _selectedRelationGoals,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedRelationGoals = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Information',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 20),
          _buildReviewItem('Country', _getCountryName(_selectedCountryId)),
          _buildReviewItem('City', _getCityName(_selectedCityId)),
          _buildReviewItem('Gender', _getGenderTitle(_selectedGender)),
          _buildReviewItem('Birth Date', _birthDate?.toIso8601String().split('T')[0] ?? 'Not set'),
          _buildReviewItem('Height', '${_heightController.text} cm'),
          _buildReviewItem('Weight', '${_weightController.text} kg'),
          _buildReviewItem('Bio', _bioController.text),
          _buildReviewItem('Age Preference', '${_minAgeSlider.round()} - ${_maxAgeSlider.round()}'),
          _buildReviewItem('Music Genres', _getSelectedItemsTitle('music_genres', _selectedMusicGenres)),
          _buildReviewItem('Interests', _getSelectedItemsTitle('interests', _selectedInterests)),
          _buildReviewItem('Education', _getSelectedItemsTitle('education', _selectedEducations)),
          _buildReviewItem('Jobs', _getSelectedItemsTitle('jobs', _selectedJobs)),
          _buildReviewItem('Languages', _getSelectedItemsTitle('languages', _selectedLanguages)),
          _buildReviewItem('Preferred Genders', _getSelectedItemsTitle('preferred_genders', _selectedPreferredGenders)),
          _buildReviewItem('Relationship Goals', _getSelectedItemsTitle('relation_goals', _selectedRelationGoals)),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(color: AppColors.textPrimaryDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
            filled: true,
            fillColor: AppColors.cardBackgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelection() {
    final countries = _countries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCountryId,
              hint: Text(
                'Select your country',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              isExpanded: true,
              style: AppTypography.body2.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              dropdownColor: AppColors.cardBackgroundDark,
              items: countries.map((country) {
                return DropdownMenuItem<int>(
                  value: country.id,
                  child: Text(country.name),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    _selectedCountryId = value;
                    _selectedCityId = null; // Reset city when country changes
                    _cities = [];
                  });
                  
                  // Fetch cities for selected country
                  try {
                    final citiesData = await ReferenceDataApiService.getCitiesByCountry(value.toString());
                    final cities = citiesData.map((data) => City.fromJson(data)).toList();
                    setState(() {
                      _cities = cities;
                    });
                  } catch (e) {
                    print('Error fetching cities: $e');
                    if (mounted) {
                      ErrorSnackBar.show(
                        context,
                        error: e,
                        errorContext: 'load_cities',
                        onAction: () async {
                          try {
                            final citiesData = await ReferenceDataApiService.getCitiesByCountry(value.toString());
                            final cities = citiesData.map((data) => City.fromJson(data)).toList();
                            setState(() {
                              _cities = cities;
                            });
                          } catch (e) {
                            // Error will be handled by ErrorSnackBar
                          }
                        },
                        actionText: 'Retry',
                      );
                    }
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCitySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedCityId,
              hint: Text(
                _selectedCountryId == null 
                    ? 'Select country first' 
                    : 'Select your city',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              isExpanded: true,
              style: AppTypography.body2.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              dropdownColor: AppColors.cardBackgroundDark,
              items: _cities.map((city) {
                return DropdownMenuItem<int>(
                  value: city.id,
                  child: Text(city.name),
                );
              }).toList(),
              onChanged: _selectedCountryId == null ? null : (value) {
                setState(() {
                  _selectedCityId = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    final genders = _genders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: genders.map((gender) {
            final isSelected = _selectedGender == gender.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = gender.id;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardBackgroundDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDark,
                  ),
                ),
                child: Text(
                  gender.title,
                  style: AppTypography.body2.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBirthDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Date',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 years ago
            );
            if (date != null) {
              final age = _calculateAge(date);
              if (age < 18) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You must be at least 18 years old to use this app.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              setState(() {
                _birthDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _birthDate?.toIso8601String().split('T')[0] ?? 'Select your birth date',
                    style: AppTypography.body2.copyWith(
                      color: _birthDate != null ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, color: AppColors.textSecondaryDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLifestylePreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lifestyle Preferences',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildLifestyleOption('Smoke', _smoke, (value) {
          setState(() {
            _smoke = value;
          });
        }),
        _buildLifestyleOption('Drink', _drink, (value) {
          setState(() {
            _drink = value;
          });
        }),
        _buildLifestyleOption('Gym/Fitness', _gym, (value) {
          setState(() {
            _gym = value;
          });
        }),
      ],
    );
  }

  Widget _buildLifestyleOption(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: AppColors.primary,
          ),
          Text(
            title,
            style: AppTypography.body2.copyWith(color: AppColors.textPrimaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferredGendersSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Genders',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _preferredGenders.map((gender) {
            final isSelected = _selectedPreferredGenders.contains(gender.id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedPreferredGenders.remove(gender.id);
                  } else {
                    _selectedPreferredGenders.add(gender.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardBackgroundDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDark,
                  ),
                ),
                child: Text(
                  gender.title,
                  style: AppTypography.body2.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiSelection({
    required String title,
    required List<ReferenceDataItem> items,
    required List<int> selectedItems,
    required Function(List<int>) onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item.id);
            return GestureDetector(
              onTap: () {
                final newSelection = List<int>.from(selectedItems);
                if (isSelected) {
                  newSelection.remove(item.id);
                } else {
                  newSelection.add(item.id);
                }
                onSelectionChanged(newSelection);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardBackgroundDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderDark,
                  ),
                ),
                child: Text(
                  item.title,
                  style: AppTypography.body2.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child:             Text(
              '$label:',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body2.copyWith(color: AppColors.textPrimaryDark),
            ),
          ),
        ],
      ),
    );
  }

  String _getCountryName(int? countryId) {
    if (countryId == null) return 'Not selected';
    final countries = _countries;
    final country = countries.firstWhere((c) => c.id == countryId, orElse: () => Country(id: 0, name: 'Unknown', code: '', phoneCode: ''));
    return country.name;
  }

  String _getCityName(int? cityId) {
    if (cityId == null) return 'Not selected';
    final city = _cities.firstWhere((c) => c.id == cityId, orElse: () => City(id: 0, name: 'Unknown', countryId: 0));
    return city.name;
  }

  String _getGenderTitle(int? genderId) {
    if (genderId == null) return 'Not selected';
    final genders = _genders;
    final gender = genders.firstWhere((g) => g.id == genderId, orElse: () => ReferenceDataItem(id: 0, title: 'Unknown', status: 'active', imageUrl: ''));
    return gender.title;
  }

  String _getSelectedItemsTitle(String category, List<int> selectedIds) {
    if (selectedIds.isEmpty) return 'None selected';
    
    List<ReferenceDataItem> items;
    switch (category) {
      case 'music_genres':
        items = _musicGenres;
        break;
      case 'educations':
        items = _educations;
        break;
      case 'jobs':
        items = _jobs;
        break;
      case 'languages':
        items = _languages;
        break;
      case 'interests':
        items = _interests;
        break;
      case 'preferred_genders':
        items = _preferredGenders;
        break;
      case 'relation_goals':
        items = _relationGoals;
        break;
      default:
        items = [];
    }
    
    final selectedItems = items.where((item) => selectedIds.contains(item.id));
    return selectedItems.map((item) => item.title).join(', ');
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildAgeRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Age Preference',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        // Range slider with square labels above thumbs
        LayoutBuilder(
          builder: (context, constraints) {
            final sliderWidth = constraints.maxWidth - 48; // Account for padding
            final minPosition = ((_minAgeSlider - 18) / (100 - 18)) * sliderWidth;
            final maxPosition = ((_maxAgeSlider - 18) / (100 - 18)) * sliderWidth;
            
            return Stack(
              children: [
                RangeSlider(
                  values: RangeValues(_minAgeSlider, _maxAgeSlider),
                  min: 18,
                  max: 100,
                  divisions: 82, // 100 - 18 = 82 divisions
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.borderDark,
                  onChanged: (RangeValues values) {
                    setState(() {
                      _minAgeSlider = values.start;
                      _maxAgeSlider = values.end;
                    });
                  },
                ),
                // Min age square above left thumb
                Positioned(
                  left: minPosition + 24 - 15, // Center the square above thumb
                  top: -35,
                  child: Container(
                    width: 30,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${_minAgeSlider.round()}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                // Max age square above right thumb
                Positioned(
                  left: maxPosition + 24 - 15, // Center the square above thumb
                  top: -35,
                  child: Container(
                    width: 30,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${_maxAgeSlider.round()}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
