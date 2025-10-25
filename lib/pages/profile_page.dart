import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/profile/profile_header.dart';
import '../components/profile/profile_info_sections.dart';
import '../components/profile/photo_gallery.dart';
import '../components/profile/safety_verification_section.dart';
import '../components/error_handling/error_display_widget.dart';
import '../components/loading/loading_widgets.dart';
import '../components/loading/skeleton_loader.dart';
import '../components/offline/offline_wrapper.dart';
import '../providers/profile_state_provider.dart';
import '../providers/profile_provider.dart';
import '../models/api_models/user_models.dart';
import '../models/user.dart';
import '../models/user_image.dart' as user_image;
import '../services/analytics_service.dart';
import '../services/error_monitoring_service.dart';
import '../screens/safety_settings_screen.dart';
import '../screens/profile/advanced_profile_customization_screen.dart';
import '../screens/profile/profile_completion_incentives_screen.dart';
import '../screens/profile/profile_verification_screen.dart';
import '../screens/profile/profile_analytics_screen.dart';
import '../screens/profile/profile_sharing_screen.dart';
import '../components/profile/customizable_profile_widget.dart';
import '../services/profile_customization_service.dart';
import '../services/gamification_service.dart';
import '../services/profile_verification_service.dart';
import '../services/profile_analytics_service.dart';
import '../services/profile_sharing_service.dart';
import '../services/profile_backup_service.dart';
import '../services/profile_template_service.dart';
import '../services/profile_export_service.dart';
import 'profile_edit_page.dart';
import 'profile_wizard_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize profile data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    try {
      await AnalyticsService.trackEvent(
        name: 'profile_view',
        action: 'profile_view',
        category: 'profile',
      );
      
      final profileProvider = context.read<ProfileStateProvider>();
      await profileProvider.loadCurrentUser();
    } catch (e) {
      await ErrorMonitoringService.logError(
        message: e.toString(),
        context: {'operation': 'ProfilePage._loadProfile'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: OfflineWrapper(
        child: Consumer<ProfileStateProvider>(
          builder: (context, profileProvider, child) {
            if (profileProvider.isLoading) {
              return _buildLoadingState();
            }

            if (profileProvider.error != null) {
              return _buildErrorState(profileProvider.error!);
            }

            final user = profileProvider.currentUser;
            if (user == null) {
              return _buildEmptyState();
            }

            return _buildProfileContent(user, profileProvider);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile header skeleton
          SkeletonCard(
            height: 200,
          ),
          const SizedBox(height: 20),
          
          // Profile info sections skeleton
          SkeletonCard(
            height: 150,
          ),
          const SizedBox(height: 20),
          
          // Photo gallery skeleton
          SkeletonCard(
            height: 120,
          ),
          const SizedBox(height: 20),
          
          // Safety verification skeleton
          SkeletonCard(
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return ErrorDisplayWidget(
      error: error,
      context: 'load_profile',
      onRetry: _loadProfile,
      isFullScreen: true,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              'No Profile Found',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your profile information could not be loaded. Please try again.',
              textAlign: TextAlign.center,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(User user, ProfileStateProvider profileProvider) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 0,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.appBackground,
          elevation: 0,
          title: Text(
            _isEditMode ? 'Edit Profile' : 'Profile',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (!_isEditMode) ...[
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: _showSettings,
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEditPage()),
                ),
              ),
            ] else ...[
              TextButton(
                onPressed: () => setState(() => _isEditMode = false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: _saveProfile,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                ProfileHeader(
                  user: user,
                  onEditPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileEditPage()),
                  ),
                ),
                const SizedBox(height: 24),

                // Profile Completion Progress
                if (!_isEditMode) _buildProfileCompletionCard(profileProvider),

                const SizedBox(height: 24),

                // Profile Information Sections
                ProfileInfoSections(
                  user: user,
                ),
                const SizedBox(height: 24),

                // Photo Gallery
                if (user.avatarUrl != null) ...[
                  PhotoGallery(images: [
                    user_image.UserImage(
                      id: 1,
                      url: user.avatarUrl!,
                      type: 'profile',
                      isPrimary: true,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    )
                  ]),
                  const SizedBox(height: 24),
                ],

                // Safety & Verification Section
                SafetyVerificationSection(
                  verification: null, // This would come from the provider
                  onVerifyPressed: _showVerificationOptions,
                ),
                const SizedBox(height: 24),

                // Action Buttons (for own profile, show management options)
                if (!_isEditMode) _buildManagementButtons(profileProvider),

                const SizedBox(height: 96), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletionCard(ProfileStateProvider profileProvider) {
    // Create a mock completion percentage for now
    final completionPercentage = 75; // This would come from the provider
    final missingFields = ['Bio', 'Photos', 'Interests']; // This would come from the provider
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.assessment,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: completionPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$completionPercentage%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (missingFields.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Complete your profile by adding:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: missingFields.map((field) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    field,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManagementButtons(ProfileStateProvider profileProvider) {
    return Column(
      children: [
        // Quick Actions
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                icon: Icons.photo_camera,
                label: 'Add Photos',
                onTap: _showPhotoOptions,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementButton(
                icon: Icons.verified_user,
                label: 'Verify Profile',
                onTap: _showVerificationOptions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                icon: Icons.tune,
                label: 'Preferences',
                onTap: _showPreferences,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementButton(
                icon: Icons.privacy_tip,
                label: 'Privacy',
                onTap: _showPrivacySettings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                icon: Icons.palette,
                label: 'Customize',
                onTap: _showAdvancedCustomization,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementButton(
                icon: Icons.edit,
                label: 'Edit Profile',
                onTap: _editProfile,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                icon: Icons.emoji_events,
                label: 'Achievements',
                onTap: _showProfileIncentives,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementButton(
                icon: Icons.trending_up,
                label: 'Progress',
                onTap: _showProfileProgress,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                icon: Icons.verified,
                label: 'Verification',
                onTap: _showProfileVerification,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementButton(
                icon: Icons.privacy_tip,
                label: 'Privacy',
                onTap: _showPrivacySettings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                icon: Icons.analytics,
                label: 'Analytics',
                onTap: _showProfileAnalytics,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementButton(
                icon: Icons.settings,
                label: 'Settings',
                onTap: _showSettings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                icon: Icons.share,
                label: 'Share Profile',
                onTap: _showProfileSharing,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementButton(
                icon: Icons.backup,
                label: 'Backup',
                onTap: _showProfileBackup,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildManagementButton(
                icon: Icons.dashboard,
                label: 'Templates',
                onTap: _showProfileTemplates,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildManagementButton(
                icon: Icons.download,
                label: 'Export',
                onTap: _showProfileExport,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods

  void _showSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _saveProfile() {
    // TODO: Save profile changes
    setState(() => _isEditMode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Photos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open camera
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open gallery
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showVerificationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Verify Your Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildVerificationOption(
              icon: Icons.camera_alt,
              title: 'Photo Verification',
              description: 'Take a selfie to verify your identity',
              onTap: () {
                Navigator.pop(context);
                // TODO: Start photo verification
              },
            ),
            const SizedBox(height: 16),
            _buildVerificationOption(
              icon: Icons.credit_card,
              title: 'ID Verification',
              description: 'Upload government-issued ID',
              onTap: () {
                Navigator.pop(context);
                // TODO: Start ID verification
              },
            ),
            const SizedBox(height: 16),
            _buildVerificationOption(
              icon: Icons.videocam,
              title: 'Video Verification',
              description: 'Record a short video',
              onTap: () {
                Navigator.pop(context);
                // TODO: Start video verification
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showPreferences() {
    // TODO: Navigate to preferences page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences page coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showPrivacySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SafetySettingsScreen(),
      ),
    );
  }

  void _showAdvancedCustomization() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdvancedProfileCustomizationScreen(),
      ),
    );
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileEditPage(),
      ),
    );
  }

  void _showProfileIncentives() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileCompletionIncentivesScreen(),
      ),
    );
  }

  void _showProfileProgress() {
    Navigator.pushNamed(context, '/gamification-dashboard');
  }

  void _showProfileVerification() {
    Navigator.pushNamed(context, '/profile-verification');
  }

  void _showProfileAnalytics() {
    Navigator.pushNamed(context, '/profile-analytics');
  }

  void _showProfileSharing() {
    Navigator.pushNamed(context, '/profile-sharing');
  }

  void _showProfileBackup() {
    Navigator.pushNamed(context, '/profile-backup');
  }

  void _showProfileTemplates() {
    Navigator.pushNamed(context, '/profile-templates');
  }

  void _showProfileExport() {
    Navigator.pushNamed(context, '/profile-export');
  }
}
