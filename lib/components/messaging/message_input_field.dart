import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class MessageInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function() onAttachmentTap;
  final Function() onEmojiTap;
  final bool isLoading;
  final String? error;

  const MessageInputField({
    Key? key,
    required this.onSendMessage,
    required this.onAttachmentTap,
    required this.onEmojiTap,
    this.isLoading = false,
    this.error,
  }) : super(key: key);

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isComposing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    widget.onSendMessage(text.trim());
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.errorLight,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.error!,
                          style: AppTypography.bodySmallStyle.copyWith(
                            color: AppColors.errorLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onAttachmentTap,
                    icon: Icon(
                      Icons.attach_file,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: AppTypography.bodyMediumStyle.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackgroundLight,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      style: AppTypography.bodyMediumStyle,
                      maxLines: 5,
                      minLines: 1,
                      onChanged: (text) {
                        setState(() {
                          _isComposing = text.isNotEmpty;
                        });
                      },
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onEmojiTap,
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  IconButton(
                    onPressed: _isComposing && !widget.isLoading
                        ? () => _handleSubmitted(_controller.text)
                        : null,
                    icon: widget.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryLight,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: _isComposing
                                ? AppColors.primaryLight
                                : AppColors.textSecondaryLight,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 