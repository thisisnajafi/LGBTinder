import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import '../../lib/services/auth_service.dart';
import '../../lib/models/auth_requests.dart';
import '../../lib/models/auth_responses.dart';
import '../../lib/utils/error_handler.dart';
import '../api_test_utils.dart';

@GenerateMocks([http.Client])
void main() {
  group('AuthService Tests', () {
    late MockHttpClient mockClient;
    
    setUp(() {
      mockClient = MockHttpClient();
    });
    
    group('Register', () {
      test('should register user successfully', () async {
        // Arrange
        final request = RegisterRequest(
          email: 'test@example.com',
          password: 'password123',
          name: 'Test User',
          age: 25,
          gender: 'non-binary',
          preferredGender: 'all',
        );
        
        final responseData = {
          'user': ApiTestUtils.createTestUser(),
          'access_token': 'test_access_token',
          'refresh_token': 'test_refresh_token',
        };
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await AuthService.register(request);
        
        // Assert
        expect(result, isA<AuthResponse>());
        expect(result.user, isNotNull);
        expect(result.accessToken, isNotNull);
        expect(result.refreshToken, isNotNull);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/register',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should handle validation errors', () async {
        // Arrange
        final request = RegisterRequest(
          email: 'invalid-email',
          password: '123',
          name: '',
          age: 15,
          gender: 'invalid',
          preferredGender: 'invalid',
        );
        
        final validationErrors = {
          'email': ['The email must be a valid email address.'],
          'password': ['The password must be at least 8 characters.'],
          'name': ['The name field is required.'],
          'age': ['The age must be at least 18.'],
          'gender': ['The selected gender is invalid.'],
          'preferred_gender': ['The selected preferred gender is invalid.'],
        };
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createValidationErrorResponse(errors: validationErrors));
        
        // Act & Assert
        expect(
          () => AuthService.register(request),
          throwsA(isA<ValidationException>()),
        );
      });
      
      test('should handle email already exists error', () async {
        // Arrange
        final request = RegisterRequest(
          email: 'existing@example.com',
          password: 'password123',
          name: 'Test User',
          age: 25,
          gender: 'non-binary',
          preferredGender: 'all',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 409,
          message: 'Email already exists',
        ));
        
        // Act & Assert
        expect(
          () => AuthService.register(request),
          throwsA(isA<ApiException>()),
        );
      });
    });
    
    group('Login', () {
      test('should login user successfully', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        final responseData = {
          'user': ApiTestUtils.createTestUser(),
          'access_token': 'test_access_token',
          'refresh_token': 'test_refresh_token',
        };
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await AuthService.login(request);
        
        // Assert
        expect(result, isA<AuthResponse>());
        expect(result.user, isNotNull);
        expect(result.accessToken, isNotNull);
        expect(result.refreshToken, isNotNull);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/login',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should handle invalid credentials', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'wrongpassword',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 401,
          message: 'Invalid credentials',
        ));
        
        // Act & Assert
        expect(
          () => AuthService.login(request),
          throwsA(isA<AuthException>()),
        );
      });
      
      test('should handle account not verified', () async {
        // Arrange
        final request = LoginRequest(
          email: 'unverified@example.com',
          password: 'password123',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 403,
          message: 'Account not verified',
        ));
        
        // Act & Assert
        expect(
          () => AuthService.login(request),
          throwsA(isA<AuthException>()),
        );
      });
    });
    
    group('Email Verification', () {
      test('should send verification email successfully', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Verification email sent'},
        ));
        
        // Act
        final result = await AuthService.sendVerificationEmail('test@example.com');
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/send-verification-email',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode({'email': 'test@example.com'}),
        );
      });
      
      test('should verify email successfully', () async {
        // Arrange
        final request = VerifyEmailRequest(
          email: 'test@example.com',
          token: 'verification_token',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Email verified successfully'},
        ));
        
        // Act
        final result = await AuthService.verifyEmail(request);
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/verify-email',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should handle invalid verification token', () async {
        // Arrange
        final request = VerifyEmailRequest(
          email: 'test@example.com',
          token: 'invalid_token',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 400,
          message: 'Invalid verification token',
        ));
        
        // Act & Assert
        expect(
          () => AuthService.verifyEmail(request),
          throwsA(isA<ApiException>()),
        );
      });
    });
    
    group('Password Management', () {
      test('should send password reset email successfully', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Password reset email sent'},
        ));
        
        // Act
        final result = await AuthService.sendPasswordResetEmail('test@example.com');
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/send-password-reset-email',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode({'email': 'test@example.com'}),
        );
      });
      
      test('should reset password successfully', () async {
        // Arrange
        final request = ResetPasswordRequest(
          email: 'test@example.com',
          token: 'reset_token',
          password: 'newpassword123',
          passwordConfirmation: 'newpassword123',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Password reset successfully'},
        ));
        
        // Act
        final result = await AuthService.resetPassword(request);
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/reset-password',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should change password successfully', () async {
        // Arrange
        final request = ChangePasswordRequest(
          currentPassword: 'oldpassword123',
          newPassword: 'newpassword123',
          newPasswordConfirmation: 'newpassword123',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Password changed successfully'},
        ));
        
        // Act
        final result = await AuthService.changePassword(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/change-password',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should handle invalid current password', () async {
        // Arrange
        final request = ChangePasswordRequest(
          currentPassword: 'wrongpassword',
          newPassword: 'newpassword123',
          newPasswordConfirmation: 'newpassword123',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 400,
          message: 'Current password is incorrect',
        ));
        
        // Act & Assert
        expect(
          () => AuthService.changePassword(request, ApiTestUtils.testAccessToken),
          throwsA(isA<ApiException>()),
        );
      });
    });
    
    group('Token Management', () {
      test('should refresh token successfully', () async {
        // Arrange
        final request = RefreshTokenRequest(
          refreshToken: 'test_refresh_token',
        );
        
        final responseData = {
          'access_token': 'new_access_token',
          'refresh_token': 'new_refresh_token',
        };
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await AuthService.refreshToken(request);
        
        // Assert
        expect(result, isA<TokenResponse>());
        expect(result.accessToken, isNotNull);
        expect(result.refreshToken, isNotNull);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/refresh-token',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should handle invalid refresh token', () async {
        // Arrange
        final request = RefreshTokenRequest(
          refreshToken: 'invalid_refresh_token',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 401,
          message: 'Invalid refresh token',
        ));
        
        // Act & Assert
        expect(
          () => AuthService.refreshToken(request),
          throwsA(isA<AuthException>()),
        );
      });
      
      test('should logout successfully', () async {
        // Arrange
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Logged out successfully'},
        ));
        
        // Act
        final result = await AuthService.logout(ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/logout',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
    });
    
    group('Account Management', () {
      test('should delete account successfully', () async {
        // Arrange
        final request = DeleteAccountRequest(
          password: 'password123',
          reason: 'No longer needed',
        );
        
        when(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Account deleted successfully'},
        ));
        
        // Act
        final result = await AuthService.deleteAccount(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'DELETE',
          '/auth/account',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should handle invalid password for account deletion', () async {
        // Arrange
        final request = DeleteAccountRequest(
          password: 'wrongpassword',
          reason: 'No longer needed',
        );
        
        when(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 400,
          message: 'Invalid password',
        ));
        
        // Act & Assert
        expect(
          () => AuthService.deleteAccount(request, ApiTestUtils.testAccessToken),
          throwsA(isA<ApiException>()),
        );
      });
    });
    
    group('Social Login', () {
      test('should login with Google successfully', () async {
        // Arrange
        final request = SocialLoginRequest(
          provider: 'google',
          token: 'google_token',
        );
        
        final responseData = {
          'user': ApiTestUtils.createTestUser(),
          'access_token': 'test_access_token',
          'refresh_token': 'test_refresh_token',
        };
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await AuthService.socialLogin(request);
        
        // Assert
        expect(result, isA<AuthResponse>());
        expect(result.user, isNotNull);
        expect(result.accessToken, isNotNull);
        expect(result.refreshToken, isNotNull);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/social-login',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should login with Apple successfully', () async {
        // Arrange
        final request = SocialLoginRequest(
          provider: 'apple',
          token: 'apple_token',
        );
        
        final responseData = {
          'user': ApiTestUtils.createTestUser(),
          'access_token': 'test_access_token',
          'refresh_token': 'test_refresh_token',
        };
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await AuthService.socialLogin(request);
        
        // Assert
        expect(result, isA<AuthResponse>());
        expect(result.user, isNotNull);
        expect(result.accessToken, isNotNull);
        expect(result.refreshToken, isNotNull);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/auth/social-login',
          headers: ApiTestUtils.createTestHeaders(),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should handle invalid social token', () async {
        // Arrange
        final request = SocialLoginRequest(
          provider: 'google',
          token: 'invalid_token',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 401,
          message: 'Invalid social token',
        ));
        
        // Act & Assert
        expect(
          () => AuthService.socialLogin(request),
          throwsA(isA<AuthException>()),
        );
      });
    });
    
    group('Rate Limiting', () {
      test('should handle rate limit exceeded', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createRateLimitResponse(retryAfter: 60));
        
        // Act & Assert
        expect(
          () => AuthService.login(request),
          throwsA(isA<RateLimitException>()),
        );
      });
    });
    
    group('Network Errors', () {
      test('should handle network timeout', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(TimeoutException('Request timeout', Duration(seconds: 30)));
        
        // Act & Assert
        expect(
          () => AuthService.login(request),
          throwsA(isA<TimeoutException>()),
        );
      });
      
      test('should handle network connection error', () async {
        // Arrange
        final request = LoginRequest(
          email: 'test@example.com',
          password: 'password123',
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(SocketException('No internet connection'));
        
        // Act & Assert
        expect(
          () => AuthService.login(request),
          throwsA(isA<SocketException>()),
        );
      });
    });
  });
}
