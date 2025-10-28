import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/webrtc_service.dart';

/// Voice Call Screen
/// 
/// Full-screen voice call UI with controls:
/// - User profile display
/// - Call duration timer
/// - Mute/unmute microphone
/// - Speaker on/off toggle
/// - End call button
/// - Connection status indicators
class VoiceCallScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;
  final bool isIncoming;

  const VoiceCallScreen({
    Key? key,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with SingleTickerProviderStateMixin {
  final WebRTCService _webrtcService = WebRTCService();
  
  StreamSubscription<CallState>? _callStateSubscription;
  CallState _callState = CallState.idle;
  
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeCall();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCall() async {
    await _webrtcService.initialize();

    // Listen to call state changes
    _callStateSubscription = _webrtcService.callState.listen((state) {
      setState(() {
        _callState = state;
      });

      if (state == CallState.connected) {
        _startCallTimer();
      } else if (state == CallState.ended ||
          state == CallState.rejected ||
          state == CallState.disconnected) {
        _endCall();
      }
    });

    // Start or wait for call
    if (!widget.isIncoming) {
      await _webrtcService.startVoiceCall(widget.userId, widget.userName);
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  void _endCall() {
    _callTimer?.cancel();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _handleAcceptCall() async {
    await _webrtcService.acceptCall();
  }

  Future<void> _handleRejectCall() async {
    _webrtcService.rejectCall();
    Navigator.of(context).pop();
  }

  Future<void> _handleEndCall() async {
    await _webrtcService.endCall();
  }

  Future<void> _toggleMute() async {
    await _webrtcService.toggleMute();
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    await _webrtcService.toggleSpeaker();
    setState(() {});
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _callStateSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            _buildBackgroundGradient(),

            // Content
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildUserAvatar(),
                      const SizedBox(height: 24),
                      _buildUserName(),
                      const SizedBox(height: 12),
                      _buildCallStatus(),
                    ],
                  ),
                ),
                _buildCallControls(),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.background,
            AppColors.background,
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Voice Call',
            style: AppTypography.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildConnectionIndicator(),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    Color indicatorColor;
    String label;

    switch (_callState) {
      case CallState.connected:
        indicatorColor = AppColors.success;
        label = 'Connected';
        break;
      case CallState.connecting:
        indicatorColor = AppColors.warning;
        label = 'Connecting...';
        break;
      case CallState.calling:
        indicatorColor = AppColors.warning;
        label = 'Calling...';
        break;
      case CallState.disconnected:
        indicatorColor = AppColors.error;
        label = 'Disconnected';
        break;
      default:
        indicatorColor = Colors.white54;
        label = 'Idle';
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: widget.userAvatar != null
              ? Image.network(
                  widget.userAvatar!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildAvatarPlaceholder(),
                )
              : _buildAvatarPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: Center(
        child: Text(
          widget.userName.substring(0, 1).toUpperCase(),
          style: AppTypography.h1.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 60,
          ),
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return Text(
      widget.userName,
      style: AppTypography.h2.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCallStatus() {
    String statusText;

    switch (_callState) {
      case CallState.incoming:
        statusText = 'Incoming call...';
        break;
      case CallState.calling:
        statusText = 'Calling...';
        break;
      case CallState.connecting:
        statusText = 'Connecting...';
        break;
      case CallState.connected:
        statusText = _formatDuration(_callDuration);
        break;
      case CallState.ended:
        statusText = 'Call ended';
        break;
      case CallState.rejected:
        statusText = 'Call rejected';
        break;
      case CallState.disconnected:
        statusText = 'Disconnected';
        break;
      default:
        statusText = '';
    }

    return Text(
      statusText,
      style: AppTypography.h4.copyWith(
        color: Colors.white70,
      ),
    );
  }

  Widget _buildCallControls() {
    if (_callState == CallState.incoming) {
      return _buildIncomingCallControls();
    } else {
      return _buildActiveCallControls();
    }
  }

  Widget _buildIncomingCallControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.call_end,
            label: 'Decline',
            color: AppColors.error,
            onPressed: _handleRejectCall,
          ),
          _buildControlButton(
            icon: Icons.call,
            label: 'Accept',
            color: AppColors.success,
            onPressed: _handleAcceptCall,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCallControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _webrtcService.isMuted ? Icons.mic_off : Icons.mic,
            label: _webrtcService.isMuted ? 'Unmute' : 'Mute',
            color: _webrtcService.isMuted ? AppColors.error : Colors.white,
            onPressed: _toggleMute,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End Call',
            color: AppColors.error,
            onPressed: _handleEndCall,
            isPrimary: true,
          ),
          _buildControlButton(
            icon: _webrtcService.isSpeakerOn
                ? Icons.volume_up
                : Icons.volume_down,
            label: _webrtcService.isSpeakerOn ? 'Speaker On' : 'Speaker Off',
            color: _webrtcService.isSpeakerOn ? AppColors.primary : Colors.white,
            onPressed: _toggleSpeaker,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: isPrimary ? 72 : 64,
            height: isPrimary ? 72 : 64,
            decoration: BoxDecoration(
              color: isPrimary ? color : color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: isPrimary ? 36 : 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}
