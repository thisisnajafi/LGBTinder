import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  // Check authentication status on app start
  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _userData = await _authService.getUserData();
        _isAuthenticated = true;
      }
    } catch (e) {
      _errorMessage = 'Error checking authentication status';
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);
      
      if (result['success']) {
        _isAuthenticated = true;
        _userData = result['user'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      if (result['success']) {
        _isAuthenticated = true;
        _userData = result['user'];
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        if (result['errors'] != null) {
          // Handle validation errors
          final errors = result['errors'] as Map<String, dynamic>;
          final errorMessages = errors.values
              .where((value) => value is List)
              .expand((value) => value as List)
              .join(', ');
          _errorMessage = errorMessages.isNotEmpty ? errorMessages : _errorMessage;
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _isAuthenticated = false;
      _userData = null;
      _clearError();
    } catch (e) {
      _errorMessage = 'Error during logout';
    } finally {
      _setLoading(false);
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    try {
      _userData = await _authService.getUserData();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error refreshing user data';
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 