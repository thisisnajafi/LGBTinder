import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing app-wide sound effects
class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  final AudioPlayer _player = AudioPlayer();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _soundEnabledKey = 'sound_effects_enabled';
  static const String _volumeKey = 'sound_effects_volume';
  
  bool _soundEnabled = true;
  double _volume = 0.5;
  bool _isInitialized = false;

  /// Initialize the sound effects service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load saved preferences
      final soundEnabledStr = await _storage.read(key: _soundEnabledKey);
      final volumeStr = await _storage.read(key: _volumeKey);
      
      _soundEnabled = soundEnabledStr != 'false'; // Default to true
      _volume = double.tryParse(volumeStr ?? '0.5') ?? 0.5;
      
      await _player.setVolume(_volume);
      
      _isInitialized = true;
      debugPrint('✅ Sound Effects Service initialized');
    } catch (e) {
      debugPrint('⚠️ Failed to initialize Sound Effects Service: $e');
      _isInitialized = true; // Continue anyway with defaults
    }
  }

  /// Check if sound effects are enabled
  bool get isSoundEnabled => _soundEnabled;

  /// Get current volume
  double get volume => _volume;

  /// Enable or disable sound effects
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storage.write(key: _soundEnabledKey, value: enabled.toString());
    debugPrint('🔊 Sound effects ${enabled ? "enabled" : "disabled"}');
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    await _storage.write(key: _volumeKey, value: _volume.toString());
    debugPrint('🔊 Volume set to $_volume');
  }

  /// Play a sound effect
  Future<void> _playSound(String assetPath) async {
    if (!_soundEnabled || !_isInitialized) return;
    
    try {
      await _player.stop(); // Stop any currently playing sound
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('⚠️ Failed to play sound $assetPath: $e');
    }
  }

  // ==================== MATCH SOUNDS ====================
  
  /// Play match celebration sound
  Future<void> playMatchSound() async {
    debugPrint('🎉 Playing match sound');
    await _playSound('sounds/match.mp3');
  }

  /// Play super like sound
  Future<void> playSuperLikeSound() async {
    debugPrint('⭐ Playing super like sound');
    await _playSound('sounds/superlike.mp3');
  }

  // ==================== SWIPE SOUNDS ====================
  
  /// Play swipe right sound
  Future<void> playSwipeRightSound() async {
    debugPrint('👉 Playing swipe right sound');
    await _playSound('sounds/swipe_right.mp3');
  }

  /// Play swipe left sound
  Future<void> playSwipeLeftSound() async {
    debugPrint('👈 Playing swipe left sound');
    await _playSound('sounds/swipe_left.mp3');
  }

  /// Play swipe up sound (for super like)
  Future<void> playSwipeUpSound() async {
    debugPrint('👆 Playing swipe up sound');
    await _playSound('sounds/swipe_up.mp3');
  }

  // ==================== NOTIFICATION SOUNDS ====================
  
  /// Play new message notification sound
  Future<void> playMessageSound() async {
    debugPrint('💬 Playing message sound');
    await _playSound('sounds/message.mp3');
  }

  /// Play general notification sound
  Future<void> playNotificationSound() async {
    debugPrint('🔔 Playing notification sound');
    await _playSound('sounds/notification.mp3');
  }

  /// Play like notification sound
  Future<void> playLikeSound() async {
    debugPrint('❤️ Playing like sound');
    await _playSound('sounds/like.mp3');
  }

  // ==================== UI SOUNDS ====================
  
  /// Play button click sound
  Future<void> playClickSound() async {
    await _playSound('sounds/click.mp3');
  }

  /// Play success sound
  Future<void> playSuccessSound() async {
    debugPrint('✅ Playing success sound');
    await _playSound('sounds/success.mp3');
  }

  /// Play error sound
  Future<void> playErrorSound() async {
    debugPrint('❌ Playing error sound');
    await _playSound('sounds/error.mp3');
  }

  /// Play whoosh sound (for animations)
  Future<void> playWhooshSound() async {
    await _playSound('sounds/whoosh.mp3');
  }

  // ==================== PROFILE SOUNDS ====================
  
  /// Play profile photo upload sound
  Future<void> playPhotoUploadSound() async {
    debugPrint('📸 Playing photo upload sound');
    await _playSound('sounds/photo_upload.mp3');
  }

  /// Play profile complete sound
  Future<void> playProfileCompleteSound() async {
    debugPrint('✨ Playing profile complete sound');
    await _playSound('sounds/profile_complete.mp3');
  }

  // ==================== TYPING SOUNDS ====================
  
  /// Play typing sound
  Future<void> playTypingSound() async {
    await _playSound('sounds/typing.mp3');
  }

  /// Play send message sound
  Future<void> playSendSound() async {
    debugPrint('📤 Playing send sound');
    await _playSound('sounds/send.mp3');
  }

  // ==================== CALL SOUNDS ====================
  
  /// Play incoming call sound (looped)
  Future<void> playIncomingCallSound() async {
    debugPrint('📞 Playing incoming call sound');
    await _player.setReleaseMode(ReleaseMode.loop);
    await _playSound('sounds/incoming_call.mp3');
  }

  /// Play call connected sound
  Future<void> playCallConnectedSound() async {
    debugPrint('📞 Playing call connected sound');
    await _player.setReleaseMode(ReleaseMode.release);
    await _playSound('sounds/call_connected.mp3');
  }

  /// Play call ended sound
  Future<void> playCallEndedSound() async {
    debugPrint('📞 Playing call ended sound');
    await _player.setReleaseMode(ReleaseMode.release);
    await _playSound('sounds/call_ended.mp3');
  }

  /// Stop all sounds
  Future<void> stopAllSounds() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint('⚠️ Failed to stop sounds: $e');
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    await _player.dispose();
    debugPrint('🔇 Sound Effects Service disposed');
  }
}

