/// WebSocket connection state enumeration
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

/// Extension for WebSocket connection state
extension WebSocketConnectionStateExtension on WebSocketConnectionState {
  String get displayName {
    switch (this) {
      case WebSocketConnectionState.connected:
        return 'Connected';
      case WebSocketConnectionState.disconnected:
        return 'Disconnected';
      case WebSocketConnectionState.connecting:
        return 'Connecting...';
      case WebSocketConnectionState.error:
        return 'Error';
    }
  }
}
