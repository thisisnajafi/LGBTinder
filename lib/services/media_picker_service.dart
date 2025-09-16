import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/haptic_feedback_service.dart';
import '../services/image_compression_service.dart';

class MediaPickerService {
  static final MediaPickerService _instance = MediaPickerService._internal();
  factory MediaPickerService() => _instance;
  MediaPickerService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  // Media picker settings
  bool _isEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _autoCompressImages = true;
  bool _allowMultipleSelection = false;
  int _maxFileSizeMB = 50;
  List<String> _allowedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  List<String> _allowedVideoFormats = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
  List<String> _allowedAudioFormats = ['mp3', 'wav', 'aac', 'm4a', 'ogg'];
  int _imageQuality = 85;
  int _maxImageWidth = 1920;
  int _maxImageHeight = 1080;

  // Getters
  bool get isEnabled => _isEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get autoCompressImages => _autoCompressImages;
  bool get allowMultipleSelection => _allowMultipleSelection;
  int get maxFileSizeMB => _maxFileSizeMB;
  List<String> get allowedImageFormats => _allowedImageFormats;
  List<String> get allowedVideoFormats => _allowedVideoFormats;
  List<String> get allowedAudioFormats => _allowedAudioFormats;
  int get imageQuality => _imageQuality;
  int get maxImageWidth => _maxImageWidth;
  int get maxImageHeight => _maxImageHeight;

  /// Initialize media picker service
  void initialize() {
    debugPrint('Media Picker Service initialized');
  }

  /// Enable/disable media picker
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Enable/disable haptic feedback
  void setHapticFeedbackEnabled(bool enabled) {
    _hapticFeedbackEnabled = enabled;
  }

  /// Enable/disable auto compression
  void setAutoCompressImages(bool enabled) {
    _autoCompressImages = enabled;
  }

  /// Enable/disable multiple selection
  void setAllowMultipleSelection(bool enabled) {
    _allowMultipleSelection = enabled;
  }

  /// Set maximum file size in MB
  void setMaxFileSizeMB(int sizeMB) {
    _maxFileSizeMB = sizeMB.clamp(1, 500);
  }

  /// Set allowed image formats
  void setAllowedImageFormats(List<String> formats) {
    _allowedImageFormats = formats;
  }

  /// Set allowed video formats
  void setAllowedVideoFormats(List<String> formats) {
    _allowedVideoFormats = formats;
  }

  /// Set allowed audio formats
  void setAllowedAudioFormats(List<String> formats) {
    _allowedAudioFormats = formats;
  }

  /// Set image compression settings
  void setImageCompressionSettings({
    int? quality,
    int? maxWidth,
    int? maxHeight,
  }) {
    if (quality != null) _imageQuality = quality.clamp(1, 100);
    if (maxWidth != null) _maxImageWidth = maxWidth.clamp(100, 4000);
    if (maxHeight != null) _maxImageHeight = maxHeight.clamp(100, 4000);
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Camera permission error: $e');
      return false;
    }
  }

  /// Request photo library permission
  Future<bool> requestPhotoLibraryPermission() async {
    try {
      final status = await Permission.photos.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Photo library permission error: $e');
      return false;
    }
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Microphone permission error: $e');
      return false;
    }
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Storage permission error: $e');
      return false;
    }
  }

  /// Pick image from camera
  Future<List<File>?> pickImageFromCamera({
    ImageQuality? quality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    if (!_isEnabled) return null;

    try {
      // Request camera permission
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        throw PermissionException('Camera permission denied');
      }

      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().camera();
      }

      // Pick image from camera
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: quality?.value ?? _imageQuality,
        maxWidth: maxWidth?.toDouble() ?? _maxImageWidth.toDouble(),
        maxHeight: maxHeight?.toDouble() ?? _maxImageHeight.toDouble(),
      );

      if (image == null) return null;

      final file = File(image.path);
      
      // Auto compress if enabled
      if (_autoCompressImages) {
        final compressedFile = await ImageCompressionService().compressImageFile(
          imageFile: file,
          quality: _imageQuality,
          maxWidth: _maxImageWidth,
          maxHeight: _maxImageHeight,
        );
        return compressedFile != null ? [compressedFile] : [file];
      }

      return [file];
    } catch (e) {
      debugPrint('Camera pick error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return null;
    }
  }

  /// Pick image from gallery
  Future<List<File>?> pickImageFromGallery({
    ImageQuality? quality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    if (!_isEnabled) return null;

    try {
      // Request photo library permission
      final hasPermission = await requestPhotoLibraryPermission();
      if (!hasPermission) {
        throw PermissionException('Photo library permission denied');
      }

      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().gallery();
      }

      // Pick image from gallery
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality?.value ?? _imageQuality,
        maxWidth: maxWidth?.toDouble() ?? _maxImageWidth.toDouble(),
        maxHeight: maxHeight?.toDouble() ?? _maxImageHeight.toDouble(),
      );

      if (image == null) return null;

      final file = File(image.path);
      
      // Auto compress if enabled
      if (_autoCompressImages) {
        final compressedFile = await ImageCompressionService().compressImageFile(
          imageFile: file,
          quality: _imageQuality,
          maxWidth: _maxImageWidth,
          maxHeight: _maxImageHeight,
        );
        return compressedFile != null ? [compressedFile] : [file];
      }

      return [file];
    } catch (e) {
      debugPrint('Gallery pick error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>?> pickMultipleImagesFromGallery({
    ImageQuality? quality,
    int? maxWidth,
    int? maxHeight,
    int? limit,
  }) async {
    if (!_isEnabled) return null;

    try {
      // Request photo library permission
      final hasPermission = await requestPhotoLibraryPermission();
      if (!hasPermission) {
        throw PermissionException('Photo library permission denied');
      }

      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().gallery();
      }

      // Pick multiple images from gallery
      final List<XFile> images = await _imagePicker.pickMultipleImages(
        imageQuality: quality?.value ?? _imageQuality,
        maxWidth: maxWidth?.toDouble() ?? _maxImageWidth.toDouble(),
        maxHeight: maxHeight?.toDouble() ?? _maxImageHeight.toDouble(),
        limit: limit ?? 10,
      );

      if (images.isEmpty) return null;

      final List<File> files = [];
      
      for (final image in images) {
        final file = File(image.path);
        
        // Auto compress if enabled
        if (_autoCompressImages) {
          final compressedFile = await ImageCompressionService().compressImageFile(
            imageFile: file,
            quality: _imageQuality,
            maxWidth: _maxImageWidth,
            maxHeight: _maxImageHeight,
          );
          files.add(compressedFile ?? file);
        } else {
          files.add(file);
        }
      }

      return files;
    } catch (e) {
      debugPrint('Multiple gallery pick error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return null;
    }
  }

  /// Pick video from camera
  Future<List<File>?> pickVideoFromCamera({
    Duration? maxDuration,
  }) async {
    if (!_isEnabled) return null;

    try {
      // Request camera permission
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        throw PermissionException('Camera permission denied');
      }

      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().camera();
      }

      // Pick video from camera
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration ?? const Duration(minutes: 5),
      );

      if (video == null) return null;

      final file = File(video.path);
      
      // Check file size
      if (await _isFileSizeValid(file)) {
        return [file];
      } else {
        throw FileSizeException('Video file too large');
      }
    } catch (e) {
      debugPrint('Camera video pick error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return null;
    }
  }

  /// Pick video from gallery
  Future<List<File>?> pickVideoFromGallery({
    Duration? maxDuration,
  }) async {
    if (!_isEnabled) return null;

    try {
      // Request photo library permission
      final hasPermission = await requestPhotoLibraryPermission();
      if (!hasPermission) {
        throw PermissionException('Photo library permission denied');
      }

      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().gallery();
      }

      // Pick video from gallery
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration ?? const Duration(minutes: 5),
      );

      if (video == null) return null;

      final file = File(video.path);
      
      // Check file size
      if (await _isFileSizeValid(file)) {
        return [file];
      } else {
        throw FileSizeException('Video file too large');
      }
    } catch (e) {
      debugPrint('Gallery video pick error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return null;
    }
  }

  /// Pick audio file
  Future<List<File>?> pickAudioFile() async {
    if (!_isEnabled) return null;

    try {
      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw PermissionException('Storage permission denied');
      }

      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().audio();
      }

      // Pick audio file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: _allowMultipleSelection,
      );

      if (result == null || result.files.isEmpty) return null;

      final List<File> files = [];
      
      for (final platformFile in result.files) {
        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          
          // Check file size and format
          if (await _isFileSizeValid(file) && _isAudioFormatValid(file.path)) {
            files.add(file);
          }
        }
      }

      return files.isNotEmpty ? files : null;
    } catch (e) {
      debugPrint('Audio pick error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return null;
    }
  }

  /// Pick any file
  Future<List<File>?> pickAnyFile({
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    if (!_isEnabled) return null;

    try {
      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw PermissionException('Storage permission denied');
      }

      // Trigger haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().file();
      }

      // Pick any file
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? [..._allowedImageFormats, ..._allowedVideoFormats, ..._allowedAudioFormats],
        allowMultiple: allowMultiple || _allowMultipleSelection,
      );

      if (result == null || result.files.isEmpty) return null;

      final List<File> files = [];
      
      for (final platformFile in result.files) {
        if (platformFile.path != null) {
          final file = File(platformFile.path!);
          
          // Check file size
          if (await _isFileSizeValid(file)) {
            files.add(file);
          }
        }
      }

      return files.isNotEmpty ? files : null;
    } catch (e) {
      debugPrint('File pick error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return null;
    }
  }

  /// Show media picker dialog
  Future<List<File>?> showMediaPickerDialog(BuildContext context, {
    bool allowImages = true,
    bool allowVideos = true,
    bool allowAudio = true,
    bool allowCamera = true,
    bool allowGallery = true,
    bool allowMultiple = false,
  }) async {
    if (!_isEnabled) return null;

    return showModalBottomSheet<List<File>?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MediaPickerDialog(
        allowImages: allowImages,
        allowVideos: allowVideos,
        allowAudio: allowAudio,
        allowCamera: allowCamera,
        allowGallery: allowGallery,
        allowMultiple: allowMultiple,
      ),
    );
  }

  /// Check if file size is valid
  Future<bool> _isFileSizeValid(File file) async {
    try {
      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);
      return fileSizeMB <= _maxFileSizeMB;
    } catch (e) {
      debugPrint('File size check error: $e');
      return false;
    }
  }

  /// Check if image format is valid
  bool _isImageFormatValid(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return _allowedImageFormats.contains(extension);
  }

  /// Check if video format is valid
  bool _isVideoFormatValid(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return _allowedVideoFormats.contains(extension);
  }

  /// Check if audio format is valid
  bool _isAudioFormatValid(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return _allowedAudioFormats.contains(extension);
  }

  /// Dispose service
  void dispose() {
    debugPrint('Media Picker Service disposed');
  }
}

class _MediaPickerDialog extends StatelessWidget {
  final bool allowImages;
  final bool allowVideos;
  final bool allowAudio;
  final bool allowCamera;
  final bool allowGallery;
  final bool allowMultiple;

  const _MediaPickerDialog({
    required this.allowImages,
    required this.allowVideos,
    required this.allowAudio,
    required this.allowCamera,
    required this.allowGallery,
    required this.allowMultiple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Select Media',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Options
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (allowImages && allowCamera)
                  _buildOption(
                    context,
                    icon: Icons.camera_alt,
                    title: 'Take Photo',
                    subtitle: 'Capture a new photo',
                    onTap: () => _pickFromCamera(context, isVideo: false),
                  ),
                
                if (allowImages && allowGallery)
                  _buildOption(
                    context,
                    icon: Icons.photo_library,
                    title: allowMultiple ? 'Select Photos' : 'Choose Photo',
                    subtitle: 'Select from gallery',
                    onTap: () => _pickFromGallery(context, isVideo: false, allowMultiple: allowMultiple),
                  ),
                
                if (allowVideos && allowCamera)
                  _buildOption(
                    context,
                    icon: Icons.videocam,
                    title: 'Record Video',
                    subtitle: 'Capture a new video',
                    onTap: () => _pickFromCamera(context, isVideo: true),
                  ),
                
                if (allowVideos && allowGallery)
                  _buildOption(
                    context,
                    icon: Icons.video_library,
                    title: 'Choose Video',
                    subtitle: 'Select from gallery',
                    onTap: () => _pickFromGallery(context, isVideo: true),
                  ),
                
                if (allowAudio)
                  _buildOption(
                    context,
                    icon: Icons.audiotrack,
                    title: 'Choose Audio',
                    subtitle: 'Select audio file',
                    onTap: () => _pickAudio(context),
                  ),
              ],
            ),
          ),
          
          // Cancel button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  void _pickFromCamera(BuildContext context, {required bool isVideo}) async {
    Navigator.pop(context);
    
    final service = MediaPickerService();
    final files = isVideo 
        ? await service.pickVideoFromCamera()
        : await service.pickImageFromCamera();
    
    if (files != null && context.mounted) {
      Navigator.pop(context, files);
    }
  }

  void _pickFromGallery(BuildContext context, {required bool isVideo, bool allowMultiple = false}) async {
    Navigator.pop(context);
    
    final service = MediaPickerService();
    final files = isVideo 
        ? await service.pickVideoFromGallery()
        : allowMultiple 
            ? await service.pickMultipleImagesFromGallery()
            : await service.pickImageFromGallery();
    
    if (files != null && context.mounted) {
      Navigator.pop(context, files);
    }
  }

  void _pickAudio(BuildContext context) async {
    Navigator.pop(context);
    
    final service = MediaPickerService();
    final files = await service.pickAudioFile();
    
    if (files != null && context.mounted) {
      Navigator.pop(context, files);
    }
  }
}

// Custom exceptions
class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class FileSizeException implements Exception {
  final String message;
  FileSizeException(this.message);
  
  @override
  String toString() => 'FileSizeException: $message';
}

// Image quality enum
enum ImageQuality {
  low(50),
  medium(75),
  high(85),
  max(100);

  const ImageQuality(this.value);
  final int value;
}
