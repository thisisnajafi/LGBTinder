import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

/// Group Chat API Service
/// 
/// Handles all group chat-related API calls:
/// - Create/edit/delete groups
/// - Add/remove members
/// - Manage admin roles
class GroupChatApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Create group chat
  static Future<GroupChatResponse> createGroup({
    required String token,
    required String name,
    required List<String> memberIds,
    String? description,
    String? photoUrl,
  }) async {
    try {
      debugPrint('Creating group chat: $name with ${memberIds.length} members');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/groups'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'member_ids': memberIds,
          'description': description,
          'photo_url': photoUrl,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          group: GroupChat.fromJson(data['data'] as Map<String, dynamic>),
          message: data['message'] as String?,
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error creating group: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get group details
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          group: GroupChat.fromJson(data['data'] as Map<String, dynamic>),
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error getting group: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Update group info
  static Future<GroupChatResponse> updateGroup({
    required String token,
    required String groupId,
    String? name,
    String? description,
    String? photoUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (photoUrl != null) body['photo_url'] = photoUrl;

      final response = await http.put(
        Uri.parse('$_baseUrl/chat/groups/$groupId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          group: GroupChat.fromJson(data['data'] as Map<String, dynamic>),
          message: data['message'] as String?,
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error updating group: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Add members to group
  static Future<GroupChatResponse> addMembers({
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error adding members: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Remove member from group
  static Future<GroupChatResponse> removeMember({
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error removing member: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Promote member to admin
  static Future<GroupChatResponse> promoteToAdmin({
    required String token,
    required String groupId,
    required String memberId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/chat/groups/$groupId/admins/$memberId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error promoting to admin: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Demote admin to member
  static Future<GroupChatResponse> demoteFromAdmin({
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error demoting admin: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Leave group
  static Future<GroupChatResponse> leaveGroup({
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error leaving group: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Delete group
  static Future<GroupChatResponse> deleteGroup({
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['status'] == true) {
        return GroupChatResponse(
          success: true,
          message: data['message'] as String?,
        );
      }

      return GroupChatResponse(
        success: false,
        error: data['message'] as String?,
      );
    } catch (e) {
      debugPrint('Error deleting group: $e');
      return GroupChatResponse(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// Group Chat Response
class GroupChatResponse {
  final bool success;
  final GroupChat? group;
  final String? message;
  final String? error;

  GroupChatResponse({
    required this.success,
    this.group,
    this.message,
    this.error,
  });
}

/// Group Chat Model
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

/// Group Member Model
class GroupMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isAdmin;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isAdmin = false,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'].toString(),
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}
