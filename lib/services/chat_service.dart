import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/error_handler.dart';
import 'haptic_feedback_service.dart';
import 'image_compression_service.dart';

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

        // Compress image before upload
        final compressedFile = await ImageCompressionService().compressChatImage(attachment);
        request.files.add(await http.MultipartFile.fromPath('attachment', compressedFile?.path ?? attachment.path));

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
        // Haptic feedback for successful message send
        await HapticFeedbackService().messageSent();
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
      await HapticFeedbackService().error();
      rethrow;
    } on ValidationException {
      await HapticFeedbackService().error();
      rethrow;
    } on ApiException {
      await HapticFeedbackService().error();
      rethrow;
    } catch (e) {
      await HapticFeedbackService().error();
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
  static Future<List<Chat>> getChats({
    String? accessToken,
    int? page,
    int? limit,
  }) async {
    // Use existing getChatUsers method
    return getChatUsers(accessToken: accessToken);
  }

  /// Get specific chat by ID (placeholder implementation)
  static Future<Chat?> getChat(String chatId, {String? accessToken}) async {
    try {
      // This would typically fetch specific chat details
      // For now, return basic chat structure
      final chatData = {
        'id': chatId,
        'type': 'direct',
        'participants': [],
        'last_message': null,
        'created_at': DateTime.now().toIso8601String(),
      };
      return Chat.fromJson(chatData);
    } catch (e) {
      throw NetworkException('Network error while fetching chat: $e');
    }
  }

  /// Create new chat (placeholder implementation) 
  static Future<Chat> createChat(String userId, {String? accessToken}) async {
    try {
      // This would typically create a new chat with a user
      // For now, return basic chat structure
      final chatData = {
        'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'direct',
        'participants': [userId],
        'created_at': DateTime.now().toIso8601String(),
      };
      return Chat.fromJson(chatData);
    } catch (e) {
      throw NetworkException('Network error while creating chat: $e');
    }
  }

  /// Create group chat (placeholder implementation)
  static Future<Chat> createGroupChat({
    required String name,
    required List<String> userIds,
    String? accessToken,
  }) async {
    try {
      // This would typically create a new group chat
      // For now, return basic group structure
      final chatData = {
        'id': 'group_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'group',
        'name': name,
        'participants': userIds,
        'created_at': DateTime.now().toIso8601String(),
      };
      return Chat.fromJson(chatData);
    } catch (e) {
      throw NetworkException('Network error while creating group chat: $e');
    }
  }

  /// Update chat (placeholder implementation)
  static Future<Chat> updateChat(String chatId, Map<String, dynamic> updates, {String? accessToken}) async {
    try {
      // This would typically update chat settings
      // For now, return updated chat structure
      final chatData = {
        'id': chatId,
        'type': 'direct',
        'participants': [],
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        ...updates,
      };
      return Chat.fromJson(chatData);
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
      // Use existing markMessagesAsRead method with chatId as userId
      return await markMessagesAsRead(chatId, accessToken: accessToken);
    } catch (e) {
      throw NetworkException('Network error while marking chat as read: $e');
    }
  }

  // Additional message methods for ChatProvider compatibility

  /// Get messages (alias for getChatHistory)
  static Future<List<Message>> getMessages(
    String chatId, {
    String? accessToken,
    int? page,
    int? limit,
    String? beforeMessageId,
    String? afterMessageId,
  }) async {
    return getChatHistory(chatId, accessToken: accessToken, page: page, limit: limit);
  }

  /// Send text message (alias for sendMessage)
  static Future<Message> sendTextMessage(
    String recipientId,
    String content, {
    String? accessToken,
    String? replyToId,
  }) async {
    return sendMessage(recipientId, content, accessToken: accessToken);
  }

  /// Send media message (placeholder - adjust parameters as needed)
  static Future<Message> sendMediaMessage(
    String chatId,
    String type,
    List<File> attachments, {
    String? content,
    String? replyToId,
    String? accessToken,
  }) async {
    // For now, use the first attachment and call sendMessage
    final attachment = attachments.isNotEmpty ? attachments.first : null;
    final messageContent = content ?? '';
    return sendMessage(chatId, messageContent, accessToken: accessToken, attachment: attachment);
  }

  /// Edit message (placeholder implementation)
  static Future<Message> editMessage(
    String chatId,
    String messageId,
    String newContent, {
    String? accessToken,
  }) async {
    try {
      // This would typically edit an existing message
      // For now, return a basic message structure
      final messageData = {
        'id': messageId,
        'chat_id': chatId,
        'content': newContent,
        'sender_id': 'current_user',
        'type': 'text',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      return Message.fromJson(messageData);
    } catch (e) {
      throw NetworkException('Network error while editing message: $e');
    }
  }

  /// Mark message as read (placeholder implementation)
  static Future<bool> markMessageAsRead(String chatId, String messageId, {String? accessToken}) async {
    try {
      // This would typically mark a specific message as read
      return true;
    } catch (e) {
      throw NetworkException('Network error while marking message as read: $e');
    }
  }

  /// Mark all messages as read (placeholder implementation)
  static Future<bool> markAllMessagesAsRead(String chatId, {String? accessToken}) async {
    try {
      // This would typically mark all messages in a chat as read
      return true;
    } catch (e) {
      throw NetworkException('Network error while marking all messages as read: $e');
    }
  }

  /// React to message (placeholder implementation)
  static Future<bool> reactToMessage(String chatId, String messageId, String reaction, {String? accessToken}) async {
    try {
      // This would typically add a reaction to a message
      return true;
    } catch (e) {
      throw NetworkException('Network error while reacting to message: $e');
    }
  }

  /// Remove reaction (placeholder implementation)
  static Future<bool> removeReaction(String chatId, String messageId, {String? accessToken}) async {
    try {
      // This would typically remove a reaction from a message
      return true;
    } catch (e) {
      throw NetworkException('Network error while removing reaction: $e');
    }
  }

  /// Send typing indicator to specific user
  static Future<bool> sendTypingIndicatorToUser(String receiverId, bool isTyping, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatTyping)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'receiver_id': receiverId,
          'is_typing': isTyping,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Receiver not found');
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

  /// Mark messages as read with specific message IDs
  static Future<bool> markMessagesAsReadWithIds(String senderId, List<String> messageIds, {String? accessToken}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getUrl(ApiConfig.chatRead)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'sender_id': senderId,
          'message_ids': messageIds,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw AuthException('Authentication required');
      } else if (response.statusCode == 404) {
        throw ApiException('Sender not found');
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

  /// Set online status
  static Future<bool> setOnlineStatus(bool isOnline, {String? accessToken}) async {
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
        throw ApiException('Failed to set online status: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while setting online status: $e');
    }
  }

  /// Send message with media
  static Future<Message> sendMessageWithMedia({
    required String receiverId,
    required String message,
    required String messageType,
    File? media,
    String? accessToken,
  }) async {
    try {
      http.Response response;

      if (media != null) {
        // Send multipart request for messages with media
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(ApiConfig.getUrl(ApiConfig.chatSend)),
        );

        request.headers.addAll({
          'Accept': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        });

        request.fields.addAll({
          'receiver_id': receiverId,
          'message': message,
          'message_type': messageType,
        });

        // Compress image before upload if it's an image
        if (messageType == 'image') {
          final compressedFile = await ImageCompressionService().compressChatImage(media);
          request.files.add(await http.MultipartFile.fromPath('media', compressedFile?.path ?? media.path));
        } else {
          request.files.add(await http.MultipartFile.fromPath('media', media.path));
        }

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
            'receiver_id': receiverId,
            'message': message,
            'message_type': messageType,
          }),
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Haptic feedback for successful message send
        await HapticFeedbackService().messageSent();
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
        throw ApiException('Receiver not found');
      } else if (response.statusCode == 403) {
        throw ApiException('Cannot send message to this user');
      } else {
        throw ApiException('Failed to send message: ${response.statusCode}');
      }
    } on AuthException {
      await HapticFeedbackService().error();
      rethrow;
    } on ValidationException {
      await HapticFeedbackService().error();
      rethrow;
    } on ApiException {
      await HapticFeedbackService().error();
      rethrow;
    } catch (e) {
      await HapticFeedbackService().error();
      throw NetworkException('Network error while sending message: $e');
    }
  }

  /// Get chat history with user
  static Future<List<Message>> getChatHistoryWithUser(String userId, {
    String? accessToken,
    int? page,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(ApiConfig.chatHistory));
      
      final queryParams = <String, String>{'user_id': userId};
      if (page != null) queryParams['page'] = page.toString();
      
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

  /// Get users with chat access
  static Future<List<User>> getUsersWithChatAccess({String? accessToken}) async {
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
        throw ApiException('Failed to fetch users with chat access: ${response.statusCode}');
      }
    } on AuthException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Network error while fetching users with chat access: $e');
    }
  }

  /// Delete own message
  static Future<bool> deleteOwnMessage(String messageId, {String? accessToken}) async {
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
}