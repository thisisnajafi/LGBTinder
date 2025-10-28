import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/api_services/payment_api_service.dart';
import '../../services/stripe_payment_service.dart';
import '../../services/token_management_service.dart';

/// Superlike Packs Screen
/// 
/// Purchase superlike packs (5, 25, 60 superlikes)
/// with pricing, discounts, and value display
class SuperlikePacksScreen extends StatefulWidget {
  const SuperlikePacksScreen({Key? key}) : super(key: key);

  @override
  State<SuperlikePacksScreen> createState() => _SuperlikePacksScreenState();
}

class _SuperlikePacksScreenState extends State<SuperlikePacksScreen> {
  List<SuperlikePack> _packs = [];
  int _currentBalance = 0;
  bool _isLoading = true;
  String? _error;
  SuperlikePack? _selectedPack;

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

      // Load packs and balance
      final packsResponse = await PaymentApiService.getSuperlikePacks(token: token);
      final balanceResponse = await PaymentApiService.getSuperlikeBalance(token: token);

      if (!packsResponse.success) {
        throw Exception(packsResponse.error ?? 'Failed to load packs');
      }

      setState(() {
        _packs = packsResponse.packs;
        _currentBalance = balanceResponse.balance;
        _isLoading = false;
        
        // Auto-select best value pack
        _selectedPack = _packs.firstWhere(
          (pack) => pack.isBestValue,
          orElse: () => _packs.isNotEmpty ? _packs[1] : _packs.first,
        );
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePack() async {
    if (_selectedPack == null) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      // Create payment intent and process payment
      final stripeService = StripePaymentService();
      final amountInCents = (_selectedPack!.price * 100).toInt();
      
      final clientSecret = await stripeService.createPaymentIntent(
        amount: amountInCents,
        description: 'Superlike Pack: ${_selectedPack!.name}',
        metadata: {
          'pack_id': _selectedPack!.id,
          'quantity': _selectedPack!.quantity.toString(),
        },
      );

      final result = await stripeService.processPayment(clientSecret: clientSecret);

      Navigator.pop(context); // Close loading dialog

      if (result.success) {
        // Process purchase on backend
        final purchaseResponse = await PaymentApiService.purchaseSuperlikePack(
          token: token,
          packId: _selectedPack!.id,
        );

        if (purchaseResponse.success) {
          _showSuccessDialog();
          _loadData(); // Refresh balance
        } else {
          _showErrorDialog(purchaseResponse.error ?? 'Purchase failed');
        }
      } else {
        if (result.error != 'cancelled') {
          _showErrorDialog(result.message);
        }
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
        title: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Purchase Successful!',
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Text(
          '${_selectedPack!.quantity} superlikes have been added to your account!',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: Text(
              'Start Using',
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
          'Buy Superlikes',
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
            'Failed to load packs',
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
        // Current balance
        _buildBalanceCard(),

        // Info banner
        _buildInfoBanner(),

        // Packs list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _packs.length,
            itemBuilder: (context, index) {
              return _buildPackCard(_packs[index]);
            },
          ),
        ),

        // Purchase button
        _buildPurchaseButton(),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Balance',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_currentBalance Superlikes',
                  style: AppTypography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Stand out with Superlikes! They notify the other person and increase your chances of matching.',
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackCard(SuperlikePack pack) {
    final isSelected = _selectedPack?.id == pack.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPack = pack),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
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
          children: [
            Row(
              children: [
                // Pack icon with quantity
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700),
                        const Color(0xFFFFA500),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 32,
                      ),
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
                
                // Pack details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            pack.name,
                            style: AppTypography.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (pack.isBestValue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BEST VALUE',
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
                      const SizedBox(height: 8),
                      Text(
                        pack.displayPrice,
                        style: AppTypography.h2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pack.discount != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Save ${pack.discount}%',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
            
            // Price per unit
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pack.displayPricePerUnit,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          if (_selectedPack != null) ...[
            Text(
              'Get ${_selectedPack!.quantity} Superlikes for ${_selectedPack!.displayPrice}',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          
          ElevatedButton(
            onPressed: _selectedPack == null ? null : _purchasePack,
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
            'Superlikes never expire',
            style: AppTypography.body3.copyWith(color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

