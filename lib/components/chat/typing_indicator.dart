import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/colors.dart';

class TypingIndicator extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const TypingIndicator({
    Key? key,
    required this.chatId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            (index + 1) * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final typingIndicators = chatProvider.getTypingIndicators(widget.chatId);
        final otherTypingUsers = typingIndicators
            .where((indicator) => indicator['userId'] != widget.currentUserId)
            .toList();

        if (otherTypingUsers.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navbarBackground,
                ),
                                  child: ClipOval(
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
              ),
              
              // Typing bubble
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navbarBackground,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: const Radius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Typing text
                    Text(
                      _getTypingText(otherTypingUsers),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    
                    const SizedBox(width: 4),
                    
                    // Animated dots
                    Row(
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _dotAnimations[index],
                          builder: (context, child) {
                            return Container(
                              width: 4,
                              height: 4,
                              margin: EdgeInsets.only(
                                left: index > 0 ? 2 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                  0.3 + (_dotAnimations[index].value * 0.7),
                                ),
                                shape: BoxShape.circle,
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTypingText(List<Map<String, dynamic>> typingUsers) {
    if (typingUsers.isEmpty) return '';
    
    if (typingUsers.length == 1) {
      final userName = typingUsers.first['userId'] ?? 'Someone';
      return '$userName is typing';
    } else if (typingUsers.length == 2) {
      final user1 = typingUsers[0]['userId'] ?? 'Someone';
      final user2 = typingUsers[1]['userId'] ?? 'Someone';
      return '$user1 and $user2 are typing';
    } else {
      return 'Several people are typing';
    }
  }
}
