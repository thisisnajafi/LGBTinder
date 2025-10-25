import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navbarBackground,
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                                             // Logo
                       FadeTransition(
                         opacity: _fadeAnimation,
                         child: Image.asset(
                           'assets/logo/logo.png',
                           height: 80,
                           width: 200,
                           fit: BoxFit.contain,
                         ),
                       ),
                       const SizedBox(height: 20),
                      const SizedBox(height: 8),
                      
                                             FadeTransition(
                         opacity: _fadeAnimation,
                         child: Text(
                           'Find your perfect match',
                           style: AppTypography.subtitle1.copyWith(
                             color: Colors.white70,
                           ),
                         ),
                       ),
                      const SizedBox(height: 40),
                      
                      // Welcome Message
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.navbarBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                                                         child: Column(
                               children: [
                                 Icon(
                                   Icons.favorite,
                                   size: 40,
                                   color: AppColors.primary,
                                 ),
                                 const SizedBox(height: 16),
                                 
                                 Text(
                                   'Welcome to LGBTinder',
                                   style: AppTypography.h2.copyWith(
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                                 const SizedBox(height: 12),
                                 
                                 Text(
                                   'A safe and inclusive space for the LGBTQ+ community to connect, discover, and build meaningful relationships.',
                                   style: AppTypography.body1.copyWith(
                                     color: Colors.white70,
                                     height: 1.5,
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                               ],
                             ),
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Action Buttons
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                                                     child: Text(
                                     'Login',
                                     style: AppTypography.button.copyWith(
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: BorderSide(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                                                     child: Text(
                                     'Create Account',
                                     style: AppTypography.button.copyWith(
                                       color: AppColors.primary,
                                       fontWeight: FontWeight.w600,
                                     ),
                                   ),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                                                             // Terms and Privacy
                               Text(
                                 'By continuing, you agree to our Terms of Service and Privacy Policy',
                                 style: AppTypography.caption.copyWith(
                                   color: Colors.white70,
                                   height: 1.4,
                                 ),
                                 textAlign: TextAlign.center,
                               ),
                              
                              const SizedBox(height: 24),
                              
                                                             // Footer Links
                               Wrap(
                                 alignment: WrapAlignment.center,
                                 spacing: 16,
                                 runSpacing: 8,
                                 children: [
                                   TextButton(
                                     onPressed: () {
                                       // TODO: Navigate to terms of service
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(
                                           content: Text('Terms of Service coming soon!'),
                                         ),
                                       );
                                     },
                                     child: Text(
                                       'Terms of Service',
                                       style: AppTypography.caption.copyWith(
                                         color: Colors.white,
                                         decoration: TextDecoration.underline,
                                       ),
                                     ),
                                   ),
                                   TextButton(
                                     onPressed: () {
                                       Navigator.pushNamed(context, '/privacy-policy');
                                     },
                                     child: Text(
                                       'Privacy Policy',
                                       style: AppTypography.caption.copyWith(
                                         color: Colors.white,
                                         decoration: TextDecoration.underline,
                                       ),
                                     ),
                                   ),
                                   TextButton(
                                     onPressed: () {
                                       Navigator.pushNamed(context, '/help-support');
                                     },
                                     child: Text(
                                       'Help & Support',
                                       style: AppTypography.caption.copyWith(
                                         color: Colors.white,
                                         decoration: TextDecoration.underline,
                                       ),
                                     ),
                                   ),
                                   // Debug: API Test Button
                                   TextButton(
                                     onPressed: () {
                                       Navigator.pushNamed(context, '/api-test');
                                     },
                                     child: Text(
                                       'API Test',
                                       style: AppTypography.caption.copyWith(
                                         color: Colors.orange,
                                         decoration: TextDecoration.underline,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
