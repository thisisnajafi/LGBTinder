aimport 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/stripe_webhook_listener_service.dart';
import '../../providers/subscription_provider.dart';

/// Invoice Payment Handler
/// 
/// Handles invoice payment webhook events:
/// - invoice.payment_succeeded
/// - invoice.payment_failed
/// 
/// Features:
/// - Real-time invoice payment notifications
/// - Payment receipt display
/// - Failed payment recovery flow
/// - Invoice history tracking
class InvoicePaymentHandler extends StatefulWidget {
  final Widget child;

  const InvoicePaymentHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<InvoicePaymentHandler> createState() => _InvoicePaymentHandlerState();
}

class _InvoicePaymentHandlerState extends State<InvoicePaymentHandler> {
  final StripeWebhookListenerService _webhookService =
      StripeWebhookListenerService();
  StreamSubscription<InvoicePaymentEvent>? _invoicePaymentSubscription;

  @override
  void initState() {
    super.initState();
    _initializeHandler();
  }

  Future<void> _initializeHandler() async {
    await _webhookService.initialize();
    
    _invoicePaymentSubscription =
        _webhookService.invoicePaymentStream.listen((event) {
      _handleInvoicePaymentEvent(event);
    });
  }

  void _handleInvoicePaymentEvent(InvoicePaymentEvent event) {
    if (event.isPaid) {
      _handleInvoicePaymentSucceeded(event);
    } else if (event.isFailed) {
      _handleInvoicePaymentFailed(event);
    }

    // Refresh subscription state
    _refreshSubscriptionData();
  }

  void _handleInvoicePaymentSucceeded(InvoicePaymentEvent event) {
    _showInvoiceDialog(
      title: 'Payment Received',
      message: 'Your payment has been successfully processed',
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      event: event,
      showReceipt: true,
    );
  }

  void _handleInvoicePaymentFailed(InvoicePaymentEvent event) {
    _showInvoiceDialog(
      title: 'Payment Failed',
      message: event.errorMessage ?? 'We couldn\'t process your payment',
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      event: event,
      showUpdatePayment: true,
    );
  }

  void _showInvoiceDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required InvoicePaymentEvent event,
    bool showReceipt = false,
    bool showUpdatePayment = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InvoicePaymentDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        event: event,
        showReceipt: showReceipt,
        showUpdatePayment: showUpdatePayment,
      ),
    );
  }

  Future<void> _refreshSubscriptionData() async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    await subscriptionProvider.refreshSubscription();
  }

  @override
  void dispose() {
    _invoicePaymentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Invoice Payment Dialog
class InvoicePaymentDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final InvoicePaymentEvent event;
  final bool showReceipt;
  final bool showUpdatePayment;

  const InvoicePaymentDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.event,
    this.showReceipt = false,
    this.showUpdatePayment = false,
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

            // Invoice Number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Invoice #${event.invoiceNumber}',
                style: AppTypography.body2.copyWith(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Amount
            Text(
              '${event.amount.toStringAsFixed(2)} ${event.currency}',
              style: AppTypography.h2.copyWith(
                color: iconColor,
                fontWeight: FontWeight.bold,
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

            const SizedBox(height: 24),

            // Invoice Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Invoice ID', event.invoiceId),
                  const Divider(height: 16, color: Colors.white12),
                  _buildDetailRow('Status', _getStatusLabel(event.status)),
                  if (event.dueDate != null) ...[
                    const Divider(height: 16, color: Colors.white12),
                    _buildDetailRow('Due Date', _formatDate(event.dueDate)),
                  ],
                  const Divider(height: 16, color: Colors.white12),
                  _buildDetailRow('Date', _formatDate(event.timestamp)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (showUpdatePayment)
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
            else if (showReceipt)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _viewReceipt(context, event);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'View Receipt',
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
          style: AppTypography.caption.copyWith(
            color: Colors.white54,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Paid';
      case 'payment_failed':
        return 'Failed';
      case 'open':
        return 'Open';
      case 'void':
        return 'Void';
      case 'uncollectible':
        return 'Uncollectible';
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

  void _viewReceipt(BuildContext context, InvoicePaymentEvent event) {
    // Navigate to receipt screen or show receipt dialog
    Navigator.of(context).pushNamed(
      '/invoice-receipt',
      arguments: {'invoiceId': event.invoiceId},
    );
  }
}

/// Invoice Payment List Widget
/// 
/// Shows a list of recent invoice payments
class InvoicePaymentList extends StatefulWidget {
  const InvoicePaymentList({Key? key}) : super(key: key);

  @override
  State<InvoicePaymentList> createState() => _InvoicePaymentListState();
}

class _InvoicePaymentListState extends State<InvoicePaymentList> {
  final StripeWebhookListenerService _webhookService =
      StripeWebhookListenerService();
  StreamSubscription<InvoicePaymentEvent>? _subscription;
  final List<InvoicePaymentEvent> _invoiceHistory = [];

  @override
  void initState() {
    super.initState();
    _subscription = _webhookService.invoicePaymentStream.listen((event) {
      setState(() {
        _invoiceHistory.insert(0, event);
        // Keep only last 20 invoices
        if (_invoiceHistory.length > 20) {
          _invoiceHistory.removeLast();
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
    if (_invoiceHistory.isEmpty) {
      return Center(
        child: Text(
          'No invoice history',
          style: AppTypography.body2.copyWith(
            color: Colors.white54,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _invoiceHistory.length,
      itemBuilder: (context, index) {
        final invoice = _invoiceHistory[index];
        return InvoicePaymentCard(invoice: invoice);
      },
    );
  }
}

/// Invoice Payment Card
class InvoicePaymentCard extends StatelessWidget {
  final InvoicePaymentEvent invoice;

  const InvoicePaymentCard({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.isPaid;
    final statusColor = isPaid ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.error_outline,
              color: statusColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Invoice Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice #${invoice.invoiceNumber}',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${invoice.amount.toStringAsFixed(2)} ${invoice.currency}',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(invoice.timestamp),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isPaid ? 'Paid' : 'Failed',
              style: AppTypography.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

