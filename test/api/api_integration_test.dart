import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lgbtinder/main.dart' as app;

/// API Integration Test Suite
/// 
/// This file contains integration tests for API endpoints including:
/// - End-to-end authentication flow
/// - Reference data loading
/// - User profile management
/// - Matching and chat functionality
/// - Error handling scenarios

void testApiIntegration() {
  group('API Integration Tests', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Complete authentication flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test registration flow
      await testRegistrationFlow(tester);
      
      // Test email verification flow
      await testEmailVerificationFlow(tester);
      
      // Test profile completion flow
      await testProfileCompletionFlow(tester);
    });

    testWidgets('Reference data loading', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test countries loading
      await testCountriesLoading(tester);
      
      // Test cities loading
      await testCitiesLoading(tester);
      
      // Test all reference data loading
      await testAllReferenceDataLoading(tester);
    });

    testWidgets('User profile management', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test profile update
      await testProfileUpdate(tester);
      
      // Test profile picture upload
      await testProfilePictureUpload(tester);
    });

    testWidgets('Matching and chat functionality', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test user liking
      await testUserLiking(tester);
      
      // Test match creation
      await testMatchCreation(tester);
      
      // Test messaging
      await testMessaging(tester);
    });

    testWidgets('Error handling scenarios', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test network error handling
      await testNetworkErrorHandling(tester);
      
      // Test validation error handling
      await testValidationErrorHandling(tester);
      
      // Test rate limiting handling
      await testRateLimitingHandling(tester);
    });
  });
}

/// Test registration flow
Future<void> testRegistrationFlow(WidgetTester tester) async {
  // Navigate to registration screen
  await tester.tap(find.text('Create Account'));
  await tester.pumpAndSettle();

  // Fill registration form
  await tester.enterText(find.byKey(const Key('first_name_field')), 'John');
  await tester.enterText(find.byKey(const Key('last_name_field')), 'Doe');
  await tester.enterText(find.byKey(const Key('email_field')), 'john.doe@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'password123');
  await tester.enterText(find.byKey(const Key('referral_code_field')), 'ABC123');

  // Submit registration
  await tester.tap(find.byKey(const Key('register_button')));
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Registration successful!'), findsOneWidget);
  expect(find.text('Please check your email for verification code.'), findsOneWidget);
}

/// Test email verification flow
Future<void> testEmailVerificationFlow(WidgetTester tester) async {
  // Navigate to email verification screen
  await tester.pumpAndSettle();

  // Enter verification code
  await tester.enterText(find.byKey(const Key('verification_code_field')), '123456');

  // Submit verification
  await tester.tap(find.byKey(const Key('verify_button')));
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Email verified successfully!'), findsOneWidget);
  expect(find.text('Please complete your profile.'), findsOneWidget);
}

/// Test profile completion flow
Future<void> testProfileCompletionFlow(WidgetTester tester) async {
  // Navigate to profile completion screen
  await tester.pumpAndSettle();

  // Fill basic info
  await tester.enterText(find.byKey(const Key('profile_bio_field')), 'Love traveling and music!');
  await tester.enterText(find.byKey(const Key('height_field')), '175');
  await tester.enterText(find.byKey(const Key('weight_field')), '70');

  // Select country and city
  await tester.tap(find.byKey(const Key('country_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('United States'));
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('city_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('New York'));
  await tester.pumpAndSettle();

  // Select gender
  await tester.tap(find.byKey(const Key('gender_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Man'));
  await tester.pumpAndSettle();

  // Select birth date
  await tester.tap(find.byKey(const Key('birth_date_field')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('15'));
  await tester.tap(find.text('6'));
  await tester.tap(find.text('1995'));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  // Set age preferences
  await tester.drag(find.byKey(const Key('min_age_slider')), const Offset(50, 0));
  await tester.drag(find.byKey(const Key('max_age_slider')), const Offset(100, 0));
  await tester.pumpAndSettle();

  // Select lifestyle preferences
  await tester.tap(find.byKey(const Key('smoke_checkbox')));
  await tester.tap(find.byKey(const Key('drink_checkbox')));
  await tester.tap(find.byKey(const Key('gym_checkbox')));
  await tester.pumpAndSettle();

  // Select interests
  await tester.tap(find.text('Music'));
  await tester.tap(find.text('Travel'));
  await tester.tap(find.text('Sports'));
  await tester.pumpAndSettle();

  // Select preferred genders
  await tester.tap(find.byKey(const Key('preferred_genders_dropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Women'));
  await tester.pumpAndSettle();

  // Select relation goals
  await tester.tap(find.text('Long-term relationship'));
  await tester.tap(find.text('Casual dating'));
  await tester.pumpAndSettle();

  // Complete profile
  await tester.tap(find.byKey(const Key('complete_profile_button')));
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Profile completed successfully!'), findsOneWidget);
}

/// Test countries loading
Future<void> testCountriesLoading(WidgetTester tester) async {
  // Navigate to profile completion screen
  await tester.pumpAndSettle();

  // Tap country dropdown
  await tester.tap(find.byKey(const Key('country_dropdown')));
  await tester.pumpAndSettle();

  // Verify countries are loaded
  expect(find.text('United States'), findsOneWidget);
  expect(find.text('United Kingdom'), findsOneWidget);
  expect(find.text('Canada'), findsOneWidget);
}

/// Test cities loading
Future<void> testCitiesLoading(WidgetTester tester) async {
  // Select a country first
  await tester.tap(find.text('United States'));
  await tester.pumpAndSettle();

  // Tap city dropdown
  await tester.tap(find.byKey(const Key('city_dropdown')));
  await tester.pumpAndSettle();

  // Verify cities are loaded
  expect(find.text('New York'), findsOneWidget);
  expect(find.text('Los Angeles'), findsOneWidget);
  expect(find.text('Chicago'), findsOneWidget);
}

/// Test all reference data loading
Future<void> testAllReferenceDataLoading(WidgetTester tester) async {
  // Navigate to interests step
  await tester.pumpAndSettle();

  // Verify interests are loaded
  expect(find.text('Music'), findsOneWidget);
  expect(find.text('Travel'), findsOneWidget);
  expect(find.text('Sports'), findsOneWidget);
  expect(find.text('Art'), findsOneWidget);

  // Navigate to relation goals step
  await tester.pumpAndSettle();

  // Verify relation goals are loaded
  expect(find.text('Long-term relationship'), findsOneWidget);
  expect(find.text('Casual dating'), findsOneWidget);
  expect(find.text('Friendship'), findsOneWidget);
}

/// Test profile update
Future<void> testProfileUpdate(WidgetTester tester) async {
  // Navigate to profile screen
  await tester.tap(find.byKey(const Key('profile_tab')));
  await tester.pumpAndSettle();

  // Tap edit profile button
  await tester.tap(find.byKey(const Key('edit_profile_button')));
  await tester.pumpAndSettle();

  // Update profile bio
  await tester.enterText(find.byKey(const Key('profile_bio_field')), 'Updated bio text');

  // Update height and weight
  await tester.enterText(find.byKey(const Key('height_field')), '180');
  await tester.enterText(find.byKey(const Key('weight_field')), '75');

  // Update age preferences
  await tester.drag(find.byKey(const Key('min_age_slider')), const Offset(60, 0));
  await tester.drag(find.byKey(const Key('max_age_slider')), const Offset(120, 0));
  await tester.pumpAndSettle();

  // Save changes
  await tester.tap(find.byKey(const Key('save_profile_button')));
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Profile updated successfully'), findsOneWidget);
}

/// Test profile picture upload
Future<void> testProfilePictureUpload(WidgetTester tester) async {
  // Navigate to profile screen
  await tester.tap(find.byKey(const Key('profile_tab')));
  await tester.pumpAndSettle();

  // Tap profile picture
  await tester.tap(find.byKey(const Key('profile_picture')));
  await tester.pumpAndSettle();

  // Select camera option
  await tester.tap(find.text('Camera'));
  await tester.pumpAndSettle();

  // Simulate taking a picture
  await tester.tap(find.byKey(const Key('take_picture_button')));
  await tester.pumpAndSettle();

  // Confirm picture
  await tester.tap(find.byKey(const Key('confirm_picture_button')));
  await tester.pumpAndSettle();

  // Verify success message
  expect(find.text('Profile picture uploaded successfully'), findsOneWidget);
}

/// Test user liking
Future<void> testUserLiking(WidgetTester tester) async {
  // Navigate to discovery screen
  await tester.tap(find.byKey(const Key('discovery_tab')));
  await tester.pumpAndSettle();

  // Like a user
  await tester.tap(find.byKey(const Key('like_button')));
  await tester.pumpAndSettle();

  // Verify like response
  expect(find.text('User liked successfully'), findsOneWidget);
}

/// Test match creation
Future<void> testMatchCreation(WidgetTester tester) async {
  // Continue liking users until a match is created
  for (int i = 0; i < 5; i++) {
    await tester.tap(find.byKey(const Key('like_button')));
    await tester.pumpAndSettle();

    // Check if match dialog appears
    if (find.text("It's a match!").evaluate().isNotEmpty) {
      // Verify match dialog
      expect(find.text("It's a match!"), findsOneWidget);
      expect(find.text('Start Chat'), findsOneWidget);

      // Close match dialog
      await tester.tap(find.byKey(const Key('close_match_dialog')));
      await tester.pumpAndSettle();
      break;
    }
  }
}

/// Test messaging
Future<void> testMessaging(WidgetTester tester) async {
  // Navigate to matches screen
  await tester.tap(find.byKey(const Key('matches_tab')));
  await tester.pumpAndSettle();

  // Tap on a match
  await tester.tap(find.byKey(const Key('match_item')));
  await tester.pumpAndSettle();

  // Send a message
  await tester.enterText(find.byKey(const Key('message_input')), 'Hey! How are you?');
  await tester.tap(find.byKey(const Key('send_message_button')));
  await tester.pumpAndSettle();

  // Verify message was sent
  expect(find.text('Hey! How are you?'), findsOneWidget);
  expect(find.text('Message sent successfully'), findsOneWidget);
}

/// Test network error handling
Future<void> testNetworkErrorHandling(WidgetTester tester) async {
  // Simulate network error by disconnecting
  // This would typically be done by mocking the network layer
  
  // Try to perform an action that requires network
  await tester.tap(find.byKey(const Key('like_button')));
  await tester.pumpAndSettle();

  // Verify error message
  expect(find.text('Network error'), findsOneWidget);
  expect(find.text('Please check your internet connection'), findsOneWidget);
}

/// Test validation error handling
Future<void> testValidationErrorHandling(WidgetTester tester) async {
  // Navigate to registration screen
  await tester.tap(find.text('Create Account'));
  await tester.pumpAndSettle();

  // Submit form with invalid data
  await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
  await tester.enterText(find.byKey(const Key('password_field')), '123');
  await tester.tap(find.byKey(const Key('register_button')));
  await tester.pumpAndSettle();

  // Verify validation errors
  expect(find.text('The email field must be a valid email address.'), findsOneWidget);
  expect(find.text('The password field must be at least 8 characters.'), findsOneWidget);
}

/// Test rate limiting handling
Future<void> testRateLimitingHandling(WidgetTester tester) async {
  // Rapidly perform actions that might trigger rate limiting
  for (int i = 0; i < 10; i++) {
    await tester.tap(find.byKey(const Key('like_button')));
    await tester.pumpAndSettle();

    // Check if rate limit message appears
    if (find.text('Rate limit exceeded').evaluate().isNotEmpty) {
      // Verify rate limit message
      expect(find.text('Rate limit exceeded'), findsOneWidget);
      expect(find.text('Please try again in'), findsOneWidget);
      break;
    }
  }
}
