import 'package:flutter/foundation.dart';

enum AttachmentType {
  image,
  video,
  audio,
  file,
  location,
  contact,
  sticker,
  gif,
  voice,
}

class MessageAttachment {
  final String id;
  final AttachmentType type;
  final String url;
  final String? thumbnail;
  final String? filename;
  final int? size;
  final Duration? duration;
  final Map<String, dynamic>? metadata;
  final bool isUploaded;
  final double? uploadProgress;
  final String? localPath;
  final int? width;
  final int? height;

  const MessageAttachment({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnail,
    this.filename,
    this.size,
    this.duration,
    this.metadata,
    this.isUploaded = true,
    this.uploadProgress,
    this.localPath,
    this.width,
    this.height,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] as String,
      type: AttachmentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => AttachmentType.file,
      ),
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String?,
      filename: json['filename'] as String?,
      size: json['size'] as int?,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isUploaded: json['isUploaded'] as bool? ?? true,
      uploadProgress: json['uploadProgress'] as double?,
      localPath: json['localPath'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'url': url,
      'thumbnail': thumbnail,
      'filename': filename,
      'size': size,
      'duration': duration?.inMilliseconds,
      'metadata': metadata,
      'isUploaded': isUploaded,
      'uploadProgress': uploadProgress,
      'localPath': localPath,
      'width': width,
      'height': height,
    };
  }

  MessageAttachment copyWith({
    String? id,
    AttachmentType? type,
    String? url,
    String? thumbnail,
    String? filename,
    int? size,
    Duration? duration,
    Map<String, dynamic>? metadata,
    bool? isUploaded,
    double? uploadProgress,
    String? localPath,
    int? width,
    int? height,
  }) {
    return MessageAttachment(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      filename: filename ?? this.filename,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      localPath: localPath ?? this.localPath,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  bool get isImage => type == AttachmentType.image;
  bool get isVideo => type == AttachmentType.video;
  bool get isAudio => type == AttachmentType.audio || type == AttachmentType.voice;
  bool get isFile => type == AttachmentType.file;
  bool get isLocation => type == AttachmentType.location;
  bool get isContact => type == AttachmentType.contact;
  bool get isSticker => type == AttachmentType.sticker;
  bool get isGif => type == AttachmentType.gif;

  String get displayName => filename ?? 'Attachment';
  String get fileSize => size != null ? _formatFileSize(size!) : 'Unknown size';
  String get durationText => duration != null ? _formatDuration(duration!) : '';

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageAttachment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageAttachment(id: $id, type: $type, url: $url, filename: $filename)';
  }
}
