import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../../theme/colors.dart';

/// Emoji Picker Widget
/// 
/// Full-featured emoji picker with:
/// - All emoji categories
/// - Search functionality
/// - Recent emojis
/// - Frequently used emojis
class EmojiPickerWidget extends StatefulWidget {
  final Function(String) onEmojiSelected;
  final double height;

  const EmojiPickerWidget({
    Key? key,
    required this.onEmojiSelected,
    this.height = 250,
  }) : super(key: key);

  @override
  State<EmojiPickerWidget> createState() => _EmojiPickerWidgetState();
}

class _EmojiPickerWidgetState extends State<EmojiPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          widget.onEmojiSelected(emoji.emoji);
        },
        onBackspacePressed: () {
          // Handle backspace
        },
        config: Config(
          height: widget.height,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            backgroundColor: AppColors.navbarBackground,
            columns: 7,
            emojiSizeMax: 28 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.20
                    : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            recentsLimit: 28,
            noRecents: const Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: Colors.white24),
              textAlign: TextAlign.center,
            ),
            loadingIndicator: const SizedBox.shrink(),
            buttonMode: ButtonMode.MATERIAL,
          ),
          skinToneConfig: const SkinToneConfig(
            enabled: true,
            dialogBackgroundColor: Color(0xFF1E1E2E),
          ),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: AppColors.cardBackgroundLight,
            iconColor: Colors.white54,
            iconColorSelected: AppColors.primary,
            indicatorColor: AppColors.primary,
            backspaceColor: AppColors.primary,
            categoryIcons: const CategoryIcons(),
            dividerColor: Colors.white24,
            showBackspaceButton: false,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(
            enabled: false,
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: AppColors.navbarBackground,
            buttonColor: AppColors.primary,
            buttonIconColor: Colors.white,
            hintText: 'Search emoji...',
            hintTextStyle: const TextStyle(
              color: Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact Emoji Picker (for inline use)
class CompactEmojiPickerWidget extends StatelessWidget {
  final Function(String) onEmojiSelected;
  final VoidCallback? onClose;

  const CompactEmojiPickerWidget({
    Key? key,
    required this.onEmojiSelected,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Emoji picker
          EmojiPickerWidget(
            onEmojiSelected: (emoji) {
              onEmojiSelected(emoji);
              onClose?.call();
            },
            height: 300,
          ),
        ],
      ),
    );
  }

  /// Show emoji picker as bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Function(String) onEmojiSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CompactEmojiPickerWidget(
        onEmojiSelected: (emoji) {
          onEmojiSelected(emoji);
          Navigator.pop(context);
        },
      ),
    );
  }
}

