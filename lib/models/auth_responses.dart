import 'auth_user.dart';

class LoginResponse {
  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginResponse &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.tokenType == tokenType &&
        other.expiresIn == expiresIn;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        tokenType.hashCode ^
        expiresIn.hashCode;
  }

  @override
  String toString() {
    return 'LoginResponse(user: $user, accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn)';
  }
}

class RegisterResponse {
  final bool status;
  final String message;
  final RegisterResponseData? data;
  final Map<String, List<String>>? errors;
  final String? error;

  const RegisterResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
    this.error,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 RegisterResponse.fromJson called with: $json');
    try {
      final result = RegisterResponse(
        status: json['status'] as bool,
        message: json['message'] as String,
        data: json['data'] != null 
            ? RegisterResponseData.fromJson(json['data'] as Map<String, dynamic>)
            : null,
        errors: json['errors'] != null 
            ? Map<String, List<String>>.from(
                (json['errors'] as Map<String, dynamic>).map(
                  (key, value) => MapEntry(
                    key, 
                    (value as List).cast<String>(),
                  ),
                ),
              )
            : null,
        error: json['error'] as String?,
      );
      print('🔍 RegisterResponse created successfully');
      return result;
    } catch (e) {
      print('💥 Error in RegisterResponse.fromJson: $e');
      print('💥 JSON data: $json');
      rethrow;
    }
  }

  bool get isSuccess => status && data != null;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get isServerError => error != null;
}

class RegisterResponseData {
  final String userId;
  final String email;
  final String resendAvailableAt;
  final int hourlyAttemptsRemaining;

  const RegisterResponseData({
    required this.userId,
    required this.email,
    required this.resendAvailableAt,
    required this.hourlyAttemptsRemaining,
  });

  factory RegisterResponseData.fromJson(Map<String, dynamic> json) {
    return RegisterResponseData(
      userId: json['user_id'].toString(), // Convert int or String to String
      email: json['email'] as String,
      resendAvailableAt: json['resend_available_at'] as String,
      hourlyAttemptsRemaining: json['hourly_attempts_remaining'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'resend_available_at': resendAvailableAt,
      'hourly_attempts_remaining': hourlyAttemptsRemaining,
    };
  }
}

class VerificationResponse {
  final bool success;
  final String message;
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;

  const VerificationResponse({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: json['user'] != null
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationResponse &&
        other.success == success &&
        other.message == message &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        user.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode;
  }

  @override
  String toString() {
    return 'VerificationResponse(success: $success, message: $message, user: $user, accessToken: $accessToken, refreshToken: $refreshToken)';
  }
}

class OtpVerificationResponse {
  final bool success;
  final String message;
  final AuthUser? user;
  final String? accessToken;
  final String? refreshToken;

  const OtpVerificationResponse({
    required this.success,
    required this.message,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerificationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: json['user'] != null
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtpVerificationResponse &&
        other.success == success &&
        other.message == message &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        user.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode;
  }

  @override
  String toString() {
    return 'OtpVerificationResponse(success: $success, message: $message, user: $user, accessToken: $accessToken, refreshToken: $refreshToken)';
  }
}

class PasswordResetResponse {
  final bool success;
  final String message;
  final String? resetToken;

  const PasswordResetResponse({
    required this.success,
    required this.message,
    this.resetToken,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      resetToken: json['reset_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'reset_token': resetToken,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordResetResponse &&
        other.success == success &&
        other.message == message &&
        other.resetToken == resetToken;
  }

  @override
  int get hashCode {
    return success.hashCode ^ message.hashCode ^ resetToken.hashCode;
  }

  @override
  String toString() {
    return 'PasswordResetResponse(success: $success, message: $message, resetToken: $resetToken)';
  }
}

class ResendVerificationResponse {
  final bool success;
  final String message;
  final int cooldownSeconds;

  const ResendVerificationResponse({
    required this.success,
    required this.message,
    required this.cooldownSeconds,
  });

  factory ResendVerificationResponse.fromJson(Map<String, dynamic> json) {
    return ResendVerificationResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      cooldownSeconds: json['cooldown_seconds'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'cooldown_seconds': cooldownSeconds,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResendVerificationResponse &&
        other.success == success &&
        other.message == message &&
        other.cooldownSeconds == cooldownSeconds;
  }

  @override
  int get hashCode {
    return success.hashCode ^ message.hashCode ^ cooldownSeconds.hashCode;
  }

  @override
  String toString() {
    return 'ResendVerificationResponse(success: $success, message: $message, cooldownSeconds: $cooldownSeconds)';
  }
}

class TokenRefreshResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const TokenRefreshResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenRefreshResponse &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.tokenType == tokenType &&
        other.expiresIn == expiresIn;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        refreshToken.hashCode ^
        tokenType.hashCode ^
        expiresIn.hashCode;
  }

  @override
  String toString() {
    return 'TokenRefreshResponse(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn)';
  }
}
