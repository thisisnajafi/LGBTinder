import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../models/user_state_models.dart';
import '../../pages/splash_page.dart';
import '../../components/splash/optimized_splash_page.dart';
import '../../components/splash/simple_splash_page.dart';
import '../../pages/home_page.dart';
import '../../screens/onboarding/enhanced_onboarding_screen.dart';
import '../../services/onboarding_manager.dart';
import 'welcome_screen.dart';
import 'register_screen.dart';
import 'email_verification_screen.dart';
import 'profile_completion_screen.dart';

/// Authentication wrapper that handles app state based on user state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingOnboarding = true;
  bool _shouldShowOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final shouldShow = await OnboardingManager.shouldShowOnboarding();
    final isFirstLaunch = await OnboardingManager.isFirstLaunch();
    
    if (mounted) {
      setState(() {
        // Only show onboarding for first-time users who are not authorized
        _shouldShowOnboarding = shouldShow && isFirstLaunch;
        _isCheckingOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while checking onboarding status
    if (_isCheckingOnboarding) {
      return const SimpleSplashPage();
    }

    // Show enhanced onboarding if needed
    if (_shouldShowOnboarding) {
      return const EnhancedOnboardingScreen();
    }

    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        // Show simple splash screen while initializing
        if (appState.isLoading) {
          return const SimpleSplashPage();
        }

        final userState = appState.currentUserState;

        // No user state - show welcome screen for registration
        if (userState == null) {
          return const WelcomeScreen();
        }

        // Handle different user states
        if (userState is EmailVerificationRequiredState) {
          return EmailVerificationScreen(
            email: userState.email,
            userId: userState.userId,
          );
        }

        if (userState is ProfileCompletionRequiredState) {
          return const ProfileCompletionScreen();
        }

        if (userState is ReadyForLoginState) {
          return const HomePage();
        }

        if (userState is BannedState) {
          return BannedScreen(
            reason: userState.banReason,
          );
        }

        if (userState is ErrorState) {
          return ErrorScreen(
            message: userState.message,
            onRetry: () => appState.initializeApp(),
          );
        }

        // Default fallback
        return const WelcomeScreen();
      },
    );
  }
}

/// Screen shown when user is banned
class BannedScreen extends StatelessWidget {
  final String? reason;

  const BannedScreen({super.key, this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Account Banned',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                reason ?? 'Your account has been banned. Please contact support for more information.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Navigate to support or contact page
                  Navigator.of(context).pushNamed('/support');
                },
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen shown when there's an error
class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
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
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        // Check authentication requirement
        if (requireAuth && appState.currentUserState == null) {
          // Redirect to welcome screen if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return const WelcomeScreen();
        }

        // Check profile completion requirement
        if (requireProfileCompletion && appState.currentUserState is! ReadyForLoginState) {
          // Redirect to appropriate screen based on user state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/profile-completion');
          });
          return const ProfileCompletionScreen();
        }

        // All requirements met - show the requested screen
        return child;
      },
    );
  }
}
