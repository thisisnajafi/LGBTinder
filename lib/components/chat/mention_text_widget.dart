import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import 'mention_input_field.dart';

/// Mention Text Widget
/// 
/// Displays text with highlighted @mentions
/// - Parses mentions from text
/// - Applies custom styling to mentions
/// - Handles tap on mentions
/// - Supports rich text formatting
class MentionTextWidget extends StatelessWidget {
  final String text;
  final List<Mention>? mentions;
  final TextStyle? style;
  final TextStyle? mentionStyle;
  final Function(String userId, String userName)? onMentionTap;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign textAlign;

  const MentionTextWidget({
    Key? key,
    required this.text,
    this.mentions,
    this.style,
    this.mentionStyle,
    this.onMentionTap,
    this.maxLines,
    this.overflow,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mentions == null || mentions!.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    return RichText(
      text: _buildTextSpan(context),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign,
    );
  }

  TextSpan _buildTextSpan(BuildContext context) {
    final defaultStyle = style ??
        AppTypography.body1.copyWith(
          color: Colors.white,
        );

    final defaultMentionStyle = mentionStyle ??
        AppTypography.body1.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        );

    // Sort mentions by start index
    final sortedMentions = List<Mention>.from(mentions!)
      ..sort((a, b) => a.startIndex.compareTo(b.startIndex));

    List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final mention in sortedMentions) {
      // Add text before mention
      if (currentIndex < mention.startIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, mention.startIndex),
            style: defaultStyle,
          ),
        );
      }

      // Add mention span
      final mentionText = text.substring(
        mention.startIndex,
        mention.endIndex.clamp(0, text.length),
      );

      spans.add(
        TextSpan(
          text: mentionText,
          style: defaultMentionStyle,
          recognizer: onMentionTap != null
              ? (TapGestureRecognizer()
                ..onTap = () => onMentionTap!(mention.userId, mention.userName))
              : null,
        ),
      );

      currentIndex = mention.endIndex;
    }

    // Add remaining text after last mention
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: defaultStyle,
        ),
      );
    }

    return TextSpan(children: spans);
  }
}

/// Auto-detect mentions in text
/// 
/// Parses @mentions from plain text without explicit mention metadata
/// Useful for backward compatibility or when mention data is not available
class AutoMentionTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? mentionStyle;
  final Function(String mentionText)? onMentionTap;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign textAlign;

  const AutoMentionTextWidget({
    Key? key,
    required this.text,
    this.style,
    this.mentionStyle,
    this.onMentionTap,
    this.maxLines,
    this.overflow,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildTextSpan(),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign,
    );
  }

  TextSpan _buildTextSpan() {
    final defaultStyle = style ??
        AppTypography.body1.copyWith(
          color: Colors.white,
        );

    final defaultMentionStyle = mentionStyle ??
        AppTypography.body1.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        );

    // Pattern to match @mentions (@ followed by word characters)
    final mentionPattern = RegExp(r'@(\w+)');
    final matches = mentionPattern.allMatches(text);

    if (matches.isEmpty) {
      return TextSpan(text: text, style: defaultStyle);
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      // Add text before mention
      if (currentIndex < match.start) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: defaultStyle,
          ),
        );
      }

      // Add mention span
      final mentionText = match.group(0)!;
      spans.add(
        TextSpan(
          text: mentionText,
          style: defaultMentionStyle,
          recognizer: onMentionTap != null
              ? (TapGestureRecognizer()
                ..onTap = () => onMentionTap!(mentionText))
              : null,
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: defaultStyle,
        ),
      );
    }

    return TextSpan(children: spans);
  }
}

/// Mention Chip Widget
/// 
/// A compact chip-style representation of a mention
/// Useful for showing mentioned users in a list
class MentionChip extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;

  const MentionChip({
    Key? key,
    required this.userName,
    this.avatarUrl,
    this.onTap,
    this.onDelete,
    this.backgroundColor,
    this.textColor,
    this.height = 32,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            if (avatarUrl != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: CircleAvatar(
                  radius: (height - 8) / 2,
                  backgroundImage: NetworkImage(avatarUrl!),
                ),
              ),

            // Name
            Text(
              '@$userName',
              style: AppTypography.caption.copyWith(
                color: textColor ?? AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),

            // Delete button
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: textColor ?? AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mention Badge
/// 
/// Shows a badge indicating user was mentioned
/// Useful for notifications and highlighting
class MentionBadge extends StatelessWidget {
  final int count;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;

  const MentionBadge({
    Key? key,
    this.count = 1,
    this.size = 20,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '@',
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

