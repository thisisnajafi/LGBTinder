import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

/// Simplified Audio Recorder Service for voice messaging
class AudioRecorderService {
  static final AudioRecorder _recorder = AudioRecorder();
  
  static bool _isRecording = false;
  static String? _recordingPath;

  /// Check if recording is currently in progress
  static bool get isRecording => _isRecording;

  /// Get the current recording path
  static String? get recordingPath => _recordingPath;

  /// Start recording audio
  static Future<bool> startRecording() async {
    try {
      if (_isRecording) return false;

      // Check if recording is permitted
      if (!await _recorder.hasPermission()) {
        if (kDebugMode) {
          print('Audio recording permission not granted');
        }
        return false;
      }

      // Get temp directory for recording
      final directory = await getTemporaryDirectory();
      _recordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording with basic config
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );

      _isRecording = true;
      return true;

    } catch (e) {
      if (kDebugMode) {
        print('Error starting audio recording: $e');
      }
      return false;
    }
  }

  /// Stop recording and return the file path
  static Future<String?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      final path = await _recorder.stop();
      _isRecording = false;

      if (recordingPath != null) {
        _recordingPath = recordingPath;
        return path;
      }

      return null;

    } catch (e) {
      if (kDebugMode) {
        print('Error stopping audio recording: $e');
      }
      _isRecording = false;
      return null;
    }
  }

  /// Cancel the current recording
  static Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.cancel();
        _isRecording = false;
        _recordingPath = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling audio recording: $e');
      }
    }
  }

  /// Get recording duration in seconds
  static Future<int> getDuration() async {
    try {
      // Return mock duration for now
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recording duration: $e');
      }
      return 0;
    }
  }

  /// Check if device supports recording
  static Future<bool> isSupported() async {
    try {
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: 'temp');
      await _recorder.stop();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose of the recorder
  static Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing audio recorder: $e');
      }
    }
  }

  /// Get amplifier level for visualization
  static Stream<double> getAmplitude() {
    // Return mock stream for now
    return Stream.periodic(Duration(milliseconds: 100), (count) => 0.0);
  }

  /// Get recording stream for monitoring
  static Stream<Duration> getRecordingStream() {
    // Return mock stream for now
    return Stream.periodic(Duration(seconds: 1), (count) => Duration(seconds: count));
  }
}