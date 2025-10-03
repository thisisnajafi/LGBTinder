import 'package:flutter/foundation.dart';
import '../models/api_models/chat_models.dart';
import '../models/api_models/auth_models.dart';
import '../services/api_services/chat_api_service.dart';
import '../services/token_management_service.dart';
import '../services/rate_limiting_service.dart';
import '../models/user_state_models.dart';

class ChatStateProvider extends ChangeNotifier {
  // State variables
  Map<int, List<MessageData>> _chatHistories = {}; // userId -> messages
  Map<int, bool> _isLoadingChat = {}; // userId -> loading state
  Map<int, bool> _isSendingMessage = {}; // userId -> sending state
  Map<int, AuthError?> _chatErrors = {}; // userId -> error
  Map<int, PaginationData> _paginationData = {}; // userId -> pagination info
  Map<int, bool> _hasMoreMessages = {}; // userId -> has more messages
  String? _lastSendError;
  int? _lastSentToUserId;

  // Getters
  Map<int, List<MessageData>> get chatHistories => _chatHistories;
  Map<int, bool> get isLoadingChat => _isLoadingChat;
  Map<int, bool> get isSendingMessage => _isSendingMessage;
  Map<int, AuthError?> get chatErrors => _chatErrors;
  Map<int, PaginationData> get paginationData => _paginationData;
  Map<int, bool> get hasMoreMessages => _hasMoreMessages;
  String? get lastSendError => _lastSendError;
  int? get lastSentToUserId => _lastSentToUserId;

  // Get messages for a specific user
  List<MessageData> getMessagesForUser(int userId) {
    return _chatHistories[userId] ?? [];
  }

  // Check if chat is loading for a specific user
  bool isChatLoading(int userId) {
    return _isLoadingChat[userId] ?? false;
  }

  // Check if message is being sent for a specific user
  bool isMessageSending(int userId) {
    return _isSendingMessage[userId] ?? false;
  }

  // Get error for a specific user's chat
  AuthError? getChatError(int userId) {
    return _chatErrors[userId];
  }

  // Get pagination data for a specific user's chat
  PaginationData? getPaginationData(int userId) {
    return _paginationData[userId];
  }

  // Check if there are more messages for a specific user
  bool hasMoreMessagesForUser(int userId) {
    return _hasMoreMessages[userId] ?? false;
  }

  // Load chat history for a user
  Future<void> loadChatHistory(int userId, {int page = 1, int limit = 20}) async {
    try {
      _setChatLoading(userId, true);
      _clearChatError(userId);

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      final chatHistoryData = await ChatApiService.getChatHistory(
        userId,
        token,
        page: page,
        limit: limit,
      );

      if (page == 1) {
        // First page - replace messages
        _chatHistories[userId] = chatHistoryData.messages;
      } else {
        // Subsequent pages - prepend older messages
        final existingMessages = _chatHistories[userId] ?? [];
        _chatHistories[userId] = [...chatHistoryData.messages, ...existingMessages];
      }

      _paginationData[userId] = chatHistoryData.pagination!;
      _hasMoreMessages[userId] = chatHistoryData.pagination?.hasPrev ?? false;

      notifyListeners();
    } catch (e) {
      _handleChatError(userId, e);
    } finally {
      _setChatLoading(userId, false);
    }
  }

  // Send a message
  Future<bool> sendMessage(int receiverId, String message, {String messageType = 'text'}) async {
    try {
      _setMessageSending(receiverId, true);
      _clearChatError(receiverId);
      _lastSendError = null;
      _lastSentToUserId = receiverId;

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      // Check rate limiting
      await RateLimitingService.checkRateLimit('default');

      final request = SendMessageRequest(
        receiverId: receiverId,
        message: message,
        messageType: MessageType.values.firstWhere(
          (type) => type.value == messageType,
          orElse: () => MessageType.text,
        ),
      );

      final response = await ChatApiService.sendMessage(request, token);

      if (response.status) {
        // Add the message to the local chat history
        final newMessage = MessageData(
          messageId: response.data?.messageId ?? 0,
          senderId: response.data?.senderId ?? 0,
          receiverId: receiverId,
          message: message,
          messageType: MessageType.text,
          sentAt: DateTime.now().toIso8601String(),
          isRead: false,
        );

        final existingMessages = _chatHistories[receiverId] ?? [];
        _chatHistories[receiverId] = [...existingMessages, newMessage];

        notifyListeners();
        return true;
      } else {
        _lastSendError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is RateLimitExceededException) {
        _lastSendError = e.message;
      } else {
        _handleChatError(receiverId, e);
      }
      notifyListeners();
      return false;
    } finally {
      _setMessageSending(receiverId, false);
    }
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages(int userId) async {
    final pagination = _paginationData[userId];
    if (pagination != null && pagination.hasPrev) {
      await loadChatHistory(userId, page: pagination.currentPage - 1);
    }
  }

  // Refresh chat for a user
  Future<void> refreshChat(int userId) async {
    await loadChatHistory(userId, page: 1);
  }

  // Add a received message (for real-time updates)
  void addReceivedMessage(int senderId, MessageData message) {
    final existingMessages = _chatHistories[senderId] ?? [];
    _chatHistories[senderId] = [...existingMessages, message];
    notifyListeners();
  }

  // Mark messages as read
  void markMessagesAsRead(int userId) {
    final messages = _chatHistories[userId];
    if (messages != null) {
      for (var message in messages) {
        if (message.receiverId == userId && !message.isRead) {
          // This would typically be handled by the API
          // For now, we'll just update the local state
        }
      }
      notifyListeners();
    }
  }

  // Clear chat data for a specific user
  void clearChatData(int userId) {
    _chatHistories.remove(userId);
    _isLoadingChat.remove(userId);
    _isSendingMessage.remove(userId);
    _chatErrors.remove(userId);
    _paginationData.remove(userId);
    _hasMoreMessages.remove(userId);
    notifyListeners();
  }

  // Clear all chat data
  void clearAllChatData() {
    _chatHistories.clear();
    _isLoadingChat.clear();
    _isSendingMessage.clear();
    _chatErrors.clear();
    _paginationData.clear();
    _hasMoreMessages.clear();
    _lastSendError = null;
    _lastSentToUserId = null;
    notifyListeners();
  }

  // Private helper methods
  void _setChatLoading(int userId, bool loading) {
    _isLoadingChat[userId] = loading;
    notifyListeners();
  }

  void _setMessageSending(int userId, bool sending) {
    _isSendingMessage[userId] = sending;
    notifyListeners();
  }

  void _clearChatError(int userId) {
    _chatErrors[userId] = null;
    notifyListeners();
  }

  void _handleChatError(int userId, dynamic error) {
    if (error is AuthError) {
      _chatErrors[userId] = error;
    } else if (error is RateLimitExceededException) {
      _chatErrors[userId] = AuthError(
        type: AuthErrorType.networkError,
        message: error.message,
        details: {'retry_after': error.retryAfter, 'message': 'Rate limit exceeded'},
      );
    } else {
      _chatErrors[userId] = AuthError(
        type: AuthErrorType.unknownError,
        message: 'An unexpected error occurred',
        details: {'error': error.toString()},
      );
    }
    notifyListeners();
  }

  // Dispose method
  @override
  void dispose() {
    super.dispose();
  }
}
