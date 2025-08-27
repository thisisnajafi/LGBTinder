import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'api_service.dart';

class ChatService {
  final ApiService _apiService;

  ChatService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Get all chats for the current user
  Future<List<Chat>> getChats({
    int page = 1,
    int limit = 20,
    String? searchQuery,
    bool? isArchived,
    bool? isPinned,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (isArchived != null) {
        queryParams['archived'] = isArchived.toString();
      }
      if (isPinned != null) {
        queryParams['pinned'] = isPinned.toString();
      }

      final response = await _apiService.get('/chats', queryParameters: queryParams);
      
      final List<dynamic> chatsData = response['chats'] ?? [];
      return chatsData.map((json) => Chat.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chats: $e');
      }
      rethrow;
    }
  }

  /// Get a specific chat by ID
  Future<Chat> getChat(String chatId) async {
    try {
      final response = await _apiService.get('/chats/$chatId');
      return Chat.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Create a new chat with a user
  Future<Chat> createChat(String userId) async {
    try {
      final response = await _apiService.post('/chats', {
        'userId': userId,
      });
      return Chat.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating chat with user $userId: $e');
      }
      rethrow;
    }
  }

  /// Create a group chat
  Future<Chat> createGroupChat({
    required String name,
    required List<String> userIds,
    String? avatar,
  }) async {
    try {
      final response = await _apiService.post('/chats/group', {
        'name': name,
        'userIds': userIds,
        if (avatar != null) 'avatar': avatar,
      });
      return Chat.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating group chat: $e');
      }
      rethrow;
    }
  }

  /// Update chat metadata
  Future<Chat> updateChat(String chatId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put('/chats/$chatId', updates);
      return Chat.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Archive a chat
  Future<void> archiveChat(String chatId) async {
    try {
      await _apiService.put('/chats/$chatId/archive', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error archiving chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Unarchive a chat
  Future<void> unarchiveChat(String chatId) async {
    try {
      await _apiService.put('/chats/$chatId/unarchive', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error unarchiving chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Pin a chat
  Future<void> pinChat(String chatId) async {
    try {
      await _apiService.put('/chats/$chatId/pin', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error pinning chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Unpin a chat
  Future<void> unpinChat(String chatId) async {
    try {
      await _apiService.put('/chats/$chatId/unpin', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error unpinning chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      await _apiService.delete('/chats/$chatId');
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Mark chat as read
  Future<void> markChatAsRead(String chatId) async {
    try {
      await _apiService.put('/chats/$chatId/read', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error marking chat $chatId as read: $e');
      }
      rethrow;
    }
  }

  /// Get chat participants
  Future<List<ChatParticipant>> getChatParticipants(String chatId) async {
    try {
      final response = await _apiService.get('/chats/$chatId/participants');
      
      final List<dynamic> participantsData = response['participants'] ?? [];
      return participantsData.map((json) => ChatParticipant.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching chat participants for $chatId: $e');
      }
      rethrow;
    }
  }

  /// Add participants to group chat
  Future<void> addParticipants(String chatId, List<String> userIds) async {
    try {
      await _apiService.post('/chats/$chatId/participants', {
        'userIds': userIds,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding participants to chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Remove participants from group chat
  Future<void> removeParticipants(String chatId, List<String> userIds) async {
    try {
      await _apiService.post('/chats/$chatId/participants/remove', {
        'userIds': userIds,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error removing participants from chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Update participant role in group chat
  Future<void> updateParticipantRole(String chatId, String userId, String role) async {
    try {
      await _apiService.put('/chats/$chatId/participants/$userId', {
        'role': role,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating participant role in chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Leave group chat
  Future<void> leaveGroupChat(String chatId) async {
    try {
      await _apiService.post('/chats/$chatId/leave', {});
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving group chat $chatId: $e');
      }
      rethrow;
    }
  }

  /// Get unread count for all chats
  Future<int> getTotalUnreadCount() async {
    try {
      final response = await _apiService.get('/chats/unread-count');
      return response['unreadCount'] ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching total unread count: $e');
      }
      rethrow;
    }
  }

  /// Search chats
  Future<List<Chat>> searchChats(String query) async {
    try {
      final response = await _apiService.get('/chats/search', queryParameters: {
        'q': query,
      });
      
      final List<dynamic> chatsData = response['chats'] ?? [];
      return chatsData.map((json) => Chat.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching chats: $e');
      }
      rethrow;
    }
  }
} 