import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/image_compression_service.dart';

class ImageCompressionSettingsScreen extends StatefulWidget {
  const ImageCompressionSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ImageCompressionSettingsScreen> createState() => _ImageCompressionSettingsScreenState();
}

class _ImageCompressionSettingsScreenState extends State<ImageCompressionSettingsScreen> {
  late ImageCompressionService _compressionService;

  @override
  void initState() {
    super.initState();
    _compressionService = ImageCompressionService();
    _compressionService.initialize();
  }

  @override
  void dispose() {
    _compressionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Image Compression Settings'),
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
            _buildQualitySettings(),
            const SizedBox(height: 24),
            _buildDimensionSettings(),
            const SizedBox(height: 24),
            _buildFileSizeSettings(),
            const SizedBox(height: 24),
            _buildFormatSettings(),
            const SizedBox(height: 24),
            _buildAdvancedSettings(),
            const SizedBox(height: 24),
            _buildPreviewSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
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
            Icons.compress,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Image Compression',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optimize image uploads for faster performance and reduced data usage',
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
            'Image Compression',
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
                      'Enable Image Compression',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Automatically compress images before upload',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _compressionService.isEnabled,
                onChanged: (value) {
                  setState(() {
                    _compressionService.setEnabled(value);
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

  Widget _buildQualitySettings() {
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
            'Quality Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Compression Quality: ${_compressionService.quality}%',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _compressionService.quality.toDouble(),
            min: 10,
            max: 100,
            divisions: 18,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _compressionService.setQuality(value.round());
              });
            },
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
                      'Provide haptic feedback during compression',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _compressionService.hapticFeedbackEnabled,
                onChanged: (value) {
                  setState(() {
                    _compressionService.setHapticFeedbackEnabled(value);
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

  Widget _buildDimensionSettings() {
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
            'Dimension Settings',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Maximum Width: ${_compressionService.maxWidth}px',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _compressionService.maxWidth.toDouble(),
            min: 300,
            max: 4000,
            divisions: 37,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _compressionService.setMaxDimensions(
                  value.round(),
                  _compressionService.maxHeight,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Maximum Height: ${_compressionService.maxHeight}px',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _compressionService.maxHeight.toDouble(),
            min: 300,
            max: 4000,
            divisions: 37,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _compressionService.setMaxDimensions(
                  _compressionService.maxWidth,
                  value.round(),
                );
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Minimum Width: ${_compressionService.minWidth}px',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _compressionService.minWidth.toDouble(),
            min: 50,
            max: 1000,
            divisions: 19,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _compressionService.setMinDimensions(
                  value.round(),
                  _compressionService.minHeight,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Minimum Height: ${_compressionService.minHeight}px',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _compressionService.minHeight.toDouble(),
            min: 50,
            max: 1000,
            divisions: 19,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _compressionService.setMinDimensions(
                  _compressionService.minWidth,
                  value.round(),
                );
              });
            },
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
            'Maximum File Size: ${_compressionService.maxFileSizeKB} KB',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _compressionService.maxFileSizeKB.toDouble(),
            min: 100,
            max: 5000,
            divisions: 49,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
            onChanged: (value) {
              setState(() {
                _compressionService.setMaxFileSizeKB(value.round());
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Rotate',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Automatically rotate images based on EXIF data',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _compressionService.autoRotate,
                onChanged: (value) {
                  setState(() {
                    _compressionService.setAutoRotate(value);
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
          Text(
            'Output Format',
            style: AppTypography.body1.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              CompressFormat.jpeg,
              CompressFormat.png,
              CompressFormat.heic,
              CompressFormat.webp,
            ].map((format) => ElevatedButton(
              onPressed: () {
                setState(() {
                  _compressionService.setFormat(format);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _compressionService.format == format 
                    ? AppColors.primary 
                    : Colors.white24,
                foregroundColor: Colors.white,
              ),
              child: Text(format.toString().split('.').last.toUpperCase()),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preserve EXIF',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Keep EXIF metadata in compressed images',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _compressionService.preserveExif,
                onChanged: (value) {
                  setState(() {
                    _compressionService.setPreserveExif(value);
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
          _buildActionTile(
            title: 'Reset to Default',
            subtitle: 'Reset all compression settings to default values',
            icon: Icons.restore,
            onTap: _resetToDefault,
          ),
          const SizedBox(height: 12),
          _buildActionTile(
            title: 'Compression Help',
            subtitle: 'Learn more about image compression features',
            icon: Icons.help_outline,
            onTap: _showCompressionHelp,
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
            'Compression Presets',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPresetCard(
            title: 'Profile Picture',
            subtitle: '800x800px, 90% quality',
            icon: Icons.person,
            onTap: () => _applyPreset('profile'),
          ),
          const SizedBox(height: 12),
          _buildPresetCard(
            title: 'Chat Message',
            subtitle: '1200x1200px, 80% quality',
            icon: Icons.message,
            onTap: () => _applyPreset('chat'),
          ),
          const SizedBox(height: 12),
          _buildPresetCard(
            title: 'Story',
            subtitle: '1080x1920px, 85% quality',
            icon: Icons.story,
            onTap: () => _applyPreset('story'),
          ),
          const SizedBox(height: 12),
          _buildPresetCard(
            title: 'Gallery',
            subtitle: '1920x1080px, 85% quality',
            icon: Icons.photo_library,
            onTap: () => _applyPreset('gallery'),
          ),
          const SizedBox(height: 12),
          _buildPresetCard(
            title: 'Thumbnail',
            subtitle: '300x300px, 70% quality',
            icon: Icons.image,
            onTap: () => _applyPreset('thumbnail'),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _testCompression,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Test Compression'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _showCompressionStats,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('View Stats'),
          ),
        ),
      ],
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

  void _applyPreset(String preset) {
    setState(() {
      switch (preset) {
        case 'profile':
          _compressionService.setQuality(90);
          _compressionService.setMaxDimensions(800, 800);
          break;
        case 'chat':
          _compressionService.setQuality(80);
          _compressionService.setMaxDimensions(1200, 1200);
          break;
        case 'story':
          _compressionService.setQuality(85);
          _compressionService.setMaxDimensions(1080, 1920);
          break;
        case 'gallery':
          _compressionService.setQuality(85);
          _compressionService.setMaxDimensions(1920, 1080);
          break;
        case 'thumbnail':
          _compressionService.setQuality(70);
          _compressionService.setMaxDimensions(300, 300);
          break;
      }
    });
  }

  void _resetToDefault() {
    setState(() {
      _compressionService.setEnabled(true);
      _compressionService.setQuality(85);
      _compressionService.setMaxDimensions(1920, 1080);
      _compressionService.setMinDimensions(300, 300);
      _compressionService.setMaxFileSizeKB(1024);
      _compressionService.setFormat(CompressFormat.jpeg);
      _compressionService.setPreserveExif(false);
      _compressionService.setAutoRotate(true);
      _compressionService.setHapticFeedbackEnabled(true);
    });
  }

  void _testCompression() {
    // This would typically open an image picker and test compression
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compression test feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showCompressionStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Compression Statistics',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Compression statistics will be displayed here:\n\n'
          '• Total images compressed: 0\n'
          '• Total space saved: 0 MB\n'
          '• Average compression ratio: 0%\n'
          '• Fastest compression time: 0ms\n'
          '• Slowest compression time: 0ms\n\n'
          'Statistics are tracked automatically when compression is enabled.',
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

  void _showCompressionHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Image Compression Help',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Image compression optimizes your photos for faster uploads:\n\n'
          '• Quality: Higher values = better quality, larger files\n'
          '• Dimensions: Maximum size images will be resized to\n'
          '• File Size: Maximum file size before compression\n'
          '• Format: Output format for compressed images\n'
          '• Auto Rotate: Automatically fix image orientation\n'
          '• Preserve EXIF: Keep metadata like GPS, camera info\n\n'
          'Compression reduces data usage and improves app performance.',
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
