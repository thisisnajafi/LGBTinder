import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

/// Group Chat API Service
/// 
/// Handles all group chat API calls:
/// - Create group chats
/// - Manage members (add/remove)
/// - Update group info
/// - Admin management
class GroupChatApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // ============================================================================
  // GROUP MANAGEMENT
  // ============================================================================

  /// Create new group chat
  /// 
  /// [token] - Authentication token
  /// [name] - Group name
  /// [description] - Group description
  /// [memberIds] - List of member IDs (min 2, max 50)
  /// [photo] - Group photo file (optional)
  static Future<GroupChatResponse> createGroup({
    required String token,
    required String name,
    String? description,
    required List<String> memberIds,
    File? photo,
  }) async {
    try {
      debugPrint('Creating group chat: $name with ${memberIds.length} members');

      final uri = Uri.parse('$_baseUrl/chat/groups');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['name'] = name;
      if (description != null) {
        request.fields['description'] = description;
      }
      request.fields['member_ids'] = jsonEncode(memberIds);

      // Add photo if provided
      if (photo != null) {
        final fileStream = http.ByteStream(photo.openRead());
        final fileLength = await photo.length();
        
        request.files.add(http.MultipartFile(
          'photo',
          fileStream,
          fileLength,
          filename: photo.path.split('/').last,
        ));
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return GroupChatResponse(
          success: true,
          groupChat: GroupChat.fromJson(responseData['data'] as Map<String, dynamic>),
        );
      } else {
        return GroupChatResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to create group',
        );
      }
    } catch (e) {
      debugPrint('Error creating group: $e');
      return GroupChatResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get group chat details
  /// 
  /// [token] - Authentication token
  /// [groupId] - Group ID
  static Future<GroupChatResponse> getGroup({
    required String token,
    required String groupId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat/groups/$groupId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return GroupChatResponse(
          success: true,
          groupChat: GroupChat.fromJson(responseData['data'] as Map<String, dynamic>),
        );
      } else {
        return GroupChatResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to fetch group',
        );
      }
    } catch (e) {
      debugPrint('Error fetching group: $e');
      return GroupChatResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update group info
  /// 
  /// [token] - Authentication token
  /// [groupId] - Group ID
  /// [name] - New group name (optional)
  /// [description] - New description (optional)
  /// [photo] - New group photo (optional)
  static Future<GroupChatResponse> updateGroup({
    required String token,
    required String groupId,
    String? name,
    String? description,
    File? photo,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/chat/groups/$groupId');
      final request = http.MultipartRequest('PUT', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      if (name != null) request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;

      if (photo != null) {
        final fileStream = http.ByteStream(photo.openRead());
        final fileLength = await photo.length();
        
        request.files.add(http.MultipartFile(
          'photo',
          fileStream,
          fileLength,
          filename: photo.path.split('/').last,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        return GroupChatResponse(
          success: true,
          groupChat: GroupChat.fromJson(responseData['data'] as Map<String, dynamic>),
        );
      } else {
        return GroupChatResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to update group',
        );
      }
    } catch (e) {
      debugPrint('Error updating group: $e');
      return GroupChatResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Delete group chat
  /// 
  /// [token] - Authentication token
  /// [groupId] - Group ID
  static Future<bool> deleteGroup({
    required String token,
    required String groupId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/groups/$groupId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error deleting group: $e');
      return false;
    }
  }

  // ============================================================================
  // MEMBER MANAGEMENT
  // ============================================================================

  /// Add members to group
  /// 
  /// [token] - Authentication token
  /// [groupId] - Group ID
  /// [memberIds] - List of user IDs to add
  static Future<bool> addMembers({
    required String token,
    required String groupId,
    required List<String> memberIds,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/groups/$groupId/members'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'member_ids': memberIds,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error adding members: $e');
      return false;
    }
  }

  /// Remove member from group
  /// 
  /// [token] - Authentication token
  /// [groupId] - Group ID
  /// [memberId] - User ID to remove
  static Future<bool> removeMember({
    required String token,
    required String groupId,
    required String memberId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/groups/$groupId/members/$memberId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error removing member: $e');
      return false;
    }
  }

  /// Leave group
  /// 
  /// [token] - Authentication token
  /// [groupId] - Group ID
  static Future<bool> leaveGroup({
    required String token,
    required String groupId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/groups/$groupId/leave'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error leaving group: $e');
      return false;
    }
  }

  // ============================================================================
  // ADMIN MANAGEMENT
  // ============================================================================

  /// Promote member to admin
  /// 
  /// [token] - Authentication token
  /// [groupId] - Group ID
  /// [memberId] - User ID to promote
  static Future<bool> promoteToAdmin({
    required String token,
    required String groupId,
    required String memberId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/groups/$groupId/admins/$memberId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error promoting to admin: $e');
      return false;
    }
  }

  /// Demote admin to regular member
  /// 
  /// [token] - Authentication token
  /// [groupId] - Group ID
  /// [memberId] - User ID to demote
  static Future<bool> demoteAdmin({
    required String token,
    required String groupId,
    required String memberId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/chat/groups/$groupId/admins/$memberId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      return response.statusCode == 200 && responseData['status'] == true;
    } catch (e) {
      debugPrint('Error demoting admin: $e');
      return false;
    }
  }
}

// ============================================================================
// RESPONSE MODELS
// ============================================================================

class GroupChatResponse {
  final bool success;
  final GroupChat? groupChat;
  final String? error;

  GroupChatResponse({
    required this.success,
    this.groupChat,
    this.error,
  });
}

// ============================================================================
// DATA MODELS
// ============================================================================

class GroupChat {
  final String id;
  final String name;
  final String? description;
  final String? photoUrl;
  final String creatorId;
  final List<GroupMember> members;
  final List<String> adminIds;
  final DateTime createdAt;
  final DateTime? updatedAt;

  GroupChat({
    required this.id,
    required this.name,
    this.description,
    this.photoUrl,
    required this.creatorId,
    required this.members,
    required this.adminIds,
    required this.createdAt,
    this.updatedAt,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      photoUrl: json['photo_url'] as String?,
      creatorId: json['creator_id'].toString(),
      members: (json['members'] as List?)
              ?.map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      adminIds: (json['admin_ids'] as List?)?.map((id) => id.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  int get memberCount => members.length;
  
  bool isAdmin(String userId) => adminIds.contains(userId);
  
  bool isCreator(String userId) => creatorId == userId;
}

class GroupMember {
  final String id;
  final String name;
  final String? photoUrl;
  final bool isAdmin;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.isAdmin,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'].toString(),
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}

