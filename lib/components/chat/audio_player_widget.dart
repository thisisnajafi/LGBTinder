import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/audio_cache_service.dart';

/// Audio Player Widget
/// 
/// Play audio messages with:
/// - Play/pause functionality
/// - Audio duration and playback progress
/// - Speed control (1x, 1.5x, 2x)
/// - Seek bar for jumping to specific position
/// - Loading state while audio is being loaded
/// - Automatic caching for offline playback
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Duration? totalDuration;
  final bool isOutgoing;
  final VoidCallback? onPlaybackComplete;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    this.totalDuration,
    this.isOutgoing = false,
    this.onPlaybackComplete,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  final AudioCacheService _cacheService = AudioCacheService();
  
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _stateSubscription;
  StreamSubscription? _completeSubscription;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _totalDuration = widget.totalDuration ?? Duration.zero;
    _setupPlayerListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _completeSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _setupPlayerListeners() {
    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = state == PlayerState.playing && _currentPosition == Duration.zero;
        });
      }
    });

    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }
    });

    _durationSubscription = _player.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
        widget.onPlaybackComplete?.call();
      }
    });
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        setState(() {
          _isLoading = true;
        });
        
        if (_currentPosition == Duration.zero || _currentPosition >= _totalDuration) {
          // Get cached audio file or download it
          final audioPath = await _cacheService.getCachedAudio(widget.audioUrl);
          
          if (audioPath != null) {
            // Check if it's a local file or URL
            if (audioPath.startsWith('http://') || audioPath.startsWith('https://')) {
              await _player.play(UrlSource(audioPath));
            } else {
              await _player.play(DeviceFileSource(audioPath));
            }
            await _player.setPlaybackRate(_playbackSpeed);
          }
        } else {
          // Resume from current position
          await _player.resume();
        }
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _showError('Failed to play audio');
    }
  }

  Future<void> _cyclePlaybackSpeed() async {
    // Cycle through: 1.0x -> 1.5x -> 2.0x -> 1.0x
    double newSpeed;
    if (_playbackSpeed == 1.0) {
      newSpeed = 1.5;
    } else if (_playbackSpeed == 1.5) {
      newSpeed = 2.0;
    } else {
      newSpeed = 1.0;
    }

    try {
      await _player.setPlaybackRate(newSpeed);
      if (mounted) {
        setState(() {
          _playbackSpeed = newSpeed;
        });
      }
    } catch (e) {
      debugPrint('Error setting playback speed: $e');
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error seeking audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _getSpeedLabel() {
    if (_playbackSpeed == 1.0) {
      return '1x';
    } else if (_playbackSpeed == 1.5) {
      return '1.5x';
    } else {
      return '2x';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    final primaryColor = widget.isOutgoing ? Colors.white : AppColors.primary;
    final secondaryColor = widget.isOutgoing ? Colors.white70 : AppColors.primary.withOpacity(0.7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Play/Pause Button
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: primaryColor,
                          size: 24,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Progress Bar and Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Seek Slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: secondaryColor.withOpacity(0.3),
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: progressValue.clamp(0.0, 1.0),
                        onChanged: (value) {
                          final newPosition = Duration(
                            milliseconds: (value * _totalDuration.inMilliseconds).round(),
                          );
                          _seekTo(newPosition);
                        },
                      ),
                    ),

                    // Time Display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_currentPosition),
                            style: AppTypography.caption.copyWith(
                              color: secondaryColor,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            _formatDuration(_totalDuration),
                            style: AppTypography.caption.copyWith(
                              color: secondaryColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Speed Control Button
              GestureDetector(
                onTap: _cyclePlaybackSpeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getSpeedLabel(),
                    style: AppTypography.caption.copyWith(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

