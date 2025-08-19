import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class PhotoGallery extends StatelessWidget {
  final List<String> photos;
  final bool isEditable;
  final Function(int) onPhotoTap;
  final VoidCallback onAddPhoto;
  final Function(int) onDeletePhoto;

  const PhotoGallery({
    Key? key,
    required this.photos,
    required this.onPhotoTap,
    required this.onAddPhoto,
    required this.onDeletePhoto,
    this.isEditable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Photos',
                style: AppTypography.titleMediumStyle,
              ),
              if (isEditable)
                TextButton.icon(
                  onPressed: onAddPhoto,
                  icon: Icon(
                    Icons.add_photo_alternate,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                  label: Text(
                    'Add Photo',
                    style: AppTypography.bodyMediumStyle.copyWith(
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length + (isEditable ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == photos.length) {
                return _AddPhotoButton(onTap: onAddPhoto);
              }
              return _PhotoItem(
                photoUrl: photos[index],
                onTap: () => onPhotoTap(index),
                onDelete: isEditable ? () => onDeletePhoto(index) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoItem extends StatelessWidget {
  final String photoUrl;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _PhotoItem({
    required this.photoUrl,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.cardBackgroundLight,
                  child: Icon(
                    Icons.image,
                    color: AppColors.textSecondaryLight,
                  ),
                );
              },
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryLight.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: AppColors.primaryLight,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: AppTypography.bodySmallStyle.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 