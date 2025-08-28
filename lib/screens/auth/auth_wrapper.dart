import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../pages/splash_page.dart';
import '../../pages/onboarding_page.dart';
import '../../pages/home_page.dart';
import 'welcome_screen.dart';

/// Authentication wrapper that handles app state based on authentication status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading state while initializing
        if (authProvider.isLoading) {
          return const SplashPage();
        }

        // Check if user is authenticated
        if (authProvider.isAuthenticated) {
          // Check if profile is completed
          if (authProvider.isProfileCompleted) {
            // User is authenticated and profile is complete - show main app
            return const HomePage();
          } else {
            // User is authenticated but profile is incomplete - show onboarding
            return const OnboardingPage();
          }
        } else {
          // User is not authenticated - show welcome screen
          return const WelcomeScreen();
        }
      },
    );
  }
}

/// Route guard for protected routes
class AuthRouteGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuth;
  final bool requireProfileCompletion;

  const AuthRouteGuard({
    super.key,
    required this.child,
    this.requireAuth = true,
    this.requireProfileCompletion = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check authentication requirement
        if (requireAuth && !authProvider.isAuthenticated) {
          // Redirect to welcome screen if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return const WelcomeScreen();
        }

        // Check profile completion requirement
        if (requireProfileCompletion && !authProvider.isProfileCompleted) {
          // Redirect to onboarding if profile not completed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/onboarding');
          });
          return const OnboardingPage();
        }

        // All requirements met - show the requested screen
        return child;
      },
    );
  }
}
