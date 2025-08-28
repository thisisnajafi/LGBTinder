import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';

class ChatService {
  /// Send a message
  static Future<Message> sendMessage(String recipientId, String content, {
    String? accessToken,
    String messageType = 'text',
    File? attachment,
  }) async {
    try {
      http.Response response;

      if (attachment != null) {
        // Send multipart request for messages with attachments
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getUrl(ApiConfig.chatSend)),
        );

        request.headers.addAll({
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });

        request.fields.addAll({
          'recipient_id': recipientId,
          'content': content,
          'type': messageType,
        });

        request.files.add(await http.MultipartFile.fromPath('attachment', attachment.path));

        final streamResponse = await request.send();
        final responseBody = await streamResponse.stream.bytesToString();
        response = http.Response(responseBody, streamResponse.statusCode);
      } else {
        // Send regular JSON request for text messages
        response = await http.post(
          Uri.parse(ApiConfig.getUrl(ApiConfig.chatSend)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'recipient_id': recipientId,
            'content': content,
            'type': messageType,
          }),
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Message.fromJson(data['data'] ?? data);
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw ValidationException(
          data['message'] ?? 'Validation failed',
          data['errors'] ?? <String, String>{},
        );
      } else if (response.statusCode == 404) {
        throw ApiException('Recipient not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Cannot send message to this user');
      } else {
        throw ApiException('Failed to send message: ${response.statusCode}');
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

  /// Get chat history with a user
  static Future<List<Message>> getChatHistory(String userId, {
    String? accessToken,
    int? page,
    int? limit,
    String? beforeMessageId,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.chatHistory));
      
      // Add query parameters
      final queryParams = <String, String>{'user_id': userId};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (beforeMessageId != null) queryParams['before'] = beforeMessageId;
      
      uri = uri.replace(queryParameters: queryParams);

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
        return items.map((item) => Message.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Chat not found');
      } else {
        throw ApiException('Failed to fetch chat history: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching chat history: $e');
    }
  }

  /// Get all chat users (conversations list)
  static Future<List<Chat>> getChatUsers({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatUsers)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'] ?? data;
        return items.map((item) => Chat.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch chat users: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching chat users: $e');
    }
  }

  /// Get accessible users (users you can chat with)
  static Future<List<User>> getAccessibleUsers({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatAccessUsers)),
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
        throw ApiException('Failed to fetch accessible users: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching accessible users: $e');
    }
  }

  /// Delete a message
  static Future<bool> deleteMessage(String messageId, {String? accessToken}) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatMessage) + '?message_id=$messageId'),
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
        throw ApiException('Message not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Cannot delete this message');
      } else {
        throw ApiException('Failed to delete message: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while deleting message: $e');
    }
  }

  /// Get unread message count
  static Future<int> getUnreadCount({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatUnreadCount)),
        headers: {
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['unread_count'] ?? data['unread_count'] ?? 0;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to fetch unread count: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching unread count: $e');
    }
  }

  /// Send typing indicator
  static Future<bool> sendTypingIndicator(String userId, bool isTyping, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatTyping)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'user_id': userId,
          'is_typing': isTyping,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to send typing indicator: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while sending typing indicator: $e');
    }
  }

  /// Mark messages as read
  static Future<bool> markMessagesAsRead(String userId, {String? accessToken, List<String>? messageIds}) async {
    try {
      final requestBody = <String, dynamic>{'user_id': userId};
      if (messageIds != null && messageIds.isNotEmpty) {
        requestBody['message_ids'] = messageIds;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatRead)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('User not found');
      } else {
        throw ApiException('Failed to mark messages as read: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while marking messages as read: $e');
    }
  }

  /// Update online status
  static Future<bool> updateOnlineStatus(bool isOnline, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatOnline)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'is_online': isOnline,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else {
        throw ApiException('Failed to update online status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while updating online status: $e');
    }
  }

  /// Get chat statistics (unread count per conversation)
  static Future<Map<String, dynamic>> getChatStatistics({String? accessToken}) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatUnreadCount) + '/detailed'),
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
        throw ApiException('Failed to fetch chat statistics: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching chat statistics: $e');
    }
  }

  // Additional methods for ChatProvider compatibility

  /// Get user's chats (alias for getChatUsers)
  static Future<List<Map<String, dynamic>>> getChats({
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    // Use existing getChatUsers method
    return getChatUsers(accessToken: accessToken);
  }

  /// Get specific chat by ID (placeholder implementation)
  static Future<Map<String, dynamic>?> getChat(String chatId, {String? accessToken}) async {
    try {
      // This would typically fetch specific chat details
      // For now, return basic chat structure
      return {
        'id': chatId,
        'type': 'direct',
        'participants': [],
        'last_message': null,
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw NetworkException('Network error while fetching chat: $e');
    }
  }

  /// Create new chat (placeholder implementation) 
  static Future<Map<String, dynamic>> createChat(String userId, {String? accessToken}) async {
    try {
      // This would typically create a new chat with a user
      // For now, return basic chat structure
      return {
        'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'direct',
        'participants': [userId],
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw NetworkException('Network error while creating chat: $e');
    }
  }

  /// Create group chat (placeholder implementation)
  static Future<Map<String, dynamic>> createGroupChat({
    required String name,
    required List<String> userIds,
    String? accessToken,
  }) async {
    try {
      // This would typically create a new group chat
      // For now, return basic group structure
      return {
        'id': 'group_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'group',
        'name': name,
        'participants': userIds,
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw NetworkException('Network error while creating group chat: $e');
    }
  }

  /// Update chat (placeholder implementation)
  static Future<Map<String, dynamic>> updateChat(String chatId, Map<String, dynamic> updates, {String? accessToken}) async {
    try {
      // This would typically update chat settings
      // For now, return updated chat structure
      return {
        'id': chatId,
        'updated_at': DateTime.now().toIso8601String(),
        ...updates,
      };
    } catch (e) {
      throw NetworkException('Network error while updating chat: $e');
    }
  }

  /// Archive chat (placeholder implementation)
  static Future<bool> archiveChat(String chatId, {String? accessToken}) async {
    try {
      // This would typically archive a chat
      return true;
    } catch (e) {
      throw NetworkException('Network error while archiving chat: $e');
    }
  }

  /// Unarchive chat (placeholder implementation)
  static Future<bool> unarchiveChat(String chatId, {String? accessToken}) async {
    try {
      // This would typically unarchive a chat
      return true;
    } catch (e) {
      throw NetworkException('Network error while unarchiving chat: $e');
    }
  }

  /// Pin chat (placeholder implementation)
  static Future<bool> pinChat(String chatId, {String? accessToken}) async {
    try {
      // This would typically pin a chat
      return true;
    } catch (e) {
      throw NetworkException('Network error while pinning chat: $e');
    }
  }

  /// Unpin chat (placeholder implementation)
  static Future<bool> unpinChat(String chatId, {String? accessToken}) async {
    try {
      // This would typically unpin a chat
      return true;
    } catch (e) {
      throw NetworkException('Network error while unpinning chat: $e');
    }
  }

  /// Delete chat (placeholder implementation)
  static Future<bool> deleteChat(String chatId, {String? accessToken}) async {
    try {
      // This would typically delete a chat
      return true;
    } catch (e) {
      throw NetworkException('Network error while deleting chat: $e');
    }
  }

  /// Mark chat as read (alias for markMessagesAsRead)
  static Future<bool> markChatAsRead(String chatId, {String? accessToken}) async {
    try {
      // Use existing markMessagesAsRead method
      return await markMessagesAsRead(chatId: chatId, accessToken: accessToken);
    } catch (e) {
      throw NetworkException('Network error while marking chat as read: $e');
    }
  }
}