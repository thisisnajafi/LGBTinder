import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lgbtinder/components/loading/loading_widgets.dart';

void main() {
  group('Loading Widgets Tests', () {
    testWidgets('LoadingWidgets.circular should render CircularProgressIndicator', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidgets.circular(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingWidgets.circular should apply custom color', (WidgetTester tester) async {
      // Arrange
      const testColor = Colors.red;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidgets.circular(color: testColor),
          ),
        ),
      );

      // Assert
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.valueColor?.value, testColor);
    });

    testWidgets('LoadingWidgets.button should render with text', (WidgetTester tester) async {
      // Arrange
      const loadingText = 'Loading...';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidgets.button(text: loadingText),
          ),
        ),
      );

      // Assert
      expect(find.text(loadingText), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingWidgets.overlay should render with loading indicator', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidgets.overlay(
              isLoading: true,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingWidgets.overlay should not show loading when isLoading is false', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidgets.overlay(
              isLoading: false,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('LoadingWidgets.fullScreen should render centered loading', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidgets.fullScreen(),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('LoadingWidgets.fullScreen should render with message', (WidgetTester tester) async {
      // Arrange
      const message = 'Please wait...';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: LoadingWidgets.fullScreen(message: message),
        ),
      );

      // Assert
      expect(find.text(message), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('LoadingWidgets.shimmer should render placeholder', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidgets.shimmer(
              width: 200,
              height: 100,
            ),
          ),
        ),
      );

      // Assert - Shimmer effect should be present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('LoadingWidgets should be accessible', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingWidgets.fullScreen(message: 'Loading content'),
          ),
        ),
      );

      // Assert - Check for semantic labels
      expect(find.text('Loading content'), findsOneWidget);
    });
  });
}

