import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'pages/onboarding_page.dart';
import 'screens/onboarding/enhanced_onboarding_screen.dart';
import 'screens/onboarding/onboarding_preferences_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
// import 'screens/profile_completion_screen.dart'; // File doesn't exist
import 'pages/profile_wizard_page.dart';
import 'pages/home_page.dart';
import 'pages/discovery_page.dart';
import 'screens/story_creation_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/safety_settings_screen.dart';
import 'screens/premium_features_screen.dart';
import 'screens/subscription_management_screen.dart';
import 'screens/payment_screen.dart';
// import 'screens/terms_of_service_screen.dart'; // File doesn't exist
// import 'screens/privacy_policy_screen.dart'; // File doesn't exist
import 'screens/accessibility_settings_screen.dart';
import 'screens/haptic_feedback_settings_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/privacy_settings_screen.dart';
import 'screens/profile/advanced_profile_customization_screen.dart';
import 'screens/profile/profile_completion_incentives_screen.dart';
import 'screens/profile/profile_verification_screen.dart';
import 'screens/profile/profile_analytics_screen.dart';
import 'screens/profile/profile_sharing_screen.dart';
import 'screens/profile/profile_backup_screen.dart';
import 'screens/profile/profile_templates_screen.dart';
import 'screens/profile/profile_export_screen.dart';
import 'components/gamification/gamification_components.dart';
// import 'help_support_screen.dart'; // File doesn't exist
import 'screens/add_payment_method_screen.dart';
import 'screens/blocked_users_screen.dart';
import 'screens/report_history_screen.dart';
// import 'screens/audio_recorder_settings_screen.dart'; // Commented out - file removed
import 'screens/video_call_screen.dart';
import 'screens/voice_call_screen.dart';
import 'models/premium_plan.dart';
import 'models/user.dart';
import 'services/firebase_notification_service.dart';
import 'pages/feed_page.dart';
import 'components/navbar/bottom_navbar.dart';
import 'pages/chat_list_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase notifications
  await FirebaseNotificationService.initialize();
  
  runApp(const LGBTinderApp());
}

class LGBTinderApp extends StatelessWidget {
  const LGBTinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Only create AppStateProvider immediately - others are lazy
        ChangeNotifierProvider(
          create: (_) => AppStateProvider(),
        ),
        // Theme provider for theme switching
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        // All other providers are lazy-loaded to improve startup performance
        ChangeNotifierProvider(
          lazy: true,
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          lazy: true,
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider(
          lazy: true,
          create: (_) => ChatProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            // Performance optimizations
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/onboarding': (context) => const OnboardingPage(),
              '/enhanced-onboarding': (context) => const EnhancedOnboardingScreen(),
              '/onboarding-preferences': (context) => OnboardingPreferencesScreen(
                initialPreferences: const OnboardingPreferences(),
                onPreferencesChanged: (preferences) {
                  // Handle preferences change
                },
              ),
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/email-verification': (context) => const EmailVerificationScreen(email: '', redirectRoute: '/home'),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              // '/profile-completion': (context) => const ProfileCompletionScreen(), // File doesn't exist
              '/profile-wizard': (context) => ProfileWizardPage(),
              '/home': (context) => const HomePage(),
              '/discovery': (context) => const DiscoveryPage(),
              '/story-creation': (context) => const StoryCreationScreen(),
              '/notification-settings': (context) => const NotificationSettingsScreen(),
              '/safety-settings': (context) => const SafetySettingsScreen(),
              '/premium-features': (context) => const PremiumFeaturesScreen(),
              '/subscription-management': (context) => const SubscriptionManagementScreen(),
              '/payment': (context) => PaymentScreen(plan: PremiumPlan.fromJson({})),
              '/video-call': (context) => VideoCallScreen(otherUser: User.fromJson({})),
              '/voice-call': (context) => VoiceCallScreen(otherUser: User.fromJson({})),
              // '/terms-of-service': (context) => const TermsOfServiceScreen(), // File doesn't exist
              // '/privacy-policy': (context) => const PrivacyPolicyScreen(), // File doesn't exist
              '/accessibility-settings': (context) => const AccessibilitySettingsScreen(),
              '/haptic-feedback-settings': (context) => const HapticFeedbackSettingsScreen(),
              '/profile-edit': (context) => ProfileEditScreen(initialData: {}),
              '/privacy-settings': (context) => PrivacySettingsScreen(
                initialSettings: const PrivacySettings(),
              ),
              '/advanced-profile-customization': (context) => const AdvancedProfileCustomizationScreen(),
              '/profile-completion-incentives': (context) => const ProfileCompletionIncentivesScreen(),
              '/profile-verification': (context) => const ProfileVerificationScreen(),
              '/profile-analytics': (context) => const ProfileAnalyticsScreen(),
              '/profile-sharing': (context) => const ProfileSharingScreen(),
              '/profile-backup': (context) => const ProfileBackupScreen(),
              '/profile-templates': (context) => const ProfileTemplatesScreen(),
              '/profile-export': (context) => const ProfileExportScreen(),
              '/gamification-dashboard': (context) => const GamificationDashboard(),
              // '/help-support': (context) => const HelpSupportScreen(), // File doesn't exist
              '/add-payment-method': (context) => const AddPaymentMethodScreen(),
              '/blocked-users': (context) => const BlockedUsersScreen(),
              '/report-history': (context) => const ReportHistoryScreen(),
              // '/audio-recorder-settings': (context) => const AudioRecorderSettingsScreen(), // Commented out - screen removed
              '/feed': (context) => const FeedPage(),
              '/main': (context) => const MainScreen(),
              '/api-test': (context) => const ApiTestPage(),
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomePage(),
          DiscoveryPage(),
          ChatListPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class ApiTestPage extends StatelessWidget {
  const ApiTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
      ),
      body: const Center(
        child: Text('API Test Page'),
      ),
    );
  }
}