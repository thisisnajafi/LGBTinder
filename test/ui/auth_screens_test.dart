import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lgbtinder/screens/auth/login_screen.dart';
import 'package:lgbtinder/screens/auth/register_screen.dart';
import 'package:lgbtinder/screens/auth/email_verification_screen.dart';
import 'package:lgbtinder/providers/app_state_provider.dart';
import 'package:lgbtinder/services/api_services/auth_api_service.dart';
import 'package:lgbtinder/models/api_models/auth_models.dart';
import 'package:lgbtinder/models/user_state_models.dart';
import 'ui_test_utils.dart';

import '../mocks/mock_auth_api_service.dart';

@GenerateMocks([AuthApiService])
void testAuthScreens() {
  group('Auth Screens UI Tests', () {
    late MockAuthApiService mockAuthApiService;
    late AppStateProvider appStateProvider;

    setUp(() {
      mockAuthApiService = MockAuthApiService();
      appStateProvider = AppStateProvider();
    });

    group('Login Screen', () {
      testWidgets('displays all required UI elements', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const LoginScreen(),
          ),
        );

        // Verify UI elements are present
        AssertionHelpers.assertScreenTitle(tester, 'Welcome Back!');
        AssertionHelpers.assertFormField(tester, const Key('email_field'));
        AssertionHelpers.assertFormField(tester, const Key('password_field'));
        AssertionHelpers.assertButton(tester, 'Sign In');
        AssertionHelpers.assertButton(tester, 'Create Account');
        expect(find.text('Forgot Password?'), findsOneWidget);
      });

      testWidgets('validates email field', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const LoginScreen(),
          ),
        );

        // Test empty email
        await TestHelpers.tapButton(tester, 'Sign In');
        AssertionHelpers.assertValidationError(tester, 'Please enter your email');

        // Test invalid email
        await TestHelpers.fillTextField(tester, const Key('email_field'), 'invalid-email');
        await TestHelpers.tapButton(tester, 'Sign In');
        AssertionHelpers.assertValidationError(tester, 'Please enter a valid email');
      });

      testWidgets('validates password field', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const LoginScreen(),
          ),
        );

        // Test empty password
        await TestHelpers.fillTextField(tester, const Key('email_field'), 'test@example.com');
        await TestHelpers.tapButton(tester, 'Sign In');
        AssertionHelpers.assertValidationError(tester, 'Please enter your password');
      });

      testWidgets('navigates to register screen', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const LoginScreen(),
          ),
        );

        await TestHelpers.tapButton(tester, 'Create Account');
        await tester.pumpAndSettle();

        // Verify navigation to register screen
        AssertionHelpers.assertScreenTitle(tester, 'Create Account');
      });

      testWidgets('shows loading state during login', (WidgetTester tester) async {
        // Mock successful login
        when(mockAuthApiService.login(any)).thenAnswer((_) async => AuthResponse(
          success: true,
          message: 'Login successful',
          data: AuthResult(
            token: 'mock_token',
            refreshToken: 'mock_refresh_token',
            user: MockUserData.mockUser,
          ),
        ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const LoginScreen(),
          ),
        );

        await FormHelpers.fillLoginForm(tester);
        await TestHelpers.tapButton(tester, 'Sign In');

        // Verify loading state
        AssertionHelpers.assertLoadingState(tester, 'Signing In...');
      });

      testWidgets('handles login success', (WidgetTester tester) async {
        // Mock successful login
        when(mockAuthApiService.login(any)).thenAnswer((_) async => AuthResponse(
          success: true,
          message: 'Login successful',
          data: AuthResult(
            token: 'mock_token',
            refreshToken: 'mock_refresh_token',
            user: MockUserData.mockUser,
          ),
        ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const LoginScreen(),
          ),
        );

        await FormHelpers.fillLoginForm(tester);
        await TestHelpers.tapButton(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Verify success message
        AssertionHelpers.assertSuccessMessage(tester, 'Login successful');
      });

      testWidgets('handles login error', (WidgetTester tester) async {
        // Mock login error
        when(mockAuthApiService.login(any)).thenThrow(Exception('Invalid credentials'));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const LoginScreen(),
          ),
        );

        await FormHelpers.fillLoginForm(tester);
        await TestHelpers.tapButton(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Verify error message
        AssertionHelpers.assertErrorState(tester, 'Invalid credentials');
      });
    });

    group('Register Screen', () {
      testWidgets('displays all required UI elements', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const RegisterScreen(),
          ),
        );

        // Verify UI elements are present
        AssertionHelpers.assertScreenTitle(tester, 'Create Account');
        AssertionHelpers.assertFormField(tester, const Key('first_name_field'));
        AssertionHelpers.assertFormField(tester, const Key('last_name_field'));
        AssertionHelpers.assertFormField(tester, const Key('email_field'));
        AssertionHelpers.assertFormField(tester, const Key('password_field'));
        AssertionHelpers.assertFormField(tester, const Key('referral_code_field'));
        AssertionHelpers.assertButton(tester, 'Create Account');
        AssertionHelpers.assertButton(tester, 'Sign In');
      });

      testWidgets('validates required fields', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const RegisterScreen(),
          ),
        );

        // Test empty form submission
        await TestHelpers.tapButton(tester, 'Create Account');
        
        AssertionHelpers.assertValidationError(tester, 'Please enter your first name');
        AssertionHelpers.assertValidationError(tester, 'Please enter your last name');
        AssertionHelpers.assertValidationError(tester, 'Please enter your email');
        AssertionHelpers.assertValidationError(tester, 'Please enter your password');
      });

      testWidgets('validates email format', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const RegisterScreen(),
          ),
        );

        await TestHelpers.fillTextField(tester, const Key('email_field'), 'invalid-email');
        await TestHelpers.tapButton(tester, 'Create Account');
        
        AssertionHelpers.assertValidationError(tester, 'Please enter a valid email');
      });

      testWidgets('validates password strength', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const RegisterScreen(),
          ),
        );

        // Test weak password
        await TestHelpers.fillTextField(tester, const Key('password_field'), '123');
        await TestHelpers.tapButton(tester, 'Create Account');
        
        AssertionHelpers.assertValidationError(tester, 'Password must be at least 8 characters');
      });

      testWidgets('navigates to login screen', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const RegisterScreen(),
          ),
        );

        await TestHelpers.tapButton(tester, 'Sign In');
        await tester.pumpAndSettle();

        // Verify navigation to login screen
        AssertionHelpers.assertScreenTitle(tester, 'Welcome Back!');
      });

      testWidgets('shows loading state during registration', (WidgetTester tester) async {
        // Mock successful registration
        when(mockAuthApiService.register(any)).thenAnswer((_) async => RegisterResponse(
          success: true,
          message: 'Registration successful',
          data: RegisterResponseData(
            userId: 1,
            email: 'test@example.com',
            requiresEmailVerification: true,
          ),
        ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const RegisterScreen(),
          ),
        );

        await FormHelpers.fillRegisterForm(tester);
        await TestHelpers.tapButton(tester, 'Create Account');

        // Verify loading state
        AssertionHelpers.assertLoadingState(tester, 'Creating Account...');
      });

      testWidgets('handles registration success', (WidgetTester tester) async {
        // Mock successful registration
        when(mockAuthApiService.register(any)).thenAnswer((_) async => RegisterResponse(
          success: true,
          message: 'Registration successful',
          data: RegisterResponseData(
            userId: 1,
            email: 'test@example.com',
            requiresEmailVerification: true,
          ),
        ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const RegisterScreen(),
          ),
        );

        await FormHelpers.fillRegisterForm(tester);
        await TestHelpers.tapButton(tester, 'Create Account');
        await tester.pumpAndSettle();

        // Verify success message and navigation
        AssertionHelpers.assertSuccessMessage(tester, 'Registration successful');
        // Should navigate to email verification screen
        AssertionHelpers.assertScreenTitle(tester, 'Verify Your Email');
      });

      testWidgets('handles registration error', (WidgetTester tester) async {
        // Mock registration error
        when(mockAuthApiService.register(any)).thenThrow(Exception('Email already exists'));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const RegisterScreen(),
          ),
        );

        await FormHelpers.fillRegisterForm(tester);
        await TestHelpers.tapButton(tester, 'Create Account');
        await tester.pumpAndSettle();

        // Verify error message
        AssertionHelpers.assertErrorState(tester, 'Email already exists');
      });
    });

    group('Email Verification Screen', () {
      testWidgets('displays all required UI elements', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const EmailVerificationScreen(userId: 1),
          ),
        );

        // Verify UI elements are present
        AssertionHelpers.assertScreenTitle(tester, 'Verify Your Email');
        AssertionHelpers.assertFormField(tester, const Key('verification_code_field'));
        AssertionHelpers.assertButton(tester, 'Verify Email');
        AssertionHelpers.assertButton(tester, 'Resend Code');
      });

      testWidgets('validates verification code', (WidgetTester tester) async {
        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const EmailVerificationScreen(userId: 1),
          ),
        );

        // Test empty code
        await TestHelpers.tapButton(tester, 'Verify Email');
        AssertionHelpers.assertValidationError(tester, 'Please enter the verification code');

        // Test invalid code length
        await TestHelpers.fillTextField(tester, const Key('verification_code_field'), '123');
        await TestHelpers.tapButton(tester, 'Verify Email');
        AssertionHelpers.assertValidationError(tester, 'Verification code must be 6 digits');
      });

      testWidgets('shows loading state during verification', (WidgetTester tester) async {
        // Mock successful verification
        when(mockAuthApiService.verifyEmail(any)).thenAnswer((_) async => VerifyEmailResponse(
          success: true,
          message: 'Email verified successfully',
          data: VerifyEmailResponseData(
            userId: 1,
            isVerified: true,
            requiresProfileCompletion: true,
          ),
        ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const EmailVerificationScreen(userId: 1),
          ),
        );

        await FormHelpers.fillEmailVerificationForm(tester);
        await TestHelpers.tapButton(tester, 'Verify Email');

        // Verify loading state
        AssertionHelpers.assertLoadingState(tester, 'Verifying...');
      });

      testWidgets('handles verification success', (WidgetTester tester) async {
        // Mock successful verification
        when(mockAuthApiService.verifyEmail(any)).thenAnswer((_) async => VerifyEmailResponse(
          success: true,
          message: 'Email verified successfully',
          data: VerifyEmailResponseData(
            userId: 1,
            isVerified: true,
            requiresProfileCompletion: true,
          ),
        ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const EmailVerificationScreen(userId: 1),
          ),
        );

        await FormHelpers.fillEmailVerificationForm(tester);
        await TestHelpers.tapButton(tester, 'Verify Email');
        await tester.pumpAndSettle();

        // Verify success message and navigation
        AssertionHelpers.assertSuccessMessage(tester, 'Email verified successfully');
        // Should navigate to profile completion screen
        AssertionHelpers.assertScreenTitle(tester, 'Complete Your Profile');
      });

      testWidgets('handles verification error', (WidgetTester tester) async {
        // Mock verification error
        when(mockAuthApiService.verifyEmail(any)).thenThrow(Exception('Invalid verification code'));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const EmailVerificationScreen(userId: 1),
          ),
        );

        await FormHelpers.fillEmailVerificationForm(tester);
        await TestHelpers.tapButton(tester, 'Verify Email');
        await tester.pumpAndSettle();

        // Verify error message
        AssertionHelpers.assertErrorState(tester, 'Invalid verification code');
      });

      testWidgets('resends verification code', (WidgetTester tester) async {
        // Mock successful resend
        when(mockAuthApiService.sendVerificationCode(any)).thenAnswer((_) async => VerificationResponse(
          success: true,
          message: 'Verification code sent',
          data: VerificationData(
            userId: 1,
            email: 'test@example.com',
            expiresAt: DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
          ),
        ));

        await tester.pumpWidget(
          MockProviderSetup.createAppWithProviders(
            appStateProvider: appStateProvider,
            child: const EmailVerificationScreen(userId: 1),
          ),
        );

        await TestHelpers.tapButton(tester, 'Resend Code');
        await tester.pumpAndSettle();

        // Verify success message
        AssertionHelpers.assertSuccessMessage(tester, 'Verification code sent');
      });
    });
  });
}