class UserPreferences {
  final int id;
  final int userId;
  final int minAge;
  final int maxAge;
  final double maxDistance; // in km
  final bool showAge;
  final bool showDistance;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.minAge,
    required this.maxAge,
    required this.maxDistance,
    this.showAge = true,
    this.showDistance = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'],
      userId: json['user_id'],
      minAge: json['min_age'] ?? 18,
      maxAge: json['max_age'] ?? 80,
      maxDistance: (json['max_distance'] ?? 50.0).toDouble(),
      showAge: json['show_age'] ?? true,
      showDistance: json['show_distance'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'min_age': minAge,
      'max_age': maxAge,
      'max_distance': maxDistance,
      'show_age': showAge,
      'show_distance': showDistance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserPreferences copyWith({
    int? id,
    int? userId,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    bool? showAge,
    bool? showDistance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      maxDistance: maxDistance ?? this.maxDistance,
      showAge: showAge ?? this.showAge,
      showDistance: showDistance ?? this.showDistance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get age range as string
  String get ageRangeText => 'Looking for ages $minAge-$maxAge';

  // Get distance as string
  String get distanceText => 'Within ${maxDistance.toInt()} km';

  @override
  String toString() {
    return 'UserPreferences(id: $id, userId: $userId, ageRange: $minAge-$maxAge, distance: $maxDistance km)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
  
  // Static method to create empty preferences
  static UserPreferences empty() {
    return UserPreferences(
      id: 0,
      userId: 0,
      minAge: 18,
      maxAge: 80,
      maxDistance: 50.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
