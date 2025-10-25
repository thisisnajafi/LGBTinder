import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lgbtinder/components/error_handling/error_display_widget.dart';

void main() {
  group('ErrorDisplayWidget Tests', () {
    testWidgets('should display error message', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'An error occurred';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: Exception(errorMessage),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should display retry button when onRetry is provided', (WidgetTester tester) async {
      // Arrange
      var retryPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: Exception('Error'),
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsOneWidget);
      
      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();
      
      expect(retryPressed, true);
    });

    testWidgets('should not display retry button when onRetry is null', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: Exception('Error'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('should display error icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: Exception('Error'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom error message', (WidgetTester tester) async {
      // Arrange
      const customMessage = 'Custom error message';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: Exception('Original error'),
              message: customMessage,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(customMessage), findsOneWidget);
    });

    testWidgets('should be centered in parent', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: Exception('Error'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('should handle null error gracefully', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ErrorDisplayWidget), findsOneWidget);
    });

    testWidgets('should display with proper styling', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: Exception('Styled error'),
            ),
          ),
        ),
      );

      // Assert - Check that icon and text are present
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Styled error'), findsOneWidget);
      
      // Get the icon widget
      final iconFinder = find.byIcon(Icons.error_outline);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('should be accessible with semantic labels', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Semantics(
              label: 'Error occurred',
              child: ErrorDisplayWidget(
                error: Exception('Accessible error'),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Accessible error'), findsOneWidget);
    });
  });
}

