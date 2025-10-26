import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../theme/colors.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onSuperLike;
  final VoidCallback onLike;

  const ActionButtons({
    Key? key,
    required this.onSkip,
    required this.onSuperLike,
    required this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          svgPath: 'assets/icons/All/broken/close-circle.svg',
          color: AppColors.secondary, // Purple
          glowColor: AppColors.secondary.withOpacity(0.4),
          size: 60,
          onTap: onSkip,
          label: 'Skip',
        ),
        _buildSuperLikeButton(),
        _buildActionButton(
          svgPath: 'assets/icons/All/broken/heart.svg',
          color: AppColors.primaryLight, // Pink
          glowColor: AppColors.primaryLight.withOpacity(0.4),
          size: 60,
          onTap: onLike,
          label: 'Like',
        ),
      ],
    );
  }

  Widget _buildSuperLikeButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onSuperLike,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Lottie fire animation behind
              SizedBox(
                width: 90,
                height: 90,
                child: Lottie.asset(
                  'assets/animations/fire_flame.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to a simple animated container if Lottie fails
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.superLikeOrangeRed.withOpacity(0.3),
                            AppColors.superLikeOrange.withOpacity(0.2),
                            AppColors.superLikeGold.withOpacity(0.1),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Gradient button with fire effect
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.superLikeOrangeRed, // Orange-red
                      AppColors.superLikeOrange, // Orange
                      AppColors.superLikeGold, // Gold
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.superLikeGold,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.superLikeOrangeRed.withOpacity(0.6),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: AppColors.superLikeGold.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/All/broken/star-1.svg',
                    width: 35,
                    height: 35,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Super Like',
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String svgPath,
    required Color color,
    required Color glowColor,
    required double size,
    required VoidCallback onTap,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBackgroundDark, // Dark background
              border: Border.all(
                color: color,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: size * 0.4,
                height: size * 0.4,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
      ],
    );
  }
} 