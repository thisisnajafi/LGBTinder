class UserVerification {
  final int id;
  final int userId;
  final bool photoVerified;
  final bool idVerified;
  final bool videoVerified;
  final int verificationScore; // 0-100
  final int totalVerifications;
  final int pendingVerifications;
  final String? verificationBadge;
  final DateTime? photoVerifiedAt;
  final DateTime? idVerifiedAt;
  final DateTime? videoVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserVerification({
    required this.id,
    required this.userId,
    this.photoVerified = false,
    this.idVerified = false,
    this.videoVerified = false,
    this.verificationScore = 0,
    this.totalVerifications = 0,
    this.pendingVerifications = 0,
    this.verificationBadge,
    this.photoVerifiedAt,
    this.idVerifiedAt,
    this.videoVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory UserVerification.fromJson(Map<String, dynamic> json) {
    return UserVerification(
      id: json['id'],
      userId: json['user_id'],
      photoVerified: json['photo_verified'] ?? false,
      idVerified: json['id_verified'] ?? false,
      videoVerified: json['video_verified'] ?? false,
      verificationScore: json['verification_score'] ?? 0,
      totalVerifications: json['total_verifications'] ?? 0,
      pendingVerifications: json['pending_verifications'] ?? 0,
      verificationBadge: json['verification_badge'],
      photoVerifiedAt: json['photo_verified_at'] != null 
          ? DateTime.parse(json['photo_verified_at']) 
          : null,
      idVerifiedAt: json['id_verified_at'] != null 
          ? DateTime.parse(json['id_verified_at']) 
          : null,
      videoVerifiedAt: json['video_verified_at'] != null 
          ? DateTime.parse(json['video_verified_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'photo_verified': photoVerified,
      'id_verified': idVerified,
      'video_verified': videoVerified,
      'verification_score': verificationScore,
      'total_verifications': totalVerifications,
      'pending_verifications': pendingVerifications,
      'verification_badge': verificationBadge,
      'photo_verified_at': photoVerifiedAt?.toIso8601String(),
      'id_verified_at': idVerifiedAt?.toIso8601String(),
      'video_verified_at': videoVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserVerification copyWith({
    int? id,
    int? userId,
    bool? photoVerified,
    bool? idVerified,
    bool? videoVerified,
    int? verificationScore,
    int? totalVerifications,
    int? pendingVerifications,
    String? verificationBadge,
    DateTime? photoVerifiedAt,
    DateTime? idVerifiedAt,
    DateTime? videoVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserVerification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      photoVerified: photoVerified ?? this.photoVerified,
      idVerified: idVerified ?? this.idVerified,
      videoVerified: videoVerified ?? this.videoVerified,
      verificationScore: verificationScore ?? this.verificationScore,
      totalVerifications: totalVerifications ?? this.totalVerifications,
      pendingVerifications: pendingVerifications ?? this.pendingVerifications,
      verificationBadge: verificationBadge ?? this.verificationBadge,
      photoVerifiedAt: photoVerifiedAt ?? this.photoVerifiedAt,
      idVerifiedAt: idVerifiedAt ?? this.idVerifiedAt,
      videoVerifiedAt: videoVerifiedAt ?? this.videoVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if user has verified profile (score > 70%)
  bool get hasVerifiedProfile => verificationScore >= 70;

  // Get verification status as string
  String get verificationStatus {
    if (verificationScore >= 70) return 'Verified Profile';
    if (verificationScore >= 30) return 'Partially Verified';
    return 'Unverified';
  }

  // Get verification progress percentage
  double get verificationProgress => verificationScore / 100.0;

  @override
  String toString() {
    return 'UserVerification(id: $id, userId: $userId, score: $verificationScore%, verified: $hasVerifiedProfile)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserVerification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
