import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_verification_service.dart';
import '../../utils/haptic_feedback_service.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _codeFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isCodeSent = false;
  bool _isVerifying = false;
  String _selectedCountryCode = '+1';
  int _countdown = 0;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'US', 'flag': '🇺🇸'},
    {'code': '+1', 'country': 'CA', 'flag': '🇨🇦'},
    {'code': '+44', 'country': 'GB', 'flag': '🇬🇧'},
    {'code': '+61', 'country': 'AU', 'flag': '🇦🇺'},
    {'code': '+49', 'country': 'DE', 'flag': '🇩🇪'},
    {'code': '+33', 'country': 'FR', 'flag': '🇫🇷'},
    {'code': '+34', 'country': 'ES', 'flag': '🇪🇸'},
    {'code': '+39', 'country': 'IT', 'flag': '🇮🇹'},
    {'code': '+31', 'country': 'NL', 'flag': '🇳🇱'},
    {'code': '+46', 'country': 'SE', 'flag': '🇸🇪'},
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

  Future<void> _sendVerificationCode() async {
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Please enter your phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual SMS sending
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      setState(() {
        _isCodeSent = true;
        _countdown = 60;
      });
      
      _startCountdown();
      _showSuccessSnackBar('Verification code sent!');
      HapticFeedbackService.mediumImpact();
    } catch (e) {
      _showErrorSnackBar('Failed to send verification code: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      _showErrorSnackBar('Please enter the verification code');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // TODO: Implement actual code verification
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      _showSuccessSnackBar('Phone number verified successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Invalid verification code');
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  void _resendCode() {
    if (_countdown > 0) return;
    _sendVerificationCode();
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
        title: const Text('Phone Verification'),
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
                if (!_isCodeSent) _buildPhoneInputSection(),
                if (_isCodeSent) _buildCodeInputSection(),
                const SizedBox(height: 32),
                _buildActionButton(),
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
                Icons.phone_android,
                color: AppColors.primaryLight,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Verify Your Phone Number',
                style: AppTypography.headlineSmallStyle.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTypography.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isCodeSent 
                ? 'Enter the verification code sent to your phone number.'
                : 'Add your phone number to verify your identity and increase account security.',
            style: AppTypography.bodyMediumStyle.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: AppTypography.titleMediumStyle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  value: _selectedCountryCode,
                  style: AppTypography.bodyMediumStyle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  items: _countryCodes.map((Map<String, String> country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(country['flag']!),
                          const SizedBox(width: 8),
                          Text(country['code']!),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCountryCode = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  hintStyle: AppTypography.bodyMediumStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.borderLight.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.borderLight.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primaryLight,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
                style: AppTypography.bodyMediumStyle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCodeInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Code',
          style: AppTypography.titleMediumStyle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppTypography.semiBold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _codeController,
          focusNode: _codeFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textAlign: TextAlign.center,
          style: AppTypography.headlineMediumStyle.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppTypography.bold,
            letterSpacing: 8,
          ),
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: AppTypography.headlineMediumStyle.copyWith(
              color: AppColors.textSecondary.withOpacity(0.5),
              letterSpacing: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderLight.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderLight.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryLight,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Didn\'t receive the code? ',
              style: AppTypography.bodyMediumStyle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: _countdown > 0 ? null : _resendCode,
              child: Text(
                _countdown > 0 ? 'Resend in ${_countdown}s' : 'Resend Code',
                style: AppTypography.bodyMediumStyle.copyWith(
                  color: _countdown > 0 
                      ? AppColors.textSecondary 
                      : AppColors.primaryLight,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || _isVerifying ? null : (_isCodeSent ? _verifyCode : _sendVerificationCode),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading || _isVerifying
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
                    _isLoading ? 'Sending...' : 'Verifying...',
                    style: AppTypography.bodyLargeStyle.copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                ],
              )
            : Text(
                _isCodeSent ? 'Verify Code' : 'Send Verification Code',
                style: AppTypography.bodyLargeStyle.copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }
}
