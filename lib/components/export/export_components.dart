import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_export_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../buttons/animated_button.dart';

class ExportFormatCard extends StatelessWidget {
  final Map<String, dynamic> format;
  final bool isSelected;
  final VoidCallback? onTap;

  const ExportFormatCard({
    Key? key,
    required this.format,
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
              ? Color(format['color']).withOpacity(0.1)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Color(format['color'])
                : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(format['color']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getFormatIcon(format['icon']),
                color: Color(format['color']),
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
                        format['name'],
                        style: AppTypography.subtitle2.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: Color(format['color']),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format['description'],
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.feedbackInfo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '.${format['extension']}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.feedbackInfo,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
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

  IconData _getFormatIcon(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'table_chart':
        return Icons.table_chart;
      case 'picture_as_pdf':
        return Icons.picture_as_pdf;
      case 'language':
        return Icons.language;
      case 'text_fields':
        return Icons.text_fields;
      default:
        return Icons.file_download;
    }
  }
}

class ExportTypeCard extends StatelessWidget {
  final Map<String, dynamic> type;
  final bool isSelected;
  final VoidCallback? onTap;

  const ExportTypeCard({
    Key? key,
    required this.type,
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
              ? Color(type['color']).withOpacity(0.1)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Color(type['color'])
                : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(type['color']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTypeIcon(type['icon']),
                color: Color(type['color']),
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
                        type['name'],
                        style: AppTypography.subtitle2.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: Color(type['color']),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type['description'],
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (type['dataTypes'] as List).take(3).map((dataType) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.borderDefault,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          dataType,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondaryDark,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String iconName) {
    switch (iconName) {
      case 'download':
        return Icons.download;
      case 'person':
        return Icons.person;
      case 'photo_library':
        return Icons.photo_library;
      case 'message':
        return Icons.message;
      case 'analytics':
        return Icons.analytics;
      case 'settings':
        return Icons.settings;
      case 'tune':
        return Icons.tune;
      default:
        return Icons.file_download;
    }
  }
}

class ExportRequestCard extends StatelessWidget {
  final ExportRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  const ExportRequestCard({
    Key? key,
    required this.request,
    this.onTap,
    this.onDownload,
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
          color: _getStatusColor(request.status),
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
                  color: _getStatusColor(request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(request.status),
                  color: _getStatusColor(request.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.type.name.toUpperCase()} - ${request.format.name.toUpperCase()}',
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(request.requestedAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.name.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: _getStatusColor(request.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Data Types
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: request.dataTypes.take(5).map((dataType) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.feedbackInfo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dataType,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.feedbackInfo,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              );
            }).toList(),
          ),
          
          if (request.dataTypes.length > 5) ...[
            const SizedBox(height: 4),
            Text(
              '+${request.dataTypes.length - 5} more',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
                fontSize: 10,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // File Info
          if (request.status == ExportStatus.completed) ...[
            Row(
              children: [
                Icon(
                  Icons.file_download,
                  color: AppColors.feedbackSuccess,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.filePath?.split('/').last ?? 'Unknown file',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (request.fileSize != null)
                  Text(
                    _formatFileSize(request.fileSize!),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onDownload?.call();
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
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

  Color _getStatusColor(ExportStatus status) {
    switch (status) {
      case ExportStatus.idle:
        return AppColors.textSecondaryDark;
      case ExportStatus.preparing:
      case ExportStatus.processing:
        return AppColors.feedbackInfo;
      case ExportStatus.completed:
        return AppColors.feedbackSuccess;
      case ExportStatus.failed:
        return AppColors.feedbackError;
      case ExportStatus.cancelled:
        return AppColors.feedbackWarning;
    }
  }

  IconData _getStatusIcon(ExportStatus status) {
    switch (status) {
      case ExportStatus.idle:
        return Icons.schedule;
      case ExportStatus.preparing:
        return Icons.settings_backup_restore;
      case ExportStatus.processing:
        return Icons.sync;
      case ExportStatus.completed:
        return Icons.check_circle;
      case ExportStatus.failed:
        return Icons.error;
      case ExportStatus.cancelled:
        return Icons.cancel;
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

class ExportProgressCard extends StatelessWidget {
  final ExportProgress progress;
  final VoidCallback? onCancel;

  const ExportProgressCard({
    Key? key,
    required this.progress,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.feedbackInfo.withOpacity(0.1),
            AppColors.feedbackInfo.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.feedbackInfo.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sync,
                color: AppColors.feedbackInfo,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Export in Progress',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${progress.percentage.toStringAsFixed(1)}%',
                style: AppTypography.h3.copyWith(
                  color: AppColors.feedbackInfo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            progress.operation,
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: progress.percentage / 100,
            backgroundColor: AppColors.surfaceSecondary,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.feedbackInfo),
            minHeight: 6,
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.currentStep}/${progress.totalSteps}',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
              Text(
                '${progress.itemsProcessed}/${progress.totalItems}',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          
          if (progress.currentItem.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              progress.currentItem,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
          
          if (progress.estimatedCompletion != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.feedbackWarning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estimated completion: ${_formatTime(progress.estimatedCompletion!)}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.feedbackWarning,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedbackService.selection();
                    onCancel?.call();
                  },
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Cancel'),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);
    
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}

class ExportStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;
  final VoidCallback? onTap;

  const ExportStatisticsCard({
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
                  'Export Statistics',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${statistics['successRate'].toStringAsFixed(1)}%',
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
                    'Total',
                    '${statistics['totalExports']}',
                    Icons.download,
                    AppColors.primaryLight,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Success',
                    '${statistics['successfulExports']}',
                    Icons.check_circle,
                    AppColors.feedbackSuccess,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Failed',
                    '${statistics['failedExports']}',
                    Icons.error,
                    AppColors.feedbackError,
                  ),
                ),
              ],
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
}
