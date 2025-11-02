import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_export_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../../components/export/export_components.dart';
import '../../components/buttons/animated_button.dart';

class ProfileExportScreen extends StatefulWidget {
  const ProfileExportScreen({Key? key}) : super(key: key);

  @override
  State<ProfileExportScreen> createState() => _ProfileExportScreenState();
}

class _ProfileExportScreenState extends State<ProfileExportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _availableFormats = [];
  List<Map<String, dynamic>> _availableTypes = [];
  List<ExportRequest> _exportHistory = [];
  Map<String, dynamic>? _statistics;
  Map<String, dynamic>? _exportSettings;
  bool _isLoading = true;
  String _userId = 'current_user'; // In a real app, this would come from user session

  ExportFormat? _selectedFormat;
  ExportType? _selectedType;
  List<String> _selectedDataTypes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadExportData();
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

  Future<void> _loadExportData() async {
    try {
      final formats = ProfileExportService.instance.getAvailableFormats();
      final types = ProfileExportService.instance.getAvailableTypes();
      final history = await ProfileExportService.instance.getExportHistory(_userId);
      final statistics = await ProfileExportService.instance.getExportStatistics(_userId);
      final settings = await ProfileExportService.instance.getExportSettings();
      
      if (mounted) {
        setState(() {
          _availableFormats = formats;
          _availableTypes = types;
          _exportHistory = history;
          _statistics = statistics;
          _exportSettings = settings;
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
        title: Text(
          'Profile Export',
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
            onPressed: _showExportSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryDark,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Export'),
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
                  _buildExportTab(),
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

  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Current Progress
          if (ProfileExportService.instance.currentStatus != ExportStatus.idle)
            ExportProgressCard(
              progress: ProfileExportService.instance.currentProgress!,
              onCancel: _cancelExport,
            ),
          
          if (ProfileExportService.instance.currentStatus != ExportStatus.idle)
            const SizedBox(height: 24),
          
          // Export Formats
          _buildExportFormats(),
          
          const SizedBox(height: 24),
          
          // Export Types
          _buildExportTypes(),
          
          const SizedBox(height: 24),
          
          // Data Types Selection
          if (_selectedType == ExportType.custom)
            _buildDataTypesSelection(),
          
          if (_selectedType == ExportType.custom)
            const SizedBox(height: 24),
          
          // Export Button
          _buildExportButton(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_exportHistory.isEmpty)
            _buildEmptyHistoryState()
          else
            ..._exportHistory.map((request) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExportRequestCard(
                  request: request,
                  onTap: () => _showRequestDetails(request),
                  onDownload: () => _downloadExport(request),
                  onDelete: () => _deleteExport(request),
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
            ExportStatisticsCard(
              statistics: _statistics!,
              onTap: _showDetailedStats,
            ),
          
          const SizedBox(height: 24),
          
          if (_statistics != null) _buildTopFormats(),
          
          const SizedBox(height: 24),
          
          if (_statistics != null) _buildTopTypes(),
        ],
      ),
    );
  }

  Widget _buildExportFormats() {
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
            'Export Format',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._availableFormats.map((format) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExportFormatCard(
                format: format,
                isSelected: _selectedFormat == format['format'],
                onTap: () {
                  setState(() {
                    _selectedFormat = format['format'];
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExportTypes() {
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
            'Export Type',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._availableTypes.map((type) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExportTypeCard(
                type: type,
                isSelected: _selectedType == type['type'],
                onTap: () {
                  setState(() {
                    _selectedType = type['type'];
                    _selectedDataTypes = List<String>.from(type['dataTypes']);
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDataTypesSelection() {
    final allDataTypes = ['profile', 'photos', 'messages', 'analytics', 'settings'];
    
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
            'Select Data Types',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allDataTypes.map((dataType) {
              final isSelected = _selectedDataTypes.contains(dataType);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDataTypes.remove(dataType);
                    } else {
                      _selectedDataTypes.add(dataType);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryLight.withOpacity(0.1)
                        : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primaryLight
                          : AppColors.borderDefault,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected 
                            ? AppColors.primaryLight
                            : AppColors.textSecondaryDark,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dataType.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: isSelected 
                              ? AppColors.primaryLight
                              : AppColors.textSecondaryDark,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    final canExport = _selectedFormat != null && 
                      _selectedType != null && 
                      (_selectedType != ExportType.custom || _selectedDataTypes.isNotEmpty);
    
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
            'Export Profile',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canExport ? _startExport : null,
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Start Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (!canExport) ...[
            const SizedBox(height: 12),
            Text(
              'Please select a format and type to start export',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
            Icons.download_outlined,
            size: 64,
            color: AppColors.textSecondaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'No Export History',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start exporting your profile data to see your export history',
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

  Widget _buildTopFormats() {
    final topFormats = _statistics!['topFormats'] as List;
    
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
            'Top Export Formats',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topFormats.map((format) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      format['format'].toUpperCase(),
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${format['count']} exports',
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
            'Top Export Types',
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
                      type['type'].toUpperCase(),
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${type['count']} exports',
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

  // Action methods
  void _startExport() {
    HapticFeedbackService.selection();
    
    if (_selectedFormat == null || _selectedType == null) return;
    
    ProfileExportService.instance.createExportRequest(
      userId: _userId,
      format: _selectedFormat!,
      type: _selectedType!,
      dataTypes: _selectedDataTypes,
      onProgress: (progress) {
        if (mounted) {
          setState(() {});
        }
      },
    ).then((request) {
      if (request.status == ExportStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export completed successfully!'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
        _refreshData();
      } else if (request.status == ExportStatus.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${request.errorMessage}'),
            backgroundColor: AppColors.feedbackError,
          ),
        );
      }
    });
  }

  void _cancelExport() {
    HapticFeedbackService.selection();
    ProfileExportService.instance.cancelCurrentExport();
    setState(() {});
  }

  void _downloadExport(ExportRequest request) {
    HapticFeedbackService.selection();
    // TODO: Implement file download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _deleteExport(ExportRequest request) {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Delete Export',
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Are you sure you want to delete this export? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (request.filePath != null) {
                ProfileExportService.instance.deleteExportFile(request.filePath!).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export deleted successfully'),
                        backgroundColor: AppColors.feedbackSuccess,
                      ),
                    );
                    _refreshData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete export'),
                        backgroundColor: AppColors.feedbackError,
                      ),
                    );
                  }
                });
              }
            },
            child: Text(
              'Delete',
              style: AppTypography.button.copyWith(color: AppColors.feedbackError),
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
    _loadExportData();
  }

  void _clearHistory() {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Clear Export History',
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Are you sure you want to clear all export history? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ProfileExportService.instance.clearExportHistory(_userId).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export history cleared'),
                    backgroundColor: AppColors.feedbackSuccess,
                  ),
                );
                _refreshData();
              });
            },
            child: Text(
              'Clear',
              style: AppTypography.button.copyWith(color: AppColors.feedbackError),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(ExportRequest request) {
    HapticFeedbackService.selection();
    // TODO: Show detailed request information
  }

  void _showDetailedStats() {
    HapticFeedbackService.selection();
    // TODO: Show detailed statistics
  }

  void _showExportSettings() {
    HapticFeedbackService.selection();
    // TODO: Show export settings
  }
}
