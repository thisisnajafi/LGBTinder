import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/haptic_feedback_service.dart';

class AudioRecorderService {
  static final AudioRecorderService _instance = AudioRecorderService._internal();
  factory AudioRecorderService() => _instance;
  AudioRecorderService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  
  // Recording state
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isEnabled = true;
  bool _hapticFeedbackEnabled = true;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  double _currentAmplitude = 0.0;

  // Recording settings
  AudioEncoder _encoder = AudioEncoder.aacLc;
  int _bitRate = 128000;
  int _sampleRate = 44100;
  int _numChannels = 1;
  bool _autoGain = true;
  bool _echoCancel = true;
  bool _noiseSuppress = true;
  Duration _maxRecordingDuration = const Duration(minutes: 5);
  Duration _minRecordingDuration = const Duration(seconds: 1);

  // Getters
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  bool get isEnabled => _isEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  String? get currentRecordingPath => _currentRecordingPath;
  Duration get recordingDuration => _recordingDuration;
  double get currentAmplitude => _currentAmplitude;
  AudioEncoder get encoder => _encoder;
  int get bitRate => _bitRate;
  int get sampleRate => _sampleRate;
  int get numChannels => _numChannels;
  bool get autoGain => _autoGain;
  bool get echoCancel => _echoCancel;
  bool get noiseSuppress => _noiseSuppress;
  Duration get maxRecordingDuration => _maxRecordingDuration;
  Duration get minRecordingDuration => _minRecordingDuration;

  // Stream controllers for real-time updates
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  final StreamController<double> _amplitudeController = StreamController<double>.broadcast();
  final StreamController<RecordingState> _stateController = StreamController<RecordingState>.broadcast();

  // Streams
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  Stream<RecordingState> get stateStream => _stateController.stream;

  /// Initialize audio recorder service
  Future<void> initialize() async {
    try {
      // Check if recording is supported
      final isSupported = await _audioRecorder.hasPermission();
      if (!isSupported) {
        debugPrint('Audio recording not supported on this device');
        _isEnabled = false;
        return;
      }

      debugPrint('Audio Recorder Service initialized');
    } catch (e) {
      debugPrint('Failed to initialize Audio Recorder Service: $e');
      _isEnabled = false;
    }
  }

  /// Enable/disable audio recorder
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Enable/disable haptic feedback
  void setHapticFeedbackEnabled(bool enabled) {
    _hapticFeedbackEnabled = enabled;
  }

  /// Set audio encoder
  void setEncoder(AudioEncoder encoder) {
    _encoder = encoder;
  }

  /// Set bit rate
  void setBitRate(int bitRate) {
    _bitRate = bitRate.clamp(32000, 320000);
  }

  /// Set sample rate
  void setSampleRate(int sampleRate) {
    _sampleRate = sampleRate.clamp(8000, 48000);
  }

  /// Set number of channels
  void setNumChannels(int channels) {
    _numChannels = channels.clamp(1, 2);
  }

  /// Set auto gain
  void setAutoGain(bool enabled) {
    _autoGain = enabled;
  }

  /// Set echo cancellation
  void setEchoCancel(bool enabled) {
    _echoCancel = enabled;
  }

  /// Set noise suppression
  void setNoiseSuppress(bool enabled) {
    _noiseSuppress = enabled;
  }

  /// Set maximum recording duration
  void setMaxRecordingDuration(Duration duration) {
    _maxRecordingDuration = duration;
  }

  /// Set minimum recording duration
  void setMinRecordingDuration(Duration duration) {
    _minRecordingDuration = duration;
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('Microphone permission error: $e');
      return false;
    }
  }

  /// Start recording
  Future<bool> startRecording({String? customPath}) async {
    if (!_isEnabled || _isRecording) return false;

    try {
      // Request microphone permission
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        throw PermissionException('Microphone permission denied');
      }

      // Generate recording path
      _currentRecordingPath = customPath ?? await _generateRecordingPath();

      // Configure recording settings
      final config = RecordConfig(
        encoder: _encoder,
        bitRate: _bitRate,
        sampleRate: _sampleRate,
        numChannels: _numChannels,
        autoGain: _autoGain,
        echoCancel: _echoCancel,
        noiseSuppress: _noiseSuppress,
      );

      // Start recording
      final isRecording = await _audioRecorder.start(config, path: _currentRecordingPath!);
      
      if (isRecording) {
        _isRecording = true;
        _isPaused = false;
        _recordingDuration = Duration.zero;
        
        // Trigger haptic feedback
        if (_hapticFeedbackEnabled) {
          await HapticFeedbackService().recordStart();
        }

        // Start duration timer
        _startDurationTimer();

        // Start amplitude monitoring
        _startAmplitudeMonitoring();

        // Notify state change
        _stateController.add(RecordingState.recording);

        debugPrint('Recording started: $_currentRecordingPath');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Start recording error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return false;
    }
  }

  /// Pause recording
  Future<bool> pauseRecording() async {
    if (!_isRecording || _isPaused) return false;

    try {
      final isPaused = await _audioRecorder.pause();
      
      if (isPaused) {
        _isPaused = true;
        
        // Trigger haptic feedback
        if (_hapticFeedbackEnabled) {
          await HapticFeedbackService().recordPause();
        }

        // Stop duration timer
        _stopDurationTimer();

        // Notify state change
        _stateController.add(RecordingState.paused);

        debugPrint('Recording paused');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Pause recording error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return false;
    }
  }

  /// Resume recording
  Future<bool> resumeRecording() async {
    if (!_isRecording || !_isPaused) return false;

    try {
      final isResumed = await _audioRecorder.resume();
      
      if (isResumed) {
        _isPaused = false;
        
        // Trigger haptic feedback
        if (_hapticFeedbackEnabled) {
          await HapticFeedbackService().recordResume();
        }

        // Resume duration timer
        _startDurationTimer();

        // Notify state change
        _stateController.add(RecordingState.recording);

        debugPrint('Recording resumed');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Resume recording error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return false;
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final recordingPath = await _audioRecorder.stop();
      
      if (recordingPath != null) {
        _isRecording = false;
        _isPaused = false;
        
        // Trigger haptic feedback
        if (_hapticFeedbackEnabled) {
          await HapticFeedbackService().recordStop();
        }

        // Stop timers and subscriptions
        _stopDurationTimer();
        _stopAmplitudeMonitoring();

        // Notify state change
        _stateController.add(RecordingState.stopped);

        debugPrint('Recording stopped: $recordingPath');
        return recordingPath;
      }

      return null;
    } catch (e) {
      debugPrint('Stop recording error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return null;
    } finally {
      _resetRecordingState();
    }
  }

  /// Cancel recording
  Future<bool> cancelRecording() async {
    if (!_isRecording) return false;

    try {
      final isCanceled = await _audioRecorder.cancel();
      
      if (isCanceled) {
        _isRecording = false;
        _isPaused = false;
        
        // Trigger haptic feedback
        if (_hapticFeedbackEnabled) {
          await HapticFeedbackService().recordCancel();
        }

        // Stop timers and subscriptions
        _stopDurationTimer();
        _stopAmplitudeMonitoring();

        // Delete the recording file if it exists
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        // Notify state change
        _stateController.add(RecordingState.canceled);

        debugPrint('Recording canceled');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Cancel recording error: $e');
      
      // Trigger error haptic feedback
      if (_hapticFeedbackEnabled) {
        await HapticFeedbackService().error();
      }
      
      return false;
    } finally {
      _resetRecordingState();
    }
  }

  /// Check if recording is in progress
  Future<bool> isRecordingInProgress() async {
    try {
      return await _audioRecorder.isRecording();
    } catch (e) {
      debugPrint('Check recording status error: $e');
      return false;
    }
  }

  /// Get recording duration
  Future<Duration?> getRecordingDuration() async {
    try {
      return await _audioRecorder.getAmplitude();
    } catch (e) {
      debugPrint('Get recording duration error: $e');
      return null;
    }
  }

  /// Get current amplitude
  Future<Amplitude> getCurrentAmplitude() async {
    try {
      return await _audioRecorder.getAmplitude();
    } catch (e) {
      debugPrint('Get amplitude error: $e');
      return const Amplitude(current: 0.0, max: 0.0);
    }
  }

  /// Generate recording path
  Future<String> _generateRecordingPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'recording_$timestamp.${_getFileExtension()}';
      return '${directory.path}/$fileName';
    } catch (e) {
      debugPrint('Generate recording path error: $e');
      return '/tmp/recording_${DateTime.now().millisecondsSinceEpoch}.${_getFileExtension()}';
    }
  }

  /// Get file extension based on encoder
  String _getFileExtension() {
    switch (_encoder) {
      case AudioEncoder.aacLc:
        return 'aac';
      case AudioEncoder.opus:
        return 'opus';
      case AudioEncoder.flac:
        return 'flac';
      case AudioEncoder.wav:
        return 'wav';
      case AudioEncoder.pcm16bits:
        return 'pcm';
      case AudioEncoder.pcm8bits:
        return 'pcm';
      case AudioEncoder.pcmFloat32:
        return 'pcm';
      case AudioEncoder.pcmMp3:
        return 'mp3';
      case AudioEncoder.pcmWav:
        return 'wav';
      case AudioEncoder.oggOpus:
        return 'ogg';
      case AudioEncoder.opusWebm:
        return 'webm';
      case AudioEncoder.aacEld:
        return 'aac';
      case AudioEncoder.aacHe:
        return 'aac';
      case AudioEncoder.amrNb:
        return 'amr';
      case AudioEncoder.amrWb:
        return 'amr';
      case AudioEncoder.g711Alaw:
        return 'alaw';
      case AudioEncoder.g711Mlaw:
        return 'mlaw';
      case AudioEncoder.g722:
        return 'g722';
      case AudioEncoder.g729:
        return 'g729';
      case AudioEncoder.gsm:
        return 'gsm';
      case AudioEncoder.gsmEfr:
        return 'gsm';
      case AudioEncoder.gsmHr:
        return 'gsm';
      case AudioEncoder.lpc:
        return 'lpc';
      case AudioEncoder.silk:
        return 'silk';
      case AudioEncoder.silk8:
        return 'silk';
      case AudioEncoder.silk12:
        return 'silk';
      case AudioEncoder.silk16:
        return 'silk';
      case AudioEncoder.silk24:
        return 'silk';
      case AudioEncoder.silk48:
        return 'silk';
      case AudioEncoder.raw:
        return 'raw';
      case AudioEncoder.avc:
        return 'avc';
      case AudioEncoder.hevc:
        return 'hevc';
      case AudioEncoder.vorbis:
        return 'ogg';
      case AudioEncoder.evrc:
        return 'evrc';
      case AudioEncoder.evrcb:
        return 'evrc';
      case AudioEncoder.evrcwb:
        return 'evrc';
      case AudioEncoder.evrcnw:
        return 'evrc';
      case AudioEncoder.aacLd:
        return 'aac';
      case AudioEncoder.aacEld:
        return 'aac';
      case AudioEncoder.xheAac:
        return 'aac';
      case AudioEncoder.aptx:
        return 'aptx';
      case AudioEncoder.aptxHd:
        return 'aptx';
      case AudioEncoder.aptxAdaptive:
        return 'aptx';
      case AudioEncoder.aptxTws:
        return 'aptx';
      case AudioEncoder.aptxTwsPlus:
        return 'aptx';
      case AudioEncoder.aptxLossless:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR2:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR3:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR4:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR5:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR6:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR7:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR8:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR9:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR10:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR11:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR12:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR13:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR14:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR15:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR16:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR17:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR18:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR19:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR20:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR21:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR22:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR23:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR24:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR25:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR26:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR27:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR28:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR29:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR30:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR31:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR32:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR33:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR34:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR35:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR36:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR37:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR38:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR39:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR40:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR41:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR42:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR43:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR44:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR45:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR46:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR47:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR48:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR49:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR50:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR51:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR52:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR53:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR54:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR55:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR56:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR57:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR58:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR59:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR60:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR61:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR62:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR63:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR64:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR65:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR66:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR67:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR68:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR69:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR70:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR71:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR72:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR73:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR74:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR75:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR76:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR77:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR78:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR79:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR80:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR81:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR82:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR83:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR84:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR85:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR86:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR87:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR88:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR89:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR90:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR91:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR92:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR93:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR94:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR95:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR96:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR97:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR98:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR99:
        return 'aptx';
      case AudioEncoder.aptxAdaptiveR100:
        return 'aptx';
      default:
        return 'aac';
    }
  }

  /// Start duration timer
  void _startDurationTimer() {
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _recordingDuration = Duration(milliseconds: _recordingDuration.inMilliseconds + 100);
      _durationController.add(_recordingDuration);

      // Check if max duration reached
      if (_recordingDuration >= _maxRecordingDuration) {
        stopRecording();
      }
    });
  }

  /// Stop duration timer
  void _stopDurationTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  /// Start amplitude monitoring
  void _startAmplitudeMonitoring() {
    _amplitudeSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen(
      (amplitude) {
        _currentAmplitude = amplitude.current;
        _amplitudeController.add(_currentAmplitude);
      },
    );
  }

  /// Stop amplitude monitoring
  void _stopAmplitudeMonitoring() {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _currentAmplitude = 0.0;
  }

  /// Reset recording state
  void _resetRecordingState() {
    _isRecording = false;
    _isPaused = false;
    _currentRecordingPath = null;
    _recordingDuration = Duration.zero;
    _currentAmplitude = 0.0;
  }

  /// Dispose service
  void dispose() {
    _stopDurationTimer();
    _stopAmplitudeMonitoring();
    _durationController.close();
    _amplitudeController.close();
    _stateController.close();
    _audioRecorder.dispose();
    debugPrint('Audio Recorder Service disposed');
  }
}

// Recording state enum
enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
  canceled,
}

// Custom exceptions
class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
  
  @override
  String toString() => 'PermissionException: $message';
}

class RecordingException implements Exception {
  final String message;
  RecordingException(this.message);
  
  @override
  String toString() => 'RecordingException: $message';
}
