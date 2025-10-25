import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import '../utils/error_handler.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  IO.Socket? _socket;
  String? _accessToken;
  String? _userId;
  bool _isConnected = false;
  bool _isConnecting = false;
  
  // Stream controllers for different types of real-time events
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _statusUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _callController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _matchController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _likeController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _groupChatController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionStateController = StreamController<String>.broadcast();
  
  // Public streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  Stream<Map<String, dynamic>> get statusUpdateStream => _statusUpdateController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get callStream => _callController.stream;
  Stream<Map<String, dynamic>> get matchStream => _matchController.stream;
  Stream<Map<String, dynamic>> get likeStream => _likeController.stream;
  Stream<Map<String, dynamic>> get groupChatStream => _groupChatController.stream;
  Stream<String> get connectionStateStream => _connectionStateController.stream;
  
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  /// Initialize WebSocket connection
  Future<void> initialize({
    required String accessToken,
    required String userId,
  }) async {
    try {
      _accessToken = accessToken;
      _userId = userId;
      
      if (_isConnecting) {
        debugPrint('WebSocket connection already in progress');
        return;
      }
      
      _isConnecting = true;
      _connectionStateController.add('connecting');
      
      await _connect();
      
      debugPrint('WebSocket Service initialized successfully');
    } catch (e) {
      _isConnecting = false;
      _connectionStateController.add('error');
      debugPrint('Failed to initialize WebSocket Service: $e');
      rethrow;
    }
  }

  /// Connect to WebSocket server
  Future<void> _connect() async {
    try {
      final serverUrl = ApiConfig.getWebSocketUrl(); // You'll need to add this to ApiConfig
      
      _socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {
          'token': _accessToken,
          'userId': _userId,
        },
        'query': {
          'platform': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'web',
        },
      });

      _setupEventListeners();
      _socket!.connect();
      
    } catch (e) {
      _isConnecting = false;
      debugPrint('Failed to connect to WebSocket server: $e');
      rethrow;
    }
  }

  /// Setup event listeners
  void _setupEventListeners() {
    _socket!.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _connectionStateController.add('connected');
      debugPrint('WebSocket connected');
      
      // Join user-specific room
      _socket!.emit('join-user-room', {'userId': _userId});
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _isConnecting = false;
      _connectionStateController.add('disconnected');
      debugPrint('WebSocket disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      _isConnecting = false;
      _connectionStateController.add('error');
      debugPrint('WebSocket connection error: $error');
    });

    _socket!.onError((error) {
      debugPrint('WebSocket error: $error');
      _connectionStateController.add('error');
    });

    // Message events
    _socket!.on('new-message', (data) {
      _messageController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('message-read', (data) {
      _messageController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('message-delivered', (data) {
      _messageController.add(Map<String, dynamic>.from(data));
    });

    // Notification events
    _socket!.on('notification', (data) {
      _notificationController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('notification-read', (data) {
      _notificationController.add(Map<String, dynamic>.from(data));
    });

    // Status update events
    _socket!.on('user-online', (data) {
      _statusUpdateController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('user-offline', (data) {
      _statusUpdateController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('user-typing', (data) {
      _typingController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('user-stopped-typing', (data) {
      _typingController.add(Map<String, dynamic>.from(data));
    });

    // Call events
    _socket!.on('call-offer', (data) {
      _callController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('call-answer', (data) {
      _callController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('call-reject', (data) {
      _callController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('call-end', (data) {
      _callController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('call-ringing', (data) {
      _callController.add(Map<String, dynamic>.from(data));
    });

    // Match events
    _socket!.on('new-match', (data) {
      _matchController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('match-updated', (data) {
      _matchController.add(Map<String, dynamic>.from(data));
    });

    // Like events
    _socket!.on('like-received', (data) {
      _likeController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('superlike-received', (data) {
      _likeController.add(Map<String, dynamic>.from(data));
    });

    // Group chat events
    _socket!.on('group-message', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-message-read', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-message-delivered', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-user-typing', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-user-joined', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-user-left', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-user-added', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-user-removed', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-updated', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('group-deleted', (data) {
      _groupChatController.add(Map<String, dynamic>.from(data));
    });

    // General events
    _socket!.on('error', (data) {
      debugPrint('WebSocket server error: $data');
    });

    _socket!.on('reconnect', (data) {
      debugPrint('WebSocket reconnected');
      _connectionStateController.add('reconnected');
    });

    _socket!.on('reconnect_error', (data) {
      debugPrint('WebSocket reconnect error: $data');
      _connectionStateController.add('reconnect_error');
    });
  }

  /// Send a message
  void sendMessage({
    required String chatId,
    required String message,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('send-message', {
      'chatId': chatId,
      'message': message,
      'messageType': messageType ?? 'text',
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send typing indicator
  void sendTypingIndicator({
    required String chatId,
    required bool isTyping,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('typing', {
      'chatId': chatId,
      'isTyping': isTyping,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Mark message as read
  void markMessageAsRead({
    required String messageId,
    required String chatId,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('mark-read', {
      'messageId': messageId,
      'chatId': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Update online status
  void updateOnlineStatus({
    required bool isOnline,
    String? status,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('status-update', {
      'isOnline': isOnline,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Join a chat room
  void joinChatRoom(String chatId) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('join-chat', {'chatId': chatId});
  }

  /// Leave a chat room
  void leaveChatRoom(String chatId) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('leave-chat', {'chatId': chatId});
  }

  /// Send call offer
  void sendCallOffer({
    required String callId,
    required String toUserId,
    required String callType, // 'voice' or 'video'
    Map<String, dynamic>? offerData,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('call-offer', {
      'callId': callId,
      'toUserId': toUserId,
      'callType': callType,
      'offerData': offerData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send call answer
  void sendCallAnswer({
    required String callId,
    required String fromUserId,
    required bool accepted,
    Map<String, dynamic>? answerData,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('call-answer', {
      'callId': callId,
      'fromUserId': fromUserId,
      'accepted': accepted,
      'answerData': answerData,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send call rejection
  void sendCallRejection({
    required String callId,
    required String fromUserId,
    String? reason,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('call-reject', {
      'callId': callId,
      'fromUserId': fromUserId,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send call end
  void sendCallEnd({
    required String callId,
    required String toUserId,
    String? reason,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('call-end', {
      'callId': callId,
      'toUserId': toUserId,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send like notification
  void sendLikeNotification({
    required String toUserId,
    required String likeType, // 'like', 'superlike'
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('like-notification', {
      'toUserId': toUserId,
      'likeType': likeType,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send match notification
  void sendMatchNotification({
    required String toUserId,
    required String matchId,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('match-notification', {
      'toUserId': toUserId,
      'matchId': matchId,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send custom event
  void sendCustomEvent({
    required String eventName,
    required Map<String, dynamic> data,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit(eventName, {
      ...data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ============================================================================
  // GROUP CHAT METHODS
  // ============================================================================

  /// Join a group chat room
  void joinGroupChatRoom(String groupId) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('join-group', {'groupId': groupId});
    debugPrint('Joined group chat room: $groupId');
  }

  /// Leave a group chat room
  void leaveGroupChatRoom(String groupId) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('leave-group', {'groupId': groupId});
    debugPrint('Left group chat room: $groupId');
  }

  /// Send a group chat message
  void sendGroupChatMessage({
    required String groupId,
    required String message,
    String? messageType,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('send-group-message', {
      'groupId': groupId,
      'message': message,
      'messageType': messageType ?? 'text',
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Send typing indicator in group chat
  void sendGroupChatTypingIndicator({
    required String groupId,
    required bool isTyping,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('group-typing', {
      'groupId': groupId,
      'isTyping': isTyping,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Mark group chat message as read
  void markGroupChatMessageAsRead({
    required String messageId,
    required String groupId,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('mark-group-message-read', {
      'messageId': messageId,
      'groupId': groupId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Add member to group chat
  void addGroupChatMember({
    required String groupId,
    required String userId,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('add-group-member', {
      'groupId': groupId,
      'userId': userId,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Remove member from group chat
  void removeGroupChatMember({
    required String groupId,
    required String userId,
    String? reason,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('remove-group-member', {
      'groupId': groupId,
      'userId': userId,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Update group chat info
  void updateGroupChatInfo({
    required String groupId,
    String? name,
    String? description,
    String? avatar,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    final updateData = <String, dynamic>{
      'groupId': groupId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (avatar != null) updateData['avatar'] = avatar;
    if (metadata != null) updateData['metadata'] = metadata;

    _socket!.emit('update-group', updateData);
  }

  /// Delete group chat
  void deleteGroupChat({
    required String groupId,
    String? reason,
  }) {
    if (!_isConnected) {
      throw NetworkException('WebSocket not connected');
    }

    _socket!.emit('delete-group', {
      'groupId': groupId,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ============================================================================

  /// Reconnect to WebSocket
  Future<void> reconnect() async {
    try {
      if (_isConnected) {
        debugPrint('WebSocket already connected');
        return;
      }

      _isConnecting = true;
      _connectionStateController.add('reconnecting');
      
      if (_socket != null) {
        _socket!.disconnect();
      }
      
      await _connect();
      
    } catch (e) {
      _isConnecting = false;
      _connectionStateController.add('reconnect_error');
      debugPrint('Failed to reconnect WebSocket: $e');
      rethrow;
    }
  }

  /// Disconnect from WebSocket
  void disconnect() {
    try {
      if (_socket != null) {
        _socket!.disconnect();
        _socket = null;
      }
      
      _isConnected = false;
      _isConnecting = false;
      _connectionStateController.add('disconnected');
      
      debugPrint('WebSocket disconnected');
    } catch (e) {
      debugPrint('Error disconnecting WebSocket: $e');
    }
  }

  /// Dispose service
  void dispose() {
    disconnect();
    
    _messageController.close();
    _notificationController.close();
    _statusUpdateController.close();
    _typingController.close();
    _callController.close();
    _matchController.close();
    _likeController.close();
    _groupChatController.close();
    _connectionStateController.close();
    
    debugPrint('WebSocket Service disposed');
  }
}

/// WebSocket event types
class WebSocketEvents {
  static const String newMessage = 'new-message';
  static const String messageRead = 'message-read';
  static const String messageDelivered = 'message-delivered';
  static const String notification = 'notification';
  static const String notificationRead = 'notification-read';
  static const String userOnline = 'user-online';
  static const String userOffline = 'user-offline';
  static const String userTyping = 'user-typing';
  static const String userStoppedTyping = 'user-stopped-typing';
  static const String callOffer = 'call-offer';
  static const String callAnswer = 'call-answer';
  static const String callReject = 'call-reject';
  static const String callEnd = 'call-end';
  static const String callRinging = 'call-ringing';
  static const String newMatch = 'new-match';
  static const String matchUpdated = 'match-updated';
  static const String likeReceived = 'like-received';
  static const String superlikeReceived = 'superlike-received';
  
  // Group chat events
  static const String groupMessage = 'group-message';
  static const String groupMessageRead = 'group-message-read';
  static const String groupMessageDelivered = 'group-message-delivered';
  static const String groupUserTyping = 'group-user-typing';
  static const String groupUserJoined = 'group-user-joined';
  static const String groupUserLeft = 'group-user-left';
  static const String groupUserAdded = 'group-user-added';
  static const String groupUserRemoved = 'group-user-removed';
  static const String groupUpdated = 'group-updated';
  static const String groupDeleted = 'group-deleted';
}

/// WebSocket connection states
class WebSocketStates {
  static const String connecting = 'connecting';
  static const String connected = 'connected';
  static const String disconnected = 'disconnected';
  static const String reconnecting = 'reconnecting';
  static const String reconnected = 'reconnected';
  static const String reconnectError = 'reconnect_error';
  static const String error = 'error';
}
