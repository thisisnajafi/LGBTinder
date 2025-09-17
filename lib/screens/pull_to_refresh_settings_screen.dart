import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/pull_to_refresh_service.dart';

class PullToRefreshSettingsScreen extends StatefulWidget {
  const PullToRefreshSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PullToRefreshSettingsScreen> createState() => _PullToRefreshSettingsScreenState();
}

class _PullToRefreshSettingsScreenState extends State<PullToRefreshSettingsScreen> {
  late PullToRefreshService _pullToRefreshService;

  @override
  void initState() {
    super.initState();
    _pullToRefreshService = PullToRefreshService();
    _pullToRefreshService.initialize();
  }

  @override
  void dispose() {
    _pullToRefreshService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Pull-to-Refresh Settings'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMainToggle(),
            const SizedBox(height: 24),
            _buildFeedbackSettings(),
            const SizedBox(height: 24),
            _buildThresholdSettings(),
            const SizedBox(height: 24),
            _buildAppearanceSettings(),
            const SizedBox(height: 24),
            _buildPreviewSection(),
            const SizedBox(height: 24),
            _buildAdvancedSettings(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.refresh,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Pull-to-Refresh',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize pull-to-refresh functionality for better user experience',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pull-to-Refresh',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.refresh,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Pull-to-Refresh',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Allow users to refresh content by pulling down',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _pullToRefreshService.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _pullToRefreshService.setEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.vibration,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haptic Feedback',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Provide haptic feedback when refreshing',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _pullToRefreshService.hapticFeedbackEnabled,
                onChanged: (value) {
                  setState(() {
                    _pullToRefreshService.setHapticFeedbackEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.volume_up,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sound Feedback',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Provide sound feedback when refreshing',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _pullToRefreshService.soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _pullToRefreshService.setSoundEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Threshold Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Refresh Threshold: ${_pullToRefreshService.refreshThreshold.toInt()}px',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _pullToRefreshService.refreshThreshold,
            min: 50,
            max: 150,
            divisions: 10,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _pullToRefreshService.setRefreshThreshold(value);
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Refresh Duration: ${_pullToRefreshService.refreshDuration.inMilliseconds}ms',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _pullToRefreshService.refreshDuration.inMilliseconds.toDouble(),
            min: 500,
            max: 3000,
            divisions: 25,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _pullToRefreshService.setRefreshDuration(Duration(milliseconds: value.round()));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appearance Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _pullToRefreshService.refreshIndicatorColor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indicator Color',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Color of the refresh indicator',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showColorPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pullToRefreshService.refreshIndicatorColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _pullToRefreshService.refreshBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Background Color',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Background color of the refresh area',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showBackgroundColorPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pullToRefreshService.refreshBackgroundColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Change'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Test the pull-to-refresh functionality',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: PullToRefreshService().createRefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPreviewItem('Item 1', Icons.person),
                  _buildPreviewItem('Item 2', Icons.favorite),
                  _buildPreviewItem('Item 3', Icons.star),
                  _buildPreviewItem('Item 4', Icons.message),
                  _buildPreviewItem('Item 5', Icons.settings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Reset to Default',
            subtitle: 'Reset all pull-to-refresh settings to default values',
            icon: Icons.restore,
            onTap: _resetToDefault,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Pull-to-Refresh Help',
            subtitle: 'Learn more about pull-to-refresh features',
            icon: Icons.help_outline,
            onTap: _showPullToRefreshHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Choose Indicator Color',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.orange,
            Colors.purple,
            Colors.pink,
            Colors.teal,
            Colors.cyan,
          ].map((color) => GestureDetector(
            onTap: () {
              setState(() {
                _pullToRefreshService.setRefreshIndicatorColor(color);
              });
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showBackgroundColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Choose Background Color',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.white,
            Colors.grey[100]!,
            Colors.grey[200]!,
            Colors.grey[300]!,
            Colors.black,
            Colors.grey[800]!,
            Colors.grey[700]!,
            Colors.grey[600]!,
          ].map((color) => GestureDetector(
            onTap: () {
              setState(() {
                _pullToRefreshService.setRefreshBackgroundColor(color);
              });
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _pullToRefreshService.setEnabled(true);
      _pullToRefreshService.setHapticFeedbackEnabled(true);
      _pullToRefreshService.setSoundEnabled(false);
      _pullToRefreshService.setRefreshThreshold(80.0);
      _pullToRefreshService.setRefreshDuration(const Duration(milliseconds: 1000));
      _pullToRefreshService.setRefreshIndicatorColor(Colors.blue);
      _pullToRefreshService.setRefreshBackgroundColor(Colors.white);
    });
  }

  void _showPullToRefreshHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Pull-to-Refresh Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Pull-to-refresh allows users to refresh content by pulling down:\n\n'
          '• Threshold: Distance to pull before refresh triggers\n'
          '• Duration: How long the refresh animation lasts\n'
          '• Haptic Feedback: Vibration when refreshing\n'
          '• Sound Feedback: Audio cue when refreshing\n'
          '• Colors: Customize indicator and background colors\n\n'
          'This feature improves user experience by providing intuitive refresh functionality.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
