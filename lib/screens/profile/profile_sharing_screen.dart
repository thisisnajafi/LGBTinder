import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/profile_sharing_service.dart';
import '../services/haptic_feedback_service.dart';
import '../components/sharing/sharing_components.dart';
import '../components/buttons/animated_button.dart';

class ProfileSharingScreen extends StatefulWidget {
  const ProfileSharingScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSharingScreen> createState() => _ProfileSharingScreenState();
}

class _ProfileSharingScreenState extends State<ProfileSharingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _availablePlatforms = [];
  List<ShareHistory> _shareHistory = [];
  Map<String, dynamic>? _statistics;
  ShareContent? _shareContent;
  bool _isLoading = true;
  String _profileId = 'current_user'; // In a real app, this would come from user session

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadSharingData();
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

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadSharingData() async {
    try {
      final platforms = ProfileSharingService.instance.getAvailableSharePlatforms();
      final history = await ProfileSharingService.instance.getShareHistory(limit: 20);
      final statistics = await ProfileSharingService.instance.getShareStatistics();
      final content = await ProfileSharingService.instance.generateProfileShareContent(
        profileId: _profileId,
        userName: 'John Doe', // In a real app, this would come from user data
        userBio: 'Love to travel and meet new people!',
        userImage: 'https://example.com/profile.jpg',
        interests: ['Travel', 'Music', 'Photography'],
        location: 'New York, NY',
        age: 25,
        gender: 'Male',
      );
      
      if (mounted) {
        setState(() {
          _availablePlatforms = platforms;
          _shareHistory = history;
          _statistics = statistics;
          _shareContent = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryLight,
          ),
        ),
      );
    }

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
          'Share Profile',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimaryDark),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.textPrimaryDark),
            onPressed: _exportData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryDark,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Share'),
            Tab(text: 'History'),
            Tab(text: 'Stats'),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShareTab(),
                  _buildHistoryTab(),
                  _buildStatsTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShareTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_shareContent != null)
            ShareContentPreview(
              content: _shareContent!,
              onTap: _showContentDetails,
            ),
          
          const SizedBox(height: 24),
          
          ShareQuickActions(
            onShareAll: _showShareOptions,
            onShareLink: _shareAsLink,
            onShareQR: _shareAsQRCode,
            onShareImage: _saveImage,
          ),
          
          const SizedBox(height: 24),
          
          _buildSharePlatforms(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_shareHistory.isEmpty)
            _buildEmptyHistoryState()
          else
            ..._shareHistory.map((history) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShareHistoryCard(
                  history: history,
                  onTap: () => _showHistoryDetails(history),
                ),
              );
            }),
          
          const SizedBox(height: 24),
          
          _buildHistoryActions(),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_statistics != null)
            ShareStatisticsCard(
              statistics: _statistics!,
              onTap: _showDetailedStats,
            ),
          
          const SizedBox(height: 24),
          
          if (_statistics != null) _buildTopPlatforms(),
          
          const SizedBox(height: 24),
          
          if (_statistics != null) _buildTopTypes(),
          
          const SizedBox(height: 24),
          
          _buildStatsActions(),
        ],
      ),
    );
  }

  Widget _buildSharePlatforms() {
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
            'Share to Platform',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._availablePlatforms.map((platform) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SharePlatformCard(
                platform: platform,
                isEnabled: platform['enabled'],
                onTap: () => _shareToPlatform(platform['platform']),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.share_outlined,
            size: 64,
            color: AppColors.textSecondaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'No Share History',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start sharing your profile to see your share history',
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryActions() {
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
            'History Actions',
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
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackError,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildTopPlatforms() {
    final topPlatforms = _statistics!['topPlatforms'] as List;
    
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
            'Top Platforms',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topPlatforms.map((platform) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      platform['platform'],
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  Text(
                    '${platform['count']} shares',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopTypes() {
    final topTypes = _statistics!['topTypes'] as List;
    
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
            'Top Share Types',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      type['type'],
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  Text(
                    '${type['count']} shares',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsActions() {
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
            'Statistics Actions',
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
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportData,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackInfo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Share Method',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ..._availablePlatforms.take(6).map((platform) {
              return ListTile(
                leading: Icon(
                  _getPlatformIcon(platform['icon']),
                  color: Color(platform['color']),
                ),
                title: Text(
                  platform['name'],
                  style: const TextStyle(color: AppColors.textPrimaryDark),
                ),
                subtitle: Text(
                  platform['description'],
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _shareToPlatform(platform['platform']);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _shareToPlatform(SharePlatform platform) {
    HapticFeedbackService.selection();
    
    if (_shareContent == null) return;
    
    ProfileSharingService.instance.shareProfile(
      platform: platform,
      content: _shareContent!,
    ).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile shared to ${_getPlatformDisplayName(platform)} successfully!'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share to ${_getPlatformDisplayName(platform)}'),
            backgroundColor: AppColors.feedbackError,
          ),
        );
      }
    });
  }

  void _shareAsLink() {
    HapticFeedbackService.selection();
    _shareToPlatform(SharePlatform.copyLink);
  }

  void _shareAsQRCode() {
    HapticFeedbackService.selection();
    _shareToPlatform(SharePlatform.qrCode);
  }

  void _saveImage() {
    HapticFeedbackService.selection();
    _shareToPlatform(SharePlatform.saveImage);
  }

  void _refreshData() {
    HapticFeedbackService.selection();
    setState(() {
      _isLoading = true;
    });
    _loadSharingData();
  }

  void _exportData() {
    HapticFeedbackService.selection();
    ProfileSharingService.instance.exportShareData().then((data) {
      // TODO: Implement data export
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data export coming soon!'),
          backgroundColor: AppColors.feedbackInfo,
        ),
      );
    });
  }

  void _clearHistory() {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Clear Share History',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'Are you sure you want to clear all share history? This action cannot be undone.',
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
              ProfileSharingService.instance.clearShareHistory().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share history cleared'),
                    backgroundColor: AppColors.feedbackSuccess,
                  ),
                );
                _refreshData();
              });
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.feedbackError),
            ),
          ),
        ],
      ),
    );
  }

  void _showContentDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Share Content Details',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_shareContent != null) ...[
                Text(
                  'Title: ${_shareContent!.title}',
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description: ${_shareContent!.description}',
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
                if (_shareContent!.link != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Link: ${_shareContent!.link}',
                    style: const TextStyle(color: AppColors.textSecondaryDark),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryDetails(ShareHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          _getPlatformDisplayName(history.platform),
          style: const TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time: ${_formatDate(history.timestamp)}',
              style: const TextStyle(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${history.isSuccessful ? 'Success' : 'Failed'}',
              style: TextStyle(
                color: history.isSuccessful 
                    ? AppColors.feedbackSuccess
                    : AppColors.feedbackError,
              ),
            ),
            if (history.recipientName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Recipient: ${history.recipientName}',
                style: const TextStyle(color: AppColors.textSecondaryDark),
              ),
            ],
            if (history.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${history.errorMessage}',
                style: const TextStyle(color: AppColors.feedbackError),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Detailed Statistics',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_statistics != null) ...[
                Text(
                  'Total Shares: ${_statistics!['totalShares']}',
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Successful: ${_statistics!['successfulShares']}',
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed: ${_statistics!['failedShares']}',
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Success Rate: ${_statistics!['successRate'].toStringAsFixed(1)}%',
                  style: const TextStyle(color: AppColors.textSecondaryDark),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String iconName) {
    switch (iconName) {
      case 'whatsapp':
        return Icons.chat;
      case 'telegram':
        return Icons.send;
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'twitter':
        return Icons.alternate_email;
      case 'snapchat':
        return Icons.camera_front;
      case 'tiktok':
        return Icons.video_call;
      case 'email':
        return Icons.email;
      case 'sms':
        return Icons.sms;
      case 'link':
        return Icons.link;
      case 'qr_code':
        return Icons.qr_code;
      case 'save':
        return Icons.save;
      default:
        return Icons.share;
    }
  }

  String _getPlatformDisplayName(SharePlatform platform) {
    switch (platform) {
      case SharePlatform.whatsapp:
        return 'WhatsApp';
      case SharePlatform.telegram:
        return 'Telegram';
      case SharePlatform.instagram:
        return 'Instagram';
      case SharePlatform.facebook:
        return 'Facebook';
      case SharePlatform.twitter:
        return 'Twitter';
      case SharePlatform.snapchat:
        return 'Snapchat';
      case SharePlatform.tiktok:
        return 'TikTok';
      case SharePlatform.email:
        return 'Email';
      case SharePlatform.sms:
        return 'SMS';
      case SharePlatform.link:
        return 'Copy Link';
      case SharePlatform.qrCode:
        return 'QR Code';
      case SharePlatform.copyLink:
        return 'Copy Link';
      case SharePlatform.saveImage:
        return 'Save Image';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
