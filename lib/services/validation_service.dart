import 'dart:io';

class ValidationService {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Password validation
  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[a-zA-Z\d!@#$%^&*(),.?":{}|<>&@]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  // Name validation
  static bool isValidName(String name) {
    // At least 2 characters, only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-Z\s]{2,}$');
    return nameRegex.hasMatch(name.trim());
  }

  // Phone number validation
  static bool isValidPhoneNumber(String phoneNumber) {
    // Basic phone number validation (digits, +, -, spaces, parentheses)
    final phoneRegex = RegExp(r'^[\+]?[1-9][\d]{0,15}$');
    return phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  // Age validation
  static bool isValidAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    final monthDiff = now.month - birthDate.month;
    final dayDiff = now.day - birthDate.day;

    if (monthDiff < 0 || (monthDiff == 0 && dayDiff < 0)) {
      return age - 1 >= 18;
    }
    return age >= 18;
  }

  // Height validation (in cm)
  static bool isValidHeight(int height) {
    return height >= 100 && height <= 250;
  }

  // Weight validation (in kg)
  static bool isValidWeight(int weight) {
    return weight >= 30 && weight <= 200;
  }

  // Age preference validation
  static bool isValidAgePreference(int minAge, int maxAge) {
    return minAge >= 18 && maxAge <= 100 && minAge <= maxAge;
  }

  // Bio validation
  static bool isValidBio(String bio) {
    return bio.trim().length >= 10 && bio.trim().length <= 500;
  }

  // File validation
  static bool isValidImageFile(File file) {
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final fileName = file.path.toLowerCase();
    return allowedExtensions.any((ext) => fileName.endsWith(ext));
  }

  // File size validation (in bytes)
  static bool isValidFileSize(File file, {int maxSizeInMB = 10}) {
    final fileSize = file.lengthSync();
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSize <= maxSizeInBytes;
  }

  // Message validation
  static bool isValidMessage(String message) {
    return message.trim().isNotEmpty && message.trim().length <= 1000;
  }

  // Country ID validation
  static bool isValidCountryId(int countryId) {
    return countryId > 0;
  }

  // City ID validation
  static bool isValidCityId(int cityId) {
    return cityId > 0;
  }

  // Gender ID validation
  static bool isValidGenderId(int genderId) {
    return genderId > 0;
  }

  // Reference data ID validation
  static bool isValidReferenceDataId(int id) {
    return id > 0;
  }

  // List validation
  static bool isValidReferenceDataList(List<int> ids) {
    return ids.isNotEmpty && ids.every((id) => id > 0);
  }

  // Device name validation
  static bool isValidDeviceName(String deviceName) {
    return deviceName.trim().isNotEmpty && deviceName.trim().length <= 100;
  }

  // URL validation
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Date validation
  static bool isValidDate(String dateString) {
    try {
      DateTime.parse(dateString);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Future date validation
  static bool isNotFutureDate(DateTime date) {
    return date.isBefore(DateTime.now()) || date.isAtSameMomentAs(DateTime.now());
  }

  // Past date validation (for birth dates)
  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Comprehensive validation for registration
  static ValidationResult validateRegistration({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? referralCode,
  }) {
    final errors = <String>[];

    if (!isValidName(firstName)) {
      errors.add('First name must be at least 2 characters and contain only letters');
    }

    if (!isValidName(lastName)) {
      errors.add('Last name must be at least 2 characters and contain only letters');
    }

    if (!isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    if (!isValidPassword(password)) {
      errors.add('Password must be at least 8 characters with uppercase, lowercase, number, and special character');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // Comprehensive validation for profile completion
  static ValidationResult validateProfileCompletion({
    required String deviceName,
    required int countryId,
    required int cityId,
    required int gender,
    required DateTime birthDate,
    required int minAgePreference,
    required int maxAgePreference,
    required String profileBio,
    required int height,
    required int weight,
    required List<int> musicGenres,
    required List<int> educations,
    required List<int> jobs,
    required List<int> languages,
    required List<int> interests,
    required List<int> preferredGenders,
    required List<int> relationGoals,
  }) {
    final errors = <String>[];

    if (!isValidDeviceName(deviceName)) {
      errors.add('Device name is required and must be less than 100 characters');
    }

    if (!isValidCountryId(countryId)) {
      errors.add('Please select a valid country');
    }

    if (!isValidCityId(cityId)) {
      errors.add('Please select a valid city');
    }

    if (!isValidGenderId(gender)) {
      errors.add('Please select a valid gender');
    }

    if (!isValidAge(birthDate)) {
      errors.add('You must be at least 18 years old');
    }

    if (!isValidAgePreference(minAgePreference, maxAgePreference)) {
      errors.add('Age preferences must be between 18-100 and min age must be less than or equal to max age');
    }

    if (!isValidBio(profileBio)) {
      errors.add('Bio must be between 10 and 500 characters');
    }

    if (!isValidHeight(height)) {
      errors.add('Height must be between 100-250 cm');
    }

    if (!isValidWeight(weight)) {
      errors.add('Weight must be between 30-200 kg');
    }

    if (!isValidReferenceDataList(musicGenres)) {
      errors.add('Please select at least one music genre');
    }

    if (!isValidReferenceDataList(educations)) {
      errors.add('Please select at least one education level');
    }

    if (!isValidReferenceDataList(jobs)) {
      errors.add('Please select at least one job');
    }

    if (!isValidReferenceDataList(languages)) {
      errors.add('Please select at least one language');
    }

    if (!isValidReferenceDataList(interests)) {
      errors.add('Please select at least one interest');
    }

    if (!isValidReferenceDataList(preferredGenders)) {
      errors.add('Please select at least one preferred gender');
    }

    if (!isValidReferenceDataList(relationGoals)) {
      errors.add('Please select at least one relationship goal');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // Comprehensive validation for profile update
  static ValidationResult validateProfileUpdate({
    String? profileBio,
    int? height,
    int? weight,
    int? minAgePreference,
    int? maxAgePreference,
  }) {
    final errors = <String>[];

    if (profileBio != null && !isValidBio(profileBio)) {
      errors.add('Bio must be between 10 and 500 characters');
    }

    if (height != null && !isValidHeight(height)) {
      errors.add('Height must be between 100-250 cm');
    }

    if (weight != null && !isValidWeight(weight)) {
      errors.add('Weight must be between 30-200 kg');
    }

    if (minAgePreference != null && maxAgePreference != null && 
        !isValidAgePreference(minAgePreference, maxAgePreference)) {
      errors.add('Age preferences must be between 18-100 and min age must be less than or equal to max age');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // Comprehensive validation for message sending
  static ValidationResult validateMessage({
    required String message,
    required int receiverId,
  }) {
    final errors = <String>[];

    if (!isValidMessage(message)) {
      errors.add('Message must not be empty and must be less than 1000 characters');
    }

    if (receiverId <= 0) {
      errors.add('Invalid receiver ID');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  // Comprehensive validation for file upload
  static ValidationResult validateFileUpload({
    required File file,
    int maxSizeInMB = 10,
  }) {
    final errors = <String>[];

    if (!isValidImageFile(file)) {
      errors.add('File must be a valid image (jpg, jpeg, png, gif, webp)');
    }

    if (!isValidFileSize(file, maxSizeInMB: maxSizeInMB)) {
      errors.add('File size must be less than ${maxSizeInMB}MB');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage {
    return errors.join('\n');
  }
}
