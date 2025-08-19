import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'dart:async';

class MatchCardPlayer extends StatefulWidget {
  final Map<String, dynamic> profile;
  final double width;
  final double height;
  final bool showShadow;

  const MatchCardPlayer({
    Key? key,
    required this.profile,
    required this.width,
    required this.height,
    this.showShadow = true,
  }) : super(key: key);

  @override
  State<MatchCardPlayer> createState() => _MatchCardPlayerState();
}

class _MatchCardPlayerState extends State<MatchCardPlayer> {
  int _currentImageIndex = 0;
  double _progress = 0.0;
  bool _imageLoaded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  @override
  void didUpdateWidget(covariant MatchCardPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      _currentImageIndex = 0;
      _resetProgress();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startProgress() {
    _timer?.cancel();
    _progress = 0.0;
    _imageLoaded = false;
    if ((widget.profile['images'] as List).length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!_imageLoaded) return;
        setState(() {
          _progress += 0.05 / 5.0; // 5 seconds
          if (_progress >= 1.0) {
            _progress = 0.0;
            _nextImage();
          }
        });
      });
    }
  }

  void _resetProgress() {
    _timer?.cancel();
    setState(() {
      _progress = 0.0;
      _imageLoaded = false;
    });
    _startProgress();
  }

  void _nextImage() {
    final images = widget.profile['images'] as List;
    setState(() {
      if (_currentImageIndex < images.length - 1) {
        _currentImageIndex++;
      } else {
        _currentImageIndex = 0;
      }
      _progress = 0.0;
      _imageLoaded = false;
    });
    _startProgress();
  }

  void _onImageTap() {
    _nextImage();
  }

  void _onImageLoaded() {
    if (!_imageLoaded) {
      setState(() {
        _imageLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onImageTap,
      child: MatchCard(
        profile: widget.profile,
        width: widget.width,
        height: widget.height,
        currentImageIndex: _currentImageIndex,
        progress: _progress,
        showProgressBar: (widget.profile['images'] as List).length > 1 && _imageLoaded,
        showShadow: widget.showShadow,
        onImageLoaded: _onImageLoaded,
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final Map<String, dynamic> profile;
  final double width;
  final double height;
  final int currentImageIndex;
  final double? progress;
  final bool showProgressBar;
  final bool showShadow;
  final VoidCallback? onImageLoaded;

  const MatchCard({
    Key? key,
    required this.profile,
    required this.width,
    required this.height,
    this.currentImageIndex = 0,
    this.progress,
    this.showProgressBar = false,
    this.showShadow = true,
    this.onImageLoaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Profile image with loading bar
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.network(
                  profile['images'][currentImageIndex],
                  key: ValueKey(currentImageIndex),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      onImageLoaded?.call();
                      return child;
                    }
                    final value = loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: AppColors.cardBackgroundDark),
                        if (value != null)
                          Align(
                            alignment: Alignment.topCenter,
                            child: LinearProgressIndicator(
                              value: value,
                              backgroundColor: Colors.black12,
                              color: AppColors.primaryLight,
                              minHeight: 4,
                            ),
                          ),
                      ],
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.cardBackgroundDark,
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Auto-advance progress bar (only if multiple images and image loaded)
            if (showProgressBar && progress != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black12,
                  color: AppColors.primaryLight,
                  minHeight: 4,
                ),
              ),
            // Profile info overlay
            _buildProfileInfoOverlay(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoOverlay(Map<String, dynamic> profile) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name and age
            Text(
              '${profile['name']} ${profile['age']}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Bio
            Text(
              profile['bio'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // Tags
            _buildTags(profile),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(Map<String, dynamic> profile) {
    return Wrap(
      spacing: 8,
      children: (profile['tags'] as List<String>).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.8),
                AppColors.secondaryLight.withOpacity(0.8),
              ],
            ),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }
} 