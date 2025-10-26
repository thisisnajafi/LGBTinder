import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../theme/typography.dart';

/// Service for sharing match celebrations
class MatchSharingService {
  /// Share match celebration as text
  static Future<void> shareMatchText({
    required User matchedUser,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ??
          '🎉 I just matched with ${matchedUser.firstName ?? matchedUser.name ?? "someone special"} on LGBTinder! 🌈';
      
      await Share.share(
        message,
        subject: 'New Match on LGBTinder!',
      );
      
      debugPrint('✅ Match shared successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to share match: $e');
      rethrow;
    }
  }

  /// Share match celebration with app link
  static Future<void> shareMatchWithLink({
    required User matchedUser,
    String? customMessage,
  }) async {
    try {
      final appLink = 'https://lgbtinder.app'; // Replace with actual app link
      final message = customMessage ??
          '🎉 I just matched with ${matchedUser.firstName ?? matchedUser.name ?? "someone special"} on LGBTinder! 🌈\n\nJoin me: $appLink';
      
      await Share.share(
        message,
        subject: 'New Match on LGBTinder!',
      );
      
      debugPrint('✅ Match with link shared successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to share match with link: $e');
      rethrow;
    }
  }

  /// Share match celebration as image
  static Future<void> shareMatchImage({
    required GlobalKey widgetKey,
    String? text,
  }) async {
    try {
      // Capture widget as image
      final boundary = widgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        throw Exception('Failed to find render boundary');
      }

      // Convert to image
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final buffer = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/match_celebration.png');
      await file.writeAsBytes(buffer);

      // Share file
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? '🎉 New Match on LGBTinder! 🌈',
        subject: 'My LGBTinder Match',
      );

      debugPrint('✅ Match image shared: ${result.status}');

      // Clean up temporary file
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to share match image: $e');
      rethrow;
    }
  }

  /// Share to specific platform
  static Future<void> shareToSpecificPlatform({
    required String message,
    String? subject,
  }) async {
    try {
      await Share.share(
        message,
        subject: subject ?? 'LGBTinder Match',
      );
      
      debugPrint('✅ Shared to platform successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to share to platform: $e');
      rethrow;
    }
  }

  /// Share match statistics
  static Future<void> shareMatchStats({
    required int totalMatches,
    required int todayMatches,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ??
          '🎉 My LGBTinder Stats 🌈\n\n'
          '💕 Total Matches: $totalMatches\n'
          '✨ Matches Today: $todayMatches\n\n'
          'Join me on LGBTinder!';
      
      await Share.share(
        message,
        subject: 'My LGBTinder Stats',
      );
      
      debugPrint('✅ Match stats shared successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to share match stats: $e');
      rethrow;
    }
  }

  /// Create shareable match celebration widget
  static Widget buildShareableMatchCard({
    required User currentUser,
    required User matchedUser,
    required GlobalKey key,
  }) {
    return RepaintBoundary(
      key: key,
      child: Container(
        width: 400,
        height: 600,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE40303), // Red
              Color(0xFFFF8C00), // Orange
              Color(0xFFFFED00), // Yellow
              Color(0xFF008026), // Green
              Color(0xFF24408E), // Blue
              Color(0xFF732982), // Purple
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              "It's a Match!",
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black45,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            
            // User avatars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Current user avatar
                _buildAvatar(currentUser),
                SizedBox(width: 40),
                // Heart icon
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                SizedBox(width: 40),
                // Matched user avatar
                _buildAvatar(matchedUser),
              ],
            ),
            SizedBox(height: 40),
            
            // Names
            Text(
              '${currentUser.firstName ?? "You"} & ${matchedUser.firstName ?? matchedUser.name ?? "Match"}',
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // App branding
            Text(
              'LGBTinder 🌈',
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAvatar(User user) {
    final imageUrl = user.images?.isNotEmpty == true 
        ? user.images!.first.url 
        : null;
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        color: Colors.grey[300],
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  static Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 60,
      color: Colors.grey[600],
    );
  }

  /// Check if sharing is available on the platform
  static Future<bool> canShare() async {
    // share_plus automatically handles platform availability
    return true;
  }

  /// Share match with custom options
  static Future<ShareResult> shareWithOptions({
    required String text,
    List<XFile>? files,
    String? subject,
    Rect? sharePositionOrigin,
  }) async {
    try {
      if (files != null && files.isNotEmpty) {
        return await Share.shareXFiles(
          files,
          text: text,
          subject: subject,
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        return await Share.shareWithResult(
          text,
          subject: subject,
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e) {
      debugPrint('⚠️ Failed to share with options: $e');
      rethrow;
    }
  }
}
