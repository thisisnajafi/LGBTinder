import 'api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  // Get all conversations
  Future<Map<String, dynamic>> getConversations({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _apiService.getData('/conversations', queryParameters: queryParams);
  }

  // Get conversation by ID
  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    return await _apiService.getData('/conversations/$conversationId');
  }

  // Get messages for a conversation
  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int? page,
    int? limit,
    String? beforeMessageId,
  }) async {
    final queryParams = <String, String>{};
    
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (beforeMessageId != null) queryParams['before'] = beforeMessageId;

    return await _apiService.getData(
      '/conversations/$conversationId/messages',
      queryParameters: queryParams,
    );
  }

  // Send a message
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String message, {
    String? messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final data = <String, dynamic>{
      'message': message,
      'type': messageType,
    };

    if (metadata != null) {
      data['metadata'] = metadata;
    }

    return await _apiService.postData(
      '/conversations/$conversationId/messages',
      data,
    );
  }

  // Send image message
  Future<Map<String, dynamic>> sendImageMessage(
    String conversationId,
    String imageUrl, {
    String? caption,
  }) async {
    final data = {
      'message': imageUrl,
      'type': 'image',
    };

    if (caption != null) {
      data['caption'] = caption;
    }

    return await _apiService.postData(
      '/conversations/$conversationId/messages',
      data,
    );
  }

  // Delete a message
  Future<Map<String, dynamic>> deleteMessage(
    String conversationId,
    String messageId,
  ) async {
    return await _apiService.deleteData(
      '/conversations/$conversationId/messages/$messageId',
    );
  }

  // Mark conversation as read
  Future<Map<String, dynamic>> markConversationAsRead(String conversationId) async {
    return await _apiService.updateData(
      '/conversations/$conversationId/read',
      {},
    );
  }

  // Mark message as read
  Future<Map<String, dynamic>> markMessageAsRead(
    String conversationId,
    String messageId,
  ) async {
    return await _apiService.updateData(
      '/conversations/$conversationId/messages/$messageId/read',
      {},
    );
  }

  // Get unread message count
  Future<Map<String, dynamic>> getUnreadCount() async {
    return await _apiService.getData('/conversations/unread-count');
  }

  // Delete conversation
  Future<Map<String, dynamic>> deleteConversation(String conversationId) async {
    return await _apiService.deleteData('/conversations/$conversationId');
  }

  // Block user in conversation
  Future<Map<String, dynamic>> blockUserInConversation(String conversationId) async {
    return await _apiService.postData(
      '/conversations/$conversationId/block',
      {},
    );
  }

  // Unblock user in conversation
  Future<Map<String, dynamic>> unblockUserInConversation(String conversationId) async {
    return await _apiService.deleteData('/conversations/$conversationId/block');
  }

  // Report conversation
  Future<Map<String, dynamic>> reportConversation(
    String conversationId,
    String reason,
  ) async {
    return await _apiService.postData(
      '/conversations/$conversationId/report',
      {'reason': reason},
    );
  }

  // Get conversation with user
  Future<Map<String, dynamic>> getConversationWithUser(String userId) async {
    return await _apiService.getData('/conversations/with/$userId');
  }

  // Create conversation with user
  Future<Map<String, dynamic>> createConversation(String userId) async {
    return await _apiService.postData('/conversations', {
      'user_id': userId,
    });
  }

  // Get typing status
  Future<Map<String, dynamic>> getTypingStatus(String conversationId) async {
    return await _apiService.getData('/conversations/$conversationId/typing');
  }

  // Send typing indicator
  Future<Map<String, dynamic>> sendTypingIndicator(
    String conversationId,
    bool isTyping,
  ) async {
    return await _apiService.postData(
      '/conversations/$conversationId/typing',
      {'is_typing': isTyping},
    );
  }

  // Get message by ID
  Future<Map<String, dynamic>> getMessage(
    String conversationId,
    String messageId,
  ) async {
    return await _apiService.getData(
      '/conversations/$conversationId/messages/$messageId',
    );
  }

  // Edit message
  Future<Map<String, dynamic>> editMessage(
    String conversationId,
    String messageId,
    String newMessage,
  ) async {
    return await _apiService.updateData(
      '/conversations/$conversationId/messages/$messageId',
      {'message': newMessage},
    );
  }

  // React to message
  Future<Map<String, dynamic>> reactToMessage(
    String conversationId,
    String messageId,
    String reaction,
  ) async {
    return await _apiService.postData(
      '/conversations/$conversationId/messages/$messageId/reactions',
      {'reaction': reaction},
    );
  }

  // Remove reaction from message
  Future<Map<String, dynamic>> removeReaction(
    String conversationId,
    String messageId,
  ) async {
    return await _apiService.deleteData(
      '/conversations/$conversationId/messages/$messageId/reactions',
    );
  }
} 