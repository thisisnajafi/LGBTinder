import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ProfileSettings extends StatelessWidget {
  final Map<String, bool> preferences;
  final Function(String, bool) onPreferenceChanged;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final VoidCallback onPrivacySettings;
  final VoidCallback onNotificationSettings;

  const ProfileSettings({
    Key? key,
    required this.preferences,
    required this.onPreferenceChanged,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onPrivacySettings,
    required this.onNotificationSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTypography.titleMediumStyle,
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Preferences',
            children: [
              _SettingsSwitch(
                title: 'Show Online Status',
                subtitle: 'Let others see when you\'re active',
                value: preferences['showOnlineStatus'] ?? false,
                onChanged: (value) => onPreferenceChanged('showOnlineStatus', value),
              ),
              _SettingsSwitch(
                title: 'Show Last Seen',
                subtitle: 'Let others see when you were last active',
                value: preferences['showLastSeen'] ?? false,
                onChanged: (value) => onPreferenceChanged('showLastSeen', value),
              ),
              _SettingsSwitch(
                title: 'Show Distance',
                subtitle: 'Let others see how far you are',
                value: preferences['showDistance'] ?? false,
                onChanged: (value) => onPreferenceChanged('showDistance', value),
              ),
              _SettingsSwitch(
                title: 'Show Age',
                subtitle: 'Let others see your age',
                value: preferences['showAge'] ?? false,
                onChanged: (value) => onPreferenceChanged('showAge', value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsButton(
                title: 'Privacy Settings',
                icon: Icons.privacy_tip,
                onTap: onPrivacySettings,
              ),
              _SettingsButton(
                title: 'Notification Settings',
                icon: Icons.notifications,
                onTap: onNotificationSettings,
              ),
              _SettingsButton(
                title: 'Logout',
                icon: Icons.logout,
                onTap: onLogout,
                isDestructive: true,
              ),
              _SettingsButton(
                title: 'Delete Account',
                icon: Icons.delete_forever,
                onTap: onDeleteAccount,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleSmallStyle.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMediumStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmallStyle.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (title == 'Logout') {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return _FadeConfirmDialog(
                title: 'Logout',
                message: 'Are you sure you want to logout?',
                confirmText: 'Logout',
                onConfirm: () => Navigator.of(context).pop(true),
                onCancel: () => Navigator.of(context).pop(false),
              );
            },
          );
          if (result == true) {
            onTap();
          }
        } else {
          onTap();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.errorLight : AppColors.primaryLight,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTypography.bodyMediumStyle.copyWith(
                color: isDestructive ? AppColors.errorLight : null,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondaryLight,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _FadeConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _FadeConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_FadeConfirmDialog> createState() => _FadeConfirmDialogState();
}

class _FadeConfirmDialogState extends State<_FadeConfirmDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacity.value,
          child: child,
        ),
        child: AlertDialog(
          backgroundColor: AppColors.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(widget.title, style: TextStyle(color: AppColors.primaryLight)),
          content: Text(widget.message, style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: widget.onConfirm,
              child: Text(widget.confirmText),
            ),
          ],
        ),
      ),
    );
  }
} 