import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../components/gradients/lgbt_gradient_system.dart';
import '../../services/haptic_feedback_service.dart';
import '../../services/onboarding_manager.dart';
import '../../components/buttons/animated_button.dart';
import '../../components/buttons/accessible_button.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class OnboardingStep {
  final String title;
  final String description;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final Widget? customContent;

  const OnboardingStep({
    required this.title,
    required this.description,
    this.imagePath,
    this.icon,
    this.iconColor,
    this.customContent,
  });
}

class EnhancedOnboardingScreen extends StatefulWidget {
  const EnhancedOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedOnboardingScreen> createState() => _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState extends State<EnhancedOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Welcome to LGBTinder',
      description: 'A safe and inclusive space for the LGBTQ+ community to connect, discover, and build meaningful relationships.',
      icon: Icons.favorite,
      iconColor: AppColors.primaryLight,
    ),
    OnboardingStep(
      title: 'Find Your Perfect Match',
      description: 'Discover amazing people who share your interests, values, and goals. Swipe right to connect!',
      icon: Icons.people,
      iconColor: AppColors.feedbackSuccess,
    ),
    OnboardingStep(
      title: 'Build Meaningful Connections',
      description: 'Chat with your matches, share experiences, and build lasting relationships in a supportive environment.',
      icon: Icons.chat_bubble,
      iconColor: AppColors.feedbackInfo,
    ),
    OnboardingStep(
      title: 'Join Our Community',
      description: 'Be part of a vibrant, supportive community that celebrates diversity and promotes authentic connections.',
      icon: Icons.group,
      iconColor: AppColors.feedbackWarning,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageController = PageController();
    _isLastPage = _currentPage == _steps.length - 1;
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

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode 
              ? AppColors.backgroundDark 
              : AppColors.background,
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                _buildHeader(context, themeProvider),
                _buildProgressIndicator(context, themeProvider),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(_steps[index], context, themeProvider);
                    },
                  ),
                ),
                _buildNavigationButtons(context, themeProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LGBTGradientSystem.rainbowGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            
            // Skip Button
            if (!_isLastPage)
              TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  'Skip',
                  style: AppTypography.buttonStyle.copyWith(
                    color: themeProvider.isDarkMode 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentPage + 1} of ${_steps.length}',
                style: AppTypography.caption.copyWith(
                  color: themeProvider.isDarkMode 
                      ? AppColors.textSecondaryDark 
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                '${((_currentPage + 1) / _steps.length * 100).round()}%',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: (_currentPage + 1) / _steps.length * _progressAnimation.value,
                backgroundColor: themeProvider.isDarkMode 
                    ? AppColors.surfaceSecondary 
                    : AppColors.surfaceSecondary,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                minHeight: 4,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingStep step, BuildContext context, ThemeProvider themeProvider) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  _buildStepIcon(step),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    step.title,
                    style: AppTypography.h2.copyWith(
                      color: themeProvider.isDarkMode 
                          ? AppColors.textPrimaryDark 
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    step.description,
                    style: AppTypography.body1.copyWith(
                      color: themeProvider.isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Custom Content
                  if (step.customContent != null) step.customContent!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIcon(OnboardingStep step) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: step.iconColor != null
                  ? LinearGradient(
                      colors: [
                        step.iconColor!.withOpacity(0.1),
                        step.iconColor!.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LGBTGradientSystem.rainbowGradient,
              borderRadius: BorderRadius.circular(64),
              border: Border.all(
                color: step.iconColor?.withOpacity(0.3) ?? AppColors.primaryLight.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              step.icon ?? Icons.favorite,
              size: 48,
              color: step.iconColor ?? AppColors.primaryLight,
            ),
          ),
        );
      },
    );
  }


  Widget _buildNavigationButtons(BuildContext context, ThemeProvider themeProvider) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: themeProvider.isDarkMode 
                              ? AppColors.borderDefault 
                              : AppColors.borderDefault,
                        ),
                        foregroundColor: themeProvider.isDarkMode 
                            ? AppColors.textPrimaryDark 
                            : AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLastPage ? _completeOnboarding : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_isLastPage ? 'Get Started' : 'Next'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Terms and Privacy
            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy',
              style: AppTypography.caption.copyWith(
                color: themeProvider.isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Footer Links
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: _showTermsOfService,
                  child: Text(
                    'Terms of Service',
                    style: AppTypography.caption.copyWith(
                      color: themeProvider.isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showPrivacyPolicy,
                  child: Text(
                    'Privacy Policy',
                    style: AppTypography.caption.copyWith(
                      color: themeProvider.isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showHelpSupport,
                  child: Text(
                    'Help & Support',
                    style: AppTypography.caption.copyWith(
                      color: themeProvider.isDarkMode 
                          ? AppColors.textSecondaryDark 
                          : AppColors.textSecondary,
                      decoration: TextDecoration.underline,
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

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _isLastPage = page == _steps.length - 1;
    });
    
    // Reset and restart animations
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    _startAnimations();
    
    HapticFeedbackService.selection();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedbackService.selection();
    _showSkipConfirmation();
  }

  void _completeOnboarding() {
    HapticFeedbackService.success();
    OnboardingManager.markOnboardingCompleted();
    _showWelcomeOptions();
  }

  void _showSkipConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AlertDialog(
            backgroundColor: themeProvider.isDarkMode 
                ? AppColors.navbarBackground 
                : AppColors.background,
            title: Text(
              'Skip Onboarding',
              style: TextStyle(
                color: themeProvider.isDarkMode 
                    ? AppColors.textPrimaryDark 
                    : AppColors.textPrimary,
              ),
            ),
            content: Text(
              'Are you sure you want to skip the onboarding? You can always access this information later.',
              style: TextStyle(
                color: themeProvider.isDarkMode 
                    ? AppColors.textSecondaryDark 
                    : AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: themeProvider.isDarkMode 
                        ? AppColors.textSecondaryDark 
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  OnboardingManager.markOnboardingSkipped();
                  _showWelcomeOptions();
                },
                child: Text(
                  'Skip',
                  style: TextStyle(color: AppColors.feedbackWarning),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showWelcomeOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode 
                  ? AppColors.navbarBackground 
                  : AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    Text(
                      'Welcome to LGBTinder!',
                      style: AppTypography.h3.copyWith(
                        color: themeProvider.isDarkMode 
                            ? AppColors.textPrimaryDark 
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Ready to start your journey?',
                      style: AppTypography.body1.copyWith(
                        color: themeProvider.isDarkMode 
                            ? AppColors.textSecondaryDark 
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'I Already Have an Account',
                          style: AppTypography.buttonStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryLight,
                          side: BorderSide(
                            color: AppColors.primaryLight,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Create New Account',
                          style: AppTypography.buttonStyle.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showTermsOfService() {
    // TODO: Implement Terms of Service screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of Service coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Implement Privacy Policy screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _showHelpSupport() {
    // TODO: Implement Help & Support screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help & Support coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }
}
