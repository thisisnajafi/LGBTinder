import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import 'cache_service.dart';
import 'websocket_service.dart';

/// Message Queue Service
/// 
/// Handles offline message queueing, delivery confirmation, and retry mechanism
/// Ensures messages are delivered even when offline or connection is unstable
class MessageQueueService {
  static final MessageQueueService _instance = MessageQueueService._internal();
  factory MessageQueueService() => _instance;
  MessageQueueService._internal();

  final List<QueuedMessage> _messageQueue = [];
  final Map<String, MessageStatus> _messageStatusMap = {};
  Timer? _retryTimer;
  bool _isProcessingQueue = false;

  // Stream controller for message status updates
  final StreamController<MessageStatusUpdate> _statusController = 
      StreamController<MessageStatusUpdate>.broadcast();
  
  Stream<MessageStatusUpdate> get statusStream => _statusController.stream;

  /// Initialize the service
  Future<void> initialize() async {
    await _loadQueueFromStorage();
    _startRetryTimer();
    _listenToWebSocketEvents();
  }

  /// Add message to queue
  Future<String> queueMessage({
    required String chatId,
    required String content,
    required String senderId,
    String messageType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final messageId = _generateMessageId();
    final message = QueuedMessage(
      messageId: messageId,
      chatId: chatId,
      content: content,
      senderId: senderId,
      messageType: messageType,
      metadata: metadata,
      timestamp: DateTime.now(),
      retryCount: 0,
      status: MessageStatus.sending,
    );

    _messageQueue.add(message);
    _messageStatusMap[messageId] = MessageStatus.sending;
    
    // Notify status update
    _statusController.add(MessageStatusUpdate(
      messageId: messageId,
      status: MessageStatus.sending,
    ));

    await _saveQueueToStorage();
    
    // Try to send immediately
    _processQueue();

    return messageId;
  }

  /// Process the message queue
  Future<void> _processQueue() async {
    if (_isProcessingQueue || _messageQueue.isEmpty) return;
    
    _isProcessingQueue = true;

    try {
      final wsService = WebSocketService();
      
      if (!wsService.isConnected) {
        debugPrint('WebSocket not connected, waiting to process queue');
        _isProcessingQueue = false;
        return;
      }

      // Process messages in order
      final messagesToSend = List<QueuedMessage>.from(_messageQueue);
      
      for (final message in messagesToSend) {
        if (message.status == MessageStatus.sent || 
            message.status == MessageStatus.delivered ||
            message.status == MessageStatus.read) {
          _messageQueue.remove(message);
          continue;
        }

        try {
          // Send message via WebSocket
          wsService.sendMessage(
            chatId: message.chatId,
            message: message.content,
            messageType: message.messageType,
            metadata: {
              ...?message.metadata,
              'client_message_id': message.messageId,
            },
          );

          // Update status to sent
          message.status = MessageStatus.sent;
          _messageStatusMap[message.messageId] = MessageStatus.sent;
          
          _statusController.add(MessageStatusUpdate(
            messageId: message.messageId,
            status: MessageStatus.sent,
          ));

          debugPrint('Message sent successfully: ${message.messageId}');
          
        } catch (e) {
          debugPrint('Failed to send message ${message.messageId}: $e');
          message.retryCount++;
          
          if (message.retryCount >= 3) {
            // Mark as failed after 3 retries
            message.status = MessageStatus.failed;
            _messageStatusMap[message.messageId] = MessageStatus.failed;
            
            _statusController.add(MessageStatusUpdate(
              messageId: message.messageId,
              status: MessageStatus.failed,
              error: 'Failed after 3 retries',
            ));
          }
        }
      }

      await _saveQueueToStorage();
      
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// Listen to WebSocket events for delivery confirmation
  void _listenToWebSocketEvents() {
    final wsService = WebSocketService();
    
    // Listen to message stream for delivery confirmations
    wsService.messageStream.listen((data) {
      if (data['type'] == 'message_delivered') {
        final clientMessageId = data['client_message_id'] as String?;
        if (clientMessageId != null) {
          _updateMessageStatus(clientMessageId, MessageStatus.delivered);
        }
      } else if (data['type'] == 'message_read') {
        final clientMessageId = data['client_message_id'] as String?;
        if (clientMessageId != null) {
          _updateMessageStatus(clientMessageId, MessageStatus.read);
        }
      }
    });

    // Listen to connection state changes
    wsService.connectionStateStream.listen((state) {
      if (state == 'connected') {
        debugPrint('WebSocket connected, processing message queue');
        _processQueue();
      }
    });
  }

  /// Update message status
  void _updateMessageStatus(String messageId, MessageStatus status) {
    _messageStatusMap[messageId] = status;
    
    // Update in queue
    final queuedMessage = _messageQueue.firstWhere(
      (msg) => msg.messageId == messageId,
      orElse: () => QueuedMessage(
        messageId: '',
        chatId: '',
        content: '',
        senderId: '',
        timestamp: DateTime.now(),
        retryCount: 0,
        status: MessageStatus.failed,
      ),
    );

    if (queuedMessage.messageId.isNotEmpty) {
      queuedMessage.status = status;
      
      // Remove from queue if delivered or read
      if (status == MessageStatus.delivered || status == MessageStatus.read) {
        _messageQueue.remove(queuedMessage);
        _saveQueueToStorage();
      }
    }

    _statusController.add(MessageStatusUpdate(
      messageId: messageId,
      status: status,
    ));
  }

  /// Get message status
  MessageStatus getMessageStatus(String messageId) {
    return _messageStatusMap[messageId] ?? MessageStatus.unknown;
  }

  /// Retry failed messages
  Future<void> retryFailedMessages() async {
    for (final message in _messageQueue) {
      if (message.status == MessageStatus.failed) {
        message.status = MessageStatus.sending;
        message.retryCount = 0;
        _messageStatusMap[message.messageId] = MessageStatus.sending;
        
        _statusController.add(MessageStatusUpdate(
          messageId: message.messageId,
          status: MessageStatus.sending,
        ));
      }
    }
    
    await _saveQueueToStorage();
    _processQueue();
  }

  /// Clear message from queue
  void clearMessage(String messageId) {
    _messageQueue.removeWhere((msg) => msg.messageId == messageId);
    _messageStatusMap.remove(messageId);
    _saveQueueToStorage();
  }

  /// Start retry timer
  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_messageQueue.isNotEmpty) {
        _processQueue();
      }
    });
  }

  /// Generate unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_messageQueue.length}';
  }

  /// Save queue to storage
  Future<void> _saveQueueToStorage() async {
    final queueData = _messageQueue.map((msg) => msg.toJson()).toList();
    await CacheService.setData(
      key: 'message_queue',
      value: queueData,
    );
  }

  /// Load queue from storage
  Future<void> _loadQueueFromStorage() async {
    final queueData = await CacheService.getData('message_queue');
    if (queueData != null && queueData is List) {
      _messageQueue.clear();
      for (final item in queueData) {
        if (item is Map<String, dynamic>) {
          final message = QueuedMessage.fromJson(item);
          _messageQueue.add(message);
          _messageStatusMap[message.messageId] = message.status;
        }
      }
      debugPrint('Loaded ${_messageQueue.length} messages from storage');
    }
  }

  /// Dispose service
  void dispose() {
    _retryTimer?.cancel();
    _statusController.close();
  }
}

/// Queued message model
class QueuedMessage {
  final String messageId;
  final String chatId;
  final String content;
  final String senderId;
  final String messageType;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  int retryCount;
  MessageStatus status;

  QueuedMessage({
    required this.messageId,
    required this.chatId,
    required this.content,
    required this.senderId,
    this.messageType = 'text',
    this.metadata,
    required this.timestamp,
    required this.retryCount,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'content': content,
      'senderId': senderId,
      'messageType': messageType,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'status': status.toString(),
    };
  }

  factory QueuedMessage.fromJson(Map<String, dynamic> json) {
    return QueuedMessage(
      messageId: json['messageId'] as String,
      chatId: json['chatId'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      messageType: json['messageType'] as String? ?? 'text',
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      status: _parseStatus(json['status'] as String?),
    );
  }

  static MessageStatus _parseStatus(String? status) {
    switch (status) {
      case 'MessageStatus.sending':
        return MessageStatus.sending;
      case 'MessageStatus.sent':
        return MessageStatus.sent;
      case 'MessageStatus.delivered':
        return MessageStatus.delivered;
      case 'MessageStatus.read':
        return MessageStatus.read;
      case 'MessageStatus.failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.unknown;
    }
  }
}

/// Message status enum
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
  unknown,
}

/// Message status update event
class MessageStatusUpdate {
  final String messageId;
  final MessageStatus status;
  final String? error;

  MessageStatusUpdate({
    required this.messageId,
    required this.status,
    this.error,
  });
}

