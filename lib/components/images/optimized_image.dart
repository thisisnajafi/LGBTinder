import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../theme/colors.dart';

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final bool enableMemoryCache;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.enableMemoryCache = true,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: fadeInDuration,
        memCacheWidth: maxWidthDiskCache,
        memCacheHeight: maxHeightDiskCache,
        placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildDefaultError(),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark,
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.error_outline,
        color: AppColors.feedbackError,
        size: 32,
      ),
    );
  }
}

class LazyImageList extends StatefulWidget {
  final List<String> imageUrls;
  final double itemHeight;
  final double itemWidth;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final Axis scrollDirection;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LazyImageList({
    Key? key,
    required this.imageUrls,
    required this.itemHeight,
    required this.itemWidth,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.scrollDirection = Axis.horizontal,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<LazyImageList> createState() => _LazyImageListState();
}

class _LazyImageListState extends State<LazyImageList> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _loadedImages = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load images that are visible or about to be visible
    final viewport = _scrollController.position.viewportDimension;
    final offset = _scrollController.position.pixels;
    
    for (int i = 0; i < widget.imageUrls.length; i++) {
      final itemPosition = i * widget.itemWidth;
      final distanceFromViewport = (itemPosition - offset).abs();
      
      if (distanceFromViewport < viewport * 2 && !_loadedImages.contains(i)) {
        setState(() {
          _loadedImages.add(i);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      itemCount: widget.imageUrls.length,
      itemBuilder: (context, index) {
        final isLoaded = _loadedImages.contains(index);
        
        return Padding(
          padding: widget.padding,
          child: OptimizedImage(
            imageUrl: isLoaded ? widget.imageUrls[index] : '',
            width: widget.itemWidth,
            height: widget.itemHeight,
            fit: widget.fit,
            borderRadius: widget.borderRadius,
            placeholder: widget.placeholder,
            errorWidget: widget.errorWidget,
          ),
        );
      },
    );
  }
}

class ImageCacheManager {
  static const int maxCacheSize = 100; // Maximum number of images to cache
  static const Duration cacheExpiration = Duration(hours: 24);
  
  static Future<void> clearCache() async {
    await CachedNetworkImage.evictFromCache('');
  }
  
  static Future<void> preloadImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await CachedNetworkImage.evictFromCache(url);
        await precacheImage(
          CachedNetworkImageProvider(url),
          // We need a context, so this is a simplified version
        );
      } catch (e) {
        debugPrint('Failed to preload image: $url');
      }
    }
  }
}

class ProfileImage extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final BorderRadiusGeometry? borderRadius;
  final bool showInitials;
  final Color? backgroundColor;
  final Color? textColor;
  final bool enableCaching;
  final Widget? placeholder;

  const ProfileImage({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = 60.0,
    this.borderRadius,
    this.showInitials = true,
    this.backgroundColor,
    this.textColor,
    this.enableCaching = true,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(size / 2);
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return OptimizedImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        borderRadius: effectiveBorderRadius,
        enableCaching: enableCaching,
        placeholder: placeholder,
        errorWidget: _buildInitialsWidget(),
      );
    }
    
    return _buildInitialsWidget();
  }

  Widget _buildInitialsWidget() {
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primaryLight;
    final effectiveTextColor = textColor ?? Colors.white;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      ),
      child: showInitials && name != null && name!.isNotEmpty
          ? Center(
              child: Text(
                _getInitials(name!),
                style: TextStyle(
                  color: effectiveTextColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Icon(
              Icons.person,
              color: effectiveTextColor,
              size: size * 0.6,
            ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }
}

class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;
  final bool enableCaching;
  final int initialIndex;
  final bool enableFullScreen;
  final VoidCallback? onImageTap;

  const ImageGallery({
    Key? key,
    required this.imageUrls,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableCaching = true,
    this.initialIndex = 0,
    this.enableFullScreen = true,
    this.onImageTap,
  }) : super(key: key);

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    if (widget.imageUrls.length == 1) {
      return _buildSingleImage();
    }

    return _buildImageCarousel();
  }

  Widget _buildEmptyState() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: AppColors.textSecondaryDark,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildSingleImage() {
    return GestureDetector(
      onTap: widget.onImageTap,
      child: OptimizedImage(
        imageUrl: widget.imageUrls[0],
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        borderRadius: widget.borderRadius,
        enableCaching: widget.enableCaching,
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: widget.onImageTap,
              child: OptimizedImage(
                imageUrl: widget.imageUrls[index],
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                borderRadius: widget.borderRadius,
                enableCaching: widget.enableCaching,
              ),
            );
          },
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
