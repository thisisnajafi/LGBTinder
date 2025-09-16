import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/chat_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/chat/chat_list_item.dart';
import '../components/chat/chat_list_header.dart';
import '../components/chat/chat_list_empty.dart';
import '../components/chat/chat_list_loading.dart';
import '../utils/error_handler.dart';
import '../utils/success_feedback.dart';
import '../services/pull_to_refresh_service.dart';
import '../services/skeleton_loader_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  bool _showArchived = false;
  bool _showPinned = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChats({bool refresh = false}) async {
    final chatProvider = context.read<ChatProvider>();
    
    try {
      await chatProvider.loadChats(
        page: 1,
        limit: 20,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        isArchived: _showArchived ? true : null,
        isPinned: _showPinned ? true : null,
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

  Future<void> _loadMoreChats() async {
    if (_isLoadingMore) return;

    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.chats.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await chatProvider.loadChats(
        page: (chatProvider.chats.length ~/ 20) + 1,
        limit: 20,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        isArchived: _showArchived ? true : null,
        isPinned: _showPinned ? true : null,
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

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreChats();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadChats(refresh: true);
  }

  void _onFilterChanged({bool? showArchived, bool? showPinned}) {
    setState(() {
      if (showArchived != null) _showArchived = showArchived;
      if (showPinned != null) _showPinned = showPinned;
    });
    _loadChats(refresh: true);
  }

  void _onChatTap(Chat chat) {
    context.read<ChatProvider>().setCurrentChat(chat);
    Navigator.pushNamed(context, '/chat', arguments: chat);
  }

  void _onNewChat() {
    Navigator.pushNamed(context, '/new-chat');
  }

  Future<void> _onRefresh() async {
    await _loadChats(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navbarBackground,
      body: PullToRefreshService().createRefreshIndicator(
        onRefresh: () => _loadChats(refresh: true),
        child: SafeArea(
          child: Column(
          children: [
            // Header
            ChatListHeader(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              onNewChat: _onNewChat,
              onFilterChanged: _onFilterChanged,
              showArchived: _showArchived,
              showPinned: _showPinned,
            ),
            
            // Chat List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.isLoadingChats && chatProvider.chats.isEmpty) {
                    return const ChatListLoading();
                  }

                  if (chatProvider.chatError != null && chatProvider.chats.isEmpty) {
                    return _buildErrorState(chatProvider.chatError!);
                  }

                  if (chatProvider.chats.isEmpty) {
                    return ChatListEmpty(
                      onRefresh: _onRefresh,
                      searchQuery: _searchQuery,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: chatProvider.chats.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatProvider.chats.length) {
                          return _buildLoadingMore();
                        }

                        final chat = chatProvider.chats[index];
                        return ChatListItem(
                          chat: chat,
                          onTap: () => _onChatTap(chat),
                          onLongPress: () => _showChatOptions(chat),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Failed to load chats',
              style: AppTypography.h6.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.body2.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

     Widget _buildLoadingMore() {
     return Padding(
       padding: const EdgeInsets.all(16),
       child: Center(
         child: CircularProgressIndicator(
           color: AppColors.primaryLight,
         ),
       ),
     );
   }

  void _showChatOptions(Chat chat) {
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
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Options
              ListTile(
                leading: Icon(
                  chat.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: Colors.white,
                ),
                title: Text(
                  chat.isPinned ? 'Unpin chat' : 'Pin chat',
                  style: AppTypography.body2.copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _togglePinChat(chat);
                },
              ),
              
              ListTile(
                leading: Icon(
                  chat.isArchived ? Icons.unarchive : Icons.archive,
                  color: Colors.white,
                ),
                                  title: Text(
                    chat.isArchived ? 'Unarchive chat' : 'Archive chat',
                    style: AppTypography.body2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                onTap: () {
                  Navigator.pop(context);
                  _toggleArchiveChat(chat);
                },
              ),
              
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  'Delete chat',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(chat);
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _togglePinChat(Chat chat) async {
    final chatProvider = context.read<ChatProvider>();
    
    try {
      if (chat.isPinned) {
        await chatProvider.unpinChat(chat.id);
        if (mounted) {
          SuccessFeedback.showSuccessToast(
            context,
            message: 'Chat unpinned',
          );
        }
      } else {
        await chatProvider.pinChat(chat.id);
        if (mounted) {
          SuccessFeedback.showSuccessToast(
            context,
            message: 'Chat pinned',
          );
        }
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

  Future<void> _toggleArchiveChat(Chat chat) async {
    final chatProvider = context.read<ChatProvider>();
    
    try {
      if (chat.isArchived) {
        await chatProvider.unarchiveChat(chat.id);
        if (mounted) {
          SuccessFeedback.showSuccessToast(
            context,
            message: 'Chat unarchived',
          );
        }
      } else {
        await chatProvider.archiveChat(chat.id);
        if (mounted) {
          SuccessFeedback.showSuccessToast(
            context,
            message: 'Chat archived',
          );
        }
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

  void _showDeleteConfirmation(Chat chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Chat',
          style: AppTypography.h6.copyWith(
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this chat? This action cannot be undone.',
          style: AppTypography.body2.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChat(chat);
            },
            child: Text(
              'Delete',
              style: AppTypography.button.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChat(Chat chat) async {
    final chatProvider = context.read<ChatProvider>();
    
    try {
      await chatProvider.deleteChat(chat.id);
      if (mounted) {
        SuccessFeedback.showSuccessToast(
          context,
          message: 'Chat deleted',
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
}
