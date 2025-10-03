import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
