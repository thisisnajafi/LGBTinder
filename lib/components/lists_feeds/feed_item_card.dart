import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../avatar/animated_avatar.dart';

class FeedItem {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  final String? location;
  final DateTime timestamp;
  final String caption;
  final List<String> images;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;

  const FeedItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    this.location,
    required this.timestamp,
    required this.caption,
    required this.images,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
    this.isSaved = false,
  });
}

class FeedItemCard extends StatefulWidget {
  final FeedItem item;
  final Function(String) onLike;
  final Function(String) onComment;
  final Function(String) onShare;
  final Function(String) onSave;
  final Function(String) onUserTap;
  final Function(String, int) onImageTap;

  const FeedItemCard({
    Key? key,
    required this.item,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    required this.onUserTap,
    required this.onImageTap,
  }) : super(key: key);

  @override
  State<FeedItemCard> createState() => _FeedItemCardState();
}

class _FeedItemCardState extends State<FeedItemCard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getTimeAgo() {
    final difference = DateTime.now().difference(widget.item.timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: GestureDetector(
              onTap: () => widget.onUserTap(widget.item.userId),
              child: AnimatedAvatar(
                imageUrl: widget.item.userImageUrl,
                size: 40,
              ),
            ),
            title: Text(
              widget.item.userName,
              style: AppTypography.titleMediumStyle,
            ),
            subtitle: Row(
              children: [
                if (widget.item.location != null) ...[
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.item.location!,
                    style: AppTypography.bodySmallStyle.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _getTimeAgo(),
                  style: AppTypography.bodySmallStyle.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Show options menu
              },
            ),
          ),

          // Image Gallery
          if (widget.item.images.isNotEmpty)
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.item.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => widget.onImageTap(widget.item.id, index),
                        child: Image.network(
                          widget.item.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.cardBackgroundLight,
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: AppColors.textSecondaryLight,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  if (widget.item.images.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.item.images.length,
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

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _ActionButton(
                  icon: widget.item.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.item.isLiked
                      ? AppColors.errorLight
                      : AppColors.textPrimaryLight,
                  count: widget.item.likeCount,
                  onTap: () => widget.onLike(widget.item.id),
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  count: widget.item.commentCount,
                  onTap: () => widget.onComment(widget.item.id),
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.share_outlined,
                  onTap: () => widget.onShare(widget.item.id),
                ),
                const Spacer(),
                _ActionButton(
                  icon: widget.item.isSaved
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  onTap: () => widget.onSave(widget.item.id),
                ),
              ],
            ),
          ),

          // Caption
          if (widget.item.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.item.caption,
                style: AppTypography.bodyMediumStyle,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final int? count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.color,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppColors.textPrimaryLight,
              size: 24,
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: AppTypography.bodyMediumStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 