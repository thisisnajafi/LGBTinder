import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/webrtc_service.dart';
import '../models/user.dart';

class VideoCallScreen extends StatefulWidget {
  final User otherUser;
  final bool isIncoming;
  final String? roomId;

  const VideoCallScreen({
    Key? key,
    required this.otherUser,
    this.isIncoming = false,
    this.roomId,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final WebRTCService _webrtcService = WebRTCService();
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isSpeakerEnabled = false;
  bool _isCallActive = false;
  String _callState = 'initializing';
  String _connectionState = 'connecting';

  @override
  void initState() {
    super.initState();
    _initializeCall();
    _setupStreams();
  }

  Future<void> _initializeCall() async {
    try {
      await _webrtcService.initialize();
      
      if (widget.isIncoming) {
        setState(() {
          _callState = 'incoming';
        });
      } else {
        await _startOutgoingCall();
      }
    } catch (e) {
      setState(() {
        _callState = 'error';
      });
      _showErrorDialog('Failed to initialize call: $e');
    }
  }

  void _setupStreams() {
    _webrtcService.callState.listen((state) {
      setState(() {
        _callState = state;
        _isCallActive = state == 'connected' || state == 'answered';
      });
    });

    _webrtcService.connectionState.listen((state) {
      setState(() {
        _connectionState = state;
      });
    });
  }

  Future<void> _startOutgoingCall() async {
    try {
      await _webrtcService.startCall(
        roomId: widget.roomId ?? 'room_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user_id', // This should come from auth provider
        otherUserId: widget.otherUser.id.toString(),
      );
    } catch (e) {
      _showErrorDialog('Failed to start call: $e');
    }
  }

  Future<void> _answerCall() async {
    try {
      // In a real implementation, you would get the offer data from the incoming call
      await _webrtcService.answerCall({
        'roomId': widget.roomId ?? 'room_${DateTime.now().millisecondsSinceEpoch}',
        'fromUserId': widget.otherUser.id.toString(),
        'toUserId': 'current_user_id',
        'offer': {}, // This would contain the actual offer data
      });
    } catch (e) {
      _showErrorDialog('Failed to answer call: $e');
    }
  }

  Future<void> _endCall() async {
    try {
      await _webrtcService.endCall();
      Navigator.pop(context);
    } catch (e) {
      _showErrorDialog('Failed to end call: $e');
    }
  }

  Future<void> _toggleCamera() async {
    try {
      await _webrtcService.toggleCamera();
      setState(() {
        _isVideoEnabled = !_isVideoEnabled;
      });
    } catch (e) {
      _showErrorDialog('Failed to toggle camera: $e');
    }
  }

  Future<void> _toggleMicrophone() async {
    try {
      await _webrtcService.toggleMicrophone();
      setState(() {
        _isAudioEnabled = !_isAudioEnabled;
      });
    } catch (e) {
      _showErrorDialog('Failed to toggle microphone: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _webrtcService.switchCamera();
    } catch (e) {
      _showErrorDialog('Failed to switch camera: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Call Error',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          message,
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: AppTypography.body1.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen)
            if (_isCallActive)
              RTCVideoView(
                _webrtcService.remoteStream,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            else
              _buildCallingScreen(),

            // Local video (picture-in-picture)
            if (_isCallActive && _isVideoEnabled)
              Positioned(
                top: 50,
                right: 20,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RTCVideoView(
                      _webrtcService._localStream,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),

            // Call controls
            _buildCallControls(),

            // Call status
            _buildCallStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildCallingScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.secondary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // User avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: widget.otherUser.images.isNotEmpty
                  ? Image.network(
                      widget.otherUser.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.otherUser.name,
            style: AppTypography.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getCallStatusText(),
            style: AppTypography.body1.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Call duration and status
          if (_isCallActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getConnectionStatusText(),
                style: AppTypography.body2.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 20),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Camera toggle
              _buildControlButton(
                icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                onPressed: _toggleCamera,
                backgroundColor: _isVideoEnabled ? Colors.white24 : Colors.red,
              ),
              
              // Microphone toggle
              _buildControlButton(
                icon: _isAudioEnabled ? Icons.mic : Icons.mic_off,
                onPressed: _toggleMicrophone,
                backgroundColor: _isAudioEnabled ? Colors.white24 : Colors.red,
              ),
              
              // Switch camera
              _buildControlButton(
                icon: Icons.switch_camera,
                onPressed: _switchCamera,
                backgroundColor: Colors.white24,
              ),
              
              // Speaker toggle
              _buildControlButton(
                icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_down,
                onPressed: () {
                  setState(() {
                    _isSpeakerEnabled = !_isSpeakerEnabled;
                  });
                },
                backgroundColor: _isSpeakerEnabled ? AppColors.primary : Colors.white24,
              ),
              
              // End call
              _buildControlButton(
                icon: Icons.call_end,
                onPressed: _endCall,
                backgroundColor: Colors.red,
                isEndCall: true,
              ),
            ],
          ),
          
          // Answer/Decline buttons for incoming calls
          if (_callState == 'incoming') ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.call_end,
                  onPressed: _endCall,
                  backgroundColor: Colors.red,
                  isEndCall: true,
                ),
                _buildControlButton(
                  icon: Icons.call,
                  onPressed: _answerCall,
                  backgroundColor: Colors.green,
                  isEndCall: true,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isEndCall ? 60 : 50,
        height: isEndCall ? 60 : 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isEndCall ? 30 : 24,
        ),
      ),
    );
  }

  Widget _buildCallStatus() {
    if (_callState == 'error') {
      return Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Call failed. Please try again.',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  String _getCallStatusText() {
    switch (_callState) {
      case 'calling':
        return 'Calling...';
      case 'incoming':
        return 'Incoming call';
      case 'answered':
        return 'Call answered';
      case 'connected':
        return 'Connected';
      case 'ended':
        return 'Call ended';
      case 'error':
        return 'Call failed';
      default:
        return 'Initializing...';
    }
  }

  String _getConnectionStatusText() {
    switch (_connectionState) {
      case 'connected':
        return 'Connected';
      case 'connecting':
        return 'Connecting...';
      case 'disconnected':
        return 'Disconnected';
      case 'error':
        return 'Connection error';
      default:
        return 'Connecting...';
    }
  }

  @override
  void dispose() {
    _webrtcService.dispose();
    super.dispose();
  }
}
