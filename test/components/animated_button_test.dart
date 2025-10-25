import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lgbtinder/components/animations/animated_components.dart';

void main() {
  group('AnimatedButton Widget Tests', () {
    testWidgets('should render button with text', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Test Button';
      var tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {
                tapped = true;
              },
              animationType: AnimationType.scale,
              child: const Text(buttonText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(tapped, false);
    });

    testWidgets('should trigger onPressed callback when tapped', (WidgetTester tester) async {
      // Arrange
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {
                tapped = true;
              },
              animationType: AnimationType.scale,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      // Assert
      expect(tapped, true);
    });

    testWidgets('should not trigger callback when onPressed is null', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: null,
              animationType: AnimationType.scale,
              child: const Text('Disabled Button'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Disabled Button'), findsOneWidget);
      
      // Try to tap (should not throw)
      await tester.tap(find.text('Disabled Button'));
      await tester.pump();
    });

    testWidgets('should render with different animation types', (WidgetTester tester) async {
      // Test scale animation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {},
              animationType: AnimationType.scale,
              child: const Text('Scale'),
            ),
          ),
        ),
      );
      expect(find.text('Scale'), findsOneWidget);

      // Test fade animation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {},
              animationType: AnimationType.fade,
              child: const Text('Fade'),
            ),
          ),
        ),
      );
      expect(find.text('Fade'), findsOneWidget);

      // Test slide animation
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {},
              animationType: AnimationType.slide,
              child: const Text('Slide'),
            ),
          ),
        ),
      );
      expect(find.text('Slide'), findsOneWidget);
    });

    testWidgets('should apply custom style', (WidgetTester tester) async {
      // Arrange
      final customStyle = ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {},
              animationType: AnimationType.scale,
              style: customStyle,
              child: const Text('Styled Button'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Styled Button'), findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(elevatedButton.style, customStyle);
    });

    testWidgets('should render with icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedButton(
              onPressed: () {},
              animationType: AnimationType.scale,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star),
                  SizedBox(width: 8),
                  Text('With Icon'),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });
  });
}

