import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

class PhotoManagement extends StatefulWidget {
  final List<UserImage> images;
  final int maxImages;
  final ValueChanged<List<UserImage>>? onImagesChanged;
  final VoidCallback? onAddPhoto;

  const PhotoManagement({
    Key? key,
    required this.images,
    this.maxImages = 6,
    this.onImagesChanged,
    this.onAddPhoto,
  }) : super(key: key);

  @override
  State<PhotoManagement> createState() => _PhotoManagementState();
}

class _PhotoManagementState extends State<PhotoManagement> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos',
              style: AppTypography.h6.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${widget.images.length}/${widget.maxImages}',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Photo grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: widget.images.length + (widget.images.length < widget.maxImages ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == widget.images.length) {
              // Add photo button
              return _buildAddPhotoButton();
            } else {
              // Photo item
              return _buildPhotoItem(widget.images[index], index);
            }
          },
        ),
        
        const SizedBox(height: 16),
        
        // Photo tips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.greyLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Photo Tips',
                    style: AppTypography.subtitle2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Add at least 3 photos for better matches\n'
                '• Use clear, well-lit photos\n'
                '• Show your face clearly in the first photo\n'
                '• Include photos that show your interests',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return InkWell(
      onTap: widget.onAddPhoto,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.greyMedium,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(UserImage image, int index) {
    return Stack(
      children: [
        // Photo
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
            ),
            child: image.url != null
                ? Image.network(
                    image.url!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
        ),
        
        // Primary photo indicator
        if (index == 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Primary',
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        // Action buttons
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reorder button (only for non-primary photos)
              if (index > 0)
                GestureDetector(
                  onTap: () => _showReorderOptions(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.drag_handle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              
              const SizedBox(width: 4),
              
              // Delete button
              GestureDetector(
                onTap: () => _showDeleteConfirmation(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Tap to edit overlay
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPhotoOptions(index),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.greyLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            color: AppColors.textSecondary,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Photo'),
              onTap: () {
                Navigator.pop(context);
                _editPhoto(index);
              },
            ),
            if (index > 0)
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Make Primary'),
                onTap: () {
                  Navigator.pop(context);
                  _makePrimary(index);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(
                'Delete Photo',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReorderOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.keyboard_arrow_up),
              title: const Text('Move Up'),
              onTap: () {
                Navigator.pop(context);
                _movePhoto(index, index - 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.keyboard_arrow_down),
              title: const Text('Move Down'),
              onTap: () {
                Navigator.pop(context);
                _movePhoto(index, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto(index);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editPhoto(int index) {
    // TODO: Implement photo editing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo editing feature coming soon!'),
      ),
    );
  }

  void _makePrimary(int index) {
    final newImages = List<UserImage>.from(widget.images);
    final photoToMove = newImages.removeAt(index);
    newImages.insert(0, photoToMove);
    widget.onImagesChanged?.call(newImages);
  }

  void _movePhoto(int fromIndex, int toIndex) {
    if (toIndex < 0 || toIndex >= widget.images.length) return;
    
    final newImages = List<UserImage>.from(widget.images);
    final photoToMove = newImages.removeAt(fromIndex);
    newImages.insert(toIndex, photoToMove);
    widget.onImagesChanged?.call(newImages);
  }

  void _deletePhoto(int index) {
    final newImages = List<UserImage>.from(widget.images);
    newImages.removeAt(index);
    widget.onImagesChanged?.call(newImages);
  }
}
