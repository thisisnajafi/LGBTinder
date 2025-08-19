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
        bottomAppBarTheme: BottomAppBarTheme(color: AppColors.appBackground),
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

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const SearchPage(),
      const Center(child: Text('Discover', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Chat', style: TextStyle(color: Colors.white))),
      const Center(child: Text('Profile', style: TextStyle(color: Colors.white))),
    ];
    return Scaffold(
      body: Stack(
        children: [
          // Page content - no bottom padding needed for floating navbar
          pages[_currentIndex],
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
}


