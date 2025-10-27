import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Media Compression Service
/// 
/// Handles compression of images and videos before upload
/// - Images: Max 1920px, Quality 80%
/// - Videos: Max 720p, Compressed
class MediaCompressionService {
  static final MediaCompressionService _instance = MediaCompressionService._internal();
  factory MediaCompressionService() => _instance;
  MediaCompressionService._internal();

  // Compression settings
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int imageQuality = 80;
  static const int maxVideoWidth = 1280; // 720p
  static const int maxVideoHeight = 720;

  /// Compress image file
  /// 
  /// [imageFile] - Original image file
  /// [quality] - Compression quality (0-100), default 80
  /// Returns compressed image file
  Future<File?> compressImage({
    required File imageFile,
    int? quality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      debugPrint('Starting image compression: ${imageFile.path}');
      
      final targetPath = await _getTargetFilePath(
        originalPath: imageFile.path,
        suffix: '_compressed',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality ?? imageQuality,
        minWidth: maxWidth ?? maxImageWidth,
        minHeight: maxHeight ?? maxImageHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        debugPrint('Image compression failed');
        return null;
      }

      final originalSize = await imageFile.length();
      final compressedSize = await result.length();
      final compressionRatio = ((1 - (compressedSize / originalSize)) * 100).toStringAsFixed(1);

      debugPrint('Image compressed successfully:');
      debugPrint('  Original: ${_formatBytes(originalSize)}');
      debugPrint('  Compressed: ${_formatBytes(compressedSize)}');
      debugPrint('  Saved: $compressionRatio%');

      return File(result.path);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Compress multiple images
  /// 
  /// [imageFiles] - List of original image files
  /// Returns list of compressed image files
  Future<List<File>> compressImages({
    required List<File> imageFiles,
    int? quality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final List<File> compressedFiles = [];

    for (final imageFile in imageFiles) {
      final compressed = await compressImage(
        imageFile: imageFile,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (compressed != null) {
        compressedFiles.add(compressed);
      } else {
        // If compression fails, use original
        compressedFiles.add(imageFile);
      }
    }

    return compressedFiles;
  }

  /// Compress video file
  /// 
  /// [videoFile] - Original video file
  /// Returns compressed video file and thumbnail
  Future<CompressedVideoResult?> compressVideo({
    required File videoFile,
  }) async {
    try {
      debugPrint('Starting video compression: ${videoFile.path}');

      // Show compression progress
      final subscription = VideoCompress.compressProgress$.subscribe((progress) {
        debugPrint('Video compression progress: ${progress.toStringAsFixed(1)}%');
      });

      final info = await VideoCompress.compressVideo(
        videoFile.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );

      subscription.unsubscribe();

      if (info == null) {
        debugPrint('Video compression failed');
        return null;
      }

      final originalSize = await videoFile.length();
      final compressedSize = info.filesize ?? 0;
      final compressionRatio = compressedSize > 0
          ? ((1 - (compressedSize / originalSize)) * 100).toStringAsFixed(1)
          : '0';

      debugPrint('Video compressed successfully:');
      debugPrint('  Original: ${_formatBytes(originalSize)}');
      debugPrint('  Compressed: ${_formatBytes(compressedSize)}');
      debugPrint('  Saved: $compressionRatio%');
      debugPrint('  Duration: ${info.duration}s');

      // Generate thumbnail
      final thumbnailFile = await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: 80,
      );

      return CompressedVideoResult(
        videoFile: File(info.path!),
        thumbnailFile: thumbnailFile,
        originalSize: originalSize,
        compressedSize: compressedSize,
        duration: info.duration,
      );
    } catch (e) {
      debugPrint('Error compressing video: $e');
      return null;
    }
  }

  /// Generate video thumbnail only
  /// 
  /// [videoFile] - Video file
  /// Returns thumbnail file
  Future<File?> generateVideoThumbnail({
    required File videoFile,
  }) async {
    try {
      final thumbnailFile = await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: 80,
      );
      
      return thumbnailFile;
    } catch (e) {
      debugPrint('Error generating video thumbnail: $e');
      return null;
    }
  }

  /// Get video info without compressing
  Future<MediaInfo?> getVideoInfo(File videoFile) async {
    try {
      final info = await VideoCompress.getMediaInfo(videoFile.path);
      
      return info;
    } catch (e) {
      debugPrint('Error getting video info: $e');
      return null;
    }
  }

  /// Cancel ongoing video compression
  Future<void> cancelVideoCompression() async {
    await VideoCompress.cancelCompression();
  }

  /// Delete all compressed files
  Future<void> deleteAllCompressedFiles() async {
    await VideoCompress.deleteAllCache();
  }

  /// Get target file path for compressed file
  Future<String> _getTargetFilePath({
    required String originalPath,
    required String suffix,
  }) async {
    final dir = await getTemporaryDirectory();
    final originalFileName = path.basenameWithoutExtension(originalPath);
    final extension = path.extension(originalPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    return path.join(
      dir.path,
      '$originalFileName$suffix\_$timestamp$extension',
    );
  }

  /// Format bytes to human-readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if file is an image
  bool isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'].contains(extension);
  }

  /// Check if file is a video
  bool isVideoFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.flv', '.m4v'].contains(extension);
  }

  /// Compress media based on file type
  Future<File?> compressMedia(File file) async {
    if (isImageFile(file.path)) {
      return await compressImage(imageFile: file);
    } else if (isVideoFile(file.path)) {
      final result = await compressVideo(videoFile: file);
      return result?.videoFile;
    }
    
    // Return original file if not image or video
    return file;
  }
}

/// Compressed video result
class CompressedVideoResult {
  final File videoFile;
  final File thumbnailFile;
  final int originalSize;
  final int compressedSize;
  final double? duration;

  CompressedVideoResult({
    required this.videoFile,
    required this.thumbnailFile,
    required this.originalSize,
    required this.compressedSize,
    this.duration,
  });

  double get compressionRatio {
    if (originalSize == 0) return 0;
    return (1 - (compressedSize / originalSize)) * 100;
  }

  String get compressionRatioString {
    return '${compressionRatio.toStringAsFixed(1)}%';
  }
}

