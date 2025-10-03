import 'package:flutter/material.dart';
import '../utils/responsive_typography.dart';

class ButtonLayoutManager {
  // Private constructor to prevent instantiation
  ButtonLayoutManager._();

  /// Get responsive button spacing based on screen size and context
  static EdgeInsets getButtonSpacing(BuildContext context, {
    ButtonLayoutType type = ButtonLayoutType.vertical,
    ButtonSpacing spacing = ButtonSpacing.medium,
  }) {
    final deviceType = ResponsiveTypography.getDeviceType(context);
    
    switch (type) {
      case ButtonLayoutType.vertical:
        return _getVerticalSpacing(deviceType, spacing);
      case ButtonLayoutType.horizontal:
        return _getHorizontalSpacing(deviceType, spacing);
      case ButtonLayoutType.grid:
        return _getGridSpacing(deviceType, spacing);
      case ButtonLayoutType.floating:
        return _getFloatingSpacing(deviceType, spacing);
    }
  }

  static EdgeInsets _getVerticalSpacing(DeviceType deviceType, ButtonSpacing spacing) {
    final baseSpacing = _getBaseSpacing(deviceType, spacing);
    return EdgeInsets.symmetric(vertical: baseSpacing);
  }

  static EdgeInsets _getHorizontalSpacing(DeviceType deviceType, ButtonSpacing spacing) {
    final baseSpacing = _getBaseSpacing(deviceType, spacing);
    return EdgeInsets.symmetric(horizontal: baseSpacing);
  }

  static EdgeInsets _getGridSpacing(DeviceType deviceType, ButtonSpacing spacing) {
    final baseSpacing = _getBaseSpacing(deviceType, spacing);
    return EdgeInsets.all(baseSpacing);
  }

  static EdgeInsets _getFloatingSpacing(DeviceType deviceType, ButtonSpacing spacing) {
    final baseSpacing = _getBaseSpacing(deviceType, spacing);
    return EdgeInsets.only(
      bottom: baseSpacing * 2,
      right: baseSpacing,
    );
  }

  static double _getBaseSpacing(DeviceType deviceType, ButtonSpacing spacing) {
    final spacingMultiplier = _getSpacingMultiplier(spacing);
    
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 8.0 * spacingMultiplier;
      case DeviceType.mediumPhone:
        return 12.0 * spacingMultiplier;
      case DeviceType.largePhone:
        return 16.0 * spacingMultiplier;
      case DeviceType.tablet:
        return 20.0 * spacingMultiplier;
      case DeviceType.desktop:
        return 24.0 * spacingMultiplier;
    }
  }

  static double _getSpacingMultiplier(ButtonSpacing spacing) {
    switch (spacing) {
      case ButtonSpacing.tight:
        return 0.5;
      case ButtonSpacing.small:
        return 0.75;
      case ButtonSpacing.medium:
        return 1.0;
      case ButtonSpacing.large:
        return 1.5;
      case ButtonSpacing.loose:
        return 2.0;
    }
  }

  /// Get responsive button alignment based on context
  static MainAxisAlignment getButtonAlignment(BuildContext context, {
    ButtonAlignment alignment = ButtonAlignment.center,
    int buttonCount = 1,
  }) {
    switch (alignment) {
      case ButtonAlignment.start:
        return MainAxisAlignment.start;
      case ButtonAlignment.center:
        return MainAxisAlignment.center;
      case ButtonAlignment.end:
        return MainAxisAlignment.end;
      case ButtonAlignment.spaceBetween:
        return MainAxisAlignment.spaceBetween;
      case ButtonAlignment.spaceEvenly:
        return MainAxisAlignment.spaceEvenly;
      case ButtonAlignment.spaceAround:
        return MainAxisAlignment.spaceAround;
      case ButtonAlignment.adaptive:
        return _getAdaptiveAlignment(context, buttonCount);
    }
  }

  static MainAxisAlignment _getAdaptiveAlignment(BuildContext context, int buttonCount) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (buttonCount == 1) {
      return MainAxisAlignment.center;
    } else if (buttonCount == 2) {
      return screenWidth < 600 ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center;
    } else {
      return screenWidth < 600 ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceBetween;
    }
  }

  /// Get responsive button size based on context
  static ButtonSize getResponsiveButtonSize(BuildContext context, {
    ButtonSize? preferredSize,
  }) {
    final deviceType = ResponsiveTypography.getDeviceType(context);
    
    if (preferredSize != null) return preferredSize;
    
    switch (deviceType) {
      case DeviceType.smallPhone:
        return ButtonSize.small;
      case DeviceType.mediumPhone:
        return ButtonSize.medium;
      case DeviceType.largePhone:
        return ButtonSize.medium;
      case DeviceType.tablet:
        return ButtonSize.large;
      case DeviceType.desktop:
        return ButtonSize.large;
    }
  }

  /// Get responsive button width constraints
  static BoxConstraints getButtonConstraints(BuildContext context, {
    ButtonWidth width = ButtonWidth.auto,
    double? customWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    switch (width) {
      case ButtonWidth.auto:
        return const BoxConstraints();
      case ButtonWidth.fill:
        return BoxConstraints(
          minWidth: screenWidth * 0.8,
          maxWidth: screenWidth * 0.95,
        );
      case ButtonWidth.half:
        return BoxConstraints(
          minWidth: screenWidth * 0.4,
          maxWidth: screenWidth * 0.5,
        );
      case ButtonWidth.third:
        return BoxConstraints(
          minWidth: screenWidth * 0.25,
          maxWidth: screenWidth * 0.35,
        );
      case ButtonWidth.custom:
        return BoxConstraints(
          minWidth: customWidth ?? 200,
          maxWidth: customWidth ?? 300,
        );
    }
  }

  /// Get responsive button padding
  static EdgeInsets getButtonPadding(BuildContext context, {
    ButtonSize size = ButtonSize.medium,
    ButtonPadding padding = ButtonPadding.normal,
  }) {
    final deviceType = ResponsiveTypography.getDeviceType(context);
    final basePadding = _getBasePadding(deviceType, size);
    final paddingMultiplier = _getPaddingMultiplier(padding);
    
    return EdgeInsets.all(basePadding * paddingMultiplier);
  }

  static double _getBasePadding(DeviceType deviceType, ButtonSize size) {
    final sizeMultiplier = _getSizeMultiplier(size);
    
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 8.0 * sizeMultiplier;
      case DeviceType.mediumPhone:
        return 12.0 * sizeMultiplier;
      case DeviceType.largePhone:
        return 16.0 * sizeMultiplier;
      case DeviceType.tablet:
        return 20.0 * sizeMultiplier;
      case DeviceType.desktop:
        return 24.0 * sizeMultiplier;
    }
  }

  static double _getSizeMultiplier(ButtonSize size) {
    switch (size) {
      case ButtonSize.small:
        return 0.75;
      case ButtonSize.medium:
        return 1.0;
      case ButtonSize.large:
        return 1.25;
    }
  }

  static double _getPaddingMultiplier(ButtonPadding padding) {
    switch (padding) {
      case ButtonPadding.tight:
        return 0.5;
      case ButtonPadding.normal:
        return 1.0;
      case ButtonPadding.loose:
        return 1.5;
    }
  }
}

enum ButtonLayoutType {
  vertical,
  horizontal,
  grid,
  floating,
}

enum ButtonSpacing {
  tight,
  small,
  medium,
  large,
  loose,
}

enum ButtonAlignment {
  start,
  center,
  end,
  spaceBetween,
  spaceEvenly,
  spaceAround,
  adaptive,
}

enum ButtonWidth {
  auto,
  fill,
  half,
  third,
  custom,
}

enum ButtonPadding {
  tight,
  normal,
  loose,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class ResponsiveButtonLayout extends StatelessWidget {
  final List<Widget> buttons;
  final ButtonLayoutType layoutType;
  final ButtonSpacing spacing;
  final ButtonAlignment alignment;
  final ButtonWidth width;
  final double? customWidth;
  final EdgeInsets? padding;
  final MainAxisSize mainAxisSize;

  const ResponsiveButtonLayout({
    Key? key,
    required this.buttons,
    this.layoutType = ButtonLayoutType.vertical,
    this.spacing = ButtonSpacing.medium,
    this.alignment = ButtonAlignment.center,
    this.width = ButtonWidth.auto,
    this.customWidth,
    this.padding,
    this.mainAxisSize = MainAxisSize.min,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonSpacing = ButtonLayoutManager.getButtonSpacing(
      context,
      type: layoutType,
      spacing: spacing,
    );
    
    final buttonAlignment = ButtonLayoutManager.getButtonAlignment(
      context,
      alignment: alignment,
      buttonCount: buttons.length,
    );

    Widget layout;
    
    switch (layoutType) {
      case ButtonLayoutType.vertical:
        layout = Column(
          mainAxisAlignment: buttonAlignment,
          mainAxisSize: mainAxisSize,
          children: _buildVerticalButtons(buttonSpacing),
        );
        break;
      case ButtonLayoutType.horizontal:
        layout = Row(
          mainAxisAlignment: buttonAlignment,
          mainAxisSize: mainAxisSize,
          children: _buildHorizontalButtons(buttonSpacing),
        );
        break;
      case ButtonLayoutType.grid:
        layout = Wrap(
          alignment: WrapAlignment.center,
          spacing: buttonSpacing.horizontal,
          runSpacing: buttonSpacing.vertical,
          children: buttons,
        );
        break;
      case ButtonLayoutType.floating:
        layout = Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _buildFloatingButtons(buttonSpacing),
        );
        break;
    }

    return Container(
      padding: padding,
      child: layout,
    );
  }

  List<Widget> _buildVerticalButtons(EdgeInsets spacing) {
    final List<Widget> spacedButtons = [];
    
    for (int i = 0; i < buttons.length; i++) {
      spacedButtons.add(buttons[i]);
      if (i < buttons.length - 1) {
        spacedButtons.add(SizedBox(height: spacing.vertical));
      }
    }
    
    return spacedButtons;
  }

  List<Widget> _buildHorizontalButtons(EdgeInsets spacing) {
    final List<Widget> spacedButtons = [];
    
    for (int i = 0; i < buttons.length; i++) {
      spacedButtons.add(buttons[i]);
      if (i < buttons.length - 1) {
        spacedButtons.add(SizedBox(width: spacing.horizontal));
      }
    }
    
    return spacedButtons;
  }

  List<Widget> _buildFloatingButtons(EdgeInsets spacing) {
    return buttons.map((button) {
      return Container(
        margin: EdgeInsets.only(bottom: spacing.vertical),
        child: button,
      );
    }).toList();
  }
}

class ButtonGroup extends StatelessWidget {
  final List<Widget> buttons;
  final ButtonLayoutType layoutType;
  final ButtonSpacing spacing;
  final ButtonAlignment alignment;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const ButtonGroup({
    Key? key,
    required this.buttons,
    this.layoutType = ButtonLayoutType.vertical,
    this.spacing = ButtonSpacing.medium,
    this.alignment = ButtonAlignment.center,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ResponsiveButtonLayout(
        buttons: buttons,
        layoutType: layoutType,
        spacing: spacing,
        alignment: alignment,
      ),
    );
  }
}
