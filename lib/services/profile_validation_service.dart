import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/haptic_feedback_service.dart';

class ProfileValidationService {
  static final ProfileValidationService _instance = ProfileValidationService._internal();
  factory ProfileValidationService() => _instance;
  ProfileValidationService._internal();

  ValidationResult validateProfile(Map<String, dynamic> profileData) {
    final errors = <String>[];
    final warnings = <String>[];
    int score = 0;
    int maxScore = 100;

    // Basic Information (30 points)
    final basicScore = _validateBasicInfo(profileData, errors, warnings);
    score += basicScore;

    // Personal Details (25 points)
    final personalScore = _validatePersonalDetails(profileData, errors, warnings);
    score += personalScore;

    // Profile Quality (25 points)
    final qualityScore = _validateProfileQuality(profileData, errors, warnings);
    score += qualityScore;

    // Photos (20 points)
    final photoScore = _validatePhotos(profileData, errors, warnings);
    score += photoScore;

    return ValidationResult(
      score: score,
      maxScore: maxScore,
      percentage: (score / maxScore * 100).round(),
      errors: errors,
      warnings: warnings,
      isComplete: errors.isEmpty,
      quality: _getQualityLevel(score),
    );
  }

  int _validateBasicInfo(Map<String, dynamic> profileData, List<String> errors, List<String> warnings) {
    int score = 0;

    // Name validation (10 points)
    final name = profileData['name']?.toString().trim();
    if (name == null || name.isEmpty) {
      errors.add('Name is required');
    } else if (name.length < 2) {
      errors.add('Name must be at least 2 characters long');
    } else if (name.length > 50) {
      warnings.add('Name is quite long');
    } else {
      score += 10;
    }

    // Age validation (10 points)
    final age = profileData['age'];
    if (age == null) {
      errors.add('Age is required');
    } else if (age < 18) {
      errors.add('You must be at least 18 years old');
    } else if (age > 100) {
      errors.add('Please enter a valid age');
    } else {
      score += 10;
    }

    // Bio validation (10 points)
    final bio = profileData['bio']?.toString().trim();
    if (bio == null || bio.isEmpty) {
      warnings.add('Add a bio to tell others about yourself');
    } else if (bio.length < 10) {
      warnings.add('Bio is too short. Add more details about yourself');
    } else if (bio.length > 500) {
      warnings.add('Bio is quite long');
    } else {
      score += 10;
    }

    return score;
  }

  int _validatePersonalDetails(Map<String, dynamic> profileData, List<String> errors, List<String> warnings) {
    int score = 0;

    // Gender validation (5 points)
    final gender = profileData['gender']?.toString().trim();
    if (gender == null || gender.isEmpty) {
      warnings.add('Gender information helps others understand you better');
    } else {
      score += 5;
    }

    // Orientation validation (5 points)
    final orientation = profileData['orientation']?.toString().trim();
    if (orientation == null || orientation.isEmpty) {
      warnings.add('Sexual orientation helps with better matching');
    } else {
      score += 5;
    }

    // Location validation (5 points)
    final location = profileData['location']?.toString().trim();
    if (location == null || location.isEmpty) {
      warnings.add('Location helps others find you nearby');
    } else {
      score += 5;
    }

    // Occupation validation (5 points)
    final occupation = profileData['occupation']?.toString().trim();
    if (occupation == null || occupation.isEmpty) {
      warnings.add('Occupation adds depth to your profile');
    } else {
      score += 5;
    }

    // Education validation (5 points)
    final education = profileData['education']?.toString().trim();
    if (education == null || education.isEmpty) {
      warnings.add('Education background is helpful');
    } else {
      score += 5;
    }

    return score;
  }

  int _validateProfileQuality(Map<String, dynamic> profileData, List<String> errors, List<String> warnings) {
    int score = 0;

    // Interests validation (15 points)
    final interests = profileData['interests'] as List<String>?;
    if (interests == null || interests.isEmpty) {
      warnings.add('Add interests to help others connect with you');
    } else if (interests.length < 3) {
      warnings.add('Add more interests to make your profile more attractive');
    } else if (interests.length > 10) {
      warnings.add('Too many interests might be overwhelming');
    } else {
      score += 15;
    }

    // Relationship status validation (5 points)
    final relationshipStatus = profileData['relationshipStatus']?.toString().trim();
    if (relationshipStatus == null || relationshipStatus.isEmpty) {
      warnings.add('Relationship status helps set expectations');
    } else {
      score += 5;
    }

    // Profile completeness bonus (5 points)
    final completedFields = _countCompletedFields(profileData);
    if (completedFields >= 8) {
      score += 5;
    }

    return score;
  }

  int _validatePhotos(Map<String, dynamic> profileData, List<String> errors, List<String> warnings) {
    int score = 0;

    // Profile photo validation (20 points)
    final profileImagePath = profileData['profileImagePath'];
    final profileImageUrl = profileData['profileImageUrl'];
    
    if ((profileImagePath == null || profileImagePath.isEmpty) && 
        (profileImageUrl == null || profileImageUrl.isEmpty)) {
      errors.add('Profile photo is required');
    } else {
      score += 20;
    }

    return score;
  }

  int _countCompletedFields(Map<String, dynamic> profileData) {
    int count = 0;
    final fields = [
      'name', 'age', 'bio', 'gender', 'orientation', 'location',
      'occupation', 'education', 'relationshipStatus', 'interests'
    ];

    for (final field in fields) {
      final value = profileData[field];
      if (value != null) {
        if (value is String && value.trim().isNotEmpty) {
          count++;
        } else if (value is List && value.isNotEmpty) {
          count++;
        } else if (value is int && value > 0) {
          count++;
        }
      }
    }

    return count;
  }

  ProfileQuality _getQualityLevel(int score) {
    if (score >= 90) return ProfileQuality.excellent;
    if (score >= 75) return ProfileQuality.good;
    if (score >= 60) return ProfileQuality.fair;
    if (score >= 40) return ProfileQuality.poor;
    return ProfileQuality.incomplete;
  }
}

class ValidationResult {
  final int score;
  final int maxScore;
  final int percentage;
  final List<String> errors;
  final List<String> warnings;
  final bool isComplete;
  final ProfileQuality quality;

  const ValidationResult({
    required this.score,
    required this.maxScore,
    required this.percentage,
    required this.errors,
    required this.warnings,
    required this.isComplete,
    required this.quality,
  });
}

enum ProfileQuality {
  incomplete,
  poor,
  fair,
  good,
  excellent,
}

class ProfileValidationWidget extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final VoidCallback? onComplete;
  final VoidCallback? onImprove;

  const ProfileValidationWidget({
    Key? key,
    required this.profileData,
    this.onComplete,
    this.onImprove,
  }) : super(key: key);

  @override
  State<ProfileValidationWidget> createState() => _ProfileValidationWidgetState();
}

class _ProfileValidationWidgetState extends State<ProfileValidationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  ValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _validateProfile();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  void _validateProfile() {
    final result = ProfileValidationService().validateProfile(widget.profileData);
    setState(() {
      _validationResult = result;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_validationResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navbarBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildScoreSection(),
                  const SizedBox(height: 20),
                  _buildIssuesSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.analytics,
          color: _getQualityColor(_validationResult!.quality),
          size: 28,
        ),
        const SizedBox(width: 12),
        const Text(
          'Profile Validation',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getQualityColor(_validationResult!.quality).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getQualityColor(_validationResult!.quality).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '${_validationResult!.percentage}%',
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: _getQualityColor(_validationResult!.quality),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getQualityText(_validationResult!.quality),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: _getQualityColor(_validationResult!.quality),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_validationResult!.score}/${_validationResult!.maxScore} points',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _validationResult!.percentage / 100,
            backgroundColor: AppColors.surfaceSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getQualityColor(_validationResult!.quality),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Issues to Fix',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 12),
        if (_validationResult!.errors.isNotEmpty) ...[
          _buildIssueList(_validationResult!.errors, true),
          const SizedBox(height: 12),
        ],
        if (_validationResult!.warnings.isNotEmpty)
          _buildIssueList(_validationResult!.warnings, false),
      ],
    );
  }

  Widget _buildIssueList(List<String> issues, bool isError) {
    return Column(
      children: issues.map((issue) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isError 
                ? AppColors.feedbackError.withOpacity(0.1)
                : AppColors.feedbackWarning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isError 
                  ? AppColors.feedbackError.withOpacity(0.3)
                  : AppColors.feedbackWarning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error : Icons.warning,
                color: isError ? AppColors.feedbackError : AppColors.feedbackWarning,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  issue,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isError ? AppColors.feedbackError : AppColors.feedbackWarning,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedbackService.selection();
              widget.onImprove?.call();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.borderDefault),
              foregroundColor: AppColors.textPrimaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Improve Profile'),
          ),
        ),
        if (_validationResult!.isComplete) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                HapticFeedbackService.success();
                widget.onComplete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.feedbackSuccess,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Complete'),
            ),
          ),
        ],
      ],
    );
  }

  Color _getQualityColor(ProfileQuality quality) {
    switch (quality) {
      case ProfileQuality.excellent:
        return AppColors.feedbackSuccess;
      case ProfileQuality.good:
        return AppColors.primaryLight;
      case ProfileQuality.fair:
        return AppColors.feedbackWarning;
      case ProfileQuality.poor:
        return AppColors.prideOrange;
      case ProfileQuality.incomplete:
        return AppColors.feedbackError;
    }
  }

  String _getQualityText(ProfileQuality quality) {
    switch (quality) {
      case ProfileQuality.excellent:
        return 'Excellent Profile!';
      case ProfileQuality.good:
        return 'Good Profile';
      case ProfileQuality.fair:
        return 'Fair Profile';
      case ProfileQuality.poor:
        return 'Needs Improvement';
      case ProfileQuality.incomplete:
        return 'Incomplete Profile';
    }
  }
}

class ProfileCompletionCard extends StatelessWidget {
  final ValidationResult validationResult;
  final VoidCallback? onTap;

  const ProfileCompletionCard({
    Key? key,
    required this.validationResult,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getQualityColor(validationResult.quality).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getQualityColor(validationResult.quality).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${validationResult.percentage}%',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getQualityColor(validationResult.quality),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Completion',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getQualityText(validationResult.quality),
                    style: AppTypography.bodyMedium.copyWith(
                      color: _getQualityColor(validationResult.quality),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: validationResult.percentage / 100,
                    backgroundColor: AppColors.surfaceSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getQualityColor(validationResult.quality),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondaryDark,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getQualityColor(ProfileQuality quality) {
    switch (quality) {
      case ProfileQuality.excellent:
        return AppColors.feedbackSuccess;
      case ProfileQuality.good:
        return AppColors.primaryLight;
      case ProfileQuality.fair:
        return AppColors.feedbackWarning;
      case ProfileQuality.poor:
        return AppColors.prideOrange;
      case ProfileQuality.incomplete:
        return AppColors.feedbackError;
    }
  }

  String _getQualityText(ProfileQuality quality) {
    switch (quality) {
      case ProfileQuality.excellent:
        return 'Excellent Profile!';
      case ProfileQuality.good:
        return 'Good Profile';
      case ProfileQuality.fair:
        return 'Fair Profile';
      case ProfileQuality.poor:
        return 'Needs Improvement';
      case ProfileQuality.incomplete:
        return 'Incomplete Profile';
    }
  }
}
