import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import '../../lib/services/profile_service.dart';
import '../../lib/models/profile_requests.dart';
import '../../lib/models/profile_responses.dart';
import '../../lib/utils/error_handler.dart';
import '../api_test_utils.dart';

@GenerateMocks([http.Client])
void main() {
  group('ProfileService Tests', () {
    late MockHttpClient mockClient;
    
    setUp(() {
      mockClient = MockHttpClient();
    });
    
    group('Profile CRUD Operations', () {
      test('should create profile successfully', () async {
        // Arrange
        final request = CreateProfileRequest(
          name: 'Test Profile',
          age: 25,
          gender: 'non-binary',
          preferredGender: 'all',
          location: 'Test City',
          bio: 'Test bio',
          interests: ['music', 'travel'],
        );
        
        final responseData = ApiTestUtils.createTestProfile();
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.createProfile(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileResponse>());
        expect(result.profile, isNotNull);
        ApiTestUtils.assertProfileStructure(result.profile);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/profiles',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should get profile successfully', () async {
        // Arrange
        final profileId = 'test_profile_id';
        final responseData = ApiTestUtils.createTestProfile();
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.getProfile(profileId, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileResponse>());
        expect(result.profile, isNotNull);
        ApiTestUtils.assertProfileStructure(result.profile);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/$profileId',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should update profile successfully', () async {
        // Arrange
        final profileId = 'test_profile_id';
        final request = UpdateProfileRequest(
          name: 'Updated Profile',
          bio: 'Updated bio',
          interests: ['music', 'travel', 'art'],
        );
        
        final responseData = ApiTestUtils.createTestProfile();
        responseData['name'] = 'Updated Profile';
        responseData['bio'] = 'Updated bio';
        responseData['interests'] = ['music', 'travel', 'art'];
        
        when(mockClient.put(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.updateProfile(profileId, request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileResponse>());
        expect(result.profile, isNotNull);
        expect(result.profile['name'], 'Updated Profile');
        expect(result.profile['bio'], 'Updated bio');
        expect(result.profile['interests'], ['music', 'travel', 'art']);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'PUT',
          '/profiles/$profileId',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should delete profile successfully', () async {
        // Arrange
        final profileId = 'test_profile_id';
        
        when(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Profile deleted successfully'},
        ));
        
        // Act
        final result = await ProfileService.deleteProfile(profileId, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'DELETE',
          '/profiles/$profileId',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should handle profile not found', () async {
        // Arrange
        final profileId = 'non_existent_profile_id';
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 404,
          message: 'Profile not found',
        ));
        
        // Act & Assert
        expect(
          () => ProfileService.getProfile(profileId, ApiTestUtils.testAccessToken),
          throwsA(isA<ApiException>()),
        );
      });
    });
    
    group('Image Management', () {
      test('should upload image successfully', () async {
        // Arrange
        final profileId = 'test_profile_id';
        final imageData = [1, 2, 3, 4, 5]; // Mock image data
        
        final responseData = {
          'image_url': 'https://example.com/images/test_image.jpg',
          'image_id': 'test_image_id',
        };
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.uploadImage(profileId, imageData, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ImageUploadResponse>());
        expect(result.imageUrl, isNotNull);
        expect(result.imageId, isNotNull);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'POST',
          '/profiles/$profileId/images',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should delete image successfully', () async {
        // Arrange
        final profileId = 'test_profile_id';
        final imageId = 'test_image_id';
        
        when(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Image deleted successfully'},
        ));
        
        // Act
        final result = await ProfileService.deleteImage(profileId, imageId, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'DELETE',
          '/profiles/$profileId/images/$imageId',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should reorder images successfully', () async {
        // Arrange
        final profileId = 'test_profile_id';
        final request = ReorderImagesRequest(
          imageIds: ['image1', 'image2', 'image3'],
        );
        
        when(mockClient.put(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(
          data: {'message': 'Images reordered successfully'},
        ));
        
        // Act
        final result = await ProfileService.reorderImages(profileId, request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isTrue);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'PUT',
          '/profiles/$profileId/images/reorder',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
          body: jsonEncode(request.toJson()),
        );
      });
      
      test('should handle invalid image format', () async {
        // Arrange
        final profileId = 'test_profile_id';
        final imageData = [1, 2, 3]; // Invalid image data
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 400,
          message: 'Invalid image format',
        ));
        
        // Act & Assert
        expect(
          () => ProfileService.uploadImage(profileId, imageData, ApiTestUtils.testAccessToken),
          throwsA(isA<ApiException>()),
        );
      });
    });
    
    group('Profile Discovery', () {
      test('should discover profiles by job successfully', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          job: 'developer',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [ApiTestUtils.createTestProfile()],
          'pagination': {
            'current_page': 1,
            'total_pages': 5,
            'total_items': 100,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByJob(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isA<List>());
        expect(result.profiles.isNotEmpty, isTrue);
        expect(result.pagination, isNotNull);
        ApiTestUtils.assertPaginationResponse(result.toJson());
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/discover/job',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should discover profiles by language successfully', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          language: 'english',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [ApiTestUtils.createTestProfile()],
          'pagination': {
            'current_page': 1,
            'total_pages': 5,
            'total_items': 100,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByLanguage(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isA<List>());
        expect(result.profiles.isNotEmpty, isTrue);
        expect(result.pagination, isNotNull);
        ApiTestUtils.assertPaginationResponse(result.toJson());
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/discover/language',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should discover profiles by relation goal successfully', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          relationGoal: 'serious',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [ApiTestUtils.createTestProfile()],
          'pagination': {
            'current_page': 1,
            'total_pages': 5,
            'total_items': 100,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByRelationGoal(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isA<List>());
        expect(result.profiles.isNotEmpty, isTrue);
        expect(result.pagination, isNotNull);
        ApiTestUtils.assertPaginationResponse(result.toJson());
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/discover/relation-goal',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should discover profiles by interest successfully', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          interest: 'music',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [ApiTestUtils.createTestProfile()],
          'pagination': {
            'current_page': 1,
            'total_pages': 5,
            'total_items': 100,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByInterest(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isA<List>());
        expect(result.profiles.isNotEmpty, isTrue);
        expect(result.pagination, isNotNull);
        ApiTestUtils.assertPaginationResponse(result.toJson());
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/discover/interest',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should discover profiles by music genre successfully', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          musicGenre: 'rock',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [ApiTestUtils.createTestProfile()],
          'pagination': {
            'current_page': 1,
            'total_pages': 5,
            'total_items': 100,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByMusicGenre(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isA<List>());
        expect(result.profiles.isNotEmpty, isTrue);
        expect(result.pagination, isNotNull);
        ApiTestUtils.assertPaginationResponse(result.toJson());
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/discover/music-genre',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should discover profiles by education successfully', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          education: 'university',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [ApiTestUtils.createTestProfile()],
          'pagination': {
            'current_page': 1,
            'total_pages': 5,
            'total_items': 100,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByEducation(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isA<List>());
        expect(result.profiles.isNotEmpty, isTrue);
        expect(result.pagination, isNotNull);
        ApiTestUtils.assertPaginationResponse(result.toJson());
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/discover/education',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should discover profiles by gender successfully', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          gender: 'non-binary',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [ApiTestUtils.createTestProfile()],
          'pagination': {
            'current_page': 1,
            'total_pages': 5,
            'total_items': 100,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByGender(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isA<List>());
        expect(result.profiles.isNotEmpty, isTrue);
        expect(result.pagination, isNotNull);
        ApiTestUtils.assertPaginationResponse(result.toJson());
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/discover/gender',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should discover profiles by preferred gender successfully', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          preferredGender: 'all',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [ApiTestUtils.createTestProfile()],
          'pagination': {
            'current_page': 1,
            'total_pages': 5,
            'total_items': 100,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByPreferredGender(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isA<List>());
        expect(result.profiles.isNotEmpty, isTrue);
        expect(result.pagination, isNotNull);
        ApiTestUtils.assertPaginationResponse(result.toJson());
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/discover/preferred-gender',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should handle empty discovery results', () async {
        // Arrange
        final request = DiscoverProfilesRequest(
          job: 'nonexistent_job',
          page: 1,
          limit: 20,
        );
        
        final responseData = {
          'profiles': [],
          'pagination': {
            'current_page': 1,
            'total_pages': 0,
            'total_items': 0,
            'per_page': 20,
          },
        };
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.discoverProfilesByJob(request, ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileListResponse>());
        expect(result.profiles, isEmpty);
        expect(result.pagination.totalItems, 0);
        expect(result.pagination.totalPages, 0);
      });
    });
    
    group('Current User Profile', () {
      test('should get current user profile successfully', () async {
        // Arrange
        final responseData = ApiTestUtils.createTestProfile();
        
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createSuccessResponse(data: responseData));
        
        // Act
        final result = await ProfileService.getCurrentUserProfile(ApiTestUtils.testAccessToken);
        
        // Assert
        expect(result, isA<ProfileResponse>());
        expect(result.profile, isNotNull);
        ApiTestUtils.assertProfileStructure(result.profile);
        
        ApiTestUtils.verifyHttpRequest(
          mockClient,
          'GET',
          '/profiles/me',
          headers: ApiTestUtils.createTestHeaders(accessToken: ApiTestUtils.testAccessToken),
        );
      });
      
      test('should handle user not authenticated', () async {
        // Arrange
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => ApiTestUtils.createErrorResponse(
          statusCode: 401,
          message: 'Unauthorized',
        ));
        
        // Act & Assert
        expect(
          () => ProfileService.getCurrentUserProfile('invalid_token'),
          throwsA(isA<AuthException>()),
        );
      });
    });
    
    group('Error Handling', () {
      test('should handle validation errors', () async {
        // Arrange
        final request = CreateProfileRequest(
          name: '',
          age: 15,
          gender: 'invalid',
          preferredGender: 'invalid',
          location: '',
          bio: '',
          interests: [],
        );
        
        final validationErrors = {
          'name': ['The name field is required.'],
          'age': ['The age must be at least 18.'],
          'gender': ['The selected gender is invalid.'],
          'preferred_gender': ['The selected preferred gender is invalid.'],
          'location': ['The location field is required.'],
          'bio': ['The bio field is required.'],
          'interests': ['The interests field is required.'],
        };
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createValidationErrorResponse(errors: validationErrors));
        
        // Act & Assert
        expect(
          () => ProfileService.createProfile(request, ApiTestUtils.testAccessToken),
          throwsA(isA<ValidationException>()),
        );
      });
      
      test('should handle rate limit exceeded', () async {
        // Arrange
        final request = CreateProfileRequest(
          name: 'Test Profile',
          age: 25,
          gender: 'non-binary',
          preferredGender: 'all',
          location: 'Test City',
          bio: 'Test bio',
          interests: ['music', 'travel'],
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => ApiTestUtils.createRateLimitResponse(retryAfter: 60));
        
        // Act & Assert
        expect(
          () => ProfileService.createProfile(request, ApiTestUtils.testAccessToken),
          throwsA(isA<RateLimitException>()),
        );
      });
      
      test('should handle network timeout', () async {
        // Arrange
        final request = CreateProfileRequest(
          name: 'Test Profile',
          age: 25,
          gender: 'non-binary',
          preferredGender: 'all',
          location: 'Test City',
          bio: 'Test bio',
          interests: ['music', 'travel'],
        );
        
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(TimeoutException('Request timeout', Duration(seconds: 30)));
        
        // Act & Assert
        expect(
          () => ProfileService.createProfile(request, ApiTestUtils.testAccessToken),
          throwsA(isA<TimeoutException>()),
        );
      });
    });
  });
}
