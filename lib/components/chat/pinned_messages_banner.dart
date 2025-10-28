import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/api_services/message_actions_api_service.dart';

/// Pinned Messages Banner
/// 
/// Shows pinned messages at the top of chat
/// Max 3 pinned messages per chat
class PinnedMessagesBanner extends StatelessWidget {
  final List<PinnedMessage> pinnedMessages;
  final Function(String messageId)? onTapMessage;
  final Function(String messageId)? onUnpin;

  const PinnedMessagesBanner({
    Key? key,
    required this.pinnedMessages,
    this.onTapMessage,
    this.onUnpin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pinnedMessages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        border: Border(
          bottom: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: Column(
        children: [
          ...pinnedMessages.map((message) => _buildPinnedMessageItem(message)),
        ],
      ),
    );
  }

  Widget _buildPinnedMessageItem(PinnedMessage message) {
    return InkWell(
      onTap: () => onTapMessage?.call(message.messageId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Pin icon
            Icon(
              Icons.push_pin,
              color: AppColors.primary,
              size: 20,
            ),
            
            const SizedBox(width: 12),
            
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderName,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.content,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Unpin button
            if (onUnpin != null)
              IconButton(
                onPressed: () => onUnpin!(message.messageId),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white54,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pin Message Dialog
/// 
/// Shows confirmation dialog when pinning a message
class PinMessageDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final int currentPinnedCount;

  const PinMessageDialog({
    Key? key,
    required this.onConfirm,
    this.currentPinnedCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canPin = currentPinnedCount < 3;

    return AlertDialog(
      backgroundColor: AppColors.cardBackgroundLight,
      title: Row(
        children: [
          Icon(
            Icons.push_pin,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Pin Message',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Text(
        canPin
            ? 'Pin this message to the top of the chat?\n\n$currentPinnedCount/3 messages currently pinned.'
            : 'Maximum 3 messages can be pinned. Please unpin a message first.',
        style: AppTypography.body1.copyWith(
          color: Colors.white70,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        if (canPin)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Pin',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
    int currentPinnedCount = 0,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => PinMessageDialog(
        onConfirm: onConfirm,
        currentPinnedCount: currentPinnedCount,
      ),
    );
  }
}

