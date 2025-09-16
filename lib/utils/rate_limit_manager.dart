import 'package:flutter/material.dart';
import '../services/rate_limiting_service.dart';
import 'error_handler.dart';

class RateLimitManager {
  static final RateLimitManager _instance = RateLimitManager._internal();
  factory RateLimitManager() => _instance;
  RateLimitManager._internal();

  final RateLimitingService _rateLimitingService = RateLimitingService();

  /// Show rate limit exceeded dialog
  Future<void> showRateLimitDialog(
    BuildContext context,
    String endpoint, {
    String? userId,
    VoidCallback? onRetry,
  }) async {
    final remaining = _rateLimitingService.getRemainingRequests(endpoint, userId: userId);
    final timeUntilReset = _rateLimitingService.getTimeUntilReset(endpoint, userId: userId);
    
    if (remaining > 0) {
      // Not actually rate limited, just show info
      ErrorHandler.showInfoMessage(
        context,
        message: 'You have $remaining requests remaining for this action.',
      );
      return;
    }

    final minutes = (timeUntilReset.inSeconds / 60).ceil();
    final message = minutes > 0 
        ? 'You\'ve reached the rate limit for this action. Please wait $minutes minutes before trying again.'
        : 'You\'ve reached the rate limit for this action. Please wait a moment before trying again.';

    await ErrorHandler.showErrorDialog(
      context,
      title: 'Rate Limit Exceeded',
      message: message,
      actionText: onRetry != null ? 'Retry Later' : null,
      onAction: onRetry,
    );
  }

  /// Show rate limit exceeded snackbar
  void showRateLimitSnackBar(
    BuildContext context,
    String endpoint, {
    String? userId,
    VoidCallback? onRetry,
  }) {
    final remaining = _rateLimitingService.getRemainingRequests(endpoint, userId: userId);
    final timeUntilReset = _rateLimitingService.getTimeUntilReset(endpoint, userId: userId);
    
    if (remaining > 0) {
      ErrorHandler.showInfoMessage(
        context,
        message: '$remaining requests remaining',
      );
      return;
    }

    final minutes = (timeUntilReset.inSeconds / 60).ceil();
    final message = minutes > 0 
        ? 'Rate limit exceeded. Wait $minutes minutes.'
        : 'Rate limit exceeded. Please wait.';

    ErrorHandler.showErrorSnackBar(
      context,
      message: message,
      actionText: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }

  /// Check if action is allowed and show appropriate feedback
  bool checkAndShowFeedback(
    BuildContext context,
    String endpoint, {
    String? userId,
    bool showDialog = false,
    VoidCallback? onRetry,
  }) {
    final isAllowed = _rateLimitingService.isRequestAllowed(endpoint, userId: userId);
    
    if (!isAllowed) {
      if (showDialog) {
        showRateLimitDialog(context, endpoint, userId: userId, onRetry: onRetry);
      } else {
        showRateLimitSnackBar(context, endpoint, userId: userId, onRetry: onRetry);
      }
    }
    
    return isAllowed;
  }

  /// Get rate limit status for display
  Map<String, dynamic> getRateLimitStatus(String endpoint, {String? userId}) {
    final remaining = _rateLimitingService.getRemainingRequests(endpoint, userId: userId);
    final timeUntilReset = _rateLimitingService.getTimeUntilReset(endpoint, userId: userId);
    final isAllowed = _rateLimitingService.isRequestAllowed(endpoint, userId: userId);
    
    return {
      'endpoint': endpoint,
      'remaining': remaining,
      'time_until_reset_seconds': timeUntilReset.inSeconds,
      'time_until_reset_minutes': (timeUntilReset.inSeconds / 60).ceil(),
      'is_allowed': isAllowed,
      'next_allowed_time': _rateLimitingService.getNextAllowedRequestTime(endpoint, userId: userId),
    };
  }

  /// Show rate limit status in a bottom sheet
  void showRateLimitStatusSheet(BuildContext context, {String? userId}) {
    final allStatus = _rateLimitingService.getAllRateLimitStatus();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => RateLimitStatusSheet(
        rateLimitStatus: allStatus,
        userId: userId,
      ),
    );
  }

  /// Create a rate limit aware button
  Widget createRateLimitAwareButton({
    required String endpoint,
    required Widget child,
    required VoidCallback onPressed,
    String? userId,
    bool showFeedback = true,
    bool showDialog = false,
  }) {
    return Builder(
      builder: (context) {
        final isAllowed = _rateLimitingService.isRequestAllowed(endpoint, userId: userId);
        
        return Opacity(
          opacity: isAllowed ? 1.0 : 0.6,
          child: child,
        );
      },
    );
  }

  /// Create a rate limit aware future builder
  Future<T?> executeWithRateLimit<T>(
    String endpoint,
    Future<T> Function() operation, {
    String? userId,
    bool retryOnRateLimit = true,
    int maxRetries = 3,
  }) async {
    try {
      return await _rateLimitingService.makeRateLimitedRequest(
        endpoint,
        () async {
          final result = await operation();
          return http.Response('', 200); // Dummy response for rate limiting
        },
        userId: userId,
        retryOnRateLimit: retryOnRateLimit,
        maxRetries: maxRetries,
      ).then((_) => operation());
    } catch (e) {
      if (e is RateLimitException) {
        rethrow;
      }
      return null;
    }
  }

  /// Get rate limit progress indicator
  Widget getRateLimitProgressIndicator(
    String endpoint, {
    String? userId,
    double size = 20.0,
  }) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: Stream.periodic(const Duration(seconds: 1)).map((_) => getRateLimitStatus(endpoint, userId: userId)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: size, height: size);
        }
        
        final status = snapshot.data!;
        final remaining = status['remaining'] as int;
        final timeUntilReset = status['time_until_reset_seconds'] as int;
        final isAllowed = status['is_allowed'] as bool;
        
        if (isAllowed) {
          return Icon(
            Icons.check_circle,
            color: Colors.green,
            size: size,
          );
        } else {
          return Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: timeUntilReset > 0 ? 1.0 - (timeUntilReset / 60.0) : 1.0,
                strokeWidth: 2.0,
                size: size,
              ),
              Icon(
                Icons.timer,
                color: Colors.orange,
                size: size * 0.6,
              ),
            ],
          );
        }
      },
    );
  }

  /// Clear rate limit for testing
  void clearRateLimit(String endpoint, {String? userId}) {
    _rateLimitingService.clearRateLimit(endpoint, userId: userId);
  }

  /// Clear all rate limits
  void clearAllRateLimits() {
    _rateLimitingService.clearAllRateLimits();
  }

  /// Set custom rate limit
  void setCustomRateLimit(String endpoint, int requests, int windowMinutes) {
    _rateLimitingService.setCustomRateLimit(endpoint, requests, windowMinutes);
  }
}

/// Rate limit status sheet widget
class RateLimitStatusSheet extends StatelessWidget {
  final Map<String, Map<String, dynamic>> rateLimitStatus;
  final String? userId;

  const RateLimitStatusSheet({
    Key? key,
    required this.rateLimitStatus,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate Limit Status',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: rateLimitStatus.length,
              itemBuilder: (context, index) {
                final entry = rateLimitStatus.entries.elementAt(index);
                final endpoint = entry.key;
                final status = entry.value;
                
                return Card(
                  child: ListTile(
                    title: Text(endpoint),
                    subtitle: Text(
                      '${status['remaining']}/${status['limit']} remaining',
                    ),
                    trailing: status['is_allowed'] as bool
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.timer, color: Colors.orange),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  RateLimitManager().clearAllRateLimits();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
