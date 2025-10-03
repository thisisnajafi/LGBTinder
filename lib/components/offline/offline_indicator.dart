import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/offline_service.dart';
import '../../providers/connectivity_provider.dart';

/// A widget that shows the current network connectivity status
class OfflineIndicator extends StatelessWidget {
  final bool showWhenOnline;
  final bool showWhenOffline;
  final Duration animationDuration;
  final EdgeInsets padding;
  final Color? onlineColor;
  final Color? offlineColor;
  final String? onlineText;
  final String? offlineText;

  const OfflineIndicator({
    super.key,
    this.showWhenOnline = false,
    this.showWhenOffline = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.padding = const EdgeInsets.all(8.0),
    this.onlineColor,
    this.offlineColor,
    this.onlineText,
    this.offlineText,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        final isOnline = connectivityProvider.isOnline;
        
        // Don't show if conditions are not met
        if (isOnline && !showWhenOnline) return const SizedBox.shrink();
        if (!isOnline && !showWhenOffline) return const SizedBox.shrink();
        
        return AnimatedContainer(
          duration: animationDuration,
          padding: padding,
          color: isOnline 
              ? (onlineColor ?? AppColors.success.withOpacity(0.1))
              : (offlineColor ?? AppColors.warning.withOpacity(0.1)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                size: 16,
                color: isOnline 
                    ? (onlineColor ?? AppColors.success)
                    : (offlineColor ?? AppColors.warning),
              ),
              const SizedBox(width: 8),
              Text(
                isOnline 
                    ? (onlineText ?? 'Online')
                    : (offlineText ?? 'Offline'),
                style: AppTypography.caption.copyWith(
                  color: isOnline 
                      ? (onlineColor ?? AppColors.success)
                      : (offlineColor ?? AppColors.warning),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A banner that shows at the top of the screen when offline
class OfflineBanner extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const OfflineBanner({
    super.key,
    this.message,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        if (connectivityProvider.isOnline) {
          return const SizedBox.shrink();
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: backgroundColor ?? AppColors.warning,
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Icon(
                  icon ?? Icons.wifi_off,
                  color: textColor ?? Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message ?? 'You are currently offline. Some features may not be available.',
                    style: AppTypography.body2.copyWith(
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: textColor ?? Colors.white,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A widget that shows offline status in a card format
class OfflineStatusCard extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const OfflineStatusCard({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.retryText = 'Retry',
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        final isOnline = connectivityProvider.isOnline;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOnline 
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? (isOnline ? Icons.wifi : Icons.wifi_off),
                size: 48,
                color: isOnline 
                    ? AppColors.success
                    : AppColors.warning,
              ),
              const SizedBox(height: 16),
              Text(
                title ?? (isOnline ? 'Connected' : 'Offline'),
                style: AppTypography.heading3.copyWith(
                  color: textColor ?? AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message ?? (isOnline 
                    ? 'You are connected to the internet.'
                    : 'You are currently offline. Some features may not be available.'),
                style: AppTypography.body2.copyWith(
                  color: textColor ?? AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isOnline && onRetry != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    retryText!,
                    style: AppTypography.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A widget that shows a loading indicator when syncing offline data
class OfflineSyncIndicator extends StatelessWidget {
  final bool isSyncing;
  final String? message;
  final Color? color;
  final double size;

  const OfflineSyncIndicator({
    super.key,
    required this.isSyncing,
    this.message,
    this.color,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSyncing) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(width: 8),
            Text(
              message!,
              style: AppTypography.caption.copyWith(
                color: color ?? AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
