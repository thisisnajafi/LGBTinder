import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../models/user.dart';
import '../../screens/story_viewing_screen.dart';

class StoriesHeader extends StatelessWidget {
  final List<User> usersWithStories;
  final VoidCallback? onCreateStory;
  final Function(User)? onStoryTap;

  const StoriesHeader({
    Key? key,
    required this.usersWithStories,
    this.onCreateStory,
    this.onStoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: usersWithStories.length + 1, // +1 for create story button
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCreateStoryButton(context);
          }
          
          final user = usersWithStories[index - 1];
          return _buildStoryCircle(user, context);
        },
      ),
    );
  }

  Widget _buildCreateStoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onCreateStory != null) {
          onCreateStory!();
        } else {
          Navigator.pushNamed(context, '/story-creation');
        }
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navbarBackground,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your Story',
              style: AppTypography.caption.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCircle(User user, BuildContext context) {
    final hasUnviewedStories = _hasUnviewedStories(user);
    
    return GestureDetector(
      onTap: () {
        if (onStoryTap != null) {
          onStoryTap!(user);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryViewingScreen(
                usersWithStories: usersWithStories,
                initialUserIndex: usersWithStories.indexOf(user),
              ),
            ),
          );
        }
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnviewedStories
                    ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.secondaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: hasUnviewedStories ? null : AppColors.navbarBackground,
                border: Border.all(
                  color: hasUnviewedStories
                      ? Colors.transparent
                      : AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: user.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: user.avatarUrl == null ? AppColors.navbarBackground : null,
                ),
                child: user.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 24,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.firstName,
              style: AppTypography.caption.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  bool _hasUnviewedStories(User user) {
    // This would typically check if the user has unviewed stories
    // For now, we'll simulate this based on some logic
    return user.isOnline ?? false;
  }
}

class StoryPreview {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final StoryType type;
  final DateTime createdAt;
  final bool isViewed;

  StoryPreview({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isViewed = false,
  });

  factory StoryPreview.fromJson(Map<String, dynamic> json) {
    return StoryPreview(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatarUrl: json['user_avatar_url'],
      content: json['content'] ?? '',
      type: StoryType.values.firstWhere(
        (e) => e.toString() == 'StoryType.${json['type']}',
        orElse: () => StoryType.text,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      isViewed: json['is_viewed'] ?? false,
    );
  }
}

enum StoryType {
  text,
  image,
  video,
}
