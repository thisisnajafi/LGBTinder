import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'components/navbar/bottom_navbar.dart';
import 'theme/colors.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/profile_page.dart';
import 'pages/chat_list_page.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'providers/profile_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/profile_completion_welcome_screen.dart';
import 'screens/auth/profile_wizard_screen.dart';
import 'screens/auth/profile_completion_screen.dart';
import 'pages/api_test_page.dart';
import 'pages/discovery_page.dart';
import 'screens/story_creation_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/safety_settings_screen.dart';
import 'screens/premium_features_screen.dart';
import 'screens/subscription_management_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/video_call_screen.dart';
import 'screens/voice_call_screen.dart';
import 'screens/legal/terms_of_service_screen.dart';
import 'screens/legal/privacy_policy_screen.dart';
import 'screens/accessibility_settings_screen.dart';
import 'screens/rainbow_theme_settings_screen.dart';
import 'screens/haptic_feedback_settings_screen.dart';
import 'screens/animation_settings_screen.dart';
import 'screens/pull_to_refresh_settings_screen.dart';
import 'screens/skeleton_loader_settings_screen.dart';
import 'screens/image_compression_settings_screen.dart';
import 'screens/media_picker_settings_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/add_payment_method_screen.dart';
import 'screens/blocked_users_screen.dart';
import 'screens/report_history_screen.dart';
// import 'screens/audio_recorder_settings_screen.dart'; // Commented out - file removed
import 'models/premium_plan.dart';
import 'models/user.dart';
import 'services/firebase_notification_service.dart';
import 'pages/feed_page.dart';

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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        // Performance optimizations
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        theme: ThemeData.dark().copyWith(
          primaryColor: AppColors.primaryLight,
          scaffoldBackgroundColor: AppColors.appBackground,
          bottomAppBarTheme: BottomAppBarThemeData(color: AppColors.appBackground),
          // Optimized animations
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/onboarding': (context) => const OnboardingPage(),
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/email-verification': (context) => const EmailVerificationScreen(email: '', redirectRoute: '/home'),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/profile-completion': (context) => const ProfileCompletionScreen(),
          '/profile-wizard': (context) => const ProfileWizardScreen(),
          '/home': (context) => const HomePage(),
          '/discovery': (context) => const DiscoveryPage(),
          '/story-creation': (context) => const StoryCreationScreen(),
          '/notification-settings': (context) => const NotificationSettingsScreen(),
          '/safety-settings': (context) => const SafetySettingsScreen(),
          '/premium-features': (context) => const PremiumFeaturesScreen(),
          '/subscription-management': (context) => const SubscriptionManagementScreen(),
          '/payment': (context) => PaymentScreen(plan: PremiumPlan.fromJson({})),
          // '/video-call': (context) => VideoCallScreen(otherUser: User.fromJson({})),  // Temporarily disabled
          // '/voice-call': (context) => VoiceCallScreen(otherUser: User.fromJson({})),  // Temporarily disabled
          '/terms-of-service': (context) => const TermsOfServiceScreen(),
          '/privacy-policy': (context) => const PrivacyPolicyScreen(),
          '/accessibility-settings': (context) => const AccessibilitySettingsScreen(),
          '/rainbow-theme-settings': (context) => const RainbowThemeSettingsScreen(),
          '/haptic-feedback-settings': (context) => const HapticFeedbackSettingsScreen(),
          '/animation-settings': (context) => const AnimationSettingsScreen(),
          '/pull-to-refresh-settings': (context) => const PullToRefreshSettingsScreen(),
          '/skeleton-loader-settings': (context) => const SkeletonLoaderSettingsScreen(),
          '/image-compression-settings': (context) => const ImageCompressionSettingsScreen(),
          '/media-picker-settings': (context) => const MediaPickerSettingsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/help-support': (context) => const HelpSupportScreen(),
          '/add-payment-method': (context) => const AddPaymentMethodScreen(),
          '/blocked-users': (context) => const BlockedUsersScreen(),
          '/report-history': (context) => const ReportHistoryScreen(),
          // '/audio-recorder-settings': (context) => const AudioRecorderSettingsScreen(), // Commented out - screen removed
          '/feed': (context) => const FeedPage(),
          '/main': (context) => const MainScreen(),
          '/api-test': (context) => const ApiTestPage(),
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
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
    
    // Start with the first page visible
    _transitionController.value = 1.0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      
      // Animate page transition
      _transitionController.forward(from: 0);
      
      // Navigate to page with animation
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const SearchPage(),
      _buildDiscoverPage(),
      _buildMessagesPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Page content with fade transitions only
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe navigation
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: pages.map((page) => _buildPageWithTransition(page)).toList(),
          ),
          
          // Floating navbar positioned at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavbar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageWithTransition(Widget page) {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: page,
        );
      },
    );
  }

  Widget _buildDiscoverPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.appBackground,
            Color(0xFF0A0A0F),
            Color(0xFF050508),
            AppColors.appBackground,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLight.withOpacity(0.2),
                      AppColors.secondaryLight.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.explore,
                  size: 60,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Discover',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Find new connections and explore the community',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesPage() {
    // return const ChatListPage(); // Commented out due to syntax error
    return const Center(child: Text('Messages Page - Under Construction'));
  }

  Widget _buildProfilePage() {
    return const ProfilePage();
  }
}


