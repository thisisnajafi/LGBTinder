import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

enum ExportFormat {
  json,
  csv,
  pdf,
  html,
  xml,
  txt,
}

enum ExportType {
  full,
  basic,
  photos,
  messages,
  analytics,
  settings,
  custom,
}

enum ExportStatus {
  idle,
  preparing,
  processing,
  completed,
  failed,
  cancelled,
}

class ExportRequest {
  final String id;
  final String userId;
  final ExportFormat format;
  final ExportType type;
  final List<String> dataTypes;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final ExportStatus status;
  final String? filePath;
  final int? fileSize;
  final String? errorMessage;
  final Map<String, dynamic> options;
  final Map<String, dynamic> metadata;

  const ExportRequest({
    required this.id,
    required this.userId,
    required this.format,
    required this.type,
    required this.dataTypes,
    required this.requestedAt,
    this.completedAt,
    this.status = ExportStatus.idle,
    this.filePath,
    this.fileSize,
    this.errorMessage,
    this.options = const {},
    this.metadata = const {},
  });

  ExportRequest copyWith({
    String? id,
    String? userId,
    ExportFormat? format,
    ExportType? type,
    List<String>? dataTypes,
    DateTime? requestedAt,
    DateTime? completedAt,
    ExportStatus? status,
    String? filePath,
    int? fileSize,
    String? errorMessage,
    Map<String, dynamic>? options,
    Map<String, dynamic>? metadata,
  }) {
    return ExportRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      format: format ?? this.format,
      type: type ?? this.type,
      dataTypes: dataTypes ?? this.dataTypes,
      requestedAt: requestedAt ?? this.requestedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      errorMessage: errorMessage ?? this.errorMessage,
      options: options ?? this.options,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'format': format.name,
      'type': type.name,
      'dataTypes': dataTypes,
      'requestedAt': requestedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
      'filePath': filePath,
      'fileSize': fileSize,
      'errorMessage': errorMessage,
      'options': options,
      'metadata': metadata,
    };
  }

  factory ExportRequest.fromJson(Map<String, dynamic> json) {
    return ExportRequest(
      id: json['id'],
      userId: json['userId'],
      format: ExportFormat.values.firstWhere((e) => e.name == json['format']),
      type: ExportType.values.firstWhere((e) => e.name == json['type']),
      dataTypes: List<String>.from(json['dataTypes']),
      requestedAt: DateTime.parse(json['requestedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      status: ExportStatus.values.firstWhere((e) => e.name == json['status']),
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      errorMessage: json['errorMessage'],
      options: Map<String, dynamic>.from(json['options'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class ExportProgress {
  final String operation;
  final int currentStep;
  final int totalSteps;
  final double percentage;
  final String currentItem;
  final int itemsProcessed;
  final int totalItems;
  final DateTime startTime;
  final DateTime? estimatedCompletion;
  final String? errorMessage;

  const ExportProgress({
    required this.operation,
    required this.currentStep,
    required this.totalSteps,
    required this.percentage,
    required this.currentItem,
    required this.itemsProcessed,
    required this.totalItems,
    required this.startTime,
    this.estimatedCompletion,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'currentStep': currentStep,
      'totalSteps': totalSteps,
      'percentage': percentage,
      'currentItem': currentItem,
      'itemsProcessed': itemsProcessed,
      'totalItems': totalItems,
      'startTime': startTime.toIso8601String(),
      'estimatedCompletion': estimatedCompletion?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  factory ExportProgress.fromJson(Map<String, dynamic> json) {
    return ExportProgress(
      operation: json['operation'],
      currentStep: json['currentStep'],
      totalSteps: json['totalSteps'],
      percentage: json['percentage'],
      currentItem: json['currentItem'],
      itemsProcessed: json['itemsProcessed'],
      totalItems: json['totalItems'],
      startTime: DateTime.parse(json['startTime']),
      estimatedCompletion: json['estimatedCompletion'] != null ? DateTime.parse(json['estimatedCompletion']) : null,
      errorMessage: json['errorMessage'],
    );
  }
}

class ProfileExportService {
  static const String _exportHistoryKey = 'profile_export_history';
  static const String _exportSettingsKey = 'profile_export_settings';
  
  static ProfileExportService? _instance;
  static ProfileExportService get instance {
    _instance ??= ProfileExportService._();
    return _instance!;
  }

  ProfileExportService._();

  ExportStatus _currentStatus = ExportStatus.idle;
  ExportProgress? _currentProgress;

  /// Get current export status
  ExportStatus get currentStatus => _currentStatus;

  /// Get current export progress
  ExportProgress? get currentProgress => _currentProgress;

  /// Create export request
  Future<ExportRequest> createExportRequest({
    required String userId,
    required ExportFormat format,
    required ExportType type,
    List<String>? dataTypes,
    Map<String, dynamic>? options,
    Function(ExportProgress)? onProgress,
  }) async {
    final request = ExportRequest(
      id: _generateExportId(),
      userId: userId,
      format: format,
      type: type,
      dataTypes: dataTypes ?? _getDefaultDataTypes(type),
      requestedAt: DateTime.now(),
      options: options ?? {},
    );

    await _saveExportRequest(request);
    await _processExportRequest(request, onProgress);

    return request;
  }

  /// Process export request
  Future<void> _processExportRequest(
    ExportRequest request,
    Function(ExportProgress)? onProgress,
  ) async {
    try {
      _currentStatus = ExportStatus.preparing;
      _currentProgress = ExportProgress(
        operation: 'Preparing export',
        currentStep: 1,
        totalSteps: 4,
        percentage: 0.0,
        currentItem: 'Initializing',
        itemsProcessed: 0,
        totalItems: 0,
        startTime: DateTime.now(),
      );
      onProgress?.call(_currentProgress!);

      // Step 1: Collect data
      await _updateProgress(1, 4, 25.0, 'Collecting profile data', onProgress);
      final profileData = await _collectProfileData(request);

      // Step 2: Format data
      await _updateProgress(2, 4, 50.0, 'Formatting data', onProgress);
      final formattedData = await _formatData(profileData, request.format);

      // Step 3: Generate file
      await _updateProgress(3, 4, 75.0, 'Generating file', onProgress);
      final filePath = await _generateFile(formattedData, request);

      // Step 4: Complete export
      await _updateProgress(4, 4, 100.0, 'Export completed', onProgress);
      final completedRequest = request.copyWith(
        status: ExportStatus.completed,
        completedAt: DateTime.now(),
        filePath: filePath,
        fileSize: await _getFileSize(filePath),
      );

      await _saveExportRequest(completedRequest);
      _currentStatus = ExportStatus.completed;
    } catch (e) {
      final failedRequest = request.copyWith(
        status: ExportStatus.failed,
        errorMessage: e.toString(),
      );
      await _saveExportRequest(failedRequest);
      _currentStatus = ExportStatus.failed;
    }
  }

  /// Get export history
  Future<List<ExportRequest>> getExportHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_exportHistoryKey);
    
    if (historyJson != null) {
      try {
        final historyList = json.decode(historyJson) as List;
        return historyList
            .map((item) => ExportRequest.fromJson(item))
            .where((request) => request.userId == userId)
            .toList();
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  /// Get export settings
  Future<Map<String, dynamic>> getExportSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_exportSettingsKey);
    
    if (settingsJson != null) {
      try {
        return json.decode(settingsJson);
      } catch (e) {
        return _getDefaultExportSettings();
      }
    }
    
    return _getDefaultExportSettings();
  }

  /// Update export settings
  Future<void> updateExportSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_exportSettingsKey, json.encode(settings));
  }

  /// Get available export formats
  List<Map<String, dynamic>> getAvailableFormats() {
    return [
      {
        'format': ExportFormat.json,
        'name': 'JSON',
        'extension': 'json',
        'description': 'Structured data format',
        'icon': 'code',
        'color': 0xFF10B981,
        'enabled': true,
      },
      {
        'format': ExportFormat.csv,
        'name': 'CSV',
        'extension': 'csv',
        'description': 'Comma-separated values',
        'icon': 'table_chart',
        'color': 0xFF3B82F6,
        'enabled': true,
      },
      {
        'format': ExportFormat.pdf,
        'name': 'PDF',
        'extension': 'pdf',
        'description': 'Portable document format',
        'icon': 'picture_as_pdf',
        'color': 0xFFEF4444,
        'enabled': true,
      },
      {
        'format': ExportFormat.html,
        'name': 'HTML',
        'extension': 'html',
        'description': 'Web page format',
        'icon': 'language',
        'color': 0xFF8B5CF6,
        'enabled': true,
      },
      {
        'format': ExportFormat.xml,
        'name': 'XML',
        'extension': 'xml',
        'description': 'Extensible markup language',
        'icon': 'code',
        'color': 0xFF6B7280,
        'enabled': true,
      },
      {
        'format': ExportFormat.txt,
        'name': 'TXT',
        'extension': 'txt',
        'description': 'Plain text format',
        'icon': 'text_fields',
        'color': 0xFF1F2937,
        'enabled': true,
      },
    ];
  }

  /// Get available export types
  List<Map<String, dynamic>> getAvailableTypes() {
    return [
      {
        'type': ExportType.full,
        'name': 'Full Export',
        'description': 'Export all profile data',
        'icon': 'download',
        'color': 0xFF10B981,
        'dataTypes': ['profile', 'photos', 'messages', 'analytics', 'settings'],
      },
      {
        'type': ExportType.basic,
        'name': 'Basic Export',
        'description': 'Export basic profile information',
        'icon': 'person',
        'color': 0xFF3B82F6,
        'dataTypes': ['profile'],
      },
      {
        'type': ExportType.photos,
        'name': 'Photos Only',
        'description': 'Export profile photos',
        'icon': 'photo_library',
        'color': 0xFF8B5CF6,
        'dataTypes': ['photos'],
      },
      {
        'type': ExportType.messages,
        'name': 'Messages Only',
        'description': 'Export chat messages',
        'icon': 'message',
        'color': 0xFFF59E0B,
        'dataTypes': ['messages'],
      },
      {
        'type': ExportType.analytics,
        'name': 'Analytics Only',
        'description': 'Export analytics data',
        'icon': 'analytics',
        'color': 0xFFEF4444,
        'dataTypes': ['analytics'],
      },
      {
        'type': ExportType.settings,
        'name': 'Settings Only',
        'description': 'Export app settings',
        'icon': 'settings',
        'color': 0xFF6B7280,
        'dataTypes': ['settings'],
      },
      {
        'type': ExportType.custom,
        'name': 'Custom Export',
        'description': 'Choose specific data to export',
        'icon': 'tune',
        'color': 0xFF1F2937,
        'dataTypes': [],
      },
    ];
  }

  /// Get export statistics
  Future<Map<String, dynamic>> getExportStatistics(String userId) async {
    final history = await getExportHistory(userId);
    
    final totalExports = history.length;
    final successfulExports = history.where((r) => r.status == ExportStatus.completed).length;
    final failedExports = history.where((r) => r.status == ExportStatus.failed).length;
    
    final formatCounts = <ExportFormat, int>{};
    final typeCounts = <ExportType, int>{};
    
    for (final request in history) {
      formatCounts[request.format] = (formatCounts[request.format] ?? 0) + 1;
      typeCounts[request.type] = (typeCounts[request.type] ?? 0) + 1;
    }
    
    final topFormats = formatCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(3);
    
    final topTypes = typeCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(3);
    
    return {
      'totalExports': totalExports,
      'successfulExports': successfulExports,
      'failedExports': failedExports,
      'successRate': totalExports > 0 ? (successfulExports / totalExports) * 100 : 0.0,
      'topFormats': topFormats.map((e) => {
        'format': e.key.name,
        'count': e.value,
      }).toList(),
      'topTypes': topTypes.map((e) => {
        'type': e.key.name,
        'count': e.value,
      }).toList(),
      'lastExportDate': history.isNotEmpty ? history.first.requestedAt.toIso8601String() : null,
    };
  }

  /// Cancel current export
  Future<void> cancelCurrentExport() async {
    _currentStatus = ExportStatus.cancelled;
    _currentProgress = null;
  }

  /// Delete export file
  Future<bool> deleteExportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear export history
  Future<void> clearExportHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_exportHistoryKey);
    
    if (historyJson != null) {
      try {
        final historyList = json.decode(historyJson) as List;
        final filteredHistory = historyList
            .map((item) => ExportRequest.fromJson(item))
            .where((request) => request.userId != userId)
            .toList();
        
        await prefs.setString(
          _exportHistoryKey,
          json.encode(filteredHistory.map((r) => r.toJson()).toList()),
        );
      } catch (e) {
        // Handle error
      }
    }
  }

  /// Private helper methods
  Future<void> _updateProgress(
    int currentStep,
    int totalSteps,
    double percentage,
    String currentItem,
    Function(ExportProgress)? onProgress,
  ) async {
    _currentProgress = ExportProgress(
      operation: _currentProgress?.operation ?? 'Processing',
      currentStep: currentStep,
      totalSteps: totalSteps,
      percentage: percentage,
      currentItem: currentItem,
      itemsProcessed: _currentProgress?.itemsProcessed ?? 0,
      totalItems: _currentProgress?.totalItems ?? 0,
      startTime: _currentProgress?.startTime ?? DateTime.now(),
      estimatedCompletion: _calculateEstimatedCompletion(percentage),
    );
    onProgress?.call(_currentProgress!);
  }

  DateTime? _calculateEstimatedCompletion(double percentage) {
    if (percentage <= 0) return null;
    
    final elapsed = DateTime.now().difference(_currentProgress!.startTime);
    final estimatedTotal = Duration(
      milliseconds: (elapsed.inMilliseconds / percentage * 100).round(),
    );
    
    return _currentProgress!.startTime.add(estimatedTotal);
  }

  Future<Map<String, dynamic>> _collectProfileData(ExportRequest request) async {
    // In a real app, this would collect actual profile data
    return {
      'profile': {
        'id': request.userId,
        'name': 'John Doe',
        'age': 25,
        'bio': 'Love to travel and meet new people!',
        'interests': ['Travel', 'Music', 'Photography'],
        'location': 'New York, NY',
        'createdAt': DateTime.now().toIso8601String(),
      },
      'photos': request.dataTypes.contains('photos') ? [
        'photo1.jpg',
        'photo2.jpg',
        'photo3.jpg',
      ] : [],
      'messages': request.dataTypes.contains('messages') ? [
        'message1',
        'message2',
        'message3',
      ] : [],
      'analytics': request.dataTypes.contains('analytics') ? {
        'views': 100,
        'likes': 50,
        'matches': 25,
      } : {},
      'settings': request.dataTypes.contains('settings') ? {
        'theme': 'dark',
        'notifications': true,
        'privacy': 'public',
      } : {},
    };
  }

  Future<String> _formatData(Map<String, dynamic> data, ExportFormat format) async {
    switch (format) {
      case ExportFormat.json:
        return json.encode(data);
      case ExportFormat.csv:
        return _formatAsCSV(data);
      case ExportFormat.html:
        return _formatAsHTML(data);
      case ExportFormat.xml:
        return _formatAsXML(data);
      case ExportFormat.txt:
        return _formatAsTXT(data);
      case ExportFormat.pdf:
        return _formatAsPDF(data);
    }
  }

  String _formatAsCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    
    // Profile data
    if (data['profile'] != null) {
      buffer.writeln('Profile Data');
      buffer.writeln('Field,Value');
      data['profile'].forEach((key, value) {
        buffer.writeln('$key,$value');
      });
      buffer.writeln();
    }
    
    // Photos
    if (data['photos'] != null && data['photos'].isNotEmpty) {
      buffer.writeln('Photos');
      buffer.writeln('Photo');
      for (final photo in data['photos']) {
        buffer.writeln(photo);
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  String _formatAsHTML(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html><head><title>Profile Export</title></head><body>');
    buffer.writeln('<h1>Profile Export</h1>');
    
    // Profile data
    if (data['profile'] != null) {
      buffer.writeln('<h2>Profile Information</h2>');
      buffer.writeln('<ul>');
      data['profile'].forEach((key, value) {
        buffer.writeln('<li><strong>$key:</strong> $value</li>');
      });
      buffer.writeln('</ul>');
    }
    
    // Photos
    if (data['photos'] != null && data['photos'].isNotEmpty) {
      buffer.writeln('<h2>Photos</h2>');
      buffer.writeln('<ul>');
      for (final photo in data['photos']) {
        buffer.writeln('<li>$photo</li>');
      }
      buffer.writeln('</ul>');
    }
    
    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  String _formatAsXML(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<profile>');
    
    // Profile data
    if (data['profile'] != null) {
      buffer.writeln('  <profileData>');
      data['profile'].forEach((key, value) {
        buffer.writeln('    <$key>$value</$key>');
      });
      buffer.writeln('  </profileData>');
    }
    
    // Photos
    if (data['photos'] != null && data['photos'].isNotEmpty) {
      buffer.writeln('  <photos>');
      for (final photo in data['photos']) {
        buffer.writeln('    <photo>$photo</photo>');
      }
      buffer.writeln('  </photos>');
    }
    
    buffer.writeln('</profile>');
    return buffer.toString();
  }

  String _formatAsTXT(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('PROFILE EXPORT');
    buffer.writeln('==============');
    buffer.writeln();
    
    // Profile data
    if (data['profile'] != null) {
      buffer.writeln('PROFILE INFORMATION');
      buffer.writeln('-------------------');
      data['profile'].forEach((key, value) {
        buffer.writeln('$key: $value');
      });
      buffer.writeln();
    }
    
    // Photos
    if (data['photos'] != null && data['photos'].isNotEmpty) {
      buffer.writeln('PHOTOS');
      buffer.writeln('------');
      for (final photo in data['photos']) {
        buffer.writeln('- $photo');
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  String _formatAsPDF(Map<String, dynamic> data) {
    // In a real app, this would generate a proper PDF
    return 'PDF content would be generated here';
  }

  Future<String> _generateFile(String content, ExportRequest request) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_export_${request.id}.${request.format.name}';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsString(content);
    return file.path;
  }

  Future<int> _getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  Future<void> _saveExportRequest(ExportRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_exportHistoryKey);
    
    List<ExportRequest> historyList = [];
    if (historyJson != null) {
      try {
        final historyData = json.decode(historyJson) as List;
        historyList = historyData.map((item) => ExportRequest.fromJson(item)).toList();
      } catch (e) {
        historyList = [];
      }
    }
    
    // Update existing request or add new one
    final existingIndex = historyList.indexWhere((r) => r.id == request.id);
    if (existingIndex >= 0) {
      historyList[existingIndex] = request;
    } else {
      historyList.insert(0, request);
    }
    
    // Keep only last 100 exports to prevent storage bloat
    if (historyList.length > 100) {
      historyList = historyList.take(100).toList();
    }
    
    await prefs.setString(
      _exportHistoryKey,
      json.encode(historyList.map((r) => r.toJson()).toList()),
    );
  }

  List<String> _getDefaultDataTypes(ExportType type) {
    switch (type) {
      case ExportType.full:
        return ['profile', 'photos', 'messages', 'analytics', 'settings'];
      case ExportType.basic:
        return ['profile'];
      case ExportType.photos:
        return ['photos'];
      case ExportType.messages:
        return ['messages'];
      case ExportType.analytics:
        return ['analytics'];
      case ExportType.settings:
        return ['settings'];
      case ExportType.custom:
        return [];
    }
  }

  Map<String, dynamic> _getDefaultExportSettings() {
    return {
      'defaultFormat': ExportFormat.json.name,
      'defaultType': ExportType.basic.name,
      'includeMetadata': true,
      'compressFiles': false,
      'autoDelete': false,
      'autoDeleteDays': 30,
    };
  }

  String _generateExportId() {
    return 'export_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }
}
