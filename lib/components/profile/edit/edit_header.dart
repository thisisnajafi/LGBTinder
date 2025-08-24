import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/typography.dart';

class EditHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSavePressed;
  final bool isSaveEnabled;
  final bool isSaving;
  final int completionPercentage;
  final bool showProgress;

  const EditHeader({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.onSavePressed,
    this.isSaveEnabled = false,
    this.isSaving = false,
    this.completionPercentage = 0,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main header row
          Row(
            children: [
              // Back button
              IconButton(
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                color: AppColors.textPrimary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headline6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Save button
              _buildSaveButton(),
            ],
          ),
          
          // Progress bar
          if (showProgress) ...[
            const SizedBox(height: 12),
            _buildProgressBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 60,
        minHeight: 40,
      ),
      child: TextButton(
        onPressed: isSaveEnabled && !isSaving ? onSavePressed : null,
        style: TextButton.styleFrom(
          backgroundColor: isSaveEnabled ? AppColors.primary : AppColors.greyLight,
          foregroundColor: isSaveEnabled ? Colors.white : AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Save',
                style: AppTypography.button.copyWith(
                  color: isSaveEnabled ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$completionPercentage%',
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: completionPercentage / 100,
          backgroundColor: AppColors.greyLight,
          valueColor: AlwaysStoppedAnimation<Color>(
            completionPercentage >= 100 ? AppColors.success : AppColors.primary,
          ),
          minHeight: 4,
        ),
      ],
    );
  }
}
