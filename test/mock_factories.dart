import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/profile_service.dart';
import '../lib/services/payment_service.dart';
import '../lib/services/chat_service.dart';
import '../lib/services/match_service.dart';
import '../lib/services/websocket_service.dart';
import '../lib/services/token_management_service.dart';
import '../lib/services/cache_service.dart';
import '../lib/services/push_notification_service.dart';
import '../lib/services/stripe_payment_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Generate mocks using: flutter pub run build_runner build
@GenerateMocks([
  http.Client,
  AuthService,
  ProfileService,
  PaymentService,
  ChatService,
  MatchService,
  WebSocketService,
  TokenManagementService,
  CacheService,
  PushNotificationService,
  StripePaymentService,
  SharedPreferences,
  FlutterSecureStorage,
])
void main() {}

/// Factory class for creating mock instances
class MockFactory {
  /// Create a mock HTTP client
  static MockClient createMockHttpClient() {
    return MockClient();
  }
  
  /// Create a mock auth service
  static MockAuthService createMockAuthService() {
    return MockAuthService();
  }
  
  /// Create a mock profile service
  static MockProfileService createMockProfileService() {
    return MockProfileService();
  }
  
  /// Create a mock payment service
  static MockPaymentService createMockPaymentService() {
    return MockPaymentService();
  }
  
  /// Create a mock chat service
  static MockChatService createMockChatService() {
    return MockChatService();
  }
  
  /// Create a mock match service
  static MockMatchService createMockMatchService() {
    return MockMatchService();
  }
  
  /// Create a mock WebSocket service
  static MockWebSocketService createMockWebSocketService() {
    return MockWebSocketService();
  }
  
  /// Create a mock token management service
  static MockTokenManagementService createMockTokenManagementService() {
    return MockTokenManagementService();
  }
  
  /// Create a mock cache service
  static MockCacheService createMockCacheService() {
    return MockCacheService();
  }
  
  /// Create a mock push notification service
  static MockPushNotificationService createMockPushNotificationService() {
    return MockPushNotificationService();
  }
  
  /// Create a mock Stripe payment service
  static MockStripePaymentService createMockStripePaymentService() {
    return MockStripePaymentService();
  }
  
  /// Create a mock SharedPreferences
  static MockSharedPreferences createMockSharedPreferences() {
    return MockSharedPreferences();
  }
  
  /// Create a mock FlutterSecureStorage
  static MockFlutterSecureStorage createMockFlutterSecureStorage() {
    return MockFlutterSecureStorage();
  }
}

