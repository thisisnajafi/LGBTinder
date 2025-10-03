import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/api_models/chat_models.dart';
import '../models/api_models/user_models.dart';
import '../models/message_attachment.dart';
import '../providers/chat_state_provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/websocket_state_provider.dart';
import '../services/websocket_service.dart';
import '../services/media_picker_service.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/chat/chat_header.dart';
import '../components/chat/message_bubble.dart';
import '../components/chat/message_input.dart';
import '../components/chat/typing_indicator.dart';
import '../components/error_handling/error_snackbar.dart';
import '../components/loading/loading_widgets.dart';
import '../components/offline/offline_wrapper.dart';
import '../components/real_time/real_time_listener.dart';
import '../services/analytics_service.dart';
import '../services/error_monitoring_service.dart';

class ChatPage extends StatefulWidget {
  final User match;

  const ChatPage({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  
  bool _isLoadingMore = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  List<MessageData> _messages = [];
  bool _isLoading = true;
  dynamic _error;
  
  // WebSocket integration
  late WebSocketService _webSocketService;
  late WebSocketStateProvider _webSocketProvider;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  bool _isOtherUserTyping = false;
  
  // Message actions
  MessageData? _replyToMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _loadMessages();
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onMessageChanged);
  }
  
  void _initializeWebSocket() {
    _webSocketService = WebSocketService();
    _webSocketProvider = context.read<WebSocketStateProvider>();
    
    // Join chat room
    _webSocketService.joinChatRoom(widget.match.id.toString());
    
    // Listen for new messages
    _messageSubscription = _webSocketService.messageStream.listen((data) {
      if (data['chatId'] == widget.match.id.toString()) {
        _handleNewMessage(data);
      }
    });
    
    // Listen for typing indicators
    _typingSubscription = _webSocketService.typingStream.listen((data) {
      if (data['chatId'] == widget.match.id.toString()) {
        _handleTypingIndicator(data);
      }
    });
  }
  
  void _handleNewMessage(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        _messages = _webSocketProvider.getMessagesForUser(widget.match.id);
      });
      
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  
  void _handleTypingIndicator(Map<String, dynamic> data) {
    if (mounted) {
      setState(() {
        _isOtherUserTyping = data['isTyping'] == true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _typingTimer?.cancel();
    
    // Clean up WebSocket subscriptions
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _webSocketService.leaveChatRoom(widget.match.id.toString());
    
    super.dispose();
  }

  Future<void> _loadMessages({bool refresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await AnalyticsService.trackEvent(
        action: 'chat_load_messages',
        category: 'chat',
        properties: {'match_id': widget.match.id},
      );

      final chatProvider = context.read<ChatStateProvider>();
      await chatProvider.loadChatHistory(widget.match.id);
      
      setState(() {
        _messages = chatProvider.getMessagesForUser(widget.match.id);
        _isLoading = false;
      });
    } catch (e) {
      await AnalyticsService.trackEvent(
        action: 'chat_load_messages_failed',
        category: 'chat',
      );

      await ErrorMonitoringService.logError(
        error: e,
        context: 'ChatPage._loadMessages',
      );

      setState(() {
        _isLoading = false;
        _error = e;
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;

    final chatProvider = context.read<ChatStateProvider>();
    if (!chatProvider.hasMoreMessagesForUser(widget.match.id)) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final pagination = chatProvider.getPaginationData(widget.match.id);
      if (pagination != null) {
        await chatProvider.loadChatHistory(
          widget.match.id,
          page: pagination.currentPage + 1,
        );
        
        setState(() {
          _messages = chatProvider.getMessagesForUser(widget.match.id);
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'load_more_messages',
          onAction: _loadMoreMessages,
          actionText: 'Retry',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _markChatAsRead() async {
    final chatProvider = context.read<ChatStateProvider>();
    try {
      chatProvider.markMessagesAsRead(widget.match.id);
      
      // Also mark as read via WebSocket
      for (final message in _messages) {
        if (!message.isRead && message.senderId != widget.match.id) {
          _webSocketService.markMessageAsRead(
            messageId: message.messageId.toString(),
            chatId: widget.match.id.toString(),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking chat as read: $e');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 200) {
      _loadMoreMessages();
    }
  }

  void _onMessageChanged(String text) {
    // Cancel previous timer
    _typingTimer?.cancel();
    
    if (text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      // Send typing indicator via WebSocket
      _webSocketService.sendTypingIndicator(
        chatId: widget.match.id.toString(),
        isTyping: true,
      );
    }
    
    // Set timer to stop typing indicator
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        // Stop typing indicator via WebSocket
        _webSocketService.sendTypingIndicator(
          chatId: widget.match.id.toString(),
          isTyping: false,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatStateProvider>();
    
    try {
      await AnalyticsService.trackEvent(
        action: 'message_send',
        category: 'chat',
        properties: {'match_id': widget.match.id},
      );

      // Clear input
      _messageController.clear();
      
      // Stop typing indicator
      setState(() {
        _isTyping = false;
      });
      _typingTimer?.cancel();
      
      // Send typing stop indicator
      _webSocketService.sendTypingIndicator(
        chatId: widget.match.id.toString(),
        isTyping: false,
      );
      
      // Send message via WebSocket for real-time delivery
      _webSocketService.sendMessage(
        chatId: widget.match.id.toString(),
        message: text,
        messageType: 'text',
      );
      
      // Also send via API for persistence
      final success = await chatProvider.sendMessage(widget.match.id, text);
      
      if (success) {
        // Update local messages
        setState(() {
          _messages = chatProvider.getMessagesForUser(widget.match.id);
        });
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            error: Exception('Failed to send message'),
            context: 'send_message',
            onAction: _sendMessage,
            actionText: 'Retry',
          );
        }
      }
    } catch (e) {
      await AnalyticsService.trackEvent(
        action: 'message_send_failed',
        category: 'chat',
      );

      await ErrorMonitoringService.logError(
        error: e,
        context: 'ChatPage._sendMessage',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'send_message',
          onAction: _sendMessage,
          actionText: 'Retry',
        );
      }
    }
  }

  Future<void> _sendMediaMessage(MessageType type, List<MessageAttachment> attachments, {String? content}) async {
    final chatProvider = context.read<ChatStateProvider>();
    
    try {
      await AnalyticsService.trackEvent(
        action: 'media_message_send',
        category: 'chat',
        properties: {
          'match_id': widget.match.id,
          'message_type': type.toString(),
          'attachment_count': attachments.length,
        },
      );

      // Send media message via WebSocket for real-time delivery
      for (final attachment in attachments) {
        _webSocketService.sendMessage(
          chatId: widget.match.id.toString(),
          message: content ?? '',
          messageType: type.toString().split('.').last,
          metadata: {
            'attachment': {
              'id': attachment.id,
              'type': attachment.type.toString().split('.').last,
              'url': attachment.url,
              'filename': attachment.filename,
              'size': attachment.size,
              'duration': attachment.duration?.inMilliseconds,
              'width': attachment.width,
              'height': attachment.height,
            }
          },
        );
      }
      
      // Also send via API for persistence
      final success = await chatProvider.sendMediaMessage(
        widget.match.id.toString(),
        type,
        attachments,
        content: content,
      );
      
      if (success) {
        // Update local messages
        setState(() {
          _messages = chatProvider.getMessagesForUser(widget.match.id);
        });
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            error: Exception('Failed to send media message'),
            context: 'send_media_message',
            onAction: () => _sendMediaMessage(type, attachments, content: content),
            actionText: 'Retry',
          );
        }
      }
    } catch (e) {
      await AnalyticsService.trackEvent(
        action: 'media_message_send_failed',
        category: 'chat',
      );

      await ErrorMonitoringService.logError(
        error: e,
        context: 'ChatPage._sendMediaMessage',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'send_media_message',
          onAction: () => _sendMediaMessage(type, attachments, content: content),
          actionText: 'Retry',
        );
      }
    }
  }

  void _onMessageLongPress(MessageData message) {
    _showMessageOptions(message);
  }

  void _showMessageOptions(MessageData message) {
    final appState = context.read<AppStateProvider>();
    final isOwnMessage = message.senderId == appState.user?.id;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.navbarBackground,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Options
              if (isOwnMessage) ...[
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: Text(
                    'Edit',
                    style: AppTypography.body2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                ),
              ],
              
                              ListTile(
                  leading: const Icon(Icons.reply, color: Colors.white),
                  title: Text(
                    'Reply',
                    style: AppTypography.body2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                onTap: () {
                  Navigator.pop(context);
                  _replyToMessage(message);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.forward, color: Colors.white),
                title: Text(
                  'Forward',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _forwardMessage(message);
                },
              ),
              
              if (isOwnMessage) ...[
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text(
                    'Delete',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message);
                  },
                ),
              ],
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _editMessage(MessageData message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Edit Message',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: TextEditingController(text: message.message),
          style: AppTypography.body1.copyWith(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Edit your message...',
            hintStyle: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
              ),
            ),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newText = (context as Element).findAncestorStateOfType<_ChatPageState>()?._messageController.text;
              if (newText != null && newText.isNotEmpty) {
                Navigator.pop(context);
                await _updateMessage(message, newText);
              }
            },
            child: Text(
              'Save',
              style: AppTypography.body1.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMessage(MessageData message, String newText) async {
    final chatProvider = context.read<ChatStateProvider>();
    
    try {
      await AnalyticsService.trackEvent(
        action: 'message_edit',
        category: 'chat',
        properties: {
          'match_id': widget.match.id,
          'message_id': message.messageId,
        },
      );

      // Update message via WebSocket for real-time delivery
      _webSocketService.sendMessage(
        chatId: widget.match.id.toString(),
        message: newText,
        messageType: 'edit',
        metadata: {
          'original_message_id': message.messageId,
          'action': 'edit',
        },
      );

      // Also update via API for persistence
      final success = await chatProvider.editMessage(
        widget.match.id.toString(),
        message.messageId.toString(),
        newText,
      );

      if (success) {
        // Update local messages
        setState(() {
          _messages = chatProvider.getMessagesForUser(widget.match.id);
        });
      } else {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            error: Exception('Failed to edit message'),
            context: 'edit_message',
            onAction: () => _updateMessage(message, newText),
            actionText: 'Retry',
          );
        }
      }
    } catch (e) {
      await AnalyticsService.trackEvent(
        action: 'message_edit_failed',
        category: 'chat',
      );

      await ErrorMonitoringService.logError(
        error: e,
        context: 'ChatPage._updateMessage',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'edit_message',
          onAction: () => _updateMessage(message, newText),
          actionText: 'Retry',
        );
      }
    }
  }

  void _replyToMessage(MessageData message) {
    // Set the message to reply to
    setState(() {
      _replyToMessage = message;
    });

    // Focus on the message input
    _messageController.clear();
    _messageController.text = 'Replying to: ${message.message}...\n';
    
    // Show reply indicator
    ErrorSnackBar.showInfo(
      context,
      message: 'Replying to message. Type your reply below.',
    );
  }

  void _forwardMessage(MessageData message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Forward Message',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select a contact to forward this message to:',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: Implement contact selection list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Contact selection coming soon!',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ErrorSnackBar.showInfo(
                context,
                message: 'Message forwarding feature coming soon!',
              );
            },
            child: Text(
              'Forward',
              style: AppTypography.body1.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMessage(MessageData message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Delete Message',
          style: AppTypography.heading3.copyWith(
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
          style: AppTypography.body1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: AppTypography.body1.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final chatProvider = context.read<ChatStateProvider>();
      
      try {
        await AnalyticsService.trackEvent(
          action: 'message_delete',
          category: 'chat',
          properties: {
            'match_id': widget.match.id,
            'message_id': message.messageId,
          },
        );

        // Delete message via WebSocket for real-time delivery
        _webSocketService.sendMessage(
          chatId: widget.match.id.toString(),
          message: '',
          messageType: 'delete',
          metadata: {
            'message_id': message.messageId,
            'action': 'delete',
          },
        );

        // Also delete via API for persistence
        final success = await chatProvider.deleteMessage(
          widget.match.id.toString(),
          message.messageId.toString(),
        );

        if (success) {
          // Update local messages
          setState(() {
            _messages = chatProvider.getMessagesForUser(widget.match.id);
          });
          
          ErrorSnackBar.showInfo(
            context,
            message: 'Message deleted successfully',
          );
        } else {
          if (mounted) {
            ErrorSnackBar.show(
              context,
              error: Exception('Failed to delete message'),
              context: 'delete_message',
              onAction: () => _deleteMessage(message),
              actionText: 'Retry',
            );
          }
        }
      } catch (e) {
        await AnalyticsService.trackEvent(
          action: 'message_delete_failed',
          category: 'chat',
        );

        await ErrorMonitoringService.logError(
          error: e,
          context: 'ChatPage._deleteMessage',
        );

        if (mounted) {
          ErrorSnackBar.show(
            context,
            error: e,
            context: 'delete_message',
            onAction: () => _deleteMessage(message),
            actionText: 'Retry',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.match.profilePictures.isNotEmpty
                  ? NetworkImage(widget.match.profilePictures.first)
                  : null,
              child: widget.match.profilePictures.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              '${widget.match.firstName} ${widget.match.lastName}',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppColors.textPrimary,
            ),
            onPressed: _showMatchInfo,
          ),
        ],
      ),
      body: OfflineWrapper(
        child: RealTimeListener(
          eventTypes: ['message', 'typing'],
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return _buildMessagesList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: LoadingWidgets.fullScreen(
        text: 'Loading messages...',
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load messages',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Column(
      children: [
        // Loading more indicator
        if (_isLoadingMore)
          Container(
            padding: const EdgeInsets.all(8),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final appState = context.read<AppStateProvider>();
              final isOwnMessage = message.senderId == appState.user?.id;
              
              return _buildMessageBubble(message, isOwnMessage);
            },
          ),
        ),
        
        // Typing indicator
        if (_isOtherUserTyping)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  '${widget.match.firstName} is typing...',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        
        // Message input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(MessageData message, bool isOwnMessage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isOwnMessage) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.match.profilePictures.isNotEmpty
                  ? NetworkImage(widget.match.profilePictures.first)
                  : null,
              child: widget.match.profilePictures.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isOwnMessage ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: AppTypography.body1.copyWith(
                      color: isOwnMessage ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.sentAt),
                    style: AppTypography.caption.copyWith(
                      color: isOwnMessage ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOwnMessage) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Icon(
                Icons.person,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _showAttachmentOptions,
            icon: const Icon(
              Icons.attach_file,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: _onMessageChanged,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: AppTypography.body1.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(
              Icons.send,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Attachment options
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.white),
                title: Text(
                  'Photo',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.videocam, color: Colors.white),
                title: Text(
                  'Video',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.mic, color: Colors.white),
                title: Text(
                  'Voice Message',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _recordVoiceMessage();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.white),
                title: Text(
                  'Document',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocument();
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showMatchInfo() {
    // TODO: Show match profile info
    ErrorSnackBar.showInfo(
      context,
      message: 'Match info coming soon!',
    );
  }

  String _formatMessageTime(String sentAt) {
    try {
      final dateTime = DateTime.parse(sentAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'now';
      }
    } catch (e) {
      return 'now';
    }
  }

  // Media picker methods
  Future<void> _pickImage() async {
    try {
      final mediaPickerService = MediaPickerService();
      final image = await mediaPickerService.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final attachment = MessageAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: AttachmentType.image,
          url: image.path,
          localPath: image.path,
          filename: image.path.split('/').last,
          size: await image.length(),
        );

        await _sendMediaMessage(MessageType.image, [attachment]);
      }
    } catch (e) {
      await ErrorMonitoringService.logError(
        error: e,
        context: 'ChatPage._pickImage',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'pick_image',
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final mediaPickerService = MediaPickerService();
      final video = await mediaPickerService.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        final attachment = MessageAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: AttachmentType.video,
          url: video.path,
          localPath: video.path,
          filename: video.path.split('/').last,
          size: await video.length(),
        );

        await _sendMediaMessage(MessageType.video, [attachment]);
      }
    } catch (e) {
      await ErrorMonitoringService.logError(
        error: e,
        context: 'ChatPage._pickVideo',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'pick_video',
        );
      }
    }
  }

  Future<void> _recordVoiceMessage() async {
    try {
      final mediaPickerService = MediaPickerService();
      final audio = await mediaPickerService.recordAudio(
        maxDuration: const Duration(minutes: 2),
      );

      if (audio != null) {
        final attachment = MessageAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: AttachmentType.voice,
          url: audio.path,
          localPath: audio.path,
          filename: audio.path.split('/').last,
          size: await audio.length(),
        );

        await _sendMediaMessage(MessageType.voice, [attachment]);
      }
    } catch (e) {
      await ErrorMonitoringService.logError(
        error: e,
        context: 'ChatPage._recordVoiceMessage',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'record_voice',
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final attachment = MessageAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: AttachmentType.file,
          url: file.path ?? '',
          localPath: file.path,
          filename: file.name,
          size: file.size,
        );

        await _sendMediaMessage(MessageType.file, [attachment]);
      }
    } catch (e) {
      await ErrorMonitoringService.logError(
        error: e,
        context: 'ChatPage._pickDocument',
      );

      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          context: 'pick_document',
        );
      }
    }
  }
}
