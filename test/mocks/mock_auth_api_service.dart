import 'package:mockito/mockito.dart';
import 'package:lgbtinder/services/api_services/auth_api_service.dart';
import 'package:lgbtinder/models/api_models/auth_models.dart';

class MockAuthApiService extends Mock implements AuthApiService {
  @override
  Future<AuthResponse> login(AuthRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#login, [request]),
      returnValue: AuthResponse(
        success: true,
        message: 'Login successful',
        data: AuthResult(
          token: 'mock_token',
          refreshToken: 'mock_refresh_token',
          user: null, // Will be set by test
        ),
      ),
    );
  }

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#register, [request]),
      returnValue: RegisterResponse(
        success: true,
        message: 'Registration successful',
        data: RegisterResponseData(
          userId: 1,
          email: request.email,
          requiresEmailVerification: true,
        ),
      ),
    );
  }

  @override
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#verifyEmail, [request]),
      returnValue: VerifyEmailResponse(
        success: true,
        message: 'Email verified successfully',
        data: VerifyEmailResponseData(
          userId: request.userId,
          isVerified: true,
          requiresProfileCompletion: true,
        ),
      ),
    );
  }

  @override
  Future<VerificationResponse> sendVerificationCode(VerificationRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#sendVerificationCode, [request]),
      returnValue: VerificationResponse(
        success: true,
        message: 'Verification code sent',
        data: VerificationData(
          userId: request.userId,
          email: 'test@example.com',
          expiresAt: DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
        ),
      ),
    );
  }

  @override
  Future<CompleteProfileResponse> completeProfile(ProfileCompletionRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#completeProfile, [request]),
      returnValue: CompleteProfileResponse(
        success: true,
        message: 'Profile completed successfully',
        data: CompleteProfileResponseData(
          userId: request.userId,
          isProfileComplete: true,
        ),
      ),
    );
  }

  @override
  Future<CheckUserStateResponse> checkUserState(CheckUserStateRequest request) async {
    return super.noSuchMethod(
      Invocation.method(#checkUserState, [request]),
      returnValue: CheckUserStateResponse(
        success: true,
        data: CheckUserStateResponseData(
          userId: 1,
          state: 'ready_for_login',
          requiresEmailVerification: false,
          requiresProfileCompletion: false,
        ),
      ),
    );
  }
}
