import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class GroupChatService {
  /// Create a new group chat
  static Future<Map<String, dynamic>> createGroup({
    required String name,
    required List<String> memberIds,
    String? accessToken,
    String? description,
    File? groupImage,
    Map<String, dynamic>? settings,
  }) async {
    try {
      if (groupImage != null) {
        // Create group with image
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getUrl(ApiConfig.groupChatCreate)),
        );

        request.headers.addAll({
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });

        request.fields.addAll({
          'name': name,
          'member_ids': jsonEncode(memberIds),
          if (description != null) 'description': description,
          if (settings != null) 'settings': jsonEncode(settings),
        });

        request.files.add(await http.MultipartFile.fromPath('group_image', groupImage.path));

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
          throw ApiException('Failed to create group: ${response.statusCode}');
        }
      } else {
        // Create group without image
        final response = await http.post(
          Uri.parse(ApiConfig.getUrl(ApiConfig.groupChatCreate)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'name': name,
            'member_ids': memberIds,
            if (description != null) 'description': description,
            if (settings != null) 'settings': settings,
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
          throw ApiException('Failed to create group: ${response.statusCode}');
        }
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while creating group: $e');
    }
  }

  /// Get user's groups
  static Future<List<Map<String, dynamic>>> getUserGroups({
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.groupChatGroups));
      
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
      } else {
        throw ApiException('Failed to fetch user groups: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching user groups: $e');
    }
  }

  /// Get group details
  static Future<Map<String, dynamic>> getGroup(String groupId, {String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.groupChatGroupById, {'groupId': groupId})),
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
        throw ApiException('Group not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied to this group');
      } else {
        throw ApiException('Failed to fetch group details: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching group details: $e');
    }
  }

  /// Send message to group
  static Future<Map<String, dynamic>> sendMessage(String groupId, {
    required String content,
    String? accessToken,
    String messageType = 'text',
    File? attachment,
  }) async {
    try {
      if (attachment != null) {
        // Send message with attachment
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getUrl(ApiConfig.groupChatSendMessage)),
        );

        request.headers.addAll({
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });

        request.fields.addAll({
          'group_id': groupId,
          'content': content,
          'type': messageType,
        });

        request.files.add(await http.MultipartFile.fromPath('attachment', attachment.path));

        final streamResponse = await request.send();
        final responseBody = await streamResponse.stream.bytesToString();
        final response = http.Response(responseBody, streamResponse.statusCode);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['data'] ?? data;
        } else if (response.statusCode == 401) {
          throw AuthException('Authentication required');
        } else if (response.statusCode == 403) {
          throw ApiException('Access denied to this group');
        } else if (response.statusCode == 404) {
          throw ApiException('Group not found');
        } else if (response.statusCode == 422) {
          final data = jsonDecode(response.body);
          throw ValidationException(
            data['message'] ?? 'Validation failed',
            data['errors'] ?? <String, String>{},
          );
        } else {
          throw ApiException('Failed to send message: ${response.statusCode}');
        }
      } else {
        // Send text message
        final response = await http.post(
          Uri.parse(ApiConfig.getUrl(ApiConfig.groupChatSendMessage)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'group_id': groupId,
            'content': content,
            'type': messageType,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['data'] ?? data;
        } else if (response.statusCode == 401) {
          throw AuthException('Authentication required');
        } else if (response.statusCode == 403) {
          throw ApiException('Access denied to this group');
        } else if (response.statusCode == 404) {
          throw ApiException('Group not found');
        } else if (response.statusCode == 422) {
          final data = jsonDecode(response.body);
          throw ValidationException(
            data['message'] ?? 'Validation failed',
            data['errors'] ?? <String, String>{},
          );
        } else {
          throw ApiException('Failed to send message: ${response.statusCode}');
        }
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending message: $e');
    }
  }

  /// Get group messages
  static Future<List<Map<String, dynamic>>> getGroupMessages(String groupId, {
    String? accessToken,
    int? page,
    int? limit,
    String? beforeMessageId,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.groupChatMessages, {'groupId': groupId}));
      
      // Add query parameters
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (beforeMessageId != null) queryParams['before'] = beforeMessageId;
      
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied to this group');
      } else if (response.statusCode == 404) {
        throw ApiException('Group not found');
      } else {
        throw ApiException('Failed to fetch group messages: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching group messages: $e');
    }
  }

  /// Add members to group
  static Future<Map<String, dynamic>> addMembers(String groupId, List<String> memberIds, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.groupChatAddMembers, {'groupId': groupId})),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'member_ids': memberIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied or insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Group not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to add members: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while adding members: $e');
    }
  }

  /// Remove member from group
  static Future<bool> removeMember(String groupId, String memberId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.groupChatRemoveMember, {'groupId': groupId}) + '?member_id=$memberId'),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied or insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Group or member not found');
      } else {
        throw ApiException('Failed to remove member: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while removing member: $e');
    }
  }

  /// Leave group
  static Future<bool> leaveGroup(String groupId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.groupChatLeave, {'groupId': groupId})),
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
        throw ApiException('Group not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Cannot leave group');
      } else {
        throw ApiException('Failed to leave group: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while leaving group: $e');
    }
  }

  /// Update group settings
  static Future<Map<String, dynamic>> updateGroup(String groupId, Map<String, dynamic> updates, {String? accessToken}) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.groupChatGroupById, {'groupId': groupId})),
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
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied or insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Group not found');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else {
        throw ApiException('Failed to update group: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ValidationException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating group: $e');
    }
  }

  /// Make user admin
  static Future<bool> makeAdmin(String groupId, String userId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.groupChatGroupById, {'groupId': groupId}) + '/make-admin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied or insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Group or user not found');
      } else {
        throw ApiException('Failed to make user admin: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while making user admin: $e');
    }
  }

  /// Remove admin privileges
  static Future<bool> removeAdmin(String groupId, String userId, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrlWithParams(ApiConfig.groupChatGroupById, {'groupId': groupId}) + '/remove-admin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 403) {
        throw ApiException('Access denied or insufficient permissions');
      } else if (response.statusCode == 404) {
        throw ApiException('Group or user not found');
      } else {
        throw ApiException('Failed to remove admin privileges: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while removing admin privileges: $e');
    }
  }
}
