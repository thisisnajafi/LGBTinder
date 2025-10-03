import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/colors.dart';
import '../badges/notification_badge.dart';
import '../../services/haptic_feedback_service.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<int>? badgeCounts;

  const BottomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.badgeCounts,
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

  static const List<String> _labels = [
    'Discover',
    'Search',
    'Activity',
    'Messages',
    'Profile',
  ];

  static const List<String> _semanticLabels = [
    'Discover new matches',
    'Search for people',
    'View activity feed',
    'View messages',
    'View profile',
  ];

  static const List<String> _hints = [
    'Double tap to discover new matches',
    'Double tap to search for people',
    'Double tap to view activity feed',
    'Double tap to view messages',
    'Double tap to view profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Bottom navigation bar',
      hint: 'Navigate between main sections of the app',
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.navbarBackground.withOpacity(0.8),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.10),
                  width: 1.2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_iconPaths.length, (index) {
                    final badgeCount = badgeCounts != null && index < badgeCounts!.length 
                        ? badgeCounts![index] 
                        : 0;
                    
                    return AnimatedBuilder(
                      animation: AlwaysStoppedAnimation(currentIndex),
                      builder: (context, child) {
                        return _NavBarItem(
                          svgPath: _iconPaths[index],
                          label: _labels[index],
                          semanticLabel: _semanticLabels[index],
                          hint: _hints[index],
                          index: index,
                          currentIndex: currentIndex,
                          onTap: onTap,
                          activeColor: _activeColors[index],
                          badgeCount: badgeCount,
                        );
                      },
                    );
                  }),
                ),
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
  final String label;
  final String semanticLabel;
  final String hint;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;
  final int badgeCount;

  const _NavBarItem({
    required this.svgPath,
    required this.label,
    required this.semanticLabel,
    required this.hint,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;
    
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      selected: isActive,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: () {
            HapticFeedbackService.selection();
            onTap(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isActive 
                  ? activeColor.withOpacity(0.1) 
                  : Colors.transparent,
            ),
            child: NavbarBadge(
              count: badgeCount,
              child: AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.7,
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(
                    svgPath,
                    color: isActive ? activeColor : Colors.white.withOpacity(0.7),
                    width: isActive ? 28 : 24,
                    height: isActive ? 28 : 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}