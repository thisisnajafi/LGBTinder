import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/haptic_feedback_service.dart';
import '../../components/buttons/animated_button.dart';
import '../../components/buttons/accessible_button.dart';

class ProfileCustomizationOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Widget content;
  final bool isPremium;
  final bool isEnabled;
  final Function()? onTap;

  const ProfileCustomizationOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.content,
    this.isPremium = false,
    this.isEnabled = true,
    this.onTap,
  });
}

class AdvancedProfileCustomizationScreen extends StatefulWidget {
  const AdvancedProfileCustomizationScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedProfileCustomizationScreen> createState() => _AdvancedProfileCustomizationScreenState();
}

class _AdvancedProfileCustomizationScreenState extends State<AdvancedProfileCustomizationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<ProfileCustomizationOption> _customizationOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCustomizationOptions();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeCustomizationOptions() {
    _customizationOptions.addAll([
      ProfileCustomizationOption(
        id: 'profile_theme',
        title: 'Profile Theme',
        description: 'Customize your profile appearance with themes',
        icon: Icons.palette,
        iconColor: AppColors.primaryLight,
        content: _buildProfileThemeContent(),
      ),
      ProfileCustomizationOption(
        id: 'profile_layout',
        title: 'Profile Layout',
        description: 'Choose how your profile information is displayed',
        icon: Icons.view_module,
        iconColor: AppColors.feedbackInfo,
        content: _buildProfileLayoutContent(),
      ),
      ProfileCustomizationOption(
        id: 'profile_sections',
        title: 'Profile Sections',
        description: 'Add or remove profile sections',
        icon: Icons.widgets,
        iconColor: AppColors.feedbackSuccess,
        content: _buildProfileSectionsContent(),
      ),
      ProfileCustomizationOption(
        id: 'profile_visibility',
        title: 'Profile Visibility',
        description: 'Control who can see different parts of your profile',
        icon: Icons.visibility,
        iconColor: AppColors.feedbackWarning,
        content: _buildProfileVisibilityContent(),
      ),
      ProfileCustomizationOption(
        id: 'profile_highlights',
        title: 'Profile Highlights',
        description: 'Add special highlights and badges to your profile',
        icon: Icons.star,
        iconColor: AppColors.feedbackError,
        content: _buildProfileHighlightsContent(),
        isPremium: true,
      ),
      ProfileCustomizationOption(
        id: 'profile_animations',
        title: 'Profile Animations',
        description: 'Customize animations and transitions',
        icon: Icons.animation,
        iconColor: AppColors.primaryLight,
        content: _buildProfileAnimationsContent(),
      ),
      ProfileCustomizationOption(
        id: 'profile_widgets',
        title: 'Profile Widgets',
        description: 'Add interactive widgets to your profile',
        icon: Icons.dashboard,
        iconColor: AppColors.feedbackInfo,
        content: _buildProfileWidgetsContent(),
        isPremium: true,
      ),
      ProfileCustomizationOption(
        id: 'profile_integrations',
        title: 'Profile Integrations',
        description: 'Connect with social media and other platforms',
        icon: Icons.link,
        iconColor: AppColors.feedbackSuccess,
        content: _buildProfileIntegrationsContent(),
      ),
    ]);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
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
          'Profile Customization',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textPrimaryDark),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildCustomizationGrid(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildPreviewSection(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            AppColors.feedbackInfo.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppColors.primaryLight,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Advanced Profile Customization',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Personalize your profile with advanced customization options. Make your profile stand out and reflect your unique personality.',
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _customizationOptions.length,
      itemBuilder: (context, index) {
        final option = _customizationOptions[index];
        return _buildCustomizationCard(option);
      },
    );
  }

  Widget _buildCustomizationCard(ProfileCustomizationOption option) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        _showCustomizationModal(option);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: option.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option.icon,
                    color: option.iconColor,
                    size: 32,
                  ),
                ),
                if (option.isPremium)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.feedbackWarning,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              option.title,
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              option.description,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset to Defaults'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceSecondary,
                    foregroundColor: AppColors.textPrimaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.borderDefault),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _previewProfile,
                  icon: const Icon(Icons.preview),
                  label: const Text('Preview Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
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
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Preview',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderDefault,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.textSecondaryDark,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profile Preview',
                    style: AppTypography.body1.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your customized profile will appear here',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomizationModal(ProfileCustomizationOption option) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondaryDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: option.iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        option.icon,
                        color: option.iconColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: AppTypography.h3.copyWith(
                              color: AppColors.textPrimaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            option.description,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (option.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.feedbackWarning,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Content
                option.content,
                
                const SizedBox(height: 20),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.borderDefault),
                          foregroundColor: AppColors.textPrimaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _saveCustomization(option);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Content builders for each customization option
  Widget _buildProfileThemeContent() {
    final themes = [
      {'name': 'Default', 'color': AppColors.primaryLight},
      {'name': 'Ocean', 'color': Colors.blue},
      {'name': 'Sunset', 'color': Colors.orange},
      {'name': 'Forest', 'color': Colors.green},
      {'name': 'Purple', 'color': Colors.purple},
    ];

    return Column(
      children: [
        Text(
          'Choose your profile theme',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: themes.map((theme) {
            return GestureDetector(
              onTap: () {
                HapticFeedbackService.selection();
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme['color'] as Color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderDefault,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    theme['name'] as String,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfileLayoutContent() {
    return Column(
      children: [
        Text(
          'Select profile layout style',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildLayoutOption('Grid Layout', Icons.grid_view, 'Organized grid format'),
        const SizedBox(height: 12),
        _buildLayoutOption('Card Layout', Icons.view_agenda, 'Card-based design'),
        const SizedBox(height: 12),
        _buildLayoutOption('Timeline Layout', Icons.timeline, 'Chronological view'),
      ],
    );
  }

  Widget _buildLayoutOption(String title, IconData icon, String description) {
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
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
          Radio(
            value: title,
            groupValue: 'Grid Layout',
            onChanged: (value) {
              HapticFeedbackService.selection();
            },
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSectionsContent() {
    final sections = [
      {'name': 'About Me', 'enabled': true},
      {'name': 'Interests', 'enabled': true},
      {'name': 'Photos', 'enabled': true},
      {'name': 'Music', 'enabled': false},
      {'name': 'Movies', 'enabled': false},
      {'name': 'Books', 'enabled': false},
      {'name': 'Travel', 'enabled': false},
    ];

    return Column(
      children: [
        Text(
          'Enable or disable profile sections',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        ...sections.map((section) {
          return SwitchListTile(
            title: Text(
              section['name'] as String,
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            value: section['enabled'] as bool,
            onChanged: (value) {
              HapticFeedbackService.selection();
            },
            activeColor: AppColors.primaryLight,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildProfileVisibilityContent() {
    return Column(
      children: [
        Text(
          'Control profile visibility',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildVisibilityOption('Public', 'Everyone can see your profile'),
        const SizedBox(height: 12),
        _buildVisibilityOption('Friends Only', 'Only your matches can see'),
        const SizedBox(height: 12),
        _buildVisibilityOption('Private', 'Only you can see your profile'),
      ],
    );
  }

  Widget _buildVisibilityOption(String title, String description) {
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
      child: Row(
        children: [
          Radio(
            value: title,
            groupValue: 'Public',
            onChanged: (value) {
              HapticFeedbackService.selection();
            },
            activeColor: AppColors.primaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHighlightsContent() {
    return Column(
      children: [
        Text(
          'Add special highlights to your profile',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.feedbackWarning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.feedbackWarning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.feedbackWarning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This feature is available for Premium users only.',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.feedbackWarning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAnimationsContent() {
    return Column(
      children: [
        Text(
          'Customize profile animations',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            'Enable Animations',
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          subtitle: Text(
            'Smooth transitions and effects',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          value: true,
          onChanged: (value) {
            HapticFeedbackService.selection();
          },
          activeColor: AppColors.primaryLight,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(
            'Parallax Effects',
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          subtitle: Text(
            'Depth and movement effects',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          value: false,
          onChanged: (value) {
            HapticFeedbackService.selection();
          },
          activeColor: AppColors.primaryLight,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildProfileWidgetsContent() {
    return Column(
      children: [
        Text(
          'Add interactive widgets',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.feedbackWarning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.feedbackWarning.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.feedbackWarning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Interactive widgets are available for Premium users only.',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.feedbackWarning,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileIntegrationsContent() {
    final integrations = [
      {'name': 'Instagram', 'icon': Icons.camera_alt, 'connected': false},
      {'name': 'Spotify', 'icon': Icons.music_note, 'connected': false},
      {'name': 'Twitter', 'icon': Icons.alternate_email, 'connected': false},
      {'name': 'LinkedIn', 'icon': Icons.business, 'connected': false},
    ];

    return Column(
      children: [
        Text(
          'Connect your social accounts',
          style: AppTypography.body1.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        ...integrations.map((integration) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderDefault,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  integration['icon'] as IconData,
                  color: AppColors.primaryLight,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    integration['name'] as String,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedbackService.selection();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    integration['connected'] as bool ? 'Connected' : 'Connect',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _resetToDefaults() {
    HapticFeedbackService.selection();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Reset to Defaults',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'Are you sure you want to reset all customizations to default settings?',
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
              HapticFeedbackService.success();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.feedbackError),
            ),
          ),
        ],
      ),
    );
  }

  void _previewProfile() {
    HapticFeedbackService.selection();
    // TODO: Implement profile preview
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile preview coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _saveCustomization(ProfileCustomizationOption option) {
    HapticFeedbackService.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${option.title} customization applied!'),
        backgroundColor: AppColors.feedbackSuccess,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Profile Customization Help',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'Use the customization options to personalize your profile. Premium features are marked with a star icon.',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
