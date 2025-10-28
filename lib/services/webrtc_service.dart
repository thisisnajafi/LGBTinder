import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/websocket_service.dart';
import '../services/auth_service.dart';

/// WebRTC Service
/// 
/// Manages peer-to-peer video and voice calling using WebRTC
/// Features:
/// - Voice calls
/// - Video calls
/// - Signaling via WebSocket
/// - ICE candidate exchange
/// - Media stream management
class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  final WebSocketService _websocketService = WebSocketService();
  final AuthService _authService = AuthService();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // Stream controllers
  final StreamController<MediaStream> _localStreamController =
      StreamController<MediaStream>.broadcast();
  final StreamController<MediaStream> _remoteStreamController =
      StreamController<MediaStream>.broadcast();
  final StreamController<CallState> _callStateController =
      StreamController<CallState>.broadcast();

  // Public streams
  Stream<MediaStream> get localStream => _localStreamController.stream;
  Stream<MediaStream> get remoteStream => _remoteStreamController.stream;
  Stream<CallState> get callState => _callStateController.stream;

  // Call state
  CallState _currentState = CallState.idle;
  String? _currentCallId;
  String? _remoteUserId;
  bool _isVideoCall = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;

  // ICE servers configuration
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {
        'urls': [
          'stun:stun.l.google.com:19302',
          'stun:stun1.l.google.com:19302',
        ]
      },
    ]
  };

  // Media constraints
  final Map<String, dynamic> _mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
      'width': {'ideal': 1280},
      'height': {'ideal': 720},
    }
  };

  /// Initialize WebRTC service
  Future<void> initialize() async {
    await _setupSignalingListeners();
    debugPrint('WebRTC Service initialized');
  }

  /// Setup WebSocket listeners for signaling
  Future<void> _setupSignalingListeners() async {
    // Listen for incoming call
    _websocketService.on('call.incoming', (data) async {
      await _handleIncomingCall(data);
    });

    // Listen for call accepted
    _websocketService.on('call.accepted', (data) async {
      await _handleCallAccepted(data);
    });

    // Listen for call rejected
    _websocketService.on('call.rejected', (data) {
      _handleCallRejected(data);
    });

    // Listen for call ended
    _websocketService.on('call.ended', (data) {
      _handleCallEnded(data);
    });

    // Listen for ICE candidate
    _websocketService.on('call.ice-candidate', (data) async {
      await _handleIceCandidate(data);
    });

    // Listen for offer
    _websocketService.on('call.offer', (data) async {
      await _handleOffer(data);
    });

    // Listen for answer
    _websocketService.on('call.answer', (data) async {
      await _handleAnswer(data);
    });
  }

  /// Start a voice call
  Future<void> startVoiceCall(String userId, String userName) async {
    _isVideoCall = false;
    await _initiateCall(userId, userName, isVideo: false);
  }

  /// Start a video call
  Future<void> startVideoCall(String userId, String userName) async {
    _isVideoCall = true;
    await _initiateCall(userId, userName, isVideo: true);
  }

  /// Initiate call
  Future<void> _initiateCall(String userId, String userName,
      {required bool isVideo}) async {
    try {
      _updateCallState(CallState.calling);
      _remoteUserId = userId;

      // Get local media stream
      await _getUserMedia(isVideo: isVideo);

      // Create peer connection
      await _createPeerConnection();

      // Send call initiation to server
      _websocketService.emit('call.initiate', {
        'to_user_id': userId,
        'to_user_name': userName,
        'is_video': isVideo,
        'timestamp': DateTime.now().toIso8601String(),
      });

      debugPrint('Call initiated to user: $userId');
    } catch (e) {
      debugPrint('Error initiating call: $e');
      _updateCallState(CallState.error);
    }
  }

  /// Handle incoming call
  Future<void> _handleIncomingCall(dynamic data) async {
    try {
      _currentCallId = data['call_id'] as String;
      _remoteUserId = data['from_user_id'] as String;
      _isVideoCall = data['is_video'] as bool? ?? false;

      _updateCallState(CallState.incoming);

      debugPrint('Incoming ${_isVideoCall ? 'video' : 'voice'} call from: $_remoteUserId');
    } catch (e) {
      debugPrint('Error handling incoming call: $e');
    }
  }

  /// Accept incoming call
  Future<void> acceptCall() async {
    try {
      _updateCallState(CallState.connecting);

      // Get local media stream
      await _getUserMedia(isVideo: _isVideoCall);

      // Create peer connection
      await _createPeerConnection();

      // Send acceptance to server
      _websocketService.emit('call.accept', {
        'call_id': _currentCallId,
        'user_id': _remoteUserId,
      });

      debugPrint('Call accepted');
    } catch (e) {
      debugPrint('Error accepting call: $e');
      _updateCallState(CallState.error);
    }
  }

  /// Reject incoming call
  void rejectCall() {
    _websocketService.emit('call.reject', {
      'call_id': _currentCallId,
      'user_id': _remoteUserId,
    });

    _updateCallState(CallState.idle);
    debugPrint('Call rejected');
  }

  /// Handle call accepted
  Future<void> _handleCallAccepted(dynamic data) async {
    try {
      _currentCallId = data['call_id'] as String;
      _updateCallState(CallState.connecting);

      // Create and send offer
      await _createOffer();

      debugPrint('Call accepted by remote user');
    } catch (e) {
      debugPrint('Error handling call accepted: $e');
    }
  }

  /// Handle call rejected
  void _handleCallRejected(dynamic data) {
    _updateCallState(CallState.rejected);
    _cleanup();
    debugPrint('Call rejected by remote user');
  }

  /// Handle call ended
  void _handleCallEnded(dynamic data) {
    _updateCallState(CallState.ended);
    _cleanup();
    debugPrint('Call ended by remote user');
  }

  /// Get user media (camera/microphone)
  Future<void> _getUserMedia({required bool isVideo}) async {
    try {
      final constraints = isVideo
          ? _mediaConstraints
          : {'audio': true, 'video': false};

      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localStreamController.add(_localStream!);

      debugPrint('Local media stream acquired');
    } catch (e) {
      debugPrint('Error getting user media: $e');
      throw Exception('Failed to access camera/microphone');
    }
  }

  /// Create peer connection
  Future<void> _createPeerConnection() async {
    try {
      _peerConnection = await createPeerConnection(_iceServers);

      // Add local stream to peer connection
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }

      // Handle remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteStreamController.add(_remoteStream!);
          _updateCallState(CallState.connected);
          debugPrint('Remote stream received');
        }
      };

      // Handle ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _websocketService.emit('call.ice-candidate', {
          'call_id': _currentCallId,
          'user_id': _remoteUserId,
          'candidate': candidate.toMap(),
        });
      };

      // Handle connection state changes
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        debugPrint('Connection state: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          _updateCallState(CallState.connected);
        } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          _updateCallState(CallState.disconnected);
        }
      };

      debugPrint('Peer connection created');
    } catch (e) {
      debugPrint('Error creating peer connection: $e');
      throw Exception('Failed to create peer connection');
    }
  }

  /// Create offer
  Future<void> _createOffer() async {
    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _websocketService.emit('call.offer', {
        'call_id': _currentCallId,
        'user_id': _remoteUserId,
        'offer': offer.toMap(),
      });

      debugPrint('Offer created and sent');
    } catch (e) {
      debugPrint('Error creating offer: $e');
    }
  }

  /// Handle offer
  Future<void> _handleOffer(dynamic data) async {
    try {
      final offerMap = data['offer'] as Map<String, dynamic>;
      final offer = RTCSessionDescription(
        offerMap['sdp'] as String,
        offerMap['type'] as String,
      );

      await _peerConnection!.setRemoteDescription(offer);

      // Create answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _websocketService.emit('call.answer', {
        'call_id': _currentCallId,
        'user_id': _remoteUserId,
        'answer': answer.toMap(),
      });

      debugPrint('Offer received and answer sent');
    } catch (e) {
      debugPrint('Error handling offer: $e');
    }
  }

  /// Handle answer
  Future<void> _handleAnswer(dynamic data) async {
    try {
      final answerMap = data['answer'] as Map<String, dynamic>;
      final answer = RTCSessionDescription(
        answerMap['sdp'] as String,
        answerMap['type'] as String,
      );

      await _peerConnection!.setRemoteDescription(answer);
      debugPrint('Answer received');
    } catch (e) {
      debugPrint('Error handling answer: $e');
    }
  }

  /// Handle ICE candidate
  Future<void> _handleIceCandidate(dynamic data) async {
    try {
      final candidateMap = data['candidate'] as Map<String, dynamic>;
      final candidate = RTCIceCandidate(
        candidateMap['candidate'] as String,
        candidateMap['sdpMid'] as String,
        candidateMap['sdpMLineIndex'] as int,
      );

      await _peerConnection!.addCandidate(candidate);
      debugPrint('ICE candidate added');
    } catch (e) {
      debugPrint('Error handling ICE candidate: $e');
    }
  }

  /// End call
  Future<void> endCall() async {
    _websocketService.emit('call.end', {
      'call_id': _currentCallId,
      'user_id': _remoteUserId,
    });

    _updateCallState(CallState.ended);
    await _cleanup();
    debugPrint('Call ended');
  }

  /// Toggle mute
  Future<void> toggleMute() async {
    if (_localStream != null) {
      _isMuted = !_isMuted;
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
      debugPrint('Microphone ${_isMuted ? 'muted' : 'unmuted'}');
    }
  }

  /// Toggle video
  Future<void> toggleVideo() async {
    if (_localStream != null && _isVideoCall) {
      _isVideoEnabled = !_isVideoEnabled;
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = _isVideoEnabled;
      });
      debugPrint('Video ${_isVideoEnabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Toggle speaker
  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    await Helper.setSpeakerphoneOn(_isSpeakerOn);
    debugPrint('Speaker ${_isSpeakerOn ? 'on' : 'off'}');
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null && _isVideoCall) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
      debugPrint('Camera switched');
    }
  }

  /// Update call state
  void _updateCallState(CallState state) {
    _currentState = state;
    _callStateController.add(state);
  }

  /// Cleanup resources
  Future<void> _cleanup() async {
    // Stop local stream
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream?.dispose();
    _localStream = null;

    // Stop remote stream
    _remoteStream?.getTracks().forEach((track) {
      track.stop();
    });
    _remoteStream?.dispose();
    _remoteStream = null;

    // Close peer connection
    await _peerConnection?.close();
    _peerConnection = null;

    // Reset state
    _currentCallId = null;
    _remoteUserId = null;
    _isMuted = false;
    _isVideoEnabled = true;
    _isSpeakerOn = false;

    debugPrint('WebRTC resources cleaned up');
  }

  /// Dispose service
  void dispose() {
    _cleanup();
    _localStreamController.close();
    _remoteStreamController.close();
    _callStateController.close();
    debugPrint('WebRTC Service disposed');
  }

  // Getters
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isVideoCall => _isVideoCall;
  CallState get currentState => _currentState;
  String? get currentCallId => _currentCallId;
  String? get remoteUserId => _remoteUserId;
}

/// Call State Enum
enum CallState {
  idle,
  calling,
  incoming,
  connecting,
  connected,
  rejected,
  ended,
  disconnected,
  error,
}
