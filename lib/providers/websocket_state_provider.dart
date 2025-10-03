import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/api_models/common_models.dart';
import '../models/api_models/chat_models.dart';
import '../models/api_models/matching_models.dart';
import '../models/websocket_connection_state.dart';
import '../services/token_management_service.dart';
import '../config/api_config.dart';

class WebSocketStateProvider extends ChangeNotifier {
  // WebSocket connection
  WebSocket? _webSocket;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _connectionError;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // Real-time data
  Map<int, bool> _typingUsers = {}; // userId -> isTyping
  Map<int, bool> _onlineUsers = {}; // userId -> isOnline
  List<MessageData> _recentMessages = [];
  List<MatchData> _newMatches = [];
  Map<int, int> _unreadCounts = {}; // userId -> unread count

  // Event streams
  final StreamController<WebSocketEvent> _eventController = StreamController<WebSocketEvent>.broadcast();
  final StreamController<MessageData> _messageController = StreamController<MessageData>.broadcast();
  final StreamController<MatchData> _matchController = StreamController<MatchData>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final Map<String, StreamController<WebSocketEvent>> _eventControllers = {};

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get connectionError => _connectionError;
  Map<int, bool> get typingUsers => _typingUsers;
  List<MessageData> get recentMessages => _recentMessages;
  List<MatchData> get newMatches => _newMatches;
  Map<int, int> get unreadCounts => _unreadCounts;

  // Connection state getter
  WebSocketConnectionState get connectionState {
    if (_isConnected) return WebSocketConnectionState.connected;
    if (_isConnecting) return WebSocketConnectionState.connecting;
    if (_connectionError != null) return WebSocketConnectionState.error;
    return WebSocketConnectionState.disconnected;
  }

  // Stream getters
  Stream<WebSocketEvent> get eventStream => _eventController.stream;
  Stream<MessageData> get messageStream => _messageController.stream;
  Stream<MatchData> get matchStream => _matchController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  // Initialize WebSocket connection
  Future<void> initialize() async {
    await connect();
  }

  // Connect to WebSocket
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    try {
      _isConnecting = true;
      _connectionError = null;
      notifyListeners();

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final wsUrl = ApiConfig.getWebSocketUrl();
      final uri = Uri.parse('$wsUrl?token=$token');
      
      _webSocket = await WebSocket.connect(uri.toString());
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionError = null;

      // Listen for messages
      _webSocket!.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      notifyListeners();
      if (kDebugMode) {
        print('WebSocket connected successfully');
      }
    } catch (e) {
      _isConnecting = false;
      _connectionError = e.toString();
      _handleConnectionError(e);
      notifyListeners();
    }
  }

  // Disconnect from WebSocket
  void disconnect() {
    _reconnectTimer?.cancel();
    _webSocket?.close();
    _webSocket = null;
    _isConnected = false;
    _isConnecting = false;
    _connectionError = null;
    notifyListeners();
  }

  // Send message through WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _webSocket != null) {
      try {
        _webSocket!.add(jsonEncode(message));
      } catch (e) {
        if (kDebugMode) {
          print('Error sending WebSocket message: $e');
        }
      }
    }
  }

  // Send typing indicator
  void sendTypingIndicator(int userId, bool isTyping) {
    sendMessage({
      'event': 'typing',
      'data': {
        'user_id': userId,
        'is_typing': isTyping,
      },
    });
  }

  // Send message read receipt
  void sendReadReceipt(int userId, int messageId) {
    sendMessage({
      'event': 'message_read',
      'data': {
        'user_id': userId,
        'message_id': messageId,
      },
    });
  }

  // Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      final event = WebSocketEvent.fromJson(data);

      _eventController.add(event);

      switch (event.event) {
        case 'new_message':
          _handleNewMessage(event.data);
          break;
        case 'typing':
          _handleTypingIndicator(event.data);
          break;
        case 'new_match':
          _handleNewMatch(event.data);
          break;
        case 'message_read':
          _handleMessageRead(event.data);
          break;
        case 'user_online':
          _handleUserOnline(event.data);
          break;
        case 'user_offline':
          _handleUserOffline(event.data);
          break;
        default:
          if (kDebugMode) {
            print('Unknown WebSocket event: ${event.event}');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling WebSocket message: $e');
      }
    }
  }

  // Handle new message event
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final message = MessageData.fromJson(data);
      _recentMessages.add(message);
      
      // Update unread count
      final senderId = message.senderId;
      _unreadCounts[senderId] = (_unreadCounts[senderId] ?? 0) + 1;
      
      _messageController.add(message);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling new message: $e');
      }
    }
  }

  // Handle typing indicator event
  void _handleTypingIndicator(Map<String, dynamic> data) {
    try {
      final userId = data['user_id'] as int;
      final isTyping = data['is_typing'] as bool;
      
      _typingUsers[userId] = isTyping;
      _typingController.add(data);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling typing indicator: $e');
      }
    }
  }

  // Handle new match event
  void _handleNewMatch(Map<String, dynamic> data) {
    try {
      final match = MatchData.fromJson(data);
      _newMatches.add(match);
      _matchController.add(match);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling new match: $e');
      }
    }
  }

  // Handle message read event
  void _handleMessageRead(Map<String, dynamic> data) {
    try {
      final userId = data['user_id'] as int;
      final messageId = data['message_id'] as int;
      
      // Update message as read in recent messages
      for (var message in _recentMessages) {
        if (message.id == messageId && message.senderId == userId) {
          // This would typically update the message's isRead status
          break;
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling message read: $e');
      }
    }
  }

  // Handle user online event
  void _handleUserOnline(Map<String, dynamic> data) {
    try {
      final userId = data['user_id'] as int;
      // Handle user online status
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling user online: $e');
      }
    }
  }

  // Handle user offline event
  void _handleUserOffline(Map<String, dynamic> data) {
    try {
      final userId = data['user_id'] as int;
      // Handle user offline status
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling user offline: $e');
      }
    }
  }

  // Handle WebSocket errors
  void _handleError(dynamic error) {
    if (kDebugMode) {
      print('WebSocket error: $error');
    }
    _connectionError = error.toString();
    _isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  // Handle WebSocket disconnection
  void _handleDisconnection() {
    if (kDebugMode) {
      print('WebSocket disconnected');
    }
    _isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  // Handle connection errors
  void _handleConnectionError(dynamic error) {
    if (kDebugMode) {
      print('WebSocket connection error: $error');
    }
    _scheduleReconnect();
  }

  // Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        print('Max reconnection attempts reached');
      }
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      if (kDebugMode) {
        print('Attempting to reconnect (${_reconnectAttempts}/$_maxReconnectAttempts)');
      }
      connect();
    });
  }

  // Clear recent messages
  void clearRecentMessages() {
    _recentMessages.clear();
    notifyListeners();
  }

  // Clear new matches
  void clearNewMatches() {
    _newMatches.clear();
    notifyListeners();
  }

  // Mark messages as read for a user
  void markMessagesAsRead(int userId) {
    _unreadCounts[userId] = 0;
    notifyListeners();
  }

  // Get unread count for a user
  int getUnreadCount(int userId) {
    return _unreadCounts[userId] ?? 0;
  }

  // Get total unread count
  int get totalUnreadCount {
    return _unreadCounts.values.fold(0, (sum, count) => sum + count);
  }

  // Check if user is typing
  bool isUserTyping(int userId) {
    return _typingUsers[userId] ?? false;
  }

  // Clear all data
  void clearAllData() {
    _typingUsers.clear();
    _recentMessages.clear();
    _newMatches.clear();
    _unreadCounts.clear();
    notifyListeners();
  }

  // Event listener management
  void addEventListener(String eventType, void Function(WebSocketEvent) handler) {
    _eventControllers[eventType]?.stream.listen(handler);
  }

  void removeEventListener(String eventType, void Function(WebSocketEvent) handler) {
    // In a real implementation, you'd need to store subscriptions to remove them
    // For now, we'll just ignore removal calls
  }

  // Typing users management
  List<int> getTypingUsers(int chatId) {
    return _typingUsers.keys.where((userId) => _typingUsers[userId] == true).toList();
  }

  // User online status
  bool isUserOnline(int userId) {
    return _onlineUsers[userId] ?? false;
  }

  // Dispose method
  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _webSocket?.close();
    _eventController.close();
    _messageController.close();
    _matchController.close();
    _typingController.close();
    super.dispose();
  }
}
