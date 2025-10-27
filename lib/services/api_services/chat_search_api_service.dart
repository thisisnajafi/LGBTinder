import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

/// Chat Search API Service
/// 
/// Handles message search functionality:
/// - Search within a specific chat
/// - Search across all chats
/// - Highlight search terms
class ChatSearchApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Search messages in a specific chat
  /// 
  /// [chatId] - ID of the chat to search in
  /// [query] - Search query string
  /// [token] - Authentication token
  /// [page] - Page number for pagination
  /// [limit] - Number of results per page
  /// Returns [SearchMessagesResponse] with matching messages
  static Future<SearchMessagesResponse> searchInChat({
    required String chatId,
    required String query,
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('Searching messages in chat $chatId: $query');

      final uri = Uri.parse('$_baseUrl/chat/$chatId/search').replace(
        queryParameters: {
          'query': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        debugPrint('Found ${responseData['data']?.length ?? 0} messages');
        
        return SearchMessagesResponse(
          success: true,
          messages: (responseData['data'] as List?)
                  ?.map((json) => SearchMessageResult.fromJson(json as Map<String, dynamic>))
                  .toList() ??
              [],
          totalCount: responseData['total_count'] as int?,
          currentPage: page,
          hasMore: responseData['has_more'] as bool? ?? false,
        );
      } else {
        return SearchMessagesResponse(
          success: false,
          messages: [],
          error: responseData['message'] as String? ?? 'Search failed',
        );
      }
    } catch (e) {
      debugPrint('Error searching messages: $e');
      return SearchMessagesResponse(
        success: false,
        messages: [],
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Search messages across all chats
  /// 
  /// [query] - Search query string
  /// [token] - Authentication token
  /// [page] - Page number for pagination
  /// [limit] - Number of results per page
  /// Returns [SearchMessagesResponse] with matching messages
  static Future<SearchMessagesResponse> searchAllChats({
    required String query,
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('Searching all chats: $query');

      final uri = Uri.parse('$_baseUrl/chat/search').replace(
        queryParameters: {
          'query': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        debugPrint('Found ${responseData['data']?.length ?? 0} messages');
        
        return SearchMessagesResponse(
          success: true,
          messages: (responseData['data'] as List?)
                  ?.map((json) => SearchMessageResult.fromJson(json as Map<String, dynamic>))
                  .toList() ??
              [],
          totalCount: responseData['total_count'] as int?,
          currentPage: page,
          hasMore: responseData['has_more'] as bool? ?? false,
        );
      } else {
        return SearchMessagesResponse(
          success: false,
          messages: [],
          error: responseData['message'] as String? ?? 'Search failed',
        );
      }
    } catch (e) {
      debugPrint('Error searching messages: $e');
      return SearchMessagesResponse(
        success: false,
        messages: [],
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get recent search queries
  /// 
  /// [token] - Authentication token
  /// Returns list of recent search queries
  static Future<List<String>> getRecentSearches({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/search/recent'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return (responseData['data'] as List?)
                ?.map((item) => item.toString())
                .toList() ??
            [];
      }

      return [];
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      return [];
    }
  }

  /// Clear search history
  /// 
  /// [token] - Authentication token
  static Future<bool> clearSearchHistory({
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/search/history'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error clearing search history: $e');
      return false;
    }
  }
}

/// Search Messages Response
class SearchMessagesResponse {
  final bool success;
  final List<SearchMessageResult> messages;
  final int? totalCount;
  final int? currentPage;
  final bool? hasMore;
  final String? error;

  SearchMessagesResponse({
    required this.success,
    required this.messages,
    this.totalCount,
    this.currentPage,
    this.hasMore,
    this.error,
  });
}

/// Search Message Result
class SearchMessageResult {
  final String messageId;
  final String chatId;
  final String chatName;
  final String? chatAvatar;
  final String content;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final DateTime timestamp;
  final List<SearchHighlight>? highlights;

  SearchMessageResult({
    required this.messageId,
    required this.chatId,
    required this.chatName,
    this.chatAvatar,
    required this.content,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.timestamp,
    this.highlights,
  });

  factory SearchMessageResult.fromJson(Map<String, dynamic> json) {
    return SearchMessageResult(
      messageId: json['message_id'].toString(),
      chatId: json['chat_id'].toString(),
      chatName: json['chat_name'] as String? ?? 'Unknown Chat',
      chatAvatar: json['chat_avatar'] as String?,
      content: json['content'] as String? ?? '',
      senderId: json['sender_id'].toString(),
      senderName: json['sender_name'] as String? ?? 'Unknown',
      senderAvatar: json['sender_avatar'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      highlights: (json['highlights'] as List?)
          ?.map((h) => SearchHighlight.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Search Highlight
class SearchHighlight {
  final int start;
  final int end;
  final String text;

  SearchHighlight({
    required this.start,
    required this.end,
    required this.text,
  });

  factory SearchHighlight.fromJson(Map<String, dynamic> json) {
    return SearchHighlight(
      start: json['start'] as int,
      end: json['end'] as int,
      text: json['text'] as String,
    );
  }
}

