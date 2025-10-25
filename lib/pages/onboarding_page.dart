import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
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
              AppColors.onboardingBlack,
              AppColors.onboardingDarkNavy,
              AppColors.onboardingDarkPurple,
              AppColors.onboardingDeepPurple,
            ],
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
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
                        dotHeight: 10,
                        dotWidth: 10,
                        spacing: 16,
                        dotColor: Colors.white.withOpacity(0.2),
                        activeDotColor: AppColors.lgbtPurple,
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
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: TextButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Back',
                                style: AppTypography.bodyMediumStyle.copyWith(
                                    color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        if (_currentPage > 0) const SizedBox(width: 16),
                        
                        // Next/Get Started button
                        Expanded(
                          flex: _currentPage > 0 ? 1 : 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: _currentPage == _slides.length - 1
                                    ? AppColors.lgbtGradient
                                    : [
                                        AppColors.lgbtBlue,
                                        AppColors.lgbtPurple,
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_currentPage == _slides.length - 1
                                          ? AppColors.lgbtRed
                                          : AppColors.lgbtBlue)
                                      .withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                              ),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: Text(
                              _currentPage == _slides.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: AppTypography.bodyMediumStyle.copyWith(
                                color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
            child: Container(
          height: screenHeight * 0.7,
          width: screenWidth * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                color: AppColors.lgbtPurple.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Image
                Container(
                  width: double.infinity,
                  height: double.infinity,
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
                              AppColors.lgbtBlue.withOpacity(0.3),
                              AppColors.lgbtPurple.withOpacity(0.3),
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                      child: Icon(
                        Icons.image,
                        size: 80,
                          color: Colors.white.withOpacity(0.5),
                      ),
                    );
                  },
                  ),
                ),
                
                // Dark gradient overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.95),
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
          
                // Text overlay at bottom
                Positioned(
                  bottom: 32,
                  left: 24,
                  right: 24,
            child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                          color: Colors.white.withOpacity(0.9),
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
          ),
        ),
      ),
    );
  }
} 