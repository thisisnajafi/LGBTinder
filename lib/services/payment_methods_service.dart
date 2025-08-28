import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class PaymentMethodsService {
  /// Get available payment methods
  static Future<List<Map<String, dynamic>>> getPaymentMethods({
    String? accessToken,
    String? currency,
    String? country,
    bool? activeOnly,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.paymentMethods));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      if (country != null) queryParams['country'] = country;
      if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch payment methods: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment methods: $e');
    }
  }

  /// Get payment method by ID
  static Future<Map<String, dynamic>> getPaymentMethod(String methodId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsById, {'id': methodId})),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment method not found');
      } else {
        throw ApiException('Failed to fetch payment method: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment method: $e');
    }
  }

  /// Get payment methods by currency
  static Future<List<Map<String, dynamic>>> getPaymentMethodsByCurrency(String currency, {
    String? accessToken,
    String? country,
    String? type,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsCurrency, {'currency': currency}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (country != null) queryParams['country'] = country;
      if (type != null) queryParams['type'] = type;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('No payment methods found for this currency');
      } else {
        throw ApiException('Failed to fetch payment methods by currency: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment methods by currency: $e');
    }
  }

  /// Get payment methods by type
  static Future<List<Map<String, dynamic>>> getPaymentMethodsByType(String type, {
    String? accessToken,
    String? currency,
    String? country,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsType, {'type': type}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      if (country != null) queryParams['country'] = country;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('No payment methods found for this type');
      } else {
        throw ApiException('Failed to fetch payment methods by type: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment methods by type: $e');
    }
  }

  /// Validate payment amount
  static Future<Map<String, dynamic>> validatePaymentAmount({
    required int amount,
    required String currency,
    required String paymentMethodId,
    String? accessToken,
    String? country,
  }) async {
    try {
      final requestBody = {
        'amount': amount,
        'currency': currency,
        'payment_method_id': paymentMethodId,
      };

      if (country != null) requestBody['country'] = country;

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.paymentMethodsValidate)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid payment amount or method',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to validate payment amount: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while validating payment amount: $e');
    }
  }

  /// Get payment method requirements
  static Future<Map<String, dynamic>> getPaymentMethodRequirements(String methodId, {
    String? accessToken,
    String? currency,
    String? country,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsById, {'id': methodId}) + '/requirements');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      if (country != null) queryParams['country'] = country;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment method not found');
      } else {
        throw ApiException('Failed to fetch payment method requirements: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment method requirements: $e');
    }
  }

  /// Get supported currencies for a payment method
  static Future<List<String>> getSupportedCurrencies(String methodId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsById, {'id': methodId}) + '/currencies'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> currencies = data['data'] ?? data;
        return currencies.cast<String>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment method not found');
      } else {
        throw ApiException('Failed to fetch supported currencies: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching supported currencies: $e');
    }
  }

  /// Get payment method fees
  static Future<Map<String, dynamic>> getPaymentMethodFees(String methodId, {
    String? accessToken,
    int? amount,
    String? currency,
    String? country,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsById, {'id': methodId}) + '/fees');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (amount != null) queryParams['amount'] = amount.toString();
      if (currency != null) queryParams['currency'] = currency;
      if (country != null) queryParams['country'] = country;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment method not found');
      } else {
        throw ApiException('Failed to fetch payment method fees: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment method fees: $e');
    }
  }

  /// Check payment method availability
  static Future<Map<String, dynamic>> checkPaymentMethodAvailability({
    required String methodId,
    String? accessToken,
    String? currency,
    String? country,
    int? amount,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsById, {'id': methodId}) + '/availability');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      if (country != null) queryParams['country'] = country;
      if (amount != null) queryParams['amount'] = amount.toString();
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment method not found');
      } else {
        throw ApiException('Failed to check payment method availability: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while checking payment method availability: $e');
    }
  }

  /// Get payment method limits
  static Future<Map<String, dynamic>> getPaymentMethodLimits(String methodId, {
    String? accessToken,
    String? currency,
    String? country,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsById, {'id': methodId}) + '/limits');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      if (country != null) queryParams['country'] = country;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment method not found');
      } else {
        throw ApiException('Failed to fetch payment method limits: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment method limits: $e');
    }
  }

  /// Get recommended payment methods
  static Future<List<Map<String, dynamic>>> getRecommendedPaymentMethods({
    String? accessToken,
    String? currency,
    String? country,
    int? amount,
    String? customerType, // 'new', 'returning', 'premium'
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.paymentMethods) + '/recommended');
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (currency != null) queryParams['currency'] = currency;
      if (country != null) queryParams['country'] = country;
      if (amount != null) queryParams['amount'] = amount.toString();
      if (customerType != null) queryParams['customer_type'] = customerType;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch recommended payment methods: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching recommended payment methods: $e');
    }
  }

  /// Get payment method icons
  static Future<Map<String, String>> getPaymentMethodIcons(String methodId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.paymentMethodsById, {'id': methodId}) + '/icons'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> icons = data['data'] ?? data;
        return icons.cast<String, String>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Payment method not found');
      } else {
        throw ApiException('Failed to fetch payment method icons: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching payment method icons: $e');
    }
  }
}
