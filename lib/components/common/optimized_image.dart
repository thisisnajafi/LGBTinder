import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Optimized image widget with caching and compression
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCompression;
  final Duration fadeInDuration;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableCompression = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!enableCompression) {
      return _buildCachedImage();
    }
    
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: 800,
      maxHeightDiskCache: 600,
      fadeInDuration: fadeInDuration,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder,
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget,
    );
  }

  Widget _buildCachedImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder,
      errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget,
    );
  }

  Widget get _defaultPlaceholder => Container(
    width: width,
    height: height,
    color: Colors.grey[200],
    child: const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    ),
  );

  Widget get _defaultErrorWidget => Container(
    width: width,
    height: height,
    color: Colors.grey[300],
    child: const Icon(
      Icons.error_outline,
      color: Colors.grey,
    ),
  );
}

/// Optimized profile image widget with special optimizations
class OptimizedProfileImage extends OptimizedImage {
  const OptimizedProfileImage({
    Key? key,
    required String imageUrl,
    double size = 60,
  }) : super(
    key: key,
    imageUrl: imageUrl,
    width: size,
    height: size,
    fit: BoxFit.cover,
    enableCompression: true,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipOval(
        child: super.build(context),
      ),
    );
  }
}

/// Optimized photo gallery item
class OptimizedPhotoItem extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isPrimary;
  final Widget? overlayWidget;

  const OptimizedPhotoItem({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.onTap,
    this.isPrimary = false,
    this.overlayWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? const Color(0xFF6B46C1) : Colors.grey[300]!,
            width: isPrimary ? 3 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
              OptimizedImage(
                imageUrl: imageUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                enableCompression: true,
              ),
              if (overlayWidget != null) overlayWidget!,
            ],
          ),
        ),
      ),
    );
  }
}
