import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Cancellation Reason Dialog
/// 
/// Collects feedback from users canceling their subscription
/// - Predefined cancellation reasons
/// - Optional text feedback
/// - Analytics for improving service
class CancellationReasonDialog extends StatefulWidget {
  final Function(CancellationFeedback feedback)? onSubmit;

  const CancellationReasonDialog({
    Key? key,
    this.onSubmit,
  }) : super(key: key);

  @override
  State<CancellationReasonDialog> createState() =>
      _CancellationReasonDialogState();

  /// Show cancellation reason dialog
  static Future<CancellationFeedback?> show(
    BuildContext context, {
    Function(CancellationFeedback feedback)? onSubmit,
  }) {
    return showDialog<CancellationFeedback>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CancellationReasonDialog(
        onSubmit: onSubmit,
      ),
    );
  }
}

class _CancellationReasonDialogState extends State<CancellationReasonDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  String? _selectedReason;
  bool _showFeedbackField = false;

  final List<CancellationReason> _reasons = [
    CancellationReason(
      id: 'too_expensive',
      title: 'Too expensive',
      icon: Icons.attach_money,
      color: AppColors.warning,
    ),
    CancellationReason(
      id: 'not_using',
      title: 'Not using it enough',
      icon: Icons.schedule,
      color: AppColors.primary,
    ),
    CancellationReason(
      id: 'found_match',
      title: 'Found a match',
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    CancellationReason(
      id: 'technical_issues',
      title: 'Technical issues',
      icon: Icons.bug_report,
      color: AppColors.error,
    ),
    CancellationReason(
      id: 'privacy_concerns',
      title: 'Privacy concerns',
      icon: Icons.privacy_tip,
      color: Colors.orange,
    ),
    CancellationReason(
      id: 'missing_features',
      title: 'Missing features',
      icon: Icons.extension,
      color: Colors.blue,
    ),
    CancellationReason(
      id: 'trying_another',
      title: 'Trying another app',
      icon: Icons.compare_arrows,
      color: Colors.purple,
    ),
    CancellationReason(
      id: 'other',
      title: 'Other reason',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reason'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final feedback = CancellationFeedback(
      reasonId: _selectedReason!,
      reasonTitle: _reasons
          .firstWhere((r) => r.id == _selectedReason)
          .title,
      additionalFeedback: _feedbackController.text.trim().isNotEmpty
          ? _feedbackController.text.trim()
          : null,
      timestamp: DateTime.now(),
    );

    widget.onSubmit?.call(feedback);
    Navigator.of(context).pop(feedback);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReasonsList(),
                    if (_showFeedbackField || _selectedReason == 'other') ...[
                      const SizedBox(height: 24),
                      _buildFeedbackField(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.feedback_outlined,
              color: AppColors.error,
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            'Help us improve',
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Please let us know why you\'re canceling',
            style: AppTypography.body2.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReasonsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _reasons.map((reason) => _buildReasonTile(reason)).toList(),
    );
  }

  Widget _buildReasonTile(CancellationReason reason) {
    final isSelected = _selectedReason == reason.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason.id;
          if (reason.id == 'other') {
            _showFeedbackField = true;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? reason.color.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? reason.color : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: reason.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                reason.icon,
                color: reason.color,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                reason.title,
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: reason.color,
                size: 24,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional feedback (optional)',
          style: AppTypography.body2.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _feedbackController,
          maxLines: 4,
          maxLength: 500,
          style: AppTypography.body1.copyWith(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Tell us more about your experience...',
            hintStyle: AppTypography.body1.copyWith(
              color: Colors.white38,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            counterStyle: AppTypography.caption.copyWith(
              color: Colors.white54,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Your feedback helps us improve the app for everyone',
          style: AppTypography.caption.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedReason != null
                    ? AppColors.error
                    : Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Submit & Cancel Subscription',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Back button
          TextButton(
            onPressed: _cancel,
            child: Text(
              'Go back',
              style: AppTypography.body2.copyWith(
                color: Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cancellation Reason Model
class CancellationReason {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  CancellationReason({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

/// Cancellation Feedback Model
class CancellationFeedback {
  final String reasonId;
  final String reasonTitle;
  final String? additionalFeedback;
  final DateTime timestamp;

  CancellationFeedback({
    required this.reasonId,
    required this.reasonTitle,
    this.additionalFeedback,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason_id': reasonId,
      'reason_title': reasonTitle,
      'additional_feedback': additionalFeedback,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CancellationFeedback.fromJson(Map<String, dynamic> json) {
    return CancellationFeedback(
      reasonId: json['reason_id'] as String,
      reasonTitle: json['reason_title'] as String,
      additionalFeedback: json['additional_feedback'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

