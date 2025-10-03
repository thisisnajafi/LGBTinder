import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../providers/websocket_state_provider.dart';
import '../../models/api_models/common_models.dart';

/// A widget that shows real-time connection status
class RealTimeConnectionStatus extends StatelessWidget {
  final bool showWhenConnected;
  final bool showWhenDisconnected;
  final bool showWhenConnecting;
  final Duration animationDuration;
  final EdgeInsets padding;
  final Color? connectedColor;
  final Color? disconnectedColor;
  final Color? connectingColor;
  final String? connectedText;
  final String? disconnectedText;
  final String? connectingText;

  const RealTimeConnectionStatus({
    super.key,
    this.showWhenConnected = false,
    this.showWhenDisconnected = true,
    this.showWhenConnecting = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.padding = const EdgeInsets.all(8.0),
    this.connectedColor,
    this.disconnectedColor,
    this.connectingColor,
    this.connectedText,
    this.disconnectedText,
    this.connectingText,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketStateProvider>(
      builder: (context, websocketProvider, child) {
        final connectionState = websocketProvider.connectionState;
        
        // Don't show if conditions are not met
        if (connectionState == WebSocketConnectionState.connected && !showWhenConnected) {
          return const SizedBox.shrink();
        }
        if (connectionState == WebSocketConnectionState.disconnected && !showWhenDisconnected) {
          return const SizedBox.shrink();
        }
        if (connectionState == WebSocketConnectionState.connecting && !showWhenConnecting) {
          return const SizedBox.shrink();
        }
        
        return AnimatedContainer(
          duration: animationDuration,
          padding: padding,
          color: _getStatusColor(connectionState),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(connectionState),
              const SizedBox(width: 8),
              Text(
                _getStatusText(connectionState),
                style: AppTypography.caption.copyWith(
                  color: _getTextColor(connectionState),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.connected:
        return Icon(
          Icons.wifi,
          size: 16,
          color: connectedColor ?? AppColors.success,
        );
      case WebSocketConnectionState.disconnected:
        return Icon(
          Icons.wifi_off,
          size: 16,
          color: disconnectedColor ?? AppColors.error,
        );
      case WebSocketConnectionState.connecting:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              connectingColor ?? AppColors.warning,
            ),
          ),
        );
    }
  }

  Color _getStatusColor(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.connected:
        return (connectedColor ?? AppColors.success).withOpacity(0.1);
      case WebSocketConnectionState.disconnected:
        return (disconnectedColor ?? AppColors.error).withOpacity(0.1);
      case WebSocketConnectionState.connecting:
        return (connectingColor ?? AppColors.warning).withOpacity(0.1);
    }
  }

  Color _getTextColor(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.connected:
        return connectedColor ?? AppColors.success;
      case WebSocketConnectionState.disconnected:
        return disconnectedColor ?? AppColors.error;
      case WebSocketConnectionState.connecting:
        return connectingColor ?? AppColors.warning;
    }
  }

  String _getStatusText(WebSocketConnectionState state) {
    switch (state) {
      case WebSocketConnectionState.connected:
        return connectedText ?? 'Connected';
      case WebSocketConnectionState.disconnected:
        return disconnectedText ?? 'Disconnected';
      case WebSocketConnectionState.connecting:
        return connectingText ?? 'Connecting...';
    }
  }
}

/// A widget that shows real-time event notifications
class RealTimeEventNotification extends StatelessWidget {
  final WebSocketEvent event;
  final Duration displayDuration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const RealTimeEventNotification({
    super.key,
    required this.event,
    this.displayDuration = const Duration(seconds: 5),
    this.onTap,
    this.onDismiss,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon ?? _getEventIcon(event.type),
            color: textColor ?? AppColors.textPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getEventTitle(event.type),
                  style: AppTypography.subtitle2.copyWith(
                    color: textColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getEventMessage(event),
                  style: AppTypography.body2.copyWith(
                    color: textColor ?? AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              iconSize: 20,
              color: textColor ?? AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'message':
        return Icons.message;
      case 'match':
        return Icons.favorite;
      case 'like':
        return Icons.thumb_up;
      case 'typing':
        return Icons.edit;
      case 'online':
        return Icons.circle;
      case 'offline':
        return Icons.circle_outlined;
      default:
        return Icons.notifications;
    }
  }

  String _getEventTitle(String eventType) {
    switch (eventType) {
      case 'message':
        return 'New Message';
      case 'match':
        return 'New Match!';
      case 'like':
        return 'Someone Liked You';
      case 'typing':
        return 'Typing...';
      case 'online':
        return 'User Online';
      case 'offline':
        return 'User Offline';
      default:
        return 'Notification';
    }
  }

  String _getEventMessage(WebSocketEvent event) {
    switch (event.type) {
      case 'message':
        return 'You have a new message';
      case 'match':
        return 'You have a new match!';
      case 'like':
        return 'Someone liked your profile';
      case 'typing':
        return 'Someone is typing...';
      case 'online':
        return 'A user came online';
      case 'offline':
        return 'A user went offline';
      default:
        return 'Real-time update';
    }
  }
}

/// A widget that shows typing indicators
class TypingIndicator extends StatelessWidget {
  final List<String> typingUsers;
  final String? currentUserId;
  final Color? dotColor;
  final double dotSize;
  final Duration animationDuration;

  const TypingIndicator({
    super.key,
    required this.typingUsers,
    this.currentUserId,
    this.dotColor,
    this.dotSize = 8.0,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    if (typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    // Filter out current user
    final otherUsers = typingUsers.where((user) => user != currentUserId).toList();
    
    if (otherUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTypingDots(),
          const SizedBox(width: 8),
          Text(
            _getTypingText(otherUsers),
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return Row(
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: animationDuration,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: dotColor ?? AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  String _getTypingText(List<String> users) {
    if (users.length == 1) {
      return '${users.first} is typing...';
    } else if (users.length == 2) {
      return '${users.first} and ${users.last} are typing...';
    } else {
      return '${users.length} people are typing...';
    }
  }
}

/// A widget that shows online status
class OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final String? username;
  final double size;
  final Color? onlineColor;
  final Color? offlineColor;
  final bool showText;
  final String? onlineText;
  final String? offlineText;

  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.username,
    this.size = 12.0,
    this.onlineColor,
    this.offlineColor,
    this.showText = false,
    this.onlineText,
    this.offlineText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isOnline 
                ? (onlineColor ?? AppColors.success)
                : (offlineColor ?? AppColors.textSecondary),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
        if (showText && username != null) ...[
          const SizedBox(width: 8),
          Text(
            isOnline 
                ? (onlineText ?? 'Online')
                : (offlineText ?? 'Offline'),
            style: AppTypography.caption.copyWith(
              color: isOnline 
                  ? (onlineColor ?? AppColors.success)
                  : (offlineColor ?? AppColors.textSecondary),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// A widget that shows real-time message status
class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final double size;
  final Color? sentColor;
  final Color? deliveredColor;
  final Color? readColor;
  final Color? failedColor;

  const MessageStatusIndicator({
    super.key,
    required this.status,
    this.size = 16.0,
    this.sentColor,
    this.deliveredColor,
    this.readColor,
    this.failedColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: _buildStatusIcon(),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: size,
          color: sentColor ?? AppColors.textSecondary,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: size,
          color: deliveredColor ?? AppColors.textSecondary,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: size,
          color: readColor ?? AppColors.primary,
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: size,
          color: failedColor ?? AppColors.error,
        );
    }
  }
}

/// Message status enumeration
enum MessageStatus {
  sent,
  delivered,
  read,
  failed,
}
