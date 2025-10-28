import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../services/auth_service.dart';
import '../models/subscription_models.dart';

/// Stripe Webhook Listener Service
/// 
/// Listens for Stripe webhook events processed by the backend
/// and updates the app state accordingly.
/// 
/// Webhook Events Handled:
/// - payment_intent.succeeded
/// - payment_intent.failed
/// - customer.subscription.created
/// - customer.subscription.updated
/// - customer.subscription.deleted
/// - invoice.payment_succeeded
/// - invoice.payment_failed
class StripeWebhookListenerService {
  static final StripeWebhookListenerService _instance =
      StripeWebhookListenerService._internal();
  factory StripeWebhookListenerService() => _instance;
  StripeWebhookListenerService._internal();

  final WebSocketService _websocketService = WebSocketService();
  final AuthService _authService = AuthService();

  // Stream controllers for different webhook events
  final StreamController<PaymentIntentEvent> _paymentIntentController =
      StreamController<PaymentIntentEvent>.broadcast();
  final StreamController<SubscriptionEvent> _subscriptionController =
      StreamController<SubscriptionEvent>.broadcast();
  final StreamController<InvoicePaymentEvent> _invoicePaymentController =
      StreamController<InvoicePaymentEvent>.broadcast();

  // Public streams
  Stream<PaymentIntentEvent> get paymentIntentStream =>
      _paymentIntentController.stream;
  Stream<SubscriptionEvent> get subscriptionStream =>
      _subscriptionController.stream;
  Stream<InvoicePaymentEvent> get invoicePaymentStream =>
      _invoicePaymentController.stream;

  bool _isListening = false;

  /// Initialize and start listening for webhook events
  Future<void> initialize() async {
    if (_isListening) return;

    final user = await _authService.getCurrentUser();
    if (user == null) {
      debugPrint('Cannot initialize webhook listener: No authenticated user');
      return;
    }

    _isListening = true;
    _setupWebSocketListeners();
    debugPrint('StripeWebhookListenerService initialized');
  }

  /// Setup WebSocket listeners for webhook events
  void _setupWebSocketListeners() {
    // Listen for payment intent events
    _websocketService.on('stripe.payment_intent.succeeded', (data) {
      _handlePaymentIntentSucceeded(data);
    });

    _websocketService.on('stripe.payment_intent.failed', (data) {
      _handlePaymentIntentFailed(data);
    });

    // Listen for subscription events
    _websocketService.on('stripe.subscription.created', (data) {
      _handleSubscriptionCreated(data);
    });

    _websocketService.on('stripe.subscription.updated', (data) {
      _handleSubscriptionUpdated(data);
    });

    _websocketService.on('stripe.subscription.deleted', (data) {
      _handleSubscriptionDeleted(data);
    });

    // Listen for invoice payment events
    _websocketService.on('stripe.invoice.payment_succeeded', (data) {
      _handleInvoicePaymentSucceeded(data);
    });

    _websocketService.on('stripe.invoice.payment_failed', (data) {
      _handleInvoicePaymentFailed(data);
    });
  }

  /// Handle payment_intent.succeeded webhook
  void _handlePaymentIntentSucceeded(dynamic data) {
    try {
      final event = PaymentIntentEvent.fromJson(data);
      _paymentIntentController.add(event);
      debugPrint('Payment Intent Succeeded: ${event.paymentIntentId}');
      
      // Show success notification
      _showNotification(
        'Payment Successful',
        'Your payment of ${event.amount} ${event.currency} was processed successfully',
        type: NotificationType.success,
      );
    } catch (e) {
      debugPrint('Error handling payment_intent.succeeded: $e');
    }
  }

  /// Handle payment_intent.failed webhook
  void _handlePaymentIntentFailed(dynamic data) {
    try {
      final event = PaymentIntentEvent.fromJson(data);
      _paymentIntentController.add(event);
      debugPrint('Payment Intent Failed: ${event.paymentIntentId}');
      
      // Show error notification
      _showNotification(
        'Payment Failed',
        event.errorMessage ?? 'Your payment could not be processed',
        type: NotificationType.error,
      );
    } catch (e) {
      debugPrint('Error handling payment_intent.failed: $e');
    }
  }

  /// Handle customer.subscription.created webhook
  void _handleSubscriptionCreated(dynamic data) {
    try {
      final event = SubscriptionEvent.fromJson(data);
      _subscriptionController.add(event);
      debugPrint('Subscription Created: ${event.subscriptionId}');
      
      // Show success notification
      _showNotification(
        'Subscription Activated',
        'Your ${event.planName} subscription is now active',
        type: NotificationType.success,
      );
    } catch (e) {
      debugPrint('Error handling subscription.created: $e');
    }
  }

  /// Handle customer.subscription.updated webhook
  void _handleSubscriptionUpdated(dynamic data) {
    try {
      final event = SubscriptionEvent.fromJson(data);
      _subscriptionController.add(event);
      debugPrint('Subscription Updated: ${event.subscriptionId}');
      
      if (event.status == SubscriptionStatus.active) {
        _showNotification(
          'Subscription Updated',
          'Your subscription has been updated successfully',
          type: NotificationType.info,
        );
      } else if (event.status == SubscriptionStatus.pastDue) {
        _showNotification(
          'Payment Required',
          'Please update your payment method to continue your subscription',
          type: NotificationType.warning,
        );
      } else if (event.status == SubscriptionStatus.canceled) {
        _showNotification(
          'Subscription Canceled',
          'Your subscription has been canceled',
          type: NotificationType.info,
        );
      }
    } catch (e) {
      debugPrint('Error handling subscription.updated: $e');
    }
  }

  /// Handle customer.subscription.deleted webhook
  void _handleSubscriptionDeleted(dynamic data) {
    try {
      final event = SubscriptionEvent.fromJson(data);
      _subscriptionController.add(event);
      debugPrint('Subscription Deleted: ${event.subscriptionId}');
      
      // Show notification
      _showNotification(
        'Subscription Ended',
        'Your subscription has ended. Premium features are no longer available.',
        type: NotificationType.warning,
      );
    } catch (e) {
      debugPrint('Error handling subscription.deleted: $e');
    }
  }

  /// Handle invoice.payment_succeeded webhook
  void _handleInvoicePaymentSucceeded(dynamic data) {
    try {
      final event = InvoicePaymentEvent.fromJson(data);
      _invoicePaymentController.add(event);
      debugPrint('Invoice Payment Succeeded: ${event.invoiceId}');
      
      // Show success notification
      _showNotification(
        'Payment Received',
        'Your payment of ${event.amount} ${event.currency} has been received',
        type: NotificationType.success,
      );
    } catch (e) {
      debugPrint('Error handling invoice.payment_succeeded: $e');
    }
  }

  /// Handle invoice.payment_failed webhook
  void _handleInvoicePaymentFailed(dynamic data) {
    try {
      final event = InvoicePaymentEvent.fromJson(data);
      _invoicePaymentController.add(event);
      debugPrint('Invoice Payment Failed: ${event.invoiceId}');
      
      // Show error notification
      _showNotification(
        'Payment Failed',
        'Payment failed for invoice ${event.invoiceNumber}. Please update your payment method.',
        type: NotificationType.error,
      );
    } catch (e) {
      debugPrint('Error handling invoice.payment_failed: $e');
    }
  }

  /// Show in-app notification
  void _showNotification(
    String title,
    String message, {
    NotificationType type = NotificationType.info,
  }) {
    // Emit notification event that UI can listen to
    _websocketService.emit('app.notification', {
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Stop listening for webhook events
  void dispose() {
    _isListening = false;
    _paymentIntentController.close();
    _subscriptionController.close();
    _invoicePaymentController.close();
    debugPrint('StripeWebhookListenerService disposed');
  }
}

/// Payment Intent Event Model
class PaymentIntentEvent {
  final String paymentIntentId;
  final String status;
  final double amount;
  final String currency;
  final String? errorMessage;
  final String? customerId;
  final DateTime timestamp;

  PaymentIntentEvent({
    required this.paymentIntentId,
    required this.status,
    required this.amount,
    required this.currency,
    this.errorMessage,
    this.customerId,
    required this.timestamp,
  });

  factory PaymentIntentEvent.fromJson(Map<String, dynamic> json) {
    return PaymentIntentEvent(
      paymentIntentId: json['payment_intent_id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble() / 100, // Convert from cents
      currency: (json['currency'] as String).toUpperCase(),
      errorMessage: json['error_message'] as String?,
      customerId: json['customer_id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  bool get isSuccessful => status == 'succeeded';
  bool get isFailed => status == 'failed';
}

/// Subscription Event Model
class SubscriptionEvent {
  final String subscriptionId;
  final String status;
  final String planId;
  final String planName;
  final double amount;
  final String currency;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime timestamp;

  SubscriptionEvent({
    required this.subscriptionId,
    required this.status,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.currency,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    required this.timestamp,
  });

  factory SubscriptionEvent.fromJson(Map<String, dynamic> json) {
    return SubscriptionEvent(
      subscriptionId: json['subscription_id'] as String,
      status: json['status'] as String,
      planId: json['plan_id'] as String,
      planName: json['plan_name'] as String,
      amount: (json['amount'] as num).toDouble() / 100,
      currency: (json['currency'] as String).toUpperCase(),
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  SubscriptionStatus get subscriptionStatus {
    switch (status.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'unpaid':
        return SubscriptionStatus.unpaid;
      default:
        return SubscriptionStatus.incomplete;
    }
  }
}

/// Invoice Payment Event Model
class InvoicePaymentEvent {
  final String invoiceId;
  final String invoiceNumber;
  final String status;
  final double amount;
  final String currency;
  final String? subscriptionId;
  final DateTime? dueDate;
  final String? errorMessage;
  final DateTime timestamp;

  InvoicePaymentEvent({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.status,
    required this.amount,
    required this.currency,
    this.subscriptionId,
    this.dueDate,
    this.errorMessage,
    required this.timestamp,
  });

  factory InvoicePaymentEvent.fromJson(Map<String, dynamic> json) {
    return InvoicePaymentEvent(
      invoiceId: json['invoice_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble() / 100,
      currency: (json['currency'] as String).toUpperCase(),
      subscriptionId: json['subscription_id'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  bool get isPaid => status == 'paid';
  bool get isFailed => status == 'payment_failed';
}

/// Subscription Status Enum
enum SubscriptionStatus {
  active,
  pastDue,
  canceled,
  unpaid,
  incomplete,
}

/// Notification Type Enum
enum NotificationType {
  success,
  error,
  warning,
  info,
}

