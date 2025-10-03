import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../theme/colors.dart';
import '../services/haptic_feedback_service.dart';

class ProfileImageEditor extends StatefulWidget {
  final String? currentImageUrl;
  final Function(String? imagePath)? onImageChanged;
  final double size;
  final bool enableCrop;
  final bool enableFilters;
  final List<ImageFilter> availableFilters;

  const ProfileImageEditor({
    Key? key,
    this.currentImageUrl,
    this.onImageChanged,
    this.size = 120.0,
    this.enableCrop = true,
    this.enableFilters = true,
    this.availableFilters = const [
      ImageFilter.none,
      ImageFilter.brightness,
      ImageFilter.contrast,
      ImageFilter.saturation,
    ],
  }) : super(key: key);

  @override
  State<ProfileImageEditor> createState() => _ProfileImageEditorState();
}

class _ProfileImageEditorState extends State<ProfileImageEditor>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  ImageFilter _currentFilter = ImageFilter.none;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImagePreview(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                if (widget.enableFilters && _selectedImage != null)
                  _buildFilterOptions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _showImageOptions,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryLight,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval(
          child: _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: widget.size,
                  height: widget.size,
                )
              : widget.currentImageUrl != null
                  ? Image.network(
                      widget.currentImageUrl!,
                      fit: BoxFit.cover,
                      width: widget.size,
                      height: widget.size,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: AppColors.textSecondaryDark,
        size: widget.size * 0.6,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.camera_alt,
          label: 'Camera',
          onTap: _pickImageFromCamera,
        ),
        _buildActionButton(
          icon: Icons.photo_library,
          label: 'Gallery',
          onTap: _pickImageFromGallery,
        ),
        if (_selectedImage != null)
          _buildActionButton(
            icon: Icons.crop,
            label: 'Crop',
            onTap: _cropImage,
          ),
        if (_selectedImage != null)
          _buildActionButton(
            icon: Icons.delete,
            label: 'Remove',
            onTap: _removeImage,
            isDestructive: true,
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDestructive ? AppColors.feedbackError : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isDestructive ? AppColors.feedbackError : AppColors.primaryLight).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.availableFilters.length,
              itemBuilder: (context, index) {
                final filter = widget.availableFilters[index];
                final isSelected = filter == _currentFilter;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentFilter = filter;
                    });
                    HapticFeedbackService.selection();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryLight : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getFilterName(filter),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterName(ImageFilter filter) {
    switch (filter) {
      case ImageFilter.none:
        return 'None';
      case ImageFilter.brightness:
        return 'Bright';
      case ImageFilter.contrast:
        return 'Contrast';
      case ImageFilter.saturation:
        return 'Saturated';
      case ImageFilter.blur:
        return 'Blur';
      case ImageFilter.sepia:
        return 'Sepia';
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModalButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                _buildModalButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primaryLight,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        widget.onImageChanged?.call(image.path);
        HapticFeedbackService.success();
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image from camera: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        widget.onImageChanged?.call(image.path);
        HapticFeedbackService.success();
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image from gallery: $e');
    }
  }

  Future<void> _cropImage() async {
    if (_selectedImage == null) return;

    try {
      final croppedFile = await ImageCropper.cropImage(
        sourcePath: _selectedImage!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primaryLight,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
        widget.onImageChanged?.call(croppedFile.path);
        HapticFeedbackService.success();
      }
    } catch (e) {
      _showErrorDialog('Failed to crop image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    widget.onImageChanged?.call(null);
    HapticFeedbackService.selection();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Error',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

enum ImageFilter {
  none,
  brightness,
  contrast,
  saturation,
  blur,
  sepia,
}

class ImageFilterPreview extends StatelessWidget {
  final File imageFile;
  final ImageFilter filter;
  final double size;

  const ImageFilterPreview({
    Key? key,
    required this.imageFile,
    required this.filter,
    this.size = 80.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
          color: _getFilterColor(),
          colorBlendMode: _getBlendMode(),
        ),
      ),
    );
  }

  Color? _getFilterColor() {
    switch (filter) {
      case ImageFilter.none:
        return null;
      case ImageFilter.brightness:
        return Colors.white.withOpacity(0.3);
      case ImageFilter.contrast:
        return Colors.black.withOpacity(0.2);
      case ImageFilter.saturation:
        return Colors.orange.withOpacity(0.2);
      case ImageFilter.blur:
        return null; // Would need custom implementation
      case ImageFilter.sepia:
        return const Color(0xFF8B4513).withOpacity(0.3);
    }
  }

  BlendMode? _getBlendMode() {
    switch (filter) {
      case ImageFilter.none:
        return null;
      case ImageFilter.brightness:
        return BlendMode.lighten;
      case ImageFilter.contrast:
        return BlendMode.multiply;
      case ImageFilter.saturation:
        return BlendMode.overlay;
      case ImageFilter.blur:
        return null; // Would need custom implementation
      case ImageFilter.sepia:
        return BlendMode.overlay;
    }
  }
}
