import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';
import 'image_compression_service.dart';

class ProfileService {

  /// Get current user's profile
  static Future<User> getProfile({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profile)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profile: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profile: $e');
    }
  }

  /// Get profile by ID
  static Future<User> getProfileById(String userId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileById, {'id': userId})),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Profile not found');
      } else {
        throw ApiException('Failed to fetch profile: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profile: $e');
    }
  }

  /// Update user profile
  static Future<User> updateProfile(Map<String, dynamic> profileData, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profileUpdate)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update profile: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating profile: $e');
    }
  }

  /// Get profile badge information
  static Future<Map<String, dynamic>> getProfileBadgeInfo({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profileBadgeInfo)),
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
      } else {
        throw ApiException('Failed to fetch profile badge info: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profile badge info: $e');
    }
  }

  /// Upload image file
  static Future<Map<String, dynamic>> uploadImage(File imageFile, {String? accessToken}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getUrl(ApiConfig.imagesUpload)),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      });

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(responseBody);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to upload image: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while uploading image: $e');
    }
  }

  /// Delete image by ID
  static Future<bool> deleteImage(String imageId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.imagesDelete, {'id': imageId})),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Image not found');
      } else {
        throw ApiException('Failed to delete image: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting image: $e');
    }
  }

  /// Set image as primary
  static Future<bool> setPrimaryImage(String imageId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.imagesSetPrimary, {'id': imageId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Image not found');
      } else {
        throw ApiException('Failed to set primary image: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while setting primary image: $e');
    }
  }

  /// Get user's images
  static Future<List<UserImage>> getImages({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.imagesList)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => UserImage.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch images: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching images: $e');
    }
  }

  /// Upload profile picture
  static Future<Map<String, dynamic>> uploadProfilePicture(File imageFile, {String? accessToken}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getUrl(ApiConfig.profilePicturesUpload)),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      });

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(responseBody);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to upload profile picture: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while uploading profile picture: $e');
    }
  }

  /// Delete profile picture by ID
  static Future<bool> deleteProfilePicture(String imageId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profilePicturesDelete, {'id': imageId})),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Profile picture not found');
      } else {
        throw ApiException('Failed to delete profile picture: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting profile picture: $e');
    }
  }

  /// Set profile picture as primary
  static Future<bool> setPrimaryProfilePicture(String imageId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profilePicturesSetPrimary, {'id': imageId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Profile picture not found');
      } else {
        throw ApiException('Failed to set primary profile picture: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while setting primary profile picture: $e');
    }
  }

  /// Get user's profile pictures
  static Future<List<UserImage>> getProfilePictures({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.profilePicturesList)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => UserImage.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profile pictures: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profile pictures: $e');
    }
  }

  /// Get user's feeds
  static Future<List<Map<String, dynamic>>> getProfileFeeds(String userId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileFeeds, {'id': userId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        throw ApiException('Profile not found');
      } else {
        throw ApiException('Failed to fetch profile feeds: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profile feeds: $e');
    }
  }

  /// Get profiles by job
  static Future<List<User>> getProfilesByJob(String jobId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileByJob, {'jobId': jobId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profiles by job: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profiles by job: $e');
    }
  }

  /// Get profiles by language
  static Future<List<User>> getProfilesByLanguage(String languageId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileByLanguage, {'languageId': languageId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profiles by language: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profiles by language: $e');
    }
  }

  /// Get profiles by relation goal
  static Future<List<User>> getProfilesByRelationGoal(String relationGoalId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileByRelationGoal, {'relationGoalId': relationGoalId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profiles by relation goal: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profiles by relation goal: $e');
    }
  }

  /// Get profiles by interest
  static Future<List<User>> getProfilesByInterest(String interestId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileByInterest, {'interestId': interestId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profiles by interest: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profiles by interest: $e');
    }
  }

  /// Get profiles by music genre
  static Future<List<User>> getProfilesByMusicGenre(String musicGenreId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileByMusicGenre, {'musicGenreId': musicGenreId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profiles by music genre: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profiles by music genre: $e');
    }
  }

  /// Get profiles by education
  static Future<List<User>> getProfilesByEducation(String educationId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileByEducation, {'educationId': educationId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profiles by education: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profiles by education: $e');
    }
  }

  /// Get profiles by preferred gender
  static Future<List<User>> getProfilesByPreferredGender(String preferredGenderId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileByPreferredGender, {'preferredGenderId': preferredGenderId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profiles by preferred gender: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profiles by preferred gender: $e');
    }
  }

  /// Get profiles by gender
  static Future<List<User>> getProfilesByGender(String genderId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.profileByGender, {'genderId': genderId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      
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
        return items.map((item) => User.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch profiles by gender: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching profiles by gender: $e');
    }
  }

  /// Reorder images
  static Future<bool> reorderImages(List<String> imageIds, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl('/images/reorder')),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'image_ids': imageIds,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to reorder images: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while reordering images: $e');
    }
  }

  /// Upload multiple images at once
  static Future<List<Map<String, dynamic>>> uploadMultipleImages(List<File> imageFiles, {String? accessToken}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.getUrl(ApiConfig.imagesUpload)),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      });

      // Add multiple files
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(await http.MultipartFile.fromPath('images[$i]', imageFiles[i].path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final List<dynamic> items = data['data'] ?? data;
        return items.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(responseBody);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to upload images: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while uploading images: $e');
    }
  }

  /// Get current user profile with subscription info
  static Future<Map<String, dynamic>> getCurrentUserProfile({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl('/user')),
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
      } else {
        throw ApiException('Failed to fetch current user profile: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching current user profile: $e');
    }
  }

}
