import 'package:flutter_test/flutter_test.dart';
import 'api_models_test.dart';
import 'api_services_test.dart';
import 'api_integration_test.dart';

/// API Test Runner
/// 
/// This file runs all API-related tests including:
/// - Model tests
/// - Service tests
/// - Integration tests
void main() {
  group('API Tests', () {
    group('Model Tests', () {
      testAuthModels();
      testReferenceDataModels();
      testUserModels();
      testMatchingModels();
      testChatModels();
      testProfileModels();
      testCommonModels();
    });

    group('Service Tests', () {
      testAuthApiService();
      testReferenceDataApiService();
      testUserApiService();
      testMatchingApiService();
      testChatApiService();
      testProfileApiService();
    });

    group('Integration Tests', () {
      testApiIntegration();
    });
  });
}
