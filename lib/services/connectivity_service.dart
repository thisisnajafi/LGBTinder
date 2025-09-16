import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/error_handler.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Timer? _connectivityTimer;
  bool _isOnline = true;
  DateTime? _lastOnlineTime;
  DateTime? _lastOfflineTime;

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isOnline => _isOnline;
  DateTime? get lastOnlineTime => _lastOnlineTime;
  DateTime? get lastOfflineTime => _lastOfflineTime;

  /// Initialize connectivity monitoring
  void initialize() {
    _startConnectivityMonitoring();
    debugPrint('ConnectivityService initialized');
  }

  /// Start monitoring connectivity
  void _startConnectivityMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await _checkConnectivity();
    });
    
    // Check immediately
    _checkConnectivity();
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final wasOnline = _isOnline;
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (_isOnline != wasOnline) {
        if (_isOnline) {
          _lastOnlineTime = DateTime.now();
          debugPrint('Device came online');
        } else {
          _lastOfflineTime = DateTime.now();
          debugPrint('Device went offline');
        }
        
        _connectivityController.add(_isOnline);
      }
    } catch (e) {
      final wasOnline = _isOnline;
      _isOnline = false;
      
      if (_isOnline != wasOnline) {
        _lastOfflineTime = DateTime.now();
        debugPrint('Device went offline: $e');
        _connectivityController.add(_isOnline);
      }
    }
  }

  /// Check connectivity with custom timeout
  Future<bool> checkConnectivityWithTimeout(Duration timeout) async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Wait for connectivity to be restored
  Future<void> waitForConnectivity({Duration? timeout}) async {
    if (_isOnline) return;
    
    final completer = Completer<void>();
    StreamSubscription? subscription;
    
    subscription = connectivityStream.listen((isOnline) {
      if (isOnline) {
        subscription?.cancel();
        completer.complete();
      }
    });
    
    if (timeout != null) {
      Timer(timeout, () {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Connectivity timeout', timeout));
        }
      });
    }
    
    return completer.future;
  }

  /// Get connectivity statistics
  Map<String, dynamic> getConnectivityStatistics() {
    return {
      'is_online': _isOnline,
      'last_online_time': _lastOnlineTime?.toIso8601String(),
      'last_offline_time': _lastOfflineTime?.toIso8601String(),
      'time_since_last_online': _lastOnlineTime != null 
          ? DateTime.now().difference(_lastOnlineTime!).inSeconds
          : null,
      'time_since_last_offline': _lastOfflineTime != null 
          ? DateTime.now().difference(_lastOfflineTime!).inSeconds
          : null,
    };
  }

  /// Check if device has been offline for a specific duration
  bool hasBeenOfflineFor(Duration duration) {
    if (_isOnline) return false;
    if (_lastOfflineTime == null) return false;
    
    return DateTime.now().difference(_lastOfflineTime!) > duration;
  }

  /// Check if device has been online for a specific duration
  bool hasBeenOnlineFor(Duration duration) {
    if (!_isOnline) return false;
    if (_lastOnlineTime == null) return false;
    
    return DateTime.now().difference(_lastOnlineTime!) > duration;
  }

  /// Get offline duration
  Duration? getOfflineDuration() {
    if (_isOnline || _lastOfflineTime == null) return null;
    return DateTime.now().difference(_lastOfflineTime!);
  }

  /// Get online duration
  Duration? getOnlineDuration() {
    if (!_isOnline || _lastOnlineTime == null) return null;
    return DateTime.now().difference(_lastOnlineTime!);
  }

  /// Dispose of the service
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }
}
