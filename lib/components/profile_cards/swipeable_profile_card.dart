import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class SwipeableProfileCard extends StatefulWidget {
  final String name;
  final int age;
  final String bio;
  final List<String> images;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onSuperLike;

  const SwipeableProfileCard({
    Key? key,
    required this.name,
    required this.age,
    required this.bio,
    required this.images,
    required this.onLike,
    required this.onDislike,
    required this.onSuperLike,
  }) : super(key: key);

  @override
  State<SwipeableProfileCard> createState() => _SwipeableProfileCardState();
}

class _SwipeableProfileCardState extends State<SwipeableProfileCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pageController = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      // Swiped right (Like)
      _controller.forward().then((_) {
        widget.onLike();
        _controller.reverse();
      });
    } else if (details.primaryVelocity! < 0) {
      // Swiped left (Dislike)
      _controller.forward().then((_) {
        widget.onDislike();
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: widget.images.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    widget.images[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.cardBackgroundLight,
                                        child: Icon(
                                          Icons.image,
                                          size: 100,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.images.length,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentPage == index
                                          ? AppColors.primaryLight
                                          : AppColors.textSecondaryLight.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${widget.name}, ${widget.age}',
                                    style: AppTypography.titleLargeStyle,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.verified,
                                    color: AppColors.successLight,
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.bio,
                                style: AppTypography.bodyMediumStyle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _ActionButton(
                                    icon: Icons.close,
                                    color: AppColors.errorLight,
                                    onTap: widget.onDislike,
                                  ),
                                  _ActionButton(
                                    icon: Icons.star,
                                    color: AppColors.warningLight,
                                    onTap: widget.onSuperLike,
                                  ),
                                  _ActionButton(
                                    icon: Icons.favorite,
                                    color: AppColors.successLight,
                                    onTap: widget.onLike,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: color,
          size: 30,
        ),
      ),
    );
  }
} 