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
      result.addError('Password is required');
      return result;
    }
    
    if (password.length < 8) {
      result.addError('Password must be at least 8 characters long');
    }
    
    if (password.length > 128) {
      result.addError('Password must be no more than 128 characters long');
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      result.addError('Password must contain at least one uppercase letter');
    }
    
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      result.addError('Password must contain at least one lowercase letter');
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      result.addError('Password must contain at least one number');
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      result.addError('Password must contain at least one special character');
    }
    
    // Check for common weak passwords
    if (_isCommonPassword(password)) {
      result.addError('Password is too common, please choose a stronger password');
    }
    
    // Check for repeated characters
    if (_hasRepeatedCharacters(password)) {
      result.addError('Password should not contain repeated characters');
    }
    
    // Check for sequential characters
    if (_hasSequentialCharacters(password)) {
      result.addError('Password should not contain sequential characters');
    }
    
    return result;
  }

  /// Validate name
  static NameValidationResult validateName(String name) {
    final result = NameValidationResult();
    
    if (name.isEmpty) {
      result.addError('Name is required');
      return result;
    }
    
    if (name.length < 2) {
      result.addError('Name must be at least 2 characters long');
    }
    
    if (name.length > 50) {
      result.addError('Name must be no more than 50 characters long');
    }
    
    if (!RegExp(r'^[a-zA-Z\s\-\.\']+$').hasMatch(name)) {
      result.addError('Name can only contain letters, spaces, hyphens, dots, and apostrophes');
    }
    
    if (RegExp(r'^\s|\s$').hasMatch(name)) {
      result.addError('Name cannot start or end with spaces');
    }
    
    if (RegExp(r'\s{2,}').hasMatch(name)) {
      result.addError('Name cannot contain multiple consecutive spaces');
    }
    
    return result;
  }

  /// Validate age
  static AgeValidationResult validateAge(int age) {
    final result = AgeValidationResult();
    
    if (age < 18) {
      result.addError('You must be at least 18 years old');
    }
    
    if (age > 100) {
      result.addError('Age must be no more than 100 years old');
    }
    
    return result;
  }

  /// Validate phone number
  static PhoneValidationResult validatePhoneNumber(String phoneNumber) {
    final result = PhoneValidationResult();
    
    if (phoneNumber.isEmpty) {
      result.addError('Phone number is required');
      return result;
    }
    
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      result.addError('Phone number must be at least 10 digits long');
    }
    
    if (digitsOnly.length > 15) {
      result.addError('Phone number must be no more than 15 digits long');
    }
    
    // Check for valid phone number patterns
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(digitsOnly)) {
      result.addError('Invalid phone number format');
    }
    
    return result;
  }

  /// Validate bio
  static BioValidationResult validateBio(String bio) {
    final result = BioValidationResult();
    
    if (bio.isEmpty) {
      result.addError('Bio is required');
      return result;
    }
    
    if (bio.length < 10) {
      result.addError('Bio must be at least 10 characters long');
    }
    
    if (bio.length > 500) {
      result.addError('Bio must be no more than 500 characters long');
    }
    
    // Check for inappropriate content
    if (_containsInappropriateContent(bio)) {
      result.addError('Bio contains inappropriate content');
    }
    
    // Check for spam patterns
    if (_containsSpamPatterns(bio)) {
      result.addError('Bio contains spam patterns');
    }
    
    return result;
  }

  /// Validate location
  static LocationValidationResult validateLocation(String location) {
    final result = LocationValidationResult();
    
    if (location.isEmpty) {
      result.addError('Location is required');
      return result;
    }
    
    if (location.length < 2) {
      result.addError('Location must be at least 2 characters long');
    }
    
    if (location.length > 100) {
      result.addError('Location must be no more than 100 characters long');
    }
    
    if (!RegExp(r'^[a-zA-Z\s\-\.,\']+$').hasMatch(location)) {
      result.addError('Location can only contain letters, spaces, hyphens, dots, commas, and apostrophes');
    }
    
    return result;
  }

  /// Validate interests
  static InterestsValidationResult validateInterests(List<String> interests) {
    final result = InterestsValidationResult();
    
    if (interests.isEmpty) {
      result.addError('At least one interest is required');
      return result;
    }
    
    if (interests.length > 10) {
      result.addError('You can select up to 10 interests');
    }
    
    for (final interest in interests) {
      if (interest.isEmpty) {
        result.addError('Interest cannot be empty');
        continue;
      }
      
      if (interest.length > 50) {
        result.addError('Interest must be no more than 50 characters long');
      }
      
      if (!RegExp(r'^[a-zA-Z\s\-\.,\']+$').hasMatch(interest)) {
        result.addError('Interest can only contain letters, spaces, hyphens, dots, commas, and apostrophes');
      }
    }
    
    // Check for duplicates
    final uniqueInterests = interests.toSet();
    if (uniqueInterests.length != interests.length) {
      result.addError('Interests must be unique');
    }
    
    return result;
  }

  /// Validate image file
  static ImageValidationResult validateImageFile(List<int> imageData, String fileName) {
    final result = ImageValidationResult();
    
    if (imageData.isEmpty) {
      result.addError('Image file is required');
      return result;
    }
    
    // Check file size (max 10MB)
    if (imageData.length > 10 * 1024 * 1024) {
      result.addError('Image file must be no more than 10MB');
    }
    
    // Check file extension
    final extension = fileName.toLowerCase().split('.').last;
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      result.addError('Image file must be JPG, JPEG, PNG, or WebP format');
    }
    
    // Check file signature
    if (!_isValidImageSignature(imageData)) {
      result.addError('Invalid image file format');
    }
    
    return result;
  }

  /// Validate message content
  static MessageValidationResult validateMessage(String message) {
    final result = MessageValidationResult();
    
    if (message.isEmpty) {
      result.addError('Message is required');
      return result;
    }
    
    if (message.length > 1000) {
      result.addError('Message must be no more than 1000 characters long');
    }
    
    // Check for inappropriate content
    if (_containsInappropriateContent(message)) {
      result.addError('Message contains inappropriate content');
    }
    
    // Check for spam patterns
    if (_containsSpamPatterns(message)) {
      result.addError('Message contains spam patterns');
    }
    
    return result;
  }

  /// Validate report content
  static ReportValidationResult validateReport(String reason, String description) {
    final result = ReportValidationResult();
    
    if (reason.isEmpty) {
      result.addError('Report reason is required');
    }
    
    if (description.isEmpty) {
      result.addError('Report description is required');
    }
    
    if (description.length < 10) {
      result.addError('Report description must be at least 10 characters long');
    }
    
    if (description.length > 500) {
      result.addError('Report description must be no more than 500 characters long');
    }
    
    return result;
  }

  /// Validate search query
  static SearchValidationResult validateSearchQuery(String query) {
    final result = SearchValidationResult();
    
    if (query.isEmpty) {
      result.addError('Search query is required');
      return result;
    }
    
    if (query.length < 2) {
      result.addError('Search query must be at least 2 characters long');
    }
    
    if (query.length > 100) {
      result.addError('Search query must be no more than 100 characters long');
    }
    
    // Check for SQL injection patterns
    if (_containsSqlInjectionPatterns(query)) {
      result.addError('Invalid search query');
    }
    
    // Check for XSS patterns
    if (_containsXssPatterns(query)) {
      result.addError('Invalid search query');
    }
    
    return result;
  }

  /// Validate URL
  static UrlValidationResult validateUrl(String url) {
    final result = UrlValidationResult();
    
    if (url.isEmpty) {
      result.addError('URL is required');
      return result;
    }
    
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !['http', 'https'].contains(uri.scheme)) {
        result.addError('URL must start with http:// or https://');
      }
      
      if (uri.host.isEmpty) {
        result.addError('URL must have a valid host');
      }
    } catch (e) {
      result.addError('Invalid URL format');
    }
    
    return result;
  }

  /// Sanitize input
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // Remove null bytes
    input = input.replaceAll('\x00', '');
    
    // Remove control characters except newlines and tabs
    input = input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    
    // Trim whitespace
    input = input.trim();
    
    return input;
  }

  /// Check if password is common
  static bool _isCommonPassword(String password) {
    final commonPasswords = [
      'password', '123456', '123456789', 'qwerty', 'abc123',
      'password123', 'admin', 'letmein', 'welcome', 'monkey',
      '1234567890', 'password1', 'qwerty123', 'dragon', 'master',
      'hello', 'freedom', 'whatever', 'qazwsx', 'trustno1',
    ];
    
    return commonPasswords.contains(password.toLowerCase());
  }

  /// Check for repeated characters
  static bool _hasRepeatedCharacters(String password) {
    return RegExp(r'(.)\1{2,}').hasMatch(password);
  }

  /// Check for sequential characters
  static bool _hasSequentialCharacters(String password) {
    final sequences = [
      'abcdefghijklmnopqrstuvwxyz',
      'zyxwvutsrqponmlkjihgfedcba',
      '0123456789',
      '9876543210',
    ];
    
    for (final sequence in sequences) {
      for (int i = 0; i <= sequence.length - 3; i++) {
        final subSequence = sequence.substring(i, i + 3);
        if (password.toLowerCase().contains(subSequence)) {
          return true;
        }
      }
    }
    
    return false;
  }

  /// Check for inappropriate content
  static bool _containsInappropriateContent(String text) {
    final inappropriateWords = [
      'spam', 'scam', 'fake', 'bot', 'hack', 'phish',
      'malware', 'virus', 'trojan', 'exploit', 'attack',
    ];
    
    final lowerText = text.toLowerCase();
    return inappropriateWords.any((word) => lowerText.contains(word));
  }

  /// Check for spam patterns
  static bool _containsSpamPatterns(String text) {
    // Check for excessive repetition
    if (RegExp(r'(.)\1{4,}').hasMatch(text)) {
      return true;
    }
    
    // Check for excessive capitalization
    if (RegExp(r'[A-Z]{5,}').hasMatch(text)) {
      return true;
    }
    
    // Check for excessive punctuation
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]{3,}').hasMatch(text)) {
      return true;
    }
    
    return false;
  }

  /// Check for SQL injection patterns
  static bool _containsSqlInjectionPatterns(String query) {
    final sqlPatterns = [
      r'union\s+select',
      r'drop\s+table',
      r'delete\s+from',
      r'insert\s+into',
      r'update\s+set',
      r'exec\s*\(',
      r'script\s*>',
      r'<script',
      r'javascript:',
      r'vbscript:',
    ];
    
    final lowerQuery = query.toLowerCase();
    return sqlPatterns.any((pattern) => RegExp(pattern).hasMatch(lowerQuery));
  }

  /// Check for XSS patterns
  static bool _containsXssPatterns(String query) {
    final xssPatterns = [
      r'<script',
      r'javascript:',
      r'vbscript:',
      r'onload\s*=',
      r'onerror\s*=',
      r'onclick\s*=',
      r'onmouseover\s*=',
      r'<iframe',
      r'<object',
      r'<embed',
    ];
    
    final lowerQuery = query.toLowerCase();
    return xssPatterns.any((pattern) => RegExp(pattern).hasMatch(lowerQuery));
  }

  /// Check if image has valid signature
  static bool _isValidImageSignature(List<int> imageData) {
    if (imageData.length < 4) return false;
    
    // Check for common image signatures
    final signatures = [
      [0xFF, 0xD8, 0xFF], // JPEG
      [0x89, 0x50, 0x4E, 0x47], // PNG
      [0x52, 0x49, 0x46, 0x46], // WebP (RIFF)
    ];
    
    for (final signature in signatures) {
      if (imageData.length >= signature.length) {
        bool matches = true;
        for (int i = 0; i < signature.length; i++) {
          if (imageData[i] != signature[i]) {
            matches = false;
            break;
          }
        }
        if (matches) return true;
      }
    }
    
    return false;
  }
}

/// Validation result base class
abstract class ValidationResult {
  final List<String> errors = [];
  
  void addError(String error) {
    errors.add(error);
  }
  
  bool get isValid => errors.isEmpty;
  
  String get firstError => errors.isNotEmpty ? errors.first : '';
  
  String get allErrors => errors.join(', ');
}

/// Password validation result
class PasswordValidationResult extends ValidationResult {}

/// Name validation result
class NameValidationResult extends ValidationResult {}

/// Age validation result
class AgeValidationResult extends ValidationResult {}

/// Phone validation result
class PhoneValidationResult extends ValidationResult {}

/// Bio validation result
class BioValidationResult extends ValidationResult {}

/// Location validation result
class LocationValidationResult extends ValidationResult {}

/// Interests validation result
class InterestsValidationResult extends ValidationResult {}

/// Image validation result
class ImageValidationResult extends ValidationResult {}

/// Message validation result
class MessageValidationResult extends ValidationResult {}

/// Report validation result
class ReportValidationResult extends ValidationResult {}

/// Search validation result
class SearchValidationResult extends ValidationResult {}

/// URL validation result
class UrlValidationResult extends ValidationResult {}
