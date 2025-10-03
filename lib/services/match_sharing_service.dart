import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../services/haptic_feedback_service.dart';

class MatchSharingService {
  static final MatchSharingService _instance = MatchSharingService._internal();
  factory MatchSharingService() => _instance;
  MatchSharingService._internal();

  Future<void> shareMatch({
    required String matchName,
    required String matchImageUrl,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 
          "I just matched with $matchName on LGBTinder! 🏳️‍🌈💕";
      
      await Share.share(
        message,
        subject: 'New Match on LGBTinder',
      );
      
      HapticFeedbackService.success();
    } catch (e) {
      debugPrint('Failed to share match: $e');
      HapticFeedbackService.error();
    }
  }

  Future<void> shareMatchImage({
    required String matchName,
    required String matchImageUrl,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 
          "I just matched with $matchName on LGBTinder! 🏳️‍🌈💕";
      
      await Share.shareXFiles(
        [], // Would need to download and convert image to XFile
        text: message,
        subject: 'New Match on LGBTinder',
      );
      
      HapticFeedbackService.success();
    } catch (e) {
      debugPrint('Failed to share match image: $e');
      HapticFeedbackService.error();
    }
  }

  Future<void> shareToSocialMedia({
    required String platform,
    required String matchName,
    required String matchImageUrl,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 
          "I just matched with $matchName on LGBTinder! 🏳️‍🌈💕";
      
      String url = '';
      switch (platform.toLowerCase()) {
        case 'twitter':
          url = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(message)}';
          break;
        case 'facebook':
          url = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(message)}';
          break;
        case 'instagram':
          // Instagram doesn't support direct sharing via URL
          await shareMatch(matchName: matchName, matchImageUrl: matchImageUrl, customMessage: customMessage);
          return;
        case 'whatsapp':
          url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
          break;
        case 'telegram':
          url = 'https://t.me/share/url?url=${Uri.encodeComponent(message)}';
          break;
        default:
          await shareMatch(matchName: matchName, matchImageUrl: matchImageUrl, customMessage: customMessage);
          return;
      }
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        HapticFeedbackService.success();
      } else {
        await shareMatch(matchName: matchName, matchImageUrl: matchImageUrl, customMessage: customMessage);
      }
    } catch (e) {
      debugPrint('Failed to share to $platform: $e');
      HapticFeedbackService.error();
    }
  }

  Future<void> copyMatchLink({
    required String matchName,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 
          "I just matched with $matchName on LGBTinder! 🏳️‍🌈💕";
      
      await Clipboard.setData(ClipboardData(text: message));
      HapticFeedbackService.success();
    } catch (e) {
      debugPrint('Failed to copy match link: $e');
      HapticFeedbackService.error();
    }
  }
}

class MatchSharingWidget extends StatefulWidget {
  final String matchName;
  final String matchImageUrl;
  final VoidCallback? onShareComplete;
  final VoidCallback? onShareCancel;

  const MatchSharingWidget({
    Key? key,
    required this.matchName,
    required this.matchImageUrl,
    this.onShareComplete,
    this.onShareCancel,
  }) : super(key: key);

  @override
  State<MatchSharingWidget> createState() => _MatchSharingWidgetState();
}

class _MatchSharingWidgetState extends State<MatchSharingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  final TextEditingController _messageController = TextEditingController();
  String _selectedPlatform = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _messageController.text = "I just matched with ${widget.matchName} on LGBTinder! 🏳️‍🌈💕";
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.navbarBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildMatchPreview(),
                  const SizedBox(height: 20),
                  _buildMessageInput(),
                  const SizedBox(height: 20),
                  _buildSharingOptions(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.share,
          color: AppColors.primaryLight,
          size: 28,
        ),
        const SizedBox(width: 12),
        const Text(
          'Share Your Match',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            _controller.reverse().then((_) {
              widget.onShareCancel?.call();
            });
          },
          child: Icon(
            Icons.close,
            color: AppColors.textSecondaryDark,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.prideRed.withOpacity(0.1),
            AppColors.pridePurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryLight,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                widget.matchImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceSecondary,
                  child: Icon(
                    Icons.person,
                    color: AppColors.textSecondaryDark,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'It\'s a Match!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You and ${widget.matchName} liked each other',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customize your message:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your message...',
            hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
          ),
          style: const TextStyle(color: AppColors.textPrimaryDark),
        ),
      ],
    );
  }

  Widget _buildSharingOptions() {
    final platforms = [
      {'name': 'General', 'icon': Icons.share, 'color': AppColors.primaryLight},
      {'name': 'Twitter', 'icon': Icons.alternate_email, 'color': Colors.blue},
      {'name': 'Facebook', 'icon': Icons.facebook, 'color': Colors.blue[800]!},
      {'name': 'WhatsApp', 'icon': Icons.message, 'color': Colors.green},
      {'name': 'Telegram', 'icon': Icons.send, 'color': Colors.blue[600]!},
      {'name': 'Copy Link', 'icon': Icons.copy, 'color': AppColors.textSecondaryDark},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share to:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: platforms.map((platform) {
            final isSelected = _selectedPlatform == platform['name'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlatform = platform['name'] as String;
                });
                HapticFeedbackService.selection();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (platform['color'] as Color).withOpacity(0.2)
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? platform['color'] as Color
                        : AppColors.borderDefault,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      platform['icon'] as IconData,
                      color: platform['color'] as Color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      platform['name'] as String,
                      style: TextStyle(
                        color: platform['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _controller.reverse().then((_) {
                widget.onShareCancel?.call();
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.borderDefault),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _selectedPlatform.isEmpty ? null : _shareMatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Share',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _shareMatch() async {
    final sharingService = MatchSharingService();
    
    switch (_selectedPlatform) {
      case 'General':
        await sharingService.shareMatch(
          matchName: widget.matchName,
          matchImageUrl: widget.matchImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'Twitter':
        await sharingService.shareToSocialMedia(
          platform: 'twitter',
          matchName: widget.matchName,
          matchImageUrl: widget.matchImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'Facebook':
        await sharingService.shareToSocialMedia(
          platform: 'facebook',
          matchName: widget.matchName,
          matchImageUrl: widget.matchImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'WhatsApp':
        await sharingService.shareToSocialMedia(
          platform: 'whatsapp',
          matchName: widget.matchName,
          matchImageUrl: widget.matchImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'Telegram':
        await sharingService.shareToSocialMedia(
          platform: 'telegram',
          matchName: widget.matchName,
          matchImageUrl: widget.matchImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'Copy Link':
        await sharingService.copyMatchLink(
          matchName: widget.matchName,
          customMessage: _messageController.text,
        );
        break;
    }
    
    _controller.reverse().then((_) {
      widget.onShareComplete?.call();
    });
  }
}

class ShareButton extends StatelessWidget {
  final String matchName;
  final String matchImageUrl;
  final VoidCallback? onShareComplete;
  final VoidCallback? onShareCancel;

  const ShareButton({
    Key? key,
    required this.matchName,
    required this.matchImageUrl,
    this.onShareComplete,
    this.onShareCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        _showShareDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.share,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: MatchSharingWidget(
          matchName: matchName,
          matchImageUrl: matchImageUrl,
          onShareComplete: () {
            Navigator.pop(context);
            onShareComplete?.call();
          },
          onShareCancel: () {
            Navigator.pop(context);
            onShareCancel?.call();
          },
        ),
      ),
    );
  }
}

class QuickShareWidget extends StatelessWidget {
  final String matchName;
  final String matchImageUrl;

  const QuickShareWidget({
    Key? key,
    required this.matchName,
    required this.matchImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Share Your Match',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickShareButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () => _quickShare(),
              ),
              _buildQuickShareButton(
                icon: Icons.copy,
                label: 'Copy',
                onTap: () => _copyMatch(),
              ),
              _buildQuickShareButton(
                icon: Icons.alternate_email,
                label: 'Twitter',
                onTap: () => _shareToTwitter(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryLight,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  void _quickShare() {
    MatchSharingService().shareMatch(
      matchName: matchName,
      matchImageUrl: matchImageUrl,
    );
  }

  void _copyMatch() {
    MatchSharingService().copyMatchLink(matchName: matchName);
  }

  void _shareToTwitter() {
    MatchSharingService().shareToSocialMedia(
      platform: 'twitter',
      matchName: matchName,
      matchImageUrl: matchImageUrl,
    );
  }
}
