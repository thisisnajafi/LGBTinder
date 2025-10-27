import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Audio Recorder Widget
/// 
/// Record voice messages with:
/// - Record, pause, resume, stop
/// - Recording duration timer
/// - Waveform visualization
/// - Maximum recording duration (5 minutes)
/// - Preview playback before sending
class AudioRecorderWidget extends StatefulWidget {
  final Function(File) onAudioRecorded;
  final VoidCallback onCancel;
  final Duration maxDuration;

  const AudioRecorderWidget({
    Key? key,
    required this.onAudioRecorded,
    required this.onCancel,
    this.maxDuration = const Duration(minutes: 5),
  }) : super(key: key);

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  
  RecordingState _state = RecordingState.idle;
  Duration _recordedDuration = Duration.zero;
  Timer? _timer;
  String? _audioPath;
  bool _isPlaying = false;
  Duration _playbackPosition = Duration.zero;
  List<double> _waveformData = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _setupPlayerListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showError('Microphone permission is required');
    }
  }

  void _setupPlayerListeners() {
    _player.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _player.onPositionChanged.listen((position) {
      setState(() {
        _playbackPosition = position;
      });
    });

    _player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _playbackPosition = Duration.zero;
      });
    });
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        // Generate file path
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _audioPath = '${directory.path}/audio_$timestamp.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 64000,
            sampleRate: 44100,
          ),
          path: _audioPath!,
        );

        setState(() {
          _state = RecordingState.recording;
          _recordedDuration = Duration.zero;
        });

        _startTimer();
      }
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _recorder.pause();
      setState(() {
        _state = RecordingState.paused;
      });
      _timer?.cancel();
    } catch (e) {
      _showError('Failed to pause recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _recorder.resume();
      setState(() {
        _state = RecordingState.recording;
      });
      _startTimer();
    } catch (e) {
      _showError('Failed to resume recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      _timer?.cancel();
      
      if (path != null && path.isNotEmpty) {
        setState(() {
          _audioPath = path;
          _state = RecordingState.preview;
        });
      }
    } catch (e) {
      _showError('Failed to stop recording: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordedDuration += const Duration(milliseconds: 100);
        
        // Add waveform data (simulated - in production, use actual amplitude)
        _waveformData.add(_recordedDuration.inMilliseconds % 100 / 100);
        if (_waveformData.length > 50) {
          _waveformData.removeAt(0);
        }

        // Check max duration
        if (_recordedDuration >= widget.maxDuration) {
          _stopRecording();
        }
      });
    });
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;

    try {
      await _player.play(DeviceFileSource(_audioPath!));
    } catch (e) {
      _showError('Failed to play audio: $e');
    }
  }

  Future<void> _pausePlayback() async {
    await _player.pause();
  }

  void _cancelRecording() {
    _timer?.cancel();
    _recorder.stop();
    _player.stop();
    
    // Delete file if exists
    if (_audioPath != null) {
      try {
        File(_audioPath!).deleteSync();
      } catch (e) {
        debugPrint('Failed to delete audio file: $e');
      }
    }
    
    widget.onCancel();
  }

  void _sendAudio() {
    if (_audioPath != null) {
      widget.onAudioRecorded(File(_audioPath!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            _state == RecordingState.preview
                ? 'Preview Audio'
                : 'Record Voice Message',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Waveform or playback progress
          if (_state == RecordingState.recording || _state == RecordingState.paused)
            _buildWaveform()
          else if (_state == RecordingState.preview)
            _buildPlaybackProgress(),

          const SizedBox(height: 24),

          // Duration display
          Text(
            _formatDuration(
              _state == RecordingState.preview
                  ? _playbackPosition
                  : _recordedDuration,
            ),
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 32),

          // Controls
          if (_state == RecordingState.idle)
            _buildIdleControls()
          else if (_state == RecordingState.recording)
            _buildRecordingControls()
          else if (_state == RecordingState.paused)
            _buildPausedControls()
          else if (_state == RecordingState.preview)
            _buildPreviewControls(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          50,
          (index) {
            final amplitude = index < _waveformData.length
                ? _waveformData[index]
                : 0.0;
            return Container(
              width: 3,
              height: 60 * amplitude.clamp(0.1, 1.0),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _state == RecordingState.recording
                    ? AppColors.primary
                    : Colors.white54,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaybackProgress() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _recordedDuration.inMilliseconds > 0
              ? _playbackPosition.inMilliseconds / _recordedDuration.inMilliseconds
              : 0,
          backgroundColor: Colors.white24,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 4,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_playbackPosition),
              style: AppTypography.body2.copyWith(color: Colors.white70),
            ),
            Text(
              _formatDuration(_recordedDuration),
              style: AppTypography.body2.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdleControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.close,
          label: 'Cancel',
          onPressed: _cancelRecording,
          color: Colors.red,
        ),
        _buildControlButton(
          icon: Icons.mic,
          label: 'Record',
          onPressed: _startRecording,
          color: AppColors.primary,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildRecordingControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.close,
          label: 'Cancel',
          onPressed: _cancelRecording,
          color: Colors.red,
        ),
        _buildControlButton(
          icon: Icons.pause,
          label: 'Pause',
          onPressed: _pauseRecording,
          color: AppColors.primary,
        ),
        _buildControlButton(
          icon: Icons.stop,
          label: 'Stop',
          onPressed: _stopRecording,
          color: AppColors.primary,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildPausedControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.close,
          label: 'Cancel',
          onPressed: _cancelRecording,
          color: Colors.red,
        ),
        _buildControlButton(
          icon: Icons.play_arrow,
          label: 'Resume',
          onPressed: _resumeRecording,
          color: AppColors.primary,
        ),
        _buildControlButton(
          icon: Icons.stop,
          label: 'Stop',
          onPressed: _stopRecording,
          color: AppColors.primary,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildPreviewControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.close,
          label: 'Cancel',
          onPressed: _cancelRecording,
          color: Colors.red,
        ),
        _buildControlButton(
          icon: _isPlaying ? Icons.pause : Icons.play_arrow,
          label: _isPlaying ? 'Pause' : 'Play',
          onPressed: _isPlaying ? _pausePlayback : _playAudio,
          color: AppColors.primary,
        ),
        _buildControlButton(
          icon: Icons.send,
          label: 'Send',
          onPressed: _sendAudio,
          color: AppColors.primary,
          isPrimary: true,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: isPrimary ? 72 : 64,
            height: isPrimary ? 72 : 64,
            decoration: BoxDecoration(
              color: isPrimary ? color : color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: isPrimary ? 36 : 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.body2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show audio recorder as bottom sheet
  static Future<File?> show(
    BuildContext context, {
    Duration maxDuration = const Duration(minutes: 5),
  }) async {
    File? recordedFile;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => AudioRecorderWidget(
        maxDuration: maxDuration,
        onAudioRecorded: (file) {
          recordedFile = file;
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );

    return recordedFile;
  }
}

/// Recording State Enum
enum RecordingState {
  idle,
  recording,
  paused,
  preview,
}

