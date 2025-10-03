import 'package:flutter/material.dart';
import '../utils/responsive_typography.dart';

class ResponsiveCardSizing {
  // Private constructor to prevent instantiation
  ResponsiveCardSizing._();

  /// Get responsive card dimensions based on screen size
  static CardDimensions getCardDimensions(BuildContext context, {
    CardType type = CardType.profile,
    double? customWidth,
    double? customHeight,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = ResponsiveTypography.getDeviceType(context);
    
    switch (type) {
      case CardType.profile:
        return _getProfileCardDimensions(screenSize, deviceType);
      case CardType.match:
        return _getMatchCardDimensions(screenSize, deviceType);
      case CardType.chat:
        return _getChatCardDimensions(screenSize, deviceType);
      case CardType.settings:
        return _getSettingsCardDimensions(screenSize, deviceType);
      case CardType.custom:
        return CardDimensions(
          width: customWidth ?? screenSize.width * 0.9,
          height: customHeight ?? screenSize.height * 0.3,
        );
    }
  }

  static CardDimensions _getProfileCardDimensions(Size screenSize, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return CardDimensions(
          width: screenSize.width * 0.85,
          height: screenSize.height * 0.6,
        );
      case DeviceType.mediumPhone:
        return CardDimensions(
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.65,
        );
      case DeviceType.largePhone:
        return CardDimensions(
          width: screenSize.width * 0.9,
          height: screenSize.height * 0.7,
        );
      case DeviceType.tablet:
        return CardDimensions(
          width: 400,
          height: 600,
        );
      case DeviceType.desktop:
        return CardDimensions(
          width: 450,
          height: 650,
        );
    }
  }

  static CardDimensions _getMatchCardDimensions(Size screenSize, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return CardDimensions(
          width: screenSize.width * 0.8,
          height: screenSize.height * 0.4,
        );
      case DeviceType.mediumPhone:
        return CardDimensions(
          width: screenSize.width * 0.85,
          height: screenSize.height * 0.45,
        );
      case DeviceType.largePhone:
        return CardDimensions(
          width: screenSize.width * 0.85,
          height: screenSize.height * 0.5,
        );
      case DeviceType.tablet:
        return CardDimensions(
          width: 350,
          height: 450,
        );
      case DeviceType.desktop:
        return CardDimensions(
          width: 400,
          height: 500,
        );
    }
  }

  static CardDimensions _getChatCardDimensions(Size screenSize, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return CardDimensions(
          width: screenSize.width,
          height: 80,
        );
      case DeviceType.mediumPhone:
        return CardDimensions(
          width: screenSize.width,
          height: 90,
        );
      case DeviceType.largePhone:
        return CardDimensions(
          width: screenSize.width,
          height: 100,
        );
      case DeviceType.tablet:
        return CardDimensions(
          width: screenSize.width,
          height: 110,
        );
      case DeviceType.desktop:
        return CardDimensions(
          width: screenSize.width,
          height: 120,
        );
    }
  }

  static CardDimensions _getSettingsCardDimensions(Size screenSize, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return CardDimensions(
          width: screenSize.width * 0.9,
          height: 60,
        );
      case DeviceType.mediumPhone:
        return CardDimensions(
          width: screenSize.width * 0.9,
          height: 70,
        );
      case DeviceType.largePhone:
        return CardDimensions(
          width: screenSize.width * 0.9,
          height: 80,
        );
      case DeviceType.tablet:
        return CardDimensions(
          width: screenSize.width * 0.8,
          height: 90,
        );
      case DeviceType.desktop:
        return CardDimensions(
          width: screenSize.width * 0.7,
          height: 100,
        );
    }
  }

  /// Get responsive padding for cards
  static EdgeInsets getCardPadding(BuildContext context, {
    CardType type = CardType.profile,
  }) {
    final deviceType = ResponsiveTypography.getDeviceType(context);
    
    switch (type) {
      case CardType.profile:
        return _getProfileCardPadding(deviceType);
      case CardType.match:
        return _getMatchCardPadding(deviceType);
      case CardType.chat:
        return _getChatCardPadding(deviceType);
      case CardType.settings:
        return _getSettingsCardPadding(deviceType);
      case CardType.custom:
        return const EdgeInsets.all(16);
    }
  }

  static EdgeInsets _getProfileCardPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.all(12);
      case DeviceType.mediumPhone:
        return const EdgeInsets.all(16);
      case DeviceType.largePhone:
        return const EdgeInsets.all(20);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(28);
    }
  }

  static EdgeInsets _getMatchCardPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.all(8);
      case DeviceType.mediumPhone:
        return const EdgeInsets.all(12);
      case DeviceType.largePhone:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(20);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
    }
  }

  static EdgeInsets _getChatCardPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case DeviceType.mediumPhone:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case DeviceType.largePhone:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  static EdgeInsets _getSettingsCardPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case DeviceType.mediumPhone:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case DeviceType.largePhone:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
    }
  }

  /// Get responsive margin for cards
  static EdgeInsets getCardMargin(BuildContext context, {
    CardType type = CardType.profile,
  }) {
    final deviceType = ResponsiveTypography.getDeviceType(context);
    
    switch (type) {
      case CardType.profile:
        return _getProfileCardMargin(deviceType);
      case CardType.match:
        return _getMatchCardMargin(deviceType);
      case CardType.chat:
        return _getChatCardMargin(deviceType);
      case CardType.settings:
        return _getSettingsCardMargin(deviceType);
      case CardType.custom:
        return const EdgeInsets.all(8);
    }
  }

  static EdgeInsets _getProfileCardMargin(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.all(8);
      case DeviceType.mediumPhone:
        return const EdgeInsets.all(12);
      case DeviceType.largePhone:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(20);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
    }
  }

  static EdgeInsets _getMatchCardMargin(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.all(4);
      case DeviceType.mediumPhone:
        return const EdgeInsets.all(6);
      case DeviceType.largePhone:
        return const EdgeInsets.all(8);
      case DeviceType.tablet:
        return const EdgeInsets.all(10);
      case DeviceType.desktop:
        return const EdgeInsets.all(12);
    }
  }

  static EdgeInsets _getChatCardMargin(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case DeviceType.mediumPhone:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case DeviceType.largePhone:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  static EdgeInsets _getSettingsCardMargin(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case DeviceType.mediumPhone:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case DeviceType.largePhone:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  /// Get responsive border radius for cards
  static double getCardBorderRadius(BuildContext context, {
    CardType type = CardType.profile,
  }) {
    final deviceType = ResponsiveTypography.getDeviceType(context);
    
    switch (type) {
      case CardType.profile:
        return _getProfileCardBorderRadius(deviceType);
      case CardType.match:
        return _getMatchCardBorderRadius(deviceType);
      case CardType.chat:
        return _getChatCardBorderRadius(deviceType);
      case CardType.settings:
        return _getSettingsCardBorderRadius(deviceType);
      case CardType.custom:
        return 12;
    }
  }

  static double _getProfileCardBorderRadius(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 16;
      case DeviceType.mediumPhone:
        return 18;
      case DeviceType.largePhone:
        return 20;
      case DeviceType.tablet:
        return 22;
      case DeviceType.desktop:
        return 24;
    }
  }

  static double _getMatchCardBorderRadius(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 12;
      case DeviceType.mediumPhone:
        return 14;
      case DeviceType.largePhone:
        return 16;
      case DeviceType.tablet:
        return 18;
      case DeviceType.desktop:
        return 20;
    }
  }

  static double _getChatCardBorderRadius(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 8;
      case DeviceType.mediumPhone:
        return 10;
      case DeviceType.largePhone:
        return 12;
      case DeviceType.tablet:
        return 14;
      case DeviceType.desktop:
        return 16;
    }
  }

  static double _getSettingsCardBorderRadius(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 8;
      case DeviceType.mediumPhone:
        return 10;
      case DeviceType.largePhone:
        return 12;
      case DeviceType.tablet:
        return 14;
      case DeviceType.desktop:
        return 16;
    }
  }
}

enum CardType {
  profile,
  match,
  chat,
  settings,
  custom,
}

class CardDimensions {
  final double width;
  final double height;

  const CardDimensions({
    required this.width,
    required this.height,
  });
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final CardType type;
  final double? customWidth;
  final double? customHeight;
  final EdgeInsets? customPadding;
  final EdgeInsets? customMargin;
  final double? customBorderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.type = CardType.custom,
    this.customWidth,
    this.customHeight,
    this.customPadding,
    this.customMargin,
    this.customBorderRadius,
    this.backgroundColor,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimensions = ResponsiveCardSizing.getCardDimensions(
      context,
      type: type,
      customWidth: customWidth,
      customHeight: customHeight,
    );
    
    final padding = customPadding ?? ResponsiveCardSizing.getCardPadding(context, type: type);
    final margin = customMargin ?? ResponsiveCardSizing.getCardMargin(context, type: type);
    final borderRadius = customBorderRadius ?? ResponsiveCardSizing.getCardBorderRadius(context, type: type);

    return Container(
      width: dimensions.width,
      height: dimensions.height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
