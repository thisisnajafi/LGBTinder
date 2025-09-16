import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/premium_service.dart';
import '../providers/auth_provider.dart';
import '../utils/api_error_handler.dart';

class PremiumFeaturesScreen extends StatefulWidget {
  const PremiumFeaturesScreen({Key? key}) : super(key: key);

  @override
  State<PremiumFeaturesScreen> createState() => _PremiumFeaturesScreenState();
}

class _PremiumFeaturesScreenState extends State<PremiumFeaturesScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _premiumStatus = {};
  List<PremiumFeature> _features = [];
  List<PremiumPlan> _plans = [];
  Map<String, dynamic> _usageStats = {};

  @override
  void initState() {
    super.initState();
    _loadPremiumData();
  }

  Future<void> _loadPremiumData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Load premium data in parallel
      final results = await Future.wait([
        PremiumService.getPremiumStatus(accessToken: accessToken),
        PremiumService.getPremiumPlans(accessToken: accessToken),
        PremiumService.getUsageStats(accessToken: accessToken),
      ]);

      setState(() {
        _premiumStatus = results[0] as Map<String, dynamic>;
        _plans = (results[1] as List<Map<String, dynamic>>)
            .map((plan) => PremiumPlan.fromJson(plan))
            .toList();
        _usageStats = results[2] as Map<String, dynamic>;
        _features = _buildPremiumFeatures();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Failed to load premium features. Please try again.',
        onRetry: _loadPremiumData,
      );
    }
  }

  List<PremiumFeature> _buildPremiumFeatures() {
    final isPremium = _premiumStatus['is_premium'] ?? false;
    final limits = _usageStats['limits'] as Map<String, dynamic>? ?? {};
    final used = _usageStats['used'] as Map<String, dynamic>? ?? {};

    return [
      PremiumFeature(
        id: 'likes',
        name: 'Likes',
        description: 'Like unlimited profiles',
        icon: 'favorite',
        isUnlimited: isPremium,
        limit: limits['likes'] as int?,
        used: used['likes'] as int?,
        isAvailable: true,
      ),
      PremiumFeature(
        id: 'super_likes',
        name: 'Super Likes',
        description: 'Stand out with super likes',
        icon: 'star',
        isUnlimited: isPremium,
        limit: limits['super_likes'] as int?,
        used: used['super_likes'] as int?,
        isAvailable: true,
      ),
      PremiumFeature(
        id: 'rewinds',
        name: 'Rewinds',
        description: 'Undo your last swipe',
        icon: 'undo',
        isUnlimited: isPremium,
        limit: limits['rewinds'] as int?,
        used: used['rewinds'] as int?,
        isAvailable: true,
      ),
      PremiumFeature(
        id: 'boost',
        name: 'Boost',
        description: 'Get more profile views',
        icon: 'trending_up',
        isUnlimited: isPremium,
        limit: limits['boost'] as int?,
        used: used['boost'] as int?,
        isAvailable: true,
      ),
      PremiumFeature(
        id: 'advanced_filters',
        name: 'Advanced Filters',
        description: 'Filter by education, job, and more',
        icon: 'filter_list',
        isUnlimited: isPremium,
        limit: null,
        used: null,
        isAvailable: isPremium,
      ),
      PremiumFeature(
        id: 'read_receipts',
        name: 'Read Receipts',
        description: 'See when your messages are read',
        icon: 'visibility',
        isUnlimited: isPremium,
        limit: null,
        used: null,
        isAvailable: isPremium,
      ),
      PremiumFeature(
        id: 'incognito_mode',
        name: 'Incognito Mode',
        description: 'Browse profiles anonymously',
        icon: 'visibility_off',
        isUnlimited: isPremium,
        limit: null,
        used: null,
        isAvailable: isPremium,
      ),
      PremiumFeature(
        id: 'unlimited_matches',
        name: 'Unlimited Matches',
        description: 'See all your matches',
        icon: 'people',
        isUnlimited: isPremium,
        limit: limits['matches'] as int?,
        used: used['matches'] as int?,
        isAvailable: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Premium Features'),
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
                  _buildPremiumStatus(),
                  const SizedBox(height: 24),
                  _buildPremiumPlans(),
                  const SizedBox(height: 24),
                  _buildPremiumFeatures(),
                  const SizedBox(height: 24),
                  _buildUsageStats(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildPremiumStatus() {
    final isPremium = _premiumStatus['is_premium'] ?? false;
    final planName = _premiumStatus['plan_name'] as String? ?? 'Free';
    final expiresAt = _premiumStatus['expires_at'] as String?;

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
            isPremium ? 'Premium Member' : 'Free Member',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            planName,
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
          ),
          if (expiresAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Expires: ${_formatDate(expiresAt)}',
              style: AppTypography.caption.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upgrade Plans',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._plans.map((plan) => _buildPlanCard(plan)),
      ],
    );
  }

  Widget _buildPlanCard(PremiumPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: plan.isPopular ? AppColors.primary : Colors.white24,
          width: plan.isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name,
                          style: AppTypography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (plan.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'POPULAR',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.description,
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.formattedPrice,
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    plan.formattedInterval,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...plan.features.map((feature) => _buildFeatureItem(feature)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _purchasePlan(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: plan.isPopular ? AppColors.primary : Colors.white24,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Upgrade to ${plan.name}',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Features',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._features.map((feature) => _buildFeatureCard(feature)),
      ],
    );
  }

  Widget _buildFeatureCard(PremiumFeature feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: feature.isAvailable
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getFeatureIcon(feature.icon),
              color: feature.isAvailable ? AppColors.primary : Colors.white70,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.name,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
                if (!feature.isUnlimited && feature.limit != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: feature.usagePercentage,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            feature.isNearLimit ? Colors.orange : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        feature.usageText,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(
            feature.isAvailable ? Icons.check_circle : Icons.lock,
            color: feature.isAvailable ? Colors.green : Colors.white70,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStats() {
    final isPremium = _premiumStatus['is_premium'] ?? false;
    
    if (isPremium) {
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
            'Usage This Month',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._features.where((f) => !f.isUnlimited && f.limit != null).map(
            (feature) => _buildUsageItem(feature),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(PremiumFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            _getFeatureIcon(feature.icon),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature.name,
              style: AppTypography.body2.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          Text(
            feature.usageText,
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'undo':
        return Icons.undo;
      case 'trending_up':
        return Icons.trending_up;
      case 'filter_list':
        return Icons.filter_list;
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'people':
        return Icons.people;
      default:
        return Icons.star;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _purchasePlan(PremiumPlan plan) {
    // TODO: Navigate to payment screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment integration for ${plan.name} coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
