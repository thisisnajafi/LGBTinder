import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';
import 'jwt_token_service.dart';
import 'input_validation_service.dart';

class SecurityManager {
  static final SecurityManager _instance = SecurityManager._internal();
  factory SecurityManager() => _instance;
  SecurityManager._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final JWTTokenService _tokenService = JWTTokenService();
  final InputValidationService _validationService = InputValidationService();
  
  // Security settings
  bool _biometricEnabled = false;
  bool _autoLockEnabled = true;
  Duration _autoLockTimeout = Duration(minutes: 15);
  bool _debugModeEnabled = false;
  
  // Security events
  final StreamController<SecurityEvent> _securityEventController = StreamController<SecurityEvent>.broadcast();
  Stream<SecurityEvent> get securityEvents => _securityEventController.stream;
  
  // Failed login attempts
  int _failedLoginAttempts = 0;
  DateTime? _lastFailedLoginAttempt;
  Duration _lockoutDuration = Duration(minutes: 15);
  
  // Session management
  DateTime? _lastActivity;
  Timer? _sessionTimer;
  
  /// Initialize security manager
  Future<void> initialize() async {
    await _loadSecuritySettings();
    await _tokenService.initialize(
      onTokenRefreshed: _onTokenRefreshed,
      onTokenRefreshFailed: _onTokenRefreshFailed,
    );
    _startSessionTimer();
    _securityEventController.add(SecurityEvent.initialized);
    debugPrint('SecurityManager initialized');
  }

  /// Load security settings from storage
  Future<void> _loadSecuritySettings() async {
    try {
      final biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
      _biometricEnabled = biometricEnabled == 'true';
      
      final autoLockEnabled = await _secureStorage.read(key: 'auto_lock_enabled');
      _autoLockEnabled = autoLockEnabled != 'false'; // Default to true
      
      final autoLockTimeout = await _secureStorage.read(key: 'auto_lock_timeout');
      if (autoLockTimeout != null) {
        _autoLockTimeout = Duration(minutes: int.parse(autoLockTimeout));
      }
      
      final debugMode = await _secureStorage.read(key: 'debug_mode_enabled');
      _debugModeEnabled = debugMode == 'true';
      
      final failedAttempts = await _secureStorage.read(key: 'failed_login_attempts');
      _failedLoginAttempts = failedAttempts != null ? int.parse(failedAttempts) : 0;
      
      final lastFailedAttempt = await _secureStorage.read(key: 'last_failed_login_attempt');
      if (lastFailedAttempt != null) {
        _lastFailedLoginAttempt = DateTime.parse(lastFailedAttempt);
      }
    } catch (e) {
      debugPrint('Failed to load security settings: $e');
    }
  }

  /// Save security settings to storage
  Future<void> _saveSecuritySettings() async {
    try {
      await Future.wait([
        _secureStorage.write(key: 'biometric_enabled', value: _biometricEnabled.toString()),
        _secureStorage.write(key: 'auto_lock_enabled', value: _autoLockEnabled.toString()),
        _secureStorage.write(key: 'auto_lock_timeout', value: _autoLockTimeout.inMinutes.toString()),
        _secureStorage.write(key: 'debug_mode_enabled', value: _debugModeEnabled.toString()),
        _secureStorage.write(key: 'failed_login_attempts', value: _failedLoginAttempts.toString()),
        if (_lastFailedLoginAttempt != null)
          _secureStorage.write(key: 'last_failed_login_attempt', value: _lastFailedLoginAttempt!.toIso8601String()),
      ]);
    } catch (e) {
      debugPrint('Failed to save security settings: $e');
    }
  }

  /// Start session timer
  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkSessionTimeout();
    });
  }

  /// Check session timeout
  void _checkSessionTimeout() {
    if (_autoLockEnabled && _lastActivity != null) {
      final timeSinceLastActivity = DateTime.now().difference(_lastActivity!);
      if (timeSinceLastActivity > _autoLockTimeout) {
        _lockSession();
      }
    }
  }

  /// Update last activity
  void updateLastActivity() {
    _lastActivity = DateTime.now();
  }

  /// Lock session
  void _lockSession() {
    _securityEventController.add(SecurityEvent.sessionLocked);
    debugPrint('Session locked due to inactivity');
  }

  /// Unlock session
  Future<bool> unlockSession(String password) async {
    try {
      // Validate password
      final validation = InputValidationService.validatePassword(password);
      if (!validation.isValid) {
        _securityEventController.add(SecurityEvent.unlockFailed);
        return false;
      }
      
      // Check if password matches stored hash
      final storedHash = await _secureStorage.read(key: 'session_password_hash');
      if (storedHash != null) {
        final inputHash = _hashPassword(password);
        if (inputHash != storedHash) {
          _securityEventController.add(SecurityEvent.unlockFailed);
          return false;
        }
      }
      
      _lastActivity = DateTime.now();
      _securityEventController.add(SecurityEvent.sessionUnlocked);
      debugPrint('Session unlocked successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to unlock session: $e');
      _securityEventController.add(SecurityEvent.unlockFailed);
      return false;
    }
  }

  /// Set session password
  Future<void> setSessionPassword(String password) async {
    try {
      final validation = InputValidationService.validatePassword(password);
      if (!validation.isValid) {
        throw ValidationException(validation.firstError);
      }
      
      final hash = _hashPassword(password);
      await _secureStorage.write(key: 'session_password_hash', value: hash);
      debugPrint('Session password set successfully');
    } catch (e) {
      debugPrint('Failed to set session password: $e');
      rethrow;
    }
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    await _saveSecuritySettings();
    _securityEventController.add(enabled ? SecurityEvent.biometricEnabled : SecurityEvent.biometricDisabled);
  }

  /// Enable/disable auto lock
  Future<void> setAutoLockEnabled(bool enabled) async {
    _autoLockEnabled = enabled;
    await _saveSecuritySettings();
    _securityEventController.add(enabled ? SecurityEvent.autoLockEnabled : SecurityEvent.autoLockDisabled);
  }

  /// Set auto lock timeout
  Future<void> setAutoLockTimeout(Duration timeout) async {
    _autoLockTimeout = timeout;
    await _saveSecuritySettings();
    _securityEventController.add(SecurityEvent.autoLockTimeoutChanged);
  }

  /// Enable/disable debug mode
  Future<void> setDebugModeEnabled(bool enabled) async {
    _debugModeEnabled = enabled;
    await _saveSecuritySettings();
    _securityEventController.add(enabled ? SecurityEvent.debugModeEnabled : SecurityEvent.debugModeDisabled);
  }

  /// Check if account is locked due to failed login attempts
  bool isAccountLocked() {
    if (_failedLoginAttempts < 5) return false;
    
    if (_lastFailedLoginAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastFailedLoginAttempt!);
      return timeSinceLastAttempt < _lockoutDuration;
    }
    
    return false;
  }

  /// Record failed login attempt
  Future<void> recordFailedLoginAttempt() async {
    _failedLoginAttempts++;
    _lastFailedLoginAttempt = DateTime.now();
    await _saveSecuritySettings();
    
    if (_failedLoginAttempts >= 5) {
      _securityEventController.add(SecurityEvent.accountLocked);
      debugPrint('Account locked due to failed login attempts');
    } else {
      _securityEventController.add(SecurityEvent.failedLoginAttempt);
      debugPrint('Failed login attempt recorded: $_failedLoginAttempts');
    }
  }

  /// Reset failed login attempts
  Future<void> resetFailedLoginAttempts() async {
    _failedLoginAttempts = 0;
    _lastFailedLoginAttempt = null;
    await _saveSecuritySettings();
    _securityEventController.add(SecurityEvent.failedLoginAttemptsReset);
    debugPrint('Failed login attempts reset');
  }

  /// Validate input with security checks
  ValidationResult validateInput(String type, dynamic input) {
    switch (type) {
      case 'email':
        return InputValidationService.isValidEmail(input as String) 
            ? ValidationResult() 
            : ValidationResult()..addError('Invalid email format');
      case 'password':
        return InputValidationService.validatePassword(input as String);
      case 'name':
        return InputValidationService.validateName(input as String);
      case 'age':
        return InputValidationService.validateAge(input as int);
      case 'phone':
        return InputValidationService.validatePhoneNumber(input as String);
      case 'bio':
        return InputValidationService.validateBio(input as String);
      case 'location':
        return InputValidationService.validateLocation(input as String);
      case 'interests':
        return InputValidationService.validateInterests(input as List<String>);
      case 'message':
        return InputValidationService.validateMessage(input as String);
      case 'report':
        final report = input as Map<String, String>;
        return InputValidationService.validateReport(report['reason']!, report['description']!);
      case 'search':
        return InputValidationService.validateSearchQuery(input as String);
      case 'url':
        return InputValidationService.validateUrl(input as String);
      default:
        return ValidationResult()..addError('Unknown validation type');
    }
  }

  /// Sanitize input
  String sanitizeInput(String input) {
    return InputValidationService.sanitizeInput(input);
  }

  /// Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure random string
  String generateSecureRandomString(int length) {
    final random = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  /// Generate secure random number
  int generateSecureRandomNumber(int min, int max) {
    final random = Random.secure();
    return min + random.nextInt(max - min + 1);
  }

  /// Encrypt sensitive data
  Future<String> encryptData(String data) async {
    try {
      // In a real app, you would use proper encryption
      // For now, we'll use base64 encoding
      final bytes = utf8.encode(data);
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Failed to encrypt data: $e');
      throw SecurityException('Failed to encrypt data');
    }
  }

  /// Decrypt sensitive data
  Future<String> decryptData(String encryptedData) async {
    try {
      // In a real app, you would use proper decryption
      // For now, we'll use base64 decoding
      final bytes = base64Decode(encryptedData);
      return utf8.decode(bytes);
    } catch (e) {
      debugPrint('Failed to decrypt data: $e');
      throw SecurityException('Failed to decrypt data');
    }
  }

  /// Store sensitive data securely
  Future<void> storeSecureData(String key, String value) async {
    try {
      final encryptedValue = await encryptData(value);
      await _secureStorage.write(key: key, value: encryptedValue);
    } catch (e) {
      debugPrint('Failed to store secure data: $e');
      throw SecurityException('Failed to store secure data');
    }
  }

  /// Retrieve sensitive data securely
  Future<String?> getSecureData(String key) async {
    try {
      final encryptedValue = await _secureStorage.read(key: key);
      if (encryptedValue != null) {
        return await decryptData(encryptedValue);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get secure data: $e');
      return null;
    }
  }

  /// Delete sensitive data
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Failed to delete secure data: $e');
    }
  }

  /// Clear all sensitive data
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('Failed to clear all secure data: $e');
    }
  }

  /// Check if device is secure
  Future<bool> isDeviceSecure() async {
    try {
      // Check if device has screen lock
      // This would require platform-specific implementation
      return true; // Placeholder
    } catch (e) {
      debugPrint('Failed to check device security: $e');
      return false;
    }
  }

  /// Get security status
  Map<String, dynamic> getSecurityStatus() {
    return {
      'biometric_enabled': _biometricEnabled,
      'auto_lock_enabled': _autoLockEnabled,
      'auto_lock_timeout_minutes': _autoLockTimeout.inMinutes,
      'debug_mode_enabled': _debugModeEnabled,
      'failed_login_attempts': _failedLoginAttempts,
      'account_locked': isAccountLocked(),
      'last_activity': _lastActivity?.toIso8601String(),
      'session_active': _lastActivity != null && 
          DateTime.now().difference(_lastActivity!) < _autoLockTimeout,
    };
  }

  /// Get security recommendations
  List<String> getSecurityRecommendations() {
    final recommendations = <String>[];
    
    if (!_biometricEnabled) {
      recommendations.add('Enable biometric authentication for better security');
    }
    
    if (!_autoLockEnabled) {
      recommendations.add('Enable auto-lock to protect your session');
    }
    
    if (_autoLockTimeout.inMinutes > 30) {
      recommendations.add('Consider reducing auto-lock timeout for better security');
    }
    
    if (_debugModeEnabled) {
      recommendations.add('Disable debug mode in production for security');
    }
    
    if (_failedLoginAttempts > 0) {
      recommendations.add('Consider changing your password after failed login attempts');
    }
    
    return recommendations;
  }

  /// Handle token refresh
  void _onTokenRefreshed(String newAccessToken, String newRefreshToken) {
    _securityEventController.add(SecurityEvent.tokenRefreshed);
    debugPrint('Token refreshed successfully');
  }

  /// Handle token refresh failure
  void _onTokenRefreshFailed() {
    _securityEventController.add(SecurityEvent.tokenRefreshFailed);
    debugPrint('Token refresh failed');
  }

  /// Dispose security manager
  void dispose() {
    _sessionTimer?.cancel();
    _securityEventController.close();
    _tokenService.dispose();
    debugPrint('SecurityManager disposed');
  }
}

/// Security event types
enum SecurityEvent {
  initialized,
  sessionLocked,
  sessionUnlocked,
  unlockFailed,
  biometricEnabled,
  biometricDisabled,
  autoLockEnabled,
  autoLockDisabled,
  autoLockTimeoutChanged,
  debugModeEnabled,
  debugModeDisabled,
  accountLocked,
  failedLoginAttempt,
  failedLoginAttemptsReset,
  tokenRefreshed,
  tokenRefreshFailed,
}

/// Security exception
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}

/// Validation result
class ValidationResult {
  final List<String> errors = [];
  
  void addError(String error) {
    errors.add(error);
  }
  
  bool get isValid => errors.isEmpty;
  
  String get firstError => errors.isNotEmpty ? errors.first : '';
  
  String get allErrors => errors.join(', ');
}
