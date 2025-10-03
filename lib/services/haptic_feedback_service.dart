import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class HapticFeedbackService {
  static bool _isEnabled = true;
  static double _intensity = 1.0;
  static Duration _cooldownDuration = const Duration(milliseconds: 100);
  static DateTime? _lastFeedbackTime;
  
  static bool get isEnabled => _isEnabled;
  static double get intensity => _intensity;
  static Duration get cooldownDuration => _cooldownDuration;
  
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  static void setIntensity(double intensity) {
    _intensity = intensity.clamp(0.0, 1.0);
  }

  static void setCooldownDuration(Duration duration) {
    _cooldownDuration = duration;
  }

  static bool _shouldTriggerFeedback() {
    if (!_isEnabled) return false;
    
    final now = DateTime.now();
    if (_lastFeedbackTime != null && 
        now.difference(_lastFeedbackTime!) < _cooldownDuration) {
      return false;
    }
    
    _lastFeedbackTime = now;
    return true;
  }
  
  static void light() {
    if (!_shouldTriggerFeedback()) return;
    
    if (_intensity > 0.5) {
      HapticFeedback.lightImpact();
    }
  }
  
  static void medium() {
    if (!_shouldTriggerFeedback()) return;
    
    if (_intensity > 0.3) {
      HapticFeedback.mediumImpact();
    }
  }
  
  static void heavy() {
    if (!_shouldTriggerFeedback()) return;
    
    HapticFeedback.heavyImpact();
  }
  
  static void selection() {
    if (!_shouldTriggerFeedback()) return;
    
    HapticFeedback.selectionClick();
  }
  
  static void success() {
    if (!_shouldTriggerFeedback()) return;
    
    HapticFeedback.lightImpact();
  }
  
  static void error() {
    if (!_shouldTriggerFeedback()) return;
    
    HapticFeedback.heavyImpact();
  }

  static void vibrate() {
    if (!_shouldTriggerFeedback()) return;
    
    HapticFeedback.vibrate();
  }

  static void customFeedback(HapticFeedbackType type) {
    if (!_shouldTriggerFeedback()) return;
    
    switch (type) {
      case HapticFeedbackType.buttonPress:
        light();
        break;
      case HapticFeedbackType.buttonRelease:
        selection();
        break;
      case HapticFeedbackType.swipe:
        medium();
        break;
      case HapticFeedbackType.match:
        heavy();
        break;
      case HapticFeedbackType.error:
        heavy();
        break;
      case HapticFeedbackType.success:
        medium();
        break;
      case HapticFeedbackType.notification:
        light();
        break;
      case HapticFeedbackType.toggle:
        selection();
        break;
    }
  }

  static void buttonPress() {
    customFeedback(HapticFeedbackType.buttonPress);
  }

  static void buttonRelease() {
    customFeedback(HapticFeedbackType.buttonRelease);
  }

  static void swipeLeft() {
    customFeedback(HapticFeedbackType.swipe);
  }

  static void swipeRight() {
    customFeedback(HapticFeedbackType.swipe);
  }

  static void swipeUp() {
    customFeedback(HapticFeedbackType.swipe);
  }

  static void matchFound() {
    customFeedback(HapticFeedbackType.match);
  }

  static void superLike() {
    customFeedback(HapticFeedbackType.match);
  }

  static void notification() {
    customFeedback(HapticFeedbackType.notification);
  }

  static void toggle() {
    customFeedback(HapticFeedbackType.toggle);
  }
}

enum HapticFeedbackType {
  buttonPress,
  buttonRelease,
  swipe,
  match,
  error,
  success,
  notification,
  toggle,
}