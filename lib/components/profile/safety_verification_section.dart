import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class SafetyVerificationSection extends StatelessWidget {
  final UserVerification? verification;
  final VoidCallback? onVerifyPressed;

  const SafetyVerificationSection({
    Key? key,
    this.verification,
    this.onVerifyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (verification == null) {
      return _buildEmptyState();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Safety & Verification',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Verification Score
          _buildVerificationScore(),
          const SizedBox(height: 16),
          // Verification Status Items
          ..._buildVerificationItems(),
        ],
      ),
    );
  }

  Widget _buildVerificationScore() {
    final score = verification!.verificationScore;
    final hasVerifiedProfile = verification!.hasVerifiedProfile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasVerifiedProfile ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasVerifiedProfile ? Colors.green[200]! : Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasVerifiedProfile ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasVerifiedProfile ? Icons.verified : Icons.pending,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasVerifiedProfile ? 'Verified Profile' : 'Verification In Progress',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasVerifiedProfile ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score% Complete',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    hasVerifiedProfile ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVerificationItems() {
    final items = <Widget>[];

    // Photo Verification
    items.add(_buildVerificationItem(
      title: 'Photo Verification',
      description: 'Verify your identity with a selfie',
      isVerified: verification!.photoVerified,
      icon: Icons.camera_alt,
      onVerify: onVerifyPressed,
    ));

    // ID Verification
    items.add(_buildVerificationItem(
      title: 'ID Verification',
      description: 'Verify with government-issued ID',
      isVerified: verification!.idVerified,
      icon: Icons.credit_card,
      onVerify: onVerifyPressed,
    ));

    // Video Verification
    items.add(_buildVerificationItem(
      title: 'Video Verification',
      description: 'Record a short video verification',
      isVerified: verification!.videoVerified,
      icon: Icons.videocam,
      onVerify: onVerifyPressed,
    ));

    return items;
  }

  Widget _buildVerificationItem({
    required String title,
    required String description,
    required bool isVerified,
    required IconData icon,
    VoidCallback? onVerify,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVerified ? Colors.green[200]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isVerified ? Colors.green : Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
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
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isVerified ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isVerified)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            )
          else if (onVerify != null)
            TextButton(
              onPressed: onVerify,
              child: const Text(
                'Verify Now',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Verification Not Available',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Verification features will be available soon',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
