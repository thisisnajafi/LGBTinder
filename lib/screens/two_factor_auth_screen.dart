import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_services/two_factor_api_service.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Two-Factor Authentication Screen
/// 
/// Features:
/// - Enable/disable 2FA
/// - QR code for authenticator apps
/// - Backup codes
/// - Verification
class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({Key? key}) : super(key: key);

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  late TwoFactorApiService _apiService;
  bool _isLoading = true;
  bool _is2FAEnabled = false;
  String? _secret;
  String? _qrCode;
  List<String> _backupCodes = [];

  @override
  void initState() {
    super.initState();
    _apiService = TwoFactorApiService(
      authService: AuthService(),
    );
    _load2FAStatus();
  }

  Future<void> _load2FAStatus() async {
    setState(() => _isLoading = true);

    try {
      final status = await _apiService.get2FAStatus();
      setState(() {
        _is2FAEnabled = status['enabled'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading 2FA status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _enable2FA() async {
    try {
      final result = await _apiService.enable2FA();
      setState(() {
        _secret = result['secret'];
        _qrCode = result['qr_code'];
      });

      if (mounted) {
        _showSetupDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disable2FA() async {
    final password = await _showPasswordDialog();
    if (password == null) return;

    try {
      await _apiService.disable2FA(password: password);
      setState(() => _is2FAEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('2FA has been disabled'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _Setup2FADialog(
        qrCode: _qrCode,
        secret: _secret,
        onVerified: (backupCodes) {
          setState(() {
            _is2FAEnabled = true;
            _backupCodes = backupCodes;
          });
          _showBackupCodesDialog(backupCodes);
        },
        apiService: _apiService,
      ),
    );
  }

  void _showBackupCodesDialog(List<String> codes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _BackupCodesDialog(codes: codes),
    );
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Confirm Password',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: AppTypography.body1.copyWith(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: AppTypography.body2.copyWith(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              'Confirm',
              style: AppTypography.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _regenerateBackupCodes() async {
    try {
      final codes = await _apiService.generateBackupCodes();
      setState(() => _backupCodes = codes);
      _showBackupCodesDialog(codes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        title: Text(
          'Two-Factor Authentication',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.security,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Extra Security Layer',
                              style: AppTypography.body1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Protect your account with an additional verification step',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2FA Toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.navbarBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      'Two-Factor Authentication',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _is2FAEnabled ? 'Enabled' : 'Disabled',
                      style: AppTypography.caption.copyWith(
                        color: _is2FAEnabled ? Colors.green : Colors.white54,
                      ),
                    ),
                    value: _is2FAEnabled,
                    onChanged: (value) {
                      if (value) {
                        _enable2FA();
                      } else {
                        _disable2FA();
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                // How it Works
                _buildSectionTitle('How It Works'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navbarBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStep(
                        number: '1',
                        title: 'Enable 2FA',
                        description:
                            'Turn on two-factor authentication above',
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        number: '2',
                        title: 'Scan QR Code',
                        description:
                            'Use an authenticator app to scan the QR code',
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        number: '3',
                        title: 'Enter Code',
                        description:
                            'Enter the 6-digit code from your authenticator app',
                      ),
                      const SizedBox(height: 12),
                      _buildStep(
                        number: '4',
                        title: 'Save Backup Codes',
                        description:
                            'Store backup codes in a safe place',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Backup Codes
                if (_is2FAEnabled) ...[
                  _buildSectionTitle('Backup Codes'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.navbarBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: const Icon(
                        Icons.code,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Generate Backup Codes',
                        style: AppTypography.body1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Use these codes if you lose access to your authenticator',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                      ),
                      onTap: _regenerateBackupCodes,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Recommended Apps
                _buildSectionTitle('Recommended Authenticator Apps'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.navbarBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildAppItem('Google Authenticator'),
                      _buildAppItem('Microsoft Authenticator'),
                      _buildAppItem('Authy'),
                      _buildAppItem('1Password'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.h5.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.body1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppItem(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _Setup2FADialog extends StatefulWidget {
  final String? qrCode;
  final String? secret;
  final Function(List<String>) onVerified;
  final TwoFactorApiService apiService;

  const _Setup2FADialog({
    required this.qrCode,
    required this.secret,
    required this.onVerified,
    required this.apiService,
  });

  @override
  State<_Setup2FADialog> createState() => _Setup2FADialogState();
}

class _Setup2FADialogState extends State<_Setup2FADialog> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await widget.apiService.verify2FASetup(
        code: _codeController.text,
      );
      
      final backupCodes = (result['backup_codes'] as List<dynamic>?)
              ?.map((code) => code.toString())
              .toList() ??
          [];

      if (mounted) {
        Navigator.pop(context);
        widget.onVerified(backupCodes);
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navbarBackground,
      title: Text(
        'Setup 2FA',
        style: AppTypography.h4.copyWith(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.qrCode != null) ...[
              Text(
                'Scan this QR code with your authenticator app',
                textAlign: TextAlign.center,
                style: AppTypography.body2.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: widget.qrCode!,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
            ],
            if (widget.secret != null) ...[
              const SizedBox(height: 16),
              Text(
                'Or enter this code manually:',
                style: AppTypography.caption.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              SelectableText(
                widget.secret!,
                style: AppTypography.body2.copyWith(
                  color: AppColors.primary,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              style: AppTypography.body1.copyWith(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter 6-digit code',
                labelStyle: AppTypography.body2.copyWith(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTypography.button.copyWith(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: _isVerifying ? null : _verify,
          child: _isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Verify',
                  style: AppTypography.button.copyWith(color: AppColors.primary),
                ),
        ),
      ],
    );
  }
}

class _BackupCodesDialog extends StatelessWidget {
  final List<String> codes;

  const _BackupCodesDialog({required this.codes});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navbarBackground,
      title: Text(
        'Backup Codes',
        style: AppTypography.h4.copyWith(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Save these codes in a safe place',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: codes
                    .map((code) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: SelectableText(
                            code,
                            style: AppTypography.body2.copyWith(
                              color: Colors.white,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: codes.join('\n')),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Codes copied to clipboard'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Done',
            style: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

