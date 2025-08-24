import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback? onLike;
  final VoidCallback? onSuperlike;
  final VoidCallback? onDislike;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final int? superlikeCount;
  final bool isOwnProfile;

  const ProfileActionButtons({
    Key? key,
    this.onLike,
    this.onSuperlike,
    this.onDislike,
    this.onReport,
    this.onBlock,
    this.superlikeCount,
    this.isOwnProfile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOwnProfile) {
      return const SizedBox.shrink(); // Don't show action buttons for own profile
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Dislike Button
              _buildActionButton(
                icon: Icons.close,
                color: Colors.red,
                onPressed: onDislike,
                tooltip: 'Dislike',
              ),
              // Like Button
              _buildActionButton(
                icon: Icons.favorite,
                color: Colors.green,
                onPressed: onLike,
                tooltip: 'Like',
                size: 60,
              ),
              // Superlike Button
              _buildActionButton(
                icon: Icons.star,
                color: Colors.blue,
                onPressed: onSuperlike,
                tooltip: 'Superlike',
                badge: superlikeCount?.toString(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Secondary Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Report Button
              _buildSecondaryButton(
                icon: Icons.flag,
                label: 'Report',
                onPressed: onReport,
                color: Colors.orange,
              ),
              // Block Button
              _buildSecondaryButton(
                icon: Icons.block,
                label: 'Block',
                onPressed: onBlock,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
    String? tooltip,
    double size = 50,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(size / 2),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: size * 0.4,
                ),
              ),
            ),
          ),
          // Badge for superlike count
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color,
                    width: 1,
                  ),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
