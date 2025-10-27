import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';
import '../media_compression_service.dart';

/// Media Upload API Service
/// 
/// Handles uploading media files (images, videos, documents) to the server
/// with progress tracking and automatic compression
class MediaUploadApiService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Upload single media file
  /// 
  /// [file] - Media file to upload
  /// [token] - Authentication token
  /// [compress] - Whether to compress before upload (default true)
  /// [onProgress] - Callback for upload progress (0.0 to 1.0)
  /// Returns [MediaUploadResponse] with uploaded file URL
  static Future<MediaUploadResponse> uploadMedia({
    required File file,
    required String token,
    bool compress = true,
    Function(double)? onProgress,
    String? mediaType,
  }) async {
    try {
      debugPrint('Starting media upload: ${file.path}');

      // Compress file if needed
      File fileToUpload = file;
      if (compress) {
        final compressionService = MediaCompressionService();
        
        if (compressionService.isImageFile(file.path)) {
          debugPrint('Compressing image before upload...');
          final compressed = await compressionService.compressImage(imageFile: file);
          if (compressed != null) {
            fileToUpload = compressed;
          }
        } else if (compressionService.isVideoFile(file.path)) {
          debugPrint('Compressing video before upload...');
          final compressed = await compressionService.compressVideo(videoFile: file);
          if (compressed != null) {
            fileToUpload = compressed.videoFile;
          }
        }
      }

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/chat/upload-media');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add file
      final fileStream = http.ByteStream(fileToUpload.openRead());
      final fileLength = await fileToUpload.length();
      
      final multipartFile = http.MultipartFile(
        'media',
        fileStream,
        fileLength,
        filename: fileToUpload.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Add media type if specified
      if (mediaType != null) {
        request.fields['media_type'] = mediaType;
      }

      debugPrint('Uploading file: ${fileToUpload.path.split('/').last}');
      debugPrint('File size: ${_formatBytes(fileLength)}');

      // Send request with progress tracking
      final streamedResponse = await request.send();

      // Track progress (simplified - in production, use a proper implementation)
      if (onProgress != null) {
        onProgress(1.0); // Progress tracking would require custom implementation
      }

      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        debugPrint('Media uploaded successfully');
        
        return MediaUploadResponse(
          success: true,
          mediaUrl: responseData['data']?['media_url'] as String?,
          thumbnailUrl: responseData['data']?['thumbnail_url'] as String?,
          mediaType: responseData['data']?['media_type'] as String?,
          fileSize: responseData['data']?['file_size'] as int?,
          duration: responseData['data']?['duration'] as int?,
          message: responseData['message'] as String?,
        );
      } else {
        return MediaUploadResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to upload media',
        );
      }
    } catch (e) {
      debugPrint('Error uploading media: $e');
      return MediaUploadResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Upload multiple media files
  /// 
  /// [files] - List of media files to upload
  /// [token] - Authentication token
  /// [compress] - Whether to compress before upload (default true)
  /// [onProgress] - Callback for overall upload progress (0.0 to 1.0)
  /// Returns list of [MediaUploadResponse]
  static Future<List<MediaUploadResponse>> uploadMultipleMedia({
    required List<File> files,
    required String token,
    bool compress = true,
    Function(double)? onProgress,
  }) async {
    final List<MediaUploadResponse> responses = [];
    
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      
      final response = await uploadMedia(
        file: file,
        token: token,
        compress: compress,
        onProgress: (fileProgress) {
          if (onProgress != null) {
            // Calculate overall progress
            final overallProgress = (i + fileProgress) / files.length;
            onProgress(overallProgress);
          }
        },
      );
      
      responses.add(response);
    }
    
    return responses;
  }

  /// Upload chat message with media
  /// 
  /// [chatId] - Chat ID
  /// [message] - Message text (optional)
  /// [file] - Media file to upload
  /// [token] - Authentication token
  /// [onProgress] - Callback for upload progress
  /// Returns [MediaUploadResponse]
  static Future<MediaUploadResponse> uploadChatMedia({
    required String chatId,
    String? message,
    required File file,
    required String token,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('Uploading chat media for chat: $chatId');

      // First compress the file
      final compressionService = MediaCompressionService();
      File fileToUpload = file;
      File? thumbnail;

      if (compressionService.isImageFile(file.path)) {
        final compressed = await compressionService.compressImage(imageFile: file);
        if (compressed != null) {
          fileToUpload = compressed;
        }
      } else if (compressionService.isVideoFile(file.path)) {
        final compressed = await compressionService.compressVideo(videoFile: file);
        if (compressed != null) {
          fileToUpload = compressed.videoFile;
          thumbnail = compressed.thumbnailFile;
        }
      }

      // Create multipart request
      final uri = Uri.parse('$_baseUrl/chat/send-media');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['chat_id'] = chatId;
      if (message != null && message.isNotEmpty) {
        request.fields['message'] = message;
      }

      // Add main file
      final fileStream = http.ByteStream(fileToUpload.openRead());
      final fileLength = await fileToUpload.length();
      
      request.files.add(http.MultipartFile(
        'media',
        fileStream,
        fileLength,
        filename: fileToUpload.path.split('/').last,
      ));

      // Add thumbnail if available
      if (thumbnail != null) {
        final thumbnailStream = http.ByteStream(thumbnail.openRead());
        final thumbnailLength = await thumbnail.length();
        
        request.files.add(http.MultipartFile(
          'thumbnail',
          thumbnailStream,
          thumbnailLength,
          filename: thumbnail.path.split('/').last,
        ));
      }

      // Send request
      final streamedResponse = await request.send();
      
      if (onProgress != null) {
        onProgress(1.0);
      }

      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['status'] == true) {
        debugPrint('Chat media uploaded successfully');
        
        return MediaUploadResponse(
          success: true,
          mediaUrl: responseData['data']?['media_url'] as String?,
          thumbnailUrl: responseData['data']?['thumbnail_url'] as String?,
          mediaType: responseData['data']?['media_type'] as String?,
          fileSize: responseData['data']?['file_size'] as int?,
          duration: responseData['data']?['duration'] as int?,
          message: responseData['message'] as String?,
        );
      } else {
        return MediaUploadResponse(
          success: false,
          error: responseData['message'] as String? ?? 'Failed to upload media',
        );
      }
    } catch (e) {
      debugPrint('Error uploading chat media: $e');
      return MediaUploadResponse(
        success: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Format bytes to human-readable string
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Media Upload Response
class MediaUploadResponse {
  final bool success;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? mediaType;
  final int? fileSize;
  final int? duration;
  final String? message;
  final String? error;

  MediaUploadResponse({
    required this.success,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mediaType,
    this.fileSize,
    this.duration,
    this.message,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'media_url': mediaUrl,
      'thumbnail_url': thumbnailUrl,
      'media_type': mediaType,
      'file_size': fileSize,
      'duration': duration,
      'message': message,
      'error': error,
    };
  }

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      success: json['success'] as bool,
      mediaUrl: json['media_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      mediaType: json['media_type'] as String?,
      fileSize: json['file_size'] as int?,
      duration: json['duration'] as int?,
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}

