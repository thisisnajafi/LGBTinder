import 'dart:convert';

/// Chat & Messaging API Models
/// 
/// This file contains all data models for chat and messaging endpoints
/// including sending messages, getting chat history, and related functionality.

// ============================================================================
// MESSAGE MODELS
// ============================================================================

/// Message type enumeration
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
}

/// Message type extension
extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.audio:
        return 'audio';
      case MessageType.file:
        return 'file';
    }
  }

  static MessageType fromString(String value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'file':
        return MessageType.file;
      default:
        return MessageType.text;
    }
  }
}

/// Request model for sending a message
class SendMessageRequest {
  final int receiverId;
  final String message;
  final MessageType messageType;

  const SendMessageRequest({
    required this.receiverId,
    required this.message,
    this.messageType = MessageType.text,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) {
    return SendMessageRequest(
      receiverId: json['receiver_id'] as int,
      message: json['message'] as String,
      messageType: MessageTypeExtension.fromString(json['message_type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
      'message': message,
      'message_type': messageType.value,
    };
  }
}

/// Message data model
class MessageData {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String message;
  final MessageType messageType;
  final String sentAt;
  final bool isRead;

  const MessageData({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.messageType,
    required this.sentAt,
    required this.isRead,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      messageId: json['message_id'] as int,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      message: json['message'] as String,
      messageType: MessageTypeExtension.fromString(json['message_type'] as String),
      sentAt: json['sent_at'] as String,
      isRead: json['is_read'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'message_type': messageType.value,
      'sent_at': sentAt,
      'is_read': isRead,
    };
  }
}

/// Send message response model
class SendMessageResponse {
  final bool status;
  final String message;
  final MessageData? data;

  const SendMessageResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: json['data'] != null 
          ? MessageData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

// ============================================================================
// CHAT HISTORY MODELS
// ============================================================================

/// Pagination data model
class PaginationData {
  final int currentPage;
  final int totalPages;
  final int totalMessages;
  final int perPage;

  const PaginationData({
    required this.currentPage,
    required this.totalPages,
    required this.totalMessages,
    required this.perPage,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalMessages: json['total_messages'] as int,
      perPage: json['per_page'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_messages': totalMessages,
      'per_page': perPage,
    };
  }

  /// Check if there are more pages
  bool get hasNextPage => currentPage < totalPages;

  /// Check if there are previous pages
  bool get hasPreviousPage => currentPage > 1;

  /// Get next page number
  int? get nextPage => hasNextPage ? currentPage + 1 : null;

  /// Get previous page number
  int? get previousPage => hasPreviousPage ? currentPage - 1 : null;
}

/// Chat history data model
class ChatHistoryData {
  final List<MessageData> messages;
  final PaginationData pagination;

  const ChatHistoryData({
    required this.messages,
    required this.pagination,
  });

  factory ChatHistoryData.fromJson(Map<String, dynamic> json) {
    return ChatHistoryData(
      messages: (json['messages'] as List).map((item) => MessageData.fromJson(item as Map<String, dynamic>)).toList(),
      pagination: PaginationData.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

/// Get chat history response model
class GetChatHistoryResponse {
  final bool status;
  final ChatHistoryData? data;

  const GetChatHistoryResponse({
    required this.status,
    this.data,
  });

  factory GetChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return GetChatHistoryResponse(
      status: json['status'] as bool,
      data: json['data'] != null 
          ? ChatHistoryData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

// ============================================================================
// CHAT UTILITIES
// ============================================================================

/// Chat helper class
class ChatHelper {
  /// Check if message is from current user
  static bool isFromCurrentUser(MessageData message, int currentUserId) {
    return message.senderId == currentUserId;
  }

  /// Check if message is to current user
  static bool isToCurrentUser(MessageData message, int currentUserId) {
    return message.receiverId == currentUserId;
  }

  /// Get message time
  static DateTime getMessageTime(MessageData message) {
    return DateTime.parse(message.sentAt);
  }

  /// Get time since message
  static Duration getTimeSinceMessage(MessageData message) {
    final messageTime = getMessageTime(message);
    return DateTime.now().difference(messageTime);
  }

  /// Format message time
  static String formatMessageTime(MessageData message) {
    final messageTime = getMessageTime(message);
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format message time for display
  static String formatMessageTimeForDisplay(MessageData message) {
    final messageTime = getMessageTime(message);
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    // If message is from today, show time
    if (difference.inDays == 0) {
      return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    }
    // If message is from yesterday, show "Yesterday"
    else if (difference.inDays == 1) {
      return 'Yesterday';
    }
    // If message is from this week, show day name
    else if (difference.inDays < 7) {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[messageTime.weekday - 1];
    }
    // If message is older, show date
    else {
      return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
    }
  }

  /// Check if message is read
  static bool isMessageRead(MessageData message) {
    return message.isRead;
  }

  /// Check if message is unread
  static bool isMessageUnread(MessageData message) {
    return !message.isRead;
  }

  /// Get unread message count
  static int getUnreadMessageCount(List<MessageData> messages, int currentUserId) {
    return messages.where((message) => 
        isToCurrentUser(message, currentUserId) && isMessageUnread(message)
    ).length;
  }

  /// Get last message
  static MessageData? getLastMessage(List<MessageData> messages) {
    if (messages.isEmpty) return null;
    
    final sortedMessages = List<MessageData>.from(messages);
    sortedMessages.sort((a, b) => DateTime.parse(b.sentAt).compareTo(DateTime.parse(a.sentAt)));
    return sortedMessages.first;
  }

  /// Get last message text
  static String getLastMessageText(List<MessageData> messages) {
    final lastMessage = getLastMessage(messages);
    if (lastMessage == null) return 'No messages';
    
    switch (lastMessage.messageType) {
      case MessageType.text:
        return lastMessage.message;
      case MessageType.image:
        return '📷 Image';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.file:
        return '📄 File';
    }
  }

  /// Get last message time
  static String getLastMessageTime(List<MessageData> messages) {
    final lastMessage = getLastMessage(messages);
    if (lastMessage == null) return '';
    
    return formatMessageTimeForDisplay(lastMessage);
  }

  /// Sort messages by time
  static List<MessageData> sortMessagesByTime(List<MessageData> messages) {
    final sortedMessages = List<MessageData>.from(messages);
    sortedMessages.sort((a, b) => DateTime.parse(a.sentAt).compareTo(DateTime.parse(b.sentAt)));
    return sortedMessages;
  }

  /// Sort messages by time (newest first)
  static List<MessageData> sortMessagesByTimeDesc(List<MessageData> messages) {
    final sortedMessages = List<MessageData>.from(messages);
    sortedMessages.sort((a, b) => DateTime.parse(b.sentAt).compareTo(DateTime.parse(a.sentAt)));
    return sortedMessages;
  }

  /// Get messages from specific user
  static List<MessageData> getMessagesFromUser(List<MessageData> messages, int userId) {
    return messages.where((message) => message.senderId == userId).toList();
  }

  /// Get messages to specific user
  static List<MessageData> getMessagesToUser(List<MessageData> messages, int userId) {
    return messages.where((message) => message.receiverId == userId).toList();
  }

  /// Get conversation between two users
  static List<MessageData> getConversation(List<MessageData> messages, int userId1, int userId2) {
    return messages.where((message) => 
        (message.senderId == userId1 && message.receiverId == userId2) ||
        (message.senderId == userId2 && message.receiverId == userId1)
    ).toList();
  }

  /// Check if message is text
  static bool isTextMessage(MessageData message) {
    return message.messageType == MessageType.text;
  }

  /// Check if message is media
  static bool isMediaMessage(MessageData message) {
    return message.messageType != MessageType.text;
  }

  /// Get message preview
  static String getMessagePreview(MessageData message) {
    if (isTextMessage(message)) {
      return message.message.length > 50 
          ? '${message.message.substring(0, 50)}...' 
          : message.message;
    } else {
      switch (message.messageType) {
        case MessageType.image:
          return '📷 Image';
        case MessageType.video:
          return '🎥 Video';
        case MessageType.audio:
          return '🎵 Audio';
        case MessageType.file:
          return '📄 File';
        default:
          return 'Message';
      }
    }
  }
}
