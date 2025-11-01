import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/theme/app_theme.dart';
import '../lib/theme/theme_provider.dart';

/// Test helper utilities for Flutter widget and integration tests
class TestHelpers {
  /// Create a MaterialApp wrapper for testing widgets with theme support
  static Widget createTestApp({
    required Widget child,
    ThemeMode themeMode = ThemeMode.light,
    ThemeProvider? themeProvider,
  }) {
    final provider = themeProvider ?? ThemeProvider();
    
    return ChangeNotifierProvider<ThemeProvider>.value(
      value: provider,
      child: MaterialApp(
        title: 'LGBTinder Test',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: child,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// Create a test scaffold wrapper
  static Widget createTestScaffold({
    required Widget child,
    AppBar? appBar,
    FloatingActionButton? floatingActionButton,
    BottomNavigationBar? bottomNavigationBar,
  }) {
    return Scaffold(
      appBar: appBar,
      body: child,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  /// Pump widget with theme support
  static Future<void> pumpWidgetWithTheme(
    WidgetTester tester,
    Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
    ThemeProvider? themeProvider,
  }) async {
    await tester.pumpWidget(
      createTestApp(
        child: widget,
        themeMode: themeMode,
        themeProvider: themeProvider,
      ),
    );
  }

  /// Wait for animations to complete
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  /// Tap widget and wait for animations
  static Future<void> tapAndWait(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Enter text in a text field
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.enterText(finder, text);
    await tester.pump();
  }

  /// Scroll to widget and make it visible
  static Future<void> ensureVisible(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.ensureVisible(finder);
    await tester.pump();
  }

  /// Drag widget
  static Future<void> dragWidget(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Find text in widget tree (case-insensitive)
  static Finder findTextCaseInsensitive(String text) {
    return find.text(text, findRichText: true);
  }

  /// Find widget by type
  static Finder findWidgetByType<T extends Widget>() {
    return find.byType(T);
  }

  /// Find widget by key
  static Finder findWidgetByKey(Key key) {
    return find.byKey(key);
  }

  /// Check if widget exists
  static bool widgetExists(Finder finder) {
    return finder.evaluate().isNotEmpty;
  }

  /// Get widget of specific type
  static T? getWidget<T extends Widget>(WidgetTester tester, Finder finder) {
    final elements = finder.evaluate();
    if (elements.isEmpty) return null;
    
    final widget = elements.first.widget;
    return widget is T ? widget : null;
  }

  /// Wait for async operations
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  /// Mock network delay
  static Future<void> simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// Common test constants
class TestConstants {
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration mediumDelay = Duration(milliseconds: 500);
  static const Duration longDelay = Duration(milliseconds: 1000);
  
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testName = 'Test User';
  static const int testAge = 25;
  
  static const Key testKey = Key('test_key');
}

/// Extension on WidgetTester for convenience
extension WidgetTesterExtensions on WidgetTester {
  /// Pump with delay
  Future<void> pumpWithDelay([Duration? delay]) async {
    await pump();
    if (delay != null) {
      await Future.delayed(delay);
      await pump();
    }
  }
  
  /// Pump and settle with timeout
  Future<void> pumpAndSettleWithTimeout([
    Duration timeout = const Duration(seconds: 5),
  ]) async {
    await pumpAndSettle(timeout);
  }
}

