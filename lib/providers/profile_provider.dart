import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/profile_service.dart';
import '../services/reference_data_service.dart';
import '../services/preferences_service.dart';
import '../services/verification_service.dart';

class ProfileProvider extends ChangeNotifier {

  // Profile data
  User? _user;
  User? get user => _user;

  // Reference data (dropdown options)
  List<Gender> _genders = [];
  List<SexualOrientation> _sexualOrientations = [];
  List<RelationGoal> _relationGoals = [];
  List<PreferredGender> _preferredGenders = [];
  List<Job> _jobs = [];
  List<Education> _educations = [];
  List<Language> _languages = [];
  List<MusicGenre> _musicGenres = [];
  List<Interest> _interests = [];

  // Getters for reference data
  List<Gender> get genders => _genders;
  List<SexualOrientation> get sexualOrientations => _sexualOrientations;
  List<RelationGoal> get relationGoals => _relationGoals;
  List<PreferredGender> get preferredGenders => _preferredGenders;
  List<Job> get jobs => _jobs;
  List<Education> get educations => _educations;
  List<Language> get languages => _languages;
  List<MusicGenre> get musicGenres => _musicGenres;
  List<Interest> get interests => _interests;

  // Loading states
  bool _isLoadingProfile = false;
  bool _isLoadingReferenceData = false;
  bool _isSavingProfile = false;
  bool _isUploadingImage = false;

  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingReferenceData => _isLoadingReferenceData;
  bool get isSavingProfile => _isSavingProfile;
  bool get isUploadingImage => _isUploadingImage;

  // Error states
  String? _profileError;
  String? _referenceDataError;
  String? _saveError;
  String? _uploadError;

  String? get profileError => _profileError;
  String? get referenceDataError => _referenceDataError;
  String? get saveError => _saveError;
  String? get uploadError => _uploadError;

  // Profile completion
  bool _isProfileComplete = false;
  int _completionPercentage = 0;
  List<String> _missingFields = [];

  bool get isProfileComplete => _isProfileComplete;
  int get completionPercentage => _completionPercentage;
  List<String> get missingFields => _missingFields;

  // Verification data
  UserVerification? _verification;
  UserVerification? get verification => _verification;

  // User preferences and settings
  UserPreferences? _preferences;
  UserSettings? _settings;

  UserPreferences? get preferences => _preferences;
  UserSettings? get settings => _settings;

  // Initialize the provider
  Future<void> initialize() async {
    await Future.wait([
      loadProfile(),
      loadReferenceData(),
    ]);
  }

  // Load user profile
  Future<void> loadProfile() async {
    _setLoadingProfile(true);
    _clearProfileError();

    try {
      _user = await ProfileService.getProfile();
      await _loadProfileCompletion();
      await _loadVerificationStatus();
      await _loadPreferences();
      await _loadSettings();
    } catch (e) {
      _setProfileError('Error loading profile: $e');
    } finally {
      _setLoadingProfile(false);
    }
  }

  // Load reference data (dropdown options)
  Future<void> loadReferenceData() async {
    _setLoadingReferenceData(true);
    _clearReferenceDataError();

    try {
      await Future.wait([
        _loadGenders(),
        _loadSexualOrientations(),
        _loadRelationGoals(),
        _loadPreferredGenders(),
        _loadJobs(),
        _loadEducation(),
        _loadLanguages(),
        _loadMusicGenres(),
        _loadInterests(),
      ]);
    } catch (e) {
      _setReferenceDataError('Error loading reference data: $e');
    } finally {
      _setLoadingReferenceData(false);
    }
  }

  // Load individual reference data
  Future<void> _loadGenders() async {
    try {
      _genders = await ReferenceDataService.getGenderOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading genders: $e');
    }
  }

  Future<void> _loadSexualOrientations() async {
    try {
      // SexualOrientation data would come from an API endpoint
      // For now, create empty list since we don't have this specific endpoint
      _sexualOrientations = [];
      notifyListeners();
    } catch (e) {
      print('Error loading sexual orientations: $e');
    }
  }

  Future<void> _loadRelationGoals() async {
    try {
      _relationGoals = await ReferenceDataService.getRelationGoalOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading relation goals: $e');
    }
  }

  Future<void> _loadPreferredGenders() async {
    try {
      _preferredGenders = await ReferenceDataService.getPreferredGenderOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading preferred genders: $e');
    }
  }

  Future<void> _loadJobs() async {
    try {
      _jobs = await ReferenceDataService.getJobOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading jobs: $e');
    }
  }

  Future<void> _loadEducation() async {
    try {
      _educations = await ReferenceDataService.getEducationOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading education: $e');
    }
  }

  Future<void> _loadLanguages() async {
    try {
      _languages = await ReferenceDataService.getLanguageOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading languages: $e');
    }
  }

  Future<void> _loadMusicGenres() async {
    try {
      _musicGenres = await ReferenceDataService.getMusicGenreOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading music genres: $e');
    }
  }

  Future<void> _loadInterests() async {
    try {
      _interests = await ReferenceDataService.getInterestOptions();
      notifyListeners();
    } catch (e) {
      print('Error loading interests: $e');
    }
  }

  // Load profile completion status
  Future<void> _loadProfileCompletion() async {
    try {
      // TODO: Implement profile completion calculation
      _isProfileComplete = true;
      _completionPercentage = 75;
      _missingFields = [];
      notifyListeners();
    } catch (e) {
      print('Error loading profile completion: $e');
    }
  }

  // Load verification status
  Future<void> _loadVerificationStatus() async {
    try {
      // TODO: Use VerificationService.getVerificationStatus() once models are aligned
      _verification = null; // Temporarily set to null
      notifyListeners();
    } catch (e) {
      print('Error loading verification status: $e');
    }
  }

  // Load user preferences
  Future<void> _loadPreferences() async {
    try {
      // TODO: Use PreferencesService.getAgePreferences() once models are aligned
      _preferences = null; // Temporarily set to null
      notifyListeners();
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  // Load user settings
  Future<void> _loadSettings() async {
    // This would typically load from a settings endpoint
    // For now, we'll create default settings
    _settings = UserSettings(
      id: 1,
      userId: _user?.id ?? 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _setSavingProfile(true);
    _clearSaveError();

    try {
      _user = await ProfileService.updateProfile(profileData);
      await _loadProfileCompletion();
      notifyListeners();
      return true;
    } catch (e) {
      _setSaveError('Error updating profile: $e');
      return false;
    } finally {
      _setSavingProfile(false);
    }
  }

  // Upload image
  Future<bool> uploadImage(String imagePath, {String type = 'gallery'}) async {
    _setUploadingImage(true);
    _clearUploadError();

    try {
      // TODO: Implement with ProfileService.uploadImage
      // final response = await ProfileService.uploadImage(File(imagePath));
      await loadProfile();
      return true;
    } catch (e) {
      _setUploadError('Error uploading image: $e');
      return false;
    } finally {
      _setUploadingImage(false);
    }
  }

  // Delete image
  Future<bool> deleteImage(int imageId) async {
    try {
      // TODO: Implement with ProfileService.deleteImage
      // await ProfileService.deleteImage(imageId.toString());
      await loadProfile();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Set primary image
  Future<bool> setPrimaryImage(int imageId) async {
    try {
      // TODO: Implement with ProfileService.setPrimaryImage
      // await ProfileService.setPrimaryImage(imageId.toString());
      await loadProfile();
      return true;
    } catch (e) {
      print('Error setting primary image: $e');
      return false;
    }
  }

  // Update preferences
  Future<bool> updatePreferences(int minAge, int maxAge) async {
    try {
      // TODO: Implement with PreferencesService.updateAgePreferences
      // await PreferencesService.updateAgePreferences(minAge: minAge, maxAge: maxAge);
      // _preferences = result;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating preferences: $e');
      return false;
    }
  }

  // Update settings
  Future<bool> updateSettings(Map<String, dynamic> settingsData) async {
    try {
      // This would typically call an API endpoint
      // For now, we'll just update the local settings
      if (_settings != null) {
        _settings = _settings!.copyWith(
          showAdultContent: settingsData['show_adult_content'],
          profileVisibility: settingsData['profile_visibility'],
          showOnlineStatus: settingsData['show_online_status'],
          showLastSeen: settingsData['show_last_seen'],
          newMatchesNotification: settingsData['new_matches_notification'],
          newMessagesNotification: settingsData['new_messages_notification'],
          likesNotification: settingsData['likes_notification'],
          superlikesNotification: settingsData['superlikes_notification'],
          storiesFromMatchesNotification: settingsData['stories_from_matches_notification'],
          feedUpdatesNotification: settingsData['feed_updates_notification'],
          safetyAlertsNotification: settingsData['safety_alerts_notification'],
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating settings: $e');
      return false;
    }
  }

  // Loading state setters
  void _setLoadingProfile(bool loading) {
    _isLoadingProfile = loading;
    notifyListeners();
  }

  void _setLoadingReferenceData(bool loading) {
    _isLoadingReferenceData = loading;
    notifyListeners();
  }

  void _setSavingProfile(bool saving) {
    _isSavingProfile = saving;
    notifyListeners();
  }

  void _setUploadingImage(bool uploading) {
    _isUploadingImage = uploading;
    notifyListeners();
  }

  // Error state setters
  void _setProfileError(String error) {
    _profileError = error;
    notifyListeners();
  }

  void _setReferenceDataError(String error) {
    _referenceDataError = error;
    notifyListeners();
  }

  void _setSaveError(String error) {
    _saveError = error;
    notifyListeners();
  }

  void _setUploadError(String error) {
    _uploadError = error;
    notifyListeners();
  }

  // Clear error states
  void _clearProfileError() {
    _profileError = null;
    notifyListeners();
  }

  void _clearReferenceDataError() {
    _referenceDataError = null;
    notifyListeners();
  }

  void _clearSaveError() {
    _saveError = null;
    notifyListeners();
  }

  void _clearUploadError() {
    _uploadError = null;
    notifyListeners();
  }

  // Clear all errors
  void clearAllErrors() {
    _clearProfileError();
    _clearReferenceDataError();
    _clearSaveError();
    _clearUploadError();
  }

  // Refresh all data
  Future<void> refresh() async {
    await initialize();
  }
}
