import 'package:flutter/foundation.dart';
import '../models/api_models/user_models.dart';
import '../models/api_models/profile_models.dart';
import '../services/api_services/user_api_service.dart';
import '../services/api_services/profile_api_service.dart';
import '../services/token_management_service.dart';
import '../services/rate_limiting_service.dart';

/// User State Provider
/// 
/// This provider manages user profile state including:
/// - Current user profile data
/// - Profile updates
/// - Profile picture uploads
/// - User preferences
/// - Profile validation
class UserStateProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isUpdating = false;

  // Profile update state
  UpdateProfileRequest? _pendingUpdate;
  bool _hasUnsavedChanges = false;

  // Profile picture state
  bool _isUploadingPicture = false;
  String? _uploadError;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUpdating => _isUpdating;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  bool get isUploadingPicture => _isUploadingPicture;
  String? get uploadError => _uploadError;

  // ============================================================================
  // USER PROFILE MANAGEMENT
  // ============================================================================

  /// Load current user profile
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await TokenManagementService.getValidAccessToken();
      if (token == null) {
        _error = 'No valid authentication token found';
        return;
      }

      _currentUser = await UserApiService.getCurrentUser(token);
    } catch (e) {
      _error = 'Failed to load user profile: ${e.toString()}';
      print('Error loading current user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      final token = await TokenManagementService.getValidAccessToken();
      if (token == null) {
        _error = 'No valid authentication token found';
        return false;
      }

      // Validate request
      if (!ProfileApiService.isValidProfileUpdateRequest(request)) {
        final errors = ProfileApiService.validateProfileUpdateRequest(request);
        _error = ProfileApiService.getProfileUpdateValidationErrors(request);
        return false;
      }

      final response = await ProfileApiService.updateProfile(request, token);

      if (response.status) {
        // Reload user profile to get updated data
        await loadCurrentUser();
        _hasUnsavedChanges = false;
        _pendingUpdate = null;
        return true;
      } else {
        _error = response.message;
        return false;
      }
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      print('Error updating profile: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Update profile bio
  Future<bool> updateProfileBio(String bio) async {
    final request = UpdateProfileRequest(profileBio: bio);
    return await updateProfile(request);
  }

  /// Update height and weight
  Future<bool> updateHeightAndWeight(int height, int weight) async {
    final request = UpdateProfileRequest(
      height: height,
      weight: weight,
    );
    return await updateProfile(request);
  }

  /// Update lifestyle preferences
  Future<bool> updateLifestylePreferences({
    bool? smoke,
    bool? drink,
    bool? gym,
  }) async {
    final request = UpdateProfileRequest(
      smoke: smoke,
      drink: drink,
      gym: gym,
    );
    return await updateProfile(request);
  }

  /// Update age preferences
  Future<bool> updateAgePreferences(int minAge, int maxAge) async {
    final request = UpdateProfileRequest(
      minAgePreference: minAge,
      maxAgePreference: maxAge,
    );
    return await updateProfile(request);
  }

  // ============================================================================
  // PROFILE PICTURE MANAGEMENT
  // ============================================================================

  /// Upload profile picture
  Future<bool> uploadProfilePicture(String imagePath, {bool isPrimary = false}) async {
    _isUploadingPicture = true;
    _uploadError = null;
    notifyListeners();

    try {
      final token = await TokenManagementService.getValidAccessToken();
      if (token == null) {
        _uploadError = 'No valid authentication token found';
        return false;
      }

      // Note: This would require actual file handling
      // For now, we'll simulate the upload process
      final result = await ProfileApiService.uploadProfilePictureWithErrorHandling(
        null, // File object would go here
        isPrimary,
        token,
      );

      if (result['success']) {
        // Reload user profile to get updated picture
        await loadCurrentUser();
        return true;
      } else {
        _uploadError = result['error'];
        return false;
      }
    } catch (e) {
      _uploadError = 'Failed to upload profile picture: ${e.toString()}';
      print('Error uploading profile picture: $e');
      return false;
    } finally {
      _isUploadingPicture = false;
      notifyListeners();
    }
  }

  /// Set primary profile picture
  Future<bool> setPrimaryProfilePicture(int imageId) async {
    // This would typically involve an API call to set the primary picture
    // For now, we'll simulate it
    try {
      await loadCurrentUser();
      return true;
    } catch (e) {
      _error = 'Failed to set primary picture: ${e.toString()}';
      return false;
    }
  }

  /// Delete profile picture
  Future<bool> deleteProfilePicture(int imageId) async {
    // This would typically involve an API call to delete the picture
    // For now, we'll simulate it
    try {
      await loadCurrentUser();
      return true;
    } catch (e) {
      _error = 'Failed to delete picture: ${e.toString()}';
      return false;
    }
  }

  // ============================================================================
  // PROFILE VALIDATION
  // ============================================================================

  /// Validate profile bio
  bool validateProfileBio(String bio) {
    return ProfileApiService.isValidProfileBio(bio);
  }

  /// Validate height
  bool validateHeight(int height) {
    return ProfileApiService.isValidHeight(height);
  }

  /// Validate weight
  bool validateWeight(int weight) {
    return ProfileApiService.isValidWeight(weight);
  }

  /// Validate age preferences
  bool validateAgePreferences(int minAge, int maxAge) {
    return ProfileApiService.isValidAgePreference(minAge, maxAge);
  }

  /// Get profile bio character count
  int getProfileBioCharacterCount(String bio) {
    return ProfileApiService.getProfileBioCharacterCount(bio);
  }

  /// Get remaining bio characters
  int getRemainingBioCharacters(String bio) {
    return ProfileApiService.getRemainingBioCharacters(bio);
  }

  /// Check if profile bio is too long
  bool isProfileBioTooLong(String bio) {
    return ProfileApiService.isProfileBioTooLong(bio);
  }

  // ============================================================================
  // PROFILE UTILITIES
  // ============================================================================

  /// Format height for display
  String formatHeight(int? height) {
    return ProfileApiService.formatHeight(height);
  }

  /// Format weight for display
  String formatWeight(int? weight) {
    return ProfileApiService.formatWeight(weight);
  }

  /// Format age preferences for display
  String formatAgePreferences(int? minAge, int? maxAge) {
    return ProfileApiService.formatAgePreference(minAge, maxAge);
  }

  /// Get lifestyle preferences string
  String getLifestylePreferences() {
    if (_currentUser == null) return 'No preferences set';
    
    return ProfileApiService.getLifestyleString(
      _currentUser!.smoke,
      _currentUser!.drink,
      _currentUser!.gym,
    );
  }

  /// Get user's primary image URL
  String? getPrimaryImageUrl() {
    return _currentUser?.primaryImageUrl;
  }

  /// Get user's age
  int? getUserAge() {
    return _currentUser?.age;
  }

  /// Get user's full name
  String? getFullName() {
    return _currentUser?.fullName;
  }

  /// Get user's location
  String? getLocation() {
    if (_currentUser == null) return null;
    
    final parts = <String>[];
    if (_currentUser!.city != null) parts.add(_currentUser!.city!);
    if (_currentUser!.country != null) parts.add(_currentUser!.country!);
    
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Check if user has completed profile
  bool get isProfileCompleted {
    return _currentUser?.profileCompleted ?? false;
  }

  /// Get profile completion percentage
  double get profileCompletionPercentage {
    if (_currentUser == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 10; // Total number of profile fields
    
    if (_currentUser!.profileBio?.isNotEmpty == true) completedFields++;
    if (_currentUser!.height != null) completedFields++;
    if (_currentUser!.weight != null) completedFields++;
    if (_currentUser!.smoke != null) completedFields++;
    if (_currentUser!.drink != null) completedFields++;
    if (_currentUser!.gym != null) completedFields++;
    if (_currentUser!.minAgePreference != null) completedFields++;
    if (_currentUser!.maxAgePreference != null) completedFields++;
    if (_currentUser!.images?.isNotEmpty == true) completedFields++;
    if (_currentUser!.interests?.isNotEmpty == true) completedFields++;
    
    return completedFields / totalFields;
  }

  // ============================================================================
  // PENDING CHANGES MANAGEMENT
  // ============================================================================

  /// Set pending update
  void setPendingUpdate(UpdateProfileRequest request) {
    _pendingUpdate = request;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// Clear pending update
  void clearPendingUpdate() {
    _pendingUpdate = null;
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  /// Save pending update
  Future<bool> savePendingUpdate() async {
    if (_pendingUpdate == null) return true;
    
    final success = await updateProfile(_pendingUpdate!);
    if (success) {
      clearPendingUpdate();
    }
    return success;
  }

  // ============================================================================
  // ERROR HANDLING
  // ============================================================================

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear upload error
  void clearUploadError() {
    _uploadError = null;
    notifyListeners();
  }

  /// Clear all errors
  void clearAllErrors() {
    _error = null;
    _uploadError = null;
    notifyListeners();
  }

  // ============================================================================
  // REFRESH AND RELOAD
  // ============================================================================

  /// Refresh user profile
  Future<void> refreshProfile() async {
    await loadCurrentUser();
  }

  /// Reload user profile
  Future<void> reloadProfile() async {
    _currentUser = null;
    await loadCurrentUser();
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if user can update profile
  bool get canUpdateProfile {
    return _currentUser != null && !_isUpdating;
  }

  /// Check if user can upload pictures
  bool get canUploadPictures {
    return _currentUser != null && !_isUploadingPicture;
  }

  /// Get user's display name
  String getDisplayName() {
    if (_currentUser == null) return 'Unknown User';
    return _currentUser!.fullName;
  }

  /// Get user's initials
  String getInitials() {
    if (_currentUser == null) return 'U';
    
    final name = _currentUser!.fullName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Check if user has profile picture
  bool get hasProfilePicture {
    return _currentUser?.images?.isNotEmpty == true;
  }

  /// Get user's profile picture count
  int get profilePictureCount {
    return _currentUser?.images?.length ?? 0;
  }

  /// Check if user is online (placeholder)
  bool get isOnline {
    // This would typically be determined by WebSocket connection status
    return true;
  }

  /// Get last seen time (placeholder)
  DateTime? get lastSeen {
    // This would typically come from the user's last activity
    return DateTime.now().subtract(const Duration(minutes: 5));
  }
}
