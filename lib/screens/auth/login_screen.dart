import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../models/user_state_models.dart';
import '../../models/api_models/auth_models.dart';
import '../../services/validation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/error_monitoring_service.dart';
import '../../services/api_services/login_password_api_service.dart';
import '../../services/token_management_service.dart';
import '../../components/animations/animated_components.dart';
import '../../components/error_handling/error_snackbar.dart';
import '../../components/loading/loading_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      _isEmailValid = ValidationService.isValidEmail(_emailController.text.trim());
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 8;
    });
  }

  Future<void> _handleGoogleLogin() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      appState.setLoading(true);
      
      await AnalyticsService.trackAuthEvent(
        action: 'google_login_attempt',
        success: false,
      );
      
      final result = await authProvider.loginWithGoogle();
      
      if (result == null) {
        // User cancelled
        return;
      }
      
      if (result['success'] == true) {
        await AnalyticsService.trackAuthEvent(
          action: 'google_login_success',
          success: true,
        );
        
        if (mounted) {
          if (result['needs_profile_completion'] == true) {
            Navigator.pushReplacementNamed(context, '/profile-wizard');
            ErrorSnackBar.showSuccess(
              context,
              message: 'Welcome! Please complete your profile.',
            );
          } else {
            Navigator.pushReplacementNamed(context, '/home');
            ErrorSnackBar.showSuccess(
              context,
              message: 'Welcome back!',
            );
          }
        }
      } else {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            error: Exception(result['error'] ?? 'Google Sign-In failed'),
            errorContext: 'google_login',
          );
        }
      }
    } catch (e) {
      await AnalyticsService.trackAuthEvent(
        action: 'google_login_failed',
        success: false,
        errorType: 'exception',
      );
      
      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'google_login',
        );
      }
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> _handleFacebookLogin() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      appState.setLoading(true);
      
      await AnalyticsService.trackAuthEvent(
        action: 'facebook_login_attempt',
        success: false,
      );
      
      final result = await authProvider.loginWithFacebook();
      
      if (result == null) {
        // User cancelled
        return;
      }
      
      if (result['success'] == true) {
        await AnalyticsService.trackAuthEvent(
          action: 'facebook_login_success',
          success: true,
        );
        
        if (mounted) {
          if (result['needs_profile_completion'] == true) {
            Navigator.pushReplacementNamed(context, '/profile-wizard');
            ErrorSnackBar.showSuccess(
              context,
              message: 'Welcome! Please complete your profile.',
            );
          } else {
            Navigator.pushReplacementNamed(context, '/home');
            ErrorSnackBar.showSuccess(
              context,
              message: 'Welcome back!',
            );
          }
        }
      } else {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            error: Exception(result['error'] ?? 'Facebook Sign-In failed'),
            errorContext: 'facebook_login',
          );
        }
      }
    } catch (e) {
      await AnalyticsService.trackAuthEvent(
        action: 'facebook_login_failed',
        success: false,
        errorType: 'exception',
      );
      
      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'facebook_login',
        );
      }
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> _handleAppleLogin() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      appState.setLoading(true);
      
      await AnalyticsService.trackAuthEvent(
        action: 'apple_login_attempt',
        success: false,
      );
      
      final result = await authProvider.loginWithApple();
      
      if (result == null) {
        // User cancelled
        return;
      }
      
      if (result['success'] == true) {
        await AnalyticsService.trackAuthEvent(
          action: 'apple_login_success',
          success: true,
        );
        
        if (mounted) {
          if (result['needs_profile_completion'] == true) {
            Navigator.pushReplacementNamed(context, '/profile-wizard');
            ErrorSnackBar.showSuccess(
              context,
              message: 'Welcome! Please complete your profile.',
            );
          } else {
            Navigator.pushReplacementNamed(context, '/home');
            ErrorSnackBar.showSuccess(
              context,
              message: 'Welcome back!',
            );
          }
        }
      } else {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            error: Exception(result['error'] ?? 'Apple Sign-In failed'),
            errorContext: 'apple_login',
          );
        }
      }
    } catch (e) {
      await AnalyticsService.trackAuthEvent(
        action: 'apple_login_failed',
        success: false,
        errorType: 'exception',
      );
      
      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'apple_login',
        );
      }
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> _handleLogin() async {
    print('🚀 Login attempt started');
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      print('❌ Login form validation failed');
      return;
    }

    // Validate email and password
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (!ValidationService.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Track login attempt
      await AnalyticsService.trackAuthEvent(
        action: 'login_attempt',
        success: false, // Will be updated based on result
      );

      print('📡 Calling password login API...');
      
      // Call the password login API
      final loginResult = await LoginPasswordApiService.loginWithPasswordWithErrorHandling(
        email: email,
        password: password,
      );

      if (loginResult['success'] == true) {
        final response = loginResult['data'] as LoginPasswordResponse;
        
        if (LoginPasswordApiService.isLoginSuccessful(response)) {
          print('✅ Login successful');
          
          // Store authentication token
          final token = LoginPasswordApiService.getAuthToken(response);
          final tokenType = LoginPasswordApiService.getTokenType(response);
          final userId = LoginPasswordApiService.getUserId(response);
          
          if (token != null && tokenType != null && userId != null) {
            await TokenManagementService.storeTokenData(
              accessToken: token,
              refreshToken: null, // Not provided in this response
              tokenType: tokenType,
              expiresAt: DateTime.now().add(const Duration(hours: 1)), // Default 1 hour
            );
            await TokenManagementService.storeUserId(userId);
          }
          
          // Track successful login
          await AnalyticsService.trackAuthEvent(
            action: 'login_success',
            success: true,
          );

          if (mounted) {
            // Check if profile completion is required
            if (LoginPasswordApiService.needsProfileCompletion(response)) {
              print('📋 Profile completion required');
              
              // Navigate to profile completion screen
              Navigator.pushReplacementNamed(context, '/profile-wizard');
              
              ErrorSnackBar.showSuccess(
                context,
                message: 'Welcome back! Please complete your profile.',
              );
            } else {
              print('✅ Profile complete, proceeding to main app');
              
              // Update app state to authenticated
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              appState.setToken(token);
              appState.setUserState(ReadyForLoginState({'user_id': userId}));
              
              ErrorSnackBar.showSuccess(
                context,
                message: 'Welcome back!',
              );
            }
          }
        } else {
          print('❌ Login failed: ${response.message}');
          
          // Track failed login
          await AnalyticsService.trackAuthEvent(
            action: 'login_failed',
            success: false,
            errorType: 'api_error',
          );

          if (mounted) {
            ErrorSnackBar.show(
              context,
              error: Exception(response.message),
              errorContext: 'login',
              onAction: _handleLogin,
              actionText: 'Try Again',
            );
          }
        }
      } else {
        final error = loginResult['error'] as Map<String, dynamic>;
        final errorCode = error['code'] as int?;
        final errorDetails = error['details'] as Map<String, dynamic>?;
        
        // Check if this is a 403 error with profile completion required
        if (errorCode == 403 && errorDetails != null) {
          final responseData = errorDetails['data'] as Map<String, dynamic>?;
          
          if (responseData != null && responseData['user_state'] == 'profile_completion_required') {
            print('📋 Profile completion required (403 response)');
            
            // Store authentication token from the 403 response
            final token = responseData['token'] as String?;
            final tokenType = responseData['token_type'] as String?;
            final userId = responseData['user_id'] as int?;
            
            if (token != null && tokenType != null && userId != null) {
              await TokenManagementService.storeTokenData(
                accessToken: token,
                refreshToken: null,
                tokenType: tokenType,
                expiresAt: DateTime.now().add(const Duration(hours: 1)),
              );
              await TokenManagementService.storeUserId(userId);
            }
            
            // Track successful login (even though profile completion is required)
            await AnalyticsService.trackAuthEvent(
              action: 'login_success_profile_incomplete',
              success: true,
            );

            if (mounted) {
              // Navigate to profile completion screen
              Navigator.pushReplacementNamed(context, '/profile-wizard');
              
              ErrorSnackBar.showSuccess(
                context,
                message: 'Welcome back! Please complete your profile.',
              );
            }
            return; // Exit early since we handled the profile completion case
          }
        }
        
        print('❌ Login API error: ${loginResult['error']}');
        
        // Track failed login
        await AnalyticsService.trackAuthEvent(
          action: 'login_failed',
          success: false,
          errorType: 'api_error',
        );

        if (mounted) {
          ErrorSnackBar.show(
            context,
            error: Exception(error['message'] ?? 'Login failed'),
            errorContext: 'login',
            onAction: _handleLogin,
            actionText: 'Try Again',
          );
        }
      }
    } catch (e) {
      print('💥 Login exception: ${e.toString()}');
      
      // Track failed login
      await AnalyticsService.trackAuthEvent(
        action: 'login_failed',
        success: false,
        errorType: e.runtimeType.toString(),
      );

      // Log error
      await ErrorMonitoringService.logAuthError(
        errorType: AuthErrorType.unknownError,
        errorMessage: 'Login failed',
        details: e.toString(),
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'login',
          onAction: _handleLogin,
          actionText: 'Try Again',
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navbarBackground,
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  
                  // Header
                  Text(
                    'Welcome Back',
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your journey',
                    style: AppTypography.subtitle1.copyWith(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Email Field
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return TextFormField(
                        controller: _emailController,
                        enabled: !appState.isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(color: appState.isLoading ? Colors.white60 : Colors.white),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!ValidationService.isValidEmail(value.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                      ),
                      suffixIcon: _isEmailValid
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Field
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return TextFormField(
                        controller: _passwordController,
                        enabled: !appState.isLoading,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(color: appState.isLoading ? Colors.white60 : Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: Colors.white70,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: appState.isLoading ? null : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  
                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Login Button
                  Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: AnimatedButton(
                          onPressed: appState.isLoading ? null : _handleLogin,
                          animationType: AnimationType.scale,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appState.isLoading ? AppColors.primary.withOpacity(0.7) : AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: appState.isLoading ? 0 : 2,
                          ),
                 child: appState.isLoading
                     ? LoadingWidgets.button(
                         text: 'Signing In...',
                         color: Colors.white,
                       )
                              : Center(
                                  child: Text(
                                    'Sign In',
                                    style: AppTypography.button.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // OR Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white30)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: AppTypography.body2.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white30)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Social Login Buttons
                  _buildSocialLoginButton(
                    icon: Icons.g_mobiledata,
                    label: 'Continue with Google',
                    color: Colors.white,
                    textColor: Colors.black87,
                    onPressed: _handleGoogleLogin,
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSocialLoginButton(
                    icon: Icons.facebook,
                    label: 'Continue with Facebook',
                    color: const Color(0xFF1877F2),
                    textColor: Colors.white,
                    onPressed: _handleFacebookLogin,
                  ),
                  const SizedBox(height: 12),
                  
                  if (Platform.isIOS)
                    _buildSocialLoginButton(
                      icon: Icons.apple,
                      label: 'Continue with Apple',
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: _handleAppleLogin,
                    ),
                  if (Platform.isIOS) const SizedBox(height: 24),
                  if (!Platform.isIOS) const SizedBox(height: 12),
                   
                   // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                                             Text(
                         "Don't have an account? ",
                         style: AppTypography.body2.copyWith(
                           color: AppColors.textSecondary,
                         ),
                       ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
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
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28, color: textColor),
        label: Text(
          label,
          style: AppTypography.button.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: color == Colors.white ? Colors.white30 : Colors.transparent,
              width: 1,
            ),
          ),
          elevation: 0,
        ),
      ),
    );
  }
} 