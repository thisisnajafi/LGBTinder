class UserImage {
  final int id;
  final String url;
  final String? thumbnailUrl;
  final String? originalUrl;
  final String type; // 'profile' or 'gallery'
  final bool isPrimary;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserImage({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.originalUrl,
    required this.type,
    this.isPrimary = false,
    this.order = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      id: json['id'],
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      originalUrl: json['original_url'],
      type: json['type'] ?? 'gallery',
      isPrimary: json['is_primary'] ?? false,
      order: json['order'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'original_url': originalUrl,
      'type': type,
      'is_primary': isPrimary,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserImage copyWith({
    int? id,
    String? url,
    String? thumbnailUrl,
    String? originalUrl,
    String? type,
    bool? isPrimary,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserImage(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      originalUrl: originalUrl ?? this.originalUrl,
      type: type ?? this.type,
      isPrimary: isPrimary ?? this.isPrimary,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserImage(id: $id, url: $url, type: $type, isPrimary: $isPrimary)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserImage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
