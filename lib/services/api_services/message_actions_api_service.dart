import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

/// Message Actions API Service
/// 
/// Handles message actions: pin, edit, delete, forward
class MessageActionsApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Pin message
  static Future<MessageActionResponse> pinMessage({
    required String token,
    required String messageId,
    required String chatId,
  }) async {
    try {
      debugPrint('Pinning message: $messageId in chat: $chatId');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/messages/$messageId/pin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chat_id': chatId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return MessageActionResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return MessageActionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error pinning message: $e');
      return MessageActionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Unpin message
  static Future<MessageActionResponse> unpinMessage({
    required String token,
    required String messageId,
    required String chatId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/messages/$messageId/pin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chat_id': chatId,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return MessageActionResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return MessageActionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error unpinning message: $e');
      return MessageActionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get pinned messages
  static Future<PinnedMessagesResponse> getPinnedMessages({
    required String token,
    required String chatId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/$chatId/pinned'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        final messages = (data['data'] as List?)
                ?.map((m) => PinnedMessage.fromJson(m as Map<String, dynamic>))
                .toList() ??
            [];

        return PinnedMessagesResponse(
          success: true,
          messages: messages,
        );
      }

      return PinnedMessagesResponse(
        success: false,
        messages: [],
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error getting pinned messages: $e');
      return PinnedMessagesResponse(
        success: false,
        messages: [],
        error: e.toString(),
      );
    }
  }

  /// Edit message
  static Future<MessageActionResponse> editMessage({
    required String token,
    required String messageId,
    required String newContent,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/chat/messages/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'content': newContent,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return MessageActionResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return MessageActionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error editing message: $e');
      return MessageActionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Delete message
  static Future<MessageActionResponse> deleteMessage({
    required String token,
    required String messageId,
    required bool deleteForEveryone,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/messages/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'delete_for_everyone': deleteForEveryone,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return MessageActionResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return MessageActionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error deleting message: $e');
      return MessageActionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Forward message
  static Future<MessageActionResponse> forwardMessage({
    required String token,
    required String messageId,
    required List<String> chatIds,
    String? comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/messages/$messageId/forward'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chat_ids': chatIds,
          'comment': comment,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return MessageActionResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return MessageActionResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error forwarding message: $e');
      return MessageActionResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// Message Action Response
class MessageActionResponse {
  final bool success;
  final String? message;
  final String? error;

  MessageActionResponse({
    required this.success,
    this.message,
    this.error,
  });
}

/// Pinned Messages Response
class PinnedMessagesResponse {
  final bool success;
  final List<PinnedMessage> messages;
  final String? error;

  PinnedMessagesResponse({
    required this.success,
    required this.messages,
    this.error,
  });
}

/// Pinned Message Model
class PinnedMessage {
  final String messageId;
  final String content;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final DateTime sentAt;
  final DateTime pinnedAt;
  final String pinnedBy;

  PinnedMessage({
    required this.messageId,
    required this.content,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.sentAt,
    required this.pinnedAt,
    required this.pinnedBy,
  });

  factory PinnedMessage.fromJson(Map<String, dynamic> json) {
    return PinnedMessage(
      messageId: json['message_id'].toString(),
      content: json['content'] as String,
      senderId: json['sender_id'].toString(),
      senderName: json['sender_name'] as String,
      senderAvatar: json['sender_avatar'] as String?,
      sentAt: DateTime.parse(json['sent_at'] as String),
      pinnedAt: DateTime.parse(json['pinned_at'] as String),
      pinnedBy: json['pinned_by'].toString(),
    );
  }
}

