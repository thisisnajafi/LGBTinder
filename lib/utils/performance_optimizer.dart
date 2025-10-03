import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceOptimizer {
  // Private constructor to prevent instantiation
  PerformanceOptimizer._();

  /// Optimize widget rebuilds by using const constructors where possible
  static Widget optimizeWidget(Widget widget) {
    return widget;
  }

  /// Debounce function calls to prevent excessive execution
  static Function debounce(Function func, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, () => func());
    };
  }

  /// Throttle function calls to limit execution frequency
  static Function throttle(Function func, Duration delay) {
    Timer? timer;
    bool isThrottled = false;
    
    return () {
      if (!isThrottled) {
        func();
        isThrottled = true;
        timer = Timer(delay, () {
          isThrottled = false;
        });
      }
    };
  }

  /// Preload images to improve perceived performance
  static Future<void> preloadImages(BuildContext context, List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await precacheImage(
          NetworkImage(url),
          context,
        );
      } catch (e) {
        debugPrint('Failed to preload image: $url');
      }
    }
  }

  /// Optimize list performance with proper item extent
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    double? itemExtent,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      itemExtent: itemExtent,
      controller: controller,
      scrollDirection: scrollDirection,
      cacheExtent: 250.0, // Cache items slightly outside viewport
    );
  }

  /// Optimize grid performance
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
  }) {
    return GridView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      controller: controller,
      cacheExtent: 250.0,
    );
  }

  /// Use RepaintBoundary to isolate expensive widgets
  static Widget repaintBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }

  /// Use AutomaticKeepAliveClientMixin for expensive widgets
  static Widget keepAlive(Widget child) {
    return KeepAlive(child: child);
  }
}

class KeepAlive extends StatefulWidget {
  final Widget child;

  const KeepAlive({Key? key, required this.child}) : super(key: key);

  @override
  State<KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class OptimizedProfilePage extends StatefulWidget {
  final Widget child;
  final bool enableLazyLoading;
  final bool enableImagePreloading;
  final List<String>? preloadImages;

  const OptimizedProfilePage({
    Key? key,
    required this.child,
    this.enableLazyLoading = true,
    this.enableImagePreloading = true,
    this.preloadImages,
  }) : super(key: key);

  @override
  State<OptimizedProfilePage> createState() => _OptimizedProfilePageState();
}

class _OptimizedProfilePageState extends State<OptimizedProfilePage>
    with AutomaticKeepAliveClientMixin {
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        if (widget.enableImagePreloading && widget.preloadImages != null) {
          PerformanceOptimizer.preloadImages(context, widget.preloadImages!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return widget.child;
  }
}

class LazyLoadWidget extends StatefulWidget {
  final Widget child;
  final Widget? placeholder;
  final Duration delay;

  const LazyLoadWidget({
    Key? key,
    required this.child,
    this.placeholder,
    this.delay = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _loadWidget();
  }

  void _loadWidget() {
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return widget.placeholder ?? const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String? name;
  final bool enableLogging;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.name,
    this.enableLogging = false,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _endTime = DateTime.now();
    
    if (widget.enableLogging) {
      final duration = _endTime.difference(_startTime);
      debugPrint('${widget.name ?? 'Widget'} build time: ${duration.inMilliseconds}ms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class OptimizedScrollView extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool enablePhysics;
  final ScrollPhysics? physics;

  const OptimizedScrollView({
    Key? key,
    required this.child,
    this.controller,
    this.enablePhysics = true,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      physics: enablePhysics 
          ? (physics ?? const BouncingScrollPhysics())
          : const NeverScrollableScrollPhysics(),
      child: child,
    );
  }
}

class MemoryOptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableMemoryCache;
  final int? maxWidth;
  final int? maxHeight;

  const MemoryOptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.enableMemoryCache = true,
    this.maxWidth,
    this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: enableMemoryCache ? maxWidth : null,
      memCacheHeight: enableMemoryCache ? maxHeight : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
    );
  }
}

class OptimizedFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final Widget? loadingWidget;
  final Widget Function(BuildContext, Object)? errorWidget;

  const OptimizedFutureBuilder({
    Key? key,
    required this.future,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return errorWidget?.call(context, snapshot.error!) ?? 
              Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.hasData) {
          return builder(context, snapshot.data!);
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}

class OptimizedStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext, T) builder;
  final Widget? loadingWidget;
  final Widget Function(BuildContext, Object)? errorWidget;

  const OptimizedStreamBuilder({
    Key? key,
    required this.stream,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return errorWidget?.call(context, snapshot.error!) ?? 
              Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.hasData) {
          return builder(context, snapshot.data!);
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}
