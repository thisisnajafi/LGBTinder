import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class MediaPicker extends StatefulWidget {
  final Function(List<File>) onMediaSelected;
  final Function(File)? onImageSelected;
  final Function(File)? onVideoSelected;
  final Function(File)? onDocumentSelected;
  final bool allowMultiple;
  final List<MediaType> allowedTypes;

  const MediaPicker({
    Key? key,
    required this.onMediaSelected,
    this.onImageSelected,
    this.onVideoSelected,
    this.onDocumentSelected,
    this.allowMultiple = true,
    this.allowedTypes = const [
      MediaType.image,
      MediaType.video,
      MediaType.document,
    ],
  }) : super(key: key);

  @override
  State<MediaPicker> createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Choose Media',
                  style: AppTypography.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_selectedFiles.isNotEmpty)
                  TextButton(
                    onPressed: _clearSelection,
                    child: Text(
                      'Clear',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Media type buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (widget.allowedTypes.contains(MediaType.image))
                    Expanded(
                      child: _buildMediaButton(
                        'Gallery',
                        Icons.photo_library,
                        () => _pickFromGallery(MediaType.image),
                      ),
                    ),
                  if (widget.allowedTypes.contains(MediaType.image)) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMediaButton(
                        'Camera',
                        Icons.camera_alt,
                        () => _captureFromCamera(MediaType.image),
                      ),
                    ),
                  ],
                  if (widget.allowedTypes.contains(MediaType.video)) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMediaButton(
                        'Video',
                        Icons.videocam,
                        () => _pickFromGallery(MediaType.video),
                      ),
                    ),
                  ],
                  if (widget.allowedTypes.contains(MediaType.document)) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMediaButton(
                        'Document',
                        Icons.insert_drive_file,
                        () => _pickDocument(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Selected files preview
          if (_selectedFiles.isNotEmpty) ...[
            const Divider(color: Colors.white24),
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  return _buildFilePreview(_selectedFiles[index], index);
                },
              ),
            ),
          ],
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedFiles.isEmpty ? null : _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Send ${_selectedFiles.length}',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(File file, int index) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _isImageFile(file.path)
                ? Image.file(
                    file,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.navbarBackground,
                    child: Icon(
                      _isVideoFile(file.path) ? Icons.videocam : Icons.insert_drive_file,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeFile(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery(MediaType type) async {
    try {
      final XFile? file = await _imagePicker.pickMedia(
        mediaType: type == MediaType.image ? MediaType.image : MediaType.video,
      );
      
      if (file != null) {
        final selectedFile = File(file.path);
        _addFile(selectedFile);
      }
    } catch (e) {
      _showError('Failed to pick media: $e');
    }
  }

  Future<void> _captureFromCamera(MediaType type) async {
    try {
      final XFile? file = await _imagePicker.pickMedia(
        mediaType: MediaType.image,
        source: ImageSource.camera,
      );
      
      if (file != null) {
        final selectedFile = File(file.path);
        _addFile(selectedFile);
      }
    } catch (e) {
      _showError('Failed to capture media: $e');
    }
  }

  Future<void> _pickDocument() async {
    // This would typically use file_picker package
    // For now, we'll show a placeholder
    _showError('Document picker not implemented yet');
  }

  void _addFile(File file) {
    if (!widget.allowMultiple) {
      _selectedFiles.clear();
    }
    
    setState(() {
      _selectedFiles.add(file);
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  void _confirmSelection() {
    widget.onMediaSelected(_selectedFiles);
    
    // Call specific callbacks
    for (final file in _selectedFiles) {
      if (_isImageFile(file.path)) {
        widget.onImageSelected?.call(file);
      } else if (_isVideoFile(file.path)) {
        widget.onVideoSelected?.call(file);
      } else {
        widget.onDocumentSelected?.call(file);
      }
    }
    
    Navigator.pop(context);
  }

  bool _isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  bool _isVideoFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

enum MediaType {
  image,
  video,
  document,
}
