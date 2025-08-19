import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import '../theme/colors.dart';
import '../components/match_interaction/action_buttons.dart';
import '../components/navbar/lgbtinder_logo.dart';
import '../components/profile_cards/match_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _particleController;
  Timer? _imageTimer;
  int _currentImageIndex = 0;

  // Sample profiles for the stack
  final List<Map<String, dynamic>> _sampleProfiles = [
    {
      'name': 'Emma',
      'age': 28,
      'bio': 'Cinema enthusiast, animal lover,\nand adventurer at heart',
      'images': [
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
      ],
      'tags': ['Cinema', 'Vegan', 'Traveler'],
    },
    {
      'name': 'Alex',
      'age': 25,
      'bio': 'Coffee lover, bookworm, and aspiring chef.',
      'images': [
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
      ],
      'tags': ['Coffee', 'Books', 'Cooking'],
    },
    {
      'name': 'Taylor',
      'age': 30,
      'bio': 'Runner, gamer, and tech enthusiast.',
      'images': [
        'https://images.pexels.com/photos/14679012/pexels-photo-14679012.jpeg',
        'https://images.pexels.com/photos/17399454/pexels-photo-17399454.jpeg',
      ],
      'tags': ['Running', 'Gaming', 'Tech'],
    },
    {
      'name': 'Jordan',
      'age': 27,
      'bio': 'Music is life. Guitarist and singer.',
      'images': [
        'https://images.pexels.com/photos/5288175/pexels-photo-5288175.jpeg',
      ],
      'tags': ['Music', 'Guitar', 'Singing'],
    },
    {
      'name': 'Morgan',
      'age': 24,
      'bio': 'Nature explorer and animal friend.',
      'images': [
        'https://images.pexels.com/photos/12794137/pexels-photo-12794137.jpeg',
      ],
      'tags': ['Nature', 'Animals', 'Adventure'],
    },
  ];

  int _topCardIndex = 0;
  bool _swipeRight = false;
  bool _swipeLeft = false;

  void _onCardSwiped(bool isRight) {
    setState(() {
      if (_topCardIndex < _sampleProfiles.length - 1) {
        _topCardIndex++;
      } else {
        _topCardIndex = 0; // Loop for demo
      }
      _swipeRight = false;
      _swipeLeft = false;
    });
  }

  void _swipeCardRight() {
    setState(() {
      _swipeRight = true;
    });
  }

  void _swipeCardLeft() {
    setState(() {
      _swipeLeft = true;
    });
  }

  @override
  void initState() {
    super.initState();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Auto-switch images every 3 seconds
    _startImageTimer();
  }

  void _startImageTimer() {
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % (_sampleProfiles[_topCardIndex]['images'] as List).length;
        });
      }
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final double logoHeight = 40 + 20 + 30; // logo + top/bottom padding
    final double actionButtonsHeight = 70 + 40; // button size + vertical padding
    final double navbarHeight = 62 + 18; // navbar height + bottom padding

    return Scaffold(
      body: Stack(
        children: [
          // Dark gradient background
          Container(
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
          ),
          
          // Glowing particles
          _buildGlowingParticles(),
          
          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final cardHeight = availableHeight - (logoHeight + actionButtonsHeight + navbarHeight);

                return Column(
                  children: [
                    // App title
                    _buildAppTitle(),
                    
                    // Profile card area
                    SizedBox(
                      height: cardHeight > 0 ? cardHeight : 0,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: List.generate(5, (i) {
                            int reverseI = 4 - i;
                            int cardIndex = _topCardIndex + reverseI;
                            if (cardIndex >= _sampleProfiles.length) return const SizedBox.shrink();
                            // Top card is swipeable and has shadow
                            if (reverseI == 0) {
                              return _SwipeableMatchCard(
                                key: ValueKey(_topCardIndex),
                                profile: _sampleProfiles[cardIndex],
                                width: screenWidth * 0.9,
                                height: cardHeight,
                                onSwiped: _onCardSwiped,
                                swipeRight: _swipeRight,
                                swipeLeft: _swipeLeft,
                                showShadow: true,
                              );
                            } else {
                              // Stacked cards below, no shadow, no opacity
                              return Positioned(
                                top: reverseI * 10.0,
                                child: MatchCard(
                                  profile: _sampleProfiles[cardIndex],
                                  width: screenWidth * 0.9 - reverseI * 10,
                                  height: cardHeight - reverseI * 10,
                                  currentImageIndex: 0,
                                  // No shadow for these cards
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                    
                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      child: ActionButtons(
                        onSkip: () {
                          _showSnackBar('Skipped!', AppColors.textSecondaryLight);
                          _swipeCardLeft();
                        },
                        onSuperLike: () {
                          _showSnackBar('Super Liked! ⭐', Colors.blue);
                        },
                        onLike: () {
                          _showSnackBar('Liked! ❤️', AppColors.primaryLight);
                          _swipeCardRight();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(_particleController.value),
        );
      },
    );
  }

  Widget _buildAppTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LGBTinderLogo(height: 30),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 32,
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientInfo,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * 0.1 * i + animationValue * 100) % size.width;
      final y = (size.height * 0.1 * i + animationValue * 50) % size.height;
      final radius = (2 + (i % 3)).toDouble();
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Swipeable card wrapper
class _SwipeableMatchCard extends StatefulWidget {
  final Map<String, dynamic> profile;
  final double width;
  final double height;
  final void Function(bool isRight) onSwiped;
  final bool swipeRight;
  final bool swipeLeft;
  final bool showShadow;

  const _SwipeableMatchCard({
    Key? key,
    required this.profile,
    required this.width,
    required this.height,
    required this.onSwiped,
    this.swipeRight = false,
    this.swipeLeft = false,
    this.showShadow = true,
  }) : super(key: key);

  @override
  State<_SwipeableMatchCard> createState() => _SwipeableMatchCardState();
}

class _SwipeableMatchCardState extends State<_SwipeableMatchCard> with SingleTickerProviderStateMixin {
  late Offset _offset;
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _offset = Offset.zero;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
    _controller.addListener(() {
      setState(() {
        _offset = _animation.value;
      });
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_offset.dx.abs() > 100) {
          widget.onSwiped(_offset.dx > 0);
        } else {
          setState(() {
            _offset = Offset.zero;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant _SwipeableMatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.swipeRight && !oldWidget.swipeRight) {
      _animateSwipe(Offset(500, 0));
    } else if (widget.swipeLeft && !oldWidget.swipeLeft) {
      _animateSwipe(Offset(-500, 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_offset.dx.abs() > 100) {
      _animateSwipe(Offset(_offset.dx > 0 ? 500 : -500, _offset.dy));
    } else {
      _animateSwipe(Offset.zero);
    }
  }

  void _animateSwipe(Offset endOffset) {
    _animation = Tween<Offset>(
      begin: _offset,
      end: endOffset,
    ).animate(_controller);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: MatchCard(
          profile: widget.profile,
          width: widget.width,
          height: widget.height,
          currentImageIndex: 0,
          // Only top card has shadow
          // Pass a prop if you want to control shadow from here
        ),
      ),
    );
  }
} 