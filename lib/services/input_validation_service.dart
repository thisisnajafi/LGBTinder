import 'package:flutter/foundation.dart';
import 'package:email_validator/email_validator.dart';
import '../utils/error_handler.dart';

class InputValidationService {
  static final InputValidationService _instance = InputValidationService._internal();
  factory InputValidationService() => _instance;
  InputValidationService._internal();

  /// Validate email address
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return EmailValidator.validate(email);
  }

  /// Validate password strength
  static PasswordValidationResult validatePassword(String password) {
    final result = PasswordValidationResult();
    
    if (password.isEmpty) {
      result.isValid = false;
      result.errors.add('Password cannot be empty');
      return result;
    }
    
    if (password.length < 8) {
      result.isValid = false;
      result.errors.add('Password must be at least 8 characters long');
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      result.isValid = false;
      result.errors.add('Password must contain at least one uppercase letter');
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      result.isValid = false;
      result.errors.add('Password must contain at least one lowercase letter');
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      result.isValid = false;
      result.errors.add('Password must contain at least one number');
    }
    
    return result;
  }

  /// Validate name
  static NameValidationResult validateName(String name) {
    final result = NameValidationResult();
    
    if (name.isEmpty) {
      result.isValid = false;
      result.errors.add('Name cannot be empty');
      return result;
    }
    
    if (name.length < 2) {
      result.isValid = false;
      result.errors.add('Name must be at least 2 characters long');
    }
    
    return result;
  }

  /// Validate phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;
    return phoneNumber.contains(RegExp(r'^[+\d\s\-\(\)]{10,}$'));
  }
}

class PasswordValidationResult {
  bool isValid = true;
  List<String> errors = [];
}

class NameValidationResult {
  bool isValid = true;
  List<String> errors = [];
}