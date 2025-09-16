import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/social_login_service.dart';
import '../../utils/api_error_handler.dart';

class SocialLoginButtons extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSuccess;
  final Function(String)? onError;
  final bool showLabels;
  final double spacing;

  const SocialLoginButtons({
    Key? key,
    this.onSuccess,
    this.onError,
    this.showLabels = true,
    this.spacing = 16.0,
  }) : super(key: key);

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign In Button
        _buildSocialButton(
          provider: 'Google',
          icon: Icons.g_mobiledata,
          color: Colors.white,
          textColor: Colors.black87,
          isLoading: _isGoogleLoading,
          onTap: _signInWithGoogle,
        ),
        
        SizedBox(height: widget.spacing),
        
        // Apple Sign In Button
        _buildSocialButton(
          provider: 'Apple',
          icon: Icons.apple,
          color: Colors.black,
          textColor: Colors.white,
          isLoading: _isAppleLoading,
          onTap: _signInWithApple,
        ),
        
        SizedBox(height: widget.spacing),
        
        // Facebook Sign In Button
        _buildSocialButton(
          provider: 'Facebook',
          icon: Icons.facebook,
          color: const Color(0xFF1877F2),
          textColor: Colors.white,
          isLoading: _isFacebookLoading,
          onTap: _signInWithFacebook,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String provider,
    required IconData icon,
    required Color color,
    required Color textColor,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: textColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with $provider',
                    style: AppTypography.body1.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      final result = await SocialLoginService.signInWithGoogle();
      
      if (result != null) {
        widget.onSuccess?.call(result);
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      final errorMessage = ApiErrorHandler.getErrorMessage(e);
      widget.onError?.call(errorMessage);
      HapticFeedback.heavyImpact();
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isAppleLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      final result = await SocialLoginService.signInWithApple();
      
      if (result != null) {
        widget.onSuccess?.call(result);
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      final errorMessage = ApiErrorHandler.getErrorMessage(e);
      widget.onError?.call(errorMessage);
      HapticFeedback.heavyImpact();
    } finally {
      setState(() {
        _isAppleLoading = false;
      });
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isFacebookLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      final result = await SocialLoginService.signInWithFacebook();
      
      if (result != null) {
        widget.onSuccess?.call(result);
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      final errorMessage = ApiErrorHandler.getErrorMessage(e);
      widget.onError?.call(errorMessage);
      HapticFeedback.heavyImpact();
    } finally {
      setState(() {
        _isFacebookLoading = false;
      });
    }
  }
}

class SocialLoginButtonsCompact extends StatelessWidget {
  final Function(Map<String, dynamic>)? onSuccess;
  final Function(String)? onError;
  final double size;

  const SocialLoginButtonsCompact({
    Key? key,
    this.onSuccess,
    this.onError,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactButton(
          provider: 'Google',
          icon: Icons.g_mobiledata,
          color: Colors.white,
          onTap: () => _signIn(context, SocialLoginService.signInWithGoogle),
        ),
        _buildCompactButton(
          provider: 'Apple',
          icon: Icons.apple,
          color: Colors.black,
          onTap: () => _signIn(context, SocialLoginService.signInWithApple),
        ),
        _buildCompactButton(
          provider: 'Facebook',
          icon: Icons.facebook,
          color: const Color(0xFF1877F2),
          onTap: () => _signIn(context, SocialLoginService.signInWithFacebook),
        ),
      ],
    );
  }

  Widget _buildCompactButton({
    required String provider,
    required IconData icon,
    required Color color,
    required Future<Map<String, dynamic>?> Function() onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: provider == 'Apple' ? Colors.white : Colors.black87,
          size: size * 0.5,
        ),
      ),
    );
  }

  Future<void> _signIn(
    BuildContext context,
    Future<Map<String, dynamic>?> Function() signInFunction,
  ) async {
    try {
      HapticFeedback.lightImpact();
      final result = await signInFunction();
      
      if (result != null) {
        onSuccess?.call(result);
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      final errorMessage = ApiErrorHandler.getErrorMessage(e);
      onError?.call(errorMessage);
      HapticFeedback.heavyImpact();
    }
  }
}

class SocialAccountManager extends StatefulWidget {
  final String userToken;
  final Function(List<SocialAccount>)? onAccountsChanged;

  const SocialAccountManager({
    Key? key,
    required this.userToken,
    this.onAccountsChanged,
  }) : super(key: key);

  @override
  State<SocialAccountManager> createState() => _SocialAccountManagerState();
}

class _SocialAccountManagerState extends State<SocialAccountManager> {
  List<SocialAccount> _linkedAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLinkedAccounts();
  }

  Future<void> _loadLinkedAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accounts = await SocialLoginService.getLinkedAccounts(
        userToken: widget.userToken,
      );
      
      setState(() {
        _linkedAccounts = accounts.map((data) => SocialAccount.fromJson(data)).toList();
        _isLoading = false;
      });
      
      widget.onAccountsChanged?.call(_linkedAccounts);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Failed to load linked accounts',
      );
    }
  }

  Future<void> _linkAccount(String provider) async {
    try {
      Map<String, dynamic>? result;
      
      switch (provider.toLowerCase()) {
        case 'google':
          result = await SocialLoginService.signInWithGoogle();
          break;
        case 'apple':
          result = await SocialLoginService.signInWithApple();
          break;
        case 'facebook':
          result = await SocialLoginService.signInWithFacebook();
          break;
      }
      
      if (result != null && result['access_token'] != null) {
        final success = await SocialLoginService.linkSocialAccount(
          provider: provider,
          accessToken: result['access_token'],
          userToken: widget.userToken,
        );
        
        if (success) {
          _loadLinkedAccounts();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$provider account linked successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Failed to link $provider account',
      );
    }
  }

  Future<void> _unlinkAccount(String provider) async {
    try {
      final success = await SocialLoginService.unlinkSocialAccount(
        provider: provider,
        userToken: widget.userToken,
      );
      
      if (success) {
        _loadLinkedAccounts();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider account unlinked successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ApiErrorHandler.handleApiError(
        context,
        e,
        customMessage: 'Failed to unlink $provider account',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Linked Accounts',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._linkedAccounts.map((account) => _buildAccountTile(account)),
        const SizedBox(height: 16),
        Text(
          'Available Accounts',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._getAvailableProviders().map((provider) => _buildLinkButton(provider)),
      ],
    );
  }

  Widget _buildAccountTile(SocialAccount account) {
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
          Icon(
            _getProviderIcon(account.provider),
            color: _getProviderColor(account.provider),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.providerDisplayName,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  account.email,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _unlinkAccount(account.provider),
            icon: const Icon(Icons.link_off, color: Colors.red),
            tooltip: 'Unlink account',
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(String provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton.icon(
        onPressed: () => _linkAccount(provider),
        icon: Icon(_getProviderIcon(provider)),
        label: Text('Link $provider Account'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _getProviderColor(provider)),
          foregroundColor: _getProviderColor(provider),
        ),
      ),
    );
  }

  List<String> _getAvailableProviders() {
    final linkedProviders = _linkedAccounts.map((account) => account.provider.toLowerCase()).toList();
    return ['Google', 'Apple', 'Facebook'].where((provider) => !linkedProviders.contains(provider.toLowerCase())).toList();
  }

  IconData _getProviderIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.account_circle;
    }
  }

  Color _getProviderColor(String provider) {
    switch (provider.toLowerCase()) {
      case 'google':
        return Colors.red;
      case 'apple':
        return Colors.black;
      case 'facebook':
        return const Color(0xFF1877F2);
      default:
        return AppColors.primary;
    }
  }
}
