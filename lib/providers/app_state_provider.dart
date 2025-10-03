import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_state_models.dart';
import '../models/user.dart';
import '../models/api_models/auth_models.dart';
import '../models/api_models/reference_data_models.dart';
import '../models/api_models/user_models.dart';
import '../services/api_services/auth_api_service.dart';
import '../services/api_services/reference_data_api_service.dart';
import '../services/api_services/user_api_service.dart';
import '../services/token_management_service.dart';
import '../services/rate_limiting_service.dart';

class AppStateProvider extends ChangeNotifier {
  UserState? _currentUserState;
  User? _user;
  String? _token;
  bool _isLoading = false;
  AuthError? _error;

  // Reference data cache
  Map<String, List<ReferenceDataItem>> _referenceData = {};
  List<Country> _countries = [];
  Map<int, List<City>> _citiesByCountry = {};
  
  // Secure storage keys
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserState? get currentUserState => _currentUserState;
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  AuthError? get error => _error;
  
  // Reference data getters
  Map<String, List<ReferenceDataItem>> get referenceData => _referenceData;
  List<Country> get countries => _countries;
  Map<int, List<City>> get citiesByCountry => _citiesByCountry;

  /// Initialize app state
  Future<void> initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is authenticated
      final isAuthenticated = await TokenManagementService.isAuthenticated();
      
      if (isAuthenticated) {
        // Get valid access token
        _token = await TokenManagementService.getValidAccessToken();
        
        if (_token != null) {
          // Get current user profile
          final userProfile = await UserApiService.getCurrentUser(_token!);
          _user = User.fromJson(userProfile?.toJson() ?? {});
          // For now, assume user needs login screen
          _currentUserState = ReadyForLoginState({'user_id': _user?.id ?? 0});
        } else {
          // Token is invalid, clear state
          _currentUserState = null;
          _user = null;
          _token = null;
        }
      } else {
        // User is not authenticated
        _currentUserState = null;
      }

      // Load reference data
      await _loadReferenceData();
    } catch (e) {
      print('Error initializing app: $e');
      _error = AuthError(
        type: AuthErrorType.networkError,
        message: 'Failed to initialize app. Please check your connection and try again.',
        details: {'error': e.toString()},
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle registration
  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        referralCode: referralCode,
      );

      final response = await AuthApiService.register(request);

      if (response.status) {
        _currentUserState = EmailVerificationRequiredState({
          'email': email,
          'user_id': response.data?.userId ?? 0,
          'userId': response.data?.userId ?? 0,
        });
        return AuthResult.success(message: response.message);
      } else {
        _error = AuthError(
          type: AuthErrorType.validationError,
          message: response.message,
          details: response.errors,
        );
        return AuthResult.error(response.message);
      }
    } catch (e) {
      _error = AuthError(
        type: AuthErrorType.networkError,
        message: 'Registration failed. Please check your connection and try again.',
        details: {'error': e.toString()},
      );
      return AuthResult.error('Registration failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle email verification
  Future<AuthResult> verifyEmail({
    required String email,
    required String code,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = VerifyEmailRequest(email: email, code: code);
      final response = await AuthApiService.verifyEmail(request);

      if (response.status) {
        if (response.data?.profileCompletionRequired == true) {
          // Store profile completion token
          await TokenManagementService.storeTokenData(
            accessToken: response.data?.token ?? '',
            tokenType: response.data?.tokenType,
            userId: response.data?.userId,
          );
          
          _currentUserState = ProfileCompletionRequiredState({
            'userId': response.data?.userId ?? 0,
            'email': email,
          });
        } else {
          _currentUserState = ReadyForLoginState({'user_id': response.data?.userId ?? 0});
        }
        return AuthResult.success(message: response.message);
      } else {
        _error = AuthError(
          type: AuthErrorType.invalidCode,
          message: response.message,
        );
        return AuthResult.error(response.message);
      }
    } catch (e) {
      _error = AuthError(
        type: AuthErrorType.networkError,
        message: 'Email verification failed. Please check your connection and try again.',
        details: {'error': e.toString()},
      );
      return AuthResult.error('Email verification failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle profile completion
  Future<AuthResult> completeProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUserState is ProfileCompletionRequiredState) {
        final state = _currentUserState as ProfileCompletionRequiredState;
        final token = state.token;

        final request = CompleteProfileRequest(
          deviceName: profileData['device_name'] ?? 'Flutter App',
          countryId: profileData['country_id'] as int,
          cityId: profileData['city_id'] as int,
          gender: profileData['gender'] as int,
          birthDate: profileData['birth_date'] as String,
          minAgePreference: profileData['min_age_preference'] as int,
          maxAgePreference: profileData['max_age_preference'] as int,
          profileBio: profileData['profile_bio'] as String,
          height: profileData['height'] as int,
          weight: profileData['weight'] as int,
          smoke: profileData['smoke'] as bool,
          drink: profileData['drink'] as bool,
          gym: profileData['gym'] as bool,
          musicGenres: List<int>.from(profileData['music_genres']),
          educations: List<int>.from(profileData['educations']),
          jobs: List<int>.from(profileData['jobs']),
          languages: List<int>.from(profileData['languages']),
          interests: List<int>.from(profileData['interests']),
          preferredGenders: List<int>.from(profileData['preferred_genders']),
          relationGoals: List<int>.from(profileData['relation_goals']),
        );

        final response = await AuthApiService.completeProfile(request, token);

        if (response.status && response.data != null) {
          // Store the new full access token
          await TokenManagementService.storeTokenData(
            accessToken: response.data!.token,
            tokenType: response.data!.tokenType,
            userId: response.data!.user.id,
          );

          _token = response.data!.token;
          _currentUserState = ReadyForLoginState({'user_id': response.data?.user.id ?? 0});

          return AuthResult.success(
            message: response.message,
            data: response.data?.toJson() ?? {},
          );
        } else {
          _error = AuthError(
            type: AuthErrorType.serverError,
            message: response.message,
          );
          return AuthResult.error(response.message);
        }
      } else {
        _error = AuthError(
          type: AuthErrorType.serverError,
          message: 'No profile completion token available. Please verify your email first.',
        );
        return AuthResult.error('No profile completion token available');
      }
    } catch (e) {
      _error = AuthError(
        type: AuthErrorType.networkError,
        message: 'Profile completion failed. Please check your connection and try again.',
        details: {'error': e.toString()},
      );
      return AuthResult.error('Profile completion failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load reference data
  Future<void> _loadReferenceData() async {
    try {
      // Load countries
      final countriesResponse = await ReferenceDataApiService.getCountries();
      _countries = countriesResponse.data;
      
      // Load all reference data - cast to proper type
      final refData = await ReferenceDataApiService.getAllReferenceData();
      _referenceData = Map<String, List<ReferenceDataItem>>.from(refData);
    } catch (e) {
      print('Error loading reference data: $e');
      // Don't fail the app initialization if reference data fails to load
    }
  }

  /// Load cities for a specific country
  Future<void> loadCitiesForCountry(int countryId) async {
    try {
      if (!_citiesByCountry.containsKey(countryId)) {
        final citiesResponse = await ReferenceDataApiService.getCitiesByCountry(countryId);
        _citiesByCountry[countryId] = citiesResponse.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cities for country $countryId: $e');
    }
  }

  /// Store token securely
  Future<void> _storeToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Store user data
  Future<void> _storeUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user));
  }

  /// Get stored user
  Future<Map<String, dynamic>?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  /// Logout
  Future<void> logout() async {
    try {
      await TokenManagementService.logout();
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      _token = null;
      _user = null;
      _currentUserState = null;
      _error = null;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
