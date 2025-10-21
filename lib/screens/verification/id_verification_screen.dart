import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_verification_service.dart';
import '../../utils/haptic_feedback_service.dart';

class IdVerificationScreen extends StatefulWidget {
  const IdVerificationScreen({Key? key}) : super(key: key);

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _frontImage;
  XFile? _backImage;
  bool _isUploading = false;
  String _selectedDocumentType = 'passport';
  String _selectedCountry = 'US';

  final List<String> _documentTypes = [
    'passport',
    'drivers_license',
    'national_id',
    'other'
  ];

  final List<String> _countries = [
    'US', 'CA', 'GB', 'AU', 'DE', 'FR', 'ES', 'IT', 'NL', 'SE'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _pickImage(ImageSource source, bool isFront) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isFront) {
            _frontImage = image;
          } else {
            _backImage = image;
          }
        });
        HapticFeedbackService.lightImpact();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _submitVerification() async {
    if (_frontImage == null) {
      _showErrorSnackBar('Please upload the front of your document');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // TODO: Implement actual verification submission
      await Future.delayed(const Duration(seconds: 2)); // Simulate upload
      
      _showSuccessSnackBar('Verification submitted successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to submit verification: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('ID Verification'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDocumentTypeSelector(),
                const SizedBox(height: 24),
                _buildCountrySelector(),
                const SizedBox(height: 24),
                _buildImageUploadSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            AppColors.secondaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: AppColors.primaryLight,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Verify Your Identity',
                style: AppTypography.headlineSmallStyle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTypography.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Upload a clear photo of your government-issued ID to verify your identity and increase trust in your profile.',
            style: AppTypography.bodyMediumStyle.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Type',
          style: AppTypography.titleMediumStyle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.borderLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDocumentType,
              isExpanded: true,
              style: AppTypography.bodyMediumStyle.copyWith(
                color: AppColors.textPrimary,
              ),
              items: _documentTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(_getDocumentTypeLabel(type)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDocumentType = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country of Issue',
          style: AppTypography.titleMediumStyle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.borderLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCountry,
              isExpanded: true,
              style: AppTypography.bodyMediumStyle.copyWith(
                color: AppColors.textPrimary,
              ),
              items: _countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCountry = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Documents',
          style: AppTypography.titleMediumStyle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildImageUploadCard(
                'Front of Document',
                _frontImage,
                true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageUploadCard(
                'Back of Document',
                _backImage,
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageUploadCard(String title, XFile? image, bool isFront) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTypography.bodyMediumStyle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTypography.medium,
            ),
          ),
          const SizedBox(height: 12),
          if (image != null)
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(image.path),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isFront) {
                            _frontImage = null;
                          } else {
                            _backImage = null;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () => _showImageSourceDialog(isFront),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.borderLight.withOpacity(0.5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to upload',
                      style: AppTypography.bodySmallStyle.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(bool isFront) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: AppTypography.titleMediumStyle.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppTypography.semiBold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera, isFront);
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery, isFront);
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _submitVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Submitting...',
                    style: AppTypography.bodyLargeStyle.copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ],
              )
            : Text(
                'Submit Verification',
                style: AppTypography.bodyLargeStyle.copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
      ),
    );
  }

  String _getDocumentTypeLabel(String type) {
    switch (type) {
      case 'passport':
        return 'Passport';
      case 'drivers_license':
        return 'Driver\'s License';
      case 'national_id':
        return 'National ID';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
