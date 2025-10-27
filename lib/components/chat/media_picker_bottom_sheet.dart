import 'package:flutter/material.dart';
import 'dart:io';
import 'media_picker.dart';

/// MediaPickerBottomSheet
/// 
/// A bottom sheet wrapper for the MediaPicker component
/// that can be shown from anywhere in the app for selecting
/// images, videos, and documents to send in chat.
/// 
/// Usage:
/// ```dart
/// final files = await MediaPickerBottomSheet.show(
///   context: context,
///   allowMultiple: true,
///   allowedTypes: [MediaType.image, MediaType.video],
/// );
/// if (files != null && files.isNotEmpty) {
///   // Handle selected files
/// }
/// ```
class MediaPickerBottomSheet {
  /// Show the media picker bottom sheet
  /// 
  /// Returns a Future that completes with the selected files,
  /// or null if the user cancels.
  static Future<List<File>?> show({
    required BuildContext context,
    Function(File)? onImageSelected,
    Function(File)? onVideoSelected,
    Function(File)? onDocumentSelected,
    bool allowMultiple = true,
    List<MediaType> allowedTypes = const [
      MediaType.image,
      MediaType.video,
      MediaType.document,
    ],
  }) async {
    List<File>? selectedFiles;

    final result = await showModalBottomSheet<List<File>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => MediaPicker(
          onMediaSelected: (files) {
            selectedFiles = files;
          },
          onImageSelected: onImageSelected,
          onVideoSelected: onVideoSelected,
          onDocumentSelected: onDocumentSelected,
          allowMultiple: allowMultiple,
          allowedTypes: allowedTypes,
        ),
      ),
    );

    return result ?? selectedFiles;
  }

  /// Show image picker only
  static Future<List<File>?> showImagePicker({
    required BuildContext context,
    bool allowMultiple = true,
  }) {
    return show(
      context: context,
      allowMultiple: allowMultiple,
      allowedTypes: [MediaType.image],
    );
  }

  /// Show video picker only
  static Future<List<File>?> showVideoPicker({
    required BuildContext context,
    bool allowMultiple = false,
  }) {
    return show(
      context: context,
      allowMultiple: allowMultiple,
      allowedTypes: [MediaType.video],
    );
  }

  /// Show document picker only
  static Future<List<File>?> showDocumentPicker({
    required BuildContext context,
    bool allowMultiple = true,
  }) {
    return show(
      context: context,
      allowMultiple: allowMultiple,
      allowedTypes: [MediaType.document],
    );
  }

  /// Show image and video picker
  static Future<List<File>?> showImageAndVideoPicker({
    required BuildContext context,
    bool allowMultiple = true,
  }) {
    return show(
      context: context,
      allowMultiple: allowMultiple,
      allowedTypes: [MediaType.image, MediaType.video],
    );
  }

  /// Quick helper to show media picker and get a single file
  static Future<File?> showSingleMediaPicker({
    required BuildContext context,
    List<MediaType> allowedTypes = const [
      MediaType.image,
      MediaType.video,
      MediaType.document,
    ],
  }) async {
    final files = await show(
      context: context,
      allowMultiple: false,
      allowedTypes: allowedTypes,
    );
    
    return (files != null && files.isNotEmpty) ? files.first : null;
  }

  /// Quick helper to show image picker and get a single image
  static Future<File?> showSingleImagePicker({
    required BuildContext context,
  }) async {
    final files = await showImagePicker(
      context: context,
      allowMultiple: false,
    );
    
    return (files != null && files.isNotEmpty) ? files.first : null;
  }

  /// Quick helper to show video picker and get a single video
  static Future<File?> showSingleVideoPicker({
    required BuildContext context,
  }) async {
    final files = await showVideoPicker(
      context: context,
      allowMultiple: false,
    );
    
    return (files != null && files.isNotEmpty) ? files.first : null;
  }
}

/// Helper extension for easy access from BuildContext
extension MediaPickerBottomSheetExtension on BuildContext {
  /// Show media picker bottom sheet
  Future<List<File>?> showMediaPicker({
    Function(File)? onImageSelected,
    Function(File)? onVideoSelected,
    Function(File)? onDocumentSelected,
    bool allowMultiple = true,
    List<MediaType> allowedTypes = const [
      MediaType.image,
      MediaType.video,
      MediaType.document,
    ],
  }) {
    return MediaPickerBottomSheet.show(
      context: this,
      onImageSelected: onImageSelected,
      onVideoSelected: onVideoSelected,
      onDocumentSelected: onDocumentSelected,
      allowMultiple: allowMultiple,
      allowedTypes: allowedTypes,
    );
  }

  /// Show image picker
  Future<List<File>?> showImagePicker({bool allowMultiple = true}) {
    return MediaPickerBottomSheet.showImagePicker(
      context: this,
      allowMultiple: allowMultiple,
    );
  }

  /// Show video picker
  Future<List<File>?> showVideoPicker({bool allowMultiple = false}) {
    return MediaPickerBottomSheet.showVideoPicker(
      context: this,
      allowMultiple: allowMultiple,
    );
  }

  /// Show single image picker
  Future<File?> showSingleImagePicker() {
    return MediaPickerBottomSheet.showSingleImagePicker(context: this);
  }

  /// Show single video picker
  Future<File?> showSingleVideoPicker() {
    return MediaPickerBottomSheet.showSingleVideoPicker(context: this);
  }
}

