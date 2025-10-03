import 'dart:convert';

/// Common API Models
/// 
/// This file contains common data models used across all API endpoints
/// including pagination, error responses, and utility models.

// ============================================================================
// PAGINATION MODELS
// ============================================================================

/// Pagination data model
class PaginationData {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final bool hasNext;
  final bool hasPrev;

  const PaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalItems: json['total_items'] as int,
      perPage: json['per_page'] as int,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrev: json['has_prev'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'per_page': perPage,
      'has_next': hasNext,
      'has_prev': hasPrev,
    };
  }

  /// Check if there are more pages
  bool get hasNextPage => hasNext;

  /// Check if there are previous pages
  bool get hasPreviousPage => hasPrev;

  /// Get next page number
  int? get nextPage => hasNextPage ? currentPage + 1 : null;

  /// Get previous page number
  int? get previousPage => hasPreviousPage ? currentPage - 1 : null;

  /// Get total number of items
  int get totalCount => totalItems;

  /// Get items per page
  int get pageSize => perPage;

  /// Get current page number
  int get pageNumber => currentPage;
}

// ============================================================================
// ERROR RESPONSE MODELS
// ============================================================================

/// API error response model
class ApiErrorResponse {
  final bool status;
  final String message;
  final Map<String, List<String>>? errors;
  final String? error;
  final int? code;

  const ApiErrorResponse({
    required this.status,
    required this.message,
    this.errors,
    this.error,
    this.code,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      errors: json['errors'] != null 
          ? Map<String, List<String>>.from(
              (json['errors'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, List<String>.from(value as List)),
              ),
            )
          : null,
      error: json['error'] as String?,
      code: json['code'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (errors != null) 'errors': errors,
      if (error != null) 'error': error,
      if (code != null) 'code': code,
    };
  }

  /// Check if response has validation errors
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  /// Get first validation error
  String? get firstValidationError {
    if (errors == null || errors!.isEmpty) return null;
    final firstError = errors!.values.first;
    return firstError.isNotEmpty ? firstError.first : null;
  }

  /// Get all validation errors as a single string
  String get allValidationErrors {
    if (errors == null || errors!.isEmpty) return message;
    
    final List<String> allErrors = [];
    for (final fieldErrors in errors!.values) {
      allErrors.addAll(fieldErrors);
    }
    return allErrors.join(', ');
  }
}

// ============================================================================
// SUCCESS RESPONSE MODELS
// ============================================================================

/// Generic success response model
class ApiSuccessResponse<T> {
  final bool status;
  final String message;
  final T? data;

  const ApiSuccessResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiSuccessResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiSuccessResponse<T>(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : json['data'] as T?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data,
    };
  }
}

// ============================================================================
// RATE LIMITING MODELS
// ============================================================================

/// Rate limiting response data model
class RateLimitData {
  final int retryAfter;

  const RateLimitData({
    required this.retryAfter,
  });

  factory RateLimitData.fromJson(Map<String, dynamic> json) {
    return RateLimitData(
      retryAfter: json['retry_after'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'retry_after': retryAfter,
    };
  }
}

/// Rate limiting response model
class RateLimitResponse {
  final bool status;
  final String message;
  final RateLimitData? data;

  const RateLimitResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory RateLimitResponse.fromJson(Map<String, dynamic> json) {
    return RateLimitResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? RateLimitData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

// ============================================================================
// WEBSOCKET MODELS
// ============================================================================

/// WebSocket event types
enum WebSocketEventType {
  messageReceived,
  userTyping,
  matchCreated,
  userOnline,
  userOffline,
}

/// WebSocket event type extension
extension WebSocketEventTypeExtension on WebSocketEventType {
  String get value {
    switch (this) {
      case WebSocketEventType.messageReceived:
        return 'message.received';
      case WebSocketEventType.userTyping:
        return 'user.typing';
      case WebSocketEventType.matchCreated:
        return 'match.created';
      case WebSocketEventType.userOnline:
        return 'user.online';
      case WebSocketEventType.userOffline:
        return 'user.offline';
    }
  }

  static WebSocketEventType fromString(String value) {
    switch (value) {
      case 'message.received':
        return WebSocketEventType.messageReceived;
      case 'user.typing':
        return WebSocketEventType.userTyping;
      case 'match.created':
        return WebSocketEventType.matchCreated;
      case 'user.online':
        return WebSocketEventType.userOnline;
      case 'user.offline':
        return WebSocketEventType.userOffline;
      default:
        return WebSocketEventType.messageReceived;
    }
  }
}

/// WebSocket event data model
class WebSocketEvent {
  final WebSocketEventType event;
  final Map<String, dynamic> data;

  const WebSocketEvent({
    required this.event,
    required this.data,
  });

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(
      event: WebSocketEventTypeExtension.fromString(json['event'] as String),
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event.value,
      'data': data,
    };
  }
}

// ============================================================================
// UTILITY MODELS
// ============================================================================

/// API response status enumeration
enum ApiResponseStatus {
  success,
  error,
  validationError,
  unauthorized,
  forbidden,
  notFound,
  rateLimited,
  serverError,
}

/// API response status extension
extension ApiResponseStatusExtension on ApiResponseStatus {
  String get value {
    switch (this) {
      case ApiResponseStatus.success:
        return 'success';
      case ApiResponseStatus.error:
        return 'error';
      case ApiResponseStatus.validationError:
        return 'validation_error';
      case ApiResponseStatus.unauthorized:
        return 'unauthorized';
      case ApiResponseStatus.forbidden:
        return 'forbidden';
      case ApiResponseStatus.notFound:
        return 'not_found';
      case ApiResponseStatus.rateLimited:
        return 'rate_limited';
      case ApiResponseStatus.serverError:
        return 'server_error';
    }
  }

  static ApiResponseStatus fromString(String value) {
    switch (value) {
      case 'success':
        return ApiResponseStatus.success;
      case 'error':
        return ApiResponseStatus.error;
      case 'validation_error':
        return ApiResponseStatus.validationError;
      case 'unauthorized':
        return ApiResponseStatus.unauthorized;
      case 'forbidden':
        return ApiResponseStatus.forbidden;
      case 'not_found':
        return ApiResponseStatus.notFound;
      case 'rate_limited':
        return ApiResponseStatus.rateLimited;
      case 'server_error':
        return ApiResponseStatus.serverError;
      default:
        return ApiResponseStatus.error;
    }
  }
}

/// HTTP status code enumeration
enum HttpStatusCode {
  ok(200),
  created(201),
  noContent(204),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  methodNotAllowed(405),
  conflict(409),
  unprocessableEntity(422),
  tooManyRequests(429),
  internalServerError(500),
  badGateway(502),
  serviceUnavailable(503),
  gatewayTimeout(504);

  const HttpStatusCode(this.code);
  final int code;

  static HttpStatusCode fromCode(int code) {
    for (final status in HttpStatusCode.values) {
      if (status.code == code) return status;
    }
    return HttpStatusCode.internalServerError;
  }
}

// ============================================================================
// COMMON UTILITIES
// ============================================================================

/// Common API utilities
class ApiUtils {
  /// Check if HTTP status code indicates success
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if HTTP status code indicates client error
  static bool isClientErrorStatusCode(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Check if HTTP status code indicates server error
  static bool isServerErrorStatusCode(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Get API response status from HTTP status code
  static ApiResponseStatus getApiResponseStatus(int statusCode) {
    if (isSuccessStatusCode(statusCode)) {
      return ApiResponseStatus.success;
    } else if (statusCode == 401) {
      return ApiResponseStatus.unauthorized;
    } else if (statusCode == 403) {
      return ApiResponseStatus.forbidden;
    } else if (statusCode == 404) {
      return ApiResponseStatus.notFound;
    } else if (statusCode == 422) {
      return ApiResponseStatus.validationError;
    } else if (statusCode == 429) {
      return ApiResponseStatus.rateLimited;
    } else if (isServerErrorStatusCode(statusCode)) {
      return ApiResponseStatus.serverError;
    } else {
      return ApiResponseStatus.error;
    }
  }

  /// Get error message from response data
  static String getErrorMessage(Map<String, dynamic> responseData) {
    if (responseData.containsKey('message')) {
      return responseData['message'] as String;
    }
    if (responseData.containsKey('error')) {
      return responseData['error'] as String;
    }
    return 'Unknown error occurred';
  }

  /// Get validation errors from response data
  static Map<String, List<String>>? getValidationErrors(Map<String, dynamic> responseData) {
    if (responseData.containsKey('errors') && responseData['errors'] != null) {
      final errors = responseData['errors'] as Map<String, dynamic>;
      return errors.map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      );
    }
    return null;
  }

  /// Check if response has validation errors
  static bool hasValidationErrors(Map<String, dynamic> responseData) {
    final errors = getValidationErrors(responseData);
    return errors != null && errors.isNotEmpty;
  }

  /// Get first validation error
  static String? getFirstValidationError(Map<String, dynamic> responseData) {
    final errors = getValidationErrors(responseData);
    if (errors == null || errors.isEmpty) return null;
    final firstError = errors.values.first;
    return firstError.isNotEmpty ? firstError.first : null;
  }

  /// Get all validation errors as a single string
  static String getAllValidationErrors(Map<String, dynamic> responseData) {
    final errors = getValidationErrors(responseData);
    if (errors == null || errors.isEmpty) {
      return getErrorMessage(responseData);
    }
    
    final List<String> allErrors = [];
    for (final fieldErrors in errors.values) {
      allErrors.addAll(fieldErrors);
    }
    return allErrors.join(', ');
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  /// Validate URL format
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sanitize string for API usage
  static String sanitizeString(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Format date for API usage
  static String formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// Parse date from API response
  static DateTime? parseDateFromApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Format datetime for API usage
  static String formatDateTimeForApi(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Parse datetime from API response
  static DateTime? parseDateTimeFromApi(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
}
