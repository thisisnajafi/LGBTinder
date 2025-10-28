import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/api_services/payment_api_service.dart';

/// Retention Offer Dialog
/// 
/// Shows special offers to retain users who are about to cancel their subscription
/// - Discounted subscription rates
/// - Free trial extensions
/// - Feature highlights
/// - Alternative plans
class RetentionOfferDialog extends StatefulWidget {
  final String currentPlanId;
  final Function()? onAcceptOffer;
  final Function()? onDeclineOffer;

  const RetentionOfferDialog({
    Key? key,
    required this.currentPlanId,
    this.onAcceptOffer,
    this.onDeclineOffer,
  }) : super(key: key);

  @override
  State<RetentionOfferDialog> createState() => _RetentionOfferDialogState();

  /// Show retention offer dialog
  static Future<bool?> show(
    BuildContext context, {
    required String currentPlanId,
    Function()? onAcceptOffer,
    Function()? onDeclineOffer,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RetentionOfferDialog(
        currentPlanId: currentPlanId,
        onAcceptOffer: onAcceptOffer,
        onDeclineOffer: onDeclineOffer,
      ),
    );
  }
}

class _RetentionOfferDialogState extends State<RetentionOfferDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  int _selectedOfferIndex = 0;

  final List<RetentionOffer> _offers = [
    RetentionOffer(
      id: 'discount_50',
      title: '50% Off for 3 Months',
      description: 'Continue your premium experience at half price',
      originalPrice: '\$29.99',
      discountedPrice: '\$14.99',
      savingsText: 'Save \$15/month',
      features: [
        'Keep all premium features',
        'Unlimited likes & superlikes',
        'See who liked you',
        'Advanced filters',
      ],
      badge: 'BEST VALUE',
      badgeColor: AppColors.success,
    ),
    RetentionOffer(
      id: 'pause_subscription',
      title: 'Pause Your Subscription',
      description: 'Take a break and come back anytime',
      originalPrice: null,
      discountedPrice: 'Free',
      savingsText: 'No charges while paused',
      features: [
        'Pause for up to 3 months',
        'Keep your current plan',
        'Resume anytime',
        'No reactivation fees',
      ],
      badge: 'FLEXIBLE',
      badgeColor: AppColors.primary,
    ),
    RetentionOffer(
      id: 'downgrade_plan',
      title: 'Switch to Basic Plan',
      description: 'Keep essential features at a lower cost',
      originalPrice: '\$29.99',
      discountedPrice: '\$9.99',
      savingsText: 'Save \$20/month',
      features: [
        'Unlimited likes',
        'See who liked you',
        'Basic filters',
        'Ad-free experience',
      ],
      badge: 'AFFORDABLE',
      badgeColor: AppColors.warning,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _acceptOffer() {
    widget.onAcceptOffer?.call();
    Navigator.of(context).pop(true);
  }

  void _declineOffer() {
    widget.onDeclineOffer?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
            decoration: BoxDecoration(
              color: AppColors.navbarBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildOfferList(),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.2),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            'We\'d hate to see you go!',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Here are some special offers just for you',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _offers.length,
      itemBuilder: (context, index) {
        return _buildOfferCard(_offers[index], index);
      },
    );
  }

  Widget _buildOfferCard(RetentionOffer offer, int index) {
    final isSelected = _selectedOfferIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOfferIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge and selection indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: offer.badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.badge,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.circle_outlined,
                    color: Colors.white.withOpacity(0.3),
                    size: 24,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              offer.title,
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Description
            Text(
              offer.description,
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 12),

            // Pricing
            Row(
              children: [
                if (offer.originalPrice != null)
                  Text(
                    offer.originalPrice!,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white54,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (offer.originalPrice != null) const SizedBox(width: 8),
                Text(
                  offer.discountedPrice,
                  style: AppTypography.h4.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    offer.savingsText,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Features
            ...offer.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Accept button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _acceptOffer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Accept Offer',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Decline button
          TextButton(
            onPressed: _declineOffer,
            child: Text(
              'No thanks, continue cancellation',
              style: AppTypography.body2.copyWith(
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Retention Offer Model
class RetentionOffer {
  final String id;
  final String title;
  final String description;
  final String? originalPrice;
  final String discountedPrice;
  final String savingsText;
  final List<String> features;
  final String badge;
  final Color badgeColor;

  RetentionOffer({
    required this.id,
    required this.title,
    required this.description,
    this.originalPrice,
    required this.discountedPrice,
    required this.savingsText,
    required this.features,
    required this.badge,
    required this.badgeColor,
  });
}

