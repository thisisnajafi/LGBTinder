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

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Relax & Connect',
      subtitle: 'Find meaningful connections in a safe space.',
      imagePath: 'assets/onboarding/1.png',
      gradientColors: [
        AppColors.lgbtRed,
        AppColors.lgbtOrange,
        AppColors.lgbtYellow,
      ],
      accentColor: AppColors.lgbtRed,
    ),
    OnboardingSlide(
      title: 'Be Yourself',
      subtitle: 'Express your true identity without limits.',
      imagePath: 'assets/onboarding/2.png',
      gradientColors: [
        AppColors.lgbtGreen,
        AppColors.lgbtBlue,
        AppColors.lgbtPurple,
      ],
      accentColor: AppColors.lgbtGreen,
    ),
    OnboardingSlide(
      title: 'Share Your Vibe',
      subtitle: 'Post stories and moments that matter.',
      imagePath: 'assets/onboarding/3.png',
      gradientColors: [
        AppColors.lgbtBlue,
        AppColors.lgbtPurple,
        AppColors.primary,
      ],
      accentColor: AppColors.lgbtBlue,
    ),
    OnboardingSlide(
      title: 'Meet, Match, & Love',
      subtitle: 'Swipe through queer-friendly profiles made for you.',
      imagePath: 'assets/onboarding/4.png',
      gradientColors: [
        AppColors.primary,
        AppColors.secondaryLight,
        AppColors.successLight,
      ],
      accentColor: AppColors.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
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
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
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
    
    _startAnimations();
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
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
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.appBackground,
                  AppColors.navbarBackground,
                  _slides[_currentPage].gradientColors.first.withOpacity(0.3),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Skip button with rainbow effect
                  if (_currentPage == 0)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: AppColors.lgbtGradient,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lgbtRed.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: _skipOnboarding,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: AppTypography.bodyMediumStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
                        _startAnimations();
                      },
                      itemCount: _slides.length,
                      itemBuilder: (context, index) {
                        return _OnboardingSlideWidget(
                          slide: _slides[index],
                          isActive: index == _currentPage,
                        );
                      },
                    ),
                  ),
                  
                  // Bottom section with enhanced indicators and buttons
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Enhanced page indicators with rainbow effect
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: _slides.length,
                            effect: WormEffect(
                              dotHeight: 10,
                              dotWidth: 10,
                              spacing: 16,
                              dotColor: Colors.white.withOpacity(0.3),
                              activeDotColor: _slides[_currentPage].accentColor,
                              paintStyle: PaintingStyle.fill,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Enhanced action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button with rainbow border
                            if (_currentPage > 0)
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: AppColors.lgbtGradient,
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      color: AppColors.appBackground,
                                    ),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeInOutCubic,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: Text(
                                        'Back',
                                        style: AppTypography.bodyMediumStyle.copyWith(
                                          color: _slides[_currentPage].accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                            if (_currentPage > 0) const SizedBox(width: 16),
                            
                            // Next/Get Started button with dynamic gradient
                            Expanded(
                              flex: _currentPage > 0 ? 1 : 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: _currentPage == _slides.length - 1
                                        ? AppColors.gradientSuccess
                                        : _slides[_currentPage].gradientColors,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_currentPage == _slides.length - 1
                                              ? AppColors.successLight
                                              : _slides[_currentPage].accentColor)
                                          .withOpacity(0.4),
                                      blurRadius: 20,
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
                                    padding: const EdgeInsets.symmetric(vertical: 16),
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
          );
        },
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradientColors;
  final Color accentColor;

  OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.gradientColors,
    required this.accentColor,
  });
}

class _OnboardingSlideWidget extends StatefulWidget {
  final OnboardingSlide slide;
  final bool isActive;

  const _OnboardingSlideWidget({
    required this.slide,
    required this.isActive,
  });

  @override
  State<_OnboardingSlideWidget> createState() => _OnboardingSlideWidgetState();
}

class _OnboardingSlideWidgetState extends State<_OnboardingSlideWidget>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _textController;
  late Animation<double> _imageScale;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _imageScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _imageController,
      curve: Curves.elasticOut,
    ));
    
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _imageController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(_OnboardingSlideWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _imageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced Image with rainbow border and glow
          Expanded(
            flex: 3,
            child: AnimatedBuilder(
              animation: _imageScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _imageScale.value,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: widget.slide.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.slide.accentColor.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: AppColors.appBackground,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset(
                          widget.slide.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: widget.slide.gradientColors.map(
                                    (color) => color.withOpacity(0.1),
                                  ).toList(),
                                ),
                              ),
                              child: Icon(
                                Icons.image,
                                size: 80,
                                color: widget.slide.accentColor.withOpacity(0.7),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Enhanced Text content with animations
          Expanded(
            flex: 2,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title with rainbow text effect
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: widget.slide.gradientColors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: Text(
                            widget.slide.title,
                            style: AppTypography.headlineLargeStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 36,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: widget.slide.accentColor.withOpacity(0.5),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Subtitle with enhanced styling
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.slide.subtitle,
                            style: AppTypography.bodyLargeStyle.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 