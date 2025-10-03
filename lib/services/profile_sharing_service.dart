import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

enum SharePlatform {
  whatsapp,
  telegram,
  instagram,
  facebook,
  twitter,
  snapchat,
  tiktok,
  email,
  sms,
  link,
  qrCode,
  copyLink,
  saveImage,
}

enum ShareType {
  profileCard,
  profileLink,
  profileImage,
  profileQR,
  profileText,
  profileVideo,
}

class ShareContent {
  final String title;
  final String description;
  final String? imagePath;
  final String? videoPath;
  final String? link;
  final String? qrCodeData;
  final Map<String, dynamic> metadata;

  const ShareContent({
    required this.title,
    required this.description,
    this.imagePath,
    this.videoPath,
    this.link,
    this.qrCodeData,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'link': link,
      'qrCodeData': qrCodeData,
      'metadata': metadata,
    };
  }

  factory ShareContent.fromJson(Map<String, dynamic> json) {
    return ShareContent(
      title: json['title'],
      description: json['description'],
      imagePath: json['imagePath'],
      videoPath: json['videoPath'],
      link: json['link'],
      qrCodeData: json['qrCodeData'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class ShareHistory {
  final String id;
  final SharePlatform platform;
  final ShareType type;
  final String? recipientId;
  final String? recipientName;
  final DateTime timestamp;
  final bool isSuccessful;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const ShareHistory({
    required this.id,
    required this.platform,
    required this.type,
    this.recipientId,
    this.recipientName,
    required this.timestamp,
    this.isSuccessful = true,
    this.errorMessage,
    this.metadata = const {},
  });

  ShareHistory copyWith({
    String? id,
    SharePlatform? platform,
    ShareType? type,
    String? recipientId,
    String? recipientName,
    DateTime? timestamp,
    bool? isSuccessful,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return ShareHistory(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      type: type ?? this.type,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      timestamp: timestamp ?? this.timestamp,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform.name,
      'type': type.name,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'timestamp': timestamp.toIso8601String(),
      'isSuccessful': isSuccessful,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  factory ShareHistory.fromJson(Map<String, dynamic> json) {
    return ShareHistory(
      id: json['id'],
      platform: SharePlatform.values.firstWhere((e) => e.name == json['platform']),
      type: ShareType.values.firstWhere((e) => e.name == json['type']),
      recipientId: json['recipientId'],
      recipientName: json['recipientName'],
      timestamp: DateTime.parse(json['timestamp']),
      isSuccessful: json['isSuccessful'],
      errorMessage: json['errorMessage'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class ProfileSharingService {
  static const String _shareHistoryKey = 'profile_share_history';
  static const String _shareSettingsKey = 'profile_share_settings';
  
  static ProfileSharingService? _instance;
  static ProfileSharingService get instance {
    _instance ??= ProfileSharingService._();
    return _instance!;
  }

  ProfileSharingService._();

  /// Generate profile share content
  Future<ShareContent> generateProfileShareContent({
    required String profileId,
    required String userName,
    required String userBio,
    String? userImage,
    List<String>? interests,
    String? location,
    int? age,
    String? gender,
    Map<String, dynamic>? additionalData,
  }) async {
    final profileLink = await _generateProfileLink(profileId);
    final qrCodeData = await _generateQRCodeData(profileLink);
    
    final title = 'Check out $userName\'s profile on LGBTinder!';
    final description = _generateProfileDescription(
      userName: userName,
      userBio: userBio,
      interests: interests,
      location: location,
      age: age,
      gender: gender,
    );

    return ShareContent(
      title: title,
      description: description,
      imagePath: userImage,
      link: profileLink,
      qrCodeData: qrCodeData,
      metadata: {
        'profileId': profileId,
        'userName': userName,
        'userBio': userBio,
        'interests': interests,
        'location': location,
        'age': age,
        'gender': gender,
        'generatedAt': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  /// Share profile to specific platform
  Future<bool> shareProfile({
    required SharePlatform platform,
    required ShareContent content,
    String? recipientId,
    String? recipientName,
    Map<String, dynamic>? customData,
  }) async {
    try {
      final shareId = _generateShareId();
      final shareHistory = ShareHistory(
        id: shareId,
        platform: platform,
        type: ShareType.profileLink,
        recipientId: recipientId,
        recipientName: recipientName,
        timestamp: DateTime.now(),
        isSuccessful: false,
        metadata: customData ?? {},
      );

      bool success = false;
      String? errorMessage;

      switch (platform) {
        case SharePlatform.whatsapp:
          success = await _shareToWhatsApp(content, recipientId);
          break;
        case SharePlatform.telegram:
          success = await _shareToTelegram(content, recipientId);
          break;
        case SharePlatform.instagram:
          success = await _shareToInstagram(content);
          break;
        case SharePlatform.facebook:
          success = await _shareToFacebook(content);
          break;
        case SharePlatform.twitter:
          success = await _shareToTwitter(content);
          break;
        case SharePlatform.snapchat:
          success = await _shareToSnapchat(content);
          break;
        case SharePlatform.tiktok:
          success = await _shareToTikTok(content);
          break;
        case SharePlatform.email:
          success = await _shareToEmail(content, recipientId);
          break;
        case SharePlatform.sms:
          success = await _shareToSMS(content, recipientId);
          break;
        case SharePlatform.link:
          success = await _shareAsLink(content);
          break;
        case SharePlatform.qrCode:
          success = await _shareAsQRCode(content);
          break;
        case SharePlatform.copyLink:
          success = await _copyLinkToClipboard(content);
          break;
        case SharePlatform.saveImage:
          success = await _saveImageToGallery(content);
          break;
      }

      if (!success) {
        errorMessage = 'Failed to share to ${platform.name}';
      }

      // Update share history
      final updatedHistory = shareHistory.copyWith(
        isSuccessful: success,
        errorMessage: errorMessage,
      );

      await _saveShareHistory(updatedHistory);
      
      // Track analytics event
      await _trackShareEvent(platform, success);

      return success;
    } catch (e) {
      await _saveShareHistory(ShareHistory(
        id: _generateShareId(),
        platform: platform,
        type: ShareType.profileLink,
        recipientId: recipientId,
        recipientName: recipientName,
        timestamp: DateTime.now(),
        isSuccessful: false,
        errorMessage: e.toString(),
        metadata: customData ?? {},
      ));
      return false;
    }
  }

  /// Get share history
  Future<List<ShareHistory>> getShareHistory({
    SharePlatform? platform,
    ShareType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_shareHistoryKey);
    
    if (historyJson != null) {
      try {
        final historyList = json.decode(historyJson) as List;
        var history = historyList.map((item) => ShareHistory.fromJson(item)).toList();
        
        // Apply filters
        if (platform != null) {
          history = history.where((h) => h.platform == platform).toList();
        }
        
        if (type != null) {
          history = history.where((h) => h.type == type).toList();
        }
        
        if (startDate != null) {
          history = history.where((h) => h.timestamp.isAfter(startDate)).toList();
        }
        
        if (endDate != null) {
          history = history.where((h) => h.timestamp.isBefore(endDate)).toList();
        }
        
        // Sort by timestamp (newest first)
        history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Apply limit
        if (limit != null && limit > 0) {
          history = history.take(limit).toList();
        }
        
        return history;
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  /// Get share statistics
  Future<Map<String, dynamic>> getShareStatistics() async {
    final history = await getShareHistory();
    
    final totalShares = history.length;
    final successfulShares = history.where((h) => h.isSuccessful).length;
    final failedShares = history.where((h) => !h.isSuccessful).length;
    
    final platformCounts = <SharePlatform, int>{};
    final typeCounts = <ShareType, int>{};
    
    for (final share in history) {
      platformCounts[share.platform] = (platformCounts[share.platform] ?? 0) + 1;
      typeCounts[share.type] = (typeCounts[share.type] ?? 0) + 1;
    }
    
    final topPlatforms = platformCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5);
    
    final topTypes = typeCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(5);
    
    return {
      'totalShares': totalShares,
      'successfulShares': successfulShares,
      'failedShares': failedShares,
      'successRate': totalShares > 0 ? (successfulShares / totalShares) * 100 : 0.0,
      'topPlatforms': topPlatforms.map((e) => {
        'platform': e.key.name,
        'count': e.value,
      }).toList(),
      'topTypes': topTypes.map((e) => {
        'type': e.key.name,
        'count': e.value,
      }).toList(),
      'lastShareDate': history.isNotEmpty ? history.first.timestamp.toIso8601String() : null,
    };
  }

  /// Get available share platforms
  List<Map<String, dynamic>> getAvailableSharePlatforms() {
    return [
      {
        'platform': SharePlatform.whatsapp,
        'name': 'WhatsApp',
        'icon': 'whatsapp',
        'color': 0xFF25D366,
        'enabled': true,
        'description': 'Share via WhatsApp message',
      },
      {
        'platform': SharePlatform.telegram,
        'name': 'Telegram',
        'icon': 'telegram',
        'color': 0xFF0088CC,
        'enabled': true,
        'description': 'Share via Telegram message',
      },
      {
        'platform': SharePlatform.instagram,
        'name': 'Instagram',
        'icon': 'instagram',
        'color': 0xFFE4405F,
        'enabled': true,
        'description': 'Share to Instagram story',
      },
      {
        'platform': SharePlatform.facebook,
        'name': 'Facebook',
        'icon': 'facebook',
        'color': 0xFF1877F2,
        'enabled': true,
        'description': 'Share to Facebook',
      },
      {
        'platform': SharePlatform.twitter,
        'name': 'Twitter',
        'icon': 'twitter',
        'color': 0xFF1DA1F2,
        'enabled': true,
        'description': 'Share to Twitter',
      },
      {
        'platform': SharePlatform.snapchat,
        'name': 'Snapchat',
        'icon': 'snapchat',
        'color': 0xFFFFFC00,
        'enabled': true,
        'description': 'Share to Snapchat',
      },
      {
        'platform': SharePlatform.tiktok,
        'name': 'TikTok',
        'icon': 'tiktok',
        'color': 0xFF000000,
        'enabled': true,
        'description': 'Share to TikTok',
      },
      {
        'platform': SharePlatform.email,
        'name': 'Email',
        'icon': 'email',
        'color': 0xFF4285F4,
        'enabled': true,
        'description': 'Share via email',
      },
      {
        'platform': SharePlatform.sms,
        'name': 'SMS',
        'icon': 'sms',
        'color': 0xFF34A853,
        'enabled': true,
        'description': 'Share via SMS',
      },
      {
        'platform': SharePlatform.link,
        'name': 'Copy Link',
        'icon': 'link',
        'color': 0xFF6366F1,
        'enabled': true,
        'description': 'Copy profile link',
      },
      {
        'platform': SharePlatform.qrCode,
        'name': 'QR Code',
        'icon': 'qr_code',
        'color': 0xFF8B5CF6,
        'enabled': true,
        'description': 'Generate QR code',
      },
      {
        'platform': SharePlatform.saveImage,
        'name': 'Save Image',
        'icon': 'save',
        'color': 0xFF10B981,
        'enabled': true,
        'description': 'Save profile image',
      },
    ];
  }

  /// Clear share history
  Future<void> clearShareHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shareHistoryKey);
  }

  /// Export share data
  Future<Map<String, dynamic>> exportShareData() async {
    final history = await getShareHistory();
    final statistics = await getShareStatistics();
    
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'shareHistory': history.map((h) => h.toJson()).toList(),
      'statistics': statistics,
    };
  }

  /// Private helper methods
  String _generateShareId() {
    return 'share_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  Future<String> _generateProfileLink(String profileId) async {
    // In a real app, this would generate a proper deep link
    return 'https://lgbtinder.app/profile/$profileId';
  }

  Future<String> _generateQRCodeData(String link) async {
    // In a real app, this would generate actual QR code data
    return 'QR_CODE_DATA_FOR_$link';
  }

  String _generateProfileDescription({
    required String userName,
    required String userBio,
    List<String>? interests,
    String? location,
    int? age,
    String? gender,
  }) {
    final buffer = StringBuffer();
    buffer.write('Meet $userName');
    
    if (age != null && gender != null) {
      buffer.write(', $age-year-old $gender');
    }
    
    if (location != null) {
      buffer.write(' from $location');
    }
    
    buffer.write(' on LGBTinder!');
    
    if (userBio.isNotEmpty) {
      buffer.write('\n\n"$userBio"');
    }
    
    if (interests != null && interests.isNotEmpty) {
      buffer.write('\n\nInterests: ${interests.take(3).join(', ')}');
      if (interests.length > 3) {
        buffer.write(' and ${interests.length - 3} more');
      }
    }
    
    buffer.write('\n\nDownload LGBTinder to connect!');
    
    return buffer.toString();
  }

  Future<bool> _shareToWhatsApp(ShareContent content, String? recipientId) async {
    // TODO: Implement WhatsApp sharing
    return true;
  }

  Future<bool> _shareToTelegram(ShareContent content, String? recipientId) async {
    // TODO: Implement Telegram sharing
    return true;
  }

  Future<bool> _shareToInstagram(ShareContent content) async {
    // TODO: Implement Instagram sharing
    return true;
  }

  Future<bool> _shareToFacebook(ShareContent content) async {
    // TODO: Implement Facebook sharing
    return true;
  }

  Future<bool> _shareToTwitter(ShareContent content) async {
    // TODO: Implement Twitter sharing
    return true;
  }

  Future<bool> _shareToSnapchat(ShareContent content) async {
    // TODO: Implement Snapchat sharing
    return true;
  }

  Future<bool> _shareToTikTok(ShareContent content) async {
    // TODO: Implement TikTok sharing
    return true;
  }

  Future<bool> _shareToEmail(ShareContent content, String? recipientId) async {
    // TODO: Implement email sharing
    return true;
  }

  Future<bool> _shareToSMS(ShareContent content, String? recipientId) async {
    // TODO: Implement SMS sharing
    return true;
  }

  Future<bool> _shareAsLink(ShareContent content) async {
    // TODO: Implement link sharing
    return true;
  }

  Future<bool> _shareAsQRCode(ShareContent content) async {
    // TODO: Implement QR code sharing
    return true;
  }

  Future<bool> _copyLinkToClipboard(ShareContent content) async {
    // TODO: Implement clipboard copying
    return true;
  }

  Future<bool> _saveImageToGallery(ShareContent content) async {
    // TODO: Implement image saving
    return true;
  }

  Future<void> _saveShareHistory(ShareHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_shareHistoryKey);
    
    List<ShareHistory> historyList = [];
    if (historyJson != null) {
      try {
        final historyData = json.decode(historyJson) as List;
        historyList = historyData.map((item) => ShareHistory.fromJson(item)).toList();
      } catch (e) {
        historyList = [];
      }
    }
    
    historyList.add(history);
    
    // Keep only last 1000 shares to prevent storage bloat
    if (historyList.length > 1000) {
      historyList = historyList.skip(historyList.length - 1000).toList();
    }
    
    await prefs.setString(
      _shareHistoryKey,
      json.encode(historyList.map((h) => h.toJson()).toList()),
    );
  }

  Future<void> _trackShareEvent(SharePlatform platform, bool success) async {
    // TODO: Track analytics event
  }
}