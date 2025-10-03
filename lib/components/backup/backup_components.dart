import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/profile_backup_service.dart';
import '../services/haptic_feedback_service.dart';
import '../components/buttons/animated_button.dart';

class BackupStatusCard extends StatelessWidget {
  final BackupStatus status;
  final BackupProgress? progress;
  final VoidCallback? onTap;

  const BackupStatusCard({
    Key? key,
    required this.status,
    this.progress,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getStatusColors(status),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(status),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _getStatusTitle(status),
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.name.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (progress != null) ...[
              Text(
                progress!.operation,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress!.percentage / 100,
                backgroundColor: AppColors.surfaceSecondary,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progress!.percentage.toStringAsFixed(1)}%',
                    style: AppTypography.body2.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${progress!.currentStep}/${progress!.totalSteps}',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
              if (progress!.currentItem.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  progress!.currentItem,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ] else ...[
              Text(
                _getStatusDescription(status),
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Color> _getStatusColors(BackupStatus status) {
    switch (status) {
      case BackupStatus.idle:
        return [
          AppColors.surfaceSecondary,
          AppColors.surfaceSecondary,
        ];
      case BackupStatus.preparing:
      case BackupStatus.uploading:
      case BackupStatus.downloading:
      case BackupStatus.restoring:
        return [
          AppColors.feedbackInfo.withOpacity(0.1),
          AppColors.feedbackInfo.withOpacity(0.05),
        ];
      case BackupStatus.completed:
        return [
          AppColors.feedbackSuccess.withOpacity(0.1),
          AppColors.feedbackSuccess.withOpacity(0.05),
        ];
      case BackupStatus.failed:
        return [
          AppColors.feedbackError.withOpacity(0.1),
          AppColors.feedbackError.withOpacity(0.05),
        ];
      case BackupStatus.cancelled:
        return [
          AppColors.feedbackWarning.withOpacity(0.1),
          AppColors.feedbackWarning.withOpacity(0.05),
        ];
    }
  }

  Color _getStatusColor(BackupStatus status) {
    switch (status) {
      case BackupStatus.idle:
        return AppColors.textSecondaryDark;
      case BackupStatus.preparing:
      case BackupStatus.uploading:
      case BackupStatus.downloading:
      case BackupStatus.restoring:
        return AppColors.feedbackInfo;
      case BackupStatus.completed:
        return AppColors.feedbackSuccess;
      case BackupStatus.failed:
        return AppColors.feedbackError;
      case BackupStatus.cancelled:
        return AppColors.feedbackWarning;
    }
  }

  IconData _getStatusIcon(BackupStatus status) {
    switch (status) {
      case BackupStatus.idle:
        return Icons.backup;
      case BackupStatus.preparing:
        return Icons.settings_backup_restore;
      case BackupStatus.uploading:
        return Icons.cloud_upload;
      case BackupStatus.downloading:
        return Icons.cloud_download;
      case BackupStatus.restoring:
        return Icons.restore;
      case BackupStatus.completed:
        return Icons.check_circle;
      case BackupStatus.failed:
        return Icons.error;
      case BackupStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusTitle(BackupStatus status) {
    switch (status) {
      case BackupStatus.idle:
        return 'Backup Status';
      case BackupStatus.preparing:
        return 'Preparing Backup';
      case BackupStatus.uploading:
        return 'Uploading Backup';
      case BackupStatus.downloading:
        return 'Downloading Backup';
      case BackupStatus.restoring:
        return 'Restoring Backup';
      case BackupStatus.completed:
        return 'Backup Complete';
      case BackupStatus.failed:
        return 'Backup Failed';
      case BackupStatus.cancelled:
        return 'Backup Cancelled';
    }
  }

  String _getStatusDescription(BackupStatus status) {
    switch (status) {
      case BackupStatus.idle:
        return 'Ready to create or restore backups';
      case BackupStatus.preparing:
        return 'Preparing your profile data for backup';
      case BackupStatus.uploading:
        return 'Uploading backup to cloud storage';
      case BackupStatus.downloading:
        return 'Downloading backup from cloud storage';
      case BackupStatus.restoring:
        return 'Restoring your profile data';
      case BackupStatus.completed:
        return 'Backup operation completed successfully';
      case BackupStatus.failed:
        return 'Backup operation failed. Please try again';
      case BackupStatus.cancelled:
        return 'Backup operation was cancelled';
    }
  }
}

class BackupItemCard extends StatelessWidget {
  final BackupItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRestore;
  final VoidCallback? onDelete;

  const BackupItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onRestore,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(item.type),
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isEncrypted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.feedbackSuccess.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.lock,
                    color: AppColors.feedbackSuccess,
                    size: 12,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Size',
                  _formatFileSize(item.size),
                  Icons.storage,
                  AppColors.feedbackInfo,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Type',
                  item.type,
                  Icons.category,
                  AppColors.feedbackWarning,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onRestore?.call();
                  },
                  icon: const Icon(Icons.restore, size: 16),
                  label: const Text('Restore'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryLight),
                    foregroundColor: AppColors.primaryLight,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onDelete?.call();
                  },
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.feedbackError),
                    foregroundColor: AppColors.feedbackError,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class CloudProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final bool isSelected;
  final VoidCallback? onTap;

  const CloudProviderCard({
    Key? key,
    required this.provider,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Color(provider['color']).withOpacity(0.1)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Color(provider['color'])
                : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(provider['color']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getProviderIcon(provider['icon']),
                color: Color(provider['color']),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        provider['name'],
                        style: AppTypography.subtitle2.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: Color(provider['color']),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider['description'],
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.feedbackInfo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          provider['freeStorage'],
                          style: AppTypography.caption.copyWith(
                            color: AppColors.feedbackInfo,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!provider['enabled'])
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.feedbackError.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'UNAVAILABLE',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.feedbackError,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(String iconName) {
    switch (iconName) {
      case 'google_drive':
        return Icons.cloud;
      case 'dropbox':
        return Icons.cloud_queue;
      case 'icloud':
        return Icons.cloud_done;
      case 'onedrive':
        return Icons.cloud_upload;
      case 'firebase':
        return Icons.local_fire_department;
      case 'aws':
        return Icons.cloud_circle;
      default:
        return Icons.cloud;
    }
  }
}

class BackupStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final VoidCallback? onTap;

  const BackupStatisticsCard({
    Key? key,
    required this.statistics,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
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
                  Icons.analytics,
                  color: AppColors.primaryLight,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Backup Statistics',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${statistics['encryptionRate'].toStringAsFixed(1)}%',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.feedbackSuccess,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Key Metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Total Backups',
                    '${statistics['totalBackups']}',
                    Icons.backup,
                    AppColors.primaryLight,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Total Size',
                    statistics['totalSizeFormatted'],
                    Icons.storage,
                    AppColors.feedbackInfo,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Encrypted',
                    '${statistics['encryptedBackups']}',
                    Icons.lock,
                    AppColors.feedbackSuccess,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Last Backup
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.feedbackWarning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Backup',
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        Text(
                          statistics['lastBackup'] != null 
                              ? _formatDate(DateTime.parse(statistics['lastBackup']))
                              : 'Never',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
