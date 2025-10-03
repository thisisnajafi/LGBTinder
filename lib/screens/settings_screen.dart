import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'notification_settings_screen.dart';
import 'safety_settings_screen.dart';
import 'accessibility_settings_screen.dart';
import 'rainbow_theme_settings_screen.dart';
import 'haptic_feedback_settings_screen.dart';
import 'animation_settings_screen.dart';
import 'pull_to_refresh_settings_screen.dart';
import 'skeleton_loader_settings_screen.dart';
import 'image_compression_settings_screen.dart';
import 'media_picker_settings_screen.dart';
import 'legal/privacy_policy_screen.dart';
import 'legal/terms_of_service_screen.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account & Privacy'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Privacy Settings',
                'Control your privacy and safety preferences',
                Icons.privacy_tip,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SafetySettingsScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                'Notification Settings',
                'Manage your notification preferences',
                Icons.notifications,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('Appearance & Experience'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Accessibility Settings',
                'Customize accessibility features',
                Icons.accessibility,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccessibilitySettingsScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                'Rainbow Theme Settings',
                'Customize rainbow theme preferences',
                Icons.palette,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RainbowThemeSettingsScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                'Animation Settings',
                'Control app animations and transitions',
                Icons.animation,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnimationSettingsScreen(),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('Media & Performance'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Image Compression Settings',
                'Configure image compression preferences',
                Icons.compress,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImageCompressionSettingsScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                'Media Picker Settings',
                'Customize media selection options',
                Icons.photo_library,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MediaPickerSettingsScreen(),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('Interaction & Feedback'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Haptic Feedback Settings',
                'Configure haptic feedback preferences',
                Icons.vibration,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HapticFeedbackSettingsScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                'Pull to Refresh Settings',
                'Customize pull-to-refresh behavior',
                Icons.refresh,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PullToRefreshSettingsScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                'Skeleton Loader Settings',
                'Configure loading skeleton preferences',
                Icons.image_not_supported_outlined,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SkeletonLoaderSettingsScreen(),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('Support & Legal'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Help & Support',
                'Get help and contact support',
                Icons.help_outline,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.policy,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
              _buildSettingsTile(
                'Terms of Service',
                'Read our terms of service',
                Icons.description,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsOfServiceScreen(),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionHeader('Account Actions'),
            _buildSettingsCard([
              _buildSettingsTile(
                'Manage Subscription',
                'View and manage your premium subscription',
                Icons.card_membership,
                () => Navigator.pushNamed(context, '/subscription-management'),
              ),
              _buildSettingsTile(
                'Logout',
                'Sign out of your account',
                Icons.logout,
                () => _showLogoutDialog(),
                isDestructive: true,
              ),
              _buildSettingsTile(
                'Delete Account',
                'Permanently delete your account',
                Icons.delete_forever,
                () => _showDeleteAccountDialog(),
                isDestructive: true,
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.titleSmallStyle.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      color: isDestructive ? Colors.red : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout functionality coming soon!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Text(
              'Logout',
              style: AppTypography.body1.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Delete Account',
          style: AppTypography.h4.copyWith(color: Colors.red),
        ),
        content: Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete account functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete account functionality coming soon!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              'Delete',
              style: AppTypography.body1.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
