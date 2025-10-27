import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Message Reply Widget
/// 
/// Shows the message being replied to in the input area
class MessageReplyWidget extends StatelessWidget {
  final ReplyMessage replyMessage;
  final VoidCallback onCancel;

  const MessageReplyWidget({
    Key? key,
    required this.replyMessage,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Replying to text
                Row(
                  children: [
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Replying to ${replyMessage.senderName}',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Original message preview
                Text(
                  replyMessage.content,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Cancel button
          IconButton(
            onPressed: onCancel,
            icon: const Icon(
              Icons.close,
              color: Colors.white70,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Message Reply Display (in message bubble)
/// 
/// Shows the quoted message inside a message bubble
class MessageReplyDisplay extends StatelessWidget {
  final ReplyMessage replyMessage;
  final VoidCallback? onTap;
  final bool isOwnMessage;

  const MessageReplyDisplay({
    Key? key,
    required this.replyMessage,
    this.onTap,
    this.isOwnMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isOwnMessage
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isOwnMessage
                  ? Colors.white.withOpacity(0.5)
                  : AppColors.primary.withOpacity(0.5),
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name
            Text(
              replyMessage.senderName,
              style: AppTypography.body2.copyWith(
                color: isOwnMessage
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Message content
            Text(
              replyMessage.content,
              style: AppTypography.body2.copyWith(
                color: isOwnMessage
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipeable Message Wrapper
/// 
/// Wraps a message to enable swipe-to-reply gesture
class SwipeableMessage extends StatefulWidget {
  final Widget child;
  final Function()? onReply;
  final bool enableSwipe;

  const SwipeableMessage({
    Key? key,
    required this.child,
    this.onReply,
    this.enableSwipe = true,
  }) : super(key: key);

  @override
  State<SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<SwipeableMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _dragDistance = 0;
  static const double _swipeThreshold = 80;
  static const double _maxSwipe = 100;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.2, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.enableSwipe) return;

    setState(() {
      _dragDistance += details.delta.dx;
      _dragDistance = _dragDistance.clamp(0, _maxSwipe);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!widget.enableSwipe) return;

    if (_dragDistance >= _swipeThreshold) {
      // Trigger reply
      widget.onReply?.call();
      
      // Animate reply icon
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }

    setState(() {
      _dragDistance = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // Reply icon (shown when swiping)
          if (_dragDistance > 20)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: (_dragDistance / _swipeThreshold).clamp(0, 1),
                  duration: const Duration(milliseconds: 100),
                  child: Icon(
                    Icons.reply,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          
          // Message content
          AnimatedSlide(
            offset: Offset(_dragDistance / 500, 0),
            duration: const Duration(milliseconds: 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// Reply Message Model
class ReplyMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String? mediaUrl;
  final String? mediaType;

  ReplyMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.mediaUrl,
    this.mediaType,
  });

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'sender_name': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'media_url': mediaUrl,
      'media_type': mediaType,
    };
  }

  factory ReplyMessage.fromJson(Map<String, dynamic> json) {
    return ReplyMessage(
      messageId: json['message_id'].toString(),
      senderId: json['sender_id'].toString(),
      senderName: json['sender_name'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
    );
  }
}

