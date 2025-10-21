import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/user.dart';
import '../utils/haptic_feedback_service.dart';

class VoiceCallScreen extends StatefulWidget {
  final User otherUser;
  final bool isIncoming;
  final String? roomId;

  const VoiceCallScreen({
    Key? key,
    required this.otherUser,
    this.isIncoming = false,
    this.roomId,
  }) : super(key: key);

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isAudioEnabled = true;
  bool _isSpeakerEnabled = false;
  bool _isCallActive = false;
  String _callState = 'initializing';
  String _connectionState = 'connecting';
  Duration _callDuration = Duration.zero;
  late DateTime _callStartTime;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCall();
    _startCallTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  void _initializeCall() {
    if (widget.isIncoming) {
      setState(() {
        _callState = 'incoming';
      });
    } else {
      _startOutgoingCall();
    }
  }

  void _startOutgoingCall() {
    setState(() {
      _callState = 'calling';
    });
    
    // Simulate call connection after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _callState = 'connected';
          _isCallActive = true;
          _connectionState = 'connected';
          _callStartTime = DateTime.now();
        });
        HapticFeedbackService.mediumImpact();
      }
    });
  }

  void _answerCall() {
    setState(() {
      _callState = 'connected';
      _isCallActive = true;
      _connectionState = 'connected';
      _callStartTime = DateTime.now();
    });
    HapticFeedbackService.mediumImpact();
  }

  void _endCall() {
    HapticFeedbackService.heavyImpact();
    Navigator.pop(context);
  }

  void _toggleMicrophone() {
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
    HapticFeedbackService.lightImpact();
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerEnabled = !_isSpeakerEnabled;
    });
    HapticFeedbackService.lightImpact();
  }

  void _startCallTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isCallActive) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime);
        });
        _startCallTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main call screen
            _buildCallScreen(),

            // Call controls
            _buildCallControls(),

            // Call status
            _buildCallStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildCallScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryLight.withOpacity(0.9),
            AppColors.secondaryLight.withOpacity(0.9),
            AppColors.accent.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // User avatar with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _callState == 'calling' ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.otherUser.images?.isNotEmpty == true
                        ? Image.network(
                            widget.otherUser.images!.first.url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            widget.otherUser.firstName ?? 'Unknown',
            style: AppTypography.headlineLargeStyle.copyWith(
              color: Colors.white,
              fontWeight: AppTypography.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getCallStatusText(),
            style: AppTypography.bodyLargeStyle.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (_isCallActive) ...[
            const SizedBox(height: 20),
            Text(
              _formatDuration(_callDuration),
              style: AppTypography.titleLargeStyle.copyWith(
                color: Colors.white,
                fontWeight: AppTypography.semiBold,
                letterSpacing: 2,
              ),
            ),
          ],
          
          // Audio visualization
          if (_isCallActive) ...[
            const SizedBox(height: 40),
            _buildAudioVisualization(),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: 80,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildAudioVisualization() {
    return Container(
      height: 60,
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            width: 8,
            height: 20 + (index * 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCallControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Call duration and status
            if (_isCallActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getConnectionStatusText(),
                  style: AppTypography.bodyMediumStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Microphone toggle
                _buildControlButton(
                  icon: _isAudioEnabled ? Icons.mic : Icons.mic_off,
                  onPressed: _toggleMicrophone,
                  backgroundColor: _isAudioEnabled ? Colors.white.withOpacity(0.2) : Colors.red,
                ),
                
                // Speaker toggle
                _buildControlButton(
                  icon: _isSpeakerEnabled ? Icons.volume_up : Icons.volume_down,
                  onPressed: _toggleSpeaker,
                  backgroundColor: _isSpeakerEnabled ? AppColors.primaryLight : Colors.white.withOpacity(0.2),
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
              color: Colors.black.withOpacity(0.3),
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
            color: Colors.red.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Call failed. Please try again.',
                  style: AppTypography.bodyLargeStyle.copyWith(
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
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}
