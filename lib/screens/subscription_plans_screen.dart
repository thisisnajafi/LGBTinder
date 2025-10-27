import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_services/payment_api_service.dart';
import '../services/stripe_payment_service.dart';
import '../services/token_management_service.dart';

/// Subscription Plans Screen
/// 
/// Display and purchase subscription plans:
/// - Bronze, Silver, Gold tiers
/// - Monthly, 3-month, 6-month, yearly options
/// - Feature comparison
/// - Promo code support
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  List<SubscriptionPlan> _plans = [];
  Subscription? _currentSubscription;
  bool _isLoading = false;
  String? _error;
  int _selectedDuration = 1; // 1=monthly, 3=3months, 6=6months, 12=yearly
  String? _promoCode;

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _loadCurrentSubscription();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await PaymentApiService.getSubscriptionPlans(token: token);

      if (response.success) {
        setState(() {
          _plans = response.plans ?? [];
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
        _error = 'Failed to load plans: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentSubscription() async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) return;

      final response = await PaymentApiService.getCurrentSubscription(token: token);

      if (response.success && response.subscription != null) {
        setState(() {
          _currentSubscription = response.subscription;
        });
      }
    } catch (e) {
      debugPrint('Error loading current subscription: $e');
    }
  }

  Future<void> _purchaseSubscription(SubscriptionPlan plan) async {
    // TODO: Navigate to payment methods and process payment
    _showSuccess('Payment flow coming soon');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          
          if (_currentSubscription != null)
            SliverToBoxAdapter(
              child: _buildCurrentSubscriptionBanner(),
            ),
          
          SliverToBoxAdapter(
            child: _buildDurationSelector(),
          ),
          
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: _buildErrorState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plan = _plans[index];
                    return _buildPlanCard(plan);
                  },
                  childCount: _plans.length,
                ),
              ),
            ),
          
          SliverToBoxAdapter(
            child: _buildPromoCodeSection(),
          ),
          
          SliverToBoxAdapter(
            child: _buildFeatureComparison(),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.navbarBackground,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Go Premium',
          style: AppTypography.h3.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock Premium Features',
                  style: AppTypography.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionBanner() {
    if (_currentSubscription == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_currentSubscription!.planName} Active',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Renews ${DateFormat('MMM dd, yyyy').format(_currentSubscription!.currentPeriodEnd)}',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to subscription management
            },
            child: Text(
              'Manage',
              style: AppTypography.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildDurationButton('1 Month', 1),
          _buildDurationButton('3 Months', 3, discount: '10% OFF'),
          _buildDurationButton('6 Months', 6, discount: '20% OFF'),
          _buildDurationButton('1 Year', 12, discount: '30% OFF'),
        ],
      ),
    );
  }

  Widget _buildDurationButton(String label, int months, {String? discount}) {
    final isSelected = _selectedDuration == months;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDuration = months;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              if (discount != null) ...[
                const SizedBox(height: 4),
                Text(
                  discount,
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final price = _getPriceForDuration(plan);
    final pricePerMonth = price != null ? price / _selectedDuration : null;
    final isCurrentPlan = _currentSubscription?.planId == plan.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isPopular ? AppColors.primary : Colors.white24,
          width: plan.isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: plan.isPopular
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    )
                  : null,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
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
                    const Spacer(),
                    if (plan.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'POPULAR',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                if (price != null && pricePerMonth != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${pricePerMonth.toStringAsFixed(2)}',
                        style: AppTypography.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/month',
                        style: AppTypography.body1.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedDuration > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Billed \$${(price / 100).toStringAsFixed(2)} every $_selectedDuration months',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          
          // Features
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: AppTypography.body2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 16),
                
                // Subscribe button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => _purchaseSubscription(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? Colors.grey
                          : plan.isPopular
                              ? Colors.white
                              : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCurrentPlan
                          ? 'Current Plan'
                          : 'Subscribe Now',
                      style: AppTypography.body1.copyWith(
                        color: plan.isPopular && !isCurrentPlan
                            ? AppColors.primary
                            : Colors.white,
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

  Widget _buildPromoCodeSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Have a promo code?',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: AppTypography.body1.copyWith(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    hintStyle: AppTypography.body1.copyWith(color: Colors.white54),
                    filled: true,
                    fillColor: AppColors.cardBackgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _promoCode = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _promoCode != null && _promoCode!.isNotEmpty
                    ? () {
                        // Apply promo code
                        _showSuccess('Promo code applied!');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Go Premium?',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.favorite,
            'Unlimited Likes',
            'Like as many profiles as you want',
          ),
          _buildFeatureItem(
            Icons.visibility,
            'See Who Liked You',
            'View all your admirers instantly',
          ),
          _buildFeatureItem(
            Icons.filter_alt,
            'Advanced Filters',
            'Find your perfect match with detailed filters',
          ),
          _buildFeatureItem(
            Icons.undo,
            'Unlimited Rewinds',
            'Go back on any profile you passed',
          ),
          _buildFeatureItem(
            Icons.rocket_launch,
            'Boost Your Profile',
            'Get 10x more visibility',
          ),
          _buildFeatureItem(
            Icons.mark_email_read,
            'Read Receipts',
            'Know when your messages are read',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            onPressed: _loadPlans,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  int? _getPriceForDuration(SubscriptionPlan plan) {
    switch (_selectedDuration) {
      case 1:
        return plan.monthlyPrice;
      case 3:
        return plan.threeMonthPrice;
      case 6:
        return plan.sixMonthPrice;
      case 12:
        return plan.yearlyPrice;
      default:
        return plan.monthlyPrice;
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
}

