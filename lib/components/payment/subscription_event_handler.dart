import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/stripe_webhook_listener_service.dart';
import '../../providers/subscription_provider.dart';
import '../../services/feature_gate_service.dart';

/// Subscription Event Handler
/// 
/// Handles subscription webhook events:
/// - customer.subscription.created
/// - customer.subscription.updated
/// - customer.subscription.deleted
/// 
/// Features:
/// - Real-time subscription status updates
/// - Feature gate refresh on subscription changes
/// - User notifications for subscription events
/// - UI updates for subscription state
class SubscriptionEventHandler extends StatefulWidget {
  final Widget child;

  const SubscriptionEventHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SubscriptionEventHandler> createState() =>
      _SubscriptionEventHandlerState();
}

class _SubscriptionEventHandlerState extends State<SubscriptionEventHandler> {
  final StripeWebhookListenerService _webhookService =
      StripeWebhookListenerService();
  final FeatureGateService _featureGateService = FeatureGateService();
  StreamSubscription<SubscriptionEvent>? _subscriptionEventSubscription;

  @override
  void initState() {
    super.initState();
    _initializeHandler();
  }

  Future<void> _initializeHandler() async {
    await _webhookService.initialize();
    
    _subscriptionEventSubscription =
        _webhookService.subscriptionStream.listen((event) {
      _handleSubscriptionEvent(event);
    });
  }

  void _handleSubscriptionEvent(SubscriptionEvent event) {
    final status = event.subscriptionStatus;

    switch (status) {
      case SubscriptionStatus.active:
        _handleSubscriptionActive(event);
        break;
      case SubscriptionStatus.pastDue:
        _handleSubscriptionPastDue(event);
        break;
      case SubscriptionStatus.canceled:
        _handleSubscriptionCanceled(event);
        break;
      case SubscriptionStatus.unpaid:
        _handleSubscriptionUnpaid(event);
        break;
      case SubscriptionStatus.incomplete:
        _handleSubscriptionIncomplete(event);
        break;
    }

    // Refresh subscription state and feature gates
    _refreshSubscriptionData();
  }

  void _handleSubscriptionActive(SubscriptionEvent event) {
    // Show success notification
    _showSubscriptionDialog(
      title: 'Subscription Active',
      message: 'Your ${event.planName} subscription is now active!',
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      event: event,
    );
  }

  void _handleSubscriptionPastDue(SubscriptionEvent event) {
    // Show warning dialog
    _showSubscriptionDialog(
      title: 'Payment Required',
      message:
          'Your subscription payment is past due. Please update your payment method to continue.',
      icon: Icons.warning,
      iconColor: AppColors.warning,
      event: event,
      showUpdatePaymentButton: true,
    );
  }

  void _handleSubscriptionCanceled(SubscriptionEvent event) {
    // Show cancelation dialog
    _showSubscriptionDialog(
      title: 'Subscription Canceled',
      message: event.cancelAtPeriodEnd
          ? 'Your subscription will end on ${_formatDate(event.currentPeriodEnd)}. Premium features will be available until then.'
          : 'Your subscription has been canceled.',
      icon: Icons.cancel,
      iconColor: AppColors.error,
      event: event,
    );
  }

  void _handleSubscriptionUnpaid(SubscriptionEvent event) {
    // Show unpaid dialog
    _showSubscriptionDialog(
      title: 'Payment Failed',
      message:
          'We couldn\'t process your payment. Your subscription is currently unpaid.',
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      event: event,
      showUpdatePaymentButton: true,
    );
  }

  void _handleSubscriptionIncomplete(SubscriptionEvent event) {
    // Show incomplete dialog
    _showSubscriptionDialog(
      title: 'Action Required',
      message:
          'Your subscription setup is incomplete. Please complete the payment process.',
      icon: Icons.info_outline,
      iconColor: AppColors.warning,
      event: event,
      showUpdatePaymentButton: true,
    );
  }

  void _showSubscriptionDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required SubscriptionEvent event,
    bool showUpdatePaymentButton = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SubscriptionEventDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        event: event,
        showUpdatePaymentButton: showUpdatePaymentButton,
      ),
    );
  }

  Future<void> _refreshSubscriptionData() async {
    // Refresh subscription provider
    final subscriptionProvider = context.read<SubscriptionProvider>();
    await subscriptionProvider.refreshSubscription();

    // Refresh feature gates
    await _featureGateService.refreshPermissions();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _subscriptionEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Subscription Event Dialog
class SubscriptionEventDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final SubscriptionEvent event;
  final bool showUpdatePaymentButton;

  const SubscriptionEventDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.event,
    this.showUpdatePaymentButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: AppTypography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Plan Name Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.planName,
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message
            Text(
              message,
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Subscription Details
            _buildDetailRow('Amount', '${event.amount.toStringAsFixed(2)} ${event.currency}'),
            const SizedBox(height: 8),
            _buildDetailRow('Status', _getStatusLabel(event.status)),
            if (event.currentPeriodEnd != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Renewal Date', _formatDate(event.currentPeriodEnd)),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            if (showUpdatePaymentButton)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _navigateToPaymentMethods(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Update Payment Method',
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Close',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.body2.copyWith(
            color: Colors.white54,
          ),
        ),
        Text(
          value,
          style: AppTypography.body2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'past_due':
        return 'Past Due';
      case 'canceled':
        return 'Canceled';
      case 'unpaid':
        return 'Unpaid';
      case 'incomplete':
        return 'Incomplete';
      default:
        return status;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToPaymentMethods(BuildContext context) {
    Navigator.of(context).pushNamed('/payment-methods');
  }
}

/// Subscription Status Banner
/// 
/// Shows a banner for subscription status changes
class SubscriptionStatusBanner extends StatefulWidget {
  const SubscriptionStatusBanner({Key? key}) : super(key: key);

  @override
  State<SubscriptionStatusBanner> createState() =>
      _SubscriptionStatusBannerState();
}

class _SubscriptionStatusBannerState extends State<SubscriptionStatusBanner> {
  final StripeWebhookListenerService _webhookService =
      StripeWebhookListenerService();
  StreamSubscription<SubscriptionEvent>? _subscription;
  SubscriptionEvent? _latestEvent;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _subscription = _webhookService.subscriptionStream.listen((event) {
      setState(() {
        _latestEvent = event;
        _isVisible = true;
      });

      // Auto-hide after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _latestEvent == null) {
      return const SizedBox.shrink();
    }

    final status = _latestEvent!.subscriptionStatus;
    final color = _getStatusColor(status);

    return AnimatedSlide(
      offset: _isVisible ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(status),
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getStatusTitle(status),
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _latestEvent!.planName,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isVisible = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.pastDue:
        return AppColors.warning;
      case SubscriptionStatus.canceled:
        return AppColors.error;
      case SubscriptionStatus.unpaid:
        return AppColors.error;
      case SubscriptionStatus.incomplete:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Icons.check_circle;
      case SubscriptionStatus.pastDue:
        return Icons.warning;
      case SubscriptionStatus.canceled:
        return Icons.cancel;
      case SubscriptionStatus.unpaid:
        return Icons.error_outline;
      case SubscriptionStatus.incomplete:
        return Icons.info_outline;
    }
  }

  String _getStatusTitle(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Subscription Active';
      case SubscriptionStatus.pastDue:
        return 'Payment Past Due';
      case SubscriptionStatus.canceled:
        return 'Subscription Canceled';
      case SubscriptionStatus.unpaid:
        return 'Payment Required';
      case SubscriptionStatus.incomplete:
        return 'Action Required';
    }
  }
}

