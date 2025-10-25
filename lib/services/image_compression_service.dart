import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import '../services/haptic_feedback_service.dart';

class ImageCompressionService {
  static final ImageCompressionService _instance = ImageCompressionService._internal();
  factory ImageCompressionService() => _instance;
  ImageCompressionService._internal();

  // Compression settings
  bool _isEnabled = true;
  int _quality = 85;
  int _maxWidth = 1920;
  int _maxHeight = 1080;
  int _minWidth = 300;
  int _minHeight = 300;
  int _maxFileSizeKB = 1024; // 1MB
  bool _preserveExif = false;
  bool _autoRotate = true;
  bool _hapticFeedbackEnabled = true;
  CompressFormat _format = CompressFormat.jpeg;
  bool _keepMetadata = false;

  // Getters
  bool get isEnabled => _isEnabled;
  int get quality => _quality;
  int get maxWidth => _maxWidth;
  int get maxHeight => _maxHeight;
  int get minWidth => _minWidth;
  int get minHeight => _minHeight;
  int get maxFileSizeKB => _maxFileSizeKB;
  bool get preserveExif => _preserveExif;
  bool get autoRotate => _autoRotate;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  CompressFormat get format => _format;
  bool get keepMetadata => _keepMetadata;

  /// Initialize image compression service
  void initialize() {
    debugPrint('Image Compression Service initialized');
  }

  /// Enable/disable image compression
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Set compression quality (1-100)
  void setQuality(int quality) {
    _quality = quality.clamp(1, 100);
  }

  /// Set maximum dimensions
  void setMaxDimensions(int width, int height) {
    _maxWidth = width.clamp(100, 4000);
    _maxHeight = height.clamp(100, 4000);
  }

  /// Set minimum dimensions
  void setMinDimensions(int width, int height) {
    _minWidth = width.clamp(50, 2000);
    _minHeight = height.clamp(50, 2000);
  }

  /// Set maximum file size in KB
  void setMaxFileSizeKB(int sizeKB) {
    _maxFileSizeKB = sizeKB.clamp(50, 10000);
  }

  /// Set compression format
  void setFormat(CompressFormat format) {
    _format = format;
  }

  /// Set preserve EXIF data
  void setPreserveExif(bool preserve) {
    _preserveExif = preserve;
  }

  /// Set auto rotate
  void setAutoRotate(bool autoRotate) {
    _autoRotate = autoRotate;
  }

  /// Set haptic feedback
  void setHapticFeedbackEnabled(bool enabled) {
    _hapticFeedbackEnabled = enabled;
  }

  /// Set keep metadata
  void setKeepMetadata(bool keep) {
    _keepMetadata = keep;
  }

  /// Compress image file
  Future<File?> compressImageFile({
    required File imageFile,
    int? quality,
    int? maxWidth,
    int? maxHeight,
    CompressFormat? format,
    bool? preserveExif,
    bool? autoRotate,
  }) async {
    if (!_isEnabled) {
      return imageFile;
    }

    try {
      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        HapticFeedbackService.compress();
      }

      // Get file info
      final fileSizeKB = await imageFile.length() / 1024;
      debugPrint('Original file size: ${fileSizeKB.toStringAsFixed(2)} KB');

      // Check if compression is needed
      if (fileSizeKB <= _maxFileSizeKB && 
          await _isImageWithinDimensions(imageFile, maxWidth ?? _maxWidth, maxHeight ?? _maxHeight)) {
        debugPrint('Image already within limits, no compression needed');
        return imageFile;
      }

      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        '${imageFile.path}_compressed',
        quality: quality ?? _quality,
        minWidth: _minWidth,
        minHeight: _minHeight,
        format: format ?? _format,
        keepExif: preserveExif ?? _preserveExif,
        autoCorrectionAngle: autoRotate ?? _autoRotate,
      );

      if (compressedFile != null) {
        final compressedSizeKB = await compressedFile.length() / 1024;
        debugPrint('Compressed file size: ${compressedSizeKB.toStringAsFixed(2)} KB');
        debugPrint('Compression ratio: ${((fileSizeKB - compressedSizeKB) / fileSizeKB * 100).toStringAsFixed(1)}%');

        // Trigger success haptic feedback
        if (_hapticFeedbackEnabled) {
          HapticFeedbackService.success();
        }

        return File(compressedFile.path);
      }

      return imageFile;
    } catch (e) {
      debugPrint('Image compression error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        HapticFeedbackService.error();
      }
      
      return imageFile;
    }
  }

  /// Compress image bytes
  Future<Uint8List?> compressImageBytes({
    required Uint8List imageBytes,
    int? quality,
    int? maxWidth,
    int? maxHeight,
    CompressFormat? format,
    bool? preserveExif,
    bool? autoRotate,
  }) async {
    if (!_isEnabled) {
      return imageBytes;
    }

    try {
      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        HapticFeedbackService.compress();
      }

      // Get bytes info
      final originalSizeKB = imageBytes.length / 1024;
      debugPrint('Original bytes size: ${originalSizeKB.toStringAsFixed(2)} KB');

      // Compress image bytes
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality ?? _quality,
        minWidth: _minWidth,
        minHeight: _minHeight,
        format: format ?? _format,
        keepExif: preserveExif ?? _preserveExif,
        autoCorrectionAngle: autoRotate ?? _autoRotate,
      );

      if (compressedBytes.isNotEmpty) {
        final compressedSizeKB = compressedBytes.length / 1024;
        debugPrint('Compressed bytes size: ${compressedSizeKB.toStringAsFixed(2)} KB');
        debugPrint('Compression ratio: ${((originalSizeKB - compressedSizeKB) / originalSizeKB * 100).toStringAsFixed(1)}%');

        // Trigger success haptic feedback
        if (_hapticFeedbackEnabled) {
          HapticFeedbackService.success();
        }

        return compressedBytes;
      }

      return imageBytes;
    } catch (e) {
      debugPrint('Image compression error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        HapticFeedbackService.error();
      }
      
      return imageBytes;
    }
  }

  /// Compress image for profile picture
  Future<File?> compressProfilePicture(File imageFile) async {
    return compressImageFile(
      imageFile: imageFile,
      quality: 90,
      maxWidth: 800,
      maxHeight: 800,
      format: CompressFormat.jpeg,
    );
  }

  /// Compress image for chat message
  Future<File?> compressChatImage(File imageFile) async {
    return compressImageFile(
      imageFile: imageFile,
      quality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
      format: CompressFormat.jpeg,
    );
  }

  /// Compress image for story
  Future<File?> compressStoryImage(File imageFile) async {
    return compressImageFile(
      imageFile: imageFile,
      quality: 85,
      maxWidth: 1080,
      maxHeight: 1920,
      format: CompressFormat.jpeg,
    );
  }

  /// Compress image for gallery
  Future<File?> compressGalleryImage(File imageFile) async {
    return compressImageFile(
      imageFile: imageFile,
      quality: 85,
      maxWidth: 1920,
      maxHeight: 1080,
      format: CompressFormat.jpeg,
    );
  }

  /// Compress image for thumbnail
  Future<File?> compressThumbnail(File imageFile) async {
    return compressImageFile(
      imageFile: imageFile,
      quality: 70,
      maxWidth: 300,
      maxHeight: 300,
      format: CompressFormat.jpeg,
    );
  }

  /// Get image dimensions
  Future<ImageDimensions> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image != null) {
        return ImageDimensions(
          width: image.width,
          height: image.height,
        );
      }
      
      return ImageDimensions(width: 0, height: 0);
    } catch (e) {
      debugPrint('Error getting image dimensions: $e');
      return ImageDimensions(width: 0, height: 0);
    }
  }

  /// Get image file size in KB
  Future<double> getImageFileSizeKB(File imageFile) async {
    try {
      final bytes = await imageFile.length();
      return bytes / 1024;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  /// Check if image needs compression
  Future<bool> needsCompression(File imageFile) async {
    try {
      final fileSizeKB = await getImageFileSizeKB(imageFile);
      final dimensions = await getImageDimensions(imageFile);
      
      return fileSizeKB > _maxFileSizeKB ||
             dimensions.width > _maxWidth ||
             dimensions.height > _maxHeight;
    } catch (e) {
      debugPrint('Error checking compression need: $e');
      return false;
    }
  }

  /// Check if image is within dimensions
  Future<bool> _isImageWithinDimensions(File imageFile, int maxWidth, int maxHeight) async {
    try {
      final dimensions = await getImageDimensions(imageFile);
      return dimensions.width <= maxWidth && dimensions.height <= maxHeight;
    } catch (e) {
      debugPrint('Error checking dimensions: $e');
      return false;
    }
  }

  /// Get compression info
  Future<CompressionInfo> getCompressionInfo(File imageFile) async {
    try {
      final originalSizeKB = await getImageFileSizeKB(imageFile);
      final dimensions = await getImageDimensions(imageFile);
      final needsCompression = await this.needsCompression(imageFile);
      
      return CompressionInfo(
        originalSizeKB: originalSizeKB,
        dimensions: dimensions,
        needsCompression: needsCompression,
        estimatedCompressedSizeKB: needsCompression ? originalSizeKB * 0.3 : originalSizeKB,
      );
    } catch (e) {
      debugPrint('Error getting compression info: $e');
      return CompressionInfo(
        originalSizeKB: 0,
        dimensions: ImageDimensions(width: 0, height: 0),
        needsCompression: false,
        estimatedCompressedSizeKB: 0,
      );
    }
  }

  /// Batch compress images
  Future<List<File?>> batchCompressImages(List<File> imageFiles) async {
    final results = <File?>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      debugPrint('Compressing image ${i + 1}/${imageFiles.length}');
      
      final compressedFile = await compressImageFile(imageFile: file);
      results.add(compressedFile);
    }
    
    return results;
  }

  /// Create compressed image with watermark
  Future<File?> compressWithWatermark({
    required File imageFile,
    required String watermarkText,
    int? quality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // First compress the image
      final compressedFile = await compressImageFile(
        imageFile: imageFile,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (compressedFile == null) return imageFile;

      // Add watermark
      final bytes = await compressedFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return compressedFile;

      // Create watermark
      final watermark = img.Image(width: 200, height: 50);
      img.fill(watermark, color: img.ColorRgba8(255, 255, 255, 128));
      
      // Composite watermark onto image
      img.compositeImage(image, watermark, dstX: image.width - 220, dstY: image.height - 70);

      // Save watermarked image
      final watermarkedBytes = img.encodeJpg(image, quality: quality ?? _quality);
      final watermarkedFile = File('${compressedFile.path}_watermarked');
      await watermarkedFile.writeAsBytes(watermarkedBytes);

      return watermarkedFile;
    } catch (e) {
      debugPrint('Error adding watermark: $e');
      return imageFile;
    }
  }

  /// Dispose service
  void dispose() {
    debugPrint('Image Compression Service disposed');
  }
}

class ImageDimensions {
  final int width;
  final int height;

  ImageDimensions({required this.width, required this.height});

  @override
  String toString() => '${width}x$height';
}

class CompressionInfo {
  final double originalSizeKB;
  final ImageDimensions dimensions;
  final bool needsCompression;
  final double estimatedCompressedSizeKB;

  CompressionInfo({
    required this.originalSizeKB,
    required this.dimensions,
    required this.needsCompression,
    required this.estimatedCompressedSizeKB,
  });

  double get compressionRatio => 
      needsCompression ? (originalSizeKB - estimatedCompressedSizeKB) / originalSizeKB : 0;

  @override
  String toString() => 
      'Size: ${originalSizeKB.toStringAsFixed(2)}KB, '
      'Dimensions: ${dimensions.toString()}, '
      'Needs compression: $needsCompression, '
      'Estimated compressed: ${estimatedCompressedSizeKB.toStringAsFixed(2)}KB';
}
