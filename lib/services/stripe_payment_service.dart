import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import '../config/api_config.dart';

/// Stripe Payment Service
/// 
/// Handles all Stripe payment operations:
/// - Payment method management
/// - Payment processing
/// - 3D Secure authentication
/// - Subscription payments
class StripePaymentService {
  static final StripePaymentService _instance = StripePaymentService._internal();
  factory StripePaymentService() => _instance;
  StripePaymentService._internal();

  bool _initialized = false;

  /// Initialize Stripe with publishable key
  Future<void> initialize({required String publishableKey}) async {
    if (_initialized) return;

    try {
      Stripe.publishableKey = publishableKey;
      Stripe.merchantIdentifier = 'merchant.com.lgbtinder.app';
      Stripe.urlScheme = 'lgbtinder';
      
      await Stripe.instance.applySettings();
      
      _initialized = true;
      debugPrint('Stripe initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Stripe: $e');
      rethrow;
    }
  }

  /// Create payment method from card details
  /// 
  /// Returns payment method ID
  Future<String?> createPaymentMethod({
    required CardFieldInputDetails cardDetails,
    BillingDetails? billingDetails,
  }) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      return paymentMethod.id;
    } catch (e) {
      debugPrint('Error creating payment method: $e');
      return null;
    }
  }

  /// Confirm payment with payment intent
  /// 
  /// [clientSecret] - Payment intent client secret from backend
  /// [paymentMethodId] - Optional payment method ID (if not using default)
  /// Returns [PaymentIntent] on success
  Future<PaymentIntent?> confirmPayment({
    required String clientSecret,
    String? paymentMethodId,
  }) async {
    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: paymentMethodId != null
            ? PaymentMethodParams.card(
                paymentMethodData: PaymentMethodData(
                  paymentMethodId: paymentMethodId,
                ),
              )
            : null,
      );

      return paymentIntent;
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      throw PaymentException(e.error.localizedMessage ?? 'Payment failed');
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      throw PaymentException('Payment failed: $e');
    }
  }

  /// Handle 3D Secure authentication
  /// 
  /// [clientSecret] - Payment intent client secret
  /// Returns true if authentication successful
  Future<bool> handle3DSecure({
    required String clientSecret,
  }) async {
    try {
      final paymentIntent = await Stripe.instance.handleNextAction(
        clientSecret,
      );

      return paymentIntent?.status == PaymentIntentsStatus.Succeeded ||
          paymentIntent?.status == PaymentIntentsStatus.RequiresCapture;
    } catch (e) {
      debugPrint('Error handling 3D Secure: $e');
      return false;
    }
  }

  /// Confirm Setup Intent (for saving card without charging)
  /// 
  /// [clientSecret] - Setup intent client secret from backend
  /// Returns [SetupIntent] on success
  Future<SetupIntent?> confirmSetupIntent({
    required String clientSecret,
  }) async {
    try {
      final setupIntent = await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      return setupIntent;
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      throw PaymentException(e.error.localizedMessage ?? 'Setup failed');
    } catch (e) {
      debugPrint('Error confirming setup intent: $e');
      throw PaymentException('Setup failed: $e');
    }
  }

  /// Present card form for collecting payment
  /// 
  /// Returns payment method ID on success
  Future<String?> presentPaymentSheet({
    required String paymentIntentClientSecret,
    String? merchantDisplayName,
    String? customerId,
    String? customerEphemeralKeySecret,
  }) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: merchantDisplayName ?? 'LGBTinder',
          customerId: customerId,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFFE94057),
              background: const Color(0xFF1E1E2E),
              componentBackground: const Color(0xFF2C2C3E),
              componentBorder: const Color(0xFF3E3E50),
              componentDivider: const Color(0xFF3E3E50),
              primaryText: Colors.white,
              secondaryText: Colors.white70,
              componentText: Colors.white,
              placeholderText: Colors.white54,
            ),
            shapes: const PaymentSheetShape(
              borderRadius: 12,
              borderWidth: 1,
            ),
            primaryButton: const PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFE94057),
                  text: Colors.white,
                  border: Color(0xFFE94057),
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFE94057),
                  text: Colors.white,
                  border: Color(0xFFE94057),
                ),
              ),
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      debugPrint('Payment sheet completed successfully');
      return paymentIntentClientSecret;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        debugPrint('Payment cancelled by user');
        return null;
      }
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      throw PaymentException(e.error.localizedMessage ?? 'Payment failed');
    } catch (e) {
      debugPrint('Error presenting payment sheet: $e');
      throw PaymentException('Payment failed: $e');
    }
  }

  /// Retrieve payment intent status
  Future<PaymentIntent?> retrievePaymentIntent(String clientSecret) async {
    try {
      final paymentIntent = await Stripe.instance.retrievePaymentIntent(
        clientSecret,
      );
      return paymentIntent;
    } catch (e) {
      debugPrint('Error retrieving payment intent: $e');
      return null;
    }
  }

  /// Check if Stripe is initialized
  bool get isInitialized => _initialized;
}

/// Payment Exception
class PaymentException implements Exception {
  final String message;

  PaymentException(this.message);

  @override
  String toString() => message;
}
