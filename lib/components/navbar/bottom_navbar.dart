import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/colors.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static const List<String> _iconPaths = [
    'assets/icons/All/bold/heart.svg',
    'assets/icons/All/bold/search-normal.svg',
    'assets/icons/All/bold/activity.svg',
    'assets/icons/All/bold/message.svg',
    'assets/icons/All/bold/user.svg',
  ];

  static const List<Color> _activeColors = [
    AppColors.primaryLight, // Heart (pink)
    Colors.white,           // Search
    Colors.white,           // Feeds
    Colors.white,           // Message
    Colors.white,           // User
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18, left: 18, right: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.navbarBackground.withOpacity(0.7),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                            ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_iconPaths.length, (index) {
                  return _NavBarItem(
                    svgPath: _iconPaths[index],
                    index: index,
                    currentIndex: currentIndex,
                    onTap: onTap,
                    activeColor: _activeColors[index],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String svgPath;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;

  const _NavBarItem({
    required this.svgPath,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          svgPath,
          color: isActive ? activeColor : Colors.white.withOpacity(0.7),
          width: isActive ? 28 : 24,
          height: isActive ? 28 : 24,
        ),
      ),
    );
  }
}