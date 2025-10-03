import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/colors.dart';
import '../services/haptic_feedback_service.dart';

class ProfileSharingService {
  static final ProfileSharingService _instance = ProfileSharingService._internal();
  factory ProfileSharingService() => _instance;
  ProfileSharingService._internal();

  Future<void> shareProfile({
    required String userName,
    required String userAge,
    required String userBio,
    required String userImageUrl,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 
          "Check out $userName's profile on LGBTinder! 🏳️‍🌈\n\n"
          "Age: $userAge\n"
          "Bio: $userBio\n\n"
          "Download LGBTinder to connect with amazing people!";
      
      await Share.share(
        message,
        subject: 'Profile from LGBTinder',
      );
      
      HapticFeedbackService.success();
    } catch (e) {
      debugPrint('Failed to share profile: $e');
      HapticFeedbackService.error();
    }
  }

  Future<void> shareProfileCard({
    required String userName,
    required String userAge,
    required String userBio,
    required String userImageUrl,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 
          "Check out $userName's profile on LGBTinder! 🏳️‍🌈\n\n"
          "Age: $userAge\n"
          "Bio: $userBio\n\n"
          "Download LGBTinder to connect with amazing people!";
      
      await Share.share(
        message,
        subject: 'Profile Card from LGBTinder',
      );
      
      HapticFeedbackService.success();
    } catch (e) {
      debugPrint('Failed to share profile card: $e');
      HapticFeedbackService.error();
    }
  }

  Future<void> shareToSocialMedia({
    required String platform,
    required String userName,
    required String userAge,
    required String userBio,
    required String userImageUrl,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 
          "Check out $userName's profile on LGBTinder! 🏳️‍🌈\n\n"
          "Age: $userAge\n"
          "Bio: $userBio\n\n"
          "Download LGBTinder to connect with amazing people!";
      
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
          await shareProfile(
            userName: userName,
            userAge: userAge,
            userBio: userBio,
            userImageUrl: userImageUrl,
            customMessage: customMessage,
          );
          return;
        case 'whatsapp':
          url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
          break;
        case 'telegram':
          url = 'https://t.me/share/url?url=${Uri.encodeComponent(message)}';
          break;
        default:
          await shareProfile(
            userName: userName,
            userAge: userAge,
            userBio: userBio,
            userImageUrl: userImageUrl,
            customMessage: customMessage,
          );
          return;
      }
      
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        HapticFeedbackService.success();
      } else {
        await shareProfile(
          userName: userName,
          userAge: userAge,
          userBio: userBio,
          userImageUrl: userImageUrl,
          customMessage: customMessage,
        );
      }
    } catch (e) {
      debugPrint('Failed to share to $platform: $e');
      HapticFeedbackService.error();
    }
  }

  Future<void> copyProfileLink({
    required String userName,
    required String userAge,
    required String userBio,
    String? customMessage,
  }) async {
    try {
      final message = customMessage ?? 
          "Check out $userName's profile on LGBTinder! 🏳️‍🌈\n\n"
          "Age: $userAge\n"
          "Bio: $userBio\n\n"
          "Download LGBTinder to connect with amazing people!";
      
      await Clipboard.setData(ClipboardData(text: message));
      HapticFeedbackService.success();
    } catch (e) {
      debugPrint('Failed to copy profile link: $e');
      HapticFeedbackService.error();
    }
  }
}

class ProfileSharingWidget extends StatefulWidget {
  final String userName;
  final String userAge;
  final String userBio;
  final String userImageUrl;
  final VoidCallback? onShareComplete;
  final VoidCallback? onShareCancel;

  const ProfileSharingWidget({
    Key? key,
    required this.userName,
    required this.userAge,
    required this.userBio,
    required this.userImageUrl,
    this.onShareComplete,
    this.onShareCancel,
  }) : super(key: key);

  @override
  State<ProfileSharingWidget> createState() => _ProfileSharingWidgetState();
}

class _ProfileSharingWidgetState extends State<ProfileSharingWidget>
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
    _messageController.text = "Check out ${widget.userName}'s profile on LGBTinder! 🏳️‍🌈\n\n"
        "Age: ${widget.userAge}\n"
        "Bio: ${widget.userBio}\n\n"
        "Download LGBTinder to connect with amazing people!";
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
                  _buildProfilePreview(),
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
          'Share Profile',
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

  Widget _buildProfilePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
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
                widget.userImageUrl,
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
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: ${widget.userAge}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userBio,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
          maxLines: 4,
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
            onPressed: _selectedPlatform.isEmpty ? null : _shareProfile,
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

  void _shareProfile() async {
    final sharingService = ProfileSharingService();
    
    switch (_selectedPlatform) {
      case 'General':
        await sharingService.shareProfile(
          userName: widget.userName,
          userAge: widget.userAge,
          userBio: widget.userBio,
          userImageUrl: widget.userImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'Twitter':
        await sharingService.shareToSocialMedia(
          platform: 'twitter',
          userName: widget.userName,
          userAge: widget.userAge,
          userBio: widget.userBio,
          userImageUrl: widget.userImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'Facebook':
        await sharingService.shareToSocialMedia(
          platform: 'facebook',
          userName: widget.userName,
          userAge: widget.userAge,
          userBio: widget.userBio,
          userImageUrl: widget.userImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'WhatsApp':
        await sharingService.shareToSocialMedia(
          platform: 'whatsapp',
          userName: widget.userName,
          userAge: widget.userAge,
          userBio: widget.userBio,
          userImageUrl: widget.userImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'Telegram':
        await sharingService.shareToSocialMedia(
          platform: 'telegram',
          userName: widget.userName,
          userAge: widget.userAge,
          userBio: widget.userBio,
          userImageUrl: widget.userImageUrl,
          customMessage: _messageController.text,
        );
        break;
      case 'Copy Link':
        await sharingService.copyProfileLink(
          userName: widget.userName,
          userAge: widget.userAge,
          userBio: widget.userBio,
          customMessage: _messageController.text,
        );
        break;
    }
    
    _controller.reverse().then((_) {
      widget.onShareComplete?.call();
    });
  }
}

class ProfileShareButton extends StatelessWidget {
  final String userName;
  final String userAge;
  final String userBio;
  final String userImageUrl;
  final VoidCallback? onShareComplete;
  final VoidCallback? onShareCancel;

  const ProfileShareButton({
    Key? key,
    required this.userName,
    required this.userAge,
    required this.userBio,
    required this.userImageUrl,
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
        child: ProfileSharingWidget(
          userName: userName,
          userAge: userAge,
          userBio: userBio,
          userImageUrl: userImageUrl,
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

class QuickProfileShare extends StatelessWidget {
  final String userName;
  final String userAge;
  final String userBio;
  final String userImageUrl;

  const QuickProfileShare({
    Key? key,
    required this.userName,
    required this.userAge,
    required this.userBio,
    required this.userImageUrl,
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
            'Share Your Profile',
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
                onTap: () => _copyProfile(),
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
    ProfileSharingService().shareProfile(
      userName: userName,
      userAge: userAge,
      userBio: userBio,
      userImageUrl: userImageUrl,
    );
  }

  void _copyProfile() {
    ProfileSharingService().copyProfileLink(
      userName: userName,
      userAge: userAge,
      userBio: userBio,
    );
  }

  void _shareToTwitter() {
    ProfileSharingService().shareToSocialMedia(
      platform: 'twitter',
      userName: userName,
      userAge: userAge,
      userBio: userBio,
      userImageUrl: userImageUrl,
    );
  }
}
