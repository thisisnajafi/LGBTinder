import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/haptic_feedback_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = true;
  double _volume = 0.7;
  Map<SoundType, String> _soundPaths = {};
  
  bool get isEnabled => _isEnabled;
  double get volume => _volume;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);
  }

  void setSoundPath(SoundType type, String path) {
    _soundPaths[type] = path;
  }

  Future<void> playSound(SoundType type) async {
    if (!_isEnabled) return;

    try {
      final soundPath = _soundPaths[type];
      if (soundPath != null && soundPath.isNotEmpty) {
        await _audioPlayer.play(AssetSource(soundPath));
      } else {
        // Fallback to system sounds
        await _playSystemSound(type);
      }
    } catch (e) {
      debugPrint('Failed to play sound: $e');
      // Fallback to system sounds
      await _playSystemSound(type);
    }
  }

  Future<void> _playSystemSound(SoundType type) async {
    switch (type) {
      case SoundType.match:
        await SystemSound.play(SystemSoundType.click);
        break;
      case SoundType.superLike:
        await SystemSound.play(SystemSoundType.click);
        break;
      case SoundType.message:
        await SystemSound.play(SystemSoundType.click);
        break;
      case SoundType.notification:
        await SystemSound.play(SystemSoundType.alert);
        break;
      case SoundType.error:
        await SystemSound.play(SystemSoundType.alert);
        break;
      case SoundType.success:
        await SystemSound.play(SystemSoundType.click);
        break;
      case SoundType.button:
        await SystemSound.play(SystemSoundType.click);
        break;
      case SoundType.swipe:
        await SystemSound.play(SystemSoundType.click);
        break;
    }
  }

  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}

enum SoundType {
  match,
  superLike,
  message,
  notification,
  error,
  success,
  button,
  swipe,
}

class SoundEffectWidget extends StatefulWidget {
  final Widget child;
  final SoundType soundType;
  final VoidCallback? onTap;
  final bool enableHapticFeedback;

  const SoundEffectWidget({
    Key? key,
    required this.child,
    required this.soundType,
    this.onTap,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  State<SoundEffectWidget> createState() => _SoundEffectWidgetState();
}

class _SoundEffectWidgetState extends State<SoundEffectWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _onTap() {
    AudioService().playSound(widget.soundType);
    
    if (widget.enableHapticFeedback) {
      HapticFeedbackService.selection();
    }
    
    widget.onTap?.call();
  }
}

class MatchSoundEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onMatch;
  final VoidCallback? onSuperLike;

  const MatchSoundEffect({
    Key? key,
    required this.child,
    this.onMatch,
    this.onSuperLike,
  }) : super(key: key);

  @override
  State<MatchSoundEffect> createState() => _MatchSoundEffectState();
}

class _MatchSoundEffectState extends State<MatchSoundEffect>
    with TickerProviderStateMixin {
  late AnimationController _matchController;
  late AnimationController _superLikeController;
  late Animation<double> _matchScaleAnimation;
  late Animation<double> _superLikeScaleAnimation;
  late Animation<double> _matchOpacityAnimation;
  late Animation<double> _superLikeOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _matchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _superLikeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _matchScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _matchController,
      curve: Curves.elasticOut,
    ));

    _superLikeScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _superLikeController,
      curve: Curves.elasticOut,
    ));

    _matchOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _matchController,
      curve: Curves.easeIn,
    ));

    _superLikeOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _superLikeController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _matchController.dispose();
    _superLikeController.dispose();
    super.dispose();
  }

  void playMatchSound() {
    AudioService().playSound(SoundType.match);
    _matchController.forward().then((_) {
      _matchController.reverse();
    });
    widget.onMatch?.call();
  }

  void playSuperLikeSound() {
    AudioService().playSound(SoundType.superLike);
    _superLikeController.forward().then((_) {
      _superLikeController.reverse();
    });
    widget.onSuperLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _matchController,
          builder: (context, child) {
            return Transform.scale(
              scale: _matchScaleAnimation.value,
              child: Opacity(
                opacity: _matchOpacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.prideRed.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _superLikeController,
          builder: (context, child) {
            return Transform.scale(
              scale: _superLikeScaleAnimation.value,
              child: Opacity(
                opacity: _superLikeOpacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.prideYellow.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class AudioSettingsWidget extends StatefulWidget {
  final Function(bool enabled)? onEnabledChanged;
  final Function(double volume)? onVolumeChanged;

  const AudioSettingsWidget({
    Key? key,
    this.onEnabledChanged,
    this.onVolumeChanged,
  }) : super(key: key);

  @override
  State<AudioSettingsWidget> createState() => _AudioSettingsWidgetState();
}

class _AudioSettingsWidgetState extends State<AudioSettingsWidget> {
  late bool _isEnabled;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _isEnabled = AudioService().isEnabled;
    _volume = AudioService().volume;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audio Settings',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text(
            'Enable Sound Effects',
            style: TextStyle(color: AppColors.textPrimaryDark),
          ),
          subtitle: const Text(
            'Play sounds for matches, messages, and interactions',
            style: TextStyle(color: AppColors.textSecondaryDark),
          ),
          value: _isEnabled,
          onChanged: (value) {
            setState(() {
              _isEnabled = value;
            });
            AudioService().setEnabled(value);
            widget.onEnabledChanged?.call(value);
          },
          activeColor: AppColors.primaryLight,
        ),
        const SizedBox(height: 16),
        Text(
          'Volume: ${(_volume * 100).round()}%',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        Slider(
          value: _volume,
          onChanged: _isEnabled ? (value) {
            setState(() {
              _volume = value;
            });
            AudioService().setVolume(value);
            widget.onVolumeChanged?.call(value);
          } : null,
          activeColor: AppColors.primaryLight,
          inactiveColor: AppColors.surfaceSecondary,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isEnabled ? () {
                  AudioService().playSound(SoundType.match);
                } : null,
                icon: const Icon(Icons.favorite),
                label: const Text('Test Match'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.prideRed,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isEnabled ? () {
                  AudioService().playSound(SoundType.superLike);
                } : null,
                icon: const Icon(Icons.star),
                label: const Text('Test Super Like'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.prideYellow,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SoundPreviewWidget extends StatelessWidget {
  final SoundType soundType;
  final String label;
  final IconData icon;

  const SoundPreviewWidget({
    Key? key,
    required this.soundType,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SoundEffectWidget(
      soundType: soundType,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            Icon(
              Icons.play_arrow,
              color: AppColors.textSecondaryDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final Map<SoundType, String> _defaultSounds = {
    SoundType.match: 'sounds/match.mp3',
    SoundType.superLike: 'sounds/super_like.mp3',
    SoundType.message: 'sounds/message.mp3',
    SoundType.notification: 'sounds/notification.mp3',
    SoundType.error: 'sounds/error.mp3',
    SoundType.success: 'sounds/success.mp3',
    SoundType.button: 'sounds/button.mp3',
    SoundType.swipe: 'sounds/swipe.mp3',
  };

  void initializeSounds() {
    final audioService = AudioService();
    for (final entry in _defaultSounds.entries) {
      audioService.setSoundPath(entry.key, entry.value);
    }
  }

  void preloadSounds() async {
    final audioService = AudioService();
    for (final soundType in SoundType.values) {
      try {
        await audioService.playSound(soundType);
        await audioService.stopSound();
      } catch (e) {
        debugPrint('Failed to preload sound: $soundType');
      }
    }
  }
}
