import 'package:flutter/material.dart';
import '../../services/api_services/account_management_api_service.dart';
import '../../services/auth_service.dart';
import '../../services/token_management_service.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Account Management Screen
/// 
/// Features:
/// - Change email
/// - Change password
/// - Deactivate account
/// - Delete account
class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({Key? key}) : super(key: key);

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  late AccountManagementApiService _apiService;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _apiService = AccountManagementApiService(
      authService: _authService,
    );
  }

  Future<void> _changeEmail() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _ChangeEmailDialog(),
    );

    if (result != null) {
      try {
        await _apiService.updateEmail(
          newEmail: result['email']!,
          password: result['password']!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email updated successfully'),
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
  }

  Future<void> _changePassword() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _ChangePasswordDialog(),
    );

    if (result != null) {
      try {
        await _apiService.updatePassword(
          currentPassword: result['current']!,
          newPassword: result['new']!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully'),
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
  }

  Future<void> _deactivateAccount() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _DeactivateAccountDialog(),
    );

    if (result != null) {
      try {
        await _apiService.deactivateAccount(
          password: result['password']!,
          reason: result['reason'],
        );

        await TokenManagementService.logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
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
  }

  Future<void> _deleteAccount() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _DeleteAccountDialog(),
    );

    if (result != null) {
      try {
        await _apiService.deleteAccount(
          password: result['password']!,
          reason: result['reason'],
        );

        await TokenManagementService.logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        title: Text(
          'Manage Account',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Security
          _buildSectionTitle('Account Security'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.navbarBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.email,
                  title: 'Change Email',
                  subtitle: 'Update your email address',
                  onTap: _changeEmail,
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildActionTile(
                  icon: Icons.lock,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: _changePassword,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionTitle('Danger Zone'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.navbarBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.pause_circle,
                  title: 'Deactivate Account',
                  subtitle: 'Temporarily deactivate your account',
                  color: Colors.orange,
                  onTap: _deactivateAccount,
                ),
                const Divider(height: 1, color: Colors.white12),
                _buildActionTile(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  color: Colors.red,
                  onTap: _deleteAccount,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Deactivating or deleting your account is permanent and cannot be undone. Please proceed with caution.',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white70,
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

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    final tileColor = color ?? AppColors.primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: tileColor, size: 24),
      title: Text(
        title,
        style: AppTypography.body1.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(
          color: Colors.white54,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white38,
      ),
      onTap: onTap,
    );
  }
}

// Change Email Dialog
class _ChangeEmailDialog extends StatefulWidget {
  const _ChangeEmailDialog();

  @override
  State<_ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<_ChangeEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navbarBackground,
      title: Text(
        'Change Email',
        style: AppTypography.h4.copyWith(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              style: AppTypography.body1.copyWith(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'New Email',
                labelStyle: AppTypography.body2.copyWith(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              style: AppTypography.body1.copyWith(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: AppTypography.body2.copyWith(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
          ],
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'email': _emailController.text,
                'password': _passwordController.text,
              });
            }
          },
          child: Text(
            'Update',
            style: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// Change Password Dialog
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navbarBackground,
      title: Text(
        'Change Password',
        style: AppTypography.h4.copyWith(color: Colors.white),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                style: AppTypography.body1.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle:
                      AppTypography.body2.copyWith(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                style: AppTypography.body1.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle:
                      AppTypography.body2.copyWith(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: AppTypography.body1.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle:
                      AppTypography.body2.copyWith(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'current': _currentPasswordController.text,
                'new': _newPasswordController.text,
              });
            }
          },
          child: Text(
            'Update',
            style: AppTypography.button.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// Deactivate Account Dialog
class _DeactivateAccountDialog extends StatefulWidget {
  const _DeactivateAccountDialog();

  @override
  State<_DeactivateAccountDialog> createState() =>
      _DeactivateAccountDialogState();
}

class _DeactivateAccountDialogState extends State<_DeactivateAccountDialog> {
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navbarBackground,
      title: Text(
        'Deactivate Account',
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
                      'Your profile will be hidden and you can reactivate later',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              style: AppTypography.body1.copyWith(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Reason (Optional)',
                labelStyle: AppTypography.body2.copyWith(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: AppTypography.body1.copyWith(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: AppTypography.body2.copyWith(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
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
          onPressed: () {
            if (_passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter your password'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'password': _passwordController.text,
              'reason': _reasonController.text,
            });
          },
          child: Text(
            'Deactivate',
            style: AppTypography.button.copyWith(color: Colors.orange),
          ),
        ),
      ],
    );
  }
}

// Delete Account Dialog
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.navbarBackground,
      title: Text(
        'Delete Account',
        style: AppTypography.h4.copyWith(color: Colors.red),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action is permanent and cannot be undone!',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              style: AppTypography.body1.copyWith(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Reason (Optional)',
                labelStyle: AppTypography.body2.copyWith(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: AppTypography.body1.copyWith(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: AppTypography.body2.copyWith(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _confirmed,
              onChanged: (value) => setState(() => _confirmed = value ?? false),
              title: Text(
                'I understand this action is permanent',
                style: AppTypography.body2.copyWith(color: Colors.white),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.red,
            ),
          ],
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
          onPressed: !_confirmed
              ? null
              : () {
                  if (_passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    'password': _passwordController.text,
                    'reason': _reasonController.text,
                  });
                },
          child: Text(
            'Delete Forever',
            style: AppTypography.button.copyWith(
              color: _confirmed ? Colors.red : Colors.white38,
            ),
          ),
        ),
      ],
    );
  }
}

