import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/haptic_feedback_service.dart';

class PrivacySettings {
  final bool showAge;
  final bool showLocation;
  final bool showOccupation;
  final bool showEducation;
  final bool showInterests;
  final bool showRelationshipStatus;
  final bool allowProfileSharing;
  final bool allowPhotoSharing;
  final bool allowContactSharing;
  final bool showOnlineStatus;
  final bool allowNotifications;
  final bool allowLocationTracking;
  final bool allowDataCollection;
  final bool allowAnalytics;
  final PrivacyLevel profileVisibility;
  final BlockedUsers blockedUsers;
  final ReportedUsers reportedUsers;

  const PrivacySettings({
    this.showAge = true,
    this.showLocation = true,
    this.showOccupation = true,
    this.showEducation = true,
    this.showInterests = true,
    this.showRelationshipStatus = true,
    this.allowProfileSharing = true,
    this.allowPhotoSharing = true,
    this.allowContactSharing = false,
    this.showOnlineStatus = true,
    this.allowNotifications = true,
    this.allowLocationTracking = true,
    this.allowDataCollection = true,
    this.allowAnalytics = true,
    this.profileVisibility = PrivacyLevel.public,
    this.blockedUsers = const BlockedUsers(),
    this.reportedUsers = const ReportedUsers(),
  });

  PrivacySettings copyWith({
    bool? showAge,
    bool? showLocation,
    bool? showOccupation,
    bool? showEducation,
    bool? showInterests,
    bool? showRelationshipStatus,
    bool? allowProfileSharing,
    bool? allowPhotoSharing,
    bool? allowContactSharing,
    bool? showOnlineStatus,
    bool? allowNotifications,
    bool? allowLocationTracking,
    bool? allowDataCollection,
    bool? allowAnalytics,
    PrivacyLevel? profileVisibility,
    BlockedUsers? blockedUsers,
    ReportedUsers? reportedUsers,
  }) {
    return PrivacySettings(
      showAge: showAge ?? this.showAge,
      showLocation: showLocation ?? this.showLocation,
      showOccupation: showOccupation ?? this.showOccupation,
      showEducation: showEducation ?? this.showEducation,
      showInterests: showInterests ?? this.showInterests,
      showRelationshipStatus: showRelationshipStatus ?? this.showRelationshipStatus,
      allowProfileSharing: allowProfileSharing ?? this.allowProfileSharing,
      allowPhotoSharing: allowPhotoSharing ?? this.allowPhotoSharing,
      allowContactSharing: allowContactSharing ?? this.allowContactSharing,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowNotifications: allowNotifications ?? this.allowNotifications,
      allowLocationTracking: allowLocationTracking ?? this.allowLocationTracking,
      allowDataCollection: allowDataCollection ?? this.allowDataCollection,
      allowAnalytics: allowAnalytics ?? this.allowAnalytics,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      reportedUsers: reportedUsers ?? this.reportedUsers,
    );
  }
}

enum PrivacyLevel {
  public,
  friends,
  private,
}

class BlockedUsers {
  final List<String> userIds;
  final List<String> usernames;

  const BlockedUsers({
    this.userIds = const [],
    this.usernames = const [],
  });

  BlockedUsers copyWith({
    List<String>? userIds,
    List<String>? usernames,
  }) {
    return BlockedUsers(
      userIds: userIds ?? this.userIds,
      usernames: usernames ?? this.usernames,
    );
  }
}

class ReportedUsers {
  final List<String> userIds;
  final List<String> usernames;
  final List<String> reasons;

  const ReportedUsers({
    this.userIds = const [],
    this.usernames = const [],
    this.reasons = const [],
  });

  ReportedUsers copyWith({
    List<String>? userIds,
    List<String>? usernames,
    List<String>? reasons,
  }) {
    return ReportedUsers(
      userIds: userIds ?? this.userIds,
      usernames: usernames ?? this.usernames,
      reasons: reasons ?? this.reasons,
    );
  }
}

class PrivacySettingsScreen extends StatefulWidget {
  final PrivacySettings initialSettings;
  final Function(PrivacySettings)? onSettingsChanged;

  const PrivacySettingsScreen({
    Key? key,
    required this.initialSettings,
    this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  late PrivacySettings _currentSettings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _currentSettings = widget.initialSettings;
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileVisibilitySection(),
                    const SizedBox(height: 24),
                    _buildInformationVisibilitySection(),
                    const SizedBox(height: 24),
                    _buildSharingPermissionsSection(),
                    const SizedBox(height: 24),
                    _buildAppPermissionsSection(),
                    const SizedBox(height: 24),
                    _buildBlockedUsersSection(),
                    const SizedBox(height: 24),
                    _buildDataManagementSection(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.navbarBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
        onPressed: () {
          HapticFeedbackService.selection();
          Navigator.of(context).pop();
        },
      ),
      title: const Text(
        'Privacy Settings',
        style: TextStyle(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (_hasChanges)
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileVisibilitySection() {
    return _buildSection(
      title: 'Profile Visibility',
      subtitle: 'Control who can see your profile',
      children: [
        _buildRadioTile(
          title: 'Public',
          subtitle: 'Anyone can see your profile',
          value: PrivacyLevel.public,
          groupValue: _currentSettings.profileVisibility,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(profileVisibility: value);
              _hasChanges = true;
            });
          },
        ),
        _buildRadioTile(
          title: 'Friends Only',
          subtitle: 'Only your matches can see your profile',
          value: PrivacyLevel.friends,
          groupValue: _currentSettings.profileVisibility,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(profileVisibility: value);
              _hasChanges = true;
            });
          },
        ),
        _buildRadioTile(
          title: 'Private',
          subtitle: 'Only you can see your profile',
          value: PrivacyLevel.private,
          groupValue: _currentSettings.profileVisibility,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(profileVisibility: value);
              _hasChanges = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildInformationVisibilitySection() {
    return _buildSection(
      title: 'Information Visibility',
      subtitle: 'Choose what information to show on your profile',
      children: [
        _buildSwitchTile(
          title: 'Show Age',
          subtitle: 'Display your age on your profile',
          value: _currentSettings.showAge,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(showAge: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Show Location',
          subtitle: 'Display your location on your profile',
          value: _currentSettings.showLocation,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(showLocation: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Show Occupation',
          subtitle: 'Display your occupation on your profile',
          value: _currentSettings.showOccupation,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(showOccupation: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Show Education',
          subtitle: 'Display your education on your profile',
          value: _currentSettings.showEducation,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(showEducation: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Show Interests',
          subtitle: 'Display your interests on your profile',
          value: _currentSettings.showInterests,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(showInterests: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Show Relationship Status',
          subtitle: 'Display your relationship status on your profile',
          value: _currentSettings.showRelationshipStatus,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(showRelationshipStatus: value);
              _hasChanges = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSharingPermissionsSection() {
    return _buildSection(
      title: 'Sharing Permissions',
      subtitle: 'Control what others can share about you',
      children: [
        _buildSwitchTile(
          title: 'Allow Profile Sharing',
          subtitle: 'Let others share your profile',
          value: _currentSettings.allowProfileSharing,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(allowProfileSharing: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Allow Photo Sharing',
          subtitle: 'Let others share your photos',
          value: _currentSettings.allowPhotoSharing,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(allowPhotoSharing: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Allow Contact Sharing',
          subtitle: 'Let others share your contact information',
          value: _currentSettings.allowContactSharing,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(allowContactSharing: value);
              _hasChanges = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAppPermissionsSection() {
    return _buildSection(
      title: 'App Permissions',
      subtitle: 'Control app functionality and notifications',
      children: [
        _buildSwitchTile(
          title: 'Show Online Status',
          subtitle: 'Let others see when you\'re online',
          value: _currentSettings.showOnlineStatus,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(showOnlineStatus: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Allow Notifications',
          subtitle: 'Receive push notifications',
          value: _currentSettings.allowNotifications,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(allowNotifications: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Allow Location Tracking',
          subtitle: 'Use your location for matching',
          value: _currentSettings.allowLocationTracking,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(allowLocationTracking: value);
              _hasChanges = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBlockedUsersSection() {
    return _buildSection(
      title: 'Blocked Users',
      subtitle: 'Manage users you\'ve blocked',
      children: [
        ListTile(
          leading: Icon(
            Icons.block,
            color: AppColors.feedbackError,
          ),
          title: const Text(
            'Blocked Users',
            style: TextStyle(color: AppColors.textPrimaryDark),
          ),
          subtitle: Text(
            '${_currentSettings.blockedUsers.userIds.length} users blocked',
            style: const TextStyle(color: AppColors.textSecondaryDark),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondaryDark,
            size: 16,
          ),
          onTap: () {
            HapticFeedbackService.selection();
            _showBlockedUsersDialog();
          },
        ),
        ListTile(
          leading: Icon(
            Icons.report,
            color: AppColors.feedbackWarning,
          ),
          title: const Text(
            'Reported Users',
            style: TextStyle(color: AppColors.textPrimaryDark),
          ),
          subtitle: Text(
            '${_currentSettings.reportedUsers.userIds.length} users reported',
            style: const TextStyle(color: AppColors.textSecondaryDark),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondaryDark,
            size: 16,
          ),
          onTap: () {
            HapticFeedbackService.selection();
            _showReportedUsersDialog();
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return _buildSection(
      title: 'Data Management',
      subtitle: 'Control how your data is used',
      children: [
        _buildSwitchTile(
          title: 'Allow Data Collection',
          subtitle: 'Let us collect data to improve the app',
          value: _currentSettings.allowDataCollection,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(allowDataCollection: value);
              _hasChanges = true;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Allow Analytics',
          subtitle: 'Help us understand how you use the app',
          value: _currentSettings.allowAnalytics,
          onChanged: (value) {
            setState(() {
              _currentSettings = _currentSettings.copyWith(allowAnalytics: value);
              _hasChanges = true;
            });
          },
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever,
            color: AppColors.feedbackError,
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: AppColors.feedbackError),
          ),
          subtitle: const Text(
            'Permanently delete your account and all data',
            style: TextStyle(color: AppColors.textSecondaryDark),
          ),
          onTap: () {
            HapticFeedbackService.selection();
            _showDeleteAccountDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimaryDark),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondaryDark),
      ),
      value: value,
      onChanged: (newValue) {
        HapticFeedbackService.selection();
        onChanged(newValue);
      },
      activeColor: AppColors.primaryLight,
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String subtitle,
    required PrivacyLevel value,
    required PrivacyLevel groupValue,
    required Function(PrivacyLevel?) onChanged,
  }) {
    return RadioListTile<PrivacyLevel>(
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimaryDark),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondaryDark),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        HapticFeedbackService.selection();
        onChanged(newValue);
      },
      activeColor: AppColors.primaryLight,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _currentSettings = widget.initialSettings;
                _hasChanges = false;
              });
              HapticFeedbackService.selection();
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.borderDefault),
              foregroundColor: AppColors.textPrimaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _hasChanges ? _saveSettings : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  void _saveSettings() {
    widget.onSettingsChanged?.call(_currentSettings);
    setState(() {
      _hasChanges = false;
    });
    HapticFeedbackService.success();
  }

  void _showBlockedUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Blocked Users',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'You have blocked ${_currentSettings.blockedUsers.userIds.length} users.',
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportedUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Reported Users',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'You have reported ${_currentSettings.reportedUsers.userIds.length} users.',
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryLight),
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
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppColors.feedbackError),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle account deletion
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.feedbackError),
            ),
          ),
        ],
      ),
    );
  }
}
