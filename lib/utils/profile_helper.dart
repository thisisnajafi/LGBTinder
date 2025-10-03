import 'dart:io';
import 'dart:math';
import '../services/validation_service.dart';

/// Helper class for profile-related operations
class ProfileHelper {
  // Profile bio validation
  static bool isValidProfileBio(String? bio) {
    if (bio == null || bio.isEmpty) return true; // Optional field
    return ValidationService.isValidBio(bio);
  }

  static int getProfileBioCharacterCount(String? bio) {
    return bio?.length ?? 0;
  }

  static int getRemainingBioCharacters(String? bio, {int maxLength = 500}) {
    final currentLength = bio?.length ?? 0;
    return max(0, maxLength - currentLength);
  }

  static bool isProfileBioTooLong(String? bio, {int maxLength = 500}) {
    return (bio?.length ?? 0) > maxLength;
  }

  // Height validation
  static bool isValidHeight(int? height) {
    if (height == null) return true; // Optional field
    return ValidationService.isValidHeight(height);
  }

  static String formatHeight(int? height) {
    if (height == null) return 'Not specified';
    return '${height}cm';
  }

  // Weight validation
  static bool isValidWeight(int? weight) {
    if (weight == null) return true; // Optional field
    return ValidationService.isValidWeight(weight);
  }

  static String formatWeight(int? weight) {
    if (weight == null) return 'Not specified';
    return '${weight}kg';
  }

  // Age preference validation
  static bool isValidAgePreference(int? minAge, int? maxAge) {
    if (minAge == null || maxAge == null) return true; // Optional fields
    return ValidationService.isValidAgePreference(minAge, maxAge);
  }

  static String formatAgePreference(int? minAge, int? maxAge) {
    if (minAge == null || maxAge == null) return 'Not specified';
    return '$minAge - $maxAge years';
  }

  // Profile picture validation
  static bool isProfilePictureFileTooLarge(File file) {
    if (!file.existsSync()) return true; // File doesn't exist
    final fileSizeInMB = file.lengthSync() / (1024 * 1024);
    return fileSizeInMB > 5; // 5MB limit
  }

  static String getProfilePictureFileSizeErrorMessage(File file) {
    if (!file.existsSync()) return 'File does not exist';
    final fileSizeInMB = file.lengthSync() / (1024 * 1024);
    return 'File size (${fileSizeInMB.toStringAsFixed(1)}MB) exceeds the maximum allowed size of 5MB';
  }

  static String getProfilePictureFileExtension(File file) {
    final path = file.path.toLowerCase();
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'jpg';
    if (path.endsWith('.png')) return 'png';
    if (path.endsWith('.gif')) return 'gif';
    if (path.endsWith('.webp')) return 'webp';
    return 'unknown';
  }

  static String getProfilePictureFileExtensionErrorMessage(File file) {
    final extension = getProfilePictureFileExtension(file);
    return 'File extension $extension is not supported. Only jpg, jpeg, png, gif, and webp files are allowed';
  }

  // Lifestyle preferences
  static String getLifestyleString(bool? smoke, bool? drink, bool? gym) {
    final parts = <String>[];
    
    if (smoke != null) {
      parts.add('Smoking: ${smoke ? "Yes" : "No"}');
    }
    if (drink != null) {
      parts.add('Drinking: ${drink ? "Yes" : "No"}');
    }
    if (gym != null) {
      parts.add('Gym: ${gym ? "Yes" : "No"}');
    }
    
    return parts.isEmpty ? 'Not specified' : parts.join(', ');
  }
}
