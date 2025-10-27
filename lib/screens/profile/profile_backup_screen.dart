import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_backup_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../../components/backup/backup_components.dart';
import '../../components/buttons/animated_button.dart';

class ProfileBackupScreen extends StatefulWidget {
  const ProfileBackupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileBackupScreen> createState() => _ProfileBackupScreenState();
}

class _ProfileBackupScreenState extends State<ProfileBackupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _availableProviders = [];
  List<BackupItem> _backupHistory = [];
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _backupSettings;
  bool _isLoading = true;
  String _profileId = 'current_user'; // In a real app, this would come from user session

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadBackupData();
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

  Future<void> _loadBackupData() async {
    try {
      final providers = ProfileBackupService.instance.getAvailableCloudProviders();
      final history = await ProfileBackupService.instance.getBackupHistory();
      final statistics = await ProfileBackupService.instance.getBackupStatistics();
      final settings = await ProfileBackupService.instance.getBackupSettings();
      
      if (mounted) {
        setState(() {
          _availableProviders = providers;
          _backupHistory = history;
          _statistics = statistics;
          _backupSettings = settings;
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
          'Profile Backup',
          style: AppTypography.titleLarge.copyWith(
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
            icon: const Icon(Icons.settings, color: AppColors.textPrimaryDark),
            onPressed: _showBackupSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryDark,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Backup'),
            Tab(text: 'History'),
            Tab(text: 'Settings'),
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
                  _buildBackupTab(),
                  _buildHistoryTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Current Status
          BackupStatusCard(
            status: ProfileBackupService.instance.currentStatus,
            progress: ProfileBackupService.instance.currentProgress,
            onTap: _showStatusDetails,
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // Cloud Providers
          _buildCloudProviders(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_statistics != null)
            BackupStatisticsCard(
              statistics: _statistics!,
              onTap: _showDetailedStats,
            ),
          
          const SizedBox(height: 24),
          
          if (_backupHistory.isEmpty)
            _buildEmptyHistoryState()
          else
            ..._backupHistory.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BackupItemCard(
                  item: item,
                  onTap: () => _showBackupDetails(item),
                  onRestore: () => _restoreBackup(item),
                  onDelete: () => _deleteBackup(item),
                ),
              );
            }),
          
          const SizedBox(height: 24),
          
          _buildHistoryActions(),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildBackupSettings(),
          
          const SizedBox(height: 24),
          
          _buildAutoBackupSettings(),
          
          const SizedBox(height: 24),
          
          _buildDataSelectionSettings(),
          
          const SizedBox(height: 24),
          
          _buildSecuritySettings(),
        ],
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
                  onPressed: _createFullBackup,
                  icon: const Icon(Icons.backup, size: 18),
                  label: const Text('Full Backup'),
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
                  onPressed: _createIncrementalBackup,
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('Incremental'),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _createSelectiveBackup,
                  icon: const Icon(Icons.checklist, size: 18),
                  label: const Text('Selective'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackSuccess,
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
                  onPressed: _showRestoreOptions,
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Restore'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackWarning,
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

  Widget _buildCloudProviders() {
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
            'Cloud Providers',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._availableProviders.map((provider) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CloudProviderCard(
                provider: provider,
                isSelected: provider['provider'] == ProfileBackupService.instance.selectedProvider,
                onTap: () => _selectCloudProvider(provider['provider']),
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
            Icons.backup_outlined,
            size: 64,
            color: AppColors.textSecondaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'No Backup History',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first backup to protect your profile data',
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

  Widget _buildBackupSettings() {
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
            'Backup Settings',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'WiFi Only',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            subtitle: const Text(
              'Only backup when connected to WiFi',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            value: _backupSettings?['wifiOnly'] ?? true,
            onChanged: (value) => _updateSetting('wifiOnly', value),
            activeColor: AppColors.primaryLight,
          ),
          SwitchListTile(
            title: const Text(
              'Battery Optimized',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            subtitle: const Text(
              'Optimize backup for battery life',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            value: _backupSettings?['batteryOptimized'] ?? true,
            onChanged: (value) => _updateSetting('batteryOptimized', value),
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildAutoBackupSettings() {
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
            'Auto Backup',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Enable Auto Backup',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            subtitle: const Text(
              'Automatically backup your profile',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            value: _backupSettings?['autoBackupEnabled'] ?? false,
            onChanged: (value) => _updateSetting('autoBackupEnabled', value),
            activeColor: AppColors.primaryLight,
          ),
          if (_backupSettings?['autoBackupEnabled'] == true) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _backupSettings?['autoBackupFrequency'] ?? 'weekly',
              decoration: const InputDecoration(
                labelText: 'Backup Frequency',
                labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) => _updateSetting('autoBackupFrequency', value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataSelectionSettings() {
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
            'Data Selection',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Include Photos',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            subtitle: const Text(
              'Backup profile photos',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            value: _backupSettings?['includePhotos'] ?? true,
            onChanged: (value) => _updateSetting('includePhotos', value),
            activeColor: AppColors.primaryLight,
          ),
          SwitchListTile(
            title: const Text(
              'Include Messages',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            subtitle: const Text(
              'Backup chat messages',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            value: _backupSettings?['includeMessages'] ?? true,
            onChanged: (value) => _updateSetting('includeMessages', value),
            activeColor: AppColors.primaryLight,
          ),
          SwitchListTile(
            title: const Text(
              'Include Settings',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            subtitle: const Text(
              'Backup app settings',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            value: _backupSettings?['includeSettings'] ?? true,
            onChanged: (value) => _updateSetting('includeSettings', value),
            activeColor: AppColors.primaryLight,
          ),
          SwitchListTile(
            title: const Text(
              'Include Analytics',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            subtitle: const Text(
              'Backup analytics data',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            value: _backupSettings?['includeAnalytics'] ?? false,
            onChanged: (value) => _updateSetting('includeAnalytics', value),
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
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
            'Security',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Encrypt Data',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
            ),
            subtitle: const Text(
              'Encrypt backup data for security',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            value: _backupSettings?['encryptData'] ?? true,
            onChanged: (value) => _updateSetting('encryptData', value),
            activeColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }

  // Action methods
  void _createFullBackup() {
    HapticFeedbackService.selection();
    ProfileBackupService.instance.createBackup(
      type: BackupType.full,
      profileId: _profileId,
      includePhotos: _backupSettings?['includePhotos'] ?? true,
      includeMessages: _backupSettings?['includeMessages'] ?? true,
      includeSettings: _backupSettings?['includeSettings'] ?? true,
      includeAnalytics: _backupSettings?['includeAnalytics'] ?? false,
      encryptData: _backupSettings?['encryptData'] ?? true,
      onProgress: (progress) {
        if (mounted) {
          setState(() {});
        }
      },
    ).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Full backup created successfully!'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create backup'),
            backgroundColor: AppColors.feedbackError,
          ),
        );
      }
    });
  }

  void _createIncrementalBackup() {
    HapticFeedbackService.selection();
    ProfileBackupService.instance.createBackup(
      type: BackupType.incremental,
      profileId: _profileId,
      includePhotos: _backupSettings?['includePhotos'] ?? true,
      includeMessages: _backupSettings?['includeMessages'] ?? true,
      includeSettings: _backupSettings?['includeSettings'] ?? true,
      includeAnalytics: _backupSettings?['includeAnalytics'] ?? false,
      encryptData: _backupSettings?['encryptData'] ?? true,
      onProgress: (progress) {
        if (mounted) {
          setState(() {});
        }
      },
    ).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incremental backup created successfully!'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
        _refreshData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create incremental backup'),
            backgroundColor: AppColors.feedbackError,
          ),
        );
      }
    });
  }

  void _createSelectiveBackup() {
    HapticFeedbackService.selection();
    _showSelectiveBackupDialog();
  }

  void _showRestoreOptions() {
    HapticFeedbackService.selection();
    if (_backupHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No backups available to restore'),
          backgroundColor: AppColors.feedbackWarning,
        ),
      );
      return;
    }
    
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
              'Select Backup to Restore',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ..._backupHistory.take(5).map((item) {
              return ListTile(
                leading: Icon(
                  _getTypeIcon(item.type),
                  color: AppColors.primaryLight,
                ),
                title: Text(
                  item.name,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
                ),
                subtitle: Text(
                  _formatDate(item.createdAt),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _restoreBackup(item);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _selectCloudProvider(CloudProvider provider) {
    HapticFeedbackService.selection();
    ProfileBackupService.instance.setCloudProvider(provider);
    setState(() {});
  }

  void _restoreBackup(BackupItem item) {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Restore Backup',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Are you sure you want to restore "${item.name}"? This will replace your current profile data.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ProfileBackupService.instance.restoreFromBackup(
                backupId: item.id,
                restorePhotos: _backupSettings?['includePhotos'] ?? true,
                restoreMessages: _backupSettings?['includeMessages'] ?? true,
                restoreSettings: _backupSettings?['includeSettings'] ?? true,
                restoreAnalytics: _backupSettings?['includeAnalytics'] ?? false,
                onProgress: (progress) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              ).then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup restored successfully!'),
                      backgroundColor: AppColors.feedbackSuccess,
                    ),
                  );
                  _refreshData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to restore backup'),
                      backgroundColor: AppColors.feedbackError,
                    ),
                  );
                }
              });
            },
            child: const Text(
              'Restore',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteBackup(BackupItem item) {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Delete Backup',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ProfileBackupService.instance.deleteBackup(item.id).then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup deleted successfully'),
                      backgroundColor: AppColors.feedbackSuccess,
                    ),
                  );
                  _refreshData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete backup'),
                      backgroundColor: AppColors.feedbackError,
                    ),
                  );
                }
              });
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

  void _refreshData() {
    HapticFeedbackService.selection();
    setState(() {
      _isLoading = true;
    });
    _loadBackupData();
  }

  void _clearHistory() {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Clear Backup History',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'Are you sure you want to clear all backup history? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup history cleared'),
                  backgroundColor: AppColors.feedbackSuccess,
                ),
              );
              _refreshData();
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

  void _updateSetting(String key, dynamic value) {
    HapticFeedbackService.selection();
    setState(() {
      _backupSettings![key] = value;
    });
    ProfileBackupService.instance.updateBackupSettings(_backupSettings!);
  }

  void _showBackupSettings() {
    HapticFeedbackService.selection();
    // TODO: Show advanced backup settings
  }

  void _showStatusDetails() {
    HapticFeedbackService.selection();
    // TODO: Show detailed status information
  }

  void _showBackupDetails(BackupItem item) {
    HapticFeedbackService.selection();
    // TODO: Show detailed backup information
  }

  void _showDetailedStats() {
    HapticFeedbackService.selection();
    // TODO: Show detailed statistics
  }

  void _showSelectiveBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Selective Backup',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'Selective backup options coming soon!',
          style: TextStyle(color: AppColors.textSecondaryDark),
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

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'full':
        return Icons.backup;
      case 'incremental':
        return Icons.update;
      case 'selective':
        return Icons.checklist;
      case 'automatic':
        return Icons.schedule;
      case 'manual':
        return Icons.touch_app;
      default:
        return Icons.backup;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
