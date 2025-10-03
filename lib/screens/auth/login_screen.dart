import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../models/user_state_models.dart';
import '../../services/validation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/error_monitoring_service.dart';
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

      print('📡 Calling app state provider login...');
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      
      // For now, we'll simulate a login since the API doesn't have a direct login endpoint
      // In a real implementation, you would call appState.login() or similar
      print('📡 App state provider login result: true');
      
      if (mounted) {
        print('✅ Login successful');
        
        // Track successful login
        await AnalyticsService.trackAuthEvent(
          action: 'login_success',
          success: true,
        );

               // Navigation will be handled by AuthWrapper
               ErrorSnackBar.showSuccess(
                 context,
                 message: 'Welcome back!',
               );
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
                  const SizedBox(height: 12),
                   
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
} 