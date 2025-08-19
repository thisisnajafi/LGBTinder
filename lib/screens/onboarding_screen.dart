import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Relax & Connect',
      subtitle: 'Find meaningful connections in a safe space.',
      imagePath: 'assets/onboarding/1.png',
    ),
    OnboardingSlide(
      title: 'Be Yourself',
      subtitle: 'Express your true identity without limits.',
      imagePath: 'assets/onboarding/2.png',
    ),
    OnboardingSlide(
      title: 'Share Your Vibe',
      subtitle: 'Post stories and moments that matter.',
      imagePath: 'assets/onboarding/3.png',
    ),
    OnboardingSlide(
      title: 'Meet, Match, & Love',
      subtitle: 'Swipe through queer-friendly profiles made for you.',
      imagePath: 'assets/onboarding/4.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e), // Navy
              Color(0xFF16213e), // Dark navy
              Color(0xFF0f3460), // Purple navy
              Color(0xFF533483), // Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button (only on first slide)
              if (_currentPage == 0)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTypography.bodyMediumStyle.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    return _OnboardingSlideWidget(slide: _slides[index]);
                  },
                ),
              ),
              
              // Bottom section with indicators and buttons
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Page indicators
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _slides.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 12,
                        dotColor: AppColors.textSecondaryLight.withOpacity(0.3),
                        activeDotColor: AppColors.primaryLight,
                        paintStyle: PaintingStyle.fill,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button (show only if not on first page)
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.secondaryLight),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Back',
                                style: AppTypography.bodyMediumStyle.copyWith(
                                  color: AppColors.secondaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        
                        if (_currentPage > 0) const SizedBox(width: 16),
                        
                        // Next/Get Started button
                        Expanded(
                          flex: _currentPage > 0 ? 1 : 1,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentPage == _slides.length - 1
                                  ? AppColors.successLight
                                  : AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 8,
                              shadowColor: (_currentPage == _slides.length - 1
                                      ? AppColors.successLight
                                      : AppColors.primaryLight)
                                  .withOpacity(0.3),
                            ),
                            child: Text(
                              _currentPage == _slides.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: AppTypography.bodyMediumStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String imagePath;

  OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class _OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlide slide;

  const _OnboardingSlideWidget({
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  slide.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryLight.withOpacity(0.1),
                            AppColors.secondaryLight.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.image,
                        size: 80,
                        color: AppColors.textSecondaryLight.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Text content
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  style: AppTypography.headlineLargeStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  slide.subtitle,
                  style: AppTypography.bodyLargeStyle.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 18,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 