import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_notification_service.dart';
import '../services/notifications_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  Map<String, bool> _notificationSettings = {};
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken != null) {
        final settings = await NotificationsService.getNotificationSettings(
          accessToken: await accessToken,
        );
        
        setState(() {
          _notificationSettings = settings;
          _pushNotificationsEnabled = settings['push_notifications'] ?? true;
          _emailNotificationsEnabled = settings['email_notifications'] ?? true;
          _smsNotificationsEnabled = settings['sms_notifications'] ?? false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load notification settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken != null) {
        await NotificationsService.updateNotificationSetting(
          key: key,
          value: value,
          accessToken: await accessToken,
        );

        setState(() {
          _notificationSettings[key] = value;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification setting updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update setting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Notification Settings'),
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
                  _buildSectionHeader('General Notifications'),
                  _buildNotificationToggle(
                    'Push Notifications',
                    'Receive push notifications on your device',
                    _pushNotificationsEnabled,
                    (value) {
                      setState(() {
                        _pushNotificationsEnabled = value;
                      });
                      _updateNotificationSetting('push_notifications', value);
                    },
                  ),
                  _buildNotificationToggle(
                    'Email Notifications',
                    'Receive notifications via email',
                    _emailNotificationsEnabled,
                    (value) {
                      setState(() {
                        _emailNotificationsEnabled = value;
                      });
                      _updateNotificationSetting('email_notifications', value);
                    },
                  ),
                  _buildNotificationToggle(
                    'SMS Notifications',
                    'Receive notifications via SMS',
                    _smsNotificationsEnabled,
                    (value) {
                      setState(() {
                        _smsNotificationsEnabled = value;
                      });
                      _updateNotificationSetting('sms_notifications', value);
                    },
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Activity Notifications'),
                  _buildNotificationToggle(
                    'New Matches',
                    'Get notified when someone likes you back',
                    _notificationSettings['new_matches'] ?? true,
                    (value) => _updateNotificationSetting('new_matches', value),
                  ),
                  _buildNotificationToggle(
                    'Messages',
                    'Get notified when you receive new messages',
                    _notificationSettings['messages'] ?? true,
                    (value) => _updateNotificationSetting('messages', value),
                  ),
                  _buildNotificationToggle(
                    'Super Likes',
                    'Get notified when someone super likes you',
                    _notificationSettings['super_likes'] ?? true,
                    (value) => _updateNotificationSetting('super_likes', value),
                  ),
                  _buildNotificationToggle(
                    'Story Views',
                    'Get notified when someone views your story',
                    _notificationSettings['story_views'] ?? false,
                    (value) => _updateNotificationSetting('story_views', value),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Social Notifications'),
                  _buildNotificationToggle(
                    'Story Reactions',
                    'Get notified when someone reacts to your story',
                    _notificationSettings['story_reactions'] ?? true,
                    (value) => _updateNotificationSetting('story_reactions', value),
                  ),
                  _buildNotificationToggle(
                    'Comments',
                    'Get notified when someone comments on your posts',
                    _notificationSettings['comments'] ?? true,
                    (value) => _updateNotificationSetting('comments', value),
                  ),
                  _buildNotificationToggle(
                    'Follows',
                    'Get notified when someone follows you',
                    _notificationSettings['follows'] ?? true,
                    (value) => _updateNotificationSetting('follows', value),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Marketing & Updates'),
                  _buildNotificationToggle(
                    'Promotional Offers',
                    'Get notified about special offers and promotions',
                    _notificationSettings['promotional'] ?? false,
                    (value) => _updateNotificationSetting('promotional', value),
                  ),
                  _buildNotificationToggle(
                    'App Updates',
                    'Get notified about new features and updates',
                    _notificationSettings['app_updates'] ?? true,
                    (value) => _updateNotificationSetting('app_updates', value),
                  ),
                  _buildNotificationToggle(
                    'Safety Alerts',
                    'Get notified about important safety information',
                    _notificationSettings['safety_alerts'] ?? true,
                    (value) => _updateNotificationSetting('safety_alerts', value),
                  ),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Quiet Hours'),
                  _buildQuietHoursSettings(),

                  const SizedBox(height: 32),

                  _buildSectionHeader('Test Notifications'),
                  _buildTestNotificationButton(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTypography.h4.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiet Hours',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set specific hours when you don\'t want to receive notifications',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '10:00 PM',
                        style: AppTypography.body2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Time',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '8:00 AM',
                        style: AppTypography.body2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Enable Quiet Hours',
              style: AppTypography.body2.copyWith(
                color: Colors.white,
              ),
            ),
            value: _notificationSettings['quiet_hours'] ?? false,
            onChanged: (value) => _updateNotificationSetting('quiet_hours', value),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotificationButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            'Test Notifications',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a test notification to verify your settings',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _sendTestNotification,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Send Test Notification'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;

      if (accessToken != null) {
        final success = await FirebaseNotificationService.sendNotificationToUser(
          userId: authProvider.user?.id.toString() ?? '',
          title: 'Test Notification',
          body: 'This is a test notification from LGBTinder!',
          accessToken: await accessToken,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test notification sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send test notification'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
