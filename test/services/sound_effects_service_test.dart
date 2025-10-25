import 'package:flutter_test/flutter_test.dart';
import 'package:lgbtinder/services/sound_effects_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundEffectsService', () {
    late SoundEffectsService soundService;

    setUp(() {
      soundService = SoundEffectsService();
    });

    test('should initialize successfully', () async {
      await soundService.initialize();
      expect(soundService.isSoundEnabled, true);
      expect(soundService.volume, greaterThanOrEqualTo(0.0));
      expect(soundService.volume, lessThanOrEqualTo(1.0));
    });

    test('should toggle sound enabled state', () async {
      await soundService.initialize();
      
      final initialState = soundService.isSoundEnabled;
      await soundService.setSoundEnabled(!initialState);
      
      expect(soundService.isSoundEnabled, !initialState);
    });

    test('should set volume within valid range', () async {
      await soundService.initialize();
      
      await soundService.setVolume(0.75);
      expect(soundService.volume, 0.75);
      
      await soundService.setVolume(0.0);
      expect(soundService.volume, 0.0);
      
      await soundService.setVolume(1.0);
      expect(soundService.volume, 1.0);
    });

    test('should clamp volume to valid range', () async {
      await soundService.initialize();
      
      await soundService.setVolume(1.5); // Above max
      expect(soundService.volume, 1.0);
      
      await soundService.setVolume(-0.5); // Below min
      expect(soundService.volume, 0.0);
    });

    test('should not throw when playing sounds', () async {
      await soundService.initialize();
      
      expect(() => soundService.playMatchSound(), returnsNormally);
      expect(() => soundService.playSwipeRightSound(), returnsNormally);
      expect(() => soundService.playSwipeLeftSound(), returnsNormally);
      expect(() => soundService.playSuperLikeSound(), returnsNormally);
      expect(() => soundService.playNotificationSound(), returnsNormally);
    });

    test('should handle playback when sound is disabled', () async {
      await soundService.initialize();
      await soundService.setSoundEnabled(false);
      
      // Should not throw even when disabled
      expect(() => soundService.playMatchSound(), returnsNormally);
    });

    test('should stop all sounds successfully', () async {
      await soundService.initialize();
      
      await soundService.playMatchSound();
      expect(() => soundService.stopAllSounds(), returnsNormally);
    });

    test('should dispose successfully', () async {
      await soundService.initialize();
      expect(() => soundService.dispose(), returnsNormally);
    });
  });
}

