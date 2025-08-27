import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_service.dart';

class MessageService {
  final ApiService _apiService;

  MessageService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Get messages for a chat
  Future<List<Message>> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
    String? beforeMessageId,
    String? afterMessageId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (beforeMessageId != null) {
        queryParams['before'] = beforeMessageId;
      }
      if (afterMessageId != null) {
        queryParams['after'] = afterMessageId;
      }

      final response = await _apiService.get(
        '/chats/$chatId/messages',
        queryParameters: queryParams,
      );
      
      final List<dynamic> messagesData = response['messages'] ?? [];
      return messagesData.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching messages for chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Send a text message
  Future<Message> sendTextMessage(
    String chatId,
    String content, {
    String? replyToId,
  }) async {
    try {
      final data = <String, dynamic>{
        'content': content,
        'type': 'text',
      };

      if (replyToId != null) {
        data['replyToId'] = replyToId;
      }

      final response = await _apiService.post('/chats/$chatId/messages', data);
      return Message.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending text message to chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Send a media message
  Future<Message> sendMediaMessage(
    String chatId,
    MessageType type,
    List<MessageAttachment> attachments, {
    String? content,
    String? replyToId,
  }) async {
    try {
      final data = <String, dynamic>{
        'type': type.toString().split('.').last,
        'attachments': attachments.map((a) => a.toJson()).toList(),
      };

      if (content != null && content.isNotEmpty) {
        data['content'] = content;
      }
      if (replyToId != null) {
        data['replyToId'] = replyToId;
      }

      final response = await _apiService.post('/chats/$chatId/messages', data);
      return Message.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending media message to chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Send an image message
  Future<Message> sendImageMessage(
    String chatId,
    String imageUrl, {
    String? caption,
    String? replyToId,
  }) async {
    final attachment = MessageAttachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AttachmentType.image,
      url: imageUrl,
    );

    return sendMediaMessage(
      chatId,
      MessageType.image,
      [attachment],
      content: caption,
      replyToId: replyToId,
    );
  }

  /// Send a video message
  Future<Message> sendVideoMessage(
    String chatId,
    String videoUrl, {
    String? caption,
    Duration? duration,
    String? replyToId,
  }) async {
    final attachment = MessageAttachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AttachmentType.video,
      url: videoUrl,
      duration: duration,
    );

    return sendMediaMessage(
      chatId,
      MessageType.video,
      [attachment],
      content: caption,
      replyToId: replyToId,
    );
  }

  /// Send an audio message
  Future<Message> sendAudioMessage(
    String chatId,
    String audioUrl, {
    Duration? duration,
    String? replyToId,
  }) async {
    final attachment = MessageAttachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AttachmentType.audio,
      url: audioUrl,
      duration: duration,
    );

    return sendMediaMessage(
      chatId,
      MessageType.audio,
      [attachment],
      replyToId: replyToId,
    );
  }

  /// Send a voice message
  Future<Message> sendVoiceMessage(
    String chatId,
    String audioUrl, {
    Duration? duration,
    String? replyToId,
  }) async {
    final attachment = MessageAttachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AttachmentType.voice,
      url: audioUrl,
      duration: duration,
    );

    return sendMediaMessage(
      chatId,
      MessageType.voice,
      [attachment],
      replyToId: replyToId,
    );
  }

  /// Send a file message
  Future<Message> sendFileMessage(
    String chatId,
    String fileUrl,
    String filename, {
    int? fileSize,
    String? replyToId,
  }) async {
    final attachment = MessageAttachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AttachmentType.file,
      url: fileUrl,
      filename: filename,
      size: fileSize,
    );

    return sendMediaMessage(
      chatId,
      MessageType.file,
      [attachment],
      replyToId: replyToId,
    );
  }

  /// Send a location message
  Future<Message> sendLocationMessage(
    String chatId,
    double latitude,
    double longitude, {
    String? locationName,
    String? replyToId,
  }) async {
    try {
      final data = <String, dynamic>{
        'type': 'location',
        'content': locationName ?? 'Location shared',
        'metadata': {
          'latitude': latitude,
          'longitude': longitude,
          'locationName': locationName,
        },
      };

      if (replyToId != null) {
        data['replyToId'] = replyToId;
      }

      final response = await _apiService.post('/chats/$chatId/messages', data);
      return Message.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending location message to chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Edit a message
  Future<Message> editMessage(
    String chatId,
    String messageId,
    String newContent,
  ) async {
    try {
      final response = await _apiService.put(
        '/chats/$chatId/messages/$messageId',
        {'content': newContent},
      );
      return Message.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error editing message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _apiService.delete('/chats/$chatId/messages/$messageId');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await _apiService.put('/chats/$chatId/messages/$messageId/read', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error marking message $messageId as read in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Mark all messages in chat as read
  Future<void> markAllMessagesAsRead(String chatId) async {
    try {
      await _apiService.put('/chats/$chatId/messages/read-all', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all messages as read in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// React to a message
  Future<void> reactToMessage(
    String chatId,
    String messageId,
    String reaction,
  ) async {
    try {
      await _apiService.post(
        '/chats/$chatId/messages/$messageId/reactions',
        {'reaction': reaction},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error reacting to message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Remove reaction from a message
  Future<void> removeReaction(String chatId, String messageId) async {
    try {
      await _apiService.delete('/chats/$chatId/messages/$messageId/reactions');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing reaction from message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Forward a message to another chat
  Future<void> forwardMessage(
    String sourceChatId,
    String messageId,
    String targetChatId,
  ) async {
    try {
      await _apiService.post(
        '/chats/$sourceChatId/messages/$messageId/forward',
        {'targetChatId': targetChatId},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error forwarding message $messageId from chat $sourceChatId to $targetChatId: $e');
      }
      rethrow;
    }
  }

  /// Search messages in a chat
  Future<List<Message>> searchMessages(
    String chatId,
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/chats/$chatId/messages/search',
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
      
      final List<dynamic> messagesData = response['messages'] ?? [];
      return messagesData.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching messages in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Get message by ID
  Future<Message> getMessage(String chatId, String messageId) async {
    try {
      final response = await _apiService.get('/chats/$chatId/messages/$messageId');
      return Message.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(String chatId, bool isTyping) async {
    try {
      await _apiService.post(
        '/chats/$chatId/typing',
        {'isTyping': isTyping},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending typing indicator to chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Get typing indicators for a chat
  Future<List<Map<String, dynamic>>> getTypingIndicators(String chatId) async {
    try {
      final response = await _apiService.get('/chats/$chatId/typing');
      final List<dynamic> typingData = response['typing'] ?? [];
      return typingData.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching typing indicators for chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Upload file for message attachment
  Future<MessageAttachment> uploadFile(
    String chatId,
    String filePath,
    AttachmentType type, {
    String? filename,
    int? fileSize,
    Duration? duration,
  }) async {
    try {
      // This would typically involve file upload logic
      // For now, we'll create a mock attachment
      final attachment = MessageAttachment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        url: 'https://example.com/uploaded-file', // Mock URL
        filename: filename,
        size: fileSize,
        duration: duration,
        isUploaded: true,
      );

      return attachment;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file for chat $chatId: $e');
      }
      rethrow;
    }
  }
}
