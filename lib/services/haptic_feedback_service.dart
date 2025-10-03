import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class HapticFeedbackService {
  static bool _isEnabled = true;
  
  static bool get isEnabled => _isEnabled;
  
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }
  
  static void light() {
    if (_isEnabled) {
      HapticFeedback.lightImpact();
    }
  }
  
  static void medium() {
    if (_isEnabled) {
      HapticFeedback.mediumImpact();
    }
  }
  
  static void heavy() {
    if (_isEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
  
  static void selection() {
    if (_isEnabled) {
      HapticFeedback.selectionClick();
    }
  }
  
  static void success() {
    if (_isEnabled) {
      HapticFeedback.lightImpact();
    }
  }
  
  static void error() {
    if (_isEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}