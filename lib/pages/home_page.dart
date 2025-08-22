import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/colors.dart';
import '../components/navbar/lgbtinder_logo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _cardAnimationController;
  Timer? _imageTimer;
  int _currentImageIndex = 0;

  // Sample profiles for the stack
  final List<Map<String, dynamic>> _sampleProfiles = [
    {
      'name': 'Jessica Parker',
      'age': 28,
      'profession': 'Professional model',
      'location': 'Chicago, IL',
      'distance': '1 km',
      'bio': 'Cinema enthusiast, animal lover,\nand adventurer at heart',
      'images': [
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
      ],
      'tags': ['Cinema', 'Vegan', 'Traveler'],
    },
    {
      'name': 'Alex Johnson',
      'age': 25,
      'profession': 'Coffee enthusiast',
      'location': 'Chicago, IL',
      'distance': '2 km',
      'bio': 'Coffee lover, bookworm, and aspiring chef.',
      'images': [
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
      ],
      'tags': ['Coffee', 'Books', 'Cooking'],
    },
    {
      'name': 'Taylor Smith',
      'age': 30,
      'profession': 'Tech enthusiast',
      'location': 'Chicago, IL',
      'distance': '3 km',
      'bio': 'Runner, gamer, and tech enthusiast.',
      'images': [
        'https://images.pexels.com/photos/14679012/pexels-photo-14679012.jpeg',
        'https://images.pexels.com/photos/17399454/pexels-photo-17399454.jpeg',
        'https://images.pexels.com/photos/17399454/pexels-photo-17399454.jpeg',
      ],
      'tags': ['Running', 'Gaming', 'Tech'],
    },
    {
      'name': 'Jordan Lee',
      'age': 27,
      'profession': 'Musician',
      'location': 'Chicago, IL',
      'distance': '4 km',
      'bio': 'Music is life. Guitarist and singer.',
      'images': [
        'https://images.pexels.com/photos/5288175/pexels-photo-5288175.jpeg',
        'https://images.pexels.com/photos/27992044/pexels-photo-27992044.jpeg',
        'https://images.pexels.com/photos/31529785/pexels-photo-31529785.jpeg',
      ],
      'tags': ['Music', 'Guitar', 'Singing'],
    },
    {
      'name': 'Morgan Davis',
      'age': 24,
      'profession': 'Nature explorer',
      'location': 'Chicago, IL',
      'distance': '5 km',
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
  bool _isStackEmpty = false;
  Set<int> _loadedCardIndices = {0, 1, 2}; // Initially load first 3 cards

  @override
  void initState() {
    super.initState();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start first card animation after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cardAnimationController.forward();
    });

    // Auto-switch images every 3 seconds
    _startImageTimer();
  }

  void _onCardSwiped(bool isRight) {
    setState(() {
      if (_topCardIndex < _sampleProfiles.length - 1) {
        _topCardIndex++;
        
        // Lazy load next card image if not already loaded
        int nextCardToLoad = _topCardIndex + 2; // Load 2 cards ahead
        if (nextCardToLoad < _sampleProfiles.length && !_loadedCardIndices.contains(nextCardToLoad)) {
          _loadedCardIndices.add(nextCardToLoad);
        }
        
        // Start smooth animation for next card
        _cardAnimationController.forward(from: 0);
      } else {
        // Stack is finished
        _isStackEmpty = true;
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

  void _upgradePlan() {
    _showSnackBar('Upgrade feature coming soon! 🚀', AppColors.primaryLight);
    // Here you would typically navigate to upgrade screen
  }

  void _startImageTimer() {
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isStackEmpty && _topCardIndex < _sampleProfiles.length) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % (_sampleProfiles[_topCardIndex]['images'] as List).length;
        });
      }
    });
  }

  @override
  void dispose() {
    _particleController.dispose();
    _cardAnimationController.dispose();
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final double logoHeight = 40 + 20 + 30; // logo + top/bottom padding
    final double actionButtonsHeight = 70 + 40; // button size + vertical padding
    final double navbarHeight = 62 + 18; // navbar height + bottom padding

    return Scaffold(
      backgroundColor: colorScheme.background, // Use theme background
      body: Stack(
        children: [
          // Theme-aware gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.background,
                  colorScheme.surface.withValues(alpha: 0.3),
                  colorScheme.surface.withValues(alpha: 0.1),
                  colorScheme.background,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final cardHeight = availableHeight - (logoHeight + actionButtonsHeight + navbarHeight);

                return Column(
                  children: [
                    // App title with theme-aware styling
                    _buildAppTitle(context),
                    
                    // Profile card area
                    SizedBox(
                      height: cardHeight > 0 ? cardHeight : 0,
                      child: Center(
                        child: _isStackEmpty 
                          ? _buildEmptyStackMessage(context)
                          : AnimatedBuilder(
                              animation: _cardAnimationController,
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: List.generate(3, (i) { // Only show 3 cards max
                                    int reverseI = 2 - i;
                                    int cardIndex = _topCardIndex + reverseI;
                                    if (cardIndex >= _sampleProfiles.length) return const SizedBox.shrink();
                                    
                                    // Calculate animation offset for smooth transition
                                    double animationOffset = 0;
                                    if (reverseI == 0) {
                                      animationOffset = (1 - _cardAnimationController.value) * 20;
                                    }
                                    
                                    // Only show card if it's loaded
                                    if (!_loadedCardIndices.contains(cardIndex)) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    // Top card is swipeable
                                    if (reverseI == 0) {
                                      return Transform.translate(
                                        offset: Offset(0, animationOffset),
                                        child: _ModernSwipeableCard(
                                          key: ValueKey(_topCardIndex),
                                          profile: _sampleProfiles[cardIndex],
                                          width: screenWidth * 0.9,
                                          height: cardHeight,
                                          onSwiped: _onCardSwiped,
                                          swipeRight: _swipeRight,
                                          swipeLeft: _swipeLeft,
                                          currentImageIndex: _currentImageIndex,
                                        ),
                                      );
                                    } else {
                                      // Background cards - completely hidden behind top card
                                      return const SizedBox.shrink(); // Don't show background cards at all
                                    }
                                  }),
                                );
                              },
                            ),
                      ),
                    ),
                    
                    // Action buttons (only show if stack is not empty)
                    if (!_isStackEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        child: _buildModernActionButtons(context),
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

  Widget _buildModernActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pass button
        _buildActionButton(
          context: context,
          icon: Icons.close,
          color: colorScheme.outline,
          onTap: () {
            _showSnackBar('Passed!', colorScheme.outline);
            _swipeCardLeft();
          },
        ),
        
        // Super like button
        _buildActionButton(
          context: context,
          icon: Icons.star,
          color: AppColors.gradientInfo[0],
          onTap: () {
            _showSnackBar('Super Liked! ⭐', AppColors.gradientInfo[0]);
          },
        ),
        
        // Like button
        _buildActionButton(
          context: context,
          icon: Icons.favorite,
          color: AppColors.errorLight,
          onTap: () {
            _showSnackBar('Liked! ❤️', AppColors.errorLight);
            _swipeCardRight();
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildEmptyStackMessage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Message
          Text(
            'Your Daily Matches are Finished',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.onBackground,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'You\'ve seen all your matches for today.\nUpgrade your plan to see more profiles!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onBackground.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Upgrade button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: AppColors.lgbtGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: _upgradePlan,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Upgrade Plan to See More',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                color: colorScheme.onSurface,
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
      ..color = AppColors.primaryLight.withValues(alpha: 0.1)
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

// Modern swipeable card wrapper
class _ModernSwipeableCard extends StatefulWidget {
  final Map<String, dynamic> profile;
  final double width;
  final double height;
  final void Function(bool isRight) onSwiped;
  final bool swipeRight;
  final bool swipeLeft;
  final int currentImageIndex;

  const _ModernSwipeableCard({
    Key? key,
    required this.profile,
    required this.width,
    required this.height,
    required this.onSwiped,
    this.swipeRight = false,
    this.swipeLeft = false,
    required this.currentImageIndex,
  }) : super(key: key);

  @override
  State<_ModernSwipeableCard> createState() => _ModernSwipeableCardState();
}

class _ModernSwipeableCardState extends State<_ModernSwipeableCard> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant _ModernSwipeableCard oldWidget) {
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
        child: _ModernCard(
          profile: widget.profile,
          width: widget.width,
          height: widget.height,
          currentImageIndex: widget.currentImageIndex,
        ),
      ),
    );
  }
}

// Modern card design with cached images and theme support
class _ModernCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final double width;
  final double height;
  final int currentImageIndex;

  const _ModernCard({
    Key? key,
    required this.profile,
    required this.width,
    required this.height,
    required this.currentImageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final images = profile['images'] as List;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Profile image with caching
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: images[currentImageIndex % images.length],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: colorScheme.surface,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: colorScheme.surface,
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: colorScheme.outline,
                  ),
                ),
                memCacheWidth: 800, // Optimize memory usage
                memCacheHeight: 1200,
                maxWidthDiskCache: 800,
                maxHeightDiskCache: 1200,
              ),
            ),
            
            // Distance badge
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      profile['distance'] ?? '1 km',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Profile info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      profile['name'] ?? 'Unknown',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Profession
                    Text(
                      profile['profession'] ?? 'Professional',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Image pagination dots
                    if (images.length > 1)
                      Row(
                        children: List.generate(images.length, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == (currentImageIndex % images.length)
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 