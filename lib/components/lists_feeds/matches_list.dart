import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../avatar/animated_avatar.dart';

class Match {
  final String id;
  final String name;
  final String imageUrl;
  final bool isOnline;
  final DateTime lastSeen;
  final String lastMessage;
  final bool isNewMatch;

  const Match({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isOnline,
    required this.lastSeen,
    required this.lastMessage,
    this.isNewMatch = false,
  });
}

class MatchesList extends StatefulWidget {
  final List<Match> matches;
  final Function(Match) onMatchTap;
  final Function(Match) onMessageTap;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const MatchesList({
    Key? key,
    required this.matches,
    required this.onMatchTap,
    required this.onMessageTap,
    this.isLoading = false,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<MatchesList> createState() => _MatchesListState();
}

class _MatchesListState extends State<MatchesList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getLastSeenText(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.matches.length,
        itemBuilder: (context, index) {
          final match = widget.matches[index];
          return _MatchListItem(
            match: match,
            onTap: () => widget.onMatchTap(match),
            onMessageTap: () => widget.onMessageTap(match),
            lastSeenText: _getLastSeenText(match.lastSeen),
          );
        },
      ),
    );
  }
}

class _MatchListItem extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;
  final VoidCallback onMessageTap;
  final String lastSeenText;

  const _MatchListItem({
    required this.match,
    required this.onTap,
    required this.onMessageTap,
    required this.lastSeenText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                AnimatedAvatar(
                  imageUrl: match.imageUrl,
                  size: 60,
                  isNewMatch: match.isNewMatch,
                ),
                if (match.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        match.name,
                        style: AppTypography.titleMediumStyle,
                      ),
                      Text(
                        lastSeenText,
                        style: AppTypography.bodySmallStyle.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    match.lastMessage,
                    style: AppTypography.bodyMediumStyle.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: onMessageTap,
              icon: Icon(
                Icons.message,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 