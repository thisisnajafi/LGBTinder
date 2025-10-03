import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/api_models/chat_models.dart';

/// Chat & Messaging API Service
/// 
/// This service handles all chat and messaging API calls including:
/// - Sending messages
/// - Getting chat history
/// - Message management
class ChatApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // MESSAGING
  // ============================================================================

  /// Send a message to a matched user
  /// 
  /// [request] - Send message request data
  /// [token] - Full access token for authentication
  /// Returns [SendMessageResponse] with message result
  static Future<SendMessageResponse> sendMessage(SendMessageRequest request, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return SendMessageResponse.fromJson(responseData);
      } else {
        // Handle error response
        return SendMessageResponse.fromJson(responseData);
      }
    } catch (e) {
      // Handle network or parsing errors
      return SendMessageResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Send message with error handling
  /// 
  /// [receiverId] - ID of the user to send message to
  /// [message] - Message content
  /// [messageType] - Type of message (text, image, video, etc.)
  /// [token] - Full access token for authentication
  /// Returns [Map<String, dynamic>] with result and error information
  static Future<Map<String, dynamic>> sendMessageWithErrorHandling(
    int receiverId,
    String message,
    MessageType messageType,
    String token,
  ) async {
    try {
      final request = SendMessageRequest(
        receiverId: receiverId,
        message: message,
        messageType: messageType,
      );
      final response = await sendMessage(request, token);

      if (response.status) {
        return {
          'success': true,
          'data': response.data,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'error': response.message,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // CHAT HISTORY
  // ============================================================================

  /// Get chat history with a specific user
  /// 
  /// [userId] - ID of the user to get chat history with
  /// [token] - Full access token for authentication
  /// [page] - Page number for pagination (optional)
  /// [limit] - Number of messages per page (optional)
  /// Returns [GetChatHistoryResponse] with chat history
  static Future<GetChatHistoryResponse> getChatHistory(
    int userId,
    String token, {
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId.toString(),
      };

      if (page != null) {
        queryParams['page'] = page.toString();
      }

      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      final uri = Uri.parse('$_baseUrl/chat/history').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return GetChatHistoryResponse.fromJson(responseData);
      } else {
        // Handle error response
        return GetChatHistoryResponse(
          status: false,
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return GetChatHistoryResponse(
        status: false,
      );
    }
  }

  /// Get chat history with error handling
  /// 
  /// [userId] - ID of the user to get chat history with
  /// [token] - Full access token for authentication
  /// [page] - Page number for pagination (optional)
  /// [limit] - Number of messages per page (optional)
  /// Returns [Map<String, dynamic>] with result and error information
  static Future<Map<String, dynamic>> getChatHistoryWithErrorHandling(
    int userId,
    String token, {
    int? page,
    int? limit,
  }) async {
    try {
      final response = await getChatHistory(userId, token, page: page, limit: limit);

      if (response.status) {
        return {
          'success': true,
          'data': response.data,
          'error': null,
        };
      } else {
        return {
          'success': false,
          'data': null,
          'error': 'Failed to fetch chat history',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  // ============================================================================
  // CHAT UTILITIES
  // ============================================================================

  /// Check if user can send message
  /// 
  /// [currentUserId] - ID of the current user
  /// [receiverId] - ID of the user to send message to
  /// Returns [bool] indicating if user can send message
  static bool canSendMessage(int currentUserId, int receiverId) {
    return currentUserId != receiverId;
  }

  /// Validate message content
  /// 
  /// [message] - Message content to validate
  /// Returns [bool] indicating if message is valid
  static bool isValidMessage(String message) {
    return message.trim().isNotEmpty;
  }

  /// Get message character count
  /// 
  /// [message] - Message content
  /// Returns [int] with character count
  static int getMessageCharacterCount(String message) {
    return message.length;
  }

  /// Check if message is too long
  /// 
  /// [message] - Message content
  /// [maxLength] - Maximum allowed length
  /// Returns [bool] indicating if message is too long
  static bool isMessageTooLong(String message, {int maxLength = 1000}) {
    return message.length > maxLength;
  }

  /// Get unread message count from chat history
  /// 
  /// [messages] - List of messages
  /// [currentUserId] - ID of the current user
  /// Returns [int] with unread message count
  static int getUnreadMessageCount(List<MessageData> messages, int currentUserId) {
    return ChatHelper.getUnreadMessageCount(messages, currentUserId);
  }

  /// Get last message from chat history
  /// 
  /// [messages] - List of messages
  /// Returns [MessageData?] with last message
  static MessageData? getLastMessage(List<MessageData> messages) {
    return ChatHelper.getLastMessage(messages);
  }

  /// Get last message text from chat history
  /// 
  /// [messages] - List of messages
  /// Returns [String] with last message text
  static String getLastMessageText(List<MessageData> messages) {
    return ChatHelper.getLastMessageText(messages);
  }

  /// Get last message time from chat history
  /// 
  /// [messages] - List of messages
  /// Returns [String] with last message time
  static String getLastMessageTime(List<MessageData> messages) {
    return ChatHelper.getLastMessageTime(messages);
  }

  /// Sort messages by time
  /// 
  /// [messages] - List of messages
  /// Returns [List<MessageData>] with sorted messages
  static List<MessageData> sortMessagesByTime(List<MessageData> messages) {
    return ChatHelper.sortMessagesByTime(messages);
  }

  /// Sort messages by time (newest first)
  /// 
  /// [messages] - List of messages
  /// Returns [List<MessageData>] with sorted messages
  static List<MessageData> sortMessagesByTimeDesc(List<MessageData> messages) {
    return ChatHelper.sortMessagesByTimeDesc(messages);
  }

  /// Get conversation between two users
  /// 
  /// [messages] - List of messages
  /// [userId1] - First user ID
  /// [userId2] - Second user ID
  /// Returns [List<MessageData>] with conversation messages
  static List<MessageData> getConversation(List<MessageData> messages, int userId1, int userId2) {
    return ChatHelper.getConversation(messages, userId1, userId2);
  }

  /// Get messages from specific user
  /// 
  /// [messages] - List of messages
  /// [userId] - User ID
  /// Returns [List<MessageData>] with messages from user
  static List<MessageData> getMessagesFromUser(List<MessageData> messages, int userId) {
    return ChatHelper.getMessagesFromUser(messages, userId);
  }

  /// Get messages to specific user
  /// 
  /// [messages] - List of messages
  /// [userId] - User ID
  /// Returns [List<MessageData>] with messages to user
  static List<MessageData> getMessagesToUser(List<MessageData> messages, int userId) {
    return ChatHelper.getMessagesToUser(messages, userId);
  }

  /// Check if message is from current user
  /// 
  /// [message] - Message data
  /// [currentUserId] - Current user ID
  /// Returns [bool] indicating if message is from current user
  static bool isFromCurrentUser(MessageData message, int currentUserId) {
    return ChatHelper.isFromCurrentUser(message, currentUserId);
  }

  /// Check if message is to current user
  /// 
  /// [message] - Message data
  /// [currentUserId] - Current user ID
  /// Returns [bool] indicating if message is to current user
  static bool isToCurrentUser(MessageData message, int currentUserId) {
    return ChatHelper.isToCurrentUser(message, currentUserId);
  }

  /// Format message time
  /// 
  /// [message] - Message data
  /// Returns [String] with formatted time
  static String formatMessageTime(MessageData message) {
    return ChatHelper.formatMessageTime(message);
  }

  /// Format message time for display
  /// 
  /// [message] - Message data
  /// Returns [String] with formatted time for display
  static String formatMessageTimeForDisplay(MessageData message) {
    return ChatHelper.formatMessageTimeForDisplay(message);
  }

  /// Get message preview
  /// 
  /// [message] - Message data
  /// Returns [String] with message preview
  static String getMessagePreview(MessageData message) {
    return ChatHelper.getMessagePreview(message);
  }

  /// Check if message is text
  /// 
  /// [message] - Message data
  /// Returns [bool] indicating if message is text
  static bool isTextMessage(MessageData message) {
    return ChatHelper.isTextMessage(message);
  }

  /// Check if message is media
  /// 
  /// [message] - Message data
  /// Returns [bool] indicating if message is media
  static bool isMediaMessage(MessageData message) {
    return ChatHelper.isMediaMessage(message);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if response indicates success
  static bool isSuccessResponse(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if response indicates client error
  static bool isClientErrorResponse(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Check if response indicates server error
  static bool isServerErrorResponse(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  /// Get error message from response
  static String getErrorMessage(Map<String, dynamic> responseData) {
    if (responseData.containsKey('message')) {
      return responseData['message'] as String;
    }
    return 'Unknown error occurred';
  }

  /// Check if user is authenticated
  static bool isAuthenticated(String? token) {
    return token != null && token.isNotEmpty;
  }

  /// Validate token format
  static bool isValidTokenFormat(String token) {
    // Basic token validation - should be non-empty and contain typical JWT structure
    return token.isNotEmpty && token.contains('.');
  }

  /// Validate user ID
  static bool isValidUserId(int userId) {
    return userId > 0;
  }

  /// Validate receiver ID
  static bool isValidReceiverId(int receiverId) {
    return receiverId > 0;
  }

  /// Validate page number
  static bool isValidPageNumber(int? page) {
    return page == null || page > 0;
  }

  /// Validate limit
  static bool isValidLimit(int? limit) {
    return limit == null || (limit > 0 && limit <= 100);
  }
}
