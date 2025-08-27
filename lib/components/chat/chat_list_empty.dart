import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class ChatListEmpty extends StatelessWidget {
  final VoidCallback onRefresh;
  final String searchQuery;

  const ChatListEmpty({
    Key? key,
    required this.onRefresh,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              isSearching ? Icons.search_off : Icons.chat_bubble_outline,
              size: 80,
              color: Colors.white.withOpacity(0.5),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              isSearching ? 'No chats found' : 'No messages yet',
              style: AppTypography.h6.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              isSearching 
                  ? 'Try adjusting your search terms or start a new conversation.'
                  : 'Start connecting with people by swiping right on profiles you like.',
              style: AppTypography.body2.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (isSearching) ...[
              const SizedBox(height: 24),
              
              // Search query display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.navbarBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Search: "$searchQuery"',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Action buttons
            if (isSearching) ...[
              // Clear search button
              ElevatedButton(
                onPressed: onRefresh,
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
                child: const Text('Clear Search'),
              ),
            ] else ...[
              // Start swiping button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
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
                child: const Text('Start Swiping'),
              ),
              
              const SizedBox(height: 16),
              
              // Refresh button
              TextButton(
                onPressed: onRefresh,
                child: Text(
                  'Refresh',
                  style: AppTypography.button.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
