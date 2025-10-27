import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Message Reaction Bar
/// 
/// Shows quick reaction options when long-pressing a message
/// Quick reactions: ❤️, 😂, 😮, 😢, 👍, 👎
class MessageReactionBar extends StatelessWidget {
  final Function(String) onReactionSelected;
  final Function()? onMoreReactions;
  final List<String> quickReactions;

  const MessageReactionBar({
    Key? key,
    required this.onReactionSelected,
    this.onMoreReactions,
    this.quickReactions = const ['❤️', '😂', '😮', '😢', '👍', '👎'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick reactions
          ...quickReactions.map((emoji) => _buildReactionButton(emoji)),
          
          // More reactions button
          if (onMoreReactions != null) ...[
            const SizedBox(width: 4),
            Container(
              width: 1,
              height: 24,
              color: Colors.white24,
            ),
            const SizedBox(width: 4),
            _buildMoreButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildReactionButton(String emoji) {
    return GestureDetector(
      onTap: () => onReactionSelected(emoji),
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return GestureDetector(
      onTap: onMoreReactions,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  /// Show reaction bar above a widget
  static Future<String?> show(
    BuildContext context, {
    required Offset position,
    required Function(String) onReactionSelected,
    Function()? onMoreReactions,
    List<String>? quickReactions,
  }) async {
    String? selectedReaction;

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          // Tap anywhere to dismiss
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          
          // Reaction bar
          Positioned(
            left: position.dx - 150,
            top: position.dy - 60,
            child: MessageReactionBar(
              quickReactions: quickReactions ?? const ['❤️', '😂', '😮', '😢', '👍', '👎'],
              onReactionSelected: (reaction) {
                selectedReaction = reaction;
                onReactionSelected(reaction);
                Navigator.pop(context);
              },
              onMoreReactions: onMoreReactions,
            ),
          ),
        ],
      ),
    );

    return selectedReaction;
  }
}

/// Message Reaction Display
/// 
/// Shows reactions on a message with counts
class MessageReactionDisplay extends StatelessWidget {
  final Map<String, int> reactions; // emoji -> count
  final Function(String)? onReactionTap;
  final int maxDisplayed;

  const MessageReactionDisplay({
    Key? key,
    required this.reactions,
    this.onReactionTap,
    this.maxDisplayed = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by count descending
    final sortedReactions = reactions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top reactions
    final displayedReactions = sortedReactions.take(maxDisplayed).toList();
    final remainingCount = reactions.length - displayedReactions.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        // Display top reactions
        ...displayedReactions.map((entry) {
          return _buildReactionChip(
            emoji: entry.key,
            count: entry.value,
            onTap: onReactionTap != null
                ? () => onReactionTap!(entry.key)
                : null,
          );
        }),
        
        // More reactions indicator
        if (remainingCount > 0)
          _buildMoreChip(remainingCount),
      ],
    );
  }

  Widget _buildReactionChip({
    required String emoji,
    required int count,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            if (count > 1) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoreChip(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '+$count',
        style: AppTypography.body2.copyWith(
          color: Colors.white54,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Reaction Users Bottom Sheet
/// 
/// Shows who reacted with each emoji
class ReactionUsersBottomSheet extends StatelessWidget {
  final Map<String, List<ReactionUser>> reactionUsers; // emoji -> users

  const ReactionUsersBottomSheet({
    Key? key,
    required this.reactionUsers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Reactions',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const Divider(color: Colors.white24),
          
          // Reactions list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reactionUsers.length,
              itemBuilder: (context, index) {
                final emoji = reactionUsers.keys.elementAt(index);
                final users = reactionUsers[emoji]!;
                
                return _buildReactionSection(emoji, users);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionSection(String emoji, List<ReactionUser> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                '${users.length}',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // Users list
        ...users.map((user) => ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          title: Text(
            user.name,
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          subtitle: user.timestamp != null
              ? Text(
                  _formatTimestamp(user.timestamp!),
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                )
              : null,
        )),
        
        const Divider(color: Colors.white24),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Show reaction users bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Map<String, List<ReactionUser>> reactionUsers,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ReactionUsersBottomSheet(
        reactionUsers: reactionUsers,
      ),
    );
  }
}

/// Reaction User Model
class ReactionUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime? timestamp;

  ReactionUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.timestamp,
  });
}

