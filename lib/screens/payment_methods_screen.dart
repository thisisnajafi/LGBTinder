import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/stripe_payment_service.dart';
import '../services/api_services/payment_api_service.dart';
import '../services/token_management_service.dart';

/// Payment Methods Screen
/// 
/// Manage saved payment methods:
/// - View all saved cards
/// - Add new card
/// - Remove card
/// - Set default payment method
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await PaymentApiService.getPaymentMethods(token: token);

      if (response.success) {
        setState(() {
          _paymentMethods = response.paymentMethods ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load payment methods: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addPaymentMethod() async {
    try {
      // Show Stripe card input
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => AddPaymentMethodBottomSheet(
          onSuccess: () {
            _loadPaymentMethods();
          },
        ),
      );
    } catch (e) {
      _showError('Failed to add payment method: $e');
    }
  }

  Future<void> _removePaymentMethod(PaymentMethod method) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundLight,
        title: Text(
          'Remove Card',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${method.card?.displayBrand} ending in ${method.card?.last4}?',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remove',
              style: AppTypography.body1.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final token = await TokenManagementService.getAccessToken();
        if (token == null) throw Exception('Not authenticated');

        final success = await PaymentApiService.deletePaymentMethod(
          token: token,
          methodId: method.id,
        );

        if (success) {
          _showSuccess('Payment method removed');
          await _loadPaymentMethods();
        } else {
          _showError('Failed to remove payment method');
        }
      } catch (e) {
        _showError('Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setDefaultPaymentMethod(PaymentMethod method) async {
    if (method.isDefault) return;

    setState(() => _isLoading = true);

    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final success = await PaymentApiService.setDefaultPaymentMethod(
        token: token,
        methodId: method.id,
      );

      if (success) {
        _showSuccess('Default payment method updated');
        await _loadPaymentMethods();
      } else {
        _showError('Failed to set default payment method');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Payment Methods',
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _error != null
              ? _buildErrorState()
              : _paymentMethods.isEmpty
                  ? _buildEmptyState()
                  : _buildPaymentMethodsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPaymentMethod,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Card',
          style: AppTypography.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: AppTypography.body1.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPaymentMethods,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: AppTypography.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            color: Colors.white.withOpacity(0.3),
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            'No Payment Methods',
            style: AppTypography.h4.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a card to make purchases',
            style: AppTypography.body1.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addPaymentMethod,
            icon: const Icon(Icons.add),
            label: const Text('Add Card'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paymentMethods.length,
      itemBuilder: (context, index) {
        final method = _paymentMethods[index];
        return _buildPaymentMethodCard(method);
      },
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final card = method.card;
    if (card == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: method.isDefault ? AppColors.primary : Colors.white24,
          width: method.isDefault ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Card brand icon
              _buildCardIcon(card.brand),
              const SizedBox(width: 12),
              
              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.displayBrand,
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.maskedNumber,
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Default badge
              if (method.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Default',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              
              // Menu button
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                color: AppColors.cardBackgroundLight,
                onSelected: (value) {
                  if (value == 'default') {
                    _setDefaultPaymentMethod(method);
                  } else if (value == 'remove') {
                    _removePaymentMethod(method);
                  }
                },
                itemBuilder: (context) => [
                  if (!method.isDefault)
                    PopupMenuItem(
                      value: 'default',
                      child: Text(
                        'Set as Default',
                        style: AppTypography.body2.copyWith(color: Colors.white),
                      ),
                    ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      'Remove',
                      style: AppTypography.body2.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Expiration date
          Row(
            children: [
              Text(
                'Expires ${card.expMonth.toString().padLeft(2, '0')}/${card.expYear}',
                style: AppTypography.body2.copyWith(color: Colors.white54),
              ),
              const Spacer(),
              Text(
                'Added ${_formatDate(method.createdAt)}',
                style: AppTypography.body2.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardIcon(String brand) {
    IconData icon;
    Color color;

    switch (brand.toLowerCase()) {
      case 'visa':
        icon = Icons.credit_card;
        color = const Color(0xFF1A1F71);
        break;
      case 'mastercard':
        icon = Icons.credit_card;
        color = const Color(0xFFEB001B);
        break;
      case 'amex':
        icon = Icons.credit_card;
        color = const Color(0xFF006FCF);
        break;
      default:
        icon = Icons.credit_card;
        color = Colors.white54;
    }

    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

/// Add Payment Method Bottom Sheet
class AddPaymentMethodBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;

  const AddPaymentMethodBottomSheet({
    Key? key,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<AddPaymentMethodBottomSheet> createState() => _AddPaymentMethodBottomSheetState();
}

class _AddPaymentMethodBottomSheetState extends State<AddPaymentMethodBottomSheet> {
  final CardFormEditController _controller = CardFormEditController();
  bool _isLoading = false;
  bool _isComplete = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);

    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Create payment method with Stripe
      final cardDetails = _controller.details;
      final paymentMethodId = await StripePaymentService().createPaymentMethod(
        cardDetails: cardDetails,
      );

      if (paymentMethodId == null) {
        throw Exception('Failed to create payment method');
      }

      // Save to backend
      final response = await PaymentApiService.addPaymentMethod(
        token: token,
        paymentMethodId: paymentMethodId,
        isDefault: false,
      );

      if (response.success) {
        widget.onSuccess();
        Navigator.pop(context);
        _showSuccess('Card added successfully');
      } else {
        throw Exception(response.error ?? 'Failed to save card');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Add Payment Method',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Card input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CardFormField(
              controller: _controller,
              style: CardFormStyle(
                backgroundColor: AppColors.cardBackgroundLight,
                borderColor: Colors.white24,
                textColor: Colors.white,
                placeholderColor: Colors.white54,
                borderRadius: 12,
              ),
              onCardChanged: (details) {
                setState(() {
                  _isComplete = details.complete;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.body1.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isComplete && !_isLoading ? _saveCard : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save Card',
                            style: AppTypography.body1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

