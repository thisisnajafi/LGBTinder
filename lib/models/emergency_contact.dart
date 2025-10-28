/// Emergency Contact Model
class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String relationship;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastNotified;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.relationship,
    this.isVerified = false,
    required this.createdAt,
    this.lastNotified,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      relationship: json['relationship'] ?? 'Other',
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastNotified: json['last_notified'] != null
          ? DateTime.parse(json['last_notified'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'relationship': relationship,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'last_notified': lastNotified?.toIso8601String(),
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastNotified,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastNotified: lastNotified ?? this.lastNotified,
    );
  }
}

