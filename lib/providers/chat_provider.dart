import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/chat_service.dart';
import '../services/message_service.dart';
import '../services/calls_service.dart';

class ChatProvider extends ChangeNotifier {

  // Chat state
  List<Chat> _chats = [];
  Chat? _currentChat;
  bool _isLoadingChats = false;
  String? _chatError;

  // Message state
  Map<String, List<Message>> _messages = {};
  Map<String, bool> _isLoadingMessages = {};
  Map<String, String?> _messageErrors = {};
  Map<String, bool> _hasMoreMessages = {};

  // Call state
  List<Call> _activeCalls = [];
  Call? _currentCall;
  bool _isLoadingCalls = false;
  String? _callError;

  // Real-time state
  Map<String, List<Map<String, dynamic>>> _typingIndicators = {};
  Map<String, int> _unreadCounts = {};

  ChatProvider();

  // Getters
  List<Chat> get chats => _chats;
  Chat? get currentChat => _currentChat;
  bool get isLoadingChats => _isLoadingChats;
  String? get chatError => _chatError;

  List<Message> getMessages(String chatId) => _messages[chatId] ?? [];
  bool isLoadingMessages(String chatId) => _isLoadingMessages[chatId] ?? false;
  String? getMessageError(String chatId) => _messageErrors[chatId];
  bool hasMoreMessages(String chatId) => _hasMoreMessages[chatId] ?? false;

  List<Call> get activeCalls => _activeCalls;
  Call? get currentCall => _currentCall;
  bool get isLoadingCalls => _isLoadingCalls;
  String? get callError => _callError;

  List<Map<String, dynamic>> getTypingIndicators(String chatId) => 
      _typingIndicators[chatId] ?? [];
  int getUnreadCount(String chatId) => _unreadCounts[chatId] ?? 0;
  int get totalUnreadCount => _unreadCounts.values.fold(0, (sum, count) => sum + count);

  // Chat operations
  Future<void> loadChats({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    bool? isArchived,
    bool? isPinned,
    bool refresh = false,
  }) async {
    try {
      _isLoadingChats = true;
      _chatError = null;
      notifyListeners();

      final newChats = await ChatService.getChats(
        page: page,
        limit: limit,
      );

      if (refresh || page == 1) {
        _chats = newChats;
      } else {
        _chats.addAll(newChats);
      }

      // Update unread counts
      for (final chat in _chats) {
        _unreadCounts[chat.id] = chat.unreadCount;
      }

      _isLoadingChats = false;
      notifyListeners();
    } catch (e) {
      _isLoadingChats = false;
      _chatError = e.toString();
      if (kDebugMode) {
        print('Error loading chats: $e');
      }
      notifyListeners();
    }
  }

  Future<void> loadChat(String chatId) async {
    try {
      final chat = await ChatService.getChat(chatId);
      _currentChat = chat;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading chat $chatId: $e');
      }
    }
  }

  Future<void> createChat(String userId) async {
    try {
      final newChat = await ChatService.createChat(userId);
      _chats.insert(0, newChat);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating chat with user $userId: $e');
      }
      rethrow;
    }
  }

  Future<void> createGroupChat({
    required String name,
    required List<String> userIds,
    String? avatar,
  }) async {
    try {
      final newChat = await ChatService.createGroupChat(
        name: name,
        userIds: userIds,
      );
      _chats.insert(0, newChat);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating group chat: $e');
      }
      rethrow;
    }
  }

  Future<void> updateChat(String chatId, Map<String, dynamic> updates) async {
    try {
      final updatedChat = await ChatService.updateChat(chatId, updates);
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        _chats[index] = updatedChat;
        if (_currentChat?.id == chatId) {
          _currentChat = updatedChat;
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> archiveChat(String chatId) async {
    try {
      await ChatService.archiveChat(chatId);
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        _chats[index] = _chats[index].copyWith(isArchived: true);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error archiving chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> unarchiveChat(String chatId) async {
    try {
      await ChatService.unarchiveChat(chatId);
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        _chats[index] = _chats[index].copyWith(isArchived: false);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unarchiving chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> pinChat(String chatId) async {
    try {
      await ChatService.pinChat(chatId);
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        _chats[index] = _chats[index].copyWith(isPinned: true);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error pinning chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> unpinChat(String chatId) async {
    try {
      await ChatService.unpinChat(chatId);
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        _chats[index] = _chats[index].copyWith(isPinned: false);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unpinning chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await ChatService.deleteChat(chatId);
      _chats.removeWhere((chat) => chat.id == chatId);
      _messages.remove(chatId);
      _unreadCounts.remove(chatId);
      if (_currentChat?.id == chatId) {
        _currentChat = null;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    try {
      await ChatService.markChatAsRead(chatId);
      _unreadCounts[chatId] = 0;
      
      // Update chat in list
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        _chats[index] = _chats[index].copyWith(unreadCount: 0);
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking chat $chatId as read: $e');
      }
    }
  }

  // Message operations
  Future<void> loadMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
    String? beforeMessageId,
    String? afterMessageId,
    bool refresh = false,
  }) async {
    try {
      _isLoadingMessages[chatId] = true;
      _messageErrors[chatId] = null;
      notifyListeners();

      final newMessages = await ChatService.getMessages(
        chatId,
        page: page,
        limit: limit,
        beforeMessageId: beforeMessageId,
        afterMessageId: afterMessageId,
      );

      if (refresh || page == 1) {
        _messages[chatId] = newMessages;
      } else {
        final existingMessages = _messages[chatId] ?? [];
        existingMessages.addAll(newMessages);
        _messages[chatId] = existingMessages;
      }

      _hasMoreMessages[chatId] = newMessages.length == limit;
      _isLoadingMessages[chatId] = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMessages[chatId] = false;
      _messageErrors[chatId] = e.toString();
      if (kDebugMode) {
        print('Error loading messages for chat $chatId: $e');
      }
      notifyListeners();
    }
  }

  Future<Message> sendTextMessage(String chatId, String content, {String? replyToId}) async {
    try {
      final message = await ChatService.sendTextMessage(
        chatId,
        content,
        replyToId: replyToId,
      );

      // Add message to local state
      final messages = _messages[chatId] ?? [];
      messages.add(message);
      _messages[chatId] = messages;

      // Update chat's last message
      final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        _chats[chatIndex] = _chats[chatIndex].copyWith(
          lastMessage: message,
          lastActivity: DateTime.now(),
        );
      }

      notifyListeners();
      return message;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending text message to chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<Message> sendMediaMessage(
    String chatId,
    MessageType type,
    List<MessageAttachment> attachments, {
    String? content,
    String? replyToId,
  }) async {
    try {
      final message = await ChatService.sendMediaMessage(
        chatId,
        type.toString().split('.').last, // Convert enum to string
        attachments.map((attachment) => File(attachment.url ?? '')).toList(),
        content: content,
        replyToId: replyToId,
      );

      // Add message to local state
      final messages = _messages[chatId] ?? [];
      messages.add(message);
      _messages[chatId] = messages;

      // Update chat's last message
      final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        _chats[chatIndex] = _chats[chatIndex].copyWith(
          lastMessage: message,
          lastActivity: DateTime.now(),
        );
      }

      notifyListeners();
      return message;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending media message to chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> editMessage(String chatId, String messageId, String newContent) async {
    try {
      final updatedMessage = await ChatService.editMessage(
        chatId,
        messageId,
        newContent,
      );

      // Update message in local state
      final messages = _messages[chatId] ?? [];
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        messages[messageIndex] = updatedMessage;
        _messages[chatId] = messages;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error editing message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await ChatService.deleteMessage(messageId);

      // Remove message from local state
      final messages = _messages[chatId] ?? [];
      messages.removeWhere((msg) => msg.id == messageId);
      _messages[chatId] = messages;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> markMessageAsRead(String chatId, String messageId) async {
    try {
      await ChatService.markMessageAsRead(chatId, messageId);
      
      // Update message status in local state
      final messages = _messages[chatId] ?? [];
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        messages[messageIndex] = messages[messageIndex].copyWith(
          status: MessageStatus.read,
        );
        _messages[chatId] = messages;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking message $messageId as read in chat $chatId: $e');
      }
    }
  }

  Future<void> markAllMessagesAsRead(String chatId) async {
    try {
      await ChatService.markAllMessagesAsRead(chatId);
      
      // Update all messages status in local state
      final messages = _messages[chatId] ?? [];
      for (int i = 0; i < messages.length; i++) {
        messages[i] = messages[i].copyWith(status: MessageStatus.read);
      }
      _messages[chatId] = messages;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all messages as read in chat $chatId: $e');
      }
    }
  }

  Future<void> reactToMessage(String chatId, String messageId, String reaction) async {
    try {
      await ChatService.reactToMessage(chatId, messageId, reaction);
      
      // Update message reactions in local state
      final messages = _messages[chatId] ?? [];
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        final currentReactions = List<String>.from(messages[messageIndex].reactions);
        if (!currentReactions.contains(reaction)) {
          currentReactions.add(reaction);
          messages[messageIndex] = messages[messageIndex].copyWith(
            reactions: currentReactions,
          );
          _messages[chatId] = messages;
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reacting to message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  Future<void> removeReaction(String chatId, String messageId) async {
    try {
      await ChatService.removeReaction(chatId, messageId);
      
      // Clear message reactions in local state
      final messages = _messages[chatId] ?? [];
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        messages[messageIndex] = messages[messageIndex].copyWith(
          reactions: [],
        );
        _messages[chatId] = messages;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing reaction from message $messageId in chat $chatId: $e');
      }
      rethrow;
    }
  }

  // Call operations
  Future<void> loadActiveCalls() async {
    try {
      _isLoadingCalls = true;
      _callError = null;
      notifyListeners();

      final callMaps = await CallsService.getActiveCalls();
      _activeCalls = callMaps.map((callMap) => Call.fromJson(callMap)).toList();
      _isLoadingCalls = false;
      notifyListeners();
    } catch (e) {
      _isLoadingCalls = false;
      _callError = e.toString();
      if (kDebugMode) {
        print('Error loading active calls: $e');
      }
      notifyListeners();
    }
  }

  Future<Call> initiateCall(String receiverId, CallType type) async {
    try {
      final callMap = await CallsService.initiateCall(
        recipientId: receiverId,
        callType: type.toString().split('.').last, // Convert CallType enum to string
      );
      final call = Call.fromJson(callMap);
      _currentCall = call;
      _activeCalls.add(call);
      notifyListeners();
      return call;
    } catch (e) {
      if (kDebugMode) {
        print('Error initiating call to $receiverId: $e');
      }
      rethrow;
    }
  }

  Future<Call> acceptCall(String callId) async {
    try {
      final callMap = await CallsService.acceptCall(callId);
      final call = Call.fromJson(callMap);
      _currentCall = call;
      
      // Update call in active calls list
      final index = _activeCalls.indexWhere((c) => c.id == callId);
      if (index != -1) {
        _activeCalls[index] = call;
      }
      
      notifyListeners();
      return call;
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting call $callId: $e');
      }
      rethrow;
    }
  }

  Future<Call> rejectCall(String callId, {String? reason}) async {
    try {
      final callMap = await CallsService.rejectCall(callId, reason: reason);
      final call = Call.fromJson(callMap);
      
      // Remove call from active calls list
      _activeCalls.removeWhere((c) => c.id == callId);
      if (_currentCall?.id == callId) {
        _currentCall = null;
      }
      
      notifyListeners();
      return call;
    } catch (e) {
      if (kDebugMode) {
        print('Error rejecting call $callId: $e');
      }
      rethrow;
    }
  }

  Future<Call> endCall(String callId) async {
    try {
      final callMap = await CallsService.endCall(callId);
      final call = Call.fromJson(callMap);
      
      // Remove call from active calls list
      _activeCalls.removeWhere((c) => c.id == callId);
      if (_currentCall?.id == callId) {
        _currentCall = null;
      }
      
      notifyListeners();
      return call;
    } catch (e) {
      if (kDebugMode) {
        print('Error ending call $callId: $e');
      }
      rethrow;
    }
  }

  // Real-time operations
  void updateTypingIndicator(String chatId, String userId, bool isTyping) {
    final indicators = List<Map<String, dynamic>>.from(_typingIndicators[chatId] ?? []);
    
    if (isTyping) {
      // Add or update typing indicator
      final existingIndex = indicators.indexWhere((indicator) => indicator['userId'] == userId);
      if (existingIndex != -1) {
        indicators[existingIndex] = {
          'userId': userId,
          'isTyping': true,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        indicators.add({
          'userId': userId,
          'isTyping': true,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } else {
      // Remove typing indicator
      indicators.removeWhere((indicator) => indicator['userId'] == userId);
    }
    
    _typingIndicators[chatId] = indicators;
    notifyListeners();
  }

  void addMessage(String chatId, Message message) {
    final messages = List<Message>.from(_messages[chatId] ?? []);
    messages.add(message);
    _messages[chatId] = messages;

    // Update chat's last message
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      _chats[chatIndex] = _chats[chatIndex].copyWith(
        lastMessage: message,
        lastActivity: DateTime.now(),
      );
    }

    // Update unread count if message is not from current user
    if (message.senderId != 'currentUserId') { // Replace with actual current user ID
      _unreadCounts[chatId] = (_unreadCounts[chatId] ?? 0) + 1;
    }

    notifyListeners();
  }

  void updateMessage(String chatId, String messageId, Message updatedMessage) {
    final messages = _messages[chatId] ?? [];
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex != -1) {
      messages[messageIndex] = updatedMessage;
      _messages[chatId] = messages;
      notifyListeners();
    }
  }

  void removeMessage(String chatId, String messageId) {
    final messages = _messages[chatId] ?? [];
    messages.removeWhere((msg) => msg.id == messageId);
    _messages[chatId] = messages;
    notifyListeners();
  }

  void updateUnreadCount(String chatId, int count) {
    _unreadCounts[chatId] = count;
    notifyListeners();
  }

  // Utility methods
  void setCurrentChat(Chat? chat) {
    _currentChat = chat;
    notifyListeners();
  }

  void setCurrentCall(Call? call) {
    _currentCall = call;
    notifyListeners();
  }

  void clearErrors() {
    _chatError = null;
    _callError = null;
    _messageErrors.clear();
    notifyListeners();
  }

  void clearChatData() {
    _chats.clear();
    _messages.clear();
    _currentChat = null;
    _unreadCounts.clear();
    _typingIndicators.clear();
    notifyListeners();
  }

  void clearCallData() {
    _activeCalls.clear();
    _currentCall = null;
    notifyListeners();
  }
}
