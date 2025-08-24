import 'package:flutter/material.dart';
import 'components/navbar/bottom_navbar.dart';
import 'theme/colors.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';

void main() {
  runApp(const LGBTinderApp());
}

class LGBTinderApp extends StatelessWidget {
  const LGBTinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primaryLight,
        scaffoldBackgroundColor: AppColors.appBackground,
        bottomAppBarTheme: BottomAppBarThemeData(color: AppColors.appBackground),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/main': (context) => const MainScreen(),
      },
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
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Messages',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chat with your matches and start conversations',
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

  Widget _buildProfilePage() {
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
                  Icons.person_outline,
                  size: 60,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Manage your profile and preferences',
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
}


