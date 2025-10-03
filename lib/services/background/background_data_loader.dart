import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../cache/reference_data_cache.dart';
import '../../models/api_models/reference_data_models.dart';

/// Background data loader for heavy operations
class BackgroundDataLoader {
  static StreamController<LoadingProgress>? _progressController;
  static StreamSubscription? _loadingSubscription;
  
  /// Initialize background loader
  static void initialize() {
    _progressController = StreamController<LoadingProgress>.broadcast();
  }
  
  /// Get loading progress stream
  static Stream<LoadingProgress> get progressStream {
    _progressController ??= StreamController<LoadingData>.broadcast();
    return _progressController!.stream;
  }
  
  /// Load reference data in background
  static Future<void> loadReferenceDataInBackground() async {
    if (_loadingSubscription != null) {
      print('🔄 Reference data loading already in progress');
      return;
    }
    
    _progressController ??= StreamController<LoadingProgress>.broadcast();
    
    print('🚀 Starting background reference data loading...');
    
    try {
      _progressController!.add(LoadingProgress.loading('Initializing...', 0.0));
      
      // Load countries
      _progressController!.add(LoadingProgress.loading('Loading countries...', 0.25));
      await ReferenceDataCache.loadCountriesWithCache();
      
      _progressController!.add(LoadingProgress.loading('Loading reference data...', 0.5));
      await ReferenceDataCache.loadReferenceDataWithCache();
      
      _progressController!.add(LoadingProgress.loading('Completing setup...', 0.75));
      
      // Simulate parsing and setup time
      await Future.delayed(const Duration(milliseconds: 200));
      
      _progressController!.add(LoadingProgress.complete('Reference data loaded successfully!'));
      
      print('✅ Background reference data loading completed');
      
    } catch (e) {
      print('❌ Background loading error: $e');
      _progressController!.add(LoadingProgress.error('Failed to load reference data: $e'));
    }
  }
  
  /// Load critical data synchronously for immediate UI needs
  static Future<void> loadCriticalDataSync() async {
    print('⚡ Loading critical data synchronously...');
    
    try {
      // Load cached data immediately
      await ReferenceDataCache.isCacheValid();
      
      // Preload first few countries if available
      await ReferenceDataCache.getCachedCountries();
      
      print('✅ Critical data loaded synchronously');
    } catch (e) {
      print('⚠️ Critical data loading warning: $e');
    }
  }
  
  /// Load additional data in background isolate
  static Future<void> loadDataInIsolate() async {
    try {
      final compute = await compute(_loadDataComputation, null);
      print('✅ Background computation completed: $compute');
    } catch (e) {
      print('❌ Background computation error: $e');
    }
  }
  
  /// Background computation function
  static Future<String> _loadDataComputation(dynamic data) async {
    // Simulate heavy computation
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      // Load additional reference data
      await ReferenceDataCache.loadReferenceDataWithCache();
      return 'Computation completed successfully';
    } catch (e) {
      return 'Computation failed: $e';
    }
  }
  
  /// Cancel current loading operation
  static void cancelLoading() {
    _loadingSubscription?.cancel();
    _loadingSubscription = null;
    _progressController?.add(LoadingProgress.cancelled());
  }
  
  /// Dispose resources
  static void dispose() {
    _loadingSubscription?.cancel();
    _progressController?.close();
    _progressController = null;
  }
}

/// Loading progress event
class LoadingProgress {
  final String message;
  final double progress;
  final LoadingProgressType type;
  final DateTime timestamp;

  const LoadingProgress({
    required this.message,
    required this.progress,
    required this.type,
    required this.timestamp,
  });

  factory LoadingProgress.loading(String message, double progress) {
    return LoadingProgress(
      message: message,
      progress: progress,
      type: LoadingProgressType.loading,
      timestamp: DateTime.now(),
    );
  }

  factory LoadingProgress.complete(String message) {
    return LoadingProgress(
      message: message,
      progress: 1.0,
      type: LoadingProgressType.complete,
      timestamp: DateTime.now(),
    );
  }

  factory LoadingProgress.error(String message) {
    return LoadingProgress(
      message: message,
      progress: 0.0,
      type: LoadingProgressType.error,
      timestamp: DateTime.now(),
    );
  }

  factory LoadingProgress.cancelled() {
    return LoadingProgress(
      message: 'Loading cancelled',
      progress: 0.0,
      type: LoadingProgressType.cancelled,
      timestamp: DateTime.now(),
    );
  }

  bool get isComplete => type == LoadingProgressType.complete;
  bool get hasError => type == LoadingProgressType.error;
  bool get isCancelled => type == LoadingProgressType.cancelled;
  bool get isLoading => type == LoadingProgressType.loading;
}

enum LoadingProgressType {
  loading,
  complete,
  error,
  cancelled,
}

/// Background loading progress widget
class BackgroundLoaderWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const BackgroundLoaderWidget({
    Key? key,
    required this.child,
    this.onComplete,
  }) : super(key: key);

  @override
  State<BackgroundLoaderWidget> createState() => _BackgroundLoaderWidgetState();
}

class _BackgroundLoaderWidgetState extends State<BackgroundLoaderWidget> {
  StreamSubscription<LoadingProgress>? _subscription;
  LoadingProgress? _currentProgress;
  bool _showProgress = false;

  @override
  void initState() {
    super.initState();
    
    // Start background loading if not already started
    BackgroundDataLoader.loadReferenceDataInBackground();
    
    // Listen to progress updates
    _subscription = BackgroundDataLoader.progressStream.listen(
      (progress) {
        if (mounted) {
          setState(() {
            _currentProgress = progress;
            _showProgress = progress.isLoading;
          });
          
          if (progress.isComplete && widget.onComplete != null) {
            widget.onComplete!();
          }
        }
      }
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showProgress && _currentProgress != null)
          _buildProgressOverlay(),
      ],
    );
  }

  Widget _buildProgressOverlay() {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _currentProgress!.message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (_currentProgress!.progress > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                value: _currentProgress!.progress,
                backgroundColor: Colors.grey[300],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
