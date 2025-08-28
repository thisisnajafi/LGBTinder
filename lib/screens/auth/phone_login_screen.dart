import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_requests.dart';
import '../../utils/validation.dart';
import 'otp_verification_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  String _selectedCountryCode = '+1'; // Default to US
  bool _isLoading = false;
  bool _isPhoneValid = false;
  
  // Common country codes
  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'name': 'US/Canada', 'flag': '🇺🇸'},
    {'code': '+44', 'name': 'UK', 'flag': '🇬🇧'},
    {'code': '+33', 'name': 'France', 'flag': '🇫🇷'},
    {'code': '+49', 'name': 'Germany', 'flag': '🇩🇪'},
    {'code': '+39', 'name': 'Italy', 'flag': '🇮🇹'},
    {'code': '+34', 'name': 'Spain', 'flag': '🇪🇸'},
    {'code': '+31', 'name': 'Netherlands', 'flag': '🇳🇱'},
    {'code': '+46', 'name': 'Sweden', 'flag': '🇸🇪'},
    {'code': '+47', 'name': 'Norway', 'flag': '🇳🇴'},
    {'code': '+45', 'name': 'Denmark', 'flag': '🇩🇰'},
    {'code': '+358', 'name': 'Finland', 'flag': '🇫🇮'},
    {'code': '+48', 'name': 'Poland', 'flag': '🇵🇱'},
    {'code': '+420', 'name': 'Czech Republic', 'flag': '🇨🇿'},
    {'code': '+36', 'name': 'Hungary', 'flag': '🇭🇺'},
    {'code': '+43', 'name': 'Austria', 'flag': '🇦🇹'},
    {'code': '+41', 'name': 'Switzerland', 'flag': '🇨🇭'},
    {'code': '+32', 'name': 'Belgium', 'flag': '🇧🇪'},
    {'code': '+351', 'name': 'Portugal', 'flag': '🇵🇹'},
    {'code': '+30', 'name': 'Greece', 'flag': '🇬🇷'},
    {'code': '+90', 'name': 'Turkey', 'flag': '🇹🇷'},
    {'code': '+7', 'name': 'Russia', 'flag': '🇷🇺'},
    {'code': '+380', 'name': 'Ukraine', 'flag': '🇺🇦'},
    {'code': '+48', 'name': 'Poland', 'flag': '🇵🇱'},
    {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
    {'code': '+81', 'name': 'Japan', 'flag': '🇯🇵'},
    {'code': '+82', 'name': 'South Korea', 'flag': '🇰🇷'},
    {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': '+64', 'name': 'New Zealand', 'flag': '🇳🇿'},
    {'code': '+27', 'name': 'South Africa', 'flag': '🇿🇦'},
    {'code': '+55', 'name': 'Brazil', 'flag': '🇧🇷'},
    {'code': '+54', 'name': 'Argentina', 'flag': '🇦🇷'},
    {'code': '+52', 'name': 'Mexico', 'flag': '🇲🇽'},
    {'code': '+57', 'name': 'Colombia', 'flag': '🇨🇴'},
    {'code': '+58', 'name': 'Venezuela', 'flag': '🇻🇪'},
    {'code': '+51', 'name': 'Peru', 'flag': '🇵🇪'},
    {'code': '+56', 'name': 'Chile', 'flag': '🇨🇱'},
    {'code': '+593', 'name': 'Ecuador', 'flag': '🇪🇨'},
    {'code': '+595', 'name': 'Paraguay', 'flag': '🇵🇾'},
    {'code': '+598', 'name': 'Uruguay', 'flag': '🇺🇾'},
    {'code': '+591', 'name': 'Bolivia', 'flag': '🇧🇴'},
    {'code': '+503', 'name': 'El Salvador', 'flag': '🇸🇻'},
    {'code': '+504', 'name': 'Honduras', 'flag': '🇭🇳'},
    {'code': '+502', 'name': 'Guatemala', 'flag': '🇬🇹'},
    {'code': '+505', 'name': 'Nicaragua', 'flag': '🇳🇮'},
    {'code': '+506', 'name': 'Costa Rica', 'flag': '🇨🇷'},
    {'code': '+507', 'name': 'Panama', 'flag': '🇵🇦'},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = ValidationUtils.isValidPhone(_phoneController.text);
    });
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final request = PhoneLoginRequest(
        phoneNumber: _phoneController.text.trim(),
        countryCode: _selectedCountryCode,
      );

      final success = await authProvider.sendOtp(request);
      
      if (success && mounted) {
        // Navigate to OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: _phoneController.text.trim(),
              countryCode: _selectedCountryCode,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send OTP: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header
                Text(
                  'Phone Login',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Enter your phone number to receive a verification code',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Country Code Selection
                Text(
                  'Country Code',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.greyMedium),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.navbarBackground,
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCountryCode,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _countryCodes.map((country) {
                      return DropdownMenuItem<String>(
                        value: country['code'],
                        child: Row(
                          children: [
                            Text(country['flag']!),
                            const SizedBox(width: 12),
                            Text(
                              '${country['code']} ${country['name']}',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCountryCode = value;
                        });
                      }
                    },
                    dropdownColor: AppColors.navbarBackground,
                    icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Phone Number Field
                Text(
                  'Phone Number',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _isPhoneValid
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.greyMedium),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.greyMedium),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                    filled: true,
                    fillColor: AppColors.navbarBackground,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!ValidationUtils.isValidPhone(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Send Verification Code',
                            style: AppTypography.button.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Info Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'We\'ll send a 6-digit verification code to your phone number. Standard message rates may apply.',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Back to Email Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Prefer email login? ',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Go back',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
