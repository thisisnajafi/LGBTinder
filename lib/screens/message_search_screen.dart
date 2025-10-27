import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_services/chat_search_api_service.dart';
import '../services/token_management_service.dart';

/// Message Search Screen
/// 
/// Search messages within a chat or across all chats
class MessageSearchScreen extends StatefulWidget {
  final String? chatId; // If null, search across all chats
  final String? chatName;

  const MessageSearchScreen({
    Key? key,
    this.chatId,
    this.chatName,
  }) : super(key: key);

  @override
  State<MessageSearchScreen> createState() => _MessageSearchScreenState();
}

class _MessageSearchScreenState extends State<MessageSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  List<SearchMessageResult> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final token = await TokenManagementService.getAccessToken();
    if (token == null) return;

    final recent = await ChatSearchApiService.getRecentSearches(token: token);
    setState(() {
      _recentSearches = recent;
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = widget.chatId != null
          ? await ChatSearchApiService.searchInChat(
              chatId: widget.chatId!,
              query: query,
              token: token,
            )
          : await ChatSearchApiService.searchAllChats(
              query: query,
              token: token,
            );

      setState(() {
        _searchResults = response.messages;
        _hasSearched = true;
        _isLoading = false;
        if (!response.success) {
          _error = response.error;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Search failed: ${e.toString()}';
      });
    }
  }

  Future<void> _clearSearchHistory() async {
    final token = await TokenManagementService.getAccessToken();
    if (token == null) return;

    final success = await ChatSearchApiService.clearSearchHistory(token: token);
    if (success) {
      setState(() {
        _recentSearches = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          style: AppTypography.body1.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.chatId != null
                ? 'Search in ${widget.chatName ?? "this chat"}...'
                : 'Search messages...',
            hintStyle: AppTypography.body1.copyWith(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _hasSearched = false;
                      });
                    },
                    icon: const Icon(Icons.clear, color: Colors.white54),
                  )
                : null,
          ),
          onChanged: (query) {
            setState(() {});
            if (query.isNotEmpty) {
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchController.text == query) {
                  _performSearch(query);
                }
              });
            }
          },
          onSubmitted: _performSearch,
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.body1.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return _buildRecentSearches();
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages found',
              style: AppTypography.body1.copyWith(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return _buildSearchResults();
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              color: Colors.white54,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Search messages',
              style: AppTypography.h4.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Find messages by keyword',
              style: AppTypography.body2.copyWith(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _clearSearchHistory,
                child: Text(
                  'Clear',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final query = _recentSearches[index];
              return ListTile(
                leading: const Icon(
                  Icons.history,
                  color: Colors.white54,
                ),
                title: Text(
                  query,
                  style: AppTypography.body1.copyWith(color: Colors.white),
                ),
                onTap: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultItem(result);
      },
    );
  }

  Widget _buildSearchResultItem(SearchMessageResult result) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: result.senderAvatar != null
            ? NetworkImage(result.senderAvatar!)
            : null,
        child: result.senderAvatar == null
            ? Text(
                result.senderName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              result.senderName,
              style: AppTypography.body1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.chatId == null) ...[
            const SizedBox(width: 8),
            Text(
              result.chatName,
              style: AppTypography.body2.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ],
      ),
      subtitle: _buildHighlightedText(result),
      trailing: Text(
        _formatTimestamp(result.timestamp),
        style: AppTypography.body2.copyWith(
          color: Colors.white54,
        ),
      ),
      onTap: () {
        // Navigate to message in chat
        Navigator.pop(context, result);
      },
    );
  }

  Widget _buildHighlightedText(SearchMessageResult result) {
    // Simple implementation - in production, use TextSpan for proper highlighting
    return Text(
      result.content,
      style: AppTypography.body2.copyWith(
        color: Colors.white70,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

