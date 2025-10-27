import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/haptic_feedback_service.dart';
import '../services/animation_service.dart';
import '../theme/typography.dart';

class PullToRefreshService {
  static final PullToRefreshService _instance = PullToRefreshService._internal();
  factory PullToRefreshService() => _instance;
  PullToRefreshService._internal();

  // Refresh settings
  bool _isEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _soundEnabled = false;
  double _refreshThreshold = 80.0;
  Duration _refreshDuration = const Duration(milliseconds: 1000);
  Color _refreshIndicatorColor = Colors.blue;
  Color _refreshBackgroundColor = Colors.white;
  String _refreshMessage = 'Pull to refresh';
  String _refreshingMessage = 'Refreshing...';
  String _releaseMessage = 'Release to refresh';

  // Getters
  bool get isEnabled => _isEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  bool get soundEnabled => _soundEnabled;
  double get refreshThreshold => _refreshThreshold;
  Duration get refreshDuration => _refreshDuration;
  Color get refreshIndicatorColor => _refreshIndicatorColor;
  Color get refreshBackgroundColor => _refreshBackgroundColor;
  String get refreshMessage => _refreshMessage;
  String get refreshingMessage => _refreshingMessage;
  String get releaseMessage => _releaseMessage;

  /// Initialize pull-to-refresh service
  void initialize() {
    debugPrint('Pull-to-Refresh Service initialized');
  }

  /// Enable/disable pull-to-refresh
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Enable/disable haptic feedback
  void setHapticFeedbackEnabled(bool enabled) {
    _hapticFeedbackEnabled = enabled;
  }

  /// Enable/disable sound feedback
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Set refresh threshold
  void setRefreshThreshold(double threshold) {
    _refreshThreshold = threshold.clamp(50.0, 150.0);
  }

  /// Set refresh duration
  void setRefreshDuration(Duration duration) {
    _refreshDuration = duration;
  }

  /// Set refresh indicator color
  void setRefreshIndicatorColor(Color color) {
    _refreshIndicatorColor = color;
  }

  /// Set refresh background color
  void setRefreshBackgroundColor(Color color) {
    _refreshBackgroundColor = color;
  }

  /// Set refresh messages
  void setRefreshMessages({
    String? refreshMessage,
    String? refreshingMessage,
    String? releaseMessage,
  }) {
    if (refreshMessage != null) _refreshMessage = refreshMessage;
    if (refreshingMessage != null) _refreshingMessage = refreshingMessage;
    if (releaseMessage != null) _releaseMessage = releaseMessage;
  }

  /// Trigger haptic feedback for refresh
  Future<void> triggerRefreshHaptic() async {
    if (_hapticFeedbackEnabled && _isEnabled) {
      HapticFeedbackService.refresh();
    }
  }

  /// Trigger sound feedback for refresh
  void triggerRefreshSound() {
    if (_soundEnabled && _isEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Create custom refresh indicator
  Widget createRefreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
    Color? color,
    Color? backgroundColor,
    double? displacement,
    String? semanticsLabel,
    String? semanticsValue,
  }) {
    if (!_isEnabled) {
      return child;
    }

    return RefreshIndicator(
      onRefresh: () async {
        await triggerRefreshHaptic();
        triggerRefreshSound();
        await onRefresh();
      },
      color: color ?? _refreshIndicatorColor,
      backgroundColor: backgroundColor ?? _refreshBackgroundColor,
      displacement: displacement ?? _refreshThreshold,
      semanticsLabel: semanticsLabel ?? _refreshMessage,
      semanticsValue: semanticsValue ?? _refreshingMessage,
      child: child,
    );
  }

  /// Create custom pull-to-refresh widget
  Widget createCustomPullToRefresh({
    required Widget child,
    required Future<void> Function() onRefresh,
    Widget? refreshIndicator,
    Color? color,
    Color? backgroundColor,
    double? threshold,
    Duration? duration,
    String? refreshText,
    String? refreshingText,
    String? releaseText,
  }) {
    if (!_isEnabled) {
      return child;
    }

    return _CustomPullToRefresh(
      onRefresh: onRefresh,
      refreshIndicator: refreshIndicator,
      color: color ?? _refreshIndicatorColor,
      backgroundColor: backgroundColor ?? _refreshBackgroundColor,
      threshold: threshold ?? _refreshThreshold,
      duration: duration ?? _refreshDuration,
      refreshText: refreshText ?? _refreshMessage,
      refreshingText: refreshingText ?? _refreshingMessage,
      releaseText: releaseText ?? _releaseMessage,
      child: child,
    );
  }

  /// Dispose service
  void dispose() {
    debugPrint('Pull-to-Refresh Service disposed');
  }
}

class _CustomPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Widget? refreshIndicator;
  final Color color;
  final Color backgroundColor;
  final double threshold;
  final Duration duration;
  final String refreshText;
  final String refreshingText;
  final String releaseText;

  const _CustomPullToRefresh({
    required this.child,
    required this.onRefresh,
    this.refreshIndicator,
    required this.color,
    required this.backgroundColor,
    required this.threshold,
    required this.duration,
    required this.refreshText,
    required this.refreshingText,
    required this.releaseText,
  });

  @override
  State<_CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<_CustomPullToRefresh>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isRefreshing = false;
  bool _canRefresh = false;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          // Main content
          Transform.translate(
            offset: Offset(0, _dragOffset),
            child: widget.child,
          ),
          // Refresh indicator
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: _dragOffset.clamp(0, widget.threshold),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: _buildRefreshIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRefreshIndicator() {
    if (_isRefreshing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.refreshingText,
            style: AppTypography.bodySmall.copyWith(
              color: widget.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    final progress = (_dragOffset / widget.threshold).clamp(0.0, 1.0);
    final text = _dragOffset >= widget.threshold 
        ? widget.releaseText 
        : widget.refreshText;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: progress,
          child: Icon(
            _dragOffset >= widget.threshold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: widget.color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: widget.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _onPanStart(DragStartDetails details) {
    // Check if we're at the top of the scrollable content
    // This is a simplified check - in a real implementation,
    // you'd want to check the actual scroll position
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isRefreshing) return;

    final delta = details.delta.dy;
    if (delta > 0) {
      setState(() {
        _dragOffset = (_dragOffset + delta * 0.5).clamp(0, widget.threshold * 1.5);
        _canRefresh = _dragOffset >= widget.threshold;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isRefreshing) return;

    if (_canRefresh) {
      _startRefresh();
    } else {
      _resetPosition();
    }
  }

  void _startRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Trigger haptic feedback
    await PullToRefreshService().triggerRefreshHaptic();

    try {
      await widget.onRefresh();
    } catch (e) {
      debugPrint('Refresh error: $e');
    } finally {
      _resetPosition();
    }
  }

  void _resetPosition() {
    _controller.forward().then((_) {
      setState(() {
        _dragOffset = 0.0;
        _canRefresh = false;
        _isRefreshing = false;
      });
      _controller.reset();
    });
  }
}

class PullToRefreshListView extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PullToRefreshListView({
    Key? key,
    required this.children,
    required this.onRefresh,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PullToRefreshService().createRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        children: children,
      ),
    );
  }
}

class PullToRefreshGridView extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const PullToRefreshGridView({
    Key? key,
    required this.children,
    required this.onRefresh,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PullToRefreshService().createRefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.count(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
        children: children,
      ),
    );
  }
}

class PullToRefreshPageView extends StatelessWidget {
  final List<Widget> children;
  final Future<void> Function() onRefresh;
  final PageController? controller;
  final bool allowImplicitScrolling;

  const PullToRefreshPageView({
    Key? key,
    required this.children,
    required this.onRefresh,
    this.controller,
    this.allowImplicitScrolling = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PullToRefreshService().createRefreshIndicator(
      onRefresh: onRefresh,
      child: PageView(
        controller: controller,
        allowImplicitScrolling: allowImplicitScrolling,
        children: children,
      ),
    );
  }
}

class PullToRefreshSingleChildScrollView extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final ScrollPhysics? physics;

  const PullToRefreshSingleChildScrollView({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.controller,
    this.padding,
    this.reverse = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PullToRefreshService().createRefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: controller,
        padding: padding,
        reverse: reverse,
        physics: physics,
        child: child,
      ),
    );
  }
}

class PullToRefreshCustomScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final Future<void> Function() onRefresh;
  final ScrollController? controller;
  final bool reverse;
  final ScrollPhysics? physics;

  const PullToRefreshCustomScrollView({
    Key? key,
    required this.slivers,
    required this.onRefresh,
    this.controller,
    this.reverse = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PullToRefreshService().createRefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        controller: controller,
        reverse: reverse,
        physics: physics,
        slivers: slivers,
      ),
    );
  }
}
