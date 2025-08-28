import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ChatListItem({
    Key? key,
    required this.chat,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 12),
              
              // Chat Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row (name, time, pin indicator)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.displayName,
                            style: AppTypography.subtitle2.copyWith(
                              color: Colors.white,
                              fontWeight: chat.hasUnreadMessages 
                                  ? FontWeight.w600 
                                  : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (chat.isPinned)
                          Icon(
                            Icons.push_pin,
                            size: 16,
                            color: AppColors.primaryLight,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          chat.timeAgo,
                          style: AppTypography.caption.copyWith(
                            color: chat.hasUnreadMessages 
                                ? AppColors.primaryLight 
                                : Colors.white.withOpacity(0.7),
                            fontWeight: chat.hasUnreadMessages 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Message preview row
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Message status indicator
                              if (chat.lastMessage != null) ...[
                                _buildMessageStatus(),
                                const SizedBox(width: 4),
                              ],
                              
                              // Message preview
                              Expanded(
                                child: Text(
                                  chat.lastMessagePreview,
                                  style: AppTypography.body2.copyWith(
                                    color: chat.hasUnreadMessages 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.7),
                                    fontWeight: chat.hasUnreadMessages 
                                        ? FontWeight.w500 
                                        : FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Unread count
                        if (chat.hasUnreadMessages)
                          _buildUnreadBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        // Avatar image
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.navbarBackground,
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
              width: 14,
              height: 14,
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
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Icon(
        chat.isGroup ? Icons.group : Icons.person,
        size: 24,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildMessageStatus() {
    if (chat.lastMessage == null) return const SizedBox.shrink();
    
    final message = chat.lastMessage!;
    final isOwnMessage = message.senderId == 'currentUserId'; // Replace with actual current user ID
    
    if (!isOwnMessage) return const SizedBox.shrink();
    
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = Colors.white.withOpacity(0.7);
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.white.withOpacity(0.7);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.white.withOpacity(0.7);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppColors.primaryLight;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = AppColors.error;
        break;
    }
    
    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Center(
        child: Text(
          chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
          style: AppTypography.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
