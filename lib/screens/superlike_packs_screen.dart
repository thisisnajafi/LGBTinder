import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_services/payment_api_service.dart';
import '../services/token_management_service.dart';

/// Superlike Packs Screen
/// 
/// Purchase superlike packs:
/// - View available packs (5, 25, 60 superlikes)
/// - See pricing and discounts
/// - Current superlike balance
/// - Usage history
/// - Purchase with saved payment method
class SuperlikePacksScreen extends StatefulWidget {
  const SuperlikePacksScreen({Key? key}) : super(key: key);

  @override
  State<SuperlikePacksScreen> createState() => _SuperlikePacksScreenState();
}

class _SuperlikePacksScreenState extends State<SuperlikePacksScreen> {
  List<SuperlikePack> _packs = [];
  int? _currentBalance;
  bool _isLoading = false;
  String? _error;
  String? _selectedPackId;

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

      // Load packs and balance in parallel
      final results = await Future.wait([
        PaymentApiService.getSuperlikePacks(token: token),
        PaymentApiService.getSuperlikeBalance(token: token),
      ]);

      final packsResponse = results[0] as SuperlikePacksResponse;
      final balance = results[1] as int?;

      if (packsResponse.success) {
        setState(() {
          _packs = packsResponse.packs ?? [];
          _currentBalance = balance;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = packsResponse.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePack(SuperlikePack pack) async {
    // TODO: Show payment method selection and process payment
    setState(() => _selectedPackId = pack.id);
    
    // Simulate purchase for now
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _selectedPackId = null);
    _showSuccess('Superlike pack purchased successfully!');
    _loadData(); // Reload to update balance
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
          'Superlike Packs',
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
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildBalanceCard(),
                    ),
                    
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Choose Your Pack',
                          style: AppTypography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final pack = _packs[index];
                            return _buildPackCard(pack);
                          },
                          childCount: _packs.length,
                        ),
                      ),
                    ),
                    
                    SliverToBoxAdapter(
                      child: _buildInfoSection(),
                    ),
                    
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 32),
                    ),
                  ],
                ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Superlikes',
                style: AppTypography.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentBalance?.toString() ?? '-',
            style: AppTypography.h1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 64,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentBalance == 1 ? 'Superlike Available' : 'Superlikes Available',
            style: AppTypography.body1.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (_currentBalance != null && _currentBalance! < 5) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Running low? Get more below',
                    style: AppTypography.body2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackCard(SuperlikePack pack) {
    final isBestValue = pack.bestValue != null;
    final isPurchasing = _selectedPackId == pack.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBestValue ? AppColors.success : Colors.white24,
          width: isBestValue ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Best value badge
          if (isBestValue)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Text(
                pack.bestValue!.toUpperCase(),
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon and quantity
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.6),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 32,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pack.quantity}',
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pack.quantity} Superlikes',
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.simpleCurrency().format(pack.pricePerSuperlike) + ' per superlike',
                        style: AppTypography.body2.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      if (pack.discount != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SAVE ${pack.discount}%',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.simpleCurrency().format(pack.price / 100),
                      style: AppTypography.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: isPurchasing ? null : () => _purchasePack(pack),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBestValue
                              ? AppColors.success
                              : AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isPurchasing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Buy',
                                style: AppTypography.body2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Superlikes',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.star,
            'Stand Out',
            'Your Superlike shows you\'re really interested and gets their attention',
          ),
          _buildInfoItem(
            Icons.notifications_active,
            'Get Noticed',
            'They\'ll see you Superliked them and are 3x more likely to match',
          ),
          _buildInfoItem(
            Icons.favorite,
            'Express Interest',
            'Show someone you\'re seriously interested, not just casually browsing',
          ),
          _buildInfoItem(
            Icons.refresh,
            'Never Expire',
            'Your Superlikes never expire, use them whenever you want',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 4),
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
            onPressed: _loadData,
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

