import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/api_services/discovery_api_service.dart';
import '../../services/token_management_service.dart';
import '../../services/cache_service.dart';
import '../../services/skeleton_loader_service.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<User> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  bool _showHistory = true;
  String _error = '';
  
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchFocusNode.requestFocus();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadSearchHistory() async {
    final history = await CacheService.getData('search_history');
    if (history != null && history is List) {
      setState(() {
        _searchHistory = history.cast<String>();
      });
    }
  }
  
  Future<void> _saveSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    // Add to history (max 10 items)
    final history = List<String>.from(_searchHistory);
    history.remove(query); // Remove if exists
    history.insert(0, query); // Add to top
    if (history.length > 10) {
      history.removeRange(10, history.length);
    }
    
    setState(() {
      _searchHistory = history;
    });
    
    await CacheService.setData(
      'search_history',
      history,
    );
  }
  
  Future<void> _clearSearchHistory() async {
    setState(() {
      _searchHistory.clear();
    });
    await CacheService.removeData('search_history');
  }
  
  void _onSearchChanged(String query) {
    // Debounce search
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _showHistory = true;
        _searchResults.clear();
        _error = '';
      });
      return;
    }
    
    setState(() {
      _showHistory = false;
      _isSearching = true;
      _error = '';
    });
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }
  
  Future<void> _performSearch(String query) async {
    try {
      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        setState(() {
          _error = 'Not authenticated';
          _isSearching = false;
        });
        return;
      }
      
      final result = await DiscoveryApiService.searchUsers(
        token: token,
        query: query,
      );
      
      if (result['success'] == true) {
        setState(() {
          _searchResults = result['results'] as List<User>;
          _isSearching = false;
        });
        
        // Save to history
        await _saveSearchHistory(query);
      } else {
        setState(() {
          _error = result['error'] as String? ?? 'Search failed';
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isSearching = false;
      });
    }
  }
  
  void _onHistoryItemTap(String query) {
    _searchController.text = query;
    _performSearch(query);
  }
  
  void _onUserTap(User user) {
    // Navigate to profile detail
    Navigator.pushNamed(
      context,
      '/profile-detail',
      arguments: {'userId': user.id.toString()},
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search by name or username...',
            hintStyle: AppTypography.body1.copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_showHistory) {
      return _buildSearchHistory();
    } else if (_isSearching) {
      return _buildLoadingState();
    } else if (_error.isNotEmpty) {
      return _buildErrorState();
    } else if (_searchResults.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildSearchResults();
    }
  }
  
  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Search for people',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find matches by name or username',
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _clearSearchHistory,
                child: Text(
                  'Clear',
                  style: AppTypography.body2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final query = _searchHistory[index];
              return ListTile(
                leading: const Icon(Icons.history, color: AppColors.textSecondary),
                title: Text(
                  query,
                  style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_outward, color: AppColors.textSecondary, size: 20),
                  onPressed: () => _onHistoryItemTap(query),
                ),
                onTap: () => _onHistoryItemTap(query),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              SkeletonLoaderService.createSkeletonCircle(size: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoaderService.createSkeletonLine(width: 150),
                    const SizedBox(height: 8),
                    SkeletonLoaderService.createSkeletonLine(width: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
            'Search Error',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: AppTypography.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserCard(user);
      },
    );
  }
  
  Widget _buildUserCard(User user) {
    return GestureDetector(
      onTap: () => _onUserTap(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: user.avatarUrl == null
                  ? Icon(
                      Icons.person,
                      size: 30,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName,
                          style: AppTypography.heading4.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified ?? false) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.age} years old',
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.bio!,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

