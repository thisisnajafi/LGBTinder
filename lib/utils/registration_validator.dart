import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

/// Comprehensive validation class for user registration
class RegistrationValidator {
  // Validation patterns
    static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
  
  // Minimum age requirement (18 years)
  static const int _minimumAge = 18;
  
  // Maximum age limit (100 years)
  static const int _maximumAge = 100;

  /// Validates first name
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return 'First name must be less than 50 characters';
    }
    
    if (!_nameRegex.hasMatch(value.trim())) {
      return 'First name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validates last name
  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return 'Last name must be less than 50 characters';
    }
    
    if (!_nameRegex.hasMatch(value.trim())) {
      return 'Last name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    if (value.trim().length > 255) {
      return 'Email must be less than 255 characters';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates date of birth
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }
    
    final now = DateTime.now();
    final age = now.year - value.year - (now.month > value.month || (now.month == value.month && now.day >= value.day) ? 0 : 1);
    
    if (age < _minimumAge) {
      return 'You must be at least $_minimumAge years old to register';
    }
    
    if (age > _maximumAge) {
      return 'Please enter a valid date of birth';
    }
    
    // Check if date is not in the future
    if (value.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }
    
    return null;
  }

  /// Validates gender selection
  static String? validateGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your gender';
    }
    
    return null;
  }

  /// Validates interested in selection
  static String? validateInterestedIn(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select who you\'re interested in';
    }
    
    return null;
  }

  /// Validates relationship goal selection
  static String? validateRelationshipGoal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your relationship goal';
    }
    
    return null;
  }

  /// Gets password strength level (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    return strength;
  }

  /// Gets password strength description
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Very Weak';
    }
  }

  /// Gets password strength color
  static Color getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  /// Calculates age from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    
    return age;
  }

  /// Validates entire registration form
  static Map<String, String?> validateRegistrationForm({
    required String? firstName,
    required String? lastName,
    required String? email,
    required String? password,
    required String? confirmPassword,
    required DateTime? dateOfBirth,
    required String? gender,
    required String? interestedIn,
    required String? relationshipGoal,
  }) {
    return {
      'firstName': validateFirstName(firstName),
      'lastName': validateLastName(lastName),
      'email': validateEmail(email),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(confirmPassword, password ?? ''),
      'dateOfBirth': validateDateOfBirth(dateOfBirth),
      'gender': validateGender(gender),
      'interestedIn': validateInterestedIn(interestedIn),
      'relationshipGoal': validateRelationshipGoal(relationshipGoal),
    };
  }

  /// Checks if the registration form is valid
  static bool isFormValid(Map<String, String?> validationResults) {
    return validationResults.values.every((error) => error == null);
  }

  /// Gets all validation errors as a list
  static List<String> getValidationErrors(Map<String, String?> validationResults) {
    return validationResults.values
        .where((error) => error != null)
        .map((error) => error!)
        .toList();
  }
}
