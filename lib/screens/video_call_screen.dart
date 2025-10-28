import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/webrtc_service.dart';

/// Video Call Screen
/// 
/// Full-screen video call UI with advanced controls:
/// - Local and remote video streams
/// - Camera switching (front/back)
/// - Video enable/disable
/// - Picture-in-picture mode
/// - Full-screen toggle
/// - All voice call features (mute, speaker, etc.)
class VideoCallScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;
  final bool isIncoming;

  const VideoCallScreen({
    Key? key,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final WebRTCService _webrtcService = WebRTCService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  StreamSubscription<CallState>? _callStateSubscription;
  StreamSubscription<MediaStream>? _localStreamSubscription;
  StreamSubscription<MediaStream>? _remoteStreamSubscription;
  
  CallState _callState = CallState.idle;
  Timer? _callTimer;
  Duration _callDuration = Duration.zero;
  
  bool _isLocalPiP = true; // Picture-in-picture mode
  bool _isFullScreen = false;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _initializeCall();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
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

    // Listen to local stream
    _localStreamSubscription = _webrtcService.localStream.listen((stream) {
      _localRenderer.srcObject = stream;
      setState(() {});
    });

    // Listen to remote stream
    _remoteStreamSubscription = _webrtcService.remoteStream.listen((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    // Start or wait for call
    if (!widget.isIncoming) {
      await _webrtcService.startVideoCall(widget.userId, widget.userName);
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

  Future<void> _toggleVideo() async {
    await _webrtcService.toggleVideo();
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    await _webrtcService.toggleSpeaker();
    setState(() {});
  }

  Future<void> _switchCamera() async {
    await _webrtcService.switchCamera();
  }

  void _togglePiP() {
    setState(() {
      _isLocalPiP = !_isLocalPiP;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startControlsTimer();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _callState == CallState.connected) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _controlsTimer?.cancel();
    _callStateSubscription?.cancel();
    _localStreamSubscription?.cancel();
    _remoteStreamSubscription?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Remote video (full screen)
            _buildRemoteVideo(),

            // Local video (PiP or full)
            if (_isLocalPiP)
              _buildLocalVideoPiP()
            else
              _buildLocalVideoFull(),

            // Controls overlay
            if (_showControls || _callState != CallState.connected)
              _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    if (_remoteRenderer.srcObject == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.userAvatar != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(widget.userAvatar!),
                )
              else
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.userName.substring(0, 1).toUpperCase(),
                    style: AppTypography.h1.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                widget.userName,
                style: AppTypography.h3.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getStatusText(),
                style: AppTypography.body1.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: RTCVideoView(
        _remoteRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: false,
      ),
    );
  }

  Widget _buildLocalVideoPiP() {
    return Positioned(
      top: 50,
      right: 16,
      child: GestureDetector(
        onTap: _togglePiP,
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _localRenderer.srcObject != null
                ? RTCVideoView(
                    _localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  )
                : Container(
                    color: Colors.black87,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.white54,
                        size: 32,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalVideoFull() {
    return SizedBox.expand(
      child: _localRenderer.srcObject != null
          ? RTCVideoView(
              _localRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: true,
            )
          : Container(
              color: Colors.black87,
              child: const Center(
                child: Icon(
                  Icons.videocam_off,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            const Spacer(),
            if (_callState == CallState.incoming)
              _buildIncomingCallControls()
            else
              _buildActiveCallControls(),
            const SizedBox(height: 32),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: AppTypography.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _callState == CallState.connected
                    ? _formatDuration(_callDuration)
                    : _getStatusText(),
                style: AppTypography.caption.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isLocalPiP ? Icons.picture_in_picture : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: _togglePiP,
              ),
              IconButton(
                icon: const Icon(
                  Icons.cameraswitch,
                  color: Colors.white,
                ),
                onPressed: _switchCamera,
              ),
            ],
          ),
        ],
      ),
    );
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
            icon: Icons.videocam,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _webrtcService.isMuted ? Icons.mic_off : Icons.mic,
            label: 'Mic',
            color: _webrtcService.isMuted ? AppColors.error : Colors.white,
            onPressed: _toggleMute,
          ),
          _buildControlButton(
            icon: _webrtcService.isVideoEnabled
                ? Icons.videocam
                : Icons.videocam_off,
            label: 'Video',
            color:
                _webrtcService.isVideoEnabled ? Colors.white : AppColors.error,
            onPressed: _toggleVideo,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End',
            color: AppColors.error,
            onPressed: _handleEndCall,
            isPrimary: true,
          ),
          _buildControlButton(
            icon: _webrtcService.isSpeakerOn
                ? Icons.volume_up
                : Icons.volume_down,
            label: 'Speaker',
            color: _webrtcService.isSpeakerOn ? AppColors.primary : Colors.white,
            onPressed: _toggleSpeaker,
          ),
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            label: 'Flip',
            color: Colors.white,
            onPressed: _switchCamera,
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
            width: isPrimary ? 64 : 56,
            height: isPrimary ? 64 : 56,
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
              size: isPrimary ? 32 : 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (_callState) {
      case CallState.incoming:
        return 'Incoming video call...';
      case CallState.calling:
        return 'Calling...';
      case CallState.connecting:
        return 'Connecting...';
      case CallState.connected:
        return 'Connected';
      case CallState.ended:
        return 'Call ended';
      case CallState.rejected:
        return 'Call rejected';
      case CallState.disconnected:
        return 'Disconnected';
      default:
        return '';
    }
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
