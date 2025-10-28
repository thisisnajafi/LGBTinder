import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Notification Settings Screen
/// 
/// Manage all notification preferences:
/// - Enable/disable by type (matches, messages, likes, calls)
/// - Quiet hours (Do Not Disturb)
/// - Notification preview settings
/// - Sound and vibration preferences
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Notification toggles
  bool _matchNotifications = true;
  bool _messageNotifications = true;
  bool _likeNotifications = true;
  bool _superlikeNotifications = true;
  bool _callNotifications = true;
  
  // Quiet hours
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);
  
  // Notification preferences
  bool _showPreviews = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _matchNotifications = prefs.getBool('notif_matches') ?? true;
      _messageNotifications = prefs.getBool('notif_messages') ?? true;
      _likeNotifications = prefs.getBool('notif_likes') ?? true;
      _superlikeNotifications = prefs.getBool('notif_superlikes') ?? true;
      _callNotifications = prefs.getBool('notif_calls') ?? true;
      
      _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;
      _quietHoursStart = TimeOfDay(
        hour: prefs.getInt('quiet_hours_start_hour') ?? 22,
        minute: prefs.getInt('quiet_hours_start_minute') ?? 0,
      );
      _quietHoursEnd = TimeOfDay(
        hour: prefs.getInt('quiet_hours_end_hour') ?? 8,
        minute: prefs.getInt('quiet_hours_end_minute') ?? 0,
      );
      
      _showPreviews = prefs.getBool('notif_show_previews') ?? true;
      _soundEnabled = prefs.getBool('notif_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notif_vibration') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveTimePreference(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _quietHoursStart : _quietHoursEnd,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.navbarBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = picked;
          _saveTimePreference('quiet_hours_start_hour', picked.hour);
          _saveTimePreference('quiet_hours_start_minute', picked.minute);
        } else {
          _quietHoursEnd = picked;
          _saveTimePreference('quiet_hours_end_hour', picked.hour);
          _saveTimePreference('quiet_hours_end_minute', picked.minute);
        }
      });
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
          'Notification Settings',
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
          // Notification Types Section
          _buildSection(
            title: 'Notification Types',
            children: [
              _buildSwitchTile(
                title: 'New Matches',
                subtitle: 'Get notified when you have a new match',
                icon: Icons.favorite,
                value: _matchNotifications,
                onChanged: (value) {
                  setState(() => _matchNotifications = value);
                  _savePreference('notif_matches', value);
                },
              ),
              _buildSwitchTile(
                title: 'Messages',
                subtitle: 'Get notified for new messages',
                icon: Icons.message,
                value: _messageNotifications,
                onChanged: (value) {
                  setState(() => _messageNotifications = value);
                  _savePreference('notif_messages', value);
                },
              ),
              _buildSwitchTile(
                title: 'Likes',
                subtitle: 'Get notified when someone likes you',
                icon: Icons.thumb_up,
                value: _likeNotifications,
                onChanged: (value) {
                  setState(() => _likeNotifications = value);
                  _savePreference('notif_likes', value);
                },
              ),
              _buildSwitchTile(
                title: 'Superlikes',
                subtitle: 'Get notified for superlikes',
                icon: Icons.star,
                value: _superlikeNotifications,
                onChanged: (value) {
                  setState(() => _superlikeNotifications = value);
                  _savePreference('notif_superlikes', value);
                },
              ),
              _buildSwitchTile(
                title: 'Calls',
                subtitle: 'Get notified for incoming calls',
                icon: Icons.phone,
                value: _callNotifications,
                onChanged: (value) {
                  setState(() => _callNotifications = value);
                  _savePreference('notif_calls', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quiet Hours Section
          _buildSection(
            title: 'Quiet Hours (Do Not Disturb)',
            children: [
              _buildSwitchTile(
                title: 'Enable Quiet Hours',
                subtitle: 'Mute notifications during specific hours',
                icon: Icons.nights_stay,
                value: _quietHoursEnabled,
                onChanged: (value) {
                  setState(() => _quietHoursEnabled = value);
                  _savePreference('quiet_hours_enabled', value);
                },
              ),
              if (_quietHoursEnabled) ...[
                _buildTimeTile(
                  title: 'Start Time',
                  time: _quietHoursStart,
                  onTap: () => _selectTime(context, true),
                ),
                _buildTimeTile(
                  title: 'End Time',
                  time: _quietHoursEnd,
                  onTap: () => _selectTime(context, false),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Display Preferences Section
          _buildSection(
            title: 'Display Preferences',
            children: [
              _buildSwitchTile(
                title: 'Show Previews',
                subtitle: 'Show message content in notifications',
                icon: Icons.visibility,
                value: _showPreviews,
                onChanged: (value) {
                  setState(() => _showPreviews = value);
                  _savePreference('notif_show_previews', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sound & Vibration Section
          _buildSection(
            title: 'Sound & Vibration',
            children: [
              _buildSwitchTile(
                title: 'Notification Sound',
                subtitle: 'Play sound for notifications',
                icon: Icons.volume_up,
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                  _savePreference('notif_sound', value);
                },
              ),
              _buildSwitchTile(
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                icon: Icons.vibration,
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() => _vibrationEnabled = value);
                  _savePreference('notif_vibration', value);
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

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
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'System notification settings may override these preferences. Check your device settings if needed.',
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
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: AppTypography.body1.copyWith(
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(
          color: Colors.white54,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.access_time, color: AppColors.primary),
      title: Text(
        title,
        style: AppTypography.body1.copyWith(
          color: Colors.white,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time.format(context),
            style: AppTypography.body1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: Colors.white54,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
