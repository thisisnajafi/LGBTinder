import 'package:flutter_test/flutter_test.dart';
import 'package:lgbtinder/models/api_models/auth_models.dart';
import 'package:lgbtinder/models/api_models/reference_data_models.dart';
import 'package:lgbtinder/models/api_models/user_models.dart';
import 'package:lgbtinder/models/api_models/matching_models.dart';
import 'package:lgbtinder/models/api_models/chat_models.dart';
import 'package:lgbtinder/models/api_models/profile_models.dart';
import 'package:lgbtinder/models/api_models/common_models.dart';

/// API Models Test Suite
/// 
/// This file contains tests for all API data models including:
/// - Authentication models
/// - Reference data models
/// - User models
/// - Matching models
/// - Chat models
/// - Profile models
/// - Common models

void testAuthModels() {
  group('Authentication Models', () {
    test('RegisterRequest should serialize and deserialize correctly', () {
      final request = RegisterRequest(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        password: 'password123',
        referralCode: 'ABC123',
      );

      final json = request.toJson();
      final fromJson = RegisterRequest.fromJson(json);

      expect(fromJson.firstName, equals('John'));
      expect(fromJson.lastName, equals('Doe'));
      expect(fromJson.email, equals('john.doe@example.com'));
      expect(fromJson.password, equals('password123'));
      expect(fromJson.referralCode, equals('ABC123'));
    });

    test('RegisterResponse should handle success response', () {
      final responseData = {
        'status': true,
        'message': 'Registration successful!',
        'data': {
          'user_id': 1,
          'email': 'john.doe@example.com',
          'email_sent': true,
          'resend_available_at': '2024-01-01 12:02:00',
          'hourly_attempts_remaining': 2,
        },
      };

      final response = RegisterResponse.fromJson(responseData);

      expect(response.status, isTrue);
      expect(response.message, equals('Registration successful!'));
      expect(response.data?.userId, equals(1));
      expect(response.data?.email, equals('john.doe@example.com'));
      expect(response.data?.emailSent, isTrue);
    });

    test('RegisterResponse should handle error response', () {
      final responseData = {
        'status': false,
        'message': 'Validation error',
        'errors': {
          'email': ['The email field is required.'],
          'password': ['The password field is required.'],
        },
      };

      final response = RegisterResponse.fromJson(responseData);

      expect(response.status, isFalse);
      expect(response.message, equals('Validation error'));
      expect(response.errors?['email']?.first, equals('The email field is required.'));
      expect(response.errors?['password']?.first, equals('The password field is required.'));
    });

    test('CheckUserStateRequest should serialize correctly', () {
      final request = CheckUserStateRequest(email: 'john.doe@example.com');
      final json = request.toJson();

      expect(json['email'], equals('john.doe@example.com'));
    });

    test('VerifyEmailRequest should serialize correctly', () {
      final request = VerifyEmailRequest(
        email: 'john.doe@example.com',
        code: '123456',
      );
      final json = request.toJson();

      expect(json['email'], equals('john.doe@example.com'));
      expect(json['code'], equals('123456'));
    });

    test('CompleteProfileRequest should serialize correctly', () {
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

      final json = request.toJson();

      expect(json['device_name'], equals('iPhone 15 Pro'));
      expect(json['country_id'], equals(1));
      expect(json['city_id'], equals(1));
      expect(json['gender'], equals(1));
      expect(json['birth_date'], equals('1995-06-15'));
      expect(json['min_age_preference'], equals(21));
      expect(json['max_age_preference'], equals(35));
      expect(json['profile_bio'], equals('Love traveling and music!'));
      expect(json['height'], equals(175));
      expect(json['weight'], equals(70));
      expect(json['smoke'], isFalse);
      expect(json['drink'], isTrue);
      expect(json['gym'], isTrue);
      expect(json['music_genres'], equals([1, 3, 5]));
      expect(json['educations'], equals([2, 3]));
      expect(json['jobs'], equals([1, 4]));
      expect(json['languages'], equals([1, 2]));
      expect(json['interests'], equals([1, 2, 3, 7]));
      expect(json['preferred_genders'], equals([1, 3]));
      expect(json['relation_goals'], equals([1, 2]));
    });
  });
}

void testReferenceDataModels() {
  group('Reference Data Models', () {
    test('Country should serialize and deserialize correctly', () {
      final country = Country(
        id: 1,
        name: 'United States',
        code: 'USA',
        phoneCode: '+1',
      );

      final json = country.toJson();
      final fromJson = Country.fromJson(json);

      expect(fromJson.id, equals(1));
      expect(fromJson.name, equals('United States'));
      expect(fromJson.code, equals('USA'));
      expect(fromJson.phoneCode, equals('+1'));
    });

    test('City should serialize and deserialize correctly', () {
      final city = City(
        id: 1,
        name: 'New York',
        stateProvince: 'New York',
      );

      final json = city.toJson();
      final fromJson = City.fromJson(json);

      expect(fromJson.id, equals(1));
      expect(fromJson.name, equals('New York'));
      expect(fromJson.stateProvince, equals('New York'));
    });

    test('Gender should serialize and deserialize correctly', () {
      final gender = Gender(
        id: 1,
        title: 'Man',
        status: 'active',
      );

      final json = gender.toJson();
      final fromJson = Gender.fromJson(json);

      expect(fromJson.id, equals(1));
      expect(fromJson.title, equals('Man'));
      expect(fromJson.status, equals('active'));
    });

    test('ReferenceDataItem should serialize and deserialize correctly', () {
      final item = ReferenceDataItem(
        id: 1,
        title: 'Software Engineer',
        status: 'active',
      );

      final json = item.toJson();
      final fromJson = ReferenceDataItem.fromJson(json);

      expect(fromJson.id, equals(1));
      expect(fromJson.title, equals('Software Engineer'));
      expect(fromJson.status, equals('active'));
    });

    test('CountriesResponse should handle response correctly', () {
      final responseData = {
        'status': 'success',
        'data': [
          {
            'id': 1,
            'name': 'United States',
            'code': 'USA',
            'phone_code': '+1',
          },
          {
            'id': 2,
            'name': 'United Kingdom',
            'code': 'GBR',
            'phone_code': '+44',
          },
        ],
      };

      final response = CountriesResponse.fromJson(responseData);

      expect(response.status, equals('success'));
      expect(response.data.length, equals(2));
      expect(response.data.first.name, equals('United States'));
      expect(response.data.last.name, equals('United Kingdom'));
    });
  });
}

void testUserModels() {
  group('User Models', () {
    test('UserImage should serialize and deserialize correctly', () {
      final image = UserImage(
        id: 1,
        url: 'https://example.com/image.jpg',
        isPrimary: true,
        order: 1,
      );

      final json = image.toJson();
      final fromJson = UserImage.fromJson(json);

      expect(fromJson.id, equals(1));
      expect(fromJson.url, equals('https://example.com/image.jpg'));
      expect(fromJson.isPrimary, isTrue);
      expect(fromJson.order, equals(1));
    });

    test('UserProfile should calculate age correctly', () {
      final profile = UserProfile(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        fullName: 'John Doe',
        email: 'john.doe@example.com',
        countryId: 1,
        cityId: 1,
        country: 'United States',
        city: 'New York',
        birthDate: '1995-06-15',
        profileBio: 'Love traveling and music!',
        height: 175,
        weight: 70,
        smoke: false,
        drink: true,
        gym: true,
        minAgePreference: 21,
        maxAgePreference: 35,
        profileCompleted: true,
        images: [],
        jobs: [],
        educations: [],
        musicGenres: [],
        languages: [],
        interests: [],
        preferredGenders: [],
        relationGoals: [],
      );

      // Age calculation should work (approximate test)
      expect(profile.age, greaterThan(25));
      expect(profile.age, lessThan(30));
    });

    test('UserProfile should get primary image URL correctly', () {
      final images = [
        UserImage(id: 1, url: 'https://example.com/image1.jpg', isPrimary: false, order: 1),
        UserImage(id: 2, url: 'https://example.com/image2.jpg', isPrimary: true, order: 2),
        UserImage(id: 3, url: 'https://example.com/image3.jpg', isPrimary: false, order: 3),
      ];

      final profile = UserProfile(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        fullName: 'John Doe',
        email: 'john.doe@example.com',
        countryId: 1,
        cityId: 1,
        country: 'United States',
        city: 'New York',
        birthDate: '1995-06-15',
        profileBio: 'Love traveling and music!',
        height: 175,
        weight: 70,
        smoke: false,
        drink: true,
        gym: true,
        minAgePreference: 21,
        maxAgePreference: 35,
        profileCompleted: true,
        images: images,
        jobs: [],
        educations: [],
        musicGenres: [],
        languages: [],
        interests: [],
        preferredGenders: [],
        relationGoals: [],
      );

      expect(profile.primaryImageUrl, equals('https://example.com/image2.jpg'));
    });
  });
}

void testMatchingModels() {
  group('Matching Models', () {
    test('LikeUserRequest should serialize correctly', () {
      final request = LikeUserRequest(targetUserId: 2);
      final json = request.toJson();

      expect(json['target_user_id'], equals(2));
    });

    test('LikeData should serialize and deserialize correctly', () {
      final likeData = LikeData(
        likeId: 1,
        targetUserId: 2,
        status: 'matched',
        isMatch: true,
        matchId: 1,
        createdAt: '2024-01-01T12:00:00Z',
      );

      final json = likeData.toJson();
      final fromJson = LikeData.fromJson(json);

      expect(fromJson.likeId, equals(1));
      expect(fromJson.targetUserId, equals(2));
      expect(fromJson.status, equals('matched'));
      expect(fromJson.isMatch, isTrue);
      expect(fromJson.matchId, equals(1));
      expect(fromJson.createdAt, equals('2024-01-01T12:00:00Z'));
    });

    test('MatchUser should serialize and deserialize correctly', () {
      final matchUser = MatchUser(
        id: 2,
        name: 'Jane Smith',
        age: 25,
        avatarUrl: 'https://example.com/avatar.jpg',
        profileBio: 'Love hiking and photography!',
        city: 'New York',
      );

      final json = matchUser.toJson();
      final fromJson = MatchUser.fromJson(json);

      expect(fromJson.id, equals(2));
      expect(fromJson.name, equals('Jane Smith'));
      expect(fromJson.age, equals(25));
      expect(fromJson.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(fromJson.profileBio, equals('Love hiking and photography!'));
      expect(fromJson.city, equals('New York'));
    });

    test('LikeStatus extension should work correctly', () {
      expect(LikeStatus.pending.value, equals('pending'));
      expect(LikeStatus.matched.value, equals('matched'));
      expect(LikeStatus.rejected.value, equals('rejected'));

      expect(LikeStatusExtension.fromString('pending'), equals(LikeStatus.pending));
      expect(LikeStatusExtension.fromString('matched'), equals(LikeStatus.matched));
      expect(LikeStatusExtension.fromString('rejected'), equals(LikeStatus.rejected));
    });

    test('MatchingHelper should work correctly', () {
      final likeData = LikeData(
        likeId: 1,
        targetUserId: 2,
        status: 'matched',
        isMatch: true,
        matchId: 1,
        createdAt: '2024-01-01T12:00:00Z',
      );

      expect(MatchingHelper.isMatch(likeData), isTrue);
      expect(MatchingHelper.isLikePending(likeData), isFalse);
    });
  });
}

void testChatModels() {
  group('Chat Models', () {
    test('SendMessageRequest should serialize correctly', () {
      final request = SendMessageRequest(
        receiverId: 2,
        message: 'Hey! How are you?',
        messageType: MessageType.text,
      );

      final json = request.toJson();

      expect(json['receiver_id'], equals(2));
      expect(json['message'], equals('Hey! How are you?'));
      expect(json['message_type'], equals('text'));
    });

    test('MessageData should serialize and deserialize correctly', () {
      final message = MessageData(
        messageId: 1,
        senderId: 1,
        receiverId: 2,
        message: 'Hey! How are you?',
        messageType: MessageType.text,
        sentAt: '2024-01-01T12:00:00Z',
        isRead: false,
      );

      final json = message.toJson();
      final fromJson = MessageData.fromJson(json);

      expect(fromJson.messageId, equals(1));
      expect(fromJson.senderId, equals(1));
      expect(fromJson.receiverId, equals(2));
      expect(fromJson.message, equals('Hey! How are you?'));
      expect(fromJson.messageType, equals(MessageType.text));
      expect(fromJson.sentAt, equals('2024-01-01T12:00:00Z'));
      expect(fromJson.isRead, isFalse);
    });

    test('PaginationData should work correctly', () {
      final pagination = PaginationData(
        currentPage: 1,
        totalPages: 5,
        totalItems: 100,
        perPage: 20,
        hasNext: true,
        hasPrev: false,
      );

      expect(pagination.hasNextPage, isTrue);
      expect(pagination.hasPreviousPage, isFalse);
      expect(pagination.nextPage, equals(2));
      expect(pagination.previousPage, isNull);
    });

    test('MessageType extension should work correctly', () {
      expect(MessageType.text.value, equals('text'));
      expect(MessageType.image.value, equals('image'));
      expect(MessageType.video.value, equals('video'));

      expect(MessageTypeExtension.fromString('text'), equals(MessageType.text));
      expect(MessageTypeExtension.fromString('image'), equals(MessageType.image));
      expect(MessageTypeExtension.fromString('video'), equals(MessageType.video));
    });

    test('ChatHelper should work correctly', () {
      final message = MessageData(
        messageId: 1,
        senderId: 1,
        receiverId: 2,
        message: 'Hey! How are you?',
        messageType: MessageType.text,
        sentAt: '2024-01-01T12:00:00Z',
        isRead: false,
      );

      expect(ChatHelper.isFromCurrentUser(message, 1), isTrue);
      expect(ChatHelper.isToCurrentUser(message, 2), isTrue);
      expect(ChatHelper.isMessageRead(message), isFalse);
      expect(ChatHelper.isMessageUnread(message), isTrue);
    });
  });
}

void testProfileModels() {
  group('Profile Models', () {
    test('UpdateProfileRequest should serialize correctly', () {
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

      final json = request.toJson();

      expect(json['profile_bio'], equals('Updated bio text'));
      expect(json['height'], equals(180));
      expect(json['weight'], equals(75));
      expect(json['smoke'], isFalse);
      expect(json['drink'], isTrue);
      expect(json['gym'], isTrue);
      expect(json['min_age_preference'], equals(22));
      expect(json['max_age_preference'], equals(40));
    });

    test('UpdateProfileRequest should check if has data', () {
      final requestWithData = UpdateProfileRequest(
        profileBio: 'Updated bio text',
        height: 180,
      );

      final requestWithoutData = UpdateProfileRequest();

      expect(requestWithData.hasData, isTrue);
      expect(requestWithoutData.hasData, isFalse);
    });

    test('UploadProfilePictureRequest should work correctly', () {
      // Note: File testing would require actual file objects
      // This is a basic structure test
      expect(UploadProfilePictureRequest, isA<Type>());
    });

    test('ProfileHelper should validate correctly', () {
      expect(ProfileHelper.isValidProfileBio('Valid bio'), isTrue);
      expect(ProfileHelper.isValidProfileBio(''), isFalse);
      expect(ProfileHelper.isValidProfileBio(null), isTrue); // Optional field

      expect(ProfileHelper.isValidHeight(175), isTrue);
      expect(ProfileHelper.isValidHeight(50), isFalse); // Too short
      expect(ProfileHelper.isValidHeight(300), isFalse); // Too tall

      expect(ProfileHelper.isValidWeight(70), isTrue);
      expect(ProfileHelper.isValidWeight(20), isFalse); // Too light
      expect(ProfileHelper.isValidWeight(250), isFalse); // Too heavy

      expect(ProfileHelper.isValidAgePreference(21, 35), isTrue);
      expect(ProfileHelper.isValidAgePreference(17, 35), isFalse); // Too young
      expect(ProfileHelper.isValidAgePreference(21, 101), isFalse); // Too old
      expect(ProfileHelper.isValidAgePreference(35, 21), isFalse); // Min > Max
    });
  });
}

void testCommonModels() {
  group('Common Models', () {
    test('ApiErrorResponse should handle validation errors', () {
      final errorData = {
        'status': false,
        'message': 'Validation error',
        'errors': {
          'email': ['The email field is required.'],
          'password': ['The password field is required.'],
        },
      };

      final error = ApiErrorResponse.fromJson(errorData);

      expect(error.status, isFalse);
      expect(error.message, equals('Validation error'));
      expect(error.hasValidationErrors, isTrue);
      expect(error.firstValidationError, equals('The email field is required.'));
      expect(error.allValidationErrors, contains('The email field is required.'));
    });

    test('ApiSuccessResponse should work correctly', () {
      final successData = {
        'status': true,
        'message': 'Success',
        'data': {'id': 1, 'name': 'Test'},
      };

      final success = ApiSuccessResponse.fromJson(
        successData,
        (data) => {'id': data['id'], 'name': data['name']},
      );

      expect(success.status, isTrue);
      expect(success.message, equals('Success'));
      expect(success.data, isNotNull);
    });

    test('RateLimitResponse should work correctly', () {
      final rateLimitData = {
        'status': false,
        'message': 'Too many requests',
        'data': {
          'retry_after': 60,
        },
      };

      final rateLimit = RateLimitResponse.fromJson(rateLimitData);

      expect(rateLimit.status, isFalse);
      expect(rateLimit.message, equals('Too many requests'));
      expect(rateLimit.data?.retryAfter, equals(60));
    });

    test('WebSocketEvent should work correctly', () {
      final eventData = {
        'event': 'message.received',
        'data': {
          'message_id': 1,
          'sender_id': 2,
          'message': 'Hello!',
        },
      };

      final event = WebSocketEvent.fromJson(eventData);

      expect(event.event, equals(WebSocketEventType.messageReceived));
      expect(event.data['message_id'], equals(1));
      expect(event.data['sender_id'], equals(2));
      expect(event.data['message'], equals('Hello!'));
    });

    test('ApiUtils should work correctly', () {
      expect(ApiUtils.isSuccessStatusCode(200), isTrue);
      expect(ApiUtils.isSuccessStatusCode(201), isTrue);
      expect(ApiUtils.isClientErrorStatusCode(400), isTrue);
      expect(ApiUtils.isClientErrorStatusCode(404), isTrue);
      expect(ApiUtils.isServerErrorStatusCode(500), isTrue);
      expect(ApiUtils.isServerErrorStatusCode(503), isTrue);

      expect(ApiUtils.getApiResponseStatus(200), equals(ApiResponseStatus.success));
      expect(ApiUtils.getApiResponseStatus(401), equals(ApiResponseStatus.unauthorized));
      expect(ApiUtils.getApiResponseStatus(403), equals(ApiResponseStatus.forbidden));
      expect(ApiUtils.getApiResponseStatus(404), equals(ApiResponseStatus.notFound));
      expect(ApiUtils.getApiResponseStatus(422), equals(ApiResponseStatus.validationError));
      expect(ApiUtils.getApiResponseStatus(429), equals(ApiResponseStatus.rateLimited));
      expect(ApiUtils.getApiResponseStatus(500), equals(ApiResponseStatus.serverError));

      expect(ApiUtils.isValidEmail('test@example.com'), isTrue);
      expect(ApiUtils.isValidEmail('invalid-email'), isFalse);

      expect(ApiUtils.isValidPassword('Password123'), isTrue);
      expect(ApiUtils.isValidPassword('weak'), isFalse);

      expect(ApiUtils.sanitizeString('  hello   world  '), equals('hello world'));
    });
  });
}
