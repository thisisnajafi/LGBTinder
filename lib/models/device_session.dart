/// Device Session Model
class DeviceSession {
  final String id;
  final String deviceName;
  final String deviceType;
  final String browser;
  final String ipAddress;
  final String location;
  final bool isCurrent;
  final DateTime lastActive;
  final DateTime createdAt;

  const DeviceSession({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.browser,
    required this.ipAddress,
    required this.location,
    this.isCurrent = false,
    required this.lastActive,
    required this.createdAt,
  });

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      id: json['id'].toString(),
      deviceName: json['device_name'] ?? 'Unknown Device',
      deviceType: json['device_type'] ?? 'unknown',
      browser: json['browser'] ?? 'Unknown Browser',
      ipAddress: json['ip_address'] ?? '',
      location: json['location'] ?? 'Unknown Location',
      isCurrent: json['is_current'] ?? false,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'device_type': deviceType,
      'browser': browser,
      'ip_address': ipAddress,
      'location': location,
      'is_current': isCurrent,
      'last_active': lastActive.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

