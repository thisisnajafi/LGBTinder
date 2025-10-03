import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:lgbtinder/services/api_services/auth_api_service.dart';
import 'package:lgbtinder/services/api_services/reference_data_api_service.dart';
import 'package:lgbtinder/services/api_services/user_api_service.dart';
import 'package:lgbtinder/services/api_services/matching_api_service.dart';
import 'package:lgbtinder/services/api_services/chat_api_service.dart';
import 'package:lgbtinder/services/api_services/profile_api_service.dart';
import 'package:lgbtinder/models/api_models/auth_models.dart';
import 'package:lgbtinder/models/api_models/reference_data_models.dart';
import 'package:lgbtinder/models/api_models/user_models.dart';
import 'package:lgbtinder/models/api_models/matching_models.dart';
import 'package:lgbtinder/models/api_models/chat_models.dart';
import 'package:lgbtinder/models/api_models/profile_models.dart';

import 'api_services_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('API Services Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    testAuthApiService();
    testReferenceDataApiService();
    testUserApiService();
    testMatchingApiService();
    testChatApiService();
    testProfileApiService();
  });
}

void testAuthApiService() {
  group('AuthApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('register should return success response', () async {
      // Arrange
      final request = RegisterRequest(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        password: 'password123',
      );

      final responseBody = '''
      {
        "status": true,
        "message": "Registration successful!",
        "data": {
          "user_id": 1,
          "email": "john.doe@example.com",
          "email_sent": true,
          "resend_available_at": "2024-01-01 12:02:00",
          "hourly_attempts_remaining": 2
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await AuthApiService.register(request);

      // Assert
      expect(response.status, isTrue);
      expect(response.message, equals('Registration successful!'));
      expect(response.data?.userId, equals(1));
      expect(response.data?.email, equals('john.doe@example.com'));
      expect(response.data?.emailSent, isTrue);
    });

    test('register should handle error response', () async {
      // Arrange
      final request = RegisterRequest(
        firstName: 'John',
        lastName: 'Doe',
        email: 'invalid-email',
        password: 'weak',
      );

      final responseBody = '''
      {
        "status": false,
        "message": "Validation error",
        "errors": {
          "email": ["The email field must be a valid email address."],
          "password": ["The password field must be at least 8 characters."]
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 422));

      // Act
      final response = await AuthApiService.register(request);

      // Assert
      expect(response.status, isFalse);
      expect(response.message, equals('Validation error'));
      expect(response.errors?['email']?.first, equals('The email field must be a valid email address.'));
      expect(response.errors?['password']?.first, equals('The password field must be at least 8 characters.'));
    });

    test('checkUserState should return user state', () async {
      // Arrange
      final request = CheckUserStateRequest(email: 'john.doe@example.com');

      final responseBody = '''
      {
        "status": false,
        "message": "Email verification required",
        "data": {
          "user_state": "email_verification_required",
          "user_id": 1,
          "email": "john.doe@example.com",
          "needs_verification": true
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 403));

      // Act
      final response = await AuthApiService.checkUserState(request);

      // Assert
      expect(response.status, isFalse);
      expect(response.message, equals('Email verification required'));
      expect(response.data?.userState, equals('email_verification_required'));
      expect(response.data?.userId, equals(1));
      expect(response.data?.needsVerification, isTrue);
    });

    test('verifyEmail should return success response', () async {
      // Arrange
      final request = VerifyEmailRequest(
        email: 'john.doe@example.com',
        code: '123456',
      );

      final responseBody = '''
      {
        "status": true,
        "message": "Email verified successfully!",
        "data": {
          "user_id": 1,
          "email": "john.doe@example.com",
          "token": "profile_completion_token_here",
          "token_type": "Bearer",
          "profile_completion_required": true
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await AuthApiService.verifyEmail(request);

      // Assert
      expect(response.status, isTrue);
      expect(response.message, equals('Email verified successfully!'));
      expect(response.data?.userId, equals(1));
      expect(response.data?.token, equals('profile_completion_token_here'));
      expect(response.data?.profileCompletionRequired, isTrue);
    });

    test('completeProfile should return success response', () async {
      // Arrange
      final request = CompleteProfileRequest(
        deviceName: 'iPhone 15 Pro',
        countryId: 1,
        cityId: 1,
        gender: 1,
        birthDate: '1995-06-15',
        minAgePreference: 21,
        maxAgePreference: 35,
        profileBio: 'Love traveling and music!',
        height: 175,
        weight: 70,
        smoke: false,
        drink: true,
        gym: true,
        musicGenres: [1, 3, 5],
        educations: [2, 3],
        jobs: [1, 4],
        languages: [1, 2],
        interests: [1, 2, 3, 7],
        preferredGenders: [1, 3],
        relationGoals: [1, 2],
      );

      final responseBody = '''
      {
        "status": true,
        "message": "Profile completed successfully!",
        "data": {
          "user": {
            "id": 1,
            "name": "John Doe",
            "email": "john.doe@example.com",
            "country_id": 1,
            "city_id": 1,
            "country": "United States",
            "city": "New York",
            "gender": 1,
            "birth_date": "1995-06-15",
            "profile_bio": "Love traveling and music!",
            "height": 175,
            "weight": 70,
            "smoke": false,
            "drink": true,
            "gym": true,
            "min_age_preference": 21,
            "max_age_preference": 35
          },
          "token": "full_access_token_here",
          "token_type": "Bearer",
          "profile_completed": true,
          "needs_profile_completion": false,
          "user_state": "ready_for_app"
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await AuthApiService.completeProfile(request, 'token');

      // Assert
      expect(response.status, isTrue);
      expect(response.message, equals('Profile completed successfully!'));
      expect(response.data?.user['id'], equals(1));
      expect(response.data?.token, equals('full_access_token_here'));
      expect(response.data?.profileCompleted, isTrue);
    });
  });
}

void testReferenceDataApiService() {
  group('ReferenceDataApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('getCountries should return countries list', () async {
      // Arrange
      final responseBody = '''
      {
        "status": "success",
        "data": [
          {
            "id": 1,
            "name": "United States",
            "code": "USA",
            "phone_code": "+1"
          },
          {
            "id": 2,
            "name": "United Kingdom",
            "code": "GBR",
            "phone_code": "+44"
          }
        ]
      }
      ''';

      when(mockClient.get(any)).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final countries = await ReferenceDataApiService.getCountries();

      // Assert
      expect(countries.length, equals(2));
      expect(countries.first.name, equals('United States'));
      expect(countries.first.code, equals('USA'));
      expect(countries.last.name, equals('United Kingdom'));
      expect(countries.last.code, equals('GBR'));
    });

    test('getCitiesByCountry should return cities list', () async {
      // Arrange
      final responseBody = '''
      {
        "status": "success",
        "data": [
          {
            "id": 1,
            "name": "New York",
            "state_province": "New York"
          },
          {
            "id": 2,
            "name": "Los Angeles",
            "state_province": "California"
          }
        ]
      }
      ''';

      when(mockClient.get(any)).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final cities = await ReferenceDataApiService.getCitiesByCountry(1);

      // Assert
      expect(cities.length, equals(2));
      expect(cities.first.name, equals('New York'));
      expect(cities.first.stateProvince, equals('New York'));
      expect(cities.last.name, equals('Los Angeles'));
      expect(cities.last.stateProvince, equals('California'));
    });

    test('getGenders should return genders list', () async {
      // Arrange
      final responseBody = '''
      {
        "status": "success",
        "data": [
          {
            "id": 1,
            "title": "Man",
            "status": "active"
          },
          {
            "id": 2,
            "title": "Woman",
            "status": "active"
          }
        ]
      }
      ''';

      when(mockClient.get(any)).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final genders = await ReferenceDataApiService.getGenders();

      // Assert
      expect(genders.length, equals(2));
      expect(genders.first.title, equals('Man'));
      expect(genders.first.status, equals('active'));
      expect(genders.last.title, equals('Woman'));
      expect(genders.last.status, equals('active'));
    });

    test('getAllReferenceData should return all reference data', () async {
      // Arrange
      final responseBody = '''
      {
        "status": "success",
        "data": [
          {
            "id": 1,
            "title": "Software Engineer",
            "status": "active"
          }
        ]
      }
      ''';

      when(mockClient.get(any)).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final allData = await ReferenceDataApiService.getAllReferenceData();

      // Assert
      expect(allData, isA<Map<String, List<ReferenceDataItem>>>());
      expect(allData['genders'], isNotNull);
      expect(allData['jobs'], isNotNull);
      expect(allData['educations'], isNotNull);
      expect(allData['interests'], isNotNull);
      expect(allData['languages'], isNotNull);
      expect(allData['musicGenres'], isNotNull);
      expect(allData['relationGoals'], isNotNull);
      expect(allData['preferredGenders'], isNotNull);
    });
  });
}

void testUserApiService() {
  group('UserApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('getCurrentUser should return user profile', () async {
      // Arrange
      final responseBody = '''
      {
        "id": 1,
        "first_name": "John",
        "last_name": "Doe",
        "full_name": "John Doe",
        "email": "john.doe@example.com",
        "country_id": 1,
        "city_id": 1,
        "country": "United States",
        "city": "New York",
        "birth_date": "1995-06-15",
        "profile_bio": "Love traveling and music!",
        "height": 175,
        "weight": 70,
        "smoke": false,
        "drink": true,
        "gym": true,
        "min_age_preference": 21,
        "max_age_preference": 35,
        "profile_completed": true,
        "images": [],
        "jobs": [],
        "educations": [],
        "music_genres": [],
        "languages": [],
        "interests": [],
        "preferred_genders": [],
        "relation_goals": []
      }
      ''';

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final user = await UserApiService.getCurrentUser('token');

      // Assert
      expect(user.id, equals(1));
      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
      expect(user.fullName, equals('John Doe'));
      expect(user.email, equals('john.doe@example.com'));
      expect(user.country, equals('United States'));
      expect(user.city, equals('New York'));
      expect(user.profileCompleted, isTrue);
    });

    test('getCurrentUser should handle error response', () async {
      // Arrange
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Unauthorized', 401));

      // Act & Assert
      expect(
        () => UserApiService.getCurrentUser('invalid_token'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

void testMatchingApiService() {
  group('MatchingApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('likeUser should return like response', () async {
      // Arrange
      final request = LikeUserRequest(targetUserId: 2);

      final responseBody = '''
      {
        "status": true,
        "message": "User liked successfully",
        "data": {
          "like_id": 1,
          "target_user_id": 2,
          "status": "pending",
          "is_match": false,
          "created_at": "2024-01-01T12:00:00Z"
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await MatchingApiService.likeUser(request, 'token');

      // Assert
      expect(response.status, isTrue);
      expect(response.message, equals('User liked successfully'));
      expect(response.data?.likeId, equals(1));
      expect(response.data?.targetUserId, equals(2));
      expect(response.data?.status, equals('pending'));
      expect(response.data?.isMatch, isFalse);
    });

    test('likeUser should return match response', () async {
      // Arrange
      final request = LikeUserRequest(targetUserId: 2);

      final responseBody = '''
      {
        "status": true,
        "message": "It's a match!",
        "data": {
          "like_id": 1,
          "target_user_id": 2,
          "status": "matched",
          "is_match": true,
          "match_id": 1,
          "created_at": "2024-01-01T12:00:00Z"
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await MatchingApiService.likeUser(request, 'token');

      // Assert
      expect(response.status, isTrue);
      expect(response.message, equals("It's a match!"));
      expect(response.data?.isMatch, isTrue);
      expect(response.data?.matchId, equals(1));
    });

    test('getMatches should return matches list', () async {
      // Arrange
      final responseBody = '''
      {
        "status": true,
        "data": [
          {
            "match_id": 1,
            "user": {
              "id": 2,
              "name": "Jane Smith",
              "age": 25,
              "avatar_url": "https://example.com/avatar.jpg",
              "profile_bio": "Love hiking and photography!",
              "city": "New York"
            },
            "matched_at": "2024-01-01T12:00:00Z",
            "last_message": {
              "id": 1,
              "message": "Hey! How are you?",
              "sent_at": "2024-01-01T12:30:00Z",
              "is_read": false
            }
          }
        ]
      }
      ''';

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final matches = await MatchingApiService.getMatches('token');

      // Assert
      expect(matches.length, equals(1));
      expect(matches.first.matchId, equals(1));
      expect(matches.first.user.name, equals('Jane Smith'));
      expect(matches.first.user.age, equals(25));
      expect(matches.first.lastMessage?.message, equals('Hey! How are you?'));
    });
  });
}

void testChatApiService() {
  group('ChatApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('sendMessage should return message response', () async {
      // Arrange
      final request = SendMessageRequest(
        receiverId: 2,
        message: 'Hey! How are you?',
        messageType: MessageType.text,
      );

      final responseBody = '''
      {
        "status": true,
        "message": "Message sent successfully",
        "data": {
          "message_id": 1,
          "sender_id": 1,
          "receiver_id": 2,
          "message": "Hey! How are you?",
          "message_type": "text",
          "sent_at": "2024-01-01T12:00:00Z",
          "is_read": false
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await ChatApiService.sendMessage(request, 'token');

      // Assert
      expect(response.status, isTrue);
      expect(response.message, equals('Message sent successfully'));
      expect(response.data?.messageId, equals(1));
      expect(response.data?.senderId, equals(1));
      expect(response.data?.receiverId, equals(2));
      expect(response.data?.message, equals('Hey! How are you?'));
      expect(response.data?.messageType, equals(MessageType.text));
      expect(response.data?.isRead, isFalse);
    });

    test('getChatHistory should return chat history', () async {
      // Arrange
      final responseBody = '''
      {
        "status": true,
        "data": {
          "messages": [
            {
              "message_id": 1,
              "sender_id": 1,
              "receiver_id": 2,
              "message": "Hey! How are you?",
              "message_type": "text",
              "sent_at": "2024-01-01T12:00:00Z",
              "is_read": true
            },
            {
              "message_id": 2,
              "sender_id": 2,
              "receiver_id": 1,
              "message": "I'm doing great! How about you?",
              "message_type": "text",
              "sent_at": "2024-01-01T12:05:00Z",
              "is_read": false
            }
          ],
          "pagination": {
            "current_page": 1,
            "total_pages": 1,
            "total_messages": 2,
            "per_page": 20
          }
        }
      }
      ''';

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await ChatApiService.getChatHistory(2, 'token');

      // Assert
      expect(response.status, isTrue);
      expect(response.data?.messages.length, equals(2));
      expect(response.data?.messages.first.message, equals('Hey! How are you?'));
      expect(response.data?.messages.last.message, equals("I'm doing great! How about you?"));
      expect(response.data?.pagination.currentPage, equals(1));
      expect(response.data?.pagination.totalMessages, equals(2));
    });

    test('ChatApiService utility methods should work correctly', () {
      // Test utility methods
      expect(ChatApiService.canSendMessage(1, 2), isTrue);
      expect(ChatApiService.canSendMessage(1, 1), isFalse);

      expect(ChatApiService.isValidMessage('Valid message'), isTrue);
      expect(ChatApiService.isValidMessage(''), isFalse);
      expect(ChatApiService.isValidMessage('   '), isFalse);

      expect(ChatApiService.getMessageCharacterCount('Hello'), equals(5));
      expect(ChatApiService.isMessageTooLong('Short message'), isFalse);
      expect(ChatApiService.isMessageTooLong('x' * 1001), isTrue);
    });
  });
}

void testProfileApiService() {
  group('ProfileApiService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    test('updateProfile should return success response', () async {
      // Arrange
      final request = UpdateProfileRequest(
        profileBio: 'Updated bio text',
        height: 180,
        weight: 75,
        smoke: false,
        drink: true,
        gym: true,
        minAgePreference: 22,
        maxAgePreference: 40,
      );

      final responseBody = '''
      {
        "status": true,
        "message": "Profile updated successfully",
        "data": {
          "id": 1,
          "profile_bio": "Updated bio text",
          "height": 180,
          "weight": 75,
          "smoke": false,
          "drink": true,
          "gym": true,
          "min_age_preference": 22,
          "max_age_preference": 40,
          "updated_at": "2024-01-01T12:00:00Z"
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final response = await ProfileApiService.updateProfile(request, 'token');

      // Assert
      expect(response.status, isTrue);
      expect(response.message, equals('Profile updated successfully'));
      expect(response.data?.id, equals(1));
      expect(response.data?.profileBio, equals('Updated bio text'));
      expect(response.data?.height, equals(180));
      expect(response.data?.weight, equals(75));
      expect(response.data?.smoke, isFalse);
      expect(response.data?.drink, isTrue);
      expect(response.data?.gym, isTrue);
    });

    test('updateProfile should handle validation errors', () async {
      // Arrange
      final request = UpdateProfileRequest(
        profileBio: 'x' * 501, // Too long
        height: 50, // Too short
        weight: 20, // Too light
      );

      final responseBody = '''
      {
        "status": false,
        "message": "Validation error",
        "errors": {
          "profile_bio": ["The profile bio field must not be greater than 500 characters."],
          "height": ["The height field must be at least 100."],
          "weight": ["The weight field must be at least 30."]
        }
      }
      ''';

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 422));

      // Act
      final response = await ProfileApiService.updateProfile(request, 'token');

      // Assert
      expect(response.status, isFalse);
      expect(response.message, equals('Validation error'));
      expect(response.errors?['profile_bio']?.first, equals('The profile bio field must not be greater than 500 characters.'));
      expect(response.errors?['height']?.first, equals('The height field must be at least 100.'));
      expect(response.errors?['weight']?.first, equals('The weight field must be at least 30.'));
    });

    test('ProfileApiService validation methods should work correctly', () {
      // Test validation methods
      final validRequest = UpdateProfileRequest(
        profileBio: 'Valid bio',
        height: 175,
        weight: 70,
        minAgePreference: 21,
        maxAgePreference: 35,
      );

      final invalidRequest = UpdateProfileRequest(
        profileBio: 'x' * 501,
        height: 50,
        weight: 20,
        minAgePreference: 17,
        maxAgePreference: 101,
      );

      expect(ProfileApiService.isValidProfileUpdateRequest(validRequest), isTrue);
      expect(ProfileApiService.isValidProfileUpdateRequest(invalidRequest), isFalse);

      final errors = ProfileApiService.validateProfileUpdateRequest(invalidRequest);
      expect(errors.isNotEmpty, isTrue);
      expect(errors.containsKey('profile_bio'), isTrue);
      expect(errors.containsKey('height'), isTrue);
      expect(errors.containsKey('weight'), isTrue);
      expect(errors.containsKey('age_preference'), isTrue);
    });

    test('ProfileApiService utility methods should work correctly', () {
      // Test utility methods
      expect(ProfileApiService.canUpdateProfile('valid_token'), isTrue);
      expect(ProfileApiService.canUpdateProfile(null), isFalse);

      expect(ProfileApiService.getProfileBioCharacterCount('Hello'), equals(5));
      expect(ProfileApiService.getRemainingBioCharacters('Hello'), equals(495));
      expect(ProfileApiService.isProfileBioTooLong('x' * 501), isTrue);

      expect(ProfileApiService.formatHeight(175), equals('175cm'));
      expect(ProfileApiService.formatWeight(70), equals('70kg'));
      expect(ProfileApiService.formatAgePreference(21, 35), equals('21-35 years'));

      expect(ProfileApiService.getLifestyleString(true, false, true), equals('Smokes, Gym'));
      expect(ProfileApiService.getLifestyleString(false, false, false), equals('No lifestyle preferences set'));
    });
  });
}
