import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../models/premium_plan.dart';
import '../../services/api_services/payment_api_service.dart';
import '../../services/stripe_payment_service.dart';
import '../../services/token_management_service.dart';

/// Premium Subscription Screen
/// 
/// Displays subscription plans (Bronze, Silver, Gold)
/// with pricing, features, and purchase functionality
class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<PremiumSubscriptionScreen> createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> {
  List<PremiumPlan> _plans = [];
  UserSubscription? _currentSubscription;
  bool _isLoading = true;
  String? _error;
  
  int _selectedDuration = 1; // 1 = monthly, 3 = 3 months, 6 = 6 months, 12 = yearly
  PremiumPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Load plans and current subscription
      final plansResponse = await PaymentApiService.getPlans(token: token);
      final subscriptionResponse = await PaymentApiService.getCurrentSubscription(token: token);

      if (!plansResponse.success) {
        throw Exception(plansResponse.error ?? 'Failed to load plans');
      }

      setState(() {
        _plans = plansResponse.plans;
        _currentSubscription = subscriptionResponse.subscription;
        _isLoading = false;
        
        // Auto-select Silver as default
        _selectedPlan = _plans.firstWhere(
          (plan) => plan.name.toLowerCase().contains('silver'),
          orElse: () => _plans.isNotEmpty ? _plans[1] : _plans.first,
        );
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _purchaseSubscription() async {
    if (_selectedPlan == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final stripeService = StripePaymentService();
      final result = await stripeService.processSubscriptionPayment(
        planId: _selectedPlan!.id,
      );

      Navigator.pop(context); // Close loading dialog

      if (result.success) {
        // Show success
        _showSuccessDialog();
      } else {
        _showErrorDialog(result.message);
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundLight,
        title: Text(
          '🎉 Welcome to Premium!',
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
        content: Text(
          'Your subscription has been activated successfully!',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(
              'Start Exploring',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackgroundLight,
        title: Text(
          'Purchase Failed',
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
        content: Text(
          message,
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
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
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          'Upgrade to Premium',
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'Failed to load plans',
            style: AppTypography.h4.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: AppTypography.body2.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Current subscription banner (if exists)
        if (_currentSubscription != null && _currentSubscription!.isActive)
          _buildCurrentSubscriptionBanner(),

        // Duration selector
        _buildDurationSelector(),

        // Plans list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              return _buildPlanCard(_plans[index]);
            },
          ),
        ),

        // Purchase button
        _buildPurchaseButton(),
      ],
    );
  }

  Widget _buildCurrentSubscriptionBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan: ${_currentSubscription!.planName}',
                  style: AppTypography.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentSubscription!.currentPeriodEnd != null)
                  Text(
                    'Renews on ${_formatDate(_currentSubscription!.currentPeriodEnd!)}',
                    style: AppTypography.body2.copyWith(color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildDurationOption('Monthly', 1),
          _buildDurationOption('3 Months', 3, discount: '15% OFF'),
          _buildDurationOption('6 Months', 6, discount: '25% OFF'),
          _buildDurationOption('Yearly', 12, discount: '40% OFF', popular: true),
        ],
      ),
    );
  }

  Widget _buildDurationOption(String label, int months, {String? discount, bool popular = false}) {
    final isSelected = _selectedDuration == months;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDuration = months),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (popular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: AppTypography.body3.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.body2.copyWith(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              if (discount != null)
                Text(
                  discount,
                  style: AppTypography.body3.copyWith(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(PremiumPlan plan) {
    final isSelected = _selectedPlan?.id == plan.id;
    final isMostPopular = plan.name.toLowerCase().contains('silver');

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white24,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Plan icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getPlanColor(plan).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getPlanIcon(plan),
                    color: _getPlanColor(plan),
                    size: 32,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Plan name and price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: AppTypography.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isMostPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'MOST POPULAR',
                                style: AppTypography.body3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_calculatePrice(plan)}/month',
                        style: AppTypography.h4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Selected indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            
            // Features
            ...plan.features.map((feature) => _buildFeatureRow(feature)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: AppTypography.body1.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_selectedPlan != null) ...[
            Text(
              'Total: \$${_calculateTotalPrice(_selectedPlan!)}',
              style: AppTypography.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Billed ${_selectedDuration == 1 ? 'monthly' : _selectedDuration == 12 ? 'annually' : 'every $_selectedDuration months'}',
              style: AppTypography.body2.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
          ],
          
          ElevatedButton(
            onPressed: _selectedPlan == null ? null : _purchaseSubscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue to Payment',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Cancel anytime. Terms and conditions apply.',
            style: AppTypography.body3.copyWith(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPlanColor(PremiumPlan plan) {
    if (plan.name.toLowerCase().contains('bronze')) {
      return const Color(0xFFCD7F32);
    } else if (plan.name.toLowerCase().contains('silver')) {
      return const Color(0xFFC0C0C0);
    } else if (plan.name.toLowerCase().contains('gold')) {
      return const Color(0xFFFFD700);
    }
    return AppColors.primary;
  }

  IconData _getPlanIcon(PremiumPlan plan) {
    if (plan.name.toLowerCase().contains('bronze')) {
      return Icons.star;
    } else if (plan.name.toLowerCase().contains('silver')) {
      return Icons.star_half;
    } else if (plan.name.toLowerCase().contains('gold')) {
      return Icons.stars;
    }
    return Icons.workspace_premium;
  }

  double _calculatePrice(PremiumPlan plan) {
    final basePrice = plan.price;
    if (_selectedDuration == 1) return basePrice;
    if (_selectedDuration == 3) return basePrice * 0.85; // 15% off
    if (_selectedDuration == 6) return basePrice * 0.75; // 25% off
    if (_selectedDuration == 12) return basePrice * 0.60; // 40% off
    return basePrice;
  }

  double _calculateTotalPrice(PremiumPlan plan) {
    return _calculatePrice(plan) * _selectedDuration;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

