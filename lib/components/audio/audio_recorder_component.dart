import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/audio_recorder_service.dart';
import '../../services/haptic_feedback_service.dart';

class AudioRecorderComponent extends StatefulWidget {
  final Function(String) onRecordingComplete;
  final Function(String)? onError;
  final bool showWaveform;
  final bool showDuration;
  final bool showAmplitude;
  final bool allowPause;
  final bool allowCancel;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? recordingColor;
  final Color? pausedColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? height;
  final bool enableHapticFeedback;
  final String? customPath;

  const AudioRecorderComponent({
    Key? key,
    required this.onRecordingComplete,
    this.onError,
    this.showWaveform = true,
    this.showDuration = true,
    this.showAmplitude = true,
    this.allowPause = true,
    this.allowCancel = true,
    this.backgroundColor,
    this.foregroundColor,
    this.recordingColor,
    this.pausedColor,
    this.padding,
    this.borderRadius,
    this.height,
    this.enableHapticFeedback = true,
    this.customPath,
  }) : super(key: key);

  @override
  State<AudioRecorderComponent> createState() => _AudioRecorderComponentState();
}

class _AudioRecorderComponentState extends State<AudioRecorderComponent>
    with TickerProviderStateMixin {
  final AudioRecorderService _audioRecorderService = AudioRecorderService();
  
  late AnimationController _pulseController;
  late AnimationController _waveformController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveformAnimation;
  
  Duration _recordingDuration = Duration.zero;
  double _currentAmplitude = 0.0;
  RecordingState _recordingState = RecordingState.idle;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeRecorder();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveformController.dispose();
    _audioRecorderService.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveformAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveformController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeRecorder() async {
    await _audioRecorderService.initialize();
    
    // Listen to duration updates
    _audioRecorderService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _recordingDuration = duration;
        });
      }
    });
    
    // Listen to amplitude updates
    _audioRecorderService.amplitudeStream.listen((amplitude) {
      if (mounted) {
        setState(() {
          _currentAmplitude = amplitude;
        });
      }
    });
    
    // Listen to state updates
    _audioRecorderService.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _recordingState = state;
        });
        
        // Update animations based on state
        switch (state) {
          case RecordingState.recording:
            _pulseController.repeat(reverse: true);
            _waveformController.repeat(reverse: true);
            break;
          case RecordingState.paused:
            _pulseController.stop();
            _waveformController.stop();
            break;
          case RecordingState.stopped:
          case RecordingState.canceled:
            _pulseController.stop();
            _waveformController.stop();
            break;
          case RecordingState.idle:
            _pulseController.reset();
            _waveformController.reset();
            break;
        }
      }
    });
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingState();
    }

    return Container(
      height: widget.height ?? 120,
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.navbarBackground,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Waveform visualization
          if (widget.showWaveform) _buildWaveform(),
          
          const SizedBox(height: 16),
          
          // Duration and amplitude info
          if (widget.showDuration || widget.showAmplitude) _buildInfoRow(),
          
          const SizedBox(height: 16),
          
          // Control buttons
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: widget.height ?? 120,
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.navbarBackground,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveformAnimation,
      builder: (context, child) {
        return Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (index) {
              final height = _getWaveformHeight(index);
              return Container(
                width: 3,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: _getWaveformColor(),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  double _getWaveformHeight(int index) {
    if (_recordingState == RecordingState.idle) return 4.0;
    
    // Create a wave pattern based on amplitude and animation
    final baseHeight = 4.0;
    final maxHeight = 32.0;
    final waveOffset = (index * 0.3) + (_waveformAnimation.value * 2 * 3.14159);
    final amplitudeFactor = (_currentAmplitude / 100.0).clamp(0.1, 1.0);
    
    return baseHeight + (maxHeight - baseHeight) * 
           (0.5 + 0.5 * (waveOffset.sin() * amplitudeFactor));
  }

  Color _getWaveformColor() {
    switch (_recordingState) {
      case RecordingState.recording:
        return widget.recordingColor ?? AppColors.error;
      case RecordingState.paused:
        return widget.pausedColor ?? AppColors.warning;
      case RecordingState.stopped:
      case RecordingState.canceled:
        return widget.foregroundColor ?? Colors.white70;
      case RecordingState.idle:
        return widget.foregroundColor ?? Colors.white70;
    }
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.showDuration)
          Text(
            _formatDuration(_recordingDuration),
            style: AppTypography.body1.copyWith(
              color: widget.foregroundColor ?? Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (widget.showAmplitude)
          Text(
            '${_currentAmplitude.toStringAsFixed(1)} dB',
            style: AppTypography.body2.copyWith(
              color: (widget.foregroundColor ?? Colors.white).withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cancel button
        if (widget.allowCancel && _recordingState != RecordingState.idle)
          _buildControlButton(
            icon: Icons.cancel,
            color: AppColors.error,
            onPressed: _cancelRecording,
          ),
        
        if (widget.allowCancel && _recordingState != RecordingState.idle)
          const SizedBox(width: 16),
        
        // Main record button
        _buildMainRecordButton(),
        
        if (widget.allowPause && _recordingState != RecordingState.idle)
          const SizedBox(width: 16),
        
        // Pause/Resume button
        if (widget.allowPause && _recordingState != RecordingState.idle)
          _buildControlButton(
            icon: _recordingState == RecordingState.paused ? Icons.play_arrow : Icons.pause,
            color: _recordingState == RecordingState.paused ? AppColors.success : AppColors.warning,
            onPressed: _recordingState == RecordingState.paused ? _resumeRecording : _pauseRecording,
          ),
      ],
    );
  }

  Widget _buildMainRecordButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _recordingState == RecordingState.recording ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: _handleMainButtonTap,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getMainButtonColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getMainButtonColor().withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _getMainButtonIcon(),
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Color _getMainButtonColor() {
    switch (_recordingState) {
      case RecordingState.recording:
        return widget.recordingColor ?? AppColors.error;
      case RecordingState.paused:
        return widget.pausedColor ?? AppColors.warning;
      case RecordingState.stopped:
      case RecordingState.canceled:
        return AppColors.success;
      case RecordingState.idle:
        return AppColors.primary;
    }
  }

  IconData _getMainButtonIcon() {
    switch (_recordingState) {
      case RecordingState.recording:
        return Icons.stop;
      case RecordingState.paused:
        return Icons.stop;
      case RecordingState.stopped:
      case RecordingState.canceled:
        return Icons.refresh;
      case RecordingState.idle:
        return Icons.mic;
    }
  }

  void _handleMainButtonTap() async {
    if (widget.enableHapticFeedback) {
      await HapticFeedbackService().light();
    }

    switch (_recordingState) {
      case RecordingState.idle:
        await _startRecording();
        break;
      case RecordingState.recording:
        await _stopRecording();
        break;
      case RecordingState.paused:
        await _stopRecording();
        break;
      case RecordingState.stopped:
      case RecordingState.canceled:
        await _startRecording();
        break;
    }
  }

  Future<void> _startRecording() async {
    try {
      final success = await _audioRecorderService.startRecording(
        customPath: widget.customPath,
      );
      
      if (!success) {
        widget.onError?.call('Failed to start recording');
      }
    } catch (e) {
      widget.onError?.call('Recording error: $e');
    }
  }

  Future<void> _pauseRecording() async {
    try {
      final success = await _audioRecorderService.pauseRecording();
      
      if (!success) {
        widget.onError?.call('Failed to pause recording');
      }
    } catch (e) {
      widget.onError?.call('Pause error: $e');
    }
  }

  Future<void> _resumeRecording() async {
    try {
      final success = await _audioRecorderService.resumeRecording();
      
      if (!success) {
        widget.onError?.call('Failed to resume recording');
      }
    } catch (e) {
      widget.onError?.call('Resume error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final recordingPath = await _audioRecorderService.stopRecording();
      
      if (recordingPath != null) {
        widget.onRecordingComplete(recordingPath);
      } else {
        widget.onError?.call('Failed to stop recording');
      }
    } catch (e) {
      widget.onError?.call('Stop error: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      final success = await _audioRecorderService.cancelRecording();
      
      if (!success) {
        widget.onError?.call('Failed to cancel recording');
      }
    } catch (e) {
      widget.onError?.call('Cancel error: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final milliseconds = duration.inMilliseconds % 1000;
    
    if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds.toString().padLeft(2, '0')}.${(milliseconds / 100).floor()}';
    }
  }
}

class AudioRecorderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRecording;
  final Duration? duration;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? recordingColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool enableHapticFeedback;

  const AudioRecorderButton({
    Key? key,
    required this.onPressed,
    this.isRecording = false,
    this.duration,
    this.backgroundColor,
    this.foregroundColor,
    this.recordingColor,
    this.padding,
    this.borderRadius,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (enableHapticFeedback) {
          await HapticFeedbackService().light();
        }
        onPressed();
      },
      icon: Icon(isRecording ? Icons.stop : Icons.mic),
      label: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecording 
            ? (recordingColor ?? AppColors.error)
            : (backgroundColor ?? AppColors.primary),
        foregroundColor: foregroundColor ?? Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class AudioRecorderFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRecording;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? recordingColor;
  final bool enableHapticFeedback;

  const AudioRecorderFloatingActionButton({
    Key? key,
    required this.onPressed,
    this.isRecording = false,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.recordingColor,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (enableHapticFeedback) {
          await HapticFeedbackService().light();
        }
        onPressed();
      },
      tooltip: tooltip ?? (isRecording ? 'Stop Recording' : 'Start Recording'),
      backgroundColor: isRecording 
          ? (recordingColor ?? AppColors.error)
          : (backgroundColor ?? AppColors.primary),
      foregroundColor: foregroundColor ?? Colors.white,
      child: Icon(isRecording ? Icons.stop : Icons.mic),
    );
  }
}

class AudioRecorderIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRecording;
  final String? tooltip;
  final Color? color;
  final Color? recordingColor;
  final double? iconSize;
  final bool enableHapticFeedback;

  const AudioRecorderIconButton({
    Key? key,
    required this.onPressed,
    this.isRecording = false,
    this.tooltip,
    this.color,
    this.recordingColor,
    this.iconSize,
    this.enableHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        if (enableHapticFeedback) {
          await HapticFeedbackService().light();
        }
        onPressed();
      },
      icon: Icon(isRecording ? Icons.stop : Icons.mic),
      tooltip: tooltip ?? (isRecording ? 'Stop Recording' : 'Start Recording'),
      color: isRecording 
          ? (recordingColor ?? AppColors.error)
          : (color ?? AppColors.primary),
      iconSize: iconSize,
    );
  }
}
