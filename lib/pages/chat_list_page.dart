import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_models/chat_models.dart';
import '../models/api_models/user_models.dart';
import '../models/user.dart';
import '../models/api_models/matching_models.dart';
import '../providers/chat_state_provider.dart';
import '../providers/matching_state_provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../components/chat/chat_list_item.dart';
import '../components/chat/chat_list_header.dart';
import '../components/chat/chat_list_empty.dart';
import '../components/chat/chat_list_loading.dart';
import '../components/error_handling/error_display_widget.dart';
import '../components/error_handling/error_snackbar.dart';
import '../components/loading/loading_widgets.dart';
import '../components/loading/skeleton_loader.dart';
import '../components/offline/offline_wrapper.dart';
import '../components/real_time/real_time_listener.dart';
import '../services/analytics_service.dart';
import '../services/error_monitoring_service.dart';

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
  List<User> _matches = []; // Changed from List<Match> - Chat list shows matched users
  bool _isLoadingMatches = true;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoadingMatches = true;
      _error = null;
    });
    
    try {
      await AnalyticsService.trackEvent(
        name: 'chat_list_load_matches',
        action: 'chat_list_load_matches',
        category: 'chat',
      );

      final matchingProvider = context.read<MatchingStateProvider>();
      await matchingProvider.loadMatches();
      
      setState(() {
        _matches = matchingProvider.matches.map((match) {
          // Handle different match types safely
          if (match is MatchData) {
            // Convert MatchUser to User
            return User(
              id: match.user.id,
              firstName: match.user.name.split(' ').first,
              lastName: match.user.name.split(' ').length > 1 ? match.user.name.split(' ').last : '',
              fullName: match.user.name,
              email: '', // MatchUser doesn't have email
              avatarUrl: match.user.avatarUrl,
              createdAt: DateTime.now(), // MatchUser doesn't have createdAt
              updatedAt: DateTime.now(), // MatchUser doesn't have updatedAt
            );
          } else if (match is User) {
            return match;
          } else {
            // Create a default user if match structure is unexpected
            return User(
              id: 1,
              firstName: 'Unknown',
              lastName: 'User',
              fullName: 'Unknown User',
              email: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }).cast<User>().toList();
        _isLoadingMatches = false;
      });
    } catch (e) {
      await AnalyticsService.trackEvent(
        name: 'chat_list_load_matches_failed',
        action: 'chat_list_load_matches_failed',
        category: 'chat',
      );

      await ErrorMonitoringService.logError(
        message: e.toString(),
        context: {'operation': 'ChatListPage._loadMatches'},
      );

      setState(() {
        _isLoadingMatches = false;
        _error = e;
      });
    }
  }

  Future<void> _loadMoreMatches() async {
    if (_isLoadingMore) return;

    final matchingProvider = context.read<MatchingStateProvider>();
    if (matchingProvider.matches.isEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await matchingProvider.loadMoreMatches();
      setState(() {
        _matches = matchingProvider.matches.map((match) {
          // Handle different match types safely
          if (match is MatchData) {
            // Convert MatchUser to User
            return User(
              id: match.user.id,
              firstName: match.user.name.split(' ').first,
              lastName: match.user.name.split(' ').length > 1 ? match.user.name.split(' ').last : '',
              fullName: match.user.name,
              email: '', // MatchUser doesn't have email
              avatarUrl: match.user.avatarUrl,
              createdAt: DateTime.now(), // MatchUser doesn't have createdAt
              updatedAt: DateTime.now(), // MatchUser doesn't have updatedAt
            );
          } else if (match is User) {
            return match;
          } else {
            // Create a default user if match structure is unexpected
            return User(
              id: 1,
              firstName: 'Unknown',
              lastName: 'User',
              fullName: 'Unknown User',
              email: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }).cast<User>().toList();
      });
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          error: e,
          errorContext: 'load_more_matches',
          onAction: _loadMoreMatches,
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

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMatches();
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterMatches();
  }

  void _onFilterChanged({bool? showArchived, bool? showPinned}) {
    setState(() {
      if (showArchived != null) _showArchived = showArchived;
      if (showPinned != null) _showPinned = showPinned;
    });
    _filterMatches();
  }

  void _onMatchTap(User match) {
    // Navigate to chat with this match
    Navigator.pushNamed(context, '/chat', arguments: match);
  }

  void _onNewChat() {
    // Show new chat options
    _showNewChatOptions();
  }

  Future<void> _onRefresh() async {
    await _loadMatches();
  }

  void _filterMatches() {
    // Filter matches based on search query
    // This would be implemented based on the actual filtering requirements
  }

  void _showNewChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
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
              
              // Options
              ListTile(
                leading: const Icon(
                  Icons.person_add,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Start New Chat',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to matches to start a new chat
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: AppTypography.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: AppColors.textPrimary,
            ),
            onPressed: _onNewChat,
          ),
        ],
      ),
      body: OfflineWrapper(
        child: RealTimeListener(
          eventTypes: ['message', 'match'],
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingMatches) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_matches.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMatchesList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonCard(
            height: 80,
          ),
          const SizedBox(height: 16),
          SkeletonCard(
            height: 80,
          ),
          const SizedBox(height: 16),
          SkeletonCard(
            height: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return ErrorDisplayWidget(
      error: _error,
      context: 'load_matches',
      onRetry: _loadMatches,
      isFullScreen: true,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No matches yet',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start swiping to find your perfect match!',
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/discovery');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Swiping'),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _matches.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _matches.length) {
            return _buildLoadingMore();
          }

          final match = _matches[index];
          return _buildMatchListItem(match);
        },
      ),
    );
  }

  Widget _buildMatchListItem(User match) {
    return Consumer<ChatStateProvider>(
      builder: (context, chatProvider, child) {
        final messages = chatProvider.getMessagesForUser(match.id);
        final lastMessage = messages.isNotEmpty ? messages.last : null;
        final unreadCount = messages.where((msg) => !msg.isRead && msg.senderId != match.id).length;

        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: match.avatarUrl != null
                ? NetworkImage(match.avatarUrl!)
                : null,
            child: match.avatarUrl == null
                ? Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          title: Text(
            match.fullName,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          subtitle: lastMessage != null
              ? Text(
                  lastMessage.message,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : Text(
                  'Start a conversation',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (lastMessage != null)
                Text(
                  _formatTime(lastMessage.sentAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => _onMatchTap(match),
        );
      },
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _formatTime(String sentAt) {
    try {
      final dateTime = DateTime.parse(sentAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'now';
      }
    } catch (e) {
      return 'now';
    }
  }

}
