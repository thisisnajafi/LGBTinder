import 'api_service.dart';
import '../models/models.dart';

class ProfileService {
  final ApiService _apiService = ApiService();

  // Profile Management
  Future<Map<String, dynamic>> getProfile() async {
    return await _apiService.getData('/api/profile');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    return await _apiService.updateData('/api/profile', profileData);
  }

  Future<Map<String, dynamic>> getProfileCompletion() async {
    return await _apiService.getData('/api/profile/completion');
  }

  // Photo Management
  Future<Map<String, dynamic>> uploadImage(String imagePath, {String type = 'gallery'}) async {
    // This would typically involve multipart form data upload
    // For now, we'll use a simple approach
    return await _apiService.postData('/api/images/upload', {
      'image_path': imagePath,
      'type': type,
    });
  }

  Future<Map<String, dynamic>> deleteImage(int imageId) async {
    return await _apiService.deleteData('/api/images/$imageId');
  }

  Future<Map<String, dynamic>> reorderImages(List<int> imageIds) async {
    return await _apiService.postData('/api/images/reorder', {
      'image_ids': imageIds,
    });
  }

  Future<Map<String, dynamic>> setPrimaryImage(int imageId) async {
    return await _apiService.postData('/api/images/$imageId/set-primary', {});
  }

  Future<Map<String, dynamic>> getImages() async {
    return await _apiService.getData('/api/images/list');
  }

  // Profile Pictures (Separate from gallery)
  Future<Map<String, dynamic>> uploadProfilePicture(String imagePath) async {
    return await _apiService.postData('/api/profile-pictures/upload', {
      'image_path': imagePath,
    });
  }

  Future<Map<String, dynamic>> deleteProfilePicture(int imageId) async {
    return await _apiService.deleteData('/api/profile-pictures/$imageId');
  }

  Future<Map<String, dynamic>> setPrimaryProfilePicture(int imageId) async {
    return await _apiService.postData('/api/profile-pictures/$imageId/set-primary', {});
  }

  Future<Map<String, dynamic>> getProfilePictures() async {
    return await _apiService.getData('/api/profile-pictures/list');
  }

  // Verification
  Future<Map<String, dynamic>> submitPhotoVerification(String imagePath) async {
    return await _apiService.postData('/api/verification/submit-photo', {
      'image_path': imagePath,
    });
  }

  Future<Map<String, dynamic>> submitIdVerification(String imagePath) async {
    return await _apiService.postData('/api/verification/submit-id', {
      'image_path': imagePath,
    });
  }

  Future<Map<String, dynamic>> submitVideoVerification(String videoPath) async {
    return await _apiService.postData('/api/verification/submit-video', {
      'video_path': videoPath,
    });
  }

  Future<Map<String, dynamic>> getVerificationStatus() async {
    return await _apiService.getData('/api/verification/status');
  }

  Future<Map<String, dynamic>> getVerificationGuidelines() async {
    return await _apiService.getData('/api/verification/guidelines');
  }

  Future<Map<String, dynamic>> getVerificationHistory() async {
    return await _apiService.getData('/api/verification/history');
  }

  // Reference Data (Dropdown Options)
  Future<Map<String, dynamic>> getGenders() async {
    return await _apiService.getData('/api/genders');
  }

  Future<Map<String, dynamic>> getSexualOrientations() async {
    return await _apiService.getData('/api/sexual-orientations');
  }

  Future<Map<String, dynamic>> getRelationGoals() async {
    return await _apiService.getData('/api/relation-goals');
  }

  Future<Map<String, dynamic>> getPreferredGenders() async {
    return await _apiService.getData('/api/preferred-genders');
  }

  Future<Map<String, dynamic>> getEducation() async {
    return await _apiService.getData('/api/education');
  }

  Future<Map<String, dynamic>> getJobs() async {
    return await _apiService.getData('/api/jobs');
  }

  Future<Map<String, dynamic>> getLanguages() async {
    return await _apiService.getData('/api/languages');
  }

  Future<Map<String, dynamic>> getMusicGenres() async {
    return await _apiService.getData('/api/music-genres');
  }

  Future<Map<String, dynamic>> getInterests() async {
    return await _apiService.getData('/api/interests');
  }

  // User Preferences
  Future<Map<String, dynamic>> updateAgePreferences(int minAge, int maxAge) async {
    return await _apiService.updateData('/api/preferences/age', {
      'min_age': minAge,
      'max_age': maxAge,
    });
  }

  Future<Map<String, dynamic>> getAgePreferences() async {
    return await _apiService.getData('/api/preferences/age');
  }

  Future<Map<String, dynamic>> resetAgePreferences() async {
    return await _apiService.deleteData('/api/preferences/age');
  }

  // User Settings
  Future<Map<String, dynamic>> setAdultContentPreference(bool showAdultContent) async {
    return await _apiService.postData('/api/user/show-adult-content', {
      'show_adult_content': showAdultContent,
    });
  }

  Future<Map<String, dynamic>> savePushNotificationToken(String token) async {
    return await _apiService.postData('/api/user/onesignal-player', {
      'token': token,
    });
  }

  Future<Map<String, dynamic>> updateNotificationPreferences(Map<String, dynamic> preferences) async {
    return await _apiService.postData('/api/user/notification-preferences', preferences);
  }

  Future<Map<String, dynamic>> getNotificationHistory() async {
    return await _apiService.getData('/api/user/notification-history');
  }

  // Profile Wizard (Step-by-step completion)
  Future<Map<String, dynamic>> getCurrentWizardStep() async {
    return await _apiService.getData('/api/profile-wizard/current-step');
  }

  Future<Map<String, dynamic>> getWizardStepOptions(String step) async {
    return await _apiService.getData('/api/profile-wizard/step-options/$step');
  }

  Future<Map<String, dynamic>> saveWizardStep(String step, Map<String, dynamic> data) async {
    return await _apiService.postData('/api/profile-wizard/save-step/$step', data);
  }

  // Helper methods for parsing responses
  User parseUserFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      return User.fromJson(response['data']);
    }
    throw Exception('Failed to parse user data: ${response['message']}');
  }

  List<Gender> parseGendersFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Gender.fromJson(json)).toList();
    }
    throw Exception('Failed to parse genders: ${response['message']}');
  }

  List<SexualOrientation> parseSexualOrientationsFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => SexualOrientation.fromJson(json)).toList();
    }
    throw Exception('Failed to parse sexual orientations: ${response['message']}');
  }

  List<RelationGoal> parseRelationGoalsFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => RelationGoal.fromJson(json)).toList();
    }
    throw Exception('Failed to parse relation goals: ${response['message']}');
  }

  List<PreferredGender> parsePreferredGendersFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => PreferredGender.fromJson(json)).toList();
    }
    throw Exception('Failed to parse preferred genders: ${response['message']}');
  }

  List<Job> parseJobsFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Job.fromJson(json)).toList();
    }
    throw Exception('Failed to parse jobs: ${response['message']}');
  }

  List<Education> parseEducationFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Education.fromJson(json)).toList();
    }
    throw Exception('Failed to parse education: ${response['message']}');
  }

  List<Language> parseLanguagesFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Language.fromJson(json)).toList();
    }
    throw Exception('Failed to parse languages: ${response['message']}');
  }

  List<MusicGenre> parseMusicGenresFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => MusicGenre.fromJson(json)).toList();
    }
    throw Exception('Failed to parse music genres: ${response['message']}');
  }

  List<Interest> parseInterestsFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      final List<dynamic> data = response['data'];
      return data.map((json) => Interest.fromJson(json)).toList();
    }
    throw Exception('Failed to parse interests: ${response['message']}');
  }

  UserVerification parseVerificationFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      return UserVerification.fromJson(response['data']);
    }
    throw Exception('Failed to parse verification data: ${response['message']}');
  }

  UserPreferences parsePreferencesFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      return UserPreferences.fromJson(response['data']);
    }
    throw Exception('Failed to parse preferences: ${response['message']}');
  }

  UserSettings parseSettingsFromResponse(Map<String, dynamic> response) {
    if (response['success'] && response['data'] != null) {
      return UserSettings.fromJson(response['data']);
    }
    throw Exception('Failed to parse settings: ${response['message']}');
  }
}
