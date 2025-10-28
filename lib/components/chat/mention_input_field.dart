import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../models/user.dart';

/// Mention Input Field
/// 
/// Text input field with @mention support for group chats
/// - Detects @ symbol and shows member picker
/// - Highlights mentions in real-time
/// - Returns formatted text with mention metadata
class MentionInputField extends StatefulWidget {
  final TextEditingController controller;
  final List<User> mentionableUsers;
  final Function(String text, List<Mention> mentions) onChanged;
  final Function(String text, List<Mention> mentions)? onSubmitted;
  final String hintText;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextStyle? style;
  final InputDecoration? decoration;

  const MentionInputField({
    Key? key,
    required this.controller,
    required this.mentionableUsers,
    required this.onChanged,
    this.onSubmitted,
    this.hintText = 'Type a message...',
    this.maxLines = 5,
    this.minLines,
    this.enabled = true,
    this.focusNode,
    this.style,
    this.decoration,
  }) : super(key: key);

  @override
  State<MentionInputField> createState() => _MentionInputFieldState();
}

class _MentionInputFieldState extends State<MentionInputField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  
  List<User> _filteredUsers = [];
  List<Mention> _mentions = [];
  String _currentMentionQuery = '';
  int _mentionStartPosition = -1;
  bool _showMentionPicker = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    // Detect @ mention
    if (selection.isValid) {
      final cursorPosition = selection.baseOffset;
      _detectMention(text, cursorPosition);
    }

    widget.onChanged(text, _mentions);
  }

  void _detectMention(String text, int cursorPosition) {
    if (cursorPosition <= 0) {
      _hideMentionPicker();
      return;
    }

    // Find the last @ before cursor
    int atPosition = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        // Check if @ is at start or preceded by space/newline
        if (i == 0 || text[i - 1] == ' ' || text[i - 1] == '\n') {
          atPosition = i;
          break;
        }
      } else if (text[i] == ' ' || text[i] == '\n') {
        // Space or newline found before @, stop searching
        break;
      }
    }

    if (atPosition >= 0) {
      // Extract mention query
      final query = text.substring(atPosition + 1, cursorPosition);
      
      // Show mention picker if query is valid
      if (query.length <= 50 && !query.contains(' ') && !query.contains('\n')) {
        _mentionStartPosition = atPosition;
        _currentMentionQuery = query;
        _filterUsers(query);
        _showMentionPickerOverlay();
      } else {
        _hideMentionPicker();
      }
    } else {
      _hideMentionPicker();
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = widget.mentionableUsers;
      });
    } else {
      setState(() {
        _filteredUsers = widget.mentionableUsers.where((user) {
          final name = user.name?.toLowerCase() ?? '';
          final username = user.username?.toLowerCase() ?? '';
          final queryLower = query.toLowerCase();
          return name.contains(queryLower) || username.contains(queryLower);
        }).toList();
      });
    }
  }

  void _showMentionPickerOverlay() {
    if (_showMentionPicker) {
      _updateOverlay();
      return;
    }

    _showMentionPicker = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideMentionPicker() {
    if (!_showMentionPicker) return;

    _showMentionPicker = false;
    _removeOverlay();
    setState(() {
      _filteredUsers = [];
      _currentMentionQuery = '';
      _mentionStartPosition = -1;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, -200),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppColors.navbarBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: _filteredUsers.isEmpty
                  ? _buildEmptyState()
                  : _buildUserList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'No members found',
        style: AppTypography.body2.copyWith(
          color: Colors.white54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: user.profileImage != null
            ? NetworkImage(user.profileImage!)
            : null,
        child: user.profileImage == null
            ? Text(
                user.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: AppTypography.body1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user.name ?? 'Unknown',
        style: AppTypography.body2.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: user.username != null
          ? Text(
              '@${user.username}',
              style: AppTypography.caption.copyWith(
                color: Colors.white54,
              ),
            )
          : null,
      onTap: () => _insertMention(user),
    );
  }

  void _insertMention(User user) {
    final text = widget.controller.text;
    final displayName = user.username ?? user.name ?? 'Unknown';
    
    // Replace @query with @mention
    final beforeMention = text.substring(0, _mentionStartPosition);
    final afterMention = text.substring(widget.controller.selection.baseOffset);
    final newText = '$beforeMention@$displayName $afterMention';

    // Create mention object
    final mention = Mention(
      userId: user.id,
      userName: user.name ?? 'Unknown',
      startIndex: _mentionStartPosition,
      endIndex: _mentionStartPosition + displayName.length + 1, // +1 for @
    );

    // Update mentions list
    _mentions.add(mention);

    // Update text
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: _mentionStartPosition + displayName.length + 2, // +2 for @ and space
      ),
    );

    _hideMentionPicker();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        style: widget.style ??
            AppTypography.body1.copyWith(
              color: Colors.white,
            ),
        decoration: widget.decoration ??
            InputDecoration(
              hintText: widget.hintText,
              hintStyle: AppTypography.body1.copyWith(
                color: Colors.white38,
              ),
              filled: true,
              fillColor: AppColors.navbarBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
        onSubmitted: (text) {
          widget.onSubmitted?.call(text, _mentions);
        },
      ),
    );
  }
}

/// Mention Model
class Mention {
  final String userId;
  final String userName;
  final int startIndex;
  final int endIndex;

  Mention({
    required this.userId,
    required this.userName,
    required this.startIndex,
    required this.endIndex,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'start_index': startIndex,
        'end_index': endIndex,
      };

  factory Mention.fromJson(Map<String, dynamic> json) {
    return Mention(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      startIndex: json['start_index'] as int,
      endIndex: json['end_index'] as int,
    );
  }
}

