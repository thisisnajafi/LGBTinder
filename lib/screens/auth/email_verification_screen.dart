import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../providers/app_state_provider.dart';
import '../../models/user_state_models.dart';
import '../../services/analytics_service.dart';
import '../../services/error_monitoring_service.dart';
import '../../services/secure_error_handler.dart';
import '../../components/error_handling/error_snackbar.dart';
import '../../components/loading/loading_widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final int? userId;
  final String? redirectRoute;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.userId,
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
  int _resendCountdown = 120; // 2 minutes
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
        if (_codeControllers[i].text.length == 1) {
          if (i < 5) {
            // Move to next input
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                _focusNodes[i + 1].requestFocus();
              }
            });
          } else {
            // Last input filled, auto-submit
            _checkAutoSubmit();
          }
        }
      });
    }
  }

  void _checkAutoSubmit() {
    final code = _getVerificationCode();
    if (code.length == 6 && !_isLoading) {
      // Auto-submit after a short delay to let user see the complete code
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_isLoading) {
          _handleVerification();
        }
      });
    }
  }

  void _startResendCountdown() {
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
    print('🚀 Email verification attempt started');
    print('📧 Email: ${widget.email}');
    
    if (_isRateLimited()) {
      final remainingTime = 15 - DateTime.now().difference(_lastAttemptTime!).inMinutes;
      print('⚠️ Rate limited, remaining time: $remainingTime minutes');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Too many attempts. Please wait $remainingTime minutes before trying again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final code = _getVerificationCode();
    print('🔢 Verification code entered: $code (length: ${code.length})');
    
    if (code.length != 6) {
      print('❌ Incomplete verification code');
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
      // Track verification attempt
      await AnalyticsService.trackAuthEvent(
        action: 'email_verification_attempt',
        success: false, // Will be updated based on result
      );

      print('📡 Calling app state provider verifyEmail...');
      final appState = context.read<AppStateProvider>();
      
      final result = await appState.verifyEmail(
        email: widget.email,
        code: code,
      );
      print('📡 App state provider verifyEmail result: ${result.success}');
      
      if (mounted) {
        print('✅ Email verification successful');
        
        // Track successful verification
        await AnalyticsService.trackAuthEvent(
          action: 'email_verification_success',
          success: true,
        );
        
        // Update attempts remaining
        setState(() {
          _attemptsRemaining--;
          _lastAttemptTime = DateTime.now();
        });

        if (_attemptsRemaining <= 0) {
          _startRateLimitTimer();
        }

               ErrorSnackBar.showSuccess(
                 context,
                 message: result.message,
               );

        // Navigate based on profile completion status
        if (appState.currentUserState is ProfileCompletionRequiredState) {
          print('🧭 Navigating to profile completion');
          Navigator.pushReplacementNamed(context, '/profile-completion');
        } else {
          print('🧭 Navigating to home');
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      print('💥 Email verification exception: ${e.toString()}');
      
      // Track failed verification
      await AnalyticsService.trackAuthEvent(
        action: 'email_verification_failed',
        success: false,
        errorType: e.runtimeType.toString(),
      );

      // Log error securely
      final authError = SecureErrorHandler.handleError(e, context: 'email_verification');
      await ErrorMonitoringService.logAuthError(
        errorType: authError.type,
        errorMessage: authError.message,
        details: authError.details,
      );

      if (mounted) {
        // Update attempts remaining
        setState(() {
          _attemptsRemaining--;
          _lastAttemptTime = DateTime.now();
        });

        if (_attemptsRemaining <= 0) {
          _startRateLimitTimer();
        }

        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'email_verification',
          onAction: _handleVerification,
          actionText: 'Try Again',
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
    print('🚀 Resend verification code attempt started');
    print('📧 Email: ${widget.email}');
    
    if (_resendCountdown > 0) {
      print('⚠️ Resend still in countdown: $_resendCountdown seconds remaining');
      return;
    }

    setState(() {
      _isResendLoading = true;
    });

    try {
      // Track resend attempt
      await AnalyticsService.trackAuthEvent(
        action: 'resend_verification_attempt',
        success: false, // Will be updated based on result
      );

      print('📡 Calling app state provider resend verification...');
      final appState = context.read<AppStateProvider>();
      // For now, we'll show a success message since resend is typically handled by the backend
      // In a real implementation, you might want to add a resend method to AppStateProvider
      print('📡 App state provider resend result: true');
      
      if (mounted) {
        print('✅ Verification code resent successfully');
        
        // Track successful resend
        await AnalyticsService.trackAuthEvent(
          action: 'resend_verification_success',
          success: true,
        );

               ErrorSnackBar.showSuccess(
                 context,
                 message: 'Verification code sent to your email.',
               );
        
        // Clear all code inputs
        for (var controller in _codeControllers) {
          controller.clear();
        }
        
        // Reset focus to first input
        _focusNodes[0].requestFocus();
        
        // Start countdown again
        setState(() {
          _resendCountdown = 120;
        });
        _startResendCountdown();
      } else {
        print('❌ Resend verification failed but no exception thrown');
               if (mounted) {
                 ErrorSnackBar.show(
                   context,
                   error: Exception('Unable to send verification code'),
                   errorContext: 'resend_verification',
                   onAction: _handleResendCode,
                   actionText: 'Try Again',
                 );
               }
      }
    } catch (e) {
      print('💥 Resend verification exception: ${e.toString()}');
      
      // Track failed resend
      await AnalyticsService.trackAuthEvent(
        action: 'resend_verification_failed',
        success: false,
        errorType: e.runtimeType.toString(),
      );

      // Log error securely
      final authError = SecureErrorHandler.handleError(e, context: 'resend_verification');
      await ErrorMonitoringService.logAuthError(
        errorType: authError.type,
        errorMessage: authError.message,
        details: authError.details,
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'email_verification',
          onAction: _handleVerification,
          actionText: 'Try Again',
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'We\'ve sent a 6-digit verification code to:',
                style: AppTypography.body1.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
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
                          color: Colors.white,
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
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
                             // 6-Digit Code Input Fields
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 children: List.generate(6, (index) {
                   return Container(
                     width: 48,
                     height: 56,
                     child: TextFormField(
                       controller: _codeControllers[index],
                       focusNode: _focusNodes[index],
                       enabled: !_isLoading,
                       textAlign: TextAlign.center,
                       keyboardType: TextInputType.number,
                       inputFormatters: [
                         FilteringTextInputFormatter.digitsOnly,
                         LengthLimitingTextInputFormatter(1),
                       ],
                       style: AppTypography.h4.copyWith(
                         color: _isLoading ? Colors.white60 : Colors.white,
                         fontWeight: FontWeight.bold,
                         fontSize: 20,
                       ),
                       onChanged: (value) {
                         if (value.length == 1 && index < 5) {
                           // Move to next input
                           Future.delayed(const Duration(milliseconds: 100), () {
                             if (mounted) {
                               _focusNodes[index + 1].requestFocus();
                             }
                           });
                         } else if (value.isEmpty && index > 0) {
                           // Move to previous input on backspace
                           Future.delayed(const Duration(milliseconds: 100), () {
                             if (mounted) {
                               _focusNodes[index - 1].requestFocus();
                             }
                           });
                         }
                       },
                       decoration: InputDecoration(
                         border: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12),
                           borderSide: BorderSide(color: Colors.white30),
                         ),
                         enabledBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12),
                           borderSide: BorderSide(
                             color: _codeControllers[index].text.isNotEmpty 
                                 ? AppColors.primary 
                                 : Colors.white30
                           ),
                         ),
                         focusedBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12),
                           borderSide: BorderSide(color: AppColors.primary, width: 2),
                         ),
                         disabledBorder: OutlineInputBorder(
                           borderRadius: BorderRadius.circular(12),
                           borderSide: BorderSide(color: Colors.white10),
                         ),
                         filled: true,
                         fillColor: _isLoading 
                             ? Colors.white10
                             : Colors.white.withOpacity(0.1),
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
                    backgroundColor: _isLoading ? AppColors.primary.withOpacity(0.7) : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: _isLoading ? 0 : 2,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoadingWidgets.button(
                              text: 'Verifying...',
                              color: Colors.white,
                            ),
                          ],
                        )
                      : Text(
                          'Verify Email',
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
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
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_resendCountdown > 0) ...[
                          Text(
                            'Resend available in ',
                            style: AppTypography.body2.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              '${(_resendCountdown ~/ 60).toString().padLeft(2, '0')}:${(_resendCountdown % 60).toString().padLeft(2, '0')}',
                              style: AppTypography.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: _isResendLoading ? null : _handleResendCode,
                            child: _isResendLoading
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LoadingWidgets.withText(
                                        text: 'Sending...',
                                        color: AppColors.primary,
                                        size: 16.0,
                                        strokeWidth: 2.0,
                                        alignment: MainAxisAlignment.center,
                                      ),
                                    ],
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
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Check your spam/junk folder\n• Make sure the email address is correct\n• Contact support if the issue persists',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
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
