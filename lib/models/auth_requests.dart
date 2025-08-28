import 'package:flutter/foundation.dart';

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] as String,
      password: json['password'] as String,
      rememberMe: json['remember_me'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    };
  }

  String toFormData() {
    final data = toJson();
    return data.entries
        .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequest &&
        other.email == email &&
        other.password == password &&
        other.rememberMe == rememberMe;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode ^ rememberMe.hashCode;

  @override
  String toString() {
    return 'LoginRequest(email: $email, password: $password, rememberMe: $rememberMe)';
  }
}

class PhoneLoginRequest {
  final String phoneNumber;
  final String countryCode;

  const PhoneLoginRequest({
    required this.phoneNumber,
    required this.countryCode,
  });

  factory PhoneLoginRequest.fromJson(Map<String, dynamic> json) {
    return PhoneLoginRequest(
      phoneNumber: json['phone_number'] as String,
      countryCode: json['country_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'country_code': countryCode,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhoneLoginRequest &&
        other.phoneNumber == phoneNumber &&
        other.countryCode == countryCode;
  }

  @override
  int get hashCode => phoneNumber.hashCode ^ countryCode.hashCode;

  @override
  String toString() {
    return 'PhoneLoginRequest(phoneNumber: $phoneNumber, countryCode: $countryCode)';
  }
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      passwordConfirmation: json['password_confirmation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  String toFormData() {
    final data = toJson();
    return data.entries
        .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterRequest &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.email == email &&
        other.password == password &&
        other.passwordConfirmation == passwordConfirmation;
  }

  @override
  int get hashCode {
    return firstName.hashCode ^
        lastName.hashCode ^
        email.hashCode ^
        password.hashCode ^
        passwordConfirmation.hashCode;
  }

  @override
  String toString() {
    return 'RegisterRequest(firstName: $firstName, lastName: $lastName, email: $email, passwordConfirmation: $passwordConfirmation)';
  }
}

class VerificationRequest {
  final String email;
  final String code;

  const VerificationRequest({
    required this.email,
    required this.code,
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      email: json['email'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerificationRequest &&
        other.email == email &&
        other.code == code;
  }

  @override
  int get hashCode => email.hashCode ^ code.hashCode;

  @override
  String toString() {
    return 'VerificationRequest(email: $email, code: $code)';
  }
}

class OtpVerificationRequest {
  final String phoneNumber;
  final String countryCode;
  final String otpCode;

  const OtpVerificationRequest({
    required this.phoneNumber,
    required this.countryCode,
    required this.otpCode,
  });

  factory OtpVerificationRequest.fromJson(Map<String, dynamic> json) {
    return OtpVerificationRequest(
      phoneNumber: json['phone_number'] as String,
      countryCode: json['country_code'] as String,
      otpCode: json['otp_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'otp_code': otpCode,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtpVerificationRequest &&
        other.phoneNumber == phoneNumber &&
        other.countryCode == countryCode &&
        other.otpCode == otpCode;
  }

  @override
  int get hashCode => phoneNumber.hashCode ^ countryCode.hashCode ^ otpCode.hashCode;

  @override
  String toString() {
    return 'OtpVerificationRequest(phoneNumber: $phoneNumber, countryCode: $countryCode, otpCode: $otpCode)';
  }
}

class PasswordResetRequest {
  final String email;

  const PasswordResetRequest({
    required this.email,
  });

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) {
    return PasswordResetRequest(
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PasswordResetRequest && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;

  @override
  String toString() {
    return 'PasswordResetRequest(email: $email)';
  }
}

class ResendVerificationRequest {
  final String email;

  const ResendVerificationRequest({
    required this.email,
  });

  factory ResendVerificationRequest.fromJson(Map<String, dynamic> json) {
    return ResendVerificationRequest(
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResendVerificationRequest && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;

  @override
  String toString() {
    return 'ResendVerificationRequest(email: $email)';
  }
}
