// Temporarily disabled due to flutter_webrtc compatibility issues
/*
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../utils/api_error_handler.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  dynamic _socket;
  String? _roomId;
  String? _userId;
  String? _otherUserId;
  
  final StreamController<MediaStream> _remoteStreamController = StreamController<MediaStream>.broadcast();
  final StreamController<String> _connectionStateController = StreamController<String>.broadcast();
  final StreamController<String> _callStateController = StreamController<String>.broadcast();
  
  Stream<MediaStream> get remoteStream => _remoteStreamController.stream;
  Stream<String> get connectionState => _connectionStateController.stream;
  Stream<String> get callState => _callStateController.stream;
  MediaStream? get localStream => _localStream;

  bool get isConnected => _peerConnection?.connectionState == RTCPeerConnectionState.RTCPeerConnectionStateConnected;
  bool get isCallActive => _localStream != null && _remoteStream != null;

  /// Initialize WebRTC service
  Future<void> initialize() async {
    try {
      // Request camera and microphone permissions
      await _requestPermissions();
      
      // Initialize socket connection
      await _initializeSocket();
      
      // Initialize peer connection
      await _initializePeerConnection();
      
      debugPrint('WebRTC Service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize WebRTC Service: $e');
      rethrow;
    }
  }

  /// Request necessary permissions
  Future<void> _requestPermissions() async {
    // Note: Permission handling would be implemented here
    // For now, we'll assume permissions are granted
    debugPrint('Permissions requested');
  }

  /// Initialize socket connection for signaling
  Future<void> _initializeSocket() async {
    try {
      // Socket.io connection setup (commented out due to API changes)
      // _socket = IO.io('wss://your-signaling-server.com', <String, dynamic>{
      //   'transports': ['websocket'],
      //   'autoConnect': false,
      // });
      debugPrint('WebRTC socket initialization skipped - API not available');

      // Socket event handlers commented out due to API changes
      /*
      _socket!.onConnect((_) {
        debugPrint('Socket connected');
        _connectionStateController.add('connected');
      });

      _socket!.onDisconnect((_) {
        debugPrint('Socket disconnected');
        _connectionStateController.add('disconnected');
      });

      _socket!.onConnectError((error) {
        debugPrint('Socket connection error: $error');
        _connectionStateController.add('error');
      });

      // Listen for incoming calls
      _socket!.on('call-offer', (data) {
        _handleIncomingCall(data);
      });

      _socket!.on('call-answer', (data) {
        _handleCallAnswer(data);
      });

      _socket!.on('ice-candidate', (data) {
        _handleIceCandidate(data);
      });

      _socket!.on('call-end', (data) {
        _handleCallEnd(data);
      });

      _socket!.connect();
      */
    } catch (e) {
      debugPrint('Failed to initialize socket: $e');
      rethrow;
    }
  }

  /// Initialize peer connection
  Future<void> _initializePeerConnection() async {
    try {
      final configuration = <String, dynamic>{
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ],
      };

      _peerConnection = await createPeerConnection(configuration);

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _socket?.emit('ice-candidate', {
          'candidate': candidate.toMap(),
          'roomId': _roomId,
          'userId': _userId,
        });
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteStream = stream;
        _remoteStreamController.add(stream);
        debugPrint('Remote stream added');
      };

      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        debugPrint('Connection state: $state');
        _connectionStateController.add(state.toString());
      };

      debugPrint('Peer connection initialized');
    } catch (e) {
      debugPrint('Failed to initialize peer connection: $e');
      rethrow;
    }
  }

  /// Start a video call
  Future<void> startCall({
    required String roomId,
    required String userId,
    required String otherUserId,
  }) async {
    try {
      _roomId = roomId;
      _userId = userId;
      _otherUserId = otherUserId;

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'min': 640, 'ideal': 1280},
          'height': {'min': 480, 'ideal': 720},
        },
      });

      // Add local stream to peer connection
      await _peerConnection!.addStream(_localStream!);

      // Create offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Send offer to other user
      _socket?.emit('call-offer', {
        'offer': offer.toMap(),
        'roomId': _roomId,
        'fromUserId': _userId,
        'toUserId': _otherUserId,
      });

      _callStateController.add('calling');
      debugPrint('Call started');
    } catch (e) {
      debugPrint('Failed to start call: $e');
      _callStateController.add('error');
      rethrow;
    }
  }

  /// Answer an incoming call
  Future<void> answerCall(Map<String, dynamic> offerData) async {
    try {
      _roomId = offerData['roomId'];
      _userId = offerData['toUserId'];
      _otherUserId = offerData['fromUserId'];

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'min': 640, 'ideal': 1280},
          'height': {'min': 480, 'ideal': 720},
        },
      });

      // Add local stream to peer connection
      await _peerConnection!.addStream(_localStream!);

      // Set remote description
      final offer = RTCSessionDescription(
        offerData['offer']['sdp'],
        offerData['offer']['type'],
      );
      await _peerConnection!.setRemoteDescription(offer);

      // Create answer
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Send answer to caller
      _socket?.emit('call-answer', {
        'answer': answer.toMap(),
        'roomId': _roomId,
        'fromUserId': _userId,
        'toUserId': _otherUserId,
      });

      _callStateController.add('answered');
      debugPrint('Call answered');
    } catch (e) {
      debugPrint('Failed to answer call: $e');
      _callStateController.add('error');
      rethrow;
    }
  }

  /// End the current call
  Future<void> endCall() async {
    try {
      // Send call end signal
      _socket?.emit('call-end', {
        'roomId': _roomId,
        'userId': _userId,
        'otherUserId': _otherUserId,
      });

      // Clean up resources
      await _cleanup();
      
      _callStateController.add('ended');
      debugPrint('Call ended');
    } catch (e) {
      debugPrint('Failed to end call: $e');
      rethrow;
    }
  }

  /// Toggle camera on/off
  Future<void> toggleCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
    }
  }

  /// Toggle microphone on/off
  Future<void> toggleMicrophone() async {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  /// Handle incoming call offer
  void _handleIncomingCall(Map<String, dynamic> data) {
    _callStateController.add('incoming');
    // This would typically trigger a UI notification
  }

  /// Handle call answer
  Future<void> _handleCallAnswer(Map<String, dynamic> data) async {
    try {
      final answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );
      await _peerConnection!.setRemoteDescription(answer);
      _callStateController.add('connected');
      debugPrint('Call connected');
    } catch (e) {
      debugPrint('Failed to handle call answer: $e');
      _callStateController.add('error');
    }
  }

  /// Handle ICE candidate
  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      debugPrint('Failed to handle ICE candidate: $e');
    }
  }

  /// Handle call end
  void _handleCallEnd(Map<String, dynamic> data) {
    _cleanup();
    _callStateController.add('ended');
    debugPrint('Call ended by remote user');
  }

  /// Clean up resources
  Future<void> _cleanup() async {
    try {
      if (_localStream != null) {
        _localStream!.dispose();
        _localStream = null;
      }
      
      if (_remoteStream != null) {
        _remoteStream!.dispose();
        _remoteStream = null;
      }
      
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;
      }
      
      _roomId = null;
      _userId = null;
      _otherUserId = null;
      
      debugPrint('Resources cleaned up');
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  /// Dispose service
  Future<void> dispose() async {
    await _cleanup();
    
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    
    _remoteStreamController.close();
    _connectionStateController.close();
    _callStateController.close();
    
    debugPrint('WebRTC Service disposed');
  }
}

class CallState {
  final String state;
  final String? roomId;
  final String? otherUserId;
  final bool isVideoEnabled;
  final bool isAudioEnabled;

  CallState({
    required this.state,
    this.roomId,
    this.otherUserId,
    this.isVideoEnabled = true,
    this.isAudioEnabled = true,
  });

  CallState copyWith({
    String? state,
    String? roomId,
    String? otherUserId,
    bool? isVideoEnabled,
    bool? isAudioEnabled,
  }) {
    return CallState(
      state: state ?? this.state,
      roomId: roomId ?? this.roomId,
      otherUserId: otherUserId ?? this.otherUserId,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
    );
  }
}
*/
