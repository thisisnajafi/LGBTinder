

class ValidationUtils {
  // Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$',
  );

  // Phone number validation regex (international format)
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[1-9]\d{1,14}$',
  );

  // Name validation regex (letters, spaces, hyphens, apostrophes)
  static final RegExp _nameRegex = RegExp(
    r'^[a-zA-Z\s\-]+$',
  );

  // URL validation regex (simplified)
  static final RegExp _urlRegex = RegExp(
    r'^https?://.*',
  );

  /// Validates if a field is required and not empty
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates character limit
  static String? validateCharacterLimit(String? value, int maxLength, String fieldName) {
    if (value == null) return null;
    if (value.length > maxLength) {
      return '$fieldName must be $maxLength characters or less';
    }
    return null;
  }

  /// Validates minimum character limit
  static String? validateMinCharacterLimit(String? value, int minLength, String fieldName) {
    if (value == null) return null;
    if (value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates age (must be 18 or older)
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 'Birth date is required';
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;
    
    if (age < 18) {
      return 'You must be at least 18 years old';
    }
    
    if (age > 100) {
      return 'Please enter a valid birth date';
    }

    return null;
  }

  /// Validates email format
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates phone number format
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // Phone is optional
    }

    // Remove all non-digit characters except +
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (!_phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates name format
  static String? validateName(String? name, String fieldName) {
    if (name == null || name.trim().isEmpty) {
      return '$fieldName is required';
    }

    if (!_nameRegex.hasMatch(name.trim())) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    if (name.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }

    return null;
  }

  /// Validates URL format
  static String? validateUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return null; // URL is optional
    }

    if (!_urlRegex.hasMatch(url.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates bio content (no inappropriate content)
  static String? validateBio(String? bio) {
    if (bio == null) return null;
    
    // Check for minimum length
    if (bio.trim().length < 10) {
      return 'Bio must be at least 10 characters';
    }

    // Check for maximum length
    if (bio.length > 500) {
      return 'Bio must be 500 characters or less';
    }

    // Check for inappropriate content (basic check)
    final inappropriateWords = [
      'spam', 'scam', 'fake', 'bot', 'automated',
      // Add more inappropriate words as needed
    ];

    final lowerBio = bio.toLowerCase();
    for (final word in inappropriateWords) {
      if (lowerBio.contains(word)) {
        return 'Bio contains inappropriate content';
      }
    }

    return null;
  }

  /// Validates location format
  static String? validateLocation(String? location) {
    if (location == null || location.trim().isEmpty) {
      return null; // Location is optional
    }

    if (location.trim().length < 2) {
      return 'Location must be at least 2 characters';
    }

    if (location.length > 100) {
      return 'Location must be 100 characters or less';
    }

    return null;
  }

  /// Validates job title
  static String? validateJobTitle(String? jobTitle) {
    if (jobTitle == null || jobTitle.trim().isEmpty) {
      return null; // Job title is optional
    }

    if (jobTitle.trim().length < 2) {
      return 'Job title must be at least 2 characters';
    }

    if (jobTitle.length > 100) {
      return 'Job title must be 100 characters or less';
    }

    return null;
  }

  /// Validates company name
  static String? validateCompany(String? company) {
    if (company == null || company.trim().isEmpty) {
      return null; // Company is optional
    }

    if (company.trim().length < 2) {
      return 'Company name must be at least 2 characters';
    }

    if (company.length > 100) {
      return 'Company name must be 100 characters or less';
    }

    return null;
  }

  /// Validates email format and returns boolean
  static bool isValidEmail(String email) {
    if (email.trim().isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validates password strength and returns boolean
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    
    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    
    // Check for at least one number
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    
    return true;
  }

  /// Validates phone number format and returns boolean
  static bool isValidPhone(String phone) {
    if (phone.trim().isEmpty) return false;
    
    // Remove all non-digit characters except +
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return _phoneRegex.hasMatch(cleanPhone);
  }

  /// Validates school name
  static String? validateSchool(String? school) {
    if (school == null || school.trim().isEmpty) {
      return null; // School is optional
    }

    if (school.trim().length < 2) {
      return 'School name must be at least 2 characters';
    }

    if (school.length > 100) {
      return 'School name must be 100 characters or less';
    }

    return null;
  }

  /// Validates age range preferences
  static String? validateAgeRange(int? minAge, int? maxAge) {
    if (minAge == null || maxAge == null) {
      return 'Age range is required';
    }

    if (minAge < 18) {
      return 'Minimum age must be at least 18';
    }

    if (maxAge > 100) {
      return 'Maximum age must be 100 or less';
    }

    if (minAge >= maxAge) {
      return 'Minimum age must be less than maximum age';
    }

    return null;
  }

  /// Validates distance range
  static String? validateDistanceRange(double? maxDistance) {
    if (maxDistance == null) {
      return 'Distance range is required';
    }

    if (maxDistance < 1) {
      return 'Distance must be at least 1 km';
    }

    if (maxDistance > 500) {
      return 'Distance must be 500 km or less';
    }

    return null;
  }

  /// Validates photo count
  static String? validatePhotoCount(List<dynamic>? photos, {int minCount = 1, int maxCount = 6}) {
    if (photos == null) {
      return 'At least $minCount photo is required';
    }

    if (photos.length < minCount) {
      return 'At least $minCount photo${minCount > 1 ? 's' : ''} is required';
    }

    if (photos.length > maxCount) {
      return 'Maximum $maxCount photos allowed';
    }

    return null;
  }

  /// Validates gender selection
  static String? validateGender(String? gender) {
    if (gender == null || gender.trim().isEmpty) {
      return 'Gender is required';
    }

    return null;
  }

  /// Validates interested in selection
  static String? validateInterestedIn(List<dynamic>? interestedIn) {
    if (interestedIn == null || interestedIn.isEmpty) {
      return 'Please select who you are interested in';
    }

    return null;
  }

  /// Validates relationship goal
  static String? validateRelationshipGoal(dynamic relationshipGoal) {
    if (relationshipGoal == null) {
      return null; // Relationship goal is optional
    }

    return null;
  }

  /// Comprehensive profile validation
  static Map<String, String?> validateProfile({
    String? name,
    DateTime? birthDate,
    String? gender,
    String? location,
    String? bio,
    String? jobTitle,
    String? company,
    String? school,
    List<dynamic>? photos,
    List<dynamic>? interestedIn,
    int? minAge,
    int? maxAge,
    double? maxDistance,
  }) {
    final errors = <String, String?>{};

    // Required fields
    errors['name'] = validateName(name, 'Name');
    errors['birthDate'] = validateAge(birthDate);
    errors['gender'] = validateGender(gender);
    errors['interestedIn'] = validateInterestedIn(interestedIn);
    errors['photos'] = validatePhotoCount(photos);

    // Optional fields
    errors['location'] = validateLocation(location);
    errors['bio'] = validateBio(bio);
    errors['jobTitle'] = validateJobTitle(jobTitle);
    errors['company'] = validateCompany(company);
    errors['school'] = validateSchool(school);

    // Preferences
    errors['ageRange'] = validateAgeRange(minAge, maxAge);
    errors['distance'] = validateDistanceRange(maxDistance);

    // Remove null values
    errors.removeWhere((key, value) => value == null);

    return errors;
  }

  /// Validates form field with multiple validators
  static String? validateField({
    required String? value,
    required String fieldName,
    bool isRequired = false,
    int? maxLength,
    int? minLength,
    String? Function(String?)? customValidator,
  }) {
    // Required validation
    if (isRequired) {
      final requiredError = validateRequired(value, fieldName);
      if (requiredError != null) return requiredError;
    }

    // Skip other validations if value is empty and not required
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Min length validation
    if (minLength != null) {
      final minLengthError = validateMinCharacterLimit(value, minLength, fieldName);
      if (minLengthError != null) return minLengthError;
    }

    // Max length validation
    if (maxLength != null) {
      final maxLengthError = validateCharacterLimit(value, maxLength, fieldName);
      if (maxLengthError != null) return maxLengthError;
    }

    // Custom validation
    if (customValidator != null) {
      final customError = customValidator(value);
      if (customError != null) return customError;
    }

    return null;
  }

  /// Sanitizes input text
  static String sanitizeText(String? text) {
    if (text == null) return '';
    
    return text
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .replaceAll(RegExp(r'[<>]'), ''); // Remove potential HTML tags
  }

  /// Formats phone number for display
  static String formatPhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) return '';
    
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    
    return phone;
  }

  /// Formats age for display
  static String formatAge(DateTime? birthDate) {
    if (birthDate == null) return '';
    
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age.toString();
  }
}
