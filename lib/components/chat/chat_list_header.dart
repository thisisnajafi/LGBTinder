import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ChatListHeader extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNewChat;
  final Function({bool? showArchived, bool? showPinned}) onFilterChanged;
  final bool showArchived;
  final bool showPinned;

  const ChatListHeader({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onNewChat,
    required this.onFilterChanged,
    required this.showArchived,
    required this.showPinned,
  }) : super(key: key);

  @override
  State<ChatListHeader> createState() => _ChatListHeaderState();
}

class _ChatListHeaderState extends State<ChatListHeader> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navbarBackground,
      child: Column(
        children: [
          // Main header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Title
                Expanded(
                  child: Text(
                    'Messages',
                    style: AppTypography.h6.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Filter button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: Icon(
                    _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                    color: Colors.white,
                  ),
                  tooltip: 'Filters',
                ),
                
                // New chat button
                IconButton(
                  onPressed: widget.onNewChat,
                  icon: const Icon(
                    Icons.edit,
                    color: AppColors.primaryLight,
                  ),
                  tooltip: 'New chat',
                ),
              ],
            ),
          ),
          
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(),
          ),
          
          // Filters
          if (_showFilters) _buildFilters(),
          
          // Divider
          Container(
            height: 1,
            color: AppColors.navbarBackground,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: widget.searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search chats...',
          hintStyle: AppTypography.body2.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    widget.searchController.clear();
                    widget.onSearchChanged('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppTypography.body2.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Pinned filter
          _buildFilterChip(
            label: 'Pinned',
            isSelected: widget.showPinned,
            onTap: () {
              widget.onFilterChanged(showPinned: !widget.showPinned);
            },
          ),
          
          const SizedBox(width: 8),
          
          // Archived filter
          _buildFilterChip(
            label: 'Archived',
            isSelected: widget.showArchived,
            onTap: () {
              widget.onFilterChanged(showArchived: !widget.showArchived);
            },
          ),
          
          const Spacer(),
          
          // Clear filters
          if (widget.showPinned || widget.showArchived)
            TextButton(
              onPressed: () {
                widget.onFilterChanged(showPinned: false, showArchived: false);
              },
              child: Text(
                'Clear',
                style: AppTypography.button.copyWith(
                  color: AppColors.primaryLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.navbarBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
