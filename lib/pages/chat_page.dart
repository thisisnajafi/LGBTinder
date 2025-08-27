import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/models.dart';
import '../providers/chat_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/chat/chat_header.dart';
import '../components/chat/message_bubble.dart';
import '../components/chat/message_input.dart';
import '../components/chat/typing_indicator.dart';
import '../utils/error_handler.dart';
import '../utils/success_feedback.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({
    Key? key,
    required this.chat,
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

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markChatAsRead();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages({bool refresh = false}) async {
    final chatProvider = context.read<ChatProvider>();
    
    try {
      await chatProvider.loadMessages(
        widget.chat.id,
        page: 1,
        limit: 50,
        refresh: refresh,
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;

    final chatProvider = context.read<ChatProvider>();
    final messages = chatProvider.getMessages(widget.chat.id);
    if (messages.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await chatProvider.loadMessages(
        widget.chat.id,
        page: (messages.length ~/ 50) + 1,
        limit: 50,
        beforeMessageId: messages.first.id,
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.getErrorMessage(e),
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
    final chatProvider = context.read<ChatProvider>();
    try {
      await chatProvider.markChatAsRead(widget.chat.id);
      await chatProvider.markAllMessagesAsRead(widget.chat.id);
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
    final chatProvider = context.read<ChatProvider>();
    
    // Cancel previous timer
    _typingTimer?.cancel();
    
    if (text.isNotEmpty && !_isTyping) {
      setState(() {
        _isTyping = true;
      });
      chatProvider.updateTypingIndicator(widget.chat.id, 'currentUserId', true);
    }
    
    // Set timer to stop typing indicator
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        chatProvider.updateTypingIndicator(widget.chat.id, 'currentUserId', false);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    
    try {
      // Clear input
      _messageController.clear();
      
      // Stop typing indicator
      setState(() {
        _isTyping = false;
      });
      chatProvider.updateTypingIndicator(widget.chat.id, 'currentUserId', false);
      _typingTimer?.cancel();
      
      // Send message
      await chatProvider.sendTextMessage(widget.chat.id, text);
      
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
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  Future<void> _sendMediaMessage(MessageType type, List<MessageAttachment> attachments, {String? content}) async {
    final chatProvider = context.read<ChatProvider>();
    
    try {
      await chatProvider.sendMediaMessage(
        widget.chat.id,
        type,
        attachments,
        content: content,
      );
      
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
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  void _onMessageLongPress(Message message) {
    _showMessageOptions(message);
  }

  void _showMessageOptions(Message message) {
    final isOwnMessage = message.senderId == 'currentUserId'; // Replace with actual current user ID
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Options
              if (isOwnMessage) ...[
                ListTile(
                  leading: const Icon(Icons.edit, color: AppColors.textPrimary),
                  title: Text(
                    'Edit',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _editMessage(message);
                  },
                ),
              ],
              
              ListTile(
                leading: const Icon(Icons.reply, color: AppColors.textPrimary),
                title: Text(
                  'Reply',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _replyToMessage(message);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.forward, color: AppColors.textPrimary),
                title: Text(
                  'Forward',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
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

  void _editMessage(Message message) {
    // TODO: Implement message editing
    SuccessFeedback.showInfoToast(
      context,
      message: 'Message editing coming soon!',
    );
  }

  void _replyToMessage(Message message) {
    // TODO: Implement message reply
    SuccessFeedback.showInfoToast(
      context,
      message: 'Message reply coming soon!',
    );
  }

  void _forwardMessage(Message message) {
    // TODO: Implement message forwarding
    SuccessFeedback.showInfoToast(
      context,
      message: 'Message forwarding coming soon!',
    );
  }

  Future<void> _deleteMessage(Message message) async {
    final chatProvider = context.read<ChatProvider>();
    
    try {
      await chatProvider.deleteMessage(widget.chat.id, message.id);
      if (mounted) {
        SuccessFeedback.showSuccessToast(
          context,
          message: 'Message deleted',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          message: ErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            ChatHeader(
              chat: widget.chat,
              onBackPressed: () => Navigator.pop(context),
              onInfoPressed: () => _showChatInfo(),
              onCallPressed: () => _initiateCall(),
            ),
            
            // Messages
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  final messages = chatProvider.getMessages(widget.chat.id);
                  final isLoading = chatProvider.isLoadingMessages(widget.chat.id);
                  
                  if (isLoading && messages.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  return Column(
                    children: [
                      // Loading more indicator
                      if (_isLoadingMore)
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: const CircularProgressIndicator(),
                        ),
                      
                      // Messages list
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isOwnMessage = message.senderId == 'currentUserId'; // Replace with actual current user ID
                            
                            return MessageBubble(
                              message: message,
                              isOwnMessage: isOwnMessage,
                              onLongPress: () => _onMessageLongPress(message),
                            );
                          },
                        ),
                      ),
                      
                      // Typing indicator
                      TypingIndicator(
                        chatId: widget.chat.id,
                        currentUserId: 'currentUserId', // Replace with actual current user ID
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Message input
            MessageInput(
              controller: _messageController,
              onMessageChanged: _onMessageChanged,
              onSendPressed: _sendMessage,
              onAttachmentPressed: _showAttachmentOptions,
            ),
          ],
        ),
      ),
    );
  }

  void _showChatInfo() {
    Navigator.pushNamed(context, '/chat-info', arguments: widget.chat);
  }

  void _initiateCall() {
    // TODO: Implement call initiation
    SuccessFeedback.showInfoToast(
      context,
      message: 'Call feature coming soon!',
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Attachment options
              ListTile(
                leading: const Icon(Icons.photo, color: AppColors.textPrimary),
                title: Text(
                  'Photo',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.videocam, color: AppColors.textPrimary),
                title: Text(
                  'Video',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.mic, color: AppColors.textPrimary),
                title: Text(
                  'Voice Message',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _recordVoiceMessage();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.attach_file, color: AppColors.textPrimary),
                title: Text(
                  'Document',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
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

  void _pickImage() {
    // TODO: Implement image picking
    SuccessFeedback.showInfoToast(
      context,
      message: 'Image picking coming soon!',
    );
  }

  void _pickVideo() {
    // TODO: Implement video picking
    SuccessFeedback.showInfoToast(
      context,
      message: 'Video picking coming soon!',
    );
  }

  void _recordVoiceMessage() {
    // TODO: Implement voice recording
    SuccessFeedback.showInfoToast(
      context,
      message: 'Voice recording coming soon!',
    );
  }

  void _pickDocument() {
    // TODO: Implement document picking
    SuccessFeedback.showInfoToast(
      context,
      message: 'Document picking coming soon!',
    );
  }
}
