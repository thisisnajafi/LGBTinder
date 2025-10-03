import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/api_models/profile_models.dart';
import '../models/api_models/auth_models.dart';
import '../models/user.dart';
import '../models/user_image.dart';
import '../models/user_preferences.dart';
import '../models/user_verification.dart';
import '../services/api_services/profile_api_service.dart';
import '../services/api_services/user_api_service.dart';
import '../services/token_management_service.dart';
import '../services/rate_limiting_service.dart';
import '../models/user_state_models.dart';

class ProfileStateProvider extends ChangeNotifier {
  // State variables
  User? _currentUser;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isUploading = false;
  AuthError? _error;
  String? _lastUpdateError;
  String? _lastUploadError;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isUploading => _isUploading;
  AuthError? get error => _error;
  String? get lastUpdateError => _lastUpdateError;
  String? get lastUploadError => _lastUploadError;
  
  // Mock getters for compatibility - return proper types
  UserPreferences? get preferences => null;
  UserVerification? get verification => null;

  // Initialize the provider
  Future<void> initialize() async {
    await loadCurrentUser();
  }

  // Load current user profile
  Future<void> loadCurrentUser() async {
    try {
      _setLoading(true);
      _clearError();

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      final userProfile = await UserApiService.getCurrentUser(token);
      // Convert UserProfile to User if needed - for now use mock
      _currentUser = _currentUser; // Keep existing user for now
      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? profileBio,
    int? height,
    int? weight,
    bool? smoke,
    bool? drink,
    bool? gym,
    int? minAgePreference,
    int? maxAgePreference,
  }) async {
    try {
      _setUpdating(true);
      _clearError();
      _lastUpdateError = null;

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      // Check rate limiting
      await RateLimitingService.checkRateLimit('default');

      final request = UpdateProfileRequest(
        profileBio: profileBio,
        height: height,
        weight: weight,
        smoke: smoke,
        drink: drink,
        gym: gym,
        minAgePreference: minAgePreference,
        maxAgePreference: maxAgePreference,
      );

      final response = await ProfileApiService.updateProfile(request, token);

      if (response.status) {
        // Update local user data
        if (_currentUser != null && response.data != null) {
          _currentUser = User(
            id: _currentUser!.id,
            firstName: _currentUser!.firstName,
            lastName: _currentUser!.lastName,
            fullName: _currentUser!.fullName,
            email: _currentUser!.email,
            countryId: _currentUser!.countryId,
            cityId: _currentUser!.cityId,
            country: _currentUser!.country,
            city: _currentUser!.city,
            birthDate: _currentUser!.birthDate,
            profileBio: _currentUser!.profileBio, // Keep existing for now
            avatarUrl: _currentUser!.avatarUrl,
            height: _currentUser!.height, // Keep existing for now - response.data is UserProfile, not direct properties
            weight: _currentUser!.weight,
            smoke: _currentUser!.smoke,
            drink: _currentUser!.drink,
            gym: _currentUser!.gym,
            minAgePreference: response.data!.minAgePreference ?? _currentUser!.minAgePreference,
            maxAgePreference: response.data!.maxAgePreference ?? _currentUser!.maxAgePreference,
            profileCompleted: _currentUser!.profileCompleted,
            createdAt: _currentUser!.createdAt,
            updatedAt: _currentUser!.updatedAt,
            images: _currentUser!.images,
            jobs: _currentUser!.jobs,
            educations: _currentUser!.educations,
            musicGenres: _currentUser!.musicGenres,
            languages: _currentUser!.languages,
            interests: _currentUser!.interests,
            preferredGenders: _currentUser!.preferredGenders,
            relationGoals: _currentUser!.relationGoals,
          );
        }
        notifyListeners();
        return true;
      } else {
        _lastUpdateError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is RateLimitExceededException) {
        _lastUpdateError = e.message;
      } else {
        _handleError(e);
      }
      notifyListeners();
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Upload profile picture
  Future<bool> uploadProfilePicture(File image, {bool isPrimary = false}) async {
    try {
      _setUploading(true);
      _clearError();
      _lastUploadError = null;

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      // Check rate limiting
      await RateLimitingService.checkRateLimit('default');

      final request = UploadProfilePictureRequest(
        imagePath: image.path,
        isPrimary: isPrimary,
      );

      final response = await ProfileApiService.uploadProfilePicture(request, token);

      if (response.status) {
        // Update local user data with new image
        if (_currentUser != null && response.data != null) {
          final newImage = UserImage(
            id: response.data!.id,
            url: response.data!.url,
            isPrimary: response.data!.isPrimary,
            order: 0, // This would need to be determined by the API
            type: 'profile', // Default to profile type
            createdAt: DateTime.now(), // Use current time for new image
            updatedAt: DateTime.now(),
          );

          final existingImages = _currentUser!.images ?? [];
          final updatedImages = [...existingImages, newImage];

          _currentUser = User(
            id: _currentUser!.id,
            firstName: _currentUser!.firstName,
            lastName: _currentUser!.lastName,
            fullName: _currentUser!.fullName,
            email: _currentUser!.email,
            countryId: _currentUser!.countryId,
            cityId: _currentUser!.cityId,
            country: _currentUser!.country,
            city: _currentUser!.city,
            birthDate: _currentUser!.birthDate,
            profileBio: _currentUser!.profileBio,
            avatarUrl: isPrimary ? response.data!.url : _currentUser!.avatarUrl,
            height: _currentUser!.height,
            weight: _currentUser!.weight,
            smoke: _currentUser!.smoke,
            drink: _currentUser!.drink,
            gym: _currentUser!.gym,
            minAgePreference: _currentUser!.minAgePreference,
            maxAgePreference: _currentUser!.maxAgePreference,
            profileCompleted: _currentUser!.profileCompleted,
            createdAt: _currentUser!.createdAt,
            updatedAt: _currentUser!.updatedAt,
            images: updatedImages.cast<UserImage>() as List<UserImage>?,
            jobs: _currentUser!.jobs,
            educations: _currentUser!.educations,
            musicGenres: _currentUser!.musicGenres,
            languages: _currentUser!.languages,
            interests: _currentUser!.interests,
            preferredGenders: _currentUser!.preferredGenders,
            relationGoals: _currentUser!.relationGoals,
          );
        }
        notifyListeners();
        return true;
      } else {
        _lastUploadError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is RateLimitExceededException) {
        _lastUploadError = e.message;
      } else {
        _handleError(e);
      }
      notifyListeners();
      return false;
    } finally {
      _setUploading(false);
    }
  }

  // Delete profile picture
  Future<bool> deleteProfilePicture(int imageId) async {
    try {
      _setUpdating(true);
      _clearError();

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      // Check rate limiting
      await RateLimitingService.checkRateLimit('default');

      // This would need to be implemented in ProfileApiService
      // final response = await ProfileApiService.deleteProfilePicture(imageId, token);

      // For now, just update local state
      if (_currentUser != null) {
        final existingImages = _currentUser!.images ?? [];
        final updatedImages = existingImages.where((img) => img.id != imageId).toList();

        _currentUser = User(
          id: _currentUser!.id,
          firstName: _currentUser!.firstName,
          lastName: _currentUser!.lastName,
          fullName: _currentUser!.fullName,
          email: _currentUser!.email,
          countryId: _currentUser!.countryId,
          cityId: _currentUser!.cityId,
          country: _currentUser!.country,
          city: _currentUser!.city,
          birthDate: _currentUser!.birthDate,
          profileBio: _currentUser!.profileBio,
          avatarUrl: _currentUser!.avatarUrl,
          height: _currentUser!.height,
          weight: _currentUser!.weight,
          smoke: _currentUser!.smoke,
          drink: _currentUser!.drink,
          gym: _currentUser!.gym,
          minAgePreference: _currentUser!.minAgePreference,
          maxAgePreference: _currentUser!.maxAgePreference,
          profileCompleted: _currentUser!.profileCompleted,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
          images: updatedImages,
          jobs: _currentUser!.jobs,
          educations: _currentUser!.educations,
          musicGenres: _currentUser!.musicGenres,
          languages: _currentUser!.languages,
          interests: _currentUser!.interests,
          preferredGenders: _currentUser!.preferredGenders,
          relationGoals: _currentUser!.relationGoals,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Set primary profile picture
  Future<bool> setPrimaryProfilePicture(int imageId) async {
    try {
      _setUpdating(true);
      _clearError();

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      // Check rate limiting
      await RateLimitingService.checkRateLimit('default');

      // This would need to be implemented in ProfileApiService
      // final response = await ProfileApiService.setPrimaryProfilePicture(imageId, token);

      // For now, just update local state
      if (_currentUser != null) {
        final existingImages = _currentUser!.images ?? [];
        final updatedImages = existingImages.map((img) {
          return UserImage(
            id: img.id,
            url: img.url,
            isPrimary: img.id == imageId,
            order: img.order,
            type: img.type, // Keep existing type
            createdAt: img.createdAt, // Keep existing createdAt
            updatedAt: img.updatedAt, // Keep existing updatedAt
          );
        }).toList();

        final primaryImage = updatedImages.firstWhere((img) => img.id == imageId);

        _currentUser = User(
          id: _currentUser!.id,
          firstName: _currentUser!.firstName,
          lastName: _currentUser!.lastName,
          fullName: _currentUser!.fullName,
          email: _currentUser!.email,
          countryId: _currentUser!.countryId,
          cityId: _currentUser!.cityId,
          country: _currentUser!.country,
          city: _currentUser!.city,
          birthDate: _currentUser!.birthDate,
          profileBio: _currentUser!.profileBio,
          avatarUrl: primaryImage.url,
          height: _currentUser!.height,
          weight: _currentUser!.weight,
          smoke: _currentUser!.smoke,
          drink: _currentUser!.drink,
          gym: _currentUser!.gym,
          minAgePreference: _currentUser!.minAgePreference,
          maxAgePreference: _currentUser!.maxAgePreference,
          profileCompleted: _currentUser!.profileCompleted,
          createdAt: _currentUser!.createdAt,
          updatedAt: _currentUser!.updatedAt,
          images: updatedImages,
          jobs: _currentUser!.jobs,
          educations: _currentUser!.educations,
          musicGenres: _currentUser!.musicGenres,
          languages: _currentUser!.languages,
          interests: _currentUser!.interests,
          preferredGenders: _currentUser!.preferredGenders,
          relationGoals: _currentUser!.relationGoals,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _setUpdating(false);
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadCurrentUser();
  }

  // Clear all data
  void clearData() {
    _currentUser = null;
    _clearError();
    _lastUpdateError = null;
    _lastUploadError = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    if (error is AuthError) {
      _error = error;
    } else if (error is RateLimitExceededException) {
      _error = AuthError(
        type: AuthErrorType.networkError,
        message: error.message,
        details: {'retry_after': error.retryAfter, 'message': 'Rate limit exceeded'},
      );
    } else {
      _error = AuthError(
        type: AuthErrorType.unknownError,
        message: 'An unexpected error occurred',
        details: {'error': error.toString()},
      );
    }
    notifyListeners();
  }

  // Dispose method
  @override
  void dispose() {
    super.dispose();
  }
}
