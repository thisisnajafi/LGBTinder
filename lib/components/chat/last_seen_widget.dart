import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../models/user.dart';

/// Last Seen Widget
/// 
/// Displays user's last seen timestamp in a human-readable format
/// - Shows "Online" if user is currently online
/// - Shows relative time like "Last seen 5 minutes ago"
/// - Respects user's privacy settings
class LastSeenWidget extends StatelessWidget {
  final User? user;
  final bool isOnline;
  final DateTime? lastSeen;
  final TextStyle? style;
  final Color? onlineColor;
  final Color? offlineColor;
  final bool showOnlineDot;
  final double dotSize;

  const LastSeenWidget({
    Key? key,
    this.user,
    this.isOnline = false,
    this.lastSeen,
    this.style,
    this.onlineColor,
    this.offlineColor,
    this.showOnlineDot = true,
    this.dotSize = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use user's lastSeen if available, otherwise use provided lastSeen
    final effectiveLastSeen = user?.lastSeen ?? lastSeen;
    final effectiveIsOnline = user?.isOnline ?? isOnline;

    // Check if user allows showing last seen
    // (In production, check user's privacy settings)
    final showLastSeen = user?.settings?.showLastSeen ?? true;

    if (!showLastSeen && !effectiveIsOnline) {
      // Don't show last seen if privacy is enabled and user is offline
      return const SizedBox.shrink();
    }

    final defaultStyle = style ??
        AppTypography.caption.copyWith(
          color: Colors.white70,
          fontSize: 12,
        );

    final defaultOnlineColor = onlineColor ?? AppColors.success;
    final defaultOfflineColor = offlineColor ?? Colors.white54;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Online indicator dot
        if (showOnlineDot)
          Container(
            width: dotSize,
            height: dotSize,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: effectiveIsOnline ? defaultOnlineColor : defaultOfflineColor,
              shape: BoxShape.circle,
              boxShadow: effectiveIsOnline
                  ? [
                      BoxShadow(
                        color: defaultOnlineColor.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),

        // Status text
        Text(
          _getLastSeenText(effectiveIsOnline, effectiveLastSeen),
          style: defaultStyle.copyWith(
            color: effectiveIsOnline ? defaultOnlineColor : defaultOfflineColor,
          ),
        ),
      ],
    );
  }

  String _getLastSeenText(bool isOnline, DateTime? lastSeen) {
    if (isOnline) {
      return 'Online';
    }

    if (lastSeen == null) {
      return 'Offline';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Last seen $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Last seen $hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Last seen $days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Last seen $weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Last seen $months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Last seen $years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}

/// Last Seen Status Badge
/// 
/// A compact badge showing online/offline status with last seen time
/// Useful for chat lists and user cards
class LastSeenBadge extends StatelessWidget {
  final User? user;
  final bool isOnline;
  final DateTime? lastSeen;
  final double size;
  final Color? onlineColor;
  final Color? offlineColor;
  final bool showTooltip;

  const LastSeenBadge({
    Key? key,
    this.user,
    this.isOnline = false,
    this.lastSeen,
    this.size = 12,
    this.onlineColor,
    this.offlineColor,
    this.showTooltip = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveLastSeen = user?.lastSeen ?? lastSeen;
    final effectiveIsOnline = user?.isOnline ?? isOnline;

    final defaultOnlineColor = onlineColor ?? AppColors.success;
    final defaultOfflineColor = offlineColor ?? Colors.white30;

    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveIsOnline ? defaultOnlineColor : defaultOfflineColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: effectiveIsOnline
            ? [
                BoxShadow(
                  color: defaultOnlineColor.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );

    if (!showTooltip) {
      return badge;
    }

    return Tooltip(
      message: _getTooltipMessage(effectiveIsOnline, effectiveLastSeen),
      child: badge,
    );
  }

  String _getTooltipMessage(bool isOnline, DateTime? lastSeen) {
    if (isOnline) {
      return 'Online now';
    }

    if (lastSeen == null) {
      return 'Offline';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return 'Active just now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Active ${difference.inDays}d ago';
    } else {
      return 'Offline';
    }
  }
}

/// Last Seen Timestamp
/// 
/// Displays the exact last seen time
/// Useful for detailed user profiles
class LastSeenTimestamp extends StatelessWidget {
  final User? user;
  final DateTime? lastSeen;
  final TextStyle? style;
  final String prefix;

  const LastSeenTimestamp({
    Key? key,
    this.user,
    this.lastSeen,
    this.style,
    this.prefix = 'Last seen: ',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveLastSeen = user?.lastSeen ?? lastSeen;

    if (effectiveLastSeen == null) {
      return Text(
        '${prefix}Never',
        style: style ??
            AppTypography.caption.copyWith(
              color: Colors.white54,
            ),
      );
    }

    final formattedTime = _formatDateTime(effectiveLastSeen);

    return Text(
      '$prefix$formattedTime',
      style: style ??
          AppTypography.caption.copyWith(
            color: Colors.white70,
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today
      return 'Today at ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      // This week
      return '${_getDayOfWeek(dateTime)} at ${_formatTime(dateTime)}';
    } else {
      // Older
      return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    return '$day/$month/$year';
  }

  String _getDayOfWeek(DateTime dateTime) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dateTime.weekday - 1];
  }
}

