import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class FeedPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onUserTap;

  const FeedPostCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          _buildPostContent(),
          _buildPostActions(),
          _buildPostStats(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    final user = post['user'] as Map<String, dynamic>? ?? {};
    final userAvatar = user['avatar_url'] as String?;
    final userName = user['first_name'] as String? ?? 'Unknown User';
    final createdAt = post['created_at'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: userAvatar != null
                  ? CachedNetworkImageProvider(userAvatar)
                  : null,
              child: userAvatar == null
                  ? const Icon(Icons.person, color: Colors.white70)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onUserTap,
                  child: Text(
                    userName,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatTimeAgo(createdAt),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onPressed: _showPostOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    final content = post['content'] as String? ?? '';
    final images = post['images'] as List<dynamic>? ?? [];
    final type = post['type'] as String? ?? 'text';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              content,
              style: AppTypography.body1.copyWith(
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (images.isNotEmpty) _buildPostImages(images),
      ],
    );
  }

  Widget _buildPostImages(List<dynamic> images) {
    if (images.length == 1) {
      return _buildSingleImage(images[0]);
    } else if (images.length == 2) {
      return _buildTwoImages(images);
    } else if (images.length >= 3) {
      return _buildMultipleImages(images);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSingleImage(dynamic image) {
    final imageUrl = image['url'] as String? ?? '';
    
    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.white24,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.white24,
            child: const Icon(
              Icons.image,
              color: Colors.white70,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoImages(List<dynamic> images) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildImageContainer(images[0], borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            )),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _buildImageContainer(images[1], borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleImages(List<dynamic> images) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildImageContainer(images[0], borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            )),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildImageContainer(images[1], borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                  )),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Stack(
                    children: [
                      _buildImageContainer(images[2], borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      )),
                      if (images.length > 3)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '+${images.length - 3}',
                              style: AppTypography.h4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(dynamic image, {required BorderRadius borderRadius}) {
    final imageUrl = image['url'] as String? ?? '';
    
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.white24,
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.white24,
          child: const Icon(
            Icons.image,
            color: Colors.white70,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildPostActions() {
    final isLiked = post['is_liked'] as bool? ?? false;
    final likesCount = post['likes_count'] as int? ?? 0;
    final commentsCount = post['comments_count'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onLike,
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  likesCount.toString(),
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: onComment,
            child: Row(
              children: [
                const Icon(
                  Icons.comment_outlined,
                  color: Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  commentsCount.toString(),
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onShare,
            child: const Icon(
              Icons.share_outlined,
              color: Colors.white70,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostStats() {
    final likesCount = post['likes_count'] as int? ?? 0;
    final commentsCount = post['comments_count'] as int? ?? 0;

    if (likesCount == 0 && commentsCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (likesCount > 0) ...[
            Text(
              '$likesCount ${likesCount == 1 ? 'like' : 'likes'}',
              style: AppTypography.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (commentsCount > 0) ...[
            Text(
              'View all $commentsCount ${commentsCount == 1 ? 'comment' : 'comments'}',
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPostOptions() {
    // TODO: Show post options (report, block, etc.)
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${(difference.inDays / 7).floor()}w ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}
