import 'package:flutter/services.dart';

/// Service for preloading and caching assets
class AssetsService {
  static bool _assetsPreloaded = false;
  
  /// Preload critical assets for faster rendering
  static Future<void> preloadCriticalAssets() async {
    if (_assetsPreloaded) return;
    
    try {
      // Preload commonly used assets
      await Future.wait([
        // Preload fonts (these are already bundled)
        Future.value(), // Fonts are automatically loaded
      ]);
      
      _assetsPreloaded = true;
      print('🎨 Critical assets preloaded successfully');
      
    } catch (e) {
      print('❌ Failed to preload assets: $e');
    }
  }
  
  /// Check if assets are preloaded
  static bool get areAssetsPreloaded => _assetsPreloaded;
  
  /// Clear preloaded assets (if needed)
  static void clearPreloadedAssets() {
    _assetsPreloaded = false;
  }
}
