import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onMessageChanged;
  final VoidCallback? onSendPressed;
  final VoidCallback? onAttachmentPressed;
  final bool isEnabled;

  const MessageInput({
    Key? key,
    required this.controller,
    this.onMessageChanged,
    this.onSendPressed,
    this.onAttachmentPressed,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            if (widget.onAttachmentPressed != null)
              IconButton(
                onPressed: widget.isEnabled ? widget.onAttachmentPressed : null,
                icon: Icon(
                  Icons.attach_file,
                  color: widget.isEnabled 
                      ? AppColors.textSecondary 
                      : AppColors.greyMedium,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            
            // Text input
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: widget.controller,
                  onChanged: widget.onMessageChanged,
                  enabled: widget.isEnabled,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            
            // Send button
            IconButton(
              onPressed: (_hasText && widget.isEnabled) 
                  ? widget.onSendPressed 
                  : null,
              icon: Icon(
                _hasText ? Icons.send : Icons.mic,
                color: (_hasText && widget.isEnabled) 
                    ? AppColors.primary 
                    : AppColors.greyMedium,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
