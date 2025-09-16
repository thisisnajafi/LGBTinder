import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/media_picker_service.dart';
import '../../services/haptic_feedback_service.dart';

class MediaPickerComponent extends StatefulWidget {
  final Function(List<File>) onMediaSelected;
  final Function(String)? onError;
  final bool allowImages;
  final bool allowVideos;
  final bool allowAudio;
  final bool allowCamera;
  final bool allowGallery;
  final bool allowMultiple;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool showPreview;
  final int maxPreviewItems;
  final bool enableHapticFeedback;

  const MediaPickerComponent({
    Key? key,
    required this.onMediaSelected,
    this.onError,
    this.allowImages = true,
    this.allowVideos = true,
    this.allowAudio = true,
    this.allowCamera = true,
    this.allowGallery = true,
    this.allowMultiple = false,
    this.title,
    this.subtitle,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.showPreview = true,
    this.maxPreviewItems = 3,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<MediaPickerComponent> createState() => _MediaPickerComponentState();
}

class _MediaPickerComponentState extends State<MediaPickerComponent> {
  final MediaPickerService _mediaPickerService = MediaPickerService();
  List<File> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _mediaPickerService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media picker button
        _buildMediaPickerButton(),
        
        // Preview section
        if (widget.showPreview && _selectedFiles.isNotEmpty)
          _buildPreviewSection(),
      ],
    );
  }

  Widget _buildMediaPickerButton() {
    return InkWell(
      onTap: _showMediaPicker,
      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      child: Container(
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.primary,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          border: Border.all(
            color: (widget.backgroundColor ?? AppColors.primary).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon ?? Icons.add_photo_alternate,
              color: widget.foregroundColor ?? Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title ?? 'Select Media',
                    style: AppTypography.body1.copyWith(
                      color: widget.foregroundColor ?? Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: AppTypography.body2.copyWith(
                        color: (widget.foregroundColor ?? Colors.white).withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: (widget.foregroundColor ?? Colors.white).withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Media (${_selectedFiles.length})',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return _buildPreviewItem(file, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(File file, int index) {
    final extension = file.path.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
    final isVideo = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
    final isAudio = ['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(extension);

    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          // Preview content
          Center(
            child: _buildPreviewContent(file, isImage, isVideo, isAudio),
          ),
          
          // Remove button
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

  Widget _buildPreviewContent(File file, bool isImage, bool isVideo, bool isAudio) {
    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon(Icons.image, 'Image');
          },
        ),
      );
    } else if (isVideo) {
      return _buildFallbackIcon(Icons.videocam, 'Video');
    } else if (isAudio) {
      return _buildFallbackIcon(Icons.audiotrack, 'Audio');
    } else {
      return _buildFallbackIcon(Icons.insert_drive_file, 'File');
    }
  }

  Widget _buildFallbackIcon(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _showMediaPicker() async {
    try {
      // Trigger haptic feedback
      if (widget.enableHapticFeedback) {
        await HapticFeedbackService().file();
      }

      final files = await _mediaPickerService.showMediaPickerDialog(
        context,
        allowImages: widget.allowImages,
        allowVideos: widget.allowVideos,
        allowAudio: widget.allowAudio,
        allowCamera: widget.allowCamera,
        allowGallery: widget.allowGallery,
        allowMultiple: widget.allowMultiple,
      );

      if (files != null && files.isNotEmpty) {
        setState(() {
          if (widget.allowMultiple) {
            _selectedFiles.addAll(files);
          } else {
            _selectedFiles = files;
          }
        });
        
        widget.onMediaSelected(_selectedFiles);
      }
    } catch (e) {
      debugPrint('Media picker error: $e');
      widget.onError?.call('Failed to select media: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    
    widget.onMediaSelected(_selectedFiles);
  }
}

class MediaPickerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool enableHapticFeedback;

  const MediaPickerButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (enableHapticFeedback) {
          await HapticFeedbackService().file();
        }
        onPressed();
      },
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class MediaPickerFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool enableHapticFeedback;

  const MediaPickerFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (enableHapticFeedback) {
          await HapticFeedbackService().file();
        }
        onPressed();
      },
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      child: Icon(icon),
    );
  }
}

class MediaPickerIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final double? iconSize;
  final bool enableHapticFeedback;

  const MediaPickerIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.iconSize,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        if (enableHapticFeedback) {
          await HapticFeedbackService().file();
        }
        onPressed();
      },
      icon: Icon(icon),
      tooltip: tooltip,
      color: color,
      iconSize: iconSize,
    );
  }
}

class MediaPickerCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool enableHapticFeedback;

  const MediaPickerCard({
    Key? key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? AppColors.navbarBackground,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          if (enableHapticFeedback) {
            await HapticFeedbackService().file();
          }
          onTap();
        },
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: foregroundColor ?? AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body1.copyWith(
                        color: foregroundColor ?? Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.body2.copyWith(
                        color: (foregroundColor ?? Colors.white).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: (foregroundColor ?? Colors.white).withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
