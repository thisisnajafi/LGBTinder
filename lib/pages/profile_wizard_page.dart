import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/models.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/media_picker_service.dart';
import '../services/haptic_feedback_service.dart';
import '../services/api_services/profile_api_service.dart';
import '../services/api_services/reference_data_api_service.dart';
import '../services/token_management_service.dart';
import '../models/api_models/profile_models.dart';

class ProfileWizardPage extends StatefulWidget {
  const ProfileWizardPage({Key? key}) : super(key: key);

  @override
  State<ProfileWizardPage> createState() => _ProfileWizardPageState();
}

class _ProfileWizardPageState extends State<ProfileWizardPage> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;
  
  int _currentStep = 0;
  final int _totalSteps = 7;
  bool _isLoading = false;
  
  // Form data - using Map format
  DateTime? _birthDate;
  Map<String, dynamic>? _selectedGender;
  String? _selectedCountryId;
  String? _selectedCityId;
  List<File> _photos = [];
  String _bio = '';
  Map<String, dynamic>? _selectedJob;
  Map<String, dynamic>? _selectedEducation;
  List<Map<String, dynamic>> _preferredGenders = [];
  Map<String, dynamic>? _relationGoal;
  List<Map<String, dynamic>> _selectedInterests = [];
  List<Map<String, dynamic>> _selectedLanguages = [];
  List<Map<String, dynamic>> _selectedMusicGenres = [];
  // Additional form data
  int _minAgePreference = 18;
  int _maxAgePreference = 50;
  int _height = 170;
  int _weight = 70;
  bool _smoke = false;
  bool _drink = false;
  bool _gym = false;
  // Data lists - using Map format to match API response
  List<Map<String, dynamic>> _genders = [];
  List<Map<String, dynamic>> _preferredGenderOptions = [];
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _educationLevels = [];
  List<Map<String, dynamic>> _relationGoals = [];
  List<Map<String, dynamic>> _interests = [];
  List<Map<String, dynamic>> _languages = [];
  List<Map<String, dynamic>> _musicGenres = [];
  Map<String, dynamic> _countries = {};
  Map<String, List<dynamic>> _citiesByCountry = {};
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadReferenceData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all reference data from API endpoints
      final data = await ReferenceDataApiService.loadAllReferenceData();
      
      setState(() {
        // Parse genders - using Map format
        _genders = (data['genders'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ?? [];
        
        // Parse preferred genders - using Map format
        _preferredGenderOptions = (data['preferredGenders'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ?? [];
        
        // Parse jobs - using Map format
        _jobs = (data['jobs'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ?? [];
        
        // Parse education - using Map format
        _educationLevels = (data['education'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ?? [];
        
        // Parse relation goals - using Map format
        _relationGoals = (data['relationGoals'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ?? [];
        
        // Parse interests - using Map format
        _interests = (data['interests'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ?? [];
        
        // Parse languages - using Map format
        _languages = (data['languages'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ?? [];
        
        // Parse music genres - using Map format
        _musicGenres = (data['musicGenres'] as List<dynamic>?)
            ?.map((item) => Map<String, dynamic>.from(item))
            .toList() ?? [];
        
        // Parse countries - convert to Map format
        final countriesList = (data['countries'] as List<dynamic>?) ?? [];
        _countries = {};
        for (final country in countriesList) {
          final countryMap = Map<String, dynamic>.from(country);
          _countries[countryMap['id'].toString()] = countryMap;
        }
        
        _isLoading = false;
      });
      
      print('✅ Successfully loaded all reference data from backend');
      print('📊 Data counts:');
      print('   - Genders: ${_genders.length}');
      print('   - Preferred Genders: ${_preferredGenderOptions.length}');
      print('   - Jobs: ${_jobs.length}');
      print('   - Education: ${_educationLevels.length}');
      print('   - Relation Goals: ${_relationGoals.length}');
      print('   - Interests: ${_interests.length}');
      print('   - Languages: ${_languages.length}');
      print('   - Music Genres: ${_musicGenres.length}');
      print('   - Countries: ${_countries.length}');
      
    } catch (e) {
      print('❌ Error loading reference data from backend: $e');
      print('🔄 Loading fallback data...');
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    setState(() {
      // Fallback gender data - using API format with title field
      _genders = [
        {'id': 1, 'title': 'Male', 'image_url': 'https://lg.abolfazlnajafi.com/storage/male.png'},
        {'id': 2, 'title': 'Female', 'image_url': 'https://lg.abolfazlnajafi.com/storage/female.png'},
        {'id': 3, 'title': 'Trans Male', 'image_url': 'https://lg.abolfazlnajafi.com/storage/trans-male.png'},
        {'id': 4, 'title': 'Trans Female', 'image_url': 'https://lg.abolfazlnajafi.com/storage/trans-female.png'},
        {'id': 5, 'title': 'Demiboy', 'image_url': 'https://lg.abolfazlnajafi.com/storage/demiboy.png'},
        {'id': 6, 'title': 'Demigirl', 'image_url': 'https://lg.abolfazlnajafi.com/storage/demigirl.png'},
        {'id': 7, 'title': 'Non-Binary', 'image_url': 'https://lg.abolfazlnajafi.com/storage/non-binary.png'},
        {'id': 8, 'title': 'Genderqueer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/genderqueer.png'},
        {'id': 9, 'title': 'Gender Fluid', 'image_url': 'https://lg.abolfazlnajafi.com/storage/gender-fluid.png'},
        {'id': 10, 'title': 'Agender', 'image_url': 'https://lg.abolfazlnajafi.com/storage/agender.png'},
        {'id': 11, 'title': 'Bigender', 'image_url': 'https://lg.abolfazlnajafi.com/storage/bigender.png'},
        {'id': 12, 'title': 'Neutrois', 'image_url': 'https://lg.abolfazlnajafi.com/storage/neutrois.png'},
        {'id': 13, 'title': 'Two-Spirit', 'image_url': 'https://lg.abolfazlnajafi.com/storage/two-spirit.png'},
        {'id': 14, 'title': 'Hijra', 'image_url': 'https://lg.abolfazlnajafi.com/storage/hijra.png'},
        {'id': 15, 'title': 'Fa\'afafine', 'image_url': 'https://lg.abolfazlnajafi.com/storage/faafafine.png'},
        {'id': 16, 'title': 'Bakla', 'image_url': 'https://lg.abolfazlnajafi.com/storage/bakla.png'},
        {'id': 17, 'title': 'Kathoey', 'image_url': 'https://lg.abolfazlnajafi.com/storage/kathoey.png'},
        {'id': 18, 'title': 'Questioning', 'image_url': 'https://lg.abolfazlnajafi.com/storage/questioning.png'},
        {'id': 19, 'title': 'Other', 'image_url': 'https://lg.abolfazlnajafi.com/storage/other.png'},
      ];
      
      // Fallback preferred genders
      _preferredGenderOptions = [
        {'id': 1, 'title': 'Male', 'image_url': 'https://lg.abolfazlnajafi.com/storage/male.png'},
        {'id': 2, 'title': 'Female', 'image_url': 'https://lg.abolfazlnajafi.com/storage/female.png'},
        {'id': 3, 'title': 'Trans Male', 'image_url': 'https://lg.abolfazlnajafi.com/storage/trans-male.png'},
        {'id': 4, 'title': 'Trans Female', 'image_url': 'https://lg.abolfazlnajafi.com/storage/trans-female.png'},
        {'id': 5, 'title': 'Demiboy', 'image_url': 'https://lg.abolfazlnajafi.com/storage/demiboy.png'},
        {'id': 6, 'title': 'Demigirl', 'image_url': 'https://lg.abolfazlnajafi.com/storage/demigirl.png'},
        {'id': 7, 'title': 'Non-Binary', 'image_url': 'https://lg.abolfazlnajafi.com/storage/non-binary.png'},
        {'id': 8, 'title': 'Genderqueer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/genderqueer.png'},
        {'id': 9, 'title': 'Gender Fluid', 'image_url': 'https://lg.abolfazlnajafi.com/storage/gender-fluid.png'},
        {'id': 10, 'title': 'Agender', 'image_url': 'https://lg.abolfazlnajafi.com/storage/agender.png'},
        {'id': 11, 'title': 'Bigender', 'image_url': 'https://lg.abolfazlnajafi.com/storage/bigender.png'},
        {'id': 12, 'title': 'Neutrois', 'image_url': 'https://lg.abolfazlnajafi.com/storage/neutrois.png'},
        {'id': 13, 'title': 'Two-Spirit', 'image_url': 'https://lg.abolfazlnajafi.com/storage/two-spirit.png'},
        {'id': 14, 'title': 'Hijra', 'image_url': 'https://lg.abolfazlnajafi.com/storage/hijra.png'},
        {'id': 15, 'title': 'Fa\'afafine', 'image_url': 'https://lg.abolfazlnajafi.com/storage/faafafine.png'},
        {'id': 16, 'title': 'Bakla', 'image_url': 'https://lg.abolfazlnajafi.com/storage/bakla.png'},
        {'id': 17, 'title': 'Kathoey', 'image_url': 'https://lg.abolfazlnajafi.com/storage/kathoey.png'},
        {'id': 18, 'title': 'Questioning', 'image_url': 'https://lg.abolfazlnajafi.com/storage/questioning.png'},
        {'id': 19, 'title': 'Other', 'image_url': 'https://lg.abolfazlnajafi.com/storage/other.png'},
      ];
      
      // Fallback jobs - using API format with title field
      _jobs = [
        {'id': 1, 'title': 'Technology', 'image_url': 'https://lg.abolfazlnajafi.com/storage/tech.png'},
        {'id': 2, 'title': 'Healthcare', 'image_url': 'https://lg.abolfazlnajafi.com/storage/healthcare.png'},
        {'id': 3, 'title': 'Education', 'image_url': 'https://lg.abolfazlnajafi.com/storage/education.png'},
        {'id': 4, 'title': 'Finance', 'image_url': 'https://lg.abolfazlnajafi.com/storage/finance.png'},
        {'id': 5, 'title': 'Marketing', 'image_url': 'https://lg.abolfazlnajafi.com/storage/marketing.png'},
        {'id': 6, 'title': 'Sales', 'image_url': 'https://lg.abolfazlnajafi.com/storage/sales.png'},
        {'id': 7, 'title': 'Legal', 'image_url': 'https://lg.abolfazlnajafi.com/storage/legal.png'},
        {'id': 8, 'title': 'Engineering', 'image_url': 'https://lg.abolfazlnajafi.com/storage/engineering.png'},
        {'id': 9, 'title': 'Design', 'image_url': 'https://lg.abolfazlnajafi.com/storage/design.png'},
        {'id': 10, 'title': 'Media & Entertainment', 'image_url': 'https://lg.abolfazlnajafi.com/storage/media.png'},
        {'id': 11, 'title': 'Retail', 'image_url': 'https://lg.abolfazlnajafi.com/storage/retail.png'},
        {'id': 12, 'title': 'Hospitality', 'image_url': 'https://lg.abolfazlnajafi.com/storage/hospitality.png'},
        {'id': 13, 'title': 'Construction', 'image_url': 'https://lg.abolfazlnajafi.com/storage/construction.png'},
        {'id': 14, 'title': 'Transportation', 'image_url': 'https://lg.abolfazlnajafi.com/storage/transportation.png'},
        {'id': 15, 'title': 'Government', 'image_url': 'https://lg.abolfazlnajafi.com/storage/government.png'},
        {'id': 16, 'title': 'Non-Profit', 'image_url': 'https://lg.abolfazlnajafi.com/storage/nonprofit.png'},
        {'id': 17, 'title': 'Consulting', 'image_url': 'https://lg.abolfazlnajafi.com/storage/consulting.png'},
        {'id': 18, 'title': 'Research', 'image_url': 'https://lg.abolfazlnajafi.com/storage/research.png'},
        {'id': 19, 'title': 'Arts & Culture', 'image_url': 'https://lg.abolfazlnajafi.com/storage/arts.png'},
        {'id': 20, 'title': 'Sports', 'image_url': 'https://lg.abolfazlnajafi.com/storage/sports.png'},
        {'id': 21, 'title': 'Food & Beverage', 'image_url': 'https://lg.abolfazlnajafi.com/storage/food.png'},
        {'id': 22, 'title': 'Fashion', 'image_url': 'https://lg.abolfazlnajafi.com/storage/fashion.png'},
        {'id': 23, 'title': 'Beauty & Wellness', 'image_url': 'https://lg.abolfazlnajafi.com/storage/beauty.png'},
        {'id': 24, 'title': 'Automotive', 'image_url': 'https://lg.abolfazlnajafi.com/storage/automotive.png'},
        {'id': 25, 'title': 'Real Estate', 'image_url': 'https://lg.abolfazlnajafi.com/storage/real-estate.png'},
        {'id': 26, 'title': 'Insurance', 'image_url': 'https://lg.abolfazlnajafi.com/storage/insurance.png'},
        {'id': 27, 'title': 'Pharmaceuticals', 'image_url': 'https://lg.abolfazlnajafi.com/storage/pharmaceuticals.png'},
        {'id': 28, 'title': 'Energy', 'image_url': 'https://lg.abolfazlnajafi.com/storage/energy.png'},
        {'id': 29, 'title': 'Environmental', 'image_url': 'https://lg.abolfazlnajafi.com/storage/environmental.png'},
        {'id': 30, 'title': 'Aerospace', 'image_url': 'https://lg.abolfazlnajafi.com/storage/aerospace.png'},
        {'id': 31, 'title': 'Defense', 'image_url': 'https://lg.abolfazlnajafi.com/storage/defense.png'},
        {'id': 32, 'title': 'Other', 'image_url': 'https://lg.abolfazlnajafi.com/storage/other.png'},
        {'id': 33, 'title': 'Software Engineer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 34, 'title': 'Data Scientist', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 35, 'title': 'Product Manager', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 36, 'title': 'Marketing Manager', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 37, 'title': 'Sales Representative', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 38, 'title': 'Teacher', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 39, 'title': 'Doctor', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 40, 'title': 'Nurse', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 41, 'title': 'Lawyer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 42, 'title': 'Accountant', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 43, 'title': 'Designer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 44, 'title': 'Writer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 45, 'title': 'Photographer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 46, 'title': 'Chef', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 47, 'title': 'Architect', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 48, 'title': 'Engineer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 49, 'title': 'Consultant', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 50, 'title': 'Entrepreneur', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 51, 'title': 'Student', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 52, 'title': 'Artist', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 53, 'title': 'Musician', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 54, 'title': 'Actor', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 55, 'title': 'Journalist', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 56, 'title': 'Pilot', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 57, 'title': 'Police Officer', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 58, 'title': 'Firefighter', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 59, 'title': 'Electrician', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 60, 'title': 'Plumber', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 61, 'title': 'Carpenter', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 62, 'title': 'Mechanic', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 63, 'title': 'Driver', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
        {'id': 64, 'title': 'Retail Worker', 'image_url': 'https://lg.abolfazlnajafi.com/storage/default-job.png'},
      ];
      
      // Fallback education
      _educationLevels = [
        {'id': 1, 'title': 'High School'},
        {'id': 2, 'title': 'Bachelor\'s Degree'},
        {'id': 3, 'title': 'Master\'s Degree'},
        {'id': 4, 'title': 'PhD'},
        {'id': 5, 'title': 'Other'},
      ];
      
      // Fallback relation goals
      _relationGoals = [
        {'id': 1, 'title': 'Long-term relationship'},
        {'id': 2, 'title': 'Marriage'},
        {'id': 3, 'title': 'Casual dating'},
        {'id': 4, 'title': 'Friendship'},
        {'id': 5, 'title': 'Hook-up'},
        {'id': 6, 'title': 'Not sure'},
      ];
      
      // Fallback interests
      _interests = [
        {'id': 1, 'title': 'Music'},
        {'id': 2, 'title': 'Movies'},
        {'id': 3, 'title': 'Sports'},
        {'id': 4, 'title': 'Travel'},
        {'id': 5, 'title': 'Food'},
        {'id': 6, 'title': 'Art'},
        {'id': 7, 'title': 'Books'},
        {'id': 8, 'title': 'Gaming'},
        {'id': 9, 'title': 'Fitness'},
        {'id': 10, 'title': 'Photography'},
      ];
      
      // Fallback languages
      _languages = [
        {'id': 1, 'title': 'English'},
        {'id': 2, 'title': 'Spanish'},
        {'id': 3, 'title': 'French'},
        {'id': 4, 'title': 'German'},
        {'id': 5, 'title': 'Italian'},
        {'id': 6, 'title': 'Portuguese'},
        {'id': 7, 'title': 'Chinese'},
        {'id': 8, 'title': 'Japanese'},
        {'id': 9, 'title': 'Korean'},
        {'id': 10, 'title': 'Arabic'},
      ];
      
      // Fallback music genres
      _musicGenres = [
        {'id': 1, 'title': 'Pop'},
        {'id': 2, 'title': 'Rock'},
        {'id': 3, 'title': 'Hip-Hop'},
        {'id': 4, 'title': 'Electronic'},
        {'id': 5, 'title': 'Jazz'},
        {'id': 6, 'title': 'Classical'},
        {'id': 7, 'title': 'Country'},
        {'id': 8, 'title': 'R&B'},
        {'id': 9, 'title': 'Reggae'},
        {'id': 10, 'title': 'Blues'},
      ];
      
      // Comprehensive list of countries - using API format with title field
      _countries = {
        '1': {'id': 1, 'title': 'Afghanistan'},
        '2': {'id': 2, 'title': 'Albania'},
        '3': {'id': 3, 'title': 'Algeria'},
        '4': {'id': 4, 'title': 'Argentina'},
        '5': {'id': 5, 'title': 'Armenia'},
        '6': {'id': 6, 'title': 'Australia'},
        '7': {'id': 7, 'title': 'Austria'},
        '8': {'id': 8, 'title': 'Azerbaijan'},
        '9': {'id': 9, 'title': 'Bahrain'},
        '10': {'id': 10, 'title': 'Bangladesh'},
        '11': {'id': 11, 'title': 'Belarus'},
        '12': {'id': 12, 'title': 'Belgium'},
        '13': {'id': 13, 'title': 'Brazil'},
        '14': {'id': 14, 'title': 'Bulgaria'},
        '15': {'id': 15, 'title': 'Cambodia'},
        '16': {'id': 16, 'title': 'Canada'},
        '17': {'id': 17, 'title': 'Chile'},
        '18': {'id': 18, 'title': 'China'},
        '19': {'id': 19, 'title': 'Colombia'},
        '20': {'id': 20, 'title': 'Croatia'},
        '21': {'id': 21, 'title': 'Czech Republic'},
        '22': {'id': 22, 'title': 'Denmark'},
        '23': {'id': 23, 'title': 'Egypt'},
        '24': {'id': 24, 'title': 'Estonia'},
        '25': {'id': 25, 'title': 'Finland'},
        '26': {'id': 26, 'title': 'France'},
        '27': {'id': 27, 'title': 'Georgia'},
        '28': {'id': 28, 'title': 'Germany'},
        '29': {'id': 29, 'title': 'Ghana'},
        '30': {'id': 30, 'title': 'Greece'},
        '31': {'id': 31, 'title': 'Hungary'},
        '32': {'id': 32, 'title': 'Iceland'},
        '33': {'id': 33, 'title': 'India'},
        '34': {'id': 34, 'title': 'Indonesia'},
        '35': {'id': 35, 'title': 'Iran'},
        '36': {'id': 36, 'title': 'Iraq'},
        '37': {'id': 37, 'title': 'Ireland'},
        '38': {'id': 38, 'title': 'Israel'},
        '39': {'id': 39, 'title': 'Italy'},
        '40': {'id': 40, 'title': 'Japan'},
        '41': {'id': 41, 'title': 'Jordan'},
        '42': {'id': 42, 'title': 'Kazakhstan'},
        '43': {'id': 43, 'title': 'Kenya'},
        '44': {'id': 44, 'title': 'Kuwait'},
        '45': {'id': 45, 'title': 'Latvia'},
        '46': {'id': 46, 'title': 'Lebanon'},
        '47': {'id': 47, 'title': 'Lithuania'},
        '48': {'id': 48, 'title': 'Luxembourg'},
        '49': {'id': 49, 'title': 'Malaysia'},
        '50': {'id': 50, 'title': 'Mexico'},
        '51': {'id': 51, 'title': 'Morocco'},
        '52': {'id': 52, 'title': 'Netherlands'},
        '53': {'id': 53, 'title': 'New Zealand'},
        '54': {'id': 54, 'title': 'Nigeria'},
        '55': {'id': 55, 'title': 'Norway'},
        '56': {'id': 56, 'title': 'Pakistan'},
        '57': {'id': 57, 'title': 'Peru'},
        '58': {'id': 58, 'title': 'Philippines'},
        '59': {'id': 59, 'title': 'Poland'},
        '60': {'id': 60, 'title': 'Portugal'},
        '61': {'id': 61, 'title': 'Qatar'},
        '62': {'id': 62, 'title': 'Romania'},
        '63': {'id': 63, 'title': 'Russia'},
        '64': {'id': 64, 'title': 'Saudi Arabia'},
        '65': {'id': 65, 'title': 'Singapore'},
        '66': {'id': 66, 'title': 'Slovakia'},
        '67': {'id': 67, 'title': 'Slovenia'},
        '68': {'id': 68, 'title': 'South Africa'},
        '69': {'id': 69, 'title': 'South Korea'},
        '70': {'id': 70, 'title': 'Spain'},
        '71': {'id': 71, 'title': 'Sri Lanka'},
        '72': {'id': 72, 'title': 'Sweden'},
        '73': {'id': 73, 'title': 'Switzerland'},
        '74': {'id': 74, 'title': 'Thailand'},
        '75': {'id': 75, 'title': 'Turkey'},
        '76': {'id': 76, 'title': 'Ukraine'},
        '77': {'id': 77, 'title': 'United Arab Emirates'},
        '78': {'id': 78, 'title': 'United Kingdom'},
        '79': {'id': 79, 'title': 'United States'},
        '80': {'id': 80, 'title': 'Vietnam'},
      };
      
      _isLoading = false;
    });
  }

  Future<void> _loadCitiesForCountry(String countryId) async {
    try {
      final cities = await ReferenceDataApiService.getCitiesByCountry(countryId);
      setState(() {
        _citiesByCountry[countryId] = cities;
      });
    } catch (e) {
      print('Error loading cities, using fallback: $e');
      _loadFallbackCities(countryId);
    }
  }

  void _loadFallbackCities(String countryId) {
    setState(() {
      // Fallback cities for different countries
      switch (countryId) {
        case '1': // United States
          _citiesByCountry[countryId] = [
            {'id': 1, 'title': 'New York'},
            {'id': 2, 'title': 'Los Angeles'},
            {'id': 3, 'title': 'Chicago'},
            {'id': 4, 'title': 'Houston'},
            {'id': 5, 'title': 'Phoenix'},
            {'id': 6, 'title': 'Philadelphia'},
            {'id': 7, 'title': 'San Antonio'},
            {'id': 8, 'title': 'San Diego'},
            {'id': 9, 'title': 'Dallas'},
            {'id': 10, 'title': 'San Jose'},
          ];
          break;
        case '2': // Canada
          _citiesByCountry[countryId] = [
            {'id': 11, 'title': 'Toronto'},
            {'id': 12, 'title': 'Montreal'},
            {'id': 13, 'title': 'Vancouver'},
            {'id': 14, 'title': 'Calgary'},
            {'id': 15, 'title': 'Edmonton'},
            {'id': 16, 'title': 'Ottawa'},
            {'id': 17, 'title': 'Winnipeg'},
            {'id': 18, 'title': 'Quebec City'},
            {'id': 19, 'title': 'Hamilton'},
            {'id': 20, 'title': 'Kitchener'},
          ];
          break;
        case '3': // United Kingdom
          _citiesByCountry[countryId] = [
            {'id': 21, 'title': 'London'},
            {'id': 22, 'title': 'Birmingham'},
            {'id': 23, 'title': 'Manchester'},
            {'id': 24, 'title': 'Glasgow'},
            {'id': 25, 'title': 'Liverpool'},
            {'id': 26, 'title': 'Leeds'},
            {'id': 27, 'title': 'Sheffield'},
            {'id': 28, 'title': 'Edinburgh'},
            {'id': 29, 'title': 'Bristol'},
            {'id': 30, 'title': 'Cardiff'},
          ];
          break;
        default:
          _citiesByCountry[countryId] = [
            {'id': 1, 'title': 'Capital City'},
            {'id': 2, 'title': 'Major City 1'},
            {'id': 3, 'title': 'Major City 2'},
            {'id': 4, 'title': 'Major City 3'},
            {'id': 5, 'title': 'Major City 4'},
          ];
      }
    });
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animateProgress();
      HapticFeedbackService.selection();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _animateProgress();
      HapticFeedbackService.selection();
    }
  }

  void _animateProgress() {
    _progressAnimationController.forward(from: 0);
  }

  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Get device name
      final deviceName = await _getDeviceName();

      // Prepare profile data
      final profileData = {
        'device_name': deviceName,
        'country_id': int.parse(_selectedCountryId!),
        'city_id': int.parse(_selectedCityId!),
        'gender': _selectedGender!['id'],
        'birth_date': _birthDate!.toIso8601String().split('T')[0],
        'min_age_preference': _minAgePreference,
        'max_age_preference': _maxAgePreference,
        'profile_bio': _bio,
        'height': _height,
        'weight': _weight,
        'smoke': _smoke,
        'drink': _drink,
        'gym': _gym,
        'music_genres': _selectedMusicGenres.map((g) => g['id']).toList(),
        'educations': _selectedEducation != null ? [_selectedEducation!['id']] : [],
        'jobs': _selectedJob != null ? [_selectedJob!['id']] : [],
        'languages': _selectedLanguages.map((l) => l['id']).toList(),
        'interests': _selectedInterests.map((i) => i['id']).toList(),
        'preferred_genders': _preferredGenders.map((g) => g['id']).toList(),
        'relation_goals': _relationGoal != null ? [_relationGoal!['id']] : [],
      };

      // Submit to API
      final response = await ProfileApiService.completeProfile(profileData);
      
      if (response['status'] == true) {
        // Update token with new full access token
        final newToken = response['data']?['token']?['access_token'];
        if (newToken != null) {
          await TokenManagementService.storeAccessToken(newToken);
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Navigate to main app
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to complete profile');
      }
    } catch (e) {
      _showError('Failed to complete profile: $e');
      print('Profile submission error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getDeviceName() async {
    try {
      // TODO: Implement device name detection using device_info_plus
      return 'Flutter Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                // Header with progress
                _buildHeader(),
                
                // Steps content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentStep = index);
                    },
                    children: [
                      _buildBasicInfoStep(),
                      _buildPhotosStep(),
                      _buildAboutYouStep(),
                      _buildPreferencesStep(),
                      _buildInterestsStep(),
                      _buildLifestyleStep(),
                      _buildReviewStep(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            widthFactor: ((_currentStep + _progressAnimation.value) / _totalSteps),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.lgbtGradient,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentStep + 1}/$_totalSteps',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Step title
          Text(
            _getStepTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStepDescription(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Basic Information';
      case 1: return 'Add Your Photos';
      case 2: return 'Tell Us About You';
      case 3: return 'Dating Preferences';
      case 4: return 'Your Interests';
      case 5: return 'Lifestyle';
      case 6: return 'Review Your Profile';
      default: return '';
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0: return 'Let\'s start with the basics';
      case 1: return 'Add at least 2 photos to continue';
      case 2: return 'Share a bit about yourself';
      case 3: return 'Help us find your perfect match';
      case 4: return 'What are you passionate about?';
      case 5: return 'Tell us about your lifestyle';
      case 6: return 'Everything looks good?';
      default: return '';
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Birthday
          _buildSectionTitle('Birthday'),
          const SizedBox(height: 12),
          _buildDatePickerField(
            label: 'Select your birthday',
            value: _birthDate,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 6570)),
                firstDate: DateTime.now().subtract(const Duration(days: 36500)),
                lastDate: DateTime.now().subtract(const Duration(days: 6570)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppColors.primary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _birthDate = picked);
              }
            },
          ),
          const SizedBox(height: 24),
          
          // Gender
          _buildSectionTitle('Gender'),
          const SizedBox(height: 12),
          _buildDropdownField<Map<String, dynamic>>(
            label: 'Select your gender',
            value: _selectedGender,
            items: _genders,
            onChanged: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: 24),
          
          // Location
          _buildSectionTitle('Location'),
          const SizedBox(height: 12),
          _buildCountryDropdown(),
          const SizedBox(height: 12),
          if (_selectedCountryId != null)
            _buildCityDropdown(),
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
          _buildSectionTitle('Your Photos'),
          const SizedBox(height: 8),
          Text(
            'Add at least 2 photos. First photo will be your main profile picture.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Photo grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              if (index < _photos.length) {
                return _buildPhotoCard(_photos[index], index);
              } else {
                return _buildAddPhotoCard(index);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutYouStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          _buildSectionTitle('Bio'),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Tell us about yourself',
            value: _bio,
            maxLines: 5,
            maxLength: 500,
            onChanged: (value) => setState(() => _bio = value),
          ),
          const SizedBox(height: 24),
          
          // Job
          _buildSectionTitle('Occupation'),
          const SizedBox(height: 12),
          _buildDropdownField<Map<String, dynamic>>(
            label: 'Select your occupation',
            value: _selectedJob,
            items: _jobs,
            onChanged: (value) => setState(() => _selectedJob = value),
          ),
          const SizedBox(height: 24),
          
          // Education
          _buildSectionTitle('Education'),
          const SizedBox(height: 12),
          _buildDropdownField<Map<String, dynamic>>(
            label: 'Select your education level',
            value: _selectedEducation,
            items: _educationLevels,
            onChanged: (value) => setState(() => _selectedEducation = value),
          ),
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
          // Age preferences
          _buildSectionTitle('Age Preferences'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Minimum Age',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildAgeSlider(
                      value: _minAgePreference.toDouble(),
                      min: 18,
                      max: _maxAgePreference - 1,
                      onChanged: (value) => setState(() => _minAgePreference = value.round()),
                    ),
                    Text(
                      '$_minAgePreference years',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Maximum Age',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildAgeSlider(
                      value: _maxAgePreference.toDouble(),
                      min: _minAgePreference + 1,
                      max: 100,
                      onChanged: (value) => setState(() => _maxAgePreference = value.round()),
                    ),
                    Text(
                      '$_maxAgePreference years',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Physical attributes
          _buildSectionTitle('Physical Attributes'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Height',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildHeightSlider(),
                    Text(
                      '$_height cm',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    _buildWeightSlider(),
                    Text(
                      '$_weight kg',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Lifestyle choices
          _buildSectionTitle('Lifestyle'),
          const SizedBox(height: 12),
          _buildLifestyleChoices(),
          const SizedBox(height: 24),
          
          // Preferred genders
          _buildSectionTitle('Interested in'),
          const SizedBox(height: 12),
          _buildMultiSelectChips<Map<String, dynamic>>(
            items: _preferredGenderOptions,
            selectedItems: _preferredGenders,
            onChanged: (selected) => setState(() => _preferredGenders = selected),
          ),
          const SizedBox(height: 24),
          
          // Relationship goal
          _buildSectionTitle('Looking for'),
          const SizedBox(height: 12),
          _buildSingleSelectChips<Map<String, dynamic>>(
            items: _relationGoals,
            selectedItem: _relationGoal,
            onChanged: (value) => setState(() => _relationGoal = value),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Your Interests'),
          const SizedBox(height: 8),
          Text(
            'Select at least 3 interests',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          _buildMultiSelectChips<Map<String, dynamic>>(
            items: _interests,
            selectedItems: _selectedInterests,
            onChanged: (selected) => setState(() => _selectedInterests = selected),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Languages
          _buildSectionTitle('Languages'),
          const SizedBox(height: 12),
          _buildMultiSelectChips<Map<String, dynamic>>(
            items: _languages,
            selectedItems: _selectedLanguages,
            onChanged: (selected) => setState(() => _selectedLanguages = selected),
          ),
          const SizedBox(height: 24),
          
          // Music genres
          _buildSectionTitle('Music Genres'),
          const SizedBox(height: 12),
          _buildMultiSelectChips<Map<String, dynamic>>(
            items: _musicGenres,
            selectedItems: _selectedMusicGenres,
            onChanged: (selected) => setState(() => _selectedMusicGenres = selected),
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
          _buildSectionTitle('Profile Preview'),
          const SizedBox(height: 20),
          
          // Summary cards
          _buildSummaryCard('Basic Info', Icons.person, [
            'Age: ${_birthDate != null ? _calculateAge(_birthDate!) : 'Not set'}',
            'Gender: ${_selectedGender?['title'] ?? 'Not set'}',
            'Location: ${_selectedCityId != null ? 'Selected' : 'Not set'}',
          ]),
          const SizedBox(height: 16),
          
          _buildSummaryCard('Photos', Icons.photo_library, [
            '${_photos.length} photos added',
          ]),
          const SizedBox(height: 16),
          
          _buildSummaryCard('About', Icons.info, [
            'Bio: ${_bio.isNotEmpty ? 'Added' : 'Not set'}',
            'Job: ${_selectedJob?['title'] ?? 'Not set'}',
            'Education: ${_selectedEducation?['title'] ?? 'Not set'}',
          ]),
          const SizedBox(height: 16),
          
          _buildSummaryCard('Preferences', Icons.favorite, [
            'Interested in: ${_preferredGenders.map((g) => g['title']).join(', ')}',
            'Looking for: ${_relationGoal?['title'] ?? 'Not set'}',
            'Age range: $_minAgePreference - $_maxAgePreference years',
          ]),
          const SizedBox(height: 16),
          
          _buildSummaryCard('Physical', Icons.height, [
            'Height: $_height cm',
            'Weight: $_weight kg',
          ]),
          const SizedBox(height: 16),
          
          _buildSummaryCard('Lifestyle', Icons.fitness_center, [
            'Smoking: ${_smoke ? "Yes" : "No"}',
            'Drinking: ${_drink ? "Yes" : "No"}',
            'Gym: ${_gym ? "Yes" : "No"}',
          ]),
          const SizedBox(height: 16),
          
          _buildSummaryCard('Interests', Icons.interests, [
            '${_selectedInterests.length} interests selected',
          ]),
          const SizedBox(height: 16),
          
          _buildSummaryCard('Culture', Icons.music_note, [
            'Languages: ${_selectedLanguages.length} selected',
            'Music: ${_selectedMusicGenres.length} selected',
          ]),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: _buildButton(
                label: 'Back',
                onPressed: _previousStep,
                isPrimary: false,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: _buildButton(
              label: _currentStep == _totalSteps - 1 ? 'Complete Profile' : 'Continue',
              onPressed: _canProceed() ? (_currentStep == _totalSteps - 1 ? _submitProfile : _nextStep) : null,
              isPrimary: true,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Basic info
        return _birthDate != null && _selectedGender != null && _selectedCityId != null;
      case 1: // Photos
        return _photos.length >= 2;
      case 2: // About
        return _bio.isNotEmpty && _selectedJob != null && _selectedEducation != null;
      case 3: // Preferences
        return _preferredGenders.isNotEmpty && _relationGoal != null;
      case 4: // Interests
        return _selectedInterests.length >= 3;
      case 5: // Lifestyle
        return _selectedLanguages.isNotEmpty;
      case 6: // Review
        return true;
      default:
        return false;
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // UI Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      initialValue: value,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? '${value.day}/${value.month}/${value.year}'
                    : label,
                style: TextStyle(
                  color: value != null ? Colors.white : Colors.white30,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(color: Colors.white30),
          ),
          isExpanded: true,
          dropdownColor: AppColors.cardBackgroundDark,
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(_getItemName(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMultiSelectChips<T>({
    required List<T> items,
    required List<T> selectedItems,
    required Function(List<T>) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return InkWell(
          onTap: () {
            final newSelection = List<T>.from(selectedItems);
            if (isSelected) {
              newSelection.remove(item);
            } else {
              newSelection.add(item);
            }
            onChanged(newSelection);
            HapticFeedbackService.selection();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: AppColors.lgbtGradient) : null,
              color: isSelected ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white30,
              ),
            ),
            child: Text(
              _getItemName(item),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSelectChips<T>({
    required List<T> items,
    required T? selectedItem,
    required Function(T) onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItem == item;
        return InkWell(
          onTap: () {
            onChanged(item);
            HapticFeedbackService.selection();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: AppColors.lgbtGradient) : null,
              color: isSelected ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.white30,
              ),
            ),
            child: Text(
              _getItemName(item),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoCard(File photo, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(photo),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          if (index == 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'MAIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () {
                setState(() => _photos.removeAt(index));
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoCard(int index) {
    return InkWell(
      onTap: () => _addPhoto(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white30,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add_a_photo,
            color: Colors.white70,
            size: 32,
          ),
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    try {
      final files = await MediaPickerService().pickImage();
      if (files != null && files.isNotEmpty) {
        setState(() {
          if (_photos.length < 6) {
            _photos.add(files.first);
          }
        });
      }
    } catch (e) {
      _showError('Failed to add photo: $e');
    }
  }

  Widget _buildSummaryCard(String title, IconData icon, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $item',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? AppColors.primary : Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary ? BorderSide.none : const BorderSide(color: Colors.white30),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  String _getItemName(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item['title'] ?? item['name'] ?? 'Unknown';
    }
    if (item is Gender || item is Job || item is Education || 
        item is RelationGoal || item is Interest || 
        item is Language || item is MusicGenre) {
      return (item as dynamic).name ?? (item as dynamic).title ?? 'Unknown';
    }
    return item.toString();
  }

  Widget _buildCountryDropdown() {
    final countries = _countries.values.toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: InkWell(
        onTap: () => _showCountrySearchDialog(countries),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCountryId != null 
                    ? (_countries[_selectedCountryId]?['title'] ?? 'Select country')
                    : 'Select country',
                style: TextStyle(
                  color: _selectedCountryId != null ? Colors.white : Colors.white30,
                ),
              ),
            ),
            const Icon(Icons.search, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  void _showCountrySearchDialog(List<dynamic> countries) {
    showDialog(
      context: context,
      builder: (context) => _buildSearchDialog(
        title: 'Select Country',
        items: countries,
        onItemSelected: (country) {
          setState(() {
            _selectedCountryId = country['id'].toString();
            _selectedCityId = null;
          });
          _loadCitiesForCountry(country['id'].toString());
          Navigator.of(context).pop();
        },
        itemBuilder: (country) => Text(country['name'] ?? 'Unknown'),
      ),
    );
  }

  Widget _buildCityDropdown() {
    final cities = _citiesByCountry[_selectedCountryId] ?? [];
    
    if (cities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: InkWell(
        onTap: () => _showCitySearchDialog(cities),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedCityId != null 
                    ? (cities.firstWhere(
                        (city) => city['id'].toString() == _selectedCityId,
                        orElse: () => {'title': 'Select city'},
                      )['title'] ?? 'Select city')
                    : 'Select city',
                style: TextStyle(
                  color: _selectedCityId != null ? Colors.white : Colors.white30,
                ),
              ),
            ),
            const Icon(Icons.search, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  void _showCitySearchDialog(List<dynamic> cities) {
    showDialog(
      context: context,
      builder: (context) => _buildSearchDialog(
        title: 'Select City',
        items: cities,
        onItemSelected: (city) {
          setState(() {
            _selectedCityId = city['id'].toString();
          });
          Navigator.of(context).pop();
        },
        itemBuilder: (city) => Text(city['name'] ?? 'Unknown'),
      ),
    );
  }

  Widget _buildSearchDialog<T>({
    required String title,
    required List<T> items,
    required Function(T) onItemSelected,
    required Widget Function(T) itemBuilder,
  }) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        String searchQuery = '';
        List<T> filteredItems = items;

        return AlertDialog(
          backgroundColor: AppColors.cardBackgroundDark,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search field
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      searchQuery = value.toLowerCase();
                         filteredItems = items.where((item) {
                           if (item is Map<String, dynamic>) {
                             return (item['title'] ?? item['name'] ?? '').toLowerCase().contains(searchQuery);
                           }
                           return item.toString().toLowerCase().contains(searchQuery);
                         }).toList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Items list
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return ListTile(
                        title: itemBuilder(item),
                        textColor: Colors.white,
                        onTap: () => onItemSelected(item),
                        hoverColor: Colors.white.withOpacity(0.1),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgeSlider({required double value, required double min, required double max, required ValueChanged<double> onChanged}) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white30,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).round(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildHeightSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white30,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      child: Slider(
        value: _height.toDouble(),
        min: 100,
        max: 250,
        divisions: 150,
        onChanged: (value) => setState(() => _height = value.round()),
      ),
    );
  }

  Widget _buildWeightSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: Colors.white30,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      child: Slider(
        value: _weight.toDouble(),
        min: 30,
        max: 200,
        divisions: 170,
        onChanged: (value) => setState(() => _weight = value.round()),
      ),
    );
  }

  Widget _buildLifestyleChoices() {
    return Column(
      children: [
        _buildLifestyleChoice(
          title: 'Smoking',
          subtitle: 'Do you smoke?',
          value: _smoke,
          onChanged: (value) => setState(() => _smoke = value),
        ),
        const SizedBox(height: 16),
        _buildLifestyleChoice(
          title: 'Drinking',
          subtitle: 'Do you drink alcohol?',
          value: _drink,
          onChanged: (value) => setState(() => _drink = value),
        ),
        const SizedBox(height: 16),
        _buildLifestyleChoice(
          title: 'Gym',
          subtitle: 'Do you go to the gym?',
          value: _gym,
          onChanged: (value) => setState(() => _gym = value),
        ),
      ],
    );
  }

  Widget _buildLifestyleChoice({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary : Colors.white30,
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white30,
          ),
        ],
      ),
    );
  }
}

// Temporary models - these should be replaced with actual API models
class Gender implements ReferenceItem {
  @override
  final int id;
  @override
  final String name;
  @override
  final String title;
  
  Gender({required this.id, required this.name}) : title = name;
}

class Job implements ReferenceItem {
  @override
  final int id;
  @override
  final String name;
  @override
  final String title;
  
  Job({required this.id, required this.name, required this.title});
}

class Education implements ReferenceItem {
  @override
  final int id;
  @override
  final String name;
  @override
  final String title;
  
  Education({required this.id, required this.name, required this.title});
}

class RelationGoal implements ReferenceItem {
  @override
  final int id;
  @override
  final String name;
  @override
  final String title;
  
  RelationGoal({required this.id, required this.name, required this.title});
}

class Interest implements ReferenceItem {
  @override
  final int id;
  @override
  final String name;
  @override
  final String title;
  
  Interest({required this.id, required this.name}) : title = name;
}

class Language implements ReferenceItem {
  @override
  final int id;
  @override
  final String name;
  @override
  final String title;
  
  Language({required this.id, required this.name}) : title = name;
}

class MusicGenre implements ReferenceItem {
  @override
  final int id;
  @override
  final String name;
  @override
  final String title;
  
  MusicGenre({required this.id, required this.name}) : title = name;
}
