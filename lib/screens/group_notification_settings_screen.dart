import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_services/group_notifications_api_service.dart';

/// Group Notification Settings Screen
/// 
/// Configure notification preferences for a specific group chat
class GroupNotificationSettingsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupNotificationSettingsScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<GroupNotificationSettingsScreen> createState() =>
      _GroupNotificationSettingsScreenState();
}

class _GroupNotificationSettingsScreenState
    extends State<GroupNotificationSettingsScreen> {
  final GroupNotificationsApiService _apiService =
      GroupNotificationsApiService();

  GroupNotificationSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final settings = await _apiService.getGroupNotificationSettings(widget.groupId);

    setState(() {
      _settings = settings ??
          GroupNotificationSettings(
            groupId: widget.groupId,
          );
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;

    setState(() {
      _isSaving = true;
    });

    final success = await _apiService.updateGroupNotificationSettings(
      groupId: widget.groupId,
      settings: _settings!,
    );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      _showSnackBar('Notification settings updated', isError: false);
    } else {
      _showSnackBar('Failed to update settings', isError: true);
    }
  }

  Future<void> _muteGroup(Duration? duration) async {
    final success = await _apiService.muteGroup(
      groupId: widget.groupId,
      duration: duration,
    );

    if (success) {
      await _loadSettings();
      _showSnackBar(
        duration == null
            ? 'Group muted permanently'
            : 'Group muted for ${_formatDuration(duration)}',
        isError: false,
      );
    } else {
      _showSnackBar('Failed to mute group', isError: true);
    }
  }

  Future<void> _unmuteGroup() async {
    final success = await _apiService.unmuteGroup(widget.groupId);

    if (success) {
      await _loadSettings();
      _showSnackBar('Group unmuted', isError: false);
    } else {
      _showSnackBar('Failed to unmute group', isError: true);
    }
  }

  void _showMuteOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildMuteOptionsSheet(),
    );
  }

  Widget _buildMuteOptionsSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Mute notifications',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll still be notified if you\'re mentioned',
            style: AppTypography.caption.copyWith(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 24),

          // Mute options
          _buildMuteOption('15 minutes', const Duration(minutes: 15)),
          _buildMuteOption('1 hour', const Duration(hours: 1)),
          _buildMuteOption('8 hours', const Duration(hours: 8)),
          _buildMuteOption('24 hours', const Duration(hours: 24)),
          _buildMuteOption('1 week', const Duration(days: 7)),
          _buildMuteOption('Forever', null),

          const SizedBox(height: 16),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuteOption(String label, Duration? duration) {
    return ListTile(
      title: Text(
        label,
        style: AppTypography.body1.copyWith(
          color: Colors.white,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _muteGroup(duration);
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: AppTypography.h4.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Notification Settings',
              style: AppTypography.caption.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : _buildSettings(),
    );
  }

  Widget _buildSettings() {
    if (_settings == null) {
      return Center(
        child: Text(
          'Failed to load settings',
          style: AppTypography.body1.copyWith(
            color: Colors.white54,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Mute Section
        _buildSection(
          title: 'Mute',
          children: [
            _buildSwitchTile(
              title: 'Mute notifications',
              subtitle: _settings!.muteStatusText,
              value: _settings!.isMuted,
              onChanged: (value) {
                if (value) {
                  _showMuteOptions();
                } else {
                  _unmuteGroup();
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Notification Preference
        _buildSection(
          title: 'Notification Preference',
          children: [
            _buildRadioTile(
              title: 'All messages',
              subtitle: 'Get notified for every message',
              value: NotificationPreference.all,
              groupValue: _settings!.preference,
              onChanged: (value) {
                setState(() {
                  _settings = _settings!.copyWith(preference: value);
                });
                _saveSettings();
              },
            ),
            _buildRadioTile(
              title: 'Mentions only',
              subtitle: 'Only when you\'re mentioned',
              value: NotificationPreference.mentionsOnly,
              groupValue: _settings!.preference,
              onChanged: (value) {
                setState(() {
                  _settings = _settings!.copyWith(preference: value);
                });
                _saveSettings();
              },
            ),
            _buildRadioTile(
              title: 'None',
              subtitle: 'No notifications',
              value: NotificationPreference.none,
              groupValue: _settings!.preference,
              onChanged: (value) {
                setState(() {
                  _settings = _settings!.copyWith(preference: value);
                });
                _saveSettings();
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Display Options
        _buildSection(
          title: 'Display',
          children: [
            _buildSwitchTile(
              title: 'Show previews',
              subtitle: 'Show message content in notifications',
              value: _settings!.showPreviews,
              onChanged: (value) {
                setState(() {
                  _settings = _settings!.copyWith(showPreviews: value);
                });
                _saveSettings();
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sound & Vibration
        _buildSection(
          title: 'Sound & Vibration',
          children: [
            _buildSwitchTile(
              title: 'Vibrate',
              subtitle: 'Vibrate on new messages',
              value: _settings!.vibrate,
              onChanged: (value) {
                setState(() {
                  _settings = _settings!.copyWith(vibrate: value);
                });
                _saveSettings();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Notification sound',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                _settings!.notificationSound ?? 'Default',
                style: AppTypography.caption.copyWith(
                  color: Colors.white54,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
              onTap: () {
                // TODO: Implement sound picker
                _showSnackBar('Sound picker coming soon');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: AppTypography.body2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.navbarBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: AppTypography.body1.copyWith(
          color: Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: Colors.white54,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    String? subtitle,
    required T value,
    required T groupValue,
    required Function(T) onChanged,
  }) {
    return RadioListTile<T>(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        title,
        style: AppTypography.body1.copyWith(
          color: Colors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: Colors.white54,
              ),
            )
          : null,
      value: value,
      groupValue: groupValue,
      onChanged: (val) => onChanged(val as T),
      activeColor: AppColors.primary,
    );
  }
}

