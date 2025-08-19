import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

enum MessageType {
  text,
  image,
  video,
  audio,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  error,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final bool isOutgoing;
  final String? mediaUrl;
  final String? mediaThumbnail;
  final Duration? mediaDuration;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.status,
    required this.isOutgoing,
    this.mediaUrl,
    this.mediaThumbnail,
    this.mediaDuration,
  });
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onMediaTap;
  final VoidCallback? onRetry;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    this.onMediaTap,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isOutgoing ? 64 : 16,
          right: message.isOutgoing ? 16 : 64,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: message.isOutgoing
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            _buildMessageContent(),
            const SizedBox(height: 4),
            _buildMessageFooter(),
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
        return _buildAudioMessage();
    }
  }

  Widget _buildTextMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isOutgoing
            ? AppColors.primaryLight
            : AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: AppTypography.bodyMediumStyle.copyWith(
          color: message.isOutgoing ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildImageMessage() {
    return GestureDetector(
      onTap: onMediaTap,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 240,
          maxHeight: 240,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.network(
                message.mediaUrl!,
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
              if (message.mediaThumbnail != null)
                Image.network(
                  message.mediaThumbnail!,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage() {
    return GestureDetector(
      onTap: onMediaTap,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 240,
          maxHeight: 240,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                message.mediaThumbnail!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.cardBackgroundLight,
                    child: Icon(
                      Icons.video_library,
                      size: 48,
                      color: AppColors.textSecondaryLight,
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              if (message.mediaDuration != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDuration(message.mediaDuration!),
                      style: AppTypography.bodySmallStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isOutgoing
            ? AppColors.primaryLight
            : AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: message.isOutgoing ? Colors.white : AppColors.primaryLight,
            size: 24,
          ),
          const SizedBox(width: 8),
          if (message.mediaDuration != null)
            Text(
              _formatDuration(message.mediaDuration!),
              style: AppTypography.bodyMediumStyle.copyWith(
                color: message.isOutgoing
                    ? Colors.white
                    : AppColors.textPrimaryLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageFooter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.timestamp),
          style: AppTypography.bodySmallStyle.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        if (message.isOutgoing) ...[
          const SizedBox(width: 4),
          _buildStatusIndicator(),
        ],
      ],
    );
  }

  Widget _buildStatusIndicator() {
    switch (message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 16,
          color: AppColors.textSecondaryLight,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 16,
          color: AppColors.textSecondaryLight,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 16,
          color: AppColors.primaryLight,
        );
      case MessageStatus.error:
        return GestureDetector(
          onTap: onRetry,
          child: Icon(
            Icons.error_outline,
            size: 16,
            color: AppColors.errorLight,
          ),
        );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
} 