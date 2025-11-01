import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/auth_service.dart';
import '../../services/token_management_service.dart';
import '../notification_settings_screen.dart';
import '../two_factor_auth_screen.dart';
import '../active_sessions_screen.dart';
import '../safety_center_screen.dart';
import '../emergency_contacts_screen.dart';
import 'account_management_screen.dart';

/// Comprehensive Settings Screen
/// 
/// Sections:
/// - Account Settings
/// - Privacy & Safety
/// - Notifications
/// - Preferences
/// - Support & About
class ComprehensiveSettingsScreen extends StatefulWidget {
  const ComprehensiveSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ComprehensiveSettingsScreen> createState() =>
      _ComprehensiveSettingsScreenState();
}

class _ComprehensiveSettingsScreenState
    extends State<ComprehensiveSettingsScreen> {
  final AuthService _authService = AuthService();

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Logout',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: AppTypography.button.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TokenManagementService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
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
          'Settings',
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
          // Account Settings Section
          _buildSectionTitle('Account Settings'),
          const SizedBox(height: 12),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.person,
              title: 'Manage Account',
              subtitle: 'Email, password, account status',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountManagementScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.devices,
              title: 'Active Sessions',
              subtitle: 'Manage logged-in devices',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActiveSessionsScreen(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // Privacy & Safety Section
          _buildSectionTitle('Privacy & Safety'),
          const SizedBox(height: 12),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              subtitle: 'Add extra security layer',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TwoFactorAuthScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.shield,
              title: 'Safety Center',
              subtitle: 'Tips and resources for staying safe',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SafetyCenterScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.contacts,
              title: 'Emergency Contacts',
              subtitle: 'Manage trusted contacts',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsScreen(),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.visibility_off,
              title: 'Privacy Settings',
              subtitle: 'Control your visibility and data',
              onTap: () {
                // Navigate to privacy settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings coming soon'),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionTitle('Notifications'),
          const SizedBox(height: 12),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.notifications,
              title: 'Notification Preferences',
              subtitle: 'Manage notification settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionTitle('Preferences'),
          const SizedBox(height: 12),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English (US)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language settings coming soon'),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.dark_mode,
              title: 'Theme',
              subtitle: 'Dark mode',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Theme settings coming soon'),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // Support & About Section
          _buildSectionTitle('Support & About'),
          const SizedBox(height: 12),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.help,
              title: 'Help Center',
              subtitle: 'Get help and support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help center coming soon'),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.article,
              title: 'Terms of Service',
              subtitle: 'Read our terms',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms of Service coming soon'),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy coming soon'),
                  ),
                );
              },
            ),
            _buildSettingsTile(
              icon: Icons.info,
              title: 'About',
              subtitle: 'LGBTinder v1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'LGBTinder',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      '© 2025 LGBTinder. All rights reserved.',
                );
              },
            ),
          ]),

          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Logout',
                style: AppTypography.button.copyWith(color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 16),
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

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
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

