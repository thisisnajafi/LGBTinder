// User State Models based on Authentication Implementation Guide

/// Abstract base class for all user states
abstract class UserState {
  const UserState();
  
  factory UserState.emailVerificationRequired(Map<String, dynamic> data) = 
    EmailVerificationRequiredState;
  factory UserState.profileCompletionRequired(Map<String, dynamic> data) = 
    ProfileCompletionRequiredState;
  factory UserState.readyForLogin(Map<String, dynamic> data) = 
    ReadyForLoginState;
  factory UserState.banned(Map<String, dynamic> data) = BannedState;
  factory UserState.error(String message) = ErrorState;
}

/// User needs to verify their email address
class EmailVerificationRequiredState extends UserState {
  final Map<String, dynamic> data;
  
  EmailVerificationRequiredState(this.data);
  
  int get userId => data['user_id'] as int;
  String get email => data['email'] as String;
  bool get needsVerification => data['needs_verification'] as bool? ?? true;
}

/// User needs to complete their profile
class ProfileCompletionRequiredState extends UserState {
  final Map<String, dynamic> data;
  
  ProfileCompletionRequiredState(this.data);
  
  int get userId => data['user_id'] as int;
  String get email => data['email'] as String;
  String get token => data['token'] as String;
  String get tokenType => data['token_type'] as String;
  Map<String, dynamic> get profileCompletionStatus => 
    data['profile_completion_status'] as Map<String, dynamic>;
  
  bool get isComplete => profileCompletionStatus['is_complete'] as bool? ?? false;
  List<String> get missingFields => 
    (profileCompletionStatus['missing_fields'] as List<dynamic>?)
        ?.map((field) => field as String)
        .toList() ?? [];
}

/// User is ready for login and can access the app
class ReadyForLoginState extends UserState {
  final Map<String, dynamic> data;
  
  ReadyForLoginState(this.data);
  
  int get userId => data['user_id'] as int;
  String get email => data['email'] as String;
  bool get profileCompleted => data['profile_completed'] as bool? ?? true;
}

/// User account is banned
class BannedState extends UserState {
  final Map<String, dynamic> data;
  
  BannedState(this.data);
  
  int get userId => data['user_id'] as int;
  String get email => data['email'] as String;
  String? get banReason => data['ban_reason'] as String?;
}

/// Error state when something goes wrong
class ErrorState extends UserState {
  final String message;
  
  ErrorState(this.message);
}

/// Auth Result for API responses
class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  
  AuthResult.success({required this.message, this.data}) : success = true;
  AuthResult.error(this.message) : success = false, data = null;
}

/// Error types for authentication
enum AuthErrorType {
  networkError,
  validationError,
  serverError,
  emailNotSent,
  invalidCode,
  userBanned,
  unknownError,
}

/// Authentication error model
class AuthError {
  final AuthErrorType type;
  final String message;
  final Map<String, dynamic>? details;
  
  AuthError({
    required this.type,
    required this.message,
    this.details,
  });
  
  factory AuthError.fromResponse(Map<String, dynamic> response) {
    final message = response['message'] ?? 'Unknown error';
    final errors = response['errors'];
    
    if (errors != null && errors is Map<String, dynamic>) {
      return AuthError(
        type: AuthErrorType.validationError,
        message: message,
        details: errors,
      );
    }
    
    return AuthError(
      type: AuthErrorType.serverError,
      message: message,
    );
  }
}
