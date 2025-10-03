import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/websocket_state_provider.dart';
import '../../models/api_models/common_models.dart';
import 'real_time_widgets.dart';

/// A widget that listens to real-time events and updates the UI accordingly
class RealTimeListener extends StatefulWidget {
  final Widget child;
  final List<String> eventTypes;
  final Function(WebSocketEvent)? onEvent;
  final bool showNotifications;
  final Duration notificationDuration;
  final bool autoDismissNotifications;

  const RealTimeListener({
    super.key,
    required this.child,
    this.eventTypes = const [],
    this.onEvent,
    this.showNotifications = true,
    this.notificationDuration = const Duration(seconds: 5),
    this.autoDismissNotifications = true,
  });

  @override
  State<RealTimeListener> createState() => _RealTimeListenerState();
}

class _RealTimeListenerState extends State<RealTimeListener> {
  final List<WebSocketEvent> _notifications = [];
  final Map<String, DateTime> _lastEventTimes = {};

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
  }

  void _setupEventListeners() {
    final websocketProvider = context.read<WebSocketStateProvider>();
    
    // Listen to all events if no specific types are provided
    final eventTypes = widget.eventTypes.isEmpty 
        ? ['message', 'match', 'like', 'typing', 'online', 'offline']
        : widget.eventTypes;
    
    for (final eventType in eventTypes) {
      websocketProvider.addEventListener(eventType, _handleEvent);
    }
  }

  void _handleEvent(WebSocketEvent event) {
    // Call custom event handler
    widget.onEvent?.call(event);
    
    // Show notification if enabled
    if (widget.showNotifications && _shouldShowNotification(event)) {
      _showNotification(event);
    }
    
    // Update last event time
    _lastEventTimes[event.type] = DateTime.now();
  }

  bool _shouldShowNotification(WebSocketEvent event) {
    // Don't show notifications for typing events
    if (event.type == 'typing') return false;
    
    // Don't show duplicate notifications within 5 seconds
    final lastTime = _lastEventTimes[event.type];
    if (lastTime != null) {
      final timeDiff = DateTime.now().difference(lastTime);
      if (timeDiff.inSeconds < 5) return false;
    }
    
    return true;
  }

  void _showNotification(WebSocketEvent event) {
    setState(() {
      _notifications.add(event);
    });
    
    // Auto-dismiss notification if enabled
    if (widget.autoDismissNotifications) {
      Future.delayed(widget.notificationDuration, () {
        if (mounted) {
          _dismissNotification(event);
        }
      });
    }
  }

  void _dismissNotification(WebSocketEvent event) {
    setState(() {
      _notifications.remove(event);
    });
  }

  @override
  void dispose() {
    final websocketProvider = context.read<WebSocketStateProvider>();
    
    // Remove event listeners
    final eventTypes = widget.eventTypes.isEmpty 
        ? ['message', 'match', 'like', 'typing', 'online', 'offline']
        : widget.eventTypes;
    
    for (final eventType in eventTypes) {
      websocketProvider.removeEventListener(eventType, _handleEvent);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_notifications.isNotEmpty)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: _notifications.map((event) {
                return RealTimeEventNotification(
                  event: event,
                  onDismiss: () => _dismissNotification(event),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

/// A widget that provides real-time updates for a specific data type
class RealTimeDataProvider<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T data) builder;
  final String dataKey;
  final T initialData;
  final String? eventType;
  final T Function(WebSocketEvent)? eventToData;
  final Duration updateInterval;
  final bool enableRealTimeUpdates;

  const RealTimeDataProvider({
    super.key,
    required this.builder,
    required this.dataKey,
    required this.initialData,
    this.eventType,
    this.eventToData,
    this.updateInterval = const Duration(seconds: 30),
    this.enableRealTimeUpdates = true,
  });

  @override
  State<RealTimeDataProvider<T>> createState() => _RealTimeDataProviderState<T>();
}

class _RealTimeDataProviderState<T> extends State<RealTimeDataProvider<T>> {
  late T _data;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _setupRealTimeUpdates();
  }

  void _setupRealTimeUpdates() {
    if (!widget.enableRealTimeUpdates) return;
    
    final websocketProvider = context.read<WebSocketStateProvider>();
    
    if (widget.eventType != null) {
      websocketProvider.addEventListener(widget.eventType!, _handleEvent);
    }
  }

  void _handleEvent(WebSocketEvent event) {
    if (widget.eventToData != null) {
      final newData = widget.eventToData!(event);
      if (newData != null) {
        setState(() {
          _data = newData;
          _lastUpdate = DateTime.now();
        });
      }
    }
  }

  @override
  void dispose() {
    if (widget.enableRealTimeUpdates && widget.eventType != null) {
      final websocketProvider = context.read<WebSocketStateProvider>();
      websocketProvider.removeEventListener(widget.eventType!, _handleEvent);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _data);
  }
}

/// A widget that shows real-time connection status with retry functionality
class RealTimeConnectionWidget extends StatelessWidget {
  final Widget child;
  final bool showStatus;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? backgroundColor;
  final Color? textColor;

  const RealTimeConnectionWidget({
    super.key,
    required this.child,
    this.showStatus = true,
    this.onRetry,
    this.retryText = 'Retry',
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketStateProvider>(
      builder: (context, websocketProvider, child) {
        return Column(
          children: [
            if (showStatus)
              RealTimeConnectionStatus(
                showWhenConnected: false,
                showWhenDisconnected: true,
                showWhenConnecting: true,
                backgroundColor: backgroundColor,
                textColor: textColor,
              ),
            Expanded(
              child: Stack(
                children: [
                  this.child,
                  if (websocketProvider.connectionState == WebSocketConnectionState.disconnected)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: onRetry ?? () => websocketProvider.connect(),
                        backgroundColor: backgroundColor ?? AppColors.primary,
                        child: Icon(
                          Icons.refresh,
                          color: textColor ?? Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A widget that provides real-time typing indicators
class RealTimeTypingIndicator extends StatelessWidget {
  final String chatId;
  final String? currentUserId;
  final Color? dotColor;
  final double dotSize;
  final Duration animationDuration;

  const RealTimeTypingIndicator({
    super.key,
    required this.chatId,
    this.currentUserId,
    this.dotColor,
    this.dotSize = 8.0,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketStateProvider>(
      builder: (context, websocketProvider, child) {
        final typingUsers = websocketProvider.getTypingUsers(chatId);
        
        return TypingIndicator(
          typingUsers: typingUsers,
          currentUserId: currentUserId,
          dotColor: dotColor,
          dotSize: dotSize,
          animationDuration: animationDuration,
        );
      },
    );
  }
}

/// A widget that provides real-time online status
class RealTimeOnlineStatus extends StatelessWidget {
  final String userId;
  final double size;
  final Color? onlineColor;
  final Color? offlineColor;
  final bool showText;
  final String? onlineText;
  final String? offlineText;

  const RealTimeOnlineStatus({
    super.key,
    required this.userId,
    this.size = 12.0,
    this.onlineColor,
    this.offlineColor,
    this.showText = false,
    this.onlineText,
    this.offlineText,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WebSocketStateProvider>(
      builder: (context, websocketProvider, child) {
        final isOnline = websocketProvider.isUserOnline(userId);
        
        return OnlineStatusIndicator(
          isOnline: isOnline,
          size: size,
          onlineColor: onlineColor,
          offlineColor: offlineColor,
          showText: showText,
          onlineText: onlineText,
          offlineText: offlineText,
        );
      },
    );
  }
}
