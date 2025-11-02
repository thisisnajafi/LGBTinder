import 'package:flutter/material.dart';
import '../../services/skeleton_loader_service.dart';

class ChatListLoading extends StatelessWidget {
  const ChatListLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 10, // Show 10 skeleton items
      itemBuilder: (context, index) {
        return _buildSkeletonItem();
      },
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar skeleton
          SkeletonLoaderService.createSkeletonAvatar(size: 48),
          
          const SizedBox(width: 12),
          
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name skeleton
                SkeletonLoaderService.createSkeletonText(
                  width: double.infinity,
                  height: 16,
                ),
                
                const SizedBox(height: 8),
                
                // Message preview skeleton
                Row(
                  children: [
                    Expanded(
                      child: SkeletonLoaderService.createSkeletonText(
                        width: double.infinity,
                        height: 14,
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Time skeleton
                    SkeletonLoaderService.createSkeletonText(
                      width: 40,
                      height: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
