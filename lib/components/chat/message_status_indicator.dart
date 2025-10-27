import 'package:flutter/material.dart';
import '../../services/message_queue_service.dart';
import '../../theme/colors.dart';

/// Message Status Indicator
/// 
/// Shows visual indicators for message status:
/// - Sending: Single gray checkmark
/// - Sent: Single gray checkmark
/// - Delivered: Double gray checkmarks
/// - Read: Double blue checkmarks
/// - Failed: Red exclamation mark
class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final double size;
  final Color? readColor;

  const MessageStatusIndicator({
    Key? key,
    required this.status,
    this.size = 16,
    this.readColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return _buildSendingIndicator();
      
      case MessageStatus.sent:
        return _buildSentIndicator();
      
      case MessageStatus.delivered:
        return _buildDeliveredIndicator();
      
      case MessageStatus.read:
        return _buildReadIndicator();
      
      case MessageStatus.failed:
        return _buildFailedIndicator();
      
      case MessageStatus.unknown:
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSendingIndicator() {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildSentIndicator() {
    return Icon(
      Icons.check,
      size: size,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildDeliveredIndicator() {
    return Stack(
      children: [
        Icon(
          Icons.check,
          size: size,
          color: Colors.grey.shade400,
        ),
        Positioned(
          left: size * 0.3,
          child: Icon(
            Icons.check,
            size: size,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildReadIndicator() {
    final color = readColor ?? AppColors.primary;
    
    return Stack(
      children: [
        Icon(
          Icons.check,
          size: size,
          color: color,
        ),
        Positioned(
          left: size * 0.3,
          child: Icon(
            Icons.check,
            size: size,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFailedIndicator() {
    return Icon(
      Icons.error,
      size: size,
      color: AppColors.error,
    );
  }
}

/// Stream-based Message Status Indicator
/// 
/// Automatically updates when message status changes
class StreamMessageStatusIndicator extends StatelessWidget {
  final String messageId;
  final MessageStatus initialStatus;
  final double size;
  final Color? readColor;

  const StreamMessageStatusIndicator({
    Key? key,
    required this.messageId,
    required this.initialStatus,
    this.size = 16,
    this.readColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MessageStatusUpdate>(
      stream: MessageQueueService().statusStream,
      initialData: MessageStatusUpdate(
        messageId: messageId,
        status: initialStatus,
      ),
      builder: (context, snapshot) {
        // Only update if this is our message
        final update = snapshot.data;
        final status = update?.messageId == messageId 
            ? update!.status 
            : initialStatus;

        return MessageStatusIndicator(
          status: status,
          size: size,
          readColor: readColor,
        );
      },
    );
  }
}

