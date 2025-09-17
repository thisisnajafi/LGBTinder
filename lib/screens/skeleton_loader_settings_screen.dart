import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/skeleton_loader_service.dart';

class SkeletonLoaderSettingsScreen extends StatefulWidget {
  const SkeletonLoaderSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SkeletonLoaderSettingsScreen> createState() => _SkeletonLoaderSettingsScreenState();
}

class _SkeletonLoaderSettingsScreenState extends State<SkeletonLoaderSettingsScreen> {
  late SkeletonLoaderService _skeletonService;

  @override
  void initState() {
    super.initState();
    _skeletonService = SkeletonLoaderService();
    _skeletonService.initialize();
  }

  @override
  void dispose() {
    _skeletonService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Skeleton Loader Settings'),
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
            _buildColorSettings(),
            const SizedBox(height: 24),
            _buildAnimationSettings(),
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
            Icons.view_stream,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Skeleton Loaders',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize skeleton loading animations for better user experience',
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
            'Skeleton Loaders',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.view_stream,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Skeleton Loaders',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Show animated skeleton placeholders while content loads',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _skeletonService.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _skeletonService.setEnabled(value);
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

  Widget _buildColorSettings() {
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
            'Color Settings',
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
                  color: _skeletonService.baseColor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Base Color',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Primary color of skeleton elements',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showBaseColorPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _skeletonService.baseColor,
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
                  color: _skeletonService.highlightColor,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Highlight Color',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Highlight color for shimmer effect',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showHighlightColorPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _skeletonService.highlightColor,
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

  Widget _buildAnimationSettings() {
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
            'Animation Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Animation Duration: ${_skeletonService.animationDuration.inMilliseconds}ms',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _skeletonService.animationDuration.inMilliseconds.toDouble(),
            min: 500,
            max: 3000,
            divisions: 25,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _skeletonService.setAnimationSettings(
                  duration: Duration(milliseconds: value.round()),
                );
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Animation Delay: ${_skeletonService.animationDelay.inMilliseconds}ms',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _skeletonService.animationDelay.inMilliseconds.toDouble(),
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _skeletonService.setAnimationSettings(
                  delay: Duration(milliseconds: value.round()),
                );
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Animation Curve',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Curves.easeInOut,
              Curves.easeIn,
              Curves.easeOut,
              Curves.linear,
              Curves.bounceIn,
              Curves.elasticIn,
            ].map((curve) => ElevatedButton(
              onPressed: () {
                setState(() {
                  _skeletonService.setAnimationSettings(curve: curve);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _skeletonService.animationCurve == curve 
                    ? AppColors.primary 
                    : Colors.white24,
                foregroundColor: Colors.white,
              ),
              child: Text(curve.toString().split('.').last),
            )).toList(),
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
            'Preview different skeleton loader types',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          _buildPreviewGrid(),
        ],
      ),
    );
  }

  Widget _buildPreviewGrid() {
    return Column(
      children: [
        // Row 1: Basic skeletons
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Box',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonBox(
                    width: 60,
                    height: 40,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Circle',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonCircle(diameter: 40),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Text',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonText(
                    width: 80,
                    height: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 2: Complex skeletons
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Avatar',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonAvatar(size: 40),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Card',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonCard(
                    width: 100,
                    height: 60,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'List Item',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonListItem(
                    width: 100,
                    height: 60,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Row 3: Specialized skeletons
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Profile Card',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonProfileCard(
                    width: 100,
                    height: 120,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Chat Message',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonChatMessage(
                    width: 100,
                    height: 60,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Grid Item',
                    style: AppTypography.body2.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _skeletonService.createSkeletonGridItem(
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
            subtitle: 'Reset all skeleton loader settings to default values',
            icon: Icons.restore,
            onTap: _resetToDefault,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Skeleton Loader Help',
            subtitle: 'Learn more about skeleton loader features',
            icon: Icons.help_outline,
            onTap: _showSkeletonLoaderHelp,
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

  void _showBaseColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Choose Base Color',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.grey[300]!,
            Colors.grey[400]!,
            Colors.grey[500]!,
            Colors.grey[600]!,
            Colors.blue[300]!,
            Colors.red[300]!,
            Colors.green[300]!,
            Colors.orange[300]!,
          ].map((color) => GestureDetector(
            onTap: () {
              setState(() {
                _skeletonService.setColors(baseColor: color);
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

  void _showHighlightColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Choose Highlight Color',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.grey[100]!,
            Colors.grey[200]!,
            Colors.white,
            Colors.blue[100]!,
            Colors.red[100]!,
            Colors.green[100]!,
            Colors.orange[100]!,
            Colors.purple[100]!,
          ].map((color) => GestureDetector(
            onTap: () {
              setState(() {
                _skeletonService.setColors(highlightColor: color);
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
      _skeletonService.setEnabled(true);
      _skeletonService.setColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
      );
      _skeletonService.setAnimationSettings(
        duration: const Duration(milliseconds: 1500),
        delay: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showSkeletonLoaderHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Skeleton Loader Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Skeleton loaders provide visual feedback while content loads:\n\n'
          '• Box: Rectangular placeholder for images or content\n'
          '• Circle: Circular placeholder for avatars or icons\n'
          '• Text: Line placeholder for text content\n'
          '• Avatar: Circular placeholder for user avatars\n'
          '• Card: Complex placeholder for card layouts\n'
          '• List Item: Placeholder for list items\n'
          '• Profile Card: Placeholder for profile cards\n'
          '• Chat Message: Placeholder for chat messages\n'
          '• Grid Item: Placeholder for grid items\n\n'
          'These improve perceived performance and user experience.',
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
