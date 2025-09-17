import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class FeedsService {
  /// Get feeds timeline
  static Future<List<Map<String, dynamic>>> getFeeds({
    String? accessToken,
    int? page,
    int? limit,
    String? type,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.feeds));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (type != null) queryParams['type'] = type;
      
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
      } else {
        throw ApiException('Failed to fetch feeds: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching feeds: $e');
    }
  }

  /// Create a new feed post
  static Future<Map<String, dynamic>> createFeed({
    required String content,
    String? accessToken,
    List<File>? attachments,
    String? type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (attachments != null && attachments.isNotEmpty) {
        // Create multipart request for posts with attachments
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getUrl(ApiConfig.feedsCreate)),
        );

        request.headers.addAll({
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });

        request.fields.addAll({
          'content': content,
          if (type != null) 'type': type,
          if (metadata != null) 'metadata': jsonEncode(metadata),
        });

        // Add file attachments
        for (int i = 0; i < attachments.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'attachments[$i]',
              attachments[i].path,
            ),
          );
        }

        final streamResponse = await request.send();
        final responseBody = await streamResponse.stream.bytesToString();
        final response = http.Response(responseBody, streamResponse.statusCode);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['data'] ?? data;
        } else if (response.statusCode == 401) {
          throw AuthException('Authentication required');
        } else if (response.statusCode == 422) {
          final data = jsonDecode(response.body);
          throw ValidationException(
            data['message'] ?? 'Validation failed',
            data['errors'] ?? <String, String>{},
          );
        } else {
          throw ApiException('Failed to create feed: ${response.statusCode}');
        }
      } else {
        // Simple text post
        final response = await http.post(
          Uri.parse(ApiConfig.getUrl(ApiConfig.feedsCreate)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'content': content,
            if (type != null) 'type': type,
            if (metadata != null) 'metadata': metadata,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['data'] ?? data;
        } else if (response.statusCode == 401) {
          throw AuthException('Authentication required');
        } else if (response.statusCode == 422) {
          final data = jsonDecode(response.body);
          throw ValidationException(
            data['message'] ?? 'Validation failed',
            data['errors'] ?? <String, String>{},
          );
        } else {
          throw ApiException('Failed to create feed: ${response.statusCode}');
        }
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating feed: $e');
    }
  }

  /// Get feed by ID
  static Future<Map<String, dynamic>> getFeed(String feedId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsById, {'id': feedId})),
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
      } else if (response.statusCode == 404) {
        throw ApiException('Feed not found');
      } else {
        throw ApiException('Failed to fetch feed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching feed: $e');
    }
  }

  /// Update feed
  static Future<Map<String, dynamic>> updateFeed(String feedId, Map<String, dynamic> updates, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsUpdate, {'id': feedId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Feed not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Not authorized to update this feed');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update feed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating feed: $e');
    }
  }

  /// Delete feed
  static Future<bool> deleteFeed(String feedId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsDelete, {'id': feedId})),
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
        throw ApiException('Feed not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Not authorized to delete this feed');
      } else {
        throw ApiException('Failed to delete feed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting feed: $e');
    }
  }

  /// Get feed comments
  static Future<List<Map<String, dynamic>>> getFeedComments(String feedId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsComments, {'feedId': feedId}));
      
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
        throw ApiException('Feed not found');
      } else {
        throw ApiException('Failed to fetch comments: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching comments: $e');
    }
  }

  /// Add comment to feed
  static Future<Map<String, dynamic>> addComment(String feedId, String content, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsComments, {'feedId': feedId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Feed not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to add comment: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while adding comment: $e');
    }
  }

  /// Like/unlike a comment
  static Future<bool> likeComment(String feedId, String commentId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsCommentLike, {
          'feedId': feedId,
          'commentId': commentId,
        })),
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
        throw ApiException('Comment not found');
      } else {
        throw ApiException('Failed to like comment: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while liking comment: $e');
    }
  }

  /// React to feed (like, love, etc.)
  static Future<Map<String, dynamic>> reactToFeed(String feedId, String reactionType, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsReactions, {'feedId': feedId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'type': reactionType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Feed not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Invalid reaction type',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to react to feed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while reacting to feed: $e');
    }
  }

  /// Remove reaction from feed
  static Future<bool> removeReaction(String feedId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsReactions, {'feedId': feedId})),
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
        throw ApiException('Feed or reaction not found');
      } else {
        throw ApiException('Failed to remove reaction: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while removing reaction: $e');
    }
  }

  /// Get user's reaction to a feed
  static Future<Map<String, dynamic>?> getMyReaction(String feedId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsMyReaction, {'feedId': feedId})),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        return null; // No reaction found
      } else {
        throw ApiException('Failed to fetch reaction: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching reaction: $e');
    }
  }

  /// Get user's liked feeds
  static Future<List<Map<String, dynamic>>> getLikedFeeds({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.feedsLiked)),
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
      } else {
        throw ApiException('Failed to fetch liked feeds: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching liked feeds: $e');
    }
  }

  /// Update comment
  static Future<Map<String, dynamic>> updateComment(String feedId, String commentId, String content, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsCommentUpdate, {
          'feedId': feedId,
          'commentId': commentId,
        })),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Comment not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Not authorized to update this comment');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update comment: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating comment: $e');
    }
  }

  /// Delete comment
  static Future<bool> deleteComment(String feedId, String commentId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsCommentDelete, {
          'feedId': feedId,
          'commentId': commentId,
        })),
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
        throw ApiException('Comment not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Not authorized to delete this comment');
      } else {
        throw ApiException('Failed to delete comment: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting comment: $e');
    }
  }

  /// Get feed reactions
  static Future<List<Map<String, dynamic>>> getFeedReactions(String feedId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsReactions, {'feedId': feedId})),
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
        throw ApiException('Feed not found');
      } else {
        throw ApiException('Failed to fetch feed reactions: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching feed reactions: $e');
    }
  }

  /// Get feed statistics
  static Future<Map<String, dynamic>> getFeedStatistics(String feedId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsById, {'id': feedId}) + '/statistics'),
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
      } else if (response.statusCode == 404) {
        throw ApiException('Feed not found');
      } else {
        throw ApiException('Failed to fetch feed statistics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching feed statistics: $e');
    }
  }

  /// Share feed
  static Future<Map<String, dynamic>> shareFeed(String feedId, {String? accessToken, String? message}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsById, {'id': feedId}) + '/share'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          if (message != null) 'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Feed not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to share feed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sharing feed: $e');
    }
  }

  /// Report feed
  static Future<bool> reportFeed(String feedId, String reason, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsById, {'id': feedId}) + '/report'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Feed not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to report feed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while reporting feed: $e');
    }
  }

  /// Get user's feeds
  static Future<List<Map<String, dynamic>>> getUserFeeds(String userId, {
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsUser, {'userId': userId}));
      
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
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to fetch user feeds: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching user feeds: $e');
    }
  }

  /// Get feed by ID with full details
  static Future<Map<String, dynamic>> getFeedDetails(String feedId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsById, {'id': feedId}) + '/details'),
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
      } else if (response.statusCode == 404) {
        throw ApiException('Feed not found');
      } else {
        throw ApiException('Failed to fetch feed details: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching feed details: $e');
    }
  }

  /// Get feed posts (alias for getFeeds)
  static Future<List<Map<String, dynamic>>> getFeedPosts({
    String? accessToken,
    int? page,
    int? limit,
    String? type,
  }) async {
    return getFeeds(
      accessToken: accessToken,
      page: page,
      limit: limit,
      type: type,
    );
  }

  /// Get users with stories
  static Future<List<Map<String, dynamic>>> getUsersWithStories({
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.storiesUsers));
      
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
      } else {
        throw ApiException('Failed to fetch users with stories: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching users with stories: $e');
    }
  }

  /// Pin/unpin feed
  static Future<bool> togglePinFeed(String feedId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.feedsById, {'id': feedId}) + '/pin'),
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
        throw ApiException('Feed not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Not authorized to pin this feed');
      } else {
        throw ApiException('Failed to toggle pin feed: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while toggling pin feed: $e');
    }
  }

  /// Get pinned feeds
  static Future<List<Map<String, dynamic>>> getPinnedFeeds({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.feedsPinned)),
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
      } else {
        throw ApiException('Failed to fetch pinned feeds: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching pinned feeds: $e');
    }
  }
}
