import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/premium_service.dart';
import '../providers/auth_provider.dart';
import '../utils/api_error_handler.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _subscriptionData = {};
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;

      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Load subscription data
      final subscriptionStatus = await PremiumService.getPremiumStatus(
        accessToken: accessToken,
      );

      setState(() {
        _subscriptionData = subscriptionStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Failed to load subscription data. Please try again.',
        onRetry: _loadSubscriptionData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Subscription Management'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentSubscription(),
                  const SizedBox(height: 24),
                  _buildSubscriptionDetails(),
                  const SizedBox(height: 24),
                  _buildPaymentHistory(),
                  const SizedBox(height: 24),
                  _buildSubscriptionActions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentSubscription() {
    final isPremium = _subscriptionData['is_premium'] ?? false;
    final planName = _subscriptionData['plan_name'] as String? ?? 'Free';
    final status = _subscriptionData['status'] as String? ?? 'inactive';
    final nextBillingDate = _subscriptionData['next_billing_date'] as String?;
    final amount = _subscriptionData['amount'] as double? ?? 0.0;
    final currency = _subscriptionData['currency'] as String? ?? 'USD';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremium
              ? [AppColors.primary, AppColors.secondary]
              : [AppColors.navbarBackground, AppColors.navbarBackground],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium ? AppColors.primary : Colors.white24,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPremium ? Icons.diamond : Icons.person,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            planName,
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStatusText(status),
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
          ),
          if (isPremium && amount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)} $currency',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (nextBillingDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Next billing: ${_formatDate(nextBillingDate)}',
              style: AppTypography.caption.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails() {
    final isPremium = _subscriptionData['is_premium'] ?? false;
    
    if (!isPremium) {
      return const SizedBox.shrink();
    }

    final startDate = _subscriptionData['start_date'] as String?;
    final endDate = _subscriptionData['end_date'] as String?;
    final interval = _subscriptionData['interval'] as String? ?? 'month';
    final autoRenew = _subscriptionData['auto_renew'] ?? true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Details',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Start Date', _formatDate(startDate ?? '')),
          _buildDetailRow('End Date', _formatDate(endDate ?? '')),
          _buildDetailRow('Billing Cycle', _getIntervalText(interval)),
          _buildDetailRow('Auto Renewal', autoRenew ? 'Enabled' : 'Disabled'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body2.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    final isPremium = _subscriptionData['is_premium'] ?? false;
    
    if (!isPremium) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment History',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_paymentHistory.isEmpty)
            Text(
              'No payment history available',
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            )
          else
            ..._paymentHistory.map((payment) => _buildPaymentItem(payment)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    final amount = payment['amount'] as double? ?? 0.0;
    final currency = payment['currency'] as String? ?? 'USD';
    final date = payment['date'] as String? ?? '';
    final status = payment['status'] as String? ?? 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            status == 'completed' ? Icons.check_circle : Icons.error,
            color: status == 'completed' ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${amount.toStringAsFixed(2)} $currency',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDate(date),
                  style: AppTypography.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Text(
            status.toUpperCase(),
            style: AppTypography.caption.copyWith(
              color: status == 'completed' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionActions() {
    final isPremium = _subscriptionData['is_premium'] ?? false;
    final status = _subscriptionData['status'] as String? ?? 'inactive';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscription Actions',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (isPremium) ...[
            _buildActionButton(
              'Change Plan',
              'Upgrade or downgrade your subscription',
              Icons.swap_horiz,
              () => _changePlan(),
            ),
            _buildActionButton(
              'Update Payment Method',
              'Change your payment information',
              Icons.payment,
              () => _updatePaymentMethod(),
            ),
            if (status == 'active') ...[
              _buildActionButton(
                'Cancel Subscription',
                'Cancel your subscription (access until end of period)',
                Icons.cancel,
                () => _cancelSubscription(),
                isDestructive: true,
              ),
            ],
          ] else ...[
            _buildActionButton(
              'Upgrade to Premium',
              'Get unlimited access to all features',
              Icons.diamond,
              () => _upgradeToPremium(),
            ),
          ],
          
          _buildActionButton(
            'Contact Support',
            'Get help with your subscription',
            Icons.support_agent,
            () => _contactSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body1.copyWith(
                        color: isDestructive ? Colors.red : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      case 'pending':
        return 'Pending';
      default:
        return 'Inactive';
    }
  }

  String _getIntervalText(String interval) {
    switch (interval.toLowerCase()) {
      case 'month':
        return 'Monthly';
      case 'year':
        return 'Yearly';
      case 'week':
        return 'Weekly';
      default:
        return interval;
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _changePlan() {
    Navigator.pushNamed(context, '/premium-features');
  }

  void _updatePaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment method update coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _cancelSubscription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Cancel Subscription',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to cancel your subscription? You will lose access to premium features at the end of your current billing period.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Subscription',
              style: AppTypography.body1.copyWith(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmCancelSubscription();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelSubscription() async {
    setState(() {
      _isCancelling = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken != null) {
        final success = await PremiumService.cancelSubscription(
          accessToken: accessToken,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadSubscriptionData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to cancel subscription'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling subscription: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCancelling = false;
      });
    }
  }

  void _upgradeToPremium() {
    Navigator.pushNamed(context, '/premium-features');
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact support feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
