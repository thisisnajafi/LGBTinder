import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final VoidCallback? onLongPress;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isOwnMessage,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          mainAxisAlignment: isOwnMessage 
              ? MainAxisAlignment.end 
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isOwnMessage) ...[
              // Avatar for received messages
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greyLight,
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            
            // Message content
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Column(
                  crossAxisAlignment: isOwnMessage 
                      ? CrossAxisAlignment.end 
                      : CrossAxisAlignment.start,
                  children: [
                    // Message bubble
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isOwnMessage 
                            ? AppColors.primary 
                            : AppColors.greyLight,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomLeft: isOwnMessage 
                              ? const Radius.circular(16) 
                              : const Radius.circular(4),
                          bottomRight: isOwnMessage 
                              ? const Radius.circular(4) 
                              : const Radius.circular(16),
                        ),
                      ),
                      child: _buildMessageContent(),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Message info (time and status)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        
                        if (isOwnMessage) ...[
                          const SizedBox(width: 4),
                          _buildMessageStatus(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.video:
        return _buildVideoMessage();
      case MessageType.audio:
      case MessageType.voice:
        return _buildAudioMessage();
      case MessageType.file:
        return _buildFileMessage();
      case MessageType.location:
        return _buildLocationMessage();
      case MessageType.contact:
        return _buildContactMessage();
      case MessageType.sticker:
        return _buildStickerMessage();
      case MessageType.gif:
        return _buildGifMessage();
    }
  }

  Widget _buildTextMessage() {
    return Text(
      message.content,
      style: AppTypography.body2.copyWith(
        color: isOwnMessage ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildImageMessage() {
    if (message.attachments.isEmpty) {
      return _buildTextMessage();
    }

    final attachment = message.attachments.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            attachment.url,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                color: AppColors.greyLight,
                child: const Icon(
                  Icons.broken_image,
                  color: AppColors.textSecondary,
                ),
              );
            },
          ),
        ),
        
        // Caption
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.content,
            style: AppTypography.body2.copyWith(
              color: isOwnMessage ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoMessage() {
    if (message.attachments.isEmpty) {
      return _buildTextMessage();
    }

    final attachment = message.attachments.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video thumbnail
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  attachment.thumbnail ?? attachment.url,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.greyLight,
                      child: const Icon(
                        Icons.videocam,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
              
              // Play button
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              
              // Duration
              if (attachment.duration != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      attachment.durationText,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Caption
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.content,
            style: AppTypography.body2.copyWith(
              color: isOwnMessage ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAudioMessage() {
    if (message.attachments.isEmpty) {
      return _buildTextMessage();
    }

    final attachment = message.attachments.first;
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwnMessage 
            ? Colors.white.withOpacity(0.2) 
            : AppColors.greyMedium,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_arrow,
            color: isOwnMessage ? Colors.white : AppColors.textPrimary,
            size: 24,
          ),
          
          const SizedBox(width: 8),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Message',
                  style: AppTypography.caption.copyWith(
                    color: isOwnMessage ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                if (attachment.duration != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    attachment.durationText,
                    style: AppTypography.caption.copyWith(
                      color: isOwnMessage 
                          ? Colors.white.withOpacity(0.8) 
                          : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessage() {
    if (message.attachments.isEmpty) {
      return _buildTextMessage();
    }

    final attachment = message.attachments.first;
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwnMessage 
            ? Colors.white.withOpacity(0.2) 
            : AppColors.greyMedium,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            color: isOwnMessage ? Colors.white : AppColors.textPrimary,
            size: 24,
          ),
          
          const SizedBox(width: 8),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.displayName,
                  style: AppTypography.caption.copyWith(
                    color: isOwnMessage ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  attachment.fileSize,
                  style: AppTypography.caption.copyWith(
                    color: isOwnMessage 
                        ? Colors.white.withOpacity(0.8) 
                        : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage() {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: isOwnMessage 
            ? Colors.white.withOpacity(0.2) 
            : AppColors.greyMedium,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Map placeholder
          Container(
            width: 200,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          
          // Location name
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                message.content,
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMessage() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwnMessage 
            ? Colors.white.withOpacity(0.2) 
            : AppColors.greyMedium,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(width: 8),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact',
                  style: AppTypography.caption.copyWith(
                    color: isOwnMessage ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  message.content,
                  style: AppTypography.caption.copyWith(
                    color: isOwnMessage 
                        ? Colors.white.withOpacity(0.8) 
                        : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerMessage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.network(
        message.content,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.greyLight,
            child: const Icon(
              Icons.emoji_emotions,
              color: AppColors.textSecondary,
              size: 48,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGifMessage() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.network(
        message.content,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.greyLight,
            child: const Icon(
              Icons.gif,
              color: AppColors.textSecondary,
              size: 48,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageStatus() {
    IconData icon;
    Color color;
    
    switch (message.status) {
      case MessageStatus.sending:
        icon = Icons.schedule;
        color = AppColors.textSecondary;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = AppColors.textSecondary;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = AppColors.textSecondary;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = AppColors.primary;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = AppColors.error;
        break;
    }
    
    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      // Today: show time only
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else {
      // Other days: show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
