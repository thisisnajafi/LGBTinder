import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticFeedbackService {
  static final HapticFeedbackService _instance = HapticFeedbackService._internal();
  factory HapticFeedbackService() => _instance;
  HapticFeedbackService._internal();

  // Haptic feedback settings
  bool _isEnabled = true;
  bool _isLightEnabled = true;
  bool _isMediumEnabled = true;
  bool _isHeavyEnabled = true;
  bool _isSelectionEnabled = true;
  bool _isImpactEnabled = true;
  bool _isNotificationEnabled = true;
  double _intensity = 1.0;
  int _duration = 100;

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isLightEnabled => _isLightEnabled;
  bool get isMediumEnabled => _isMediumEnabled;
  bool get isHeavyEnabled => _isHeavyEnabled;
  bool get isSelectionEnabled => _isSelectionEnabled;
  bool get isImpactEnabled => _isImpactEnabled;
  bool get isNotificationEnabled => _isNotificationEnabled;
  double get intensity => _intensity;
  int get duration => _duration;

  /// Initialize haptic feedback service
  Future<void> initialize() async {
    try {
      // Check if device supports haptic feedback
      final hasVibrator = await Vibration.hasVibrator();
      if (!hasVibrator) {
        debugPrint('Device does not support vibration');
        _isEnabled = false;
        return;
      }

      // Check if device supports custom vibration patterns
      final hasCustomVibrations = await Vibration.hasCustomVibrationsSupport();
      debugPrint('Custom vibrations supported: $hasCustomVibrations');

      debugPrint('Haptic Feedback Service initialized');
    } catch (e) {
      debugPrint('Failed to initialize Haptic Feedback Service: $e');
      _isEnabled = false;
    }
  }

  /// Enable/disable haptic feedback
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Set haptic intensity (0.0 to 1.0)
  void setIntensity(double intensity) {
    _intensity = intensity.clamp(0.0, 1.0);
  }

  /// Set vibration duration in milliseconds
  void setDuration(int duration) {
    _duration = duration.clamp(10, 1000);
  }

  /// Enable/disable specific haptic types
  void setLightEnabled(bool enabled) => _isLightEnabled = enabled;
  void setMediumEnabled(bool enabled) => _isMediumEnabled = enabled;
  void setHeavyEnabled(bool enabled) => _isHeavyEnabled = enabled;
  void setSelectionEnabled(bool enabled) => _isSelectionEnabled = enabled;
  void setImpactEnabled(bool enabled) => _isImpactEnabled = enabled;
  void setNotificationEnabled(bool enabled) => _isNotificationEnabled = enabled;

  /// Light haptic feedback (for subtle interactions)
  Future<void> light() async {
    if (!_isEnabled || !_isLightEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Light haptic feedback error: $e');
    }
  }

  /// Medium haptic feedback (for standard interactions)
  Future<void> medium() async {
    if (!_isEnabled || !_isMediumEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Medium haptic feedback error: $e');
    }
  }

  /// Heavy haptic feedback (for important interactions)
  Future<void> heavy() async {
    if (!_isEnabled || !_isHeavyEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Heavy haptic feedback error: $e');
    }
  }

  /// Selection haptic feedback (for list selections, switches)
  Future<void> selection() async {
    if (!_isEnabled || !_isSelectionEnabled) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Selection haptic feedback error: $e');
    }
  }

  /// Impact haptic feedback (for button presses, taps)
  Future<void> impact() async {
    if (!_isEnabled || !_isImpactEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Impact haptic feedback error: $e');
    }
  }

  /// Notification haptic feedback (for alerts, notifications)
  Future<void> notification() async {
    if (!_isEnabled || !_isNotificationEnabled) return;
    
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('Notification haptic feedback error: $e');
    }
  }

  /// Custom vibration pattern
  Future<void> customPattern(List<int> pattern) async {
    if (!_isEnabled) return;
    
    try {
      await Vibration.vibrate(pattern: pattern);
    } catch (e) {
      debugPrint('Custom pattern haptic feedback error: $e');
    }
  }

  /// Custom vibration with duration
  Future<void> customDuration(int duration) async {
    if (!_isEnabled) return;
    
    try {
      await Vibration.vibrate(duration: duration);
    } catch (e) {
      debugPrint('Custom duration haptic feedback error: $e');
    }
  }

  /// Success haptic feedback (double tap pattern)
  Future<void> success() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 100, 50, 100]);
    } catch (e) {
      debugPrint('Success haptic feedback error: $e');
    }
  }

  /// Error haptic feedback (long vibration)
  Future<void> error() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 200, 100, 200]);
    } catch (e) {
      debugPrint('Error haptic feedback error: $e');
    }
  }

  /// Warning haptic feedback (triple tap pattern)
  Future<void> warning() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 150, 50, 150, 50, 150]);
    } catch (e) {
      debugPrint('Warning haptic feedback error: $e');
    }
  }

  /// Like haptic feedback (quick double tap)
  Future<void> like() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 50, 25, 50]);
    } catch (e) {
      debugPrint('Like haptic feedback error: $e');
    }
  }

  /// Super like haptic feedback (special pattern)
  Future<void> superLike() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 100, 50, 100, 50, 100]);
    } catch (e) {
      debugPrint('Super like haptic feedback error: $e');
    }
  }

  /// Match haptic feedback (celebration pattern)
  Future<void> match() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 200, 100, 200, 100, 200, 100, 200]);
    } catch (e) {
      debugPrint('Match haptic feedback error: $e');
    }
  }

  /// Message sent haptic feedback
  Future<void> messageSent() async {
    if (!_isEnabled) return;
    
    try {
      await light();
    } catch (e) {
      debugPrint('Message sent haptic feedback error: $e');
    }
  }

  /// Message received haptic feedback
  Future<void> messageReceived() async {
    if (!_isEnabled) return;
    
    try {
      await medium();
    } catch (e) {
      debugPrint('Message received haptic feedback error: $e');
    }
  }

  /// Swipe left haptic feedback
  Future<void> swipeLeft() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 80]);
    } catch (e) {
      debugPrint('Swipe left haptic feedback error: $e');
    }
  }

  /// Swipe right haptic feedback
  Future<void> swipeRight() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 80]);
    } catch (e) {
      debugPrint('Swipe right haptic feedback error: $e');
    }
  }

  /// Swipe up haptic feedback
  Future<void> swipeUp() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 80]);
    } catch (e) {
      debugPrint('Swipe up haptic feedback error: $e');
    }
  }

  /// Swipe down haptic feedback
  Future<void> swipeDown() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 80]);
    } catch (e) {
      debugPrint('Swipe down haptic feedback error: $e');
    }
  }

  /// Button press haptic feedback
  Future<void> buttonPress() async {
    if (!_isEnabled) return;
    
    try {
      await impact();
    } catch (e) {
      debugPrint('Button press haptic feedback error: $e');
    }
  }

  /// Toggle switch haptic feedback
  Future<void> toggleSwitch() async {
    if (!_isEnabled) return;
    
    try {
      await selection();
    } catch (e) {
      debugPrint('Toggle switch haptic feedback error: $e');
    }
  }

  /// Slider haptic feedback
  Future<void> sliderChange() async {
    if (!_isEnabled) return;
    
    try {
      await light();
    } catch (e) {
      debugPrint('Slider change haptic feedback error: $e');
    }
  }

  /// Page transition haptic feedback
  Future<void> pageTransition() async {
    if (!_isEnabled) return;
    
    try {
      await light();
    } catch (e) {
      debugPrint('Page transition haptic feedback error: $e');
    }
  }

  /// Refresh haptic feedback
  Future<void> refresh() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 100, 50, 100]);
    } catch (e) {
      debugPrint('Refresh haptic feedback error: $e');
    }
  }

  /// Compress haptic feedback
  Future<void> compress() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 50, 25, 50, 25, 50]);
    } catch (e) {
      debugPrint('Compress haptic feedback error: $e');
    }
  }

  /// Camera haptic feedback
  Future<void> camera() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 100, 50, 100]);
    } catch (e) {
      debugPrint('Camera haptic feedback error: $e');
    }
  }

  /// Gallery haptic feedback
  Future<void> gallery() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 75, 25, 75]);
    } catch (e) {
      debugPrint('Gallery haptic feedback error: $e');
    }
  }

  /// Audio haptic feedback
  Future<void> audio() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 60, 30, 60, 30, 60]);
    } catch (e) {
      debugPrint('Audio haptic feedback error: $e');
    }
  }

  /// File haptic feedback
  Future<void> file() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 80, 40, 80]);
    } catch (e) {
      debugPrint('File haptic feedback error: $e');
    }
  }

  /// Record start haptic feedback
  Future<void> recordStart() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 100, 50, 100]);
    } catch (e) {
      debugPrint('Record start haptic feedback error: $e');
    }
  }

  /// Record pause haptic feedback
  Future<void> recordPause() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 50, 25, 50]);
    } catch (e) {
      debugPrint('Record pause haptic feedback error: $e');
    }
  }

  /// Record resume haptic feedback
  Future<void> recordResume() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 75, 25, 75]);
    } catch (e) {
      debugPrint('Record resume haptic feedback error: $e');
    }
  }

  /// Record stop haptic feedback
  Future<void> recordStop() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 100, 50, 100, 25, 50]);
    } catch (e) {
      debugPrint('Record stop haptic feedback error: $e');
    }
  }

  /// Record cancel haptic feedback
  Future<void> recordCancel() async {
    if (!_isEnabled) return;
    
    try {
      await customPattern([0, 50, 25, 50, 25, 50]);
    } catch (e) {
      debugPrint('Record cancel haptic feedback error: $e');
    }
  }

  /// Loading start haptic feedback
  Future<void> loadingStart() async {
    if (!_isEnabled) return;
    
    try {
      await light();
    } catch (e) {
      debugPrint('Loading start haptic feedback error: $e');
    }
  }

  /// Loading complete haptic feedback
  Future<void> loadingComplete() async {
    if (!_isEnabled) return;
    
    try {
      await medium();
    } catch (e) {
      debugPrint('Loading complete haptic feedback error: $e');
    }
  }

  /// Stop all vibrations
  Future<void> stop() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      debugPrint('Stop vibration error: $e');
    }
  }

  /// Dispose service
  void dispose() {
    debugPrint('Haptic Feedback Service disposed');
  }
}

class HapticButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final HapticType hapticType;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const HapticButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.hapticType = HapticType.buttonPress,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await _triggerHaptic();
        onPressed?.call();
      },
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: foregroundColor),
          child: child,
        ),
      ),
    );
  }

  Future<void> _triggerHaptic() async {
    final hapticService = HapticFeedbackService();
    
    switch (hapticType) {
      case HapticType.light:
        await hapticService.light();
        break;
      case HapticType.medium:
        await hapticService.medium();
        break;
      case HapticType.heavy:
        await hapticService.heavy();
        break;
      case HapticType.selection:
        await hapticService.selection();
        break;
      case HapticType.impact:
        await hapticService.impact();
        break;
      case HapticType.buttonPress:
        await hapticService.buttonPress();
        break;
      case HapticType.toggleSwitch:
        await hapticService.toggleSwitch();
        break;
      case HapticType.sliderChange:
        await hapticService.sliderChange();
        break;
      case HapticType.pageTransition:
        await hapticService.pageTransition();
        break;
      case HapticType.success:
        await hapticService.success();
        break;
      case HapticType.error:
        await hapticService.error();
        break;
      case HapticType.warning:
        await hapticService.warning();
        break;
      case HapticType.like:
        await hapticService.like();
        break;
      case HapticType.superLike:
        await hapticService.superLike();
        break;
      case HapticType.match:
        await hapticService.match();
        break;
      case HapticType.messageSent:
        await hapticService.messageSent();
        break;
      case HapticType.messageReceived:
        await hapticService.messageReceived();
        break;
      case HapticType.swipeLeft:
        await hapticService.swipeLeft();
        break;
      case HapticType.swipeRight:
        await hapticService.swipeRight();
        break;
      case HapticType.swipeUp:
        await hapticService.swipeUp();
        break;
      case HapticType.swipeDown:
        await hapticService.swipeDown();
        break;
      case HapticType.refresh:
        await hapticService.refresh();
        break;
      case HapticType.loadingStart:
        await hapticService.loadingStart();
        break;
      case HapticType.loadingComplete:
        await hapticService.loadingComplete();
        break;
    }
  }
}

enum HapticType {
  light,
  medium,
  heavy,
  selection,
  impact,
  buttonPress,
  toggleSwitch,
  sliderChange,
  pageTransition,
  success,
  error,
  warning,
  like,
  superLike,
  match,
  messageSent,
  messageReceived,
  swipeLeft,
  swipeRight,
  swipeUp,
  swipeDown,
  refresh,
  loadingStart,
  loadingComplete,
}

class HapticSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const HapticSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  State<HapticSwitch> createState() => _HapticSwitchState();
}

class _HapticSwitchState extends State<HapticSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: widget.value,
      onChanged: (value) async {
        await HapticFeedbackService().toggleSwitch();
        widget.onChanged?.call(value);
      },
      activeColor: widget.activeColor,
      inactiveThumbColor: widget.inactiveColor,
    );
  }
}

class HapticSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final Color? activeColor;
  final Color? inactiveColor;

  const HapticSlider({
    Key? key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      min: min,
      max: max,
      onChanged: (value) async {
        await HapticFeedbackService().sliderChange();
        onChanged?.call(value);
      },
      activeColor: activeColor,
      inactiveColor: inactiveColor,
    );
  }
}
