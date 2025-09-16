import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/profile_service.dart';
import '../services/chat_service.dart';

class ApiTest {
  /// Test basic API connectivity
  static Future<bool> testApiConnectivity() async {
    try {
      print('🔍 Testing API connectivity...');
      print('🌐 Base URL: ${ApiConfig.baseUrl}');
      
      // Test a simple endpoint (we'll use the profile endpoint as it should exist)
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      // Even if we get 401 (unauthorized), it means the API is reachable
      if (response.statusCode == 200 || response.statusCode == 401) {
        print('✅ API is reachable');
        return true;
      } else {
        print('❌ API returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 API connectivity test failed: $e');
      return false;
    }
  }
  
  /// Test authentication endpoint
  static Future<bool> testAuthEndpoint() async {
    try {
      print('🔍 Testing auth endpoint...');
      
      // Test with invalid credentials to see if endpoint responds
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.login)),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: 'email=test@example.com&password=invalid',
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Auth endpoint status: ${response.statusCode}');
      print('📡 Auth endpoint response: ${response.body}');
      
      // We expect 401 or 422 for invalid credentials, which means endpoint is working
      if (response.statusCode == 401 || response.statusCode == 422) {
        print('✅ Auth endpoint is working');
        return true;
      } else {
        print('❌ Auth endpoint returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Auth endpoint test failed: $e');
      return false;
    }
  }
  
  /// Test registration endpoint
  static Future<bool> testRegistrationEndpoint() async {
    try {
      print('🔍 Testing registration endpoint...');
      
      // Test with invalid data to see if endpoint responds
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.register)),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: 'email=test@example.com&password=test&first_name=Test&last_name=User',
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Registration endpoint status: ${response.statusCode}');
      print('📡 Registration endpoint response: ${response.body}');
      
      // We expect 422 for validation errors, which means endpoint is working
      if (response.statusCode == 200 || response.statusCode == 422) {
        print('✅ Registration endpoint is working');
        return true;
      } else {
        print('❌ Registration endpoint returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Registration endpoint test failed: $e');
      return false;
    }
  }
  
  /// Test profile management endpoints
  static Future<bool> testProfileEndpoints() async {
    try {
      print('🔍 Testing profile endpoints...');
      
      // Test profile endpoint without authentication (should return 401)
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profile)),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Profile endpoint status: ${response.statusCode}');
      print('📡 Profile endpoint response: ${response.body}');
      
      // We expect 401 for unauthenticated requests, which means endpoint is working
      if (response.statusCode == 401) {
        print('✅ Profile endpoint is working (requires authentication)');
        return true;
      } else {
        print('❌ Profile endpoint returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Profile endpoint test failed: $e');
      return false;
    }
  }
  
  /// Test profile update endpoint
  static Future<bool> testProfileUpdateEndpoint() async {
    try {
      print('🔍 Testing profile update endpoint...');
      
      // Test profile update endpoint without authentication (should return 401)
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profileUpdate)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'first_name': 'Test',
          'last_name': 'User',
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Profile update endpoint status: ${response.statusCode}');
      print('📡 Profile update endpoint response: ${response.body}');
      
      // We expect 401 for unauthenticated requests, which means endpoint is working
      if (response.statusCode == 401) {
        print('✅ Profile update endpoint is working (requires authentication)');
        return true;
      } else {
        print('❌ Profile update endpoint returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Profile update endpoint test failed: $e');
      return false;
    }
  }
  
  /// Test image upload endpoint
  static Future<bool> testImageUploadEndpoint() async {
    try {
      print('🔍 Testing image upload endpoint...');
      
      // Test image upload endpoint without authentication (should return 401)
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.imagesUpload)),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Image upload endpoint status: ${response.statusCode}');
      print('📡 Image upload endpoint response: ${response.body}');
      
      // We expect 401 or 422 for unauthenticated/invalid requests, which means endpoint is working
      if (response.statusCode == 401 || response.statusCode == 422) {
        print('✅ Image upload endpoint is working (requires authentication)');
        return true;
      } else {
        print('❌ Image upload endpoint returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Image upload endpoint test failed: $e');
      return false;
    }
  }
  
  /// Test chat endpoints
  static Future<bool> testChatEndpoints() async {
    try {
      print('🔍 Testing chat endpoints...');
      
      // Test chat users endpoint without authentication (should return 401)
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatUsers)),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Chat users endpoint status: ${response.statusCode}');
      print('📡 Chat users endpoint response: ${response.body}');
      
      // We expect 401 for unauthenticated requests, which means endpoint is working
      if (response.statusCode == 401) {
        print('✅ Chat users endpoint is working (requires authentication)');
        return true;
      } else {
        print('❌ Chat users endpoint returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Chat endpoint test failed: $e');
      return false;
    }
  }
  
  /// Test chat send message endpoint
  static Future<bool> testChatSendEndpoint() async {
    try {
      print('🔍 Testing chat send message endpoint...');
      
      // Test chat send endpoint without authentication (should return 401)
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatSend)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'recipient_id': '1',
          'content': 'Test message',
          'type': 'text',
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('📡 Chat send endpoint status: ${response.statusCode}');
      print('📡 Chat send endpoint response: ${response.body}');
      
      // We expect 401 for unauthenticated requests, which means endpoint is working
      if (response.statusCode == 401) {
        print('✅ Chat send endpoint is working (requires authentication)');
        return true;
      } else {
        print('❌ Chat send endpoint returned unexpected status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Chat send endpoint test failed: $e');
      return false;
    }
  }
  
  /// Run all API tests
  static Future<Map<String, bool>> runAllTests() async {
    print('🚀 Starting API connectivity tests...');
    print('=' * 50);
    
    final results = <String, bool>{};
    
    results['API Connectivity'] = await testApiConnectivity();
    print('');
    
    results['Auth Endpoint'] = await testAuthEndpoint();
    print('');
    
    results['Registration Endpoint'] = await testRegistrationEndpoint();
    print('');
    
    results['Profile Endpoint'] = await testProfileEndpoints();
    print('');
    
    results['Profile Update Endpoint'] = await testProfileUpdateEndpoint();
    print('');
    
    results['Image Upload Endpoint'] = await testImageUploadEndpoint();
    print('');
    
    results['Chat Users Endpoint'] = await testChatEndpoints();
    print('');
    
    results['Chat Send Endpoint'] = await testChatSendEndpoint();
    print('');
    
    print('=' * 50);
    print('📊 Test Results:');
    results.forEach((test, result) {
      print('${result ? '✅' : '❌'} $test: ${result ? 'PASS' : 'FAIL'}');
    });
    
    final allPassed = results.values.every((result) => result);
    print('${allPassed ? '✅' : '❌'} Overall: ${allPassed ? 'ALL TESTS PASSED' : 'SOME TESTS FAILED'}');
    
    return results;
  }
}
