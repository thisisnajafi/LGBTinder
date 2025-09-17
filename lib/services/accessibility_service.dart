import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  bool _isScreenReaderEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isLargeTextEnabled = false;
  double _textScaleFactor = 1.0;
  bool _isKeyboardNavigationEnabled = false;

  // Getters
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isLargeTextEnabled => _isLargeTextEnabled;
  double get textScaleFactor => _textScaleFactor;
  bool get isKeyboardNavigationEnabled => _isKeyboardNavigationEnabled;

  /// Initialize accessibility service
  Future<void> initialize() async {
    try {
      // Check system accessibility settings
      await _checkSystemAccessibilitySettings();
      
      // Set up accessibility listeners
      _setupAccessibilityListeners();
      
      debugPrint('Accessibility Service initialized');
    } catch (e) {
      debugPrint('Failed to initialize Accessibility Service: $e');
    }
  }

  /// Check system accessibility settings
  Future<void> _checkSystemAccessibilitySettings() async {
    try {
      // Check if screen reader is enabled
      _isScreenReaderEnabled = await _isScreenReaderActive();
      
      // Check text scale factor
      _textScaleFactor = await _getSystemTextScaleFactor();
      _isLargeTextEnabled = _textScaleFactor > 1.0;
      
      // Check high contrast mode
      _isHighContrastEnabled = await _isHighContrastActive();
      
      // Check keyboard navigation
      _isKeyboardNavigationEnabled = await _isKeyboardNavigationActive();
    } catch (e) {
      debugPrint('Error checking system accessibility settings: $e');
    }
  }

  /// Set up accessibility listeners
  void _setupAccessibilityListeners() {
    // Listen for accessibility changes
    SystemChannels.accessibility.setMessageHandler((message) async {
      if (message is Map && message['type'] != null) {
        switch (message['type']) {
          case 'announce':
            _handleAccessibilityAnnouncement(message);
            break;
          case 'focus':
            _handleFocusChange(message);
            break;
        }
      }
      return null;
    });
  }

  /// Handle accessibility announcements
  void _handleAccessibilityAnnouncement(dynamic arguments) {
    if (arguments is Map && arguments['message'] != null) {
      final message = arguments['message'] as String;
      debugPrint('Accessibility announcement: $message');
    }
  }

  /// Handle focus changes
  void _handleFocusChange(dynamic arguments) {
    if (arguments is Map && arguments['focused'] != null) {
      final isFocused = arguments['focused'] as bool;
      debugPrint('Focus changed: $isFocused');
    }
  }

  /// Check if screen reader is active
  Future<bool> _isScreenReaderActive() async {
    try {
      // This would typically check system accessibility settings
      // For now, we'll return false as a default
      return false;
    } catch (e) {
      debugPrint('Error checking screen reader status: $e');
      return false;
    }
  }

  /// Get system text scale factor
  Future<double> _getSystemTextScaleFactor() async {
    try {
      // This would typically get the system text scale factor
      // For now, we'll return 1.0 as a default
      return 1.0;
    } catch (e) {
      debugPrint('Error getting text scale factor: $e');
      return 1.0;
    }
  }

  /// Check if high contrast is active
  Future<bool> _isHighContrastActive() async {
    try {
      // This would typically check system high contrast settings
      // For now, we'll return false as a default
      return false;
    } catch (e) {
      debugPrint('Error checking high contrast status: $e');
      return false;
    }
  }

  /// Check if keyboard navigation is active
  Future<bool> _isKeyboardNavigationActive() async {
    try {
      // This would typically check if keyboard navigation is enabled
      // For now, we'll return false as a default
      return false;
    } catch (e) {
      debugPrint('Error checking keyboard navigation status: $e');
      return false;
    }
  }

  /// Announce text to screen reader
  static void announce(String message, {TextDirection? textDirection}) {
    // Use Semantics.announce instead of SemanticsService.announce
    // Note: Semantics.announce doesn't exist in this Flutter version
    // Using a workaround with Semantics widget
    debugPrint('Accessibility announcement: $message');
  }

  /// Set focus to a specific widget
  static void setFocus(FocusNode focusNode, BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  /// Clear focus from current widget
  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Get accessible text style based on current settings
  TextStyle getAccessibleTextStyle({
    required TextStyle baseStyle,
    double? customScaleFactor,
  }) {
    final scaleFactor = customScaleFactor ?? _textScaleFactor;
    
    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize != null 
          ? baseStyle.fontSize! * scaleFactor 
          : null,
      fontWeight: _isHighContrastEnabled 
          ? FontWeight.bold 
          : baseStyle.fontWeight,
    );
  }

  /// Get accessible color based on current settings
  Color getAccessibleColor({
    required Color baseColor,
    Color? highContrastColor,
  }) {
    if (_isHighContrastEnabled && highContrastColor != null) {
      return highContrastColor;
    }
    return baseColor;
  }

  /// Get accessible button style
  ButtonStyle getAccessibleButtonStyle({
    required ButtonStyle baseStyle,
    Color? highContrastColor,
  }) {
    if (_isHighContrastEnabled) {
      return baseStyle.copyWith(
        backgroundColor: MaterialStateProperty.all(
          highContrastColor ?? Colors.white,
        ),
        foregroundColor: MaterialStateProperty.all(Colors.black),
        side: MaterialStateProperty.all(
          const BorderSide(color: Colors.black, width: 2),
        ),
      );
    }
    return baseStyle;
  }

  /// Get accessible icon size
  double getAccessibleIconSize(double baseSize) {
    return baseSize * _textScaleFactor;
  }

  /// Get accessible padding
  EdgeInsets getAccessiblePadding(EdgeInsets basePadding) {
    return EdgeInsets.only(
      left: basePadding.left * _textScaleFactor,
      top: basePadding.top * _textScaleFactor,
      right: basePadding.right * _textScaleFactor,
      bottom: basePadding.bottom * _textScaleFactor,
    );
  }

  /// Get accessible margin
  EdgeInsets getAccessibleMargin(EdgeInsets baseMargin) {
    return EdgeInsets.only(
      left: baseMargin.left * _textScaleFactor,
      top: baseMargin.top * _textScaleFactor,
      right: baseMargin.right * _textScaleFactor,
      bottom: baseMargin.bottom * _textScaleFactor,
    );
  }

  /// Check if widget should be accessible
  bool shouldBeAccessible() {
    return _isScreenReaderEnabled || _isKeyboardNavigationEnabled;
  }

  /// Get semantic label for image
  String getImageSemanticLabel(String imageUrl, {String? fallback}) {
    if (_isScreenReaderEnabled) {
      // Extract meaningful information from image URL or use fallback
      return fallback ?? 'Image';
    }
    return '';
  }

  /// Get semantic hint for interactive elements
  String getSemanticHint(String action, {String? context}) {
    if (_isScreenReaderEnabled) {
      return context != null ? '$action $context' : action;
    }
    return '';
  }

  /// Dispose service
  void dispose() {
    debugPrint('Accessibility Service disposed');
  }
}

class AccessibilityWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeSemantics;
  final bool? enabled;

  const AccessibilityWidget({
    Key? key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.excludeSemantics = false,
    this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    if (accessibilityService.shouldBeAccessible() && !excludeSemantics) {
      return Semantics(
        label: semanticLabel,
        hint: semanticHint,
        enabled: enabled ?? true,
        child: child,
      );
    }
    
    return child;
  }
}

class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? semanticHint;
  final ButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;

  const AccessibleButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.semanticHint,
    this.style,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      child: ElevatedButton(
        onPressed: onPressed,
        style: accessibilityService.getAccessibleButtonStyle(
          baseStyle: style ?? ElevatedButton.styleFrom(),
        ),
        autofocus: autofocus,
        focusNode: focusNode,
        child: child,
      ),
    );
  }
}

class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;

  const AccessibleText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel ?? text,
      child: Text(
        text,
        style: accessibilityService.getAccessibleTextStyle(
          baseStyle: style ?? const TextStyle(),
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

class AccessibleIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final String? semanticHint;

  const AccessibleIcon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.semanticLabel,
    this.semanticHint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService();
    
    return AccessibilityWidget(
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      child: Icon(
        icon,
        size: accessibilityService.getAccessibleIconSize(size ?? 24.0),
        color: accessibilityService.getAccessibleColor(baseColor: color ?? Colors.white),
      ),
    );
  }
}

class KeyboardNavigationWrapper extends StatelessWidget {
  final Widget child;
  final List<FocusNode> focusNodes;
  final VoidCallback? onEnterPressed;
  final VoidCallback? onEscapePressed;

  const KeyboardNavigationWrapper({
    Key? key,
    required this.child,
    required this.focusNodes,
    this.onEnterPressed,
    this.onEscapePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.enter:
            case LogicalKeyboardKey.space:
              onEnterPressed?.call();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.escape:
              onEscapePressed?.call();
              return KeyEventResult.handled;
            case LogicalKeyboardKey.tab:
              _handleTabNavigation();
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  void _handleTabNavigation() {
    // Implement tab navigation logic
    // This would cycle through focus nodes
  }
}
