import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/stripe_webhook_listener_service.dart';
import '../../providers/subscription_provider.dart';

/// Payment Intent Handler
/// 
/// Handles payment_intent.succeeded and payment_intent.failed webhook events
/// - Displays real-time payment status updates
/// - Shows success/failure notifications
/// - Updates subscription state
/// - Provides retry mechanism for failed payments
class PaymentIntentHandler extends StatefulWidget {
  final Widget child;

  const PaymentIntentHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PaymentIntentHandler> createState() => _PaymentIntentHandlerState();
}

class _PaymentIntentHandlerState extends State<PaymentIntentHandler> {
  final StripeWebhookListenerService _webhookService =
      StripeWebhookListenerService();
  StreamSubscription<PaymentIntentEvent>? _paymentIntentSubscription;

  @override
  void initState() {
    super.initState();
    _initializeHandler();
  }

  Future<void> _initializeHandler() async {
    await _webhookService.initialize();
    
    _paymentIntentSubscription =
        _webhookService.paymentIntentStream.listen((event) {
      _handlePaymentIntentEvent(event);
    });
  }

  void _handlePaymentIntentEvent(PaymentIntentEvent event) {
    if (event.isSuccessful) {
      _handlePaymentSuccess(event);
    } else if (event.isFailed) {
      _handlePaymentFailure(event);
    }
  }

  void _handlePaymentSuccess(PaymentIntentEvent event) {
    // Update subscription state
    final subscriptionProvider = context.read<SubscriptionProvider>();
    subscriptionProvider.refreshSubscription();

    // Show success dialog
    _showPaymentSuccessDialog(event);
  }

  void _handlePaymentFailure(PaymentIntentEvent event) {
    // Show failure dialog
    _showPaymentFailureDialog(event);
  }

  void _showPaymentSuccessDialog(PaymentIntentEvent event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentSuccessDialog(event: event),
    );
  }

  void _showPaymentFailureDialog(PaymentIntentEvent event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentFailureDialog(event: event),
    );
  }

  @override
  void dispose() {
    _paymentIntentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Payment Success Dialog
class PaymentSuccessDialog extends StatelessWidget {
  final PaymentIntentEvent event;

  const PaymentSuccessDialog({
    Key? key,
    required this.event,
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
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Payment Successful!',
              style: AppTypography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Amount
            Text(
              '${event.amount.toStringAsFixed(2)} ${event.currency}',
              style: AppTypography.h2.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Details
            Text(
              'Your payment has been processed successfully',
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Payment Intent ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ID: ${event.paymentIntentId}',
                style: AppTypography.caption.copyWith(
                  color: Colors.white54,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
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
}

/// Payment Failure Dialog
class PaymentFailureDialog extends StatelessWidget {
  final PaymentIntentEvent event;

  const PaymentFailureDialog({
    Key? key,
    required this.event,
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
            // Error Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Payment Failed',
              style: AppTypography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Amount
            Text(
              '${event.amount.toStringAsFixed(2)} ${event.currency}',
              style: AppTypography.h3.copyWith(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 16),

            // Error Message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Details:',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.errorMessage ?? 'Payment could not be processed',
                    style: AppTypography.body2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
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
                        'Update Payment',
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPaymentMethods(BuildContext context) {
    Navigator.of(context).pushNamed('/payment-methods');
  }
}

/// Payment Intent Status Widget
/// 
/// Shows a compact status indicator for recent payment intents
class PaymentIntentStatusWidget extends StatefulWidget {
  const PaymentIntentStatusWidget({Key? key}) : super(key: key);

  @override
  State<PaymentIntentStatusWidget> createState() =>
      _PaymentIntentStatusWidgetState();
}

class _PaymentIntentStatusWidgetState
    extends State<PaymentIntentStatusWidget> {
  final StripeWebhookListenerService _webhookService =
      StripeWebhookListenerService();
  StreamSubscription<PaymentIntentEvent>? _subscription;
  PaymentIntentEvent? _latestEvent;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _subscription = _webhookService.paymentIntentStream.listen((event) {
      setState(() {
        _latestEvent = event;
        _isVisible = true;
      });

      // Auto-hide after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
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

    final isSuccess = _latestEvent!.isSuccessful;

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSuccess
              ? AppColors.success.withOpacity(0.2)
              : AppColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSuccess
                ? AppColors.success.withOpacity(0.5)
                : AppColors.error.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error_outline,
              color: isSuccess ? AppColors.success : AppColors.error,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isSuccess ? 'Payment Successful' : 'Payment Failed',
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_latestEvent!.amount.toStringAsFixed(2)} ${_latestEvent!.currency}',
                    style: AppTypography.body2.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
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
}

