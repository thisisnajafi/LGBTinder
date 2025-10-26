import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/user_state_models.dart';
import '../../models/user.dart';
import '../../models/api_models/reference_data_models.dart';
import '../../services/token_management_service.dart';
import '../../services/api_services/user_api_service.dart';
import '../../services/api_services/reference_data_api_service.dart';
import '../../services/cache/reference_data_cache.dart';
import '../../services/preload/assets_service.dart';
import '../../components/navbar/lgbtinder_logo.dart';

/// Optimized splash page with performance improvements
class OptimizedSplashPage extends StatefulWidget {
  const OptimizedSplashPage({super.key});

  @override
  State<OptimizedSplashPage> createState() => _OptimizedSplashPageState();
}

class _OptimizedSplashPageState extends State<OptimizedSplashPage> 
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  // Performance tracking
  DateTime _startTime = DateTime.now();
  String _currentOperation = 'Initializing...';
  double _progress = 0.0;
  bool _hasTimedOut = false;
  
  // Splash timeout (max 10 seconds)
  static const Duration _maxSplashDuration = Duration(seconds: 10);
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    // Start logo animation immediately
    _logoController.forward();
  }

  void _startInitialization() async {
    // Set timeout timer
    _timeoutTimer = Timer(_maxSplashDuration, _handleTimeout);
    
    try {
      await _performOptimizedInitialization();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _performOptimizedInitialization() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    
    _updateProgress(0.1, 'Starting initialization...');
    
    // Start parallel operations
    await Future.wait([
      _checkAuthenticationAsync(appState),
      _loadCriticalDataAsync(appState),
      _preloadEssentialServices(appState),
    ], eagerError: false);
    
    // Wait for minimum splash time (better UX)
    await _waitForMinimumSplashDuration();
  }

  Future<void> _checkAuthenticationAsync(AppStateProvider appState) async {
    try {
      _updateProgress(0.3, 'Verifying user session...');
      
      final isAuthenticated = await TokenManagementService.isAuthenticated();
      
      if (isAuthenticated && _progress < 0.7) {
        _updateProgress(0.5, 'Loading user profile...');
        
        final token = await TokenManagementService.getValidAccessToken();
        if (token != null) {
          final userProfile = await UserApiService.getCurrentUser(token);
          if (userProfile != null) {
            appState.setUser(User.fromJson(userProfile.toJson()));
            appState.setToken(token);
            appState.setUserState(ReadyForLoginState({'user_id': appState.user?.id ?? 0}));
          }
        }
      } else if (_progress < 0.7) {
        _updateProgress(0.4, 'Preparing for first-time setup...');
        appState.setUserState(null);
      }
      
    } catch (e) {
      print('Authentication check failed: $e');
      _handleAuthenticationError(appState);
    }
  }

  Future<void> _loadCriticalDataAsync(AppStateProvider appState) async {
    try {
      _updateProgress(0.6, 'Loading app data...');
      
      // Load reference data in background (non-blocking)
      final countriesFuture = ReferenceDataCache.loadCountriesWithCache();
      final referenceDataFuture = ReferenceDataCache.loadReferenceDataWithCache();
      
      final results = await Future.wait([
        countriesFuture.catchError((e) {
          print('Countries loading failed: $e');
          return <Country>[];
        }),
        referenceDataFuture.catchError((e) {
          print('Reference data loading failed: $e');
          return <String, List<ReferenceDataItem>>{};
        }),
      ], eagerError: false);
      
      // Safe casting with fallbacks
      final countries = results.isNotEmpty ? 
        (results[0] as List<Country>?) ?? <Country>[] : <Country>[];
      final referenceData = results.length > 1 ? 
        (results[1] as Map<String, List<ReferenceDataItem>>?) ?? 
        <String, List<ReferenceDataItem>>{} : <String, List<ReferenceDataItem>>{};
      
      appState.setCountries(countries);
      appState.setReferenceData(referenceData);
      
      _updateProgress(0.9, 'Finalizing setup...');
      
    } catch (e) {
      print('Critical data loading failed: $e');
      // Continue with empty data
      appState.setCountries([]);
      appState.setReferenceData({});
    }
  }

  Future<void> _preloadEssentialServices(AppStateProvider appState) async {
    try {
      _updateProgress(0.8, 'Preparing services...');
      
      // Preload essential services in the background
      await Future.wait([
        AssetsService.preloadCriticalAssets(),
        Future.delayed(const Duration(milliseconds: 200)), // Simulate other service setup
      ]);
      
      print('🎛️ Essential services preloaded successfully');
      
    } catch (e) {
      print('Service preloading failed: $e');
      // Continue anyway
    }
  }

  Future<void> _waitForMinimumSplashDuration() async {
    final elapsed = DateTime.now().difference(_startTime);
    const minimumSplashDuration = Duration(milliseconds: 1500);
    
    if (elapsed < minimumSplashDuration) {
      await Future.delayed(minimumSplashDuration - elapsed);
    }
    
    if (_progress < 1.0) {
      _updateProgress(1.0, 'Ready!');
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    _completeInitialization();
  }

  void _updateProgress(double newProgress, String operation) {
    if (!mounted) return; // Safety check
    
    setState(() {
      _progress = newProgress.clamp(0.0, 1.0);
      _currentOperation = operation;
    });
    
    try {
      _progressController.animateTo(_progress.clamp(0.0, 1.0));
    } catch (e) {
      print('Animation error: $e');
    }
  }

  void _handleTimeout() {
    if (!mounted) return; // Safety check
    
    if (!_hasTimedOut && _progress < 1.0) {
      _hasTimedOut = true;
      _updateProgress(1.0, 'Loading completed (timeout reached)');
      
      // Force completion after timeout
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _completeInitialization();
        }
      });
    }
  }

  void _handleAuthenticationError(AppStateProvider appState) {
    print('🔒 Authentication failed - proceeding as new user');
    appState.setUserState(null);
    appState.setUser(null);
    appState.setToken(null);
    _updateProgress(0.4, 'Ready for new user setup');
  }

  void _handleError(dynamic error) {
    print('Splash initialization error: $error');
    _updateProgress(1.0, 'Continuing with limited functionality...');
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _completeInitialization();
      }
    });
  }

  void _completeInitialization() {
    if (!mounted) return; // Check if widget is still mounted
    
    _timeoutTimer?.cancel();
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.setLoading(false);
    } catch (e) {
      print('Error setting app state: $e');
    }
    
    // No need to navigate manually - AuthWrapper will handle it
  }

  @override
  void dispose() {
    // Cancel all timers
    _timeoutTimer?.cancel();
    
    // Dispose controllers
    try {
      _logoController.dispose();
      _progressController.dispose();
    } catch (e) {
      print('Error disposing controllers: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splashDuration = DateTime.now().difference(_startTime);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.gray800,
              AppColors.secondary,
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value.clamp(0.0, 1.0),
                        child: Opacity(
                          opacity: _logoAnimation.value.clamp(0.0, 1.0),
                          child: const LGBTinderLogo(
                            size: 120,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Progress section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // Progress indicator
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                        return LinearProgressIndicator(
                          value: (_progressAnimation.value * _progress).clamp(0.0, 1.0),
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          minHeight: 4,
                        );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Current operation text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _currentOperation,
                          key: ValueKey(_currentOperation),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Progress percentage
                      Text(
                        '${(_progress * 100).round()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Debug info (only in debug mode)
                      if (kDebugMode) ...[
                        Text(
                          'Elapsed: ${splashDuration.inMilliseconds}ms',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        if (_hasTimedOut)
                          const Text(
                            '⚠️ Timeout reached',
                            style: TextStyle(
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: const Text(
                  'LGBTinder by PrideTech',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
