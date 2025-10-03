/// Common exceptions used across the application

/// Network-related exceptions
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// API-related exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// Validation-related exceptions
class ValidationException implements Exception {
  final String message;
  final List<String> fields;

  const ValidationException({
    required this.message,
    required this.fields,
  });

  @override
  String toString() {
    return message;
  }
}

/// Authentication-related exceptions
class AuthenticationException implements Exception {
  final String message;
  final String? details;

  const AuthenticationException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// Authorization-related exceptions
class AuthorizationException implements Exception {
  final String message;
  final String? details;

  const AuthorizationException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// Cache-related exceptions
class CacheException implements Exception {
  final String message;
  final String? details;

  const CacheException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// File-related exceptions
class FileException implements Exception {
  final String message;
  final String? details;

  const FileException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// Database-related exceptions
class DatabaseException implements Exception {
  final String message;
  final String? details;

  const DatabaseException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// WebSocket-related exceptions
class WebSocketException implements Exception {
  final String message;
  final String? details;

  const WebSocketException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// Location-related exceptions
class LocationException implements Exception {
  final String message;
  final String? details;

  const LocationException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}

/// Permission-related exceptions
class PermissionException implements Exception {
  final String message;
  final String? details;

  const PermissionException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return message;
  }
}
