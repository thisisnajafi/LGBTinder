import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Media Viewer
/// 
/// Full-screen media viewer with:
/// - Pinch-to-zoom for images
/// - Video playback with controls
/// - Swipe navigation between media
/// - Download, share, and delete options
class MediaViewer extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final bool allowDownload;
  final bool allowShare;
  final bool allowDelete;
  final Function(int)? onDelete;

  const MediaViewer({
    Key? key,
    required this.mediaItems,
    this.initialIndex = 0,
    this.allowDownload = true,
    this.allowShare = true,
    this.allowDelete = false,
    this.onDelete,
  }) : super(key: key);

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Set immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Media gallery
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.mediaItems.length,
              itemBuilder: (context, index) {
                final mediaItem = widget.mediaItems[index];
                
                return _buildMediaItem(mediaItem);
              },
            ),
            
            // Top controls
            if (_showControls)
              _buildTopControls(),
            
            // Bottom controls
            if (_showControls && widget.mediaItems.length > 1)
              _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(MediaItem mediaItem) {
    switch (mediaItem.type) {
      case MediaType.image:
        return _buildImageViewer(mediaItem);
      case MediaType.video:
        return _buildVideoViewer(mediaItem);
      default:
        return const Center(
          child: Text(
            'Unsupported media type',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  Widget _buildImageViewer(MediaItem mediaItem) {
    return PhotoView(
      imageProvider: mediaItem.isLocal
          ? FileImage(File(mediaItem.url))
          : CachedNetworkImageProvider(mediaItem.url) as ImageProvider,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
      backgroundDecoration: const BoxDecoration(
        color: Colors.black,
      ),
      loadingBuilder: (context, event) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: AppTypography.body1.copyWith(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoViewer(MediaItem mediaItem) {
    return VideoPlayerWidget(
      url: mediaItem.url,
      isLocal: mediaItem.isLocal,
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 8,
          right: 8,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Close button
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 28,
              ),
            ),
            
            const Spacer(),
            
            // Share button
            if (widget.allowShare)
              IconButton(
                onPressed: _shareMedia,
                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            
            // Download button
            if (widget.allowDownload)
              IconButton(
                onPressed: _downloadMedia,
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            
            // Delete button
            if (widget.allowDelete)
              IconButton(
                onPressed: _deleteMedia,
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.mediaItems.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Counter
            Text(
              '${_currentIndex + 1} / ${widget.mediaItems.length}',
              style: AppTypography.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareMedia() async {
    final currentMedia = widget.mediaItems[_currentIndex];
    
    try {
      if (currentMedia.isLocal) {
        await Share.shareXFiles([XFile(currentMedia.url)]);
      } else {
        await Share.share(currentMedia.url);
      }
    } catch (e) {
      _showSnackBar('Failed to share media');
    }
  }

  Future<void> _downloadMedia() async {
    // TODO: Implement download functionality
    _showSnackBar('Download functionality coming soon');
  }

  Future<void> _deleteMedia() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Media'),
        content: const Text('Are you sure you want to delete this media?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onDelete?.call(_currentIndex);
      Navigator.pop(context);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool isLocal;

  const VideoPlayerWidget({
    Key? key,
    required this.url,
    this.isLocal = false,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = widget.isLocal
          ? VideoPlayerController.file(File(widget.url))
          : VideoPlayerController.networkUrl(Uri.parse(widget.url));

      await _controller.initialize();
      
      setState(() {
        _isInitialized = true;
      });
      
      // Auto play
      _controller.play();
      _controller.setLooping(true);
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load video',
              style: AppTypography.body1.copyWith(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Video player
        Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        
        // Play/Pause button
        VideoControls(controller: _controller),
      ],
    );
  }
}

/// Video Controls Widget
class VideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoControls({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  void _listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Pause button
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  widget.controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(widget.controller.value.position),
                      style: AppTypography.body2.copyWith(color: Colors.white),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Expanded(
                      child: VideoProgressIndicator(
                        widget.controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: AppColors.primary,
                          bufferedColor: Colors.white.withOpacity(0.3),
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    Text(
                      _formatDuration(widget.controller.value.duration),
                      style: AppTypography.body2.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Media Item Model
class MediaItem {
  final String url;
  final MediaType type;
  final bool isLocal;

  MediaItem({
    required this.url,
    required this.type,
    this.isLocal = false,
  });
}

/// Media Type Enum
enum MediaType {
  image,
  video,
  document,
}
