import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Upload Progress Indicator
/// 
/// Shows upload progress for media files with cancel option
class UploadProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? fileName;
  final String? fileSize;
  final VoidCallback? onCancel;
  final bool isUploading;
  final String? errorMessage;

  const UploadProgressIndicator({
    Key? key,
    required this.progress,
    this.fileName,
    this.fileSize,
    this.onCancel,
    this.isUploading = true,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // File icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUploading ? Icons.cloud_upload : Icons.check_circle,
                  color: isUploading ? AppColors.primary : AppColors.success,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? 'Uploading...',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (fileSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        fileSize!,
                        style: AppTypography.body2.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Cancel button
              if (onCancel != null && isUploading)
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress bar
          if (isUploading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Progress percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% complete',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white70,
                  ),
                ),
                if (progress < 1.0)
                  Text(
                    'Uploading...',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ],
          
          // Error message
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.error,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          // Success message
          if (!isUploading && errorMessage == null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Upload complete',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Multiple Upload Progress Indicator
/// 
/// Shows progress for multiple file uploads
class MultipleUploadProgressIndicator extends StatelessWidget {
  final List<UploadItem> items;
  final VoidCallback? onCancel;

  const MultipleUploadProgressIndicator({
    Key? key,
    required this.items,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalProgress = items.isEmpty 
        ? 0.0 
        : items.map((item) => item.progress).reduce((a, b) => a + b) / items.length;
    
    final uploadingCount = items.where((item) => item.isUploading).length;
    final completedCount = items.where((item) => !item.isUploading && item.errorMessage == null).length;
    final failedCount = items.where((item) => item.errorMessage != null).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  uploadingCount > 0 ? Icons.cloud_upload : Icons.check_circle,
                  color: uploadingCount > 0 ? AppColors.primary : AppColors.success,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploading ${items.length} ${items.length == 1 ? 'file' : 'files'}',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount completed, $failedCount failed',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Cancel button
              if (onCancel != null && uploadingCount > 0)
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white70,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Overall progress bar
          if (uploadingCount > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalProgress,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '${(totalProgress * 100).toStringAsFixed(0)}% complete',
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
          
          // Individual file progress
          const SizedBox(height: 12),
          
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                // File type icon
                Icon(
                  _getFileIcon(item.fileName),
                  color: Colors.white70,
                  size: 20,
                ),
                
                const SizedBox(width: 8),
                
                // File name
                Expanded(
                  child: Text(
                    item.fileName,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Status icon
                if (item.isUploading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: item.progress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  )
                else if (item.errorMessage != null)
                  Icon(
                    Icons.error,
                    color: AppColors.error,
                    size: 16,
                  )
                else
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      return Icons.image;
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      return Icons.videocam;
    } else if (['mp3', 'm4a', 'wav', 'aac'].contains(extension)) {
      return Icons.audiotrack;
    } else if (['pdf'].contains(extension)) {
      return Icons.picture_as_pdf;
    } else {
      return Icons.insert_drive_file;
    }
  }
}

/// Upload Item Model
class UploadItem {
  final String fileName;
  final double progress;
  final bool isUploading;
  final String? errorMessage;

  UploadItem({
    required this.fileName,
    required this.progress,
    this.isUploading = true,
    this.errorMessage,
  });
}

