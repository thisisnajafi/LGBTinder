import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/config/api_config.dart';
import '../lib/utils/error_handler.dart';

// Generate mocks with: flutter packages pub run build_runner build
@GenerateMocks([http.Client])
class MockHttpClient extends Mock implements http.Client {}

class ApiTestUtils {
  static const String testBaseUrl = 'https://api.test.com';
  static const String testAccessToken = 'test_access_token';
  
  /// Create a mock HTTP client
  static MockHttpClient createMockClient() {
    return MockHttpClient();
  }
  
  /// Create test headers
  static Map<String, String> createTestHeaders({String? accessToken}) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }
  
  /// Create test response
  static http.Response createTestResponse({
    required int statusCode,
    required String body,
    Map<String, String>? headers,
  }) {
    return http.Response(body, statusCode, headers: headers ?? {});
  }
  
  /// Create success response
  static http.Response createSuccessResponse({
    required Map<String, dynamic> data,
    String? message,
  }) {
    final responseBody = {
      'success': true,
      'data': data,
      if (message != null) 'message': message,
    };
    return createTestResponse(
      statusCode: 200,
      body: jsonEncode(responseBody),
    );
  }
  
  /// Create error response
  static http.Response createErrorResponse({
    required int statusCode,
    required String message,
    Map<String, dynamic>? errors,
  }) {
    final responseBody = {
      'success': false,
      'message': message,
      if (errors != null) 'errors': errors,
    };
    return createTestResponse(
      statusCode: statusCode,
      body: jsonEncode(responseBody),
    );
  }
  
  /// Create validation error response
  static http.Response createValidationErrorResponse({
    required Map<String, List<String>> errors,
  }) {
    return createErrorResponse(
      statusCode: 422,
      message: 'Validation failed',
      errors: errors,
    );
  }
  
  /// Create rate limit response
  static http.Response createRateLimitResponse({
    required int retryAfter,
  }) {
    return createTestResponse(
      statusCode: 429,
      body: jsonEncode({
        'success': false,
        'message': 'Rate limit exceeded',
        'retry_after': retryAfter,
      }),
      headers: {
        'x-ratelimit-limit': '100',
        'x-ratelimit-remaining': '0',
        'x-ratelimit-reset': '1640995200',
        'retry-after': retryAfter.toString(),
      },
    );
  }
  
  /// Verify HTTP request
  static void verifyHttpRequest(
    MockHttpClient mockClient,
    String method,
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) {
    switch (method.toLowerCase()) {
      case 'get':
        verify(mockClient.get(
          Uri.parse('$testBaseUrl$endpoint'),
          headers: headers,
        )).called(1);
        break;
      case 'post':
        verify(mockClient.post(
          Uri.parse('$testBaseUrl$endpoint'),
          headers: headers,
          body: body,
        )).called(1);
        break;
      case 'put':
        verify(mockClient.put(
          Uri.parse('$testBaseUrl$endpoint'),
          headers: headers,
          body: body,
        )).called(1);
        break;
      case 'delete':
        verify(mockClient.delete(
          Uri.parse('$testBaseUrl$endpoint'),
          headers: headers,
        )).called(1);
        break;
      case 'patch':
        verify(mockClient.patch(
          Uri.parse('$testBaseUrl$endpoint'),
          headers: headers,
          body: body,
        )).called(1);
        break;
    }
  }
  
  /// Test data generators
  static Map<String, dynamic> createTestUser() {
    return {
      'id': 'test_user_id',
      'email': 'test@example.com',
      'name': 'Test User',
      'age': 25,
      'gender': 'non-binary',
      'preferred_gender': 'all',
      'location': 'Test City',
      'bio': 'Test bio',
      'interests': ['music', 'travel'],
      'created_at': '2023-01-01T00:00:00Z',
      'updated_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestProfile() {
    return {
      'id': 'test_profile_id',
      'user_id': 'test_user_id',
      'name': 'Test Profile',
      'age': 25,
      'gender': 'non-binary',
      'preferred_gender': 'all',
      'location': 'Test City',
      'bio': 'Test bio',
      'interests': ['music', 'travel'],
      'images': ['image1.jpg', 'image2.jpg'],
      'verified': false,
      'created_at': '2023-01-01T00:00:00Z',
      'updated_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestMatch() {
    return {
      'id': 'test_match_id',
      'user1_id': 'test_user_id',
      'user2_id': 'test_user2_id',
      'matched_at': '2023-01-01T00:00:00Z',
      'status': 'active',
    };
  }
  
  static Map<String, dynamic> createTestMessage() {
    return {
      'id': 'test_message_id',
      'chat_id': 'test_chat_id',
      'sender_id': 'test_user_id',
      'content': 'Test message',
      'type': 'text',
      'sent_at': '2023-01-01T00:00:00Z',
      'read_at': null,
    };
  }
  
  static Map<String, dynamic> createTestStory() {
    return {
      'id': 'test_story_id',
      'user_id': 'test_user_id',
      'content': 'Test story content',
      'type': 'text',
      'media_url': null,
      'expires_at': '2023-01-02T00:00:00Z',
      'created_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestFeed() {
    return {
      'id': 'test_feed_id',
      'user_id': 'test_user_id',
      'content': 'Test feed content',
      'type': 'text',
      'media_urls': [],
      'likes_count': 0,
      'comments_count': 0,
      'created_at': '2023-01-01T00:00:00Z',
      'updated_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestNotification() {
    return {
      'id': 'test_notification_id',
      'user_id': 'test_user_id',
      'type': 'like',
      'title': 'New Like',
      'message': 'Someone liked your profile',
      'data': {'user_id': 'test_user2_id'},
      'read': false,
      'created_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestCall() {
    return {
      'id': 'test_call_id',
      'caller_id': 'test_user_id',
      'receiver_id': 'test_user2_id',
      'type': 'voice',
      'status': 'initiated',
      'started_at': '2023-01-01T00:00:00Z',
      'ended_at': null,
      'duration': 0,
    };
  }
  
  static Map<String, dynamic> createTestGroup() {
    return {
      'id': 'test_group_id',
      'name': 'Test Group',
      'description': 'Test group description',
      'admin_ids': ['test_user_id'],
      'member_ids': ['test_user_id', 'test_user2_id'],
      'created_at': '2023-01-01T00:00:00Z',
      'updated_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestSubscription() {
    return {
      'id': 'test_subscription_id',
      'user_id': 'test_user_id',
      'plan_id': 'test_plan_id',
      'status': 'active',
      'started_at': '2023-01-01T00:00:00Z',
      'expires_at': '2023-02-01T00:00:00Z',
      'auto_renew': true,
    };
  }
  
  static Map<String, dynamic> createTestSuperlikePack() {
    return {
      'id': 'test_pack_id',
      'name': 'Test Pack',
      'description': 'Test superlike pack',
      'superlikes_count': 5,
      'price': 9.99,
      'currency': 'USD',
      'active': true,
    };
  }
  
  static Map<String, dynamic> createTestReport() {
    return {
      'id': 'test_report_id',
      'reporter_id': 'test_user_id',
      'reported_id': 'test_user2_id',
      'type': 'user',
      'reason': 'inappropriate_behavior',
      'description': 'Test report description',
      'status': 'pending',
      'created_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestVerification() {
    return {
      'id': 'test_verification_id',
      'user_id': 'test_user_id',
      'type': 'photo',
      'status': 'pending',
      'submitted_at': '2023-01-01T00:00:00Z',
      'reviewed_at': null,
      'approved_at': null,
    };
  }
  
  static Map<String, dynamic> createTestAnalytics() {
    return {
      'user_id': 'test_user_id',
      'date': '2023-01-01',
      'views': 10,
      'likes': 5,
      'matches': 2,
      'messages_sent': 15,
      'messages_received': 12,
    };
  }
  
  static Map<String, dynamic> createTestSafetyReport() {
    return {
      'id': 'test_safety_report_id',
      'user_id': 'test_user_id',
      'type': 'emergency',
      'description': 'Test safety report',
      'location': 'Test Location',
      'status': 'pending',
      'created_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestReferenceData() {
    return {
      'id': 'test_ref_id',
      'name': 'Test Reference',
      'category': 'test_category',
      'active': true,
      'created_at': '2023-01-01T00:00:00Z',
    };
  }
  
  static Map<String, dynamic> createTestProfileWizardStep() {
    return {
      'step': 'basic_info',
      'title': 'Basic Information',
      'description': 'Tell us about yourself',
      'fields': [
        {'name': 'name', 'type': 'text', 'required': true},
        {'name': 'age', 'type': 'number', 'required': true},
        {'name': 'bio', 'type': 'textarea', 'required': false},
      ],
      'completed': false,
    };
  }
  
  static Map<String, dynamic> createTestSubscriptionPlan() {
    return {
      'id': 'test_plan_id',
      'name': 'Premium',
      'description': 'Premium subscription plan',
      'price': 9.99,
      'currency': 'USD',
      'duration_days': 30,
      'features': ['unlimited_likes', 'superlikes', 'advanced_filters'],
      'active': true,
    };
  }
  
  /// Assert response structure
  static void assertSuccessResponse(Map<String, dynamic> response) {
    expect(response['success'], isTrue);
    expect(response['data'], isNotNull);
  }
  
  static void assertErrorResponse(Map<String, dynamic> response) {
    expect(response['success'], isFalse);
    expect(response['message'], isNotNull);
  }
  
  static void assertValidationErrorResponse(Map<String, dynamic> response) {
    assertErrorResponse(response);
    expect(response['errors'], isNotNull);
  }
  
  /// Assert pagination structure
  static void assertPaginationResponse(Map<String, dynamic> response) {
    assertSuccessResponse(response);
    expect(response['data'], isA<List>());
    expect(response['pagination'], isNotNull);
    expect(response['pagination']['current_page'], isA<int>());
    expect(response['pagination']['total_pages'], isA<int>());
    expect(response['pagination']['total_items'], isA<int>());
  }
  
  /// Assert user structure
  static void assertUserStructure(Map<String, dynamic> user) {
    expect(user['id'], isNotNull);
    expect(user['email'], isNotNull);
    expect(user['name'], isNotNull);
    expect(user['created_at'], isNotNull);
    expect(user['updated_at'], isNotNull);
  }
  
  /// Assert profile structure
  static void assertProfileStructure(Map<String, dynamic> profile) {
    expect(profile['id'], isNotNull);
    expect(profile['user_id'], isNotNull);
    expect(profile['name'], isNotNull);
    expect(profile['age'], isA<int>());
    expect(profile['gender'], isNotNull);
    expect(profile['created_at'], isNotNull);
    expect(profile['updated_at'], isNotNull);
  }
  
  /// Assert match structure
  static void assertMatchStructure(Map<String, dynamic> match) {
    expect(match['id'], isNotNull);
    expect(match['user1_id'], isNotNull);
    expect(match['user2_id'], isNotNull);
    expect(match['matched_at'], isNotNull);
    expect(match['status'], isNotNull);
  }
  
  /// Assert message structure
  static void assertMessageStructure(Map<String, dynamic> message) {
    expect(message['id'], isNotNull);
    expect(message['chat_id'], isNotNull);
    expect(message['sender_id'], isNotNull);
    expect(message['content'], isNotNull);
    expect(message['type'], isNotNull);
    expect(message['sent_at'], isNotNull);
  }
  
  /// Assert story structure
  static void assertStoryStructure(Map<String, dynamic> story) {
    expect(story['id'], isNotNull);
    expect(story['user_id'], isNotNull);
    expect(story['content'], isNotNull);
    expect(story['type'], isNotNull);
    expect(story['expires_at'], isNotNull);
    expect(story['created_at'], isNotNull);
  }
  
  /// Assert feed structure
  static void assertFeedStructure(Map<String, dynamic> feed) {
    expect(feed['id'], isNotNull);
    expect(feed['user_id'], isNotNull);
    expect(feed['content'], isNotNull);
    expect(feed['type'], isNotNull);
    expect(feed['likes_count'], isA<int>());
    expect(feed['comments_count'], isA<int>());
    expect(feed['created_at'], isNotNull);
    expect(feed['updated_at'], isNotNull);
  }
  
  /// Assert notification structure
  static void assertNotificationStructure(Map<String, dynamic> notification) {
    expect(notification['id'], isNotNull);
    expect(notification['user_id'], isNotNull);
    expect(notification['type'], isNotNull);
    expect(notification['title'], isNotNull);
    expect(notification['message'], isNotNull);
    expect(notification['read'], isA<bool>());
    expect(notification['created_at'], isNotNull);
  }
  
  /// Assert call structure
  static void assertCallStructure(Map<String, dynamic> call) {
    expect(call['id'], isNotNull);
    expect(call['caller_id'], isNotNull);
    expect(call['receiver_id'], isNotNull);
    expect(call['type'], isNotNull);
    expect(call['status'], isNotNull);
    expect(call['started_at'], isNotNull);
  }
  
  /// Assert group structure
  static void assertGroupStructure(Map<String, dynamic> group) {
    expect(group['id'], isNotNull);
    expect(group['name'], isNotNull);
    expect(group['admin_ids'], isA<List>());
    expect(group['member_ids'], isA<List>());
    expect(group['created_at'], isNotNull);
    expect(group['updated_at'], isNotNull);
  }
  
  /// Assert subscription structure
  static void assertSubscriptionStructure(Map<String, dynamic> subscription) {
    expect(subscription['id'], isNotNull);
    expect(subscription['user_id'], isNotNull);
    expect(subscription['plan_id'], isNotNull);
    expect(subscription['status'], isNotNull);
    expect(subscription['started_at'], isNotNull);
    expect(subscription['expires_at'], isNotNull);
  }
  
  /// Assert superlike pack structure
  static void assertSuperlikePackStructure(Map<String, dynamic> pack) {
    expect(pack['id'], isNotNull);
    expect(pack['name'], isNotNull);
    expect(pack['description'], isNotNull);
    expect(pack['superlikes_count'], isA<int>());
    expect(pack['price'], isA<double>());
    expect(pack['currency'], isNotNull);
    expect(pack['active'], isA<bool>());
  }
  
  /// Assert report structure
  static void assertReportStructure(Map<String, dynamic> report) {
    expect(report['id'], isNotNull);
    expect(report['reporter_id'], isNotNull);
    expect(report['reported_id'], isNotNull);
    expect(report['type'], isNotNull);
    expect(report['reason'], isNotNull);
    expect(report['status'], isNotNull);
    expect(report['created_at'], isNotNull);
  }
  
  /// Assert verification structure
  static void assertVerificationStructure(Map<String, dynamic> verification) {
    expect(verification['id'], isNotNull);
    expect(verification['user_id'], isNotNull);
    expect(verification['type'], isNotNull);
    expect(verification['status'], isNotNull);
    expect(verification['submitted_at'], isNotNull);
  }
  
  /// Assert analytics structure
  static void assertAnalyticsStructure(Map<String, dynamic> analytics) {
    expect(analytics['user_id'], isNotNull);
    expect(analytics['date'], isNotNull);
    expect(analytics['views'], isA<int>());
    expect(analytics['likes'], isA<int>());
    expect(analytics['matches'], isA<int>());
  }
  
  /// Assert safety report structure
  static void assertSafetyReportStructure(Map<String, dynamic> report) {
    expect(report['id'], isNotNull);
    expect(report['user_id'], isNotNull);
    expect(report['type'], isNotNull);
    expect(report['description'], isNotNull);
    expect(report['status'], isNotNull);
    expect(report['created_at'], isNotNull);
  }
  
  /// Assert reference data structure
  static void assertReferenceDataStructure(Map<String, dynamic> data) {
    expect(data['id'], isNotNull);
    expect(data['name'], isNotNull);
    expect(data['category'], isNotNull);
    expect(data['active'], isA<bool>());
    expect(data['created_at'], isNotNull);
  }
  
  /// Assert profile wizard step structure
  static void assertProfileWizardStepStructure(Map<String, dynamic> step) {
    expect(step['step'], isNotNull);
    expect(step['title'], isNotNull);
    expect(step['description'], isNotNull);
    expect(step['fields'], isA<List>());
    expect(step['completed'], isA<bool>());
  }
  
  /// Assert subscription plan structure
  static void assertSubscriptionPlanStructure(Map<String, dynamic> plan) {
    expect(plan['id'], isNotNull);
    expect(plan['name'], isNotNull);
    expect(plan['description'], isNotNull);
    expect(plan['price'], isA<double>());
    expect(plan['currency'], isNotNull);
    expect(plan['duration_days'], isA<int>());
    expect(plan['features'], isA<List>());
    expect(plan['active'], isA<bool>());
  }
}
