import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lgbtinder/pages/profile_page.dart';
import 'package:lgbtinder/pages/profile_edit_page.dart';
import 'package:lgbtinder/providers/profile_state_provider.dart';
import 'package:lgbtinder/services/api_services/profile_api_service.dart';
import 'package:lgbtinder/models/api_models/user_models.dart';
import 'ui_test_utils.dart';

import '../mocks/mock_profile_api_service.dart';

@GenerateMocks([ProfileStateProvider, ProfileApiService])
void testProfileScreens() {
  group('Profile Screens UI Tests', () {
    late MockProfileStateProvider mockProfileStateProvider;

    setUp(() {
      mockProfileStateProvider = MockProfileStateProvider();
      MockProviderSetup.setupMockProfileStateProvider(mockProfileStateProvider);
    });

    group('Profile Page', () {
      testWidgets('displays user profile information', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfilePage(),
          ),
        );

        // Verify profile header
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Test bio'), findsOneWidget);
        AssertionHelpers.assertIcon(tester, Icons.edit);

        // Verify profile sections
        expect(find.text('About Me'), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);
        expect(find.text('Interests'), findsOneWidget);
        expect(find.text('New York'), findsOneWidget);
        expect(find.text('Software Engineer'), findsOneWidget);
        expect(find.text('Bachelor\'s Degree'), findsOneWidget);
      });

      testWidgets('shows loading state', (WidgetTester tester) async {
        when(mockProfileStateProvider.isLoading).thenReturn(true);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfilePage(),
          ),
        );

        // Verify loading state
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows error state', (WidgetTester tester) async {
        when(mockProfileStateProvider.isLoading).thenReturn(false);
        when(mockProfileStateProvider.error).thenReturn('Failed to load profile');

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfilePage(),
          ),
        );

        // Verify error state
        AssertionHelpers.assertErrorState(tester, 'Failed to load profile');
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('navigates to profile edit page', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfilePage(),
          ),
        );

        await TestHelpers.tapIcon(tester, Icons.edit);
        await tester.pumpAndSettle();

        // Verify navigation to profile edit page
        AssertionHelpers.assertScreenTitle(tester, 'Edit Profile');
      });

      testWidgets('displays profile pictures', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfilePage(),
          ),
        );

        // Verify profile pictures are displayed
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('displays user stats', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfilePage(),
          ),
        );

        // Verify user stats
        expect(find.text('25'), findsOneWidget); // Age
        expect(find.text('180 cm'), findsOneWidget); // Height
        expect(find.text('70 kg'), findsOneWidget); // Weight
      });
    });

    group('Profile Edit Page', () {
      testWidgets('displays all form fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Verify form fields are present
        AssertionHelpers.assertFormField(tester, const Key('first_name_field'));
        AssertionHelpers.assertFormField(tester, const Key('last_name_field'));
        AssertionHelpers.assertFormField(tester, const Key('bio_field'));
        AssertionHelpers.assertFormField(tester, const Key('height_field'));
        AssertionHelpers.assertFormField(tester, const Key('weight_field'));
        AssertionHelpers.assertFormField(tester, const Key('location_field'));
        AssertionHelpers.assertFormField(tester, const Key('job_field'));
        AssertionHelpers.assertFormField(tester, const Key('education_field'));
      });

      testWidgets('pre-fills form with current user data', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Verify form is pre-filled
        expect(find.text('John'), findsOneWidget);
        expect(find.text('Doe'), findsOneWidget);
        expect(find.text('Test bio'), findsOneWidget);
        expect(find.text('180'), findsOneWidget);
        expect(find.text('70'), findsOneWidget);
        expect(find.text('New York'), findsOneWidget);
        expect(find.text('Software Engineer'), findsOneWidget);
        expect(find.text('Bachelor\'s Degree'), findsOneWidget);
      });

      testWidgets('validates required fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Clear required fields
        await TestHelpers.fillTextField(tester, const Key('first_name_field'), '');
        await TestHelpers.fillTextField(tester, const Key('last_name_field'), '');
        await TestHelpers.fillTextField(tester, const Key('bio_field'), '');

        // Try to save
        await TestHelpers.tapButton(tester, 'Save');

        // Verify validation errors
        AssertionHelpers.assertValidationError(tester, 'Please enter your first name');
        AssertionHelpers.assertValidationError(tester, 'Please enter your last name');
        AssertionHelpers.assertValidationError(tester, 'Please enter your bio');
      });

      testWidgets('validates height and weight fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Test invalid height
        await TestHelpers.fillTextField(tester, const Key('height_field'), 'abc');
        await TestHelpers.tapButton(tester, 'Save');
        AssertionHelpers.assertValidationError(tester, 'Please enter a valid height');

        // Test invalid weight
        await TestHelpers.fillTextField(tester, const Key('weight_field'), 'xyz');
        await TestHelpers.tapButton(tester, 'Save');
        AssertionHelpers.assertValidationError(tester, 'Please enter a valid weight');
      });

      testWidgets('shows loading state during save', (WidgetTester tester) async {
        when(mockProfileStateProvider.updateProfile(any)).thenAnswer((_) async => true);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        await TestHelpers.tapButton(tester, 'Save');

        // Verify loading state
        AssertionHelpers.assertLoadingState(tester, 'Saving...');
      });

      testWidgets('handles save success', (WidgetTester tester) async {
        when(mockProfileStateProvider.updateProfile(any)).thenAnswer((_) async => true);

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        await TestHelpers.tapButton(tester, 'Save');
        await tester.pumpAndSettle();

        // Verify success message
        AssertionHelpers.assertSuccessMessage(tester, 'Profile updated successfully');
      });

      testWidgets('handles save error', (WidgetTester tester) async {
        when(mockProfileStateProvider.updateProfile(any)).thenThrow(Exception('Failed to update profile'));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        await TestHelpers.tapButton(tester, 'Save');
        await tester.pumpAndSettle();

        // Verify error message
        AssertionHelpers.assertErrorState(tester, 'Failed to update profile');
      });

      testWidgets('allows adding profile pictures', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Find and tap add photo button
        await TestHelpers.tapIcon(tester, Icons.add_photo_alternate);
        await tester.pumpAndSettle();

        // Verify photo picker options are shown
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);
      });

      testWidgets('allows removing profile pictures', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Find and tap remove photo button
        await TestHelpers.tapIcon(tester, Icons.delete);
        await tester.pumpAndSettle();

        // Verify confirmation dialog
        expect(find.text('Remove Photo'), findsOneWidget);
        expect(find.text('Are you sure you want to remove this photo?'), findsOneWidget);
      });

      testWidgets('navigates back on cancel', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        await TestHelpers.tapIcon(tester, Icons.close);
        await tester.pumpAndSettle();

        // Verify navigation back
        expect(find.byType(ProfileEditPage), findsNothing);
      });

      testWidgets('shows unsaved changes dialog', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Make changes
        await TestHelpers.fillTextField(tester, const Key('bio_field'), 'Updated bio');

        // Try to navigate back
        await TestHelpers.tapIcon(tester, Icons.close);
        await tester.pumpAndSettle();

        // Verify unsaved changes dialog
        expect(find.text('Unsaved Changes'), findsOneWidget);
        expect(find.text('You have unsaved changes. Do you want to save them?'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Discard'), findsOneWidget);
      });

      testWidgets('validates bio length', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Test bio too long
        final longBio = 'a' * 501; // Assuming max length is 500
        await TestHelpers.fillTextField(tester, const Key('bio_field'), longBio);
        await TestHelpers.tapButton(tester, 'Save');

        AssertionHelpers.assertValidationError(tester, 'Bio must be less than 500 characters');
      });

      testWidgets('validates height range', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Test height too low
        await TestHelpers.fillTextField(tester, const Key('height_field'), '50');
        await TestHelpers.tapButton(tester, 'Save');
        AssertionHelpers.assertValidationError(tester, 'Height must be between 100 and 250 cm');

        // Test height too high
        await TestHelpers.fillTextField(tester, const Key('height_field'), '300');
        await TestHelpers.tapButton(tester, 'Save');
        AssertionHelpers.assertValidationError(tester, 'Height must be between 100 and 250 cm');
      });

      testWidgets('validates weight range', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            profileStateProvider: mockProfileStateProvider,
            child: const ProfileEditPage(),
          ),
        );

        // Test weight too low
        await TestHelpers.fillTextField(tester, const Key('weight_field'), '20');
        await TestHelpers.tapButton(tester, 'Save');
        AssertionHelpers.assertValidationError(tester, 'Weight must be between 30 and 200 kg');

        // Test weight too high
        await TestHelpers.fillTextField(tester, const Key('weight_field'), '300');
        await TestHelpers.tapButton(tester, 'Save');
        AssertionHelpers.assertValidationError(tester, 'Weight must be between 30 and 200 kg');
      });
    });
  });
}