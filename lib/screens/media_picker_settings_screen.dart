import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/media_picker_service.dart';

class MediaPickerSettingsScreen extends StatefulWidget {
  const MediaPickerSettingsScreen({Key? key}) : super(key: key);

  @override
  State<MediaPickerSettingsScreen> createState() => _MediaPickerSettingsScreenState();
}

class _MediaPickerSettingsScreenState extends State<MediaPickerSettingsScreen> {
  late MediaPickerService _mediaPickerService;

  @override
  void initState() {
    super.initState();
    _mediaPickerService = MediaPickerService();
    _mediaPickerService.initialize();
  }

  @override
  void dispose() {
    _mediaPickerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Media Picker Settings'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMainToggle(),
            const SizedBox(height: 24),
            _buildFileSizeSettings(),
            const SizedBox(height: 24),
            _buildFormatSettings(),
            const SizedBox(height: 24),
            _buildCompressionSettings(),
            const SizedBox(height: 24),
            _buildAdvancedSettings(),
            const SizedBox(height: 24),
            _buildPreviewSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_photo_alternate,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Media Picker',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize media selection options for images, videos, and audio',
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Media Picker',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.add_photo_alternate,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Media Picker',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Allow users to select media files',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _mediaPickerService.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _mediaPickerService.setEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileSizeSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'File Size Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Maximum File Size: ${_mediaPickerService.maxFileSizeMB} MB',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _mediaPickerService.maxFileSizeMB.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _mediaPickerService.setMaxFileSizeMB(value.round());
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.checklist,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allow Multiple Selection',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Allow users to select multiple files at once',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _mediaPickerService.allowMultipleSelection,
                onChanged: (value) {
                  setState(() {
                    _mediaPickerService.setAllowMultipleSelection(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Format Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFormatSection(
            'Image Formats',
            _mediaPickerService.allowedImageFormats,
            ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff'],
            (formats) => _mediaPickerService.setAllowedImageFormats(formats),
          ),
          const SizedBox(height: 16),
          _buildFormatSection(
            'Video Formats',
            _mediaPickerService.allowedVideoFormats,
            ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv', 'wmv'],
            (formats) => _mediaPickerService.setAllowedVideoFormats(formats),
          ),
          const SizedBox(height: 16),
          _buildFormatSection(
            'Audio Formats',
            _mediaPickerService.allowedAudioFormats,
            ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac', 'wma'],
            (formats) => _mediaPickerService.setAllowedAudioFormats(formats),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection(
    String title,
    List<String> currentFormats,
    List<String> availableFormats,
    Function(List<String>) onFormatsChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.body1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableFormats.map((format) {
            final isSelected = currentFormats.contains(format);
            return FilterChip(
              label: Text(format.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                final newFormats = List<String>.from(currentFormats);
                if (selected) {
                  newFormats.add(format);
                } else {
                  newFormats.remove(format);
                }
                setState(() {
                  onFormatsChanged(newFormats);
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.3),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompressionSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compression Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.compress,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Compress Images',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Automatically compress images after selection',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _mediaPickerService.autoCompressImages,
                onChanged: (value) {
                  setState(() {
                    _mediaPickerService.setAutoCompressImages(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Image Quality: ${_mediaPickerService.imageQuality}%',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _mediaPickerService.imageQuality.toDouble(),
            min: 10,
            max: 100,
            divisions: 18,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _mediaPickerService.setImageCompressionSettings(quality: value.round());
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Max Image Width: ${_mediaPickerService.maxImageWidth}px',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _mediaPickerService.maxImageWidth.toDouble(),
            min: 300,
            max: 4000,
            divisions: 37,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _mediaPickerService.setImageCompressionSettings(maxWidth: value.round());
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Max Image Height: ${_mediaPickerService.maxImageHeight}px',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _mediaPickerService.maxImageHeight.toDouble(),
            min: 300,
            max: 4000,
            divisions: 37,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _mediaPickerService.setImageCompressionSettings(maxHeight: value.round());
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.vibration,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haptic Feedback',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Provide haptic feedback during media selection',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _mediaPickerService.hapticFeedbackEnabled,
                onChanged: (value) {
                  setState(() {
                    _mediaPickerService.setHapticFeedbackEnabled(value);
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Reset to Default',
            subtitle: 'Reset all media picker settings to default values',
            icon: Icons.restore,
            onTap: _resetToDefault,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Media Picker Help',
            subtitle: 'Learn more about media picker features',
            icon: Icons.help_outline,
            onTap: _showMediaPickerHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Test the media picker functionality',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _testImagePicker,
                  icon: const Icon(Icons.image),
                  label: const Text('Test Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _testVideoPicker,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Test Videos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testAudioPicker,
              icon: const Icon(Icons.audiotrack),
              label: const Text('Test Audio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.body2.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _testImagePicker() async {
    try {
      final files = await _mediaPickerService.pickImageFromGallery();
      if (files != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected ${files.length} image(s)'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _testVideoPicker() async {
    try {
      final files = await _mediaPickerService.pickVideoFromGallery();
      if (files != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected ${files.length} video(s)'),
            backgroundColor: AppColors.secondaryLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _testAudioPicker() async {
    try {
      final files = await _mediaPickerService.pickAudioFile();
      if (files != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected ${files.length} audio file(s)'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _resetToDefault() {
    setState(() {
      _mediaPickerService.setEnabled(true);
      _mediaPickerService.setHapticFeedbackEnabled(true);
      _mediaPickerService.setAutoCompressImages(true);
      _mediaPickerService.setAllowMultipleSelection(false);
      _mediaPickerService.setMaxFileSizeMB(50);
      _mediaPickerService.setAllowedImageFormats(['jpg', 'jpeg', 'png', 'gif', 'webp']);
      _mediaPickerService.setAllowedVideoFormats(['mp4', 'mov', 'avi', 'mkv', 'webm']);
      _mediaPickerService.setAllowedAudioFormats(['mp3', 'wav', 'aac', 'm4a', 'ogg']);
      _mediaPickerService.setImageCompressionSettings(
        quality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
    });
  }

  void _showMediaPickerHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Media Picker Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Media picker allows users to select various types of media:\n\n'
          '• Images: Photos from camera or gallery\n'
          '• Videos: Video recordings from camera or gallery\n'
          '• Audio: Audio files from device storage\n'
          '• Multiple Selection: Choose multiple files at once\n'
          '• File Size Limits: Control maximum file sizes\n'
          '• Format Support: Customize supported file formats\n'
          '• Auto Compression: Automatically compress images\n'
          '• Haptic Feedback: Provide tactile feedback\n\n'
          'This improves user experience for media sharing.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
