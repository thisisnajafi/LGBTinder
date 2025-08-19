import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String _baseUrl = 'https://your-api-url.com/api'; // Replace with your actual API URL
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _secureStorage.read(key: _userKey);
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      // Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        await logout();
        return false;
      }
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Store token and user data
        await _secureStorage.write(key: _tokenKey, value: data['token']);
        
        if (data['user'] != null) {
          await _secureStorage.write(
            key: _userKey, 
            value: json.encode(data['user'])
          );
        }

        return {
          'success': true,
          'message': 'Login successful',
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Store token and user data
        await _secureStorage.write(key: _tokenKey, value: data['token']);
        
        if (data['user'] != null) {
          await _secureStorage.write(
            key: _userKey, 
            value: json.encode(data['user'])
          );
        }

        return {
          'success': true,
          'message': 'Registration successful',
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  // Get headers with authorization token
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Make authenticated API request
  Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await getAuthHeaders();
    final uri = Uri.parse('$_baseUrl$endpoint');

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
      case 'PUT':
        return await http.put(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Refresh token (if your API supports it)
  Future<bool> refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/refresh'),
        headers: await getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _secureStorage.write(key: _tokenKey, value: data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
} 