import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lgbtinder/screens/auth/profile_completion_screen.dart';
import 'package:lgbtinder/providers/app_state_provider.dart';
import 'package:lgbtinder/services/api_services/reference_data_api_service.dart';
import 'package:lgbtinder/services/api_services/auth_api_service.dart';
import 'package:lgbtinder/models/api_models/reference_data_models.dart';
import 'package:lgbtinder/models/api_models/auth_models.dart';
import 'ui_test_utils.dart';

import '../mocks/mock_reference_data_api_service.dart';
import '../mocks/mock_auth_api_service.dart';

@GenerateMocks([ReferenceDataApiService, AuthApiService])
void testProfileCompletionScreens() {
  group('Profile Completion Screens UI Tests', () {
    late MockReferenceDataApiService mockReferenceDataApiService;
    late MockAuthApiService mockAuthApiService;
    late AppStateProvider appStateProvider;

    setUp(() {
      mockReferenceDataApiService = MockReferenceDataApiService();
      mockAuthApiService = MockAuthApiService();
      appStateProvider = AppStateProvider();
      
      // Setup mock reference data
      when(mockReferenceDataApiService.getCountries()).thenAnswer((_) async => 
        ReferenceDataResponse(
          success: true,
          data: MockReferenceData.mockCountries,
        ));
      
      when(mockReferenceDataApiService.getCities(any)).thenAnswer((_) async => 
        ReferenceDataResponse(
          success: true,
          data: MockReferenceData.mockCities,
        ));
      
      when(mockReferenceDataApiService.getGenders()).thenAnswer((_) async => 
        ReferenceDataResponse(
          success: true,
          data: MockReferenceData.mockGenders,
        ));
      
      when(mockReferenceDataApiService.getInterests()).thenAnswer((_) async => 
        ReferenceDataResponse(
          success: true,
          data: MockReferenceData.mockInterests,
        ));
      
      when(mockReferenceDataApiService.getPreferredGenders()).thenAnswer((_) async => 
        ReferenceDataResponse(
          success: true,
          data: MockReferenceData.mockPreferredGenders,
        ));
    });

    group('Profile Completion Screen', () {
      testWidgets('displays step 1 form fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Verify step 1 form fields
        AssertionHelpers.assertFormField(tester, const Key('first_name_field'));
        AssertionHelpers.assertFormField(tester, const Key('last_name_field'));
        AssertionHelpers.assertFormField(tester, const Key('birth_date_field'));
        AssertionHelpers.assertFormField(tester, const Key('gender_dropdown'));
        AssertionHelpers.assertFormField(tester, const Key('country_dropdown'));
        AssertionHelpers.assertFormField(tester, const Key('city_dropdown'));

        // Verify step indicator
        expect(find.text('Step 1 of 3'), findsOneWidget);
        expect(find.text('Basic Information'), findsOneWidget);
      });

      testWidgets('displays step 2 form fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill step 1 and proceed
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        // Verify step 2 form fields
        AssertionHelpers.assertFormField(tester, const Key('height_field'));
        AssertionHelpers.assertFormField(tester, const Key('weight_field'));
        AssertionHelpers.assertFormField(tester, const Key('bio_field'));

        // Verify step indicator
        expect(find.text('Step 2 of 3'), findsOneWidget);
        expect(find.text('Physical Information'), findsOneWidget);
      });

      testWidgets('displays step 3 form fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill steps 1 and 2 and proceed
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        await FormHelpers.fillProfileCompletionStep2(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        // Verify step 3 form fields
        AssertionHelpers.assertFormField(tester, const Key('preferred_gender_dropdown'));
        AssertionHelpers.assertFormField(tester, const Key('interests_dropdown'));

        // Verify step indicator
        expect(find.text('Step 3 of 3'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
      });

      testWidgets('validates required fields in step 1', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Try to proceed without filling required fields
        await TestHelpers.tapButton(tester, 'Next');

        // Verify validation errors
        AssertionHelpers.assertValidationError(tester, 'Please enter your first name');
        AssertionHelpers.assertValidationError(tester, 'Please enter your last name');
        AssertionHelpers.assertValidationError(tester, 'Please select your birth date');
        AssertionHelpers.assertValidationError(tester, 'Please select your gender');
        AssertionHelpers.assertValidationError(tester, 'Please select your country');
        AssertionHelpers.assertValidationError(tester, 'Please select your city');
      });

      testWidgets('validates age requirement', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Select birth date that makes user under 18
        await TestHelpers.selectDate(tester, const Key('birth_date_field'), DateTime(2010, 1, 1));
        await TestHelpers.tapButton(tester, 'Next');

        // Verify age validation error
        AssertionHelpers.assertValidationError(tester, 'You must be at least 18 years old');
      });

      testWidgets('validates required fields in step 2', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill step 1 and proceed
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        // Try to proceed without filling required fields
        await TestHelpers.tapButton(tester, 'Next');

        // Verify validation errors
        AssertionHelpers.assertValidationError(tester, 'Please enter your height');
        AssertionHelpers.assertValidationError(tester, 'Please enter your weight');
        AssertionHelpers.assertValidationError(tester, 'Please enter your bio');
      });

      testWidgets('validates height and weight ranges', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill step 1 and proceed
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        // Test invalid height
        await TestHelpers.fillTextField(tester, const Key('height_field'), '50');
        await TestHelpers.tapButton(tester, 'Next');
        AssertionHelpers.assertValidationError(tester, 'Height must be between 100 and 250 cm');

        // Test invalid weight
        await TestHelpers.fillTextField(tester, const Key('weight_field'), '20');
        await TestHelpers.tapButton(tester, 'Next');
        AssertionHelpers.assertValidationError(tester, 'Weight must be between 30 and 200 kg');
      });

      testWidgets('validates bio length', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill step 1 and proceed
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        // Test bio too long
        final longBio = 'a' * 501; // Assuming max length is 500
        await TestHelpers.fillTextField(tester, const Key('bio_field'), longBio);
        await TestHelpers.tapButton(tester, 'Next');

        AssertionHelpers.assertValidationError(tester, 'Bio must be less than 500 characters');
      });

      testWidgets('validates required fields in step 3', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill steps 1 and 2 and proceed
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        await FormHelpers.fillProfileCompletionStep2(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        // Try to complete without filling required fields
        await TestHelpers.tapButton(tester, 'Complete Profile');

        // Verify validation errors
        AssertionHelpers.assertValidationError(tester, 'Please select your preferred gender');
        AssertionHelpers.assertValidationError(tester, 'Please select at least one interest');
      });

      testWidgets('allows going back to previous step', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill step 1 and proceed
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        // Go back to step 1
        await TestHelpers.tapButton(tester, 'Back');
        await tester.pumpAndSettle();

        // Verify we're back on step 1
        expect(find.text('Step 1 of 3'), findsOneWidget);
        expect(find.text('Basic Information'), findsOneWidget);
      });

      testWidgets('shows loading state during profile completion', (WidgetTester tester) async {
        // Mock successful profile completion
        when(mockAuthApiService.completeProfile(any)).thenAnswer((_) async => 
          CompleteProfileResponse(
            success: true,
            message: 'Profile completed successfully',
            data: CompleteProfileResponseData(
              userId: 1,
              isProfileComplete: true,
            ),
          ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill all steps
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        await FormHelpers.fillProfileCompletionStep2(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        await FormHelpers.fillProfileCompletionStep3(tester);

        // Complete profile
        await TestHelpers.tapButton(tester, 'Complete Profile');

        // Verify loading state
        AssertionHelpers.assertLoadingState(tester, 'Completing Profile...');
      });

      testWidgets('handles profile completion success', (WidgetTester tester) async {
        // Mock successful profile completion
        when(mockAuthApiService.completeProfile(any)).thenAnswer((_) async => 
          CompleteProfileResponse(
            success: true,
            message: 'Profile completed successfully',
            data: CompleteProfileResponseData(
              userId: 1,
              isProfileComplete: true,
            ),
          ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill all steps
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        await FormHelpers.fillProfileCompletionStep2(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        await FormHelpers.fillProfileCompletionStep3(tester);

        // Complete profile
        await TestHelpers.tapButton(tester, 'Complete Profile');
        await tester.pumpAndSettle();

        // Verify success message
        AssertionHelpers.assertSuccessMessage(tester, 'Profile completed successfully');
      });

      testWidgets('handles profile completion error', (WidgetTester tester) async {
        // Mock profile completion error
        when(mockAuthApiService.completeProfile(any)).thenThrow(Exception('Failed to complete profile'));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Fill all steps
        await FormHelpers.fillProfileCompletionStep1(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        await FormHelpers.fillProfileCompletionStep2(tester);
        await TestHelpers.tapButton(tester, 'Next');
        await tester.pumpAndSettle();

        await FormHelpers.fillProfileCompletionStep3(tester);

        // Complete profile
        await TestHelpers.tapButton(tester, 'Complete Profile');
        await tester.pumpAndSettle();

        // Verify error message
        AssertionHelpers.assertErrorState(tester, 'Failed to complete profile');
      });

      testWidgets('loads reference data on initialization', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Verify loading state
        AssertionHelpers.assertLoadingState(tester, 'Loading...');

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Verify reference data is loaded
        expect(find.text('United States'), findsOneWidget);
        expect(find.text('Male'), findsOneWidget);
        expect(find.text('Female'), findsOneWidget);
      });

      testWidgets('handles reference data loading error', (WidgetTester tester) async {
        // Mock reference data loading error
        when(mockReferenceDataApiService.getCountries()).thenThrow(Exception('Failed to load countries'));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for error to occur
        await tester.pumpAndSettle();

        // Verify error state
        AssertionHelpers.assertErrorState(tester, 'Failed to load countries');
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('updates cities when country changes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Select country
        await TestHelpers.selectDropdownItem(tester, const Key('country_dropdown'), 'United States');
        await tester.pumpAndSettle();

        // Verify cities are updated
        expect(find.text('New York'), findsOneWidget);
        expect(find.text('Los Angeles'), findsOneWidget);
      });

      testWidgets('displays progress indicator', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // Verify progress indicator
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('validates email format if email field is present', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const ProfileCompletionScreen(userId: 1),
          ),
        );

        // Wait for reference data to load
        await tester.pumpAndSettle();

        // If email field exists, test validation
        if (find.byKey(const Key('email_field')).evaluate().isNotEmpty) {
          await TestHelpers.fillTextField(tester, const Key('email_field'), 'invalid-email');
          await TestHelpers.tapButton(tester, 'Next');
          
          AssertionHelpers.assertValidationError(tester, 'Please enter a valid email');
        }
      });
    });
  });
}