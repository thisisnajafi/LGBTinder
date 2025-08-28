import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth_requests.dart';
import '../../utils/validation.dart';
import '../../utils/registration_validator.dart';
import 'email_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isFirstNameValid = false;
  bool _isLastNameValid = false;
  bool _isTermsAccepted = false;
  
  // Password strength validation
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
    _firstNameController.addListener(_validateFirstName);
    _lastNameController.addListener(_validateLastName);
    _passwordController.addListener(_validatePasswordStrength);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      _isEmailValid = RegistrationValidator.validateEmail(_emailController.text) == null;
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = RegistrationValidator.validatePassword(_passwordController.text) == null;
    });
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    setState(() {
      _isConfirmPasswordValid = RegistrationValidator.validateConfirmPassword(
        _confirmPasswordController.text, 
        _passwordController.text
      ) == null;
    });
  }

  void _validateFirstName() {
    setState(() {
      _isFirstNameValid = RegistrationValidator.validateFirstName(_firstNameController.text) == null;
    });
  }

  void _validateLastName() {
    setState(() {
      _isLastNameValid = RegistrationValidator.validateLastName(_lastNameController.text) == null;
    });
  }

  void _validatePasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isValid ? AppColors.success : Colors.white30,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.body2.copyWith(
              color: isValid ? AppColors.success : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    print('🚀 Registration attempt started');
    print('📋 Form validation: ${_formKey.currentState!.validate()}');
    print('📋 Terms accepted: $_isTermsAccepted');
    print('📋 Password requirements: ${_hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar}');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }
    
    // Check if terms are accepted
    if (!_isTermsAccepted) {
      print('❌ Terms not accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service and Privacy Policy'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check if all password requirements are met
    if (!(_hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar)) {
      print('❌ Password requirements not met');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please ensure all password requirements are met'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Creating registration request...');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final request = RegisterRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      print('📝 Registration data: firstName=${request.firstName}, lastName=${request.lastName}, email=${request.email}');
      print('🔐 Password length: ${_passwordController.text.length}');
      print('🔐 Passwords match: ${_passwordController.text == _confirmPasswordController.text}');
      
      print('📡 Calling auth provider register...');
      final success = await authProvider.register(request);
      print('📡 Auth provider result: $success');
      
      if (success && mounted) {
        print('✅ Registration successful, navigating to verification');
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully! Please check your email for verification.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate to verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(
              email: _emailController.text.trim(),
              redirectRoute: '/home',
            ),
          ),
        );
      } else {
        print('❌ Registration failed but no exception thrown');
        print('❌ Auth provider error: ${authProvider.authError}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to create account. Please check your information and try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('💥 Registration exception: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to create account. Please check your internet connection and try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
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
                    'Create Account',
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Join LGBTinder and find your perfect match',
                    style: AppTypography.subtitle1.copyWith(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                  

                  
                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: _isLoading ? Colors.white60 : Colors.white),
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      hintText: 'Enter your first name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                      suffixIcon: _isFirstNameValid
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
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    validator: (value) => RegistrationValidator.validateFirstName(value),
                  ),
                  const SizedBox(height: 20),
                  
                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    enabled: !_isLoading,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: _isLoading ? Colors.white60 : Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Enter your last name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                      suffixIcon: _isLastNameValid
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
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    validator: (value) => RegistrationValidator.validateLastName(value),
                  ),
                  const SizedBox(height: 20),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: _isLoading ? Colors.white60 : Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(
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
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    validator: (value) => RegistrationValidator.validateEmail(value),
                  ),
                  const SizedBox(height: 20),
                  
                  // Password
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: _isLoading ? Colors.white60 : Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: Colors.white70,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
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
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    validator: (value) => RegistrationValidator.validatePassword(value),
                  ),
                  const SizedBox(height: 12),
                  
                  // Password Strength Checklist
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements',
                          style: AppTypography.body2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPasswordRequirement('At least 8 characters', _hasMinLength),
                        _buildPasswordRequirement('Contains uppercase letter', _hasUppercase),
                        _buildPasswordRequirement('Contains lowercase letter', _hasLowercase),
                        _buildPasswordRequirement('Contains number', _hasNumber),
                        _buildPasswordRequirement('Contains special character', _hasSpecialChar),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    enabled: !_isLoading,
                    obscureText: !_isConfirmPasswordVisible,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: _isLoading ? Colors.white60 : Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: const TextStyle(color: Colors.white30),
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: Colors.white70,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
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
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    validator: (value) => RegistrationValidator.validateConfirmPassword(value, _passwordController.text),
                  ),
                  const SizedBox(height: 32),
                  
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
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
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Creating Account...',
                                  style: AppTypography.button.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Create Account',
                              style: AppTypography.button.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Terms and Privacy
                  Row(
                    children: [
                      Checkbox(
                        value: _isTermsAccepted,
                        onChanged: _isLoading ? null : (value) {
                          setState(() {
                            _isTermsAccepted = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Sign In',
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
