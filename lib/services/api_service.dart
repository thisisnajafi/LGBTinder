import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String _baseUrl = 'https://your-api-url.com/api'; // Replace with your actual API URL
  static const String _tokenKey = 'jwt_token';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get stored JWT token
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? json.decode(response.body) : {};

    switch (statusCode) {
      case 200:
      case 201:
        // Log success message
        print('✅ API Success: ${response.request?.url} - Status: $statusCode');
        return {
          'success': true,
          'data': body,
          'message': body['message'] ?? 'Success',
          'statusCode': statusCode,
        };
      
      case 204:
        // Log warning for no content
        print('⚠️ API Warning: No content available for the request - ${response.request?.url}');
        return {
          'success': true,
          'data': null,
          'message': 'No content available for the request.',
          'statusCode': statusCode,
        };
      
      case 400:
        print('❌ API Error 400: Bad Request - ${response.request?.url}');
        return {
          'success': false,
          'error': 'Bad Request',
          'message': 'Bad Request – Please check the request data and try again.',
          'errors': body['errors'],
          'statusCode': statusCode,
        };
      
      case 401:
        print('❌ API Error 401: Unauthorized - ${response.request?.url}');
        return {
          'success': false,
          'error': 'Unauthorized',
          'message': 'Unauthorized – Please login to continue.',
          'statusCode': statusCode,
        };
      
      case 403:
        print('❌ API Error 403: Forbidden - ${response.request?.url}');
        return {
          'success': false,
          'error': 'Forbidden',
          'message': 'Access Denied – You do not have permission to perform this action.',
          'statusCode': statusCode,
        };
      
      case 404:
        print('❌ API Error 404: Not Found - ${response.request?.url}');
        return {
          'success': false,
          'error': 'Not Found',
          'message': 'Not Found – The requested resource does not exist.',
          'statusCode': statusCode,
        };
      
      case 422:
        print('❌ API Error 422: Validation Error - ${response.request?.url}');
        return {
          'success': false,
          'error': 'Validation Error',
          'message': body['message'] ?? 'Validation failed',
          'errors': body['errors'],
          'statusCode': statusCode,
        };
      
      case 500:
        print('❌ API Error 500: Server Error - ${response.request?.url}');
        return {
          'success': false,
          'error': 'Server Error',
          'message': 'Server Error – Something went wrong, please try again later.',
          'statusCode': statusCode,
        };
      
      default:
        print('❌ API Error $statusCode: Unknown Error - ${response.request?.url}');
        return {
          'success': false,
          'error': 'Unknown Error',
          'message': 'An unexpected error occurred',
          'statusCode': statusCode,
        };
    }
  }

  // POST method for creating data
  Future<Map<String, dynamic>> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('http') ? endpoint : '$_baseUrl$endpoint';
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network Error in POST: ${e.toString()} - $endpoint');
      return {
        'success': false,
        'error': 'Network Error',
        'message': 'Failed to connect to server: ${e.toString()}',
        'statusCode': 0,
      };
    }
  }

  // GET method for retrieving data
  Future<Map<String, dynamic>> getData(String endpoint, {Map<String, String>? queryParameters}) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('http') ? endpoint : '$_baseUrl$endpoint';
      
      Uri uri = Uri.parse(url);
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await http.get(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network Error in GET: ${e.toString()} - $endpoint');
      return {
        'success': false,
        'error': 'Network Error',
        'message': 'Failed to connect to server: ${e.toString()}',
        'statusCode': 0,
      };
    }
  }

  // PUT method for updating data
  Future<Map<String, dynamic>> updateData(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('http') ? endpoint : '$_baseUrl$endpoint';
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network Error in PUT: ${e.toString()} - $endpoint');
      return {
        'success': false,
        'error': 'Network Error',
        'message': 'Failed to connect to server: ${e.toString()}',
        'statusCode': 0,
      };
    }
  }

  // PATCH method for partial updates
  Future<Map<String, dynamic>> patchData(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('http') ? endpoint : '$_baseUrl$endpoint';
      
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network Error in PATCH: ${e.toString()} - $endpoint');
      return {
        'success': false,
        'error': 'Network Error',
        'message': 'Failed to connect to server: ${e.toString()}',
        'statusCode': 0,
      };
    }
  }

  // DELETE method for removing data
  Future<Map<String, dynamic>> deleteData(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('http') ? endpoint : '$_baseUrl$endpoint';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network Error in DELETE: ${e.toString()} - $endpoint');
      return {
        'success': false,
        'error': 'Network Error',
        'message': 'Failed to connect to server: ${e.toString()}',
        'statusCode': 0,
      };
    }
  }

  // Upload file with data
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    Map<String, String> fields,
    Map<String, http.MultipartFile> files,
  ) async {
    try {
      final token = await _getToken();
      final headers = {
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final url = endpoint.startsWith('http') ? endpoint : '$_baseUrl$endpoint';
      
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.fields.addAll(fields);
      request.files.addAll(files.values);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network Error in File Upload: ${e.toString()} - $endpoint');
      return {
        'success': false,
        'error': 'Network Error',
        'message': 'Failed to upload file: ${e.toString()}',
        'statusCode': 0,
      };
    }
  }

  // Generic method for any HTTP request
  Future<Map<String, dynamic>> request(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = endpoint.startsWith('http') ? endpoint : '$_baseUrl$endpoint';
      
      Uri uri = Uri.parse(url);
      if (queryParameters != null) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network Error in Generic Request: ${e.toString()} - $endpoint');
      return {
        'success': false,
        'error': 'Network Error',
        'message': 'Request failed: ${e.toString()}',
        'statusCode': 0,
      };
    }
  }
  
  // Alias methods for compatibility with existing services
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParameters, Map<String, String>? queryParams}) {
    return getData(endpoint, queryParameters: queryParameters ?? queryParams);
  }
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) {
    return postData(endpoint, data);
  }
  
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) {
    return updateData(endpoint, data);
  }
  
  Future<Map<String, dynamic>> delete(String endpoint) {
    return deleteData(endpoint);
  }
} 