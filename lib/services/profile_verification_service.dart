import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

enum VerificationType {
  photo,
  identity,
  phone,
  email,
  social,
  video,
}

enum VerificationStatus {
  pending,
  approved,
  rejected,
  expired,
  cancelled,
}

class VerificationDocument {
  final String id;
  final VerificationType type;
  final String? imagePath;
  final String? documentNumber;
  final DateTime submittedAt;
  final VerificationStatus status;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final Map<String, dynamic> metadata;

  const VerificationDocument({
    required this.id,
    required this.type,
    this.imagePath,
    this.documentNumber,
    required this.submittedAt,
    this.status = VerificationStatus.pending,
    this.rejectionReason,
    this.reviewedAt,
    this.reviewerId,
    this.metadata = const {},
  });

  VerificationDocument copyWith({
    String? id,
    VerificationType? type,
    String? imagePath,
    String? documentNumber,
    DateTime? submittedAt,
    VerificationStatus? status,
    String? rejectionReason,
    DateTime? reviewedAt,
    String? reviewerId,
    Map<String, dynamic>? metadata,
  }) {
    return VerificationDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      documentNumber: documentNumber ?? this.documentNumber,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerId: reviewerId ?? this.reviewerId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'imagePath': imagePath,
      'documentNumber': documentNumber,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.name,
      'rejectionReason': rejectionReason,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewerId': reviewerId,
      'metadata': metadata,
    };
  }

  factory VerificationDocument.fromJson(Map<String, dynamic> json) {
    return VerificationDocument(
      id: json['id'],
      type: VerificationType.values.firstWhere((e) => e.name == json['type']),
      imagePath: json['imagePath'],
      documentNumber: json['documentNumber'],
      submittedAt: DateTime.parse(json['submittedAt']),
      status: VerificationStatus.values.firstWhere((e) => e.name == json['status']),
      rejectionReason: json['rejectionReason'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewerId: json['reviewerId'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class VerificationResult {
  final bool isVerified;
  final List<VerificationType> verifiedTypes;
  final double verificationScore;
  final DateTime? lastVerifiedAt;
  final String? verificationBadge;
  final Map<String, dynamic> verificationData;

  const VerificationResult({
    required this.isVerified,
    required this.verifiedTypes,
    required this.verificationScore,
    this.lastVerifiedAt,
    this.verificationBadge,
    this.verificationData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'isVerified': isVerified,
      'verifiedTypes': verifiedTypes.map((e) => e.name).toList(),
      'verificationScore': verificationScore,
      'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
      'verificationBadge': verificationBadge,
      'verificationData': verificationData,
    };
  }

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      isVerified: json['isVerified'],
      verifiedTypes: (json['verifiedTypes'] as List)
          .map((e) => VerificationType.values.firstWhere((v) => v.name == e))
          .toList(),
      verificationScore: json['verificationScore'],
      lastVerifiedAt: json['lastVerifiedAt'] != null ? DateTime.parse(json['lastVerifiedAt']) : null,
      verificationBadge: json['verificationBadge'],
      verificationData: Map<String, dynamic>.from(json['verificationData'] ?? {}),
    );
  }
}

class ProfileVerificationService {
  static const String _verificationDocumentsKey = 'verification_documents';
  static const String _verificationResultKey = 'verification_result';
  static const String _verificationSettingsKey = 'verification_settings';
  
  static ProfileVerificationService? _instance;
  static ProfileVerificationService get instance {
    _instance ??= ProfileVerificationService._();
    return _instance!;
  }

  ProfileVerificationService._();

  /// Submit a verification document
  Future<VerificationDocument> submitVerificationDocument({
    required VerificationType type,
    required String imagePath,
    String? documentNumber,
    Map<String, dynamic>? metadata,
  }) async {
    final document = VerificationDocument(
      id: _generateDocumentId(),
      type: type,
      imagePath: imagePath,
      documentNumber: documentNumber,
      submittedAt: DateTime.now(),
      metadata: metadata ?? {},
    );

    await _saveVerificationDocument(document);
    return document;
  }

  /// Get all verification documents
  Future<List<VerificationDocument>> getVerificationDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getString(_verificationDocumentsKey);
    
    if (documentsJson != null) {
      try {
        final documentsList = json.decode(documentsJson) as List;
        return documentsList.map((item) => VerificationDocument.fromJson(item)).toList();
      } catch (e) {
        return [];
      }
    }
    
    return [];
  }

  /// Get verification result
  Future<VerificationResult> getVerificationResult() async {
    final prefs = await SharedPreferences.getInstance();
    final resultJson = prefs.getString(_verificationResultKey);
    
    if (resultJson != null) {
      try {
        final resultMap = json.decode(resultJson);
        return VerificationResult.fromJson(resultMap);
      } catch (e) {
        return _getDefaultVerificationResult();
      }
    }
    
    return _getDefaultVerificationResult();
  }

  /// Update verification document status
  Future<void> updateVerificationStatus(
    String documentId,
    VerificationStatus status, {
    String? rejectionReason,
    String? reviewerId,
  }) async {
    final documents = await getVerificationDocuments();
    final documentIndex = documents.indexWhere((d) => d.id == documentId);
    
    if (documentIndex != -1) {
      documents[documentIndex] = documents[documentIndex].copyWith(
        status: status,
        rejectionReason: rejectionReason,
        reviewedAt: DateTime.now(),
        reviewerId: reviewerId,
      );
      
      await _saveVerificationDocuments(documents);
      await _updateVerificationResult();
    }
  }

  /// Get verification requirements
  Map<VerificationType, Map<String, dynamic>> getVerificationRequirements() {
    return {
      VerificationType.photo: {
        'title': 'Photo Verification',
        'description': 'Take a selfie to verify your identity',
        'instructions': [
          'Take a clear selfie with good lighting',
          'Make sure your face is clearly visible',
          'Avoid wearing sunglasses or hats',
          'Look directly at the camera',
        ],
        'required': true,
        'points': 50,
        'icon': 'photo_camera',
      },
      VerificationType.identity: {
        'title': 'Identity Verification',
        'description': 'Upload a government-issued ID',
        'instructions': [
          'Upload a clear photo of your ID',
          'Make sure all text is readable',
          'Include both front and back if applicable',
          'Ensure the ID is not expired',
        ],
        'required': true,
        'points': 100,
        'icon': 'badge',
      },
      VerificationType.phone: {
        'title': 'Phone Verification',
        'description': 'Verify your phone number',
        'instructions': [
          'Enter your phone number',
          'Receive a verification code via SMS',
          'Enter the code to verify',
        ],
        'required': false,
        'points': 25,
        'icon': 'phone',
      },
      VerificationType.email: {
        'title': 'Email Verification',
        'description': 'Verify your email address',
        'instructions': [
          'Check your email for a verification link',
          'Click the link to verify your email',
        ],
        'required': false,
        'points': 25,
        'icon': 'email',
      },
      VerificationType.social: {
        'title': 'Social Media Verification',
        'description': 'Connect your social media accounts',
        'instructions': [
          'Connect your Instagram, Facebook, or LinkedIn',
          'Verify your account ownership',
        ],
        'required': false,
        'points': 30,
        'icon': 'share',
      },
      VerificationType.video: {
        'title': 'Video Verification',
        'description': 'Record a short video verification',
        'instructions': [
          'Record a 10-second video saying your name',
          'Make sure your face is clearly visible',
          'Speak clearly and look at the camera',
        ],
        'required': false,
        'points': 75,
        'icon': 'videocam',
      },
    };
  }

  /// Get verification progress
  Future<Map<String, dynamic>> getVerificationProgress() async {
    final documents = await getVerificationDocuments();
    final requirements = getVerificationRequirements();
    final result = await getVerificationResult();
    
    int totalRequired = 0;
    int completedRequired = 0;
    int totalOptional = 0;
    int completedOptional = 0;
    int totalPoints = 0;
    int earnedPoints = 0;
    
    for (final requirement in requirements.entries) {
      final type = requirement.key;
      final data = requirement.value;
      final isRequired = data['required'] as bool;
      final points = data['points'] as int;
      
      totalPoints += points;
      
      if (isRequired) {
        totalRequired++;
        final document = documents.firstWhere(
          (d) => d.type == type && d.status == VerificationStatus.approved,
          orElse: () => VerificationDocument(
            id: '',
            type: type,
            submittedAt: DateTime.now(),
            status: VerificationStatus.pending,
          ),
        );
        
        if (document.status == VerificationStatus.approved) {
          completedRequired++;
          earnedPoints += points;
        }
      } else {
        totalOptional++;
        final document = documents.firstWhere(
          (d) => d.type == type && d.status == VerificationStatus.approved,
          orElse: () => VerificationDocument(
            id: '',
            type: type,
            submittedAt: DateTime.now(),
            status: VerificationStatus.pending,
          ),
        );
        
        if (document.status == VerificationStatus.approved) {
          completedOptional++;
          earnedPoints += points;
        }
      }
    }
    
    final completionPercentage = totalRequired > 0 
        ? (completedRequired / totalRequired) * 100 
        : 0.0;
    
    return {
      'totalRequired': totalRequired,
      'completedRequired': completedRequired,
      'totalOptional': totalOptional,
      'completedOptional': completedOptional,
      'completionPercentage': completionPercentage,
      'totalPoints': totalPoints,
      'earnedPoints': earnedPoints,
      'isFullyVerified': completedRequired == totalRequired,
      'verificationScore': result.verificationScore,
      'verifiedTypes': result.verifiedTypes.map((e) => e.name).toList(),
    };
  }

  /// Get verification statistics
  Future<Map<String, dynamic>> getVerificationStats() async {
    final documents = await getVerificationDocuments();
    final result = await getVerificationResult();
    final progress = await getVerificationProgress();
    
    final pendingDocuments = documents.where((d) => d.status == VerificationStatus.pending).length;
    final approvedDocuments = documents.where((d) => d.status == VerificationStatus.approved).length;
    final rejectedDocuments = documents.where((d) => d.status == VerificationStatus.rejected).length;
    
    return {
      'totalDocuments': documents.length,
      'pendingDocuments': pendingDocuments,
      'approvedDocuments': approvedDocuments,
      'rejectedDocuments': rejectedDocuments,
      'isVerified': result.isVerified,
      'verificationScore': result.verificationScore,
      'verifiedTypes': result.verifiedTypes.length,
      'completionPercentage': progress['completionPercentage'],
      'earnedPoints': progress['earnedPoints'],
      'totalPoints': progress['totalPoints'],
    };
  }

  /// Delete verification document
  Future<void> deleteVerificationDocument(String documentId) async {
    final documents = await getVerificationDocuments();
    documents.removeWhere((d) => d.id == documentId);
    await _saveVerificationDocuments(documents);
    await _updateVerificationResult();
  }

  /// Resubmit verification document
  Future<VerificationDocument> resubmitVerificationDocument(
    String documentId, {
    String? newImagePath,
    String? documentNumber,
    Map<String, dynamic>? metadata,
  }) async {
    final documents = await getVerificationDocuments();
    final documentIndex = documents.indexWhere((d) => d.id == documentId);
    
    if (documentIndex != -1) {
      final oldDocument = documents[documentIndex];
      final newDocument = oldDocument.copyWith(
        imagePath: newImagePath ?? oldDocument.imagePath,
        documentNumber: documentNumber ?? oldDocument.documentNumber,
        submittedAt: DateTime.now(),
        status: VerificationStatus.pending,
        rejectionReason: null,
        reviewedAt: null,
        reviewerId: null,
        metadata: metadata ?? oldDocument.metadata,
      );
      
      documents[documentIndex] = newDocument;
      await _saveVerificationDocuments(documents);
      return newDocument;
    }
    
    throw Exception('Document not found');
  }

  /// Private helper methods
  String _generateDocumentId() {
    return 'doc_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  Future<void> _saveVerificationDocument(VerificationDocument document) async {
    final documents = await getVerificationDocuments();
    documents.add(document);
    await _saveVerificationDocuments(documents);
    await _updateVerificationResult();
  }

  Future<void> _saveVerificationDocuments(List<VerificationDocument> documents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _verificationDocumentsKey,
      json.encode(documents.map((d) => d.toJson()).toList()),
    );
  }

  Future<void> _updateVerificationResult() async {
    final documents = await getVerificationDocuments();
    final approvedDocuments = documents.where((d) => d.status == VerificationStatus.approved).toList();
    
    final verifiedTypes = approvedDocuments.map((d) => d.type).toList();
    final isVerified = verifiedTypes.isNotEmpty;
    final verificationScore = _calculateVerificationScore(verifiedTypes);
    final lastVerifiedAt = approvedDocuments.isNotEmpty 
        ? approvedDocuments.map((d) => d.reviewedAt).where((d) => d != null).map((d) => d!).reduce((a, b) => a.isAfter(b) ? a : b)
        : null;
    
    final result = VerificationResult(
      isVerified: isVerified,
      verifiedTypes: verifiedTypes,
      verificationScore: verificationScore,
      lastVerifiedAt: lastVerifiedAt,
      verificationBadge: _getVerificationBadge(verificationScore),
      verificationData: {
        'totalDocuments': documents.length,
        'approvedDocuments': approvedDocuments.length,
        'verificationTypes': verifiedTypes.map((e) => e.name).toList(),
      },
    );
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verificationResultKey, json.encode(result.toJson()));
  }

  double _calculateVerificationScore(List<VerificationType> verifiedTypes) {
    if (verifiedTypes.isEmpty) return 0.0;
    
    final requirements = getVerificationRequirements();
    int totalPoints = 0;
    int earnedPoints = 0;
    
    for (final requirement in requirements.entries) {
      final type = requirement.key;
      final points = requirement.value['points'] as int;
      totalPoints += points;
      
      if (verifiedTypes.contains(type)) {
        earnedPoints += points;
      }
    }
    
    return totalPoints > 0 ? (earnedPoints / totalPoints) * 100 : 0.0;
  }

  String _getVerificationBadge(double score) {
    if (score >= 100) return 'Verified';
    if (score >= 75) return 'Highly Verified';
    if (score >= 50) return 'Partially Verified';
    if (score >= 25) return 'Basic Verification';
    return 'Unverified';
  }

  VerificationResult _getDefaultVerificationResult() {
    return const VerificationResult(
      isVerified: false,
      verifiedTypes: [],
      verificationScore: 0.0,
    );
  }
}
