import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/offline_service.dart';
import '../../theme/app_colors.dart';
import 'offline_indicator.dart';

/// A wrapper widget that provides offline functionality to its child
class OfflineWrapper extends StatelessWidget {
  final Widget child;
  final bool showOfflineBanner;
  final bool showOfflineIndicator;
  final String? offlineMessage;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const OfflineWrapper({
    super.key,
    required this.child,
    this.showOfflineBanner = true,
    this.showOfflineIndicator = false,
    this.offlineMessage,
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
        return Column(
          children: [
            if (showOfflineBanner)
              OfflineBanner(
                message: offlineMessage,
                backgroundColor: backgroundColor,
                textColor: textColor,
                icon: icon,
                onTap: onRetry,
              ),
            Expanded(
              child: Stack(
                children: [
                  this.child,
                  if (showOfflineIndicator)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: OfflineIndicator(
                        showWhenOnline: true,
                        showWhenOffline: true,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A widget that shows different content based on connectivity status
class ConnectivityAwareWidget extends StatelessWidget {
  final Widget onlineChild;
  final Widget offlineChild;
  final bool showLoadingWhileChecking;
  final Widget? loadingChild;

  const ConnectivityAwareWidget({
    super.key,
    required this.onlineChild,
    required this.offlineChild,
    this.showLoadingWhileChecking = false,
    this.loadingChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        // Show loading while checking connectivity
        if (showLoadingWhileChecking && !connectivityProvider.isInitialized) {
          return loadingChild ?? const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        // Show appropriate content based on connectivity
        return connectivityProvider.isOnline ? onlineChild : offlineChild;
      },
    );
  }
}

/// A widget that executes a function with offline support
class OfflineAwareFunction extends StatelessWidget {
  final String cacheKey;
  final Future<Widget> Function() onlineFunction;
  final Widget Function() offlineFunction;
  final Duration? cacheExpiry;
  final bool forceRefresh;
  final Widget? loadingChild;
  final Widget? errorChild;

  const OfflineAwareFunction({
    super.key,
    required this.cacheKey,
    required this.onlineFunction,
    required this.offlineFunction,
    this.cacheExpiry,
    this.forceRefresh = false,
    this.loadingChild,
    this.errorChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        return FutureBuilder<Widget>(
          future: connectivityProvider.executeWithOfflineSupport(
            cacheKey: cacheKey,
            onlineFunction: onlineFunction,
            offlineFunction: offlineFunction,
            cacheExpiry: cacheExpiry,
            forceRefresh: forceRefresh,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadingChild ?? const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (snapshot.hasError) {
              return errorChild ?? Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            
            return snapshot.data ?? offlineFunction();
          },
        );
      },
    );
  }
}

/// A widget that shows a retry button when offline
class OfflineRetryButton extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? retryText;
  final ButtonStyle? style;
  final bool showWhenOnline;
  final bool showWhenOffline;

  const OfflineRetryButton({
    super.key,
    this.onRetry,
    this.retryText = 'Retry',
    this.style,
    this.showWhenOnline = false,
    this.showWhenOffline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        final isOnline = connectivityProvider.isOnline;
        
        // Don't show if conditions are not met
        if (isOnline && !showWhenOnline) return const SizedBox.shrink();
        if (!isOnline && !showWhenOffline) return const SizedBox.shrink();
        
        return ElevatedButton(
          onPressed: onRetry,
          style: style ?? ElevatedButton.styleFrom(
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
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

/// A widget that shows offline status in a compact format
class OfflineStatusCompact extends StatelessWidget {
  final String? onlineText;
  final String? offlineText;
  final Color? onlineColor;
  final Color? offlineColor;
  final IconData? onlineIcon;
  final IconData? offlineIcon;
  final double iconSize;
  final double fontSize;

  const OfflineStatusCompact({
    super.key,
    this.onlineText,
    this.offlineText,
    this.onlineColor,
    this.offlineColor,
    this.onlineIcon,
    this.offlineIcon,
    this.iconSize = 16.0,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        final isOnline = connectivityProvider.isOnline;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline 
                  ? (onlineIcon ?? Icons.wifi)
                  : (offlineIcon ?? Icons.wifi_off),
              size: iconSize,
              color: isOnline 
                  ? (onlineColor ?? AppColors.success)
                  : (offlineColor ?? AppColors.warning),
            ),
            const SizedBox(width: 4),
            Text(
              isOnline 
                  ? (onlineText ?? 'Online')
                  : (offlineText ?? 'Offline'),
              style: TextStyle(
                fontSize: fontSize,
                color: isOnline 
                    ? (onlineColor ?? AppColors.success)
                    : (offlineColor ?? AppColors.warning),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
