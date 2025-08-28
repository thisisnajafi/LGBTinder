import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_requests.dart';
import '../../utils/error_handler.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String? redirectRoute;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.redirectRoute,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResendLoading = false;
  int _resendCountdown = 0;
  int _attemptsRemaining = 3;
  DateTime? _lastAttemptTime;
  Timer? _resendTimer;
  Timer? _rateLimitTimer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
    _setupCodeInputs();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _rateLimitTimer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _setupCodeInputs() {
    for (int i = 0; i < 6; i++) {
      _codeControllers[i].addListener(() {
        if (_codeControllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60;
    });
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _startRateLimitTimer() {
    _rateLimitTimer = Timer(const Duration(minutes: 15), () {
      if (mounted) {
        setState(() {
          _attemptsRemaining = 3;
          _lastAttemptTime = null;
        });
      }
    });
  }

  String _getVerificationCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  bool _isRateLimited() {
    if (_attemptsRemaining <= 0) {
      if (_lastAttemptTime != null) {
        final timeSinceLastAttempt = DateTime.now().difference(_lastAttemptTime!);
        if (timeSinceLastAttempt.inMinutes < 15) {
          return true;
        } else {
          // Reset rate limit after 15 minutes
          setState(() {
            _attemptsRemaining = 3;
            _lastAttemptTime = null;
          });
          _rateLimitTimer?.cancel();
        }
      }
    }
    return false;
  }

  Future<void> _handleVerification() async {
    if (_isRateLimited()) {
      final remainingTime = 15 - DateTime.now().difference(_lastAttemptTime!).inMinutes;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Too many attempts. Please wait $remainingTime minutes before trying again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final code = _getVerificationCode();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit verification code.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final request = VerificationRequest(
        email: widget.email,
        code: code,
      );

      final success = await authProvider.verifyCode(request);
      
      if (success && mounted) {
        // Update attempts remaining
        setState(() {
          _attemptsRemaining--;
          _lastAttemptTime = DateTime.now();
        });

        if (_attemptsRemaining <= 0) {
          _startRateLimitTimer();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to next screen or back
        if (widget.redirectRoute != null) {
          Navigator.pushReplacementNamed(context, widget.redirectRoute!);
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        // Update attempts remaining
        setState(() {
          _attemptsRemaining--;
          _lastAttemptTime = DateTime.now();
        });

        if (_attemptsRemaining <= 0) {
          _startRateLimitTimer();
        }

        String errorMessage = 'Verification failed';
        if (e is ValidationException) {
          errorMessage = e.message;
        } else if (e is AuthException) {
          errorMessage = e.message;
        } else if (e is RateLimitException) {
          errorMessage = 'Too many attempts. Please wait before trying again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

  Future<void> _handleResendCode() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResendLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendVerification(widget.email);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email.'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Clear previous code inputs
        for (var controller in _codeControllers) {
          controller.clear();
        }
        
        // Reset focus to first input
        _focusNodes[0].requestFocus();
        
        // Start countdown again
        _startResendCountdown();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to resend verification code';
        if (e is ValidationException) {
          errorMessage = e.message;
        } else if (e is AuthException) {
          errorMessage = e.message;
        } else if (e is RateLimitException) {
          errorMessage = 'Too many resend attempts. Please wait before trying again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResendLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navbarBackground,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Header
              Text(
                'Verify Your Email',
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'We\'ve sent a 6-digit verification code to:',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.navbarBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.greyMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.email,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Verification Code Input
              Text(
                'Enter Verification Code',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
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
                        filled: true,
                        fillColor: AppColors.navbarBackground,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              
              // Rate Limit Info
              if (_attemptsRemaining < 3) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Attempts remaining: $_attemptsRemaining',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || _isRateLimited() ? null : _handleVerification,
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
                          'Verify Email',
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Resend Code Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'Didn\'t receive the code?',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    if (_resendCountdown > 0) ...[
                      Text(
                        'Resend available in $_resendCountdown seconds',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: _isResendLoading ? null : _handleResendCode,
                        child: _isResendLoading
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : Text(
                                'Resend Code',
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Help Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.navbarBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.greyMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Need Help?',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your spam/junk folder\n• Make sure the email address is correct\n• Contact support if the issue persists',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
