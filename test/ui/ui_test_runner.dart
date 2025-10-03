import 'package:flutter_test/flutter_test.dart';
import 'auth_screens_test.dart';
import 'profile_screens_test.dart';
import 'matching_screens_test.dart';
import 'chat_screens_test.dart';
import 'profile_completion_test.dart';

/// UI Test Runner
/// 
/// This file runs all UI-related tests including:
/// - Authentication screen tests
/// - Profile screen tests
/// - Matching screen tests
/// - Chat screen tests
/// - Profile completion tests
void main() {
  group('UI Tests', () {
    group('Authentication Screens', () {
      testAuthScreens();
    });

    group('Profile Screens', () {
      testProfileScreens();
    });

    group('Matching Screens', () {
      testMatchingScreens();
    });

    group('Chat Screens', () {
      testChatScreens();
    });

    group('Profile Completion', () {
      testProfileCompletion();
    });
  });
}
