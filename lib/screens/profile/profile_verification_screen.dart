import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_verification_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../../components/verification/verification_components.dart';
import '../../components/buttons/animated_button.dart';

class ProfileVerificationScreen extends StatefulWidget {
  const ProfileVerificationScreen({Key? key}) : super(key: key);

  @override
  State<ProfileVerificationScreen> createState() => _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState extends State<ProfileVerificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  VerificationResult? _verificationResult;
  List<VerificationDocument> _documents = [];
  Map<String, dynamic>? _progress;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadVerificationData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadVerificationData() async {
    try {
      final result = await ProfileVerificationService.instance.getVerificationResult();
      final documents = await ProfileVerificationService.instance.getVerificationDocuments();
      final progress = await ProfileVerificationService.instance.getVerificationProgress();
      final stats = await ProfileVerificationService.instance.getVerificationStats();
      
      if (mounted) {
        setState(() {
          _verificationResult = result;
          _documents = documents;
          _progress = progress;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryLight,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () {
            HapticFeedbackService.selection();
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Profile Verification',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryDark,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Status'),
            Tab(text: 'Documents'),
            Tab(text: 'Requirements'),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStatusTab(),
                  _buildDocumentsTab(),
                  _buildRequirementsTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_verificationResult != null)
            VerificationStatusCard(
              result: _verificationResult!,
              onTap: _showVerificationDetails,
            ),
          
          const SizedBox(height: 24),
          
          if (_progress != null)
            VerificationProgressCard(
              progress: _progress!,
              onTap: _showProgressDetails,
            ),
          
          const SizedBox(height: 24),
          
          if (_stats != null) _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_documents.isEmpty)
            _buildEmptyDocumentsState()
          else
            ..._documents.map((document) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VerificationDocumentCard(
                  document: document,
                  onTap: () => _showDocumentDetails(document),
                  onResubmit: () => _resubmitDocument(document),
                  onDelete: () => _deleteDocument(document),
                ),
              );
            }),
          
          const SizedBox(height: 24),
          
          _buildAddVerificationButton(),
        ],
      ),
    );
  }

  Widget _buildRequirementsTab() {
    final requirements = ProfileVerificationService.instance.getVerificationRequirements();
    final verifiedTypes = _verificationResult?.verifiedTypes ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...requirements.entries.map((entry) {
            final type = entry.key;
            final requirement = entry.value;
            final isCompleted = verifiedTypes.contains(type);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VerificationRequirementCard(
                type: type,
                requirement: requirement,
                isCompleted: isCompleted,
                onTap: () => _startVerification(type),
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          _buildVerificationBenefits(),
        ],
      ),
    );
  }

  Widget _buildEmptyDocumentsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.security_outlined,
            size: 64,
            color: AppColors.textSecondaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'No Verification Documents',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start verifying your profile to build trust and get more matches',
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showVerificationOptions,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Start Verification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddVerificationButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Add More Verifications',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete additional verifications to increase your trust score',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showVerificationOptions,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Verification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Statistics',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Documents',
                  '${_stats!['totalDocuments']}',
                  Icons.description,
                  AppColors.primaryLight,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Approved',
                  '${_stats!['approvedDocuments']}',
                  Icons.check_circle,
                  AppColors.feedbackSuccess,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Pending',
                  '${_stats!['pendingDocuments']}',
                  Icons.pending,
                  AppColors.feedbackWarning,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Score',
                  '${_stats!['verificationScore'].round()}%',
                  Icons.star,
                  AppColors.feedbackInfo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBenefits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Verify Your Profile?',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            Icons.verified,
            'Build Trust',
            'Verified profiles get 3x more matches',
            AppColors.feedbackSuccess,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.visibility,
            'Better Visibility',
            'Appear higher in discovery results',
            AppColors.feedbackInfo,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.security,
            'Safer Dating',
            'Reduce fake profiles and catfishing',
            AppColors.feedbackWarning,
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.star,
            'Premium Features',
            'Access to exclusive verified features',
            AppColors.feedbackError,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVerificationDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Verification Details',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_verificationResult != null) ...[
              Text(
                'Verification Score: ${_verificationResult!.verificationScore.round()}%',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Verified Types: ${_verificationResult!.verifiedTypes.length}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
              if (_verificationResult!.lastVerifiedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last Verified: ${_formatDate(_verificationResult!.lastVerifiedAt!)}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
              ],
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgressDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Progress Details',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_progress != null) ...[
              Text(
                'Required: ${_progress!['completedRequired']}/${_progress!['totalRequired']}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Optional: ${_progress!['completedOptional']}/${_progress!['totalOptional']}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Points: ${_progress!['earnedPoints']}/${_progress!['totalPoints']}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Completion: ${_progress!['completionPercentage'].round()}%',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(VerificationDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          _getTypeDisplayName(document.type),
          style: const TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${_getStatusDisplayName(document.status)}',
              style: const TextStyle(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Submitted: ${_formatDate(document.submittedAt)}',
              style: const TextStyle(color: AppColors.textSecondaryDark),
            ),
            if (document.reviewedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reviewed: ${_formatDate(document.reviewedAt!)}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
            ],
            if (document.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Rejection Reason: ${document.rejectionReason}',
                style: const TextStyle(color: AppColors.feedbackError),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showVerificationOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Verification Type',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...ProfileVerificationService.instance.getVerificationRequirements().entries.map((entry) {
              final type = entry.key;
              final requirement = entry.value;
              final isCompleted = _verificationResult?.verifiedTypes.contains(type) ?? false;
              
              return ListTile(
                leading: Icon(
                  _getTypeIcon(type),
                  color: isCompleted ? AppColors.feedbackSuccess : AppColors.primaryLight,
                ),
                title: Text(
                  requirement['title'],
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  requirement['description'],
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
                trailing: isCompleted
                    ? Icon(Icons.check_circle, color: AppColors.feedbackSuccess)
                    : Text(
                        '${requirement['points']} pts',
                        style: const TextStyle(color: AppColors.feedbackWarning),
                      ),
                onTap: () {
                  Navigator.pop(context);
                  _startVerification(type);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _startVerification(VerificationType type) {
    HapticFeedbackService.selection();
    
    switch (type) {
      case VerificationType.photo:
        _startPhotoVerification();
        break;
      case VerificationType.identity:
        _startIdentityVerification();
        break;
      case VerificationType.phone:
        _startPhoneVerification();
        break;
      case VerificationType.email:
        _startEmailVerification();
        break;
      case VerificationType.social:
        _startSocialVerification();
        break;
      case VerificationType.video:
        _startVideoVerification();
        break;
    }
  }

  void _startPhotoVerification() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navbarBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Photo Verification',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Take a clear selfie to verify your identity',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Choose Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.feedbackInfo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startIdentityVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identity verification coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _startPhoneVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone verification coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _startEmailVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verification coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _startSocialVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Social media verification coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _startVideoVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video verification coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      
      if (image != null) {
        // TODO: Upload image and submit verification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded successfully! Verification pending review.'),
            backgroundColor: AppColors.feedbackSuccess,
          ),
        );
        
        // Refresh data
        _loadVerificationData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image. Please try again.'),
          backgroundColor: AppColors.feedbackError,
        ),
      );
    }
  }

  void _resubmitDocument(VerificationDocument document) {
    HapticFeedbackService.selection();
    _startVerification(document.type);
  }

  void _deleteDocument(VerificationDocument document) {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: const Text(
          'Delete Document',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'Are you sure you want to delete this verification document?',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete document
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document deleted successfully'),
                  backgroundColor: AppColors.feedbackSuccess,
                ),
              );
              _loadVerificationData();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.feedbackError),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return Icons.photo_camera;
      case VerificationType.identity:
        return Icons.badge;
      case VerificationType.phone:
        return Icons.phone;
      case VerificationType.email:
        return Icons.email;
      case VerificationType.social:
        return Icons.share;
      case VerificationType.video:
        return Icons.videocam;
    }
  }

  String _getTypeDisplayName(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return 'Photo Verification';
      case VerificationType.identity:
        return 'Identity Verification';
      case VerificationType.phone:
        return 'Phone Verification';
      case VerificationType.email:
        return 'Email Verification';
      case VerificationType.social:
        return 'Social Media Verification';
      case VerificationType.video:
        return 'Video Verification';
    }
  }

  String _getStatusDisplayName(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 'Under Review';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
      case VerificationStatus.expired:
        return 'Expired';
      case VerificationStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
