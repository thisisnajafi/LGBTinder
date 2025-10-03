import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/email_verification_service.dart';
import '../../utils/error_handler.dart';

class PasswordResetFlowScreen extends StatefulWidget {
  const PasswordResetFlowScreen({super.key});

  @override
  State<PasswordResetFlowScreen> createState() => _PasswordResetFlowScreenState();
}

class _PasswordResetFlowScreenState extends State<PasswordResetFlowScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isResendLoading = false;
  int _resendCountdown = 120; // 2 minutes
  Timer? _resendTimer;
  String? _resetToken;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _setupOtpInputs();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _setupOtpInputs() {
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 && i < 5) {
          _otpFocusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _startResendCountdown() {
    _resendCountdown = 120; // 2 minutes
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendPasswordResetOtp() async {
    if (_emailController.text.isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await EmailVerificationService.sendPasswordResetOtp(_emailController.text);
      
      if (response.status) {
        _userEmail = _emailController.text;
        _startResendCountdown();
        _showSuccessSnackBar(response.message);
        _nextStep();
      } else {
        _showErrorSnackBar(response.message);
      }
    } on ValidationException catch (e) {
      _showErrorSnackBar(e.message);
    } on RateLimitException catch (e) {
      _showErrorSnackBar('${e.message}. Please wait ${e.cooldownSeconds} seconds before trying again.');
    } on NetworkException catch (e) {
      _showErrorSnackBar('Network error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPasswordResetOtp() async {
    final otpCode = _getOtpCode();
    if (otpCode.length != 6) {
      _showErrorSnackBar('Please enter the complete 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await EmailVerificationService.verifyPasswordResetOtp(
        _userEmail!,
        otpCode,
      );
      
      if (response.status && response.data != null) {
        _resetToken = response.data!.resetToken;
        _showSuccessSnackBar(response.message);
        _nextStep();
      } else {
        _showErrorSnackBar(response.message);
      }
    } on ValidationException catch (e) {
      _showErrorSnackBar(e.message);
    } on AuthException catch (e) {
      _showErrorSnackBar(e.message);
    } on NetworkException catch (e) {
      _showErrorSnackBar('Network error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter a new password');
      return;
    }

    if (_passwordController.text.length < 8) {
      _showErrorSnackBar('Password must be at least 8 characters long');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await EmailVerificationService.resetPassword(
        email: _userEmail!,
        resetToken: _resetToken!,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );
      
      if (success) {
        _showSuccessSnackBar('Password reset successfully! You can now login with your new password.');
        Navigator.pop(context);
      } else {
        _showErrorSnackBar('Failed to reset password. Please try again.');
      }
    } on ValidationException catch (e) {
      _showErrorSnackBar(e.message);
    } on ApiException catch (e) {
      _showErrorSnackBar(e.message);
    } on NetworkException catch (e) {
      _showErrorSnackBar('Network error: ${e.message}');
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResendLoading = true;
    });

    try {
      final response = await EmailVerificationService.sendPasswordResetOtp(_userEmail!);
      
      if (response.status) {
        _startResendCountdown();
        _showSuccessSnackBar('OTP sent successfully!');
      } else {
        _showErrorSnackBar(response.message);
      }
    } on RateLimitException catch (e) {
      _showErrorSnackBar('${e.message}. Please wait ${e.cooldownSeconds} seconds before trying again.');
    } catch (e) {
      _showErrorSnackBar('Failed to resend OTP. Please try again.');
    } finally {
      setState(() {
        _isResendLoading = false;
      });
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reset Password',
          style: AppTypography.h6.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: index <= _currentStep ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEmailStep(),
                _buildOtpStep(),
                _buildPasswordStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your email address',
            style: AppTypography.h5.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll send you a verification code to reset your password.',
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendPasswordResetOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Send Verification Code',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter verification code',
            style: AppTypography.h5.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ve sent a 6-digit code to ${_userEmail ?? 'your email'}',
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                height: 55,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyPasswordResetOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Verify Code',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: TextButton(
              onPressed: _resendCountdown > 0 || _isResendLoading ? null : _resendOtp,
              child: _isResendLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _resendCountdown > 0
                          ? 'Resend code in ${_resendCountdown}s'
                          : 'Resend code',
                      style: AppTypography.body2.copyWith(
                        color: _resendCountdown > 0 ? AppColors.textSecondary : AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set new password',
            style: AppTypography.h5.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a strong password for your account.',
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'Enter new password',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm new password',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Reset Password',
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
