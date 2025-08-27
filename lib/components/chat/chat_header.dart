import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ChatHeader extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onBackPressed;
  final VoidCallback? onInfoPressed;
  final VoidCallback? onCallPressed;

  const ChatHeader({
    Key? key,
    required this.chat,
    this.onBackPressed,
    this.onInfoPressed,
    this.onCallPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          
          // Avatar and info
          Expanded(
            child: GestureDetector(
              onTap: onInfoPressed,
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.greyLight,
                        ),
                        child: chat.displayAvatar != null
                            ? ClipOval(
                                child: Image.network(
                                  chat.displayAvatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildAvatarFallback();
                                  },
                                ),
                              )
                            : _buildAvatarFallback(),
                      ),
                      
                      // Online indicator
                      if (chat.participants.isNotEmpty && chat.participants.first.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.displayName,
                          style: AppTypography.subtitle2.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        if (chat.participants.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            chat.participants.first.statusText,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action buttons
          if (onCallPressed != null) ...[
            // Voice call button
            IconButton(
              onPressed: onCallPressed,
              icon: const Icon(Icons.call, size: 20),
              color: AppColors.primary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
            
            // Video call button
            IconButton(
              onPressed: onCallPressed,
              icon: const Icon(Icons.videocam, size: 20),
              color: AppColors.primary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ],
          
          // More options button
          IconButton(
            onPressed: onInfoPressed,
            icon: const Icon(Icons.more_vert, size: 20),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Icon(
        chat.isGroup ? Icons.group : Icons.person,
        size: 20,
        color: AppColors.textSecondary,
      ),
    );
  }
}
