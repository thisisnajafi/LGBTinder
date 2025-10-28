import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Audio Cache Service
/// 
/// Manages caching of audio files to reduce bandwidth usage
/// and improve playback performance.
/// 
/// Features:
/// - Download and cache audio files locally
/// - Check cache before downloading
/// - Automatic cache size management (max 100MB)
/// - Clear cache when needed
/// - Track cache statistics
class AudioCacheService {
  static final AudioCacheService _instance = AudioCacheService._internal();
  factory AudioCacheService() => _instance;
  AudioCacheService._internal();

  static const String _cacheDirectory = 'audio_cache';
  static const int _maxCacheSizeMB = 100;
  static const String _cacheMetadataKey = 'audio_cache_metadata';

  Directory? _cacheDir;
  Map<String, AudioCacheMetadata> _cacheMetadata = {};
  bool _isInitialized = false;

  /// Initialize the audio cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/$_cacheDirectory');

      // Create cache directory if it doesn't exist
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }

      // Load cache metadata
      await _loadCacheMetadata();

      _isInitialized = true;
      debugPrint('AudioCacheService initialized. Cache dir: ${_cacheDir!.path}');
    } catch (e) {
      debugPrint('Error initializing AudioCacheService: $e');
    }
  }

  /// Get cached audio file or download if not cached
  Future<String?> getCachedAudio(String audioUrl) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final cacheKey = _generateCacheKey(audioUrl);
      final cachedFile = File('${_cacheDir!.path}/$cacheKey.m4a');

      // Check if file exists in cache
      if (await cachedFile.exists()) {
        debugPrint('Audio found in cache: $cacheKey');
        
        // Update last accessed time
        _cacheMetadata[cacheKey] = AudioCacheMetadata(
          url: audioUrl,
          filePath: cachedFile.path,
          fileSize: await cachedFile.length(),
          lastAccessed: DateTime.now(),
          downloadedAt: _cacheMetadata[cacheKey]?.downloadedAt ?? DateTime.now(),
        );
        await _saveCacheMetadata();

        return cachedFile.path;
      }

      // Download and cache the audio file
      return await _downloadAndCache(audioUrl, cachedFile);
    } catch (e) {
      debugPrint('Error getting cached audio: $e');
      return audioUrl; // Return original URL as fallback
    }
  }

  /// Download audio file and save to cache
  Future<String?> _downloadAndCache(String audioUrl, File cachedFile) async {
    try {
      debugPrint('Downloading audio: $audioUrl');

      final response = await http.get(Uri.parse(audioUrl));
      
      if (response.statusCode == 200) {
        // Write file to cache
        await cachedFile.writeAsBytes(response.bodyBytes);
        
        final cacheKey = _generateCacheKey(audioUrl);
        final fileSize = await cachedFile.length();

        // Add to metadata
        _cacheMetadata[cacheKey] = AudioCacheMetadata(
          url: audioUrl,
          filePath: cachedFile.path,
          fileSize: fileSize,
          lastAccessed: DateTime.now(),
          downloadedAt: DateTime.now(),
        );
        await _saveCacheMetadata();

        debugPrint('Audio cached: $cacheKey (${fileSize / 1024} KB)');

        // Check cache size and cleanup if needed
        await _cleanupCacheIfNeeded();

        return cachedFile.path;
      } else {
        debugPrint('Failed to download audio: ${response.statusCode}');
        return audioUrl; // Return original URL as fallback
      }
    } catch (e) {
      debugPrint('Error downloading audio: $e');
      return audioUrl; // Return original URL as fallback
    }
  }

  /// Generate cache key from URL using MD5 hash
  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  /// Load cache metadata from SharedPreferences
  Future<void> _loadCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString(_cacheMetadataKey);

      if (metadataJson != null) {
        final Map<String, dynamic> decoded = json.decode(metadataJson);
        _cacheMetadata = decoded.map(
          (key, value) => MapEntry(
            key,
            AudioCacheMetadata.fromJson(value as Map<String, dynamic>),
          ),
        );
        debugPrint('Loaded cache metadata: ${_cacheMetadata.length} entries');
      }
    } catch (e) {
      debugPrint('Error loading cache metadata: $e');
      _cacheMetadata = {};
    }
  }

  /// Save cache metadata to SharedPreferences
  Future<void> _saveCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = json.encode(
        _cacheMetadata.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(_cacheMetadataKey, metadataJson);
    } catch (e) {
      debugPrint('Error saving cache metadata: $e');
    }
  }

  /// Get total cache size in bytes
  Future<int> getCacheSize() async {
    int totalSize = 0;
    for (final metadata in _cacheMetadata.values) {
      totalSize += metadata.fileSize;
    }
    return totalSize;
  }

  /// Get cache size in MB
  Future<double> getCacheSizeMB() async {
    final bytes = await getCacheSize();
    return bytes / (1024 * 1024);
  }

  /// Cleanup cache if it exceeds max size
  Future<void> _cleanupCacheIfNeeded() async {
    final cacheSizeMB = await getCacheSizeMB();
    
    if (cacheSizeMB > _maxCacheSizeMB) {
      debugPrint('Cache size ($cacheSizeMB MB) exceeds limit ($_maxCacheSizeMB MB). Cleaning up...');
      
      // Sort by last accessed time (oldest first)
      final sortedEntries = _cacheMetadata.entries.toList()
        ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

      // Remove oldest files until cache is under limit
      for (final entry in sortedEntries) {
        if (await getCacheSizeMB() <= _maxCacheSizeMB * 0.8) {
          break; // Stop when cache is at 80% of limit
        }

        try {
          final file = File(entry.value.filePath);
          if (await file.exists()) {
            await file.delete();
          }
          _cacheMetadata.remove(entry.key);
          debugPrint('Removed cached audio: ${entry.key}');
        } catch (e) {
          debugPrint('Error removing cached file: $e');
        }
      }

      await _saveCacheMetadata();
      debugPrint('Cache cleanup complete. New size: ${await getCacheSizeMB()} MB');
    }
  }

  /// Clear all cached audio files
  Future<void> clearCache() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Delete all files in cache directory
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }

      // Clear metadata
      _cacheMetadata.clear();
      await _saveCacheMetadata();

      debugPrint('Audio cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Get cache statistics
  Future<AudioCacheStats> getCacheStats() async {
    final totalFiles = _cacheMetadata.length;
    final totalSizeBytes = await getCacheSize();
    final totalSizeMB = totalSizeBytes / (1024 * 1024);

    return AudioCacheStats(
      totalFiles: totalFiles,
      totalSizeBytes: totalSizeBytes,
      totalSizeMB: totalSizeMB,
      maxSizeMB: _maxCacheSizeMB,
      utilizationPercent: (totalSizeMB / _maxCacheSizeMB) * 100,
    );
  }

  /// Check if audio is cached
  Future<bool> isCached(String audioUrl) async {
    if (!_isInitialized) {
      await initialize();
    }

    final cacheKey = _generateCacheKey(audioUrl);
    final cachedFile = File('${_cacheDir!.path}/$cacheKey.m4a');
    return await cachedFile.exists();
  }

  /// Preload audio files for offline use
  Future<void> preloadAudios(List<String> audioUrls) async {
    for (final url in audioUrls) {
      try {
        await getCachedAudio(url);
      } catch (e) {
        debugPrint('Error preloading audio: $e');
      }
    }
  }
}

/// Audio Cache Metadata
class AudioCacheMetadata {
  final String url;
  final String filePath;
  final int fileSize;
  final DateTime lastAccessed;
  final DateTime downloadedAt;

  AudioCacheMetadata({
    required this.url,
    required this.filePath,
    required this.fileSize,
    required this.lastAccessed,
    required this.downloadedAt,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'filePath': filePath,
        'fileSize': fileSize,
        'lastAccessed': lastAccessed.toIso8601String(),
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory AudioCacheMetadata.fromJson(Map<String, dynamic> json) {
    return AudioCacheMetadata(
      url: json['url'] as String,
      filePath: json['filePath'] as String,
      fileSize: json['fileSize'] as int,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
    );
  }
}

/// Audio Cache Statistics
class AudioCacheStats {
  final int totalFiles;
  final int totalSizeBytes;
  final double totalSizeMB;
  final int maxSizeMB;
  final double utilizationPercent;

  AudioCacheStats({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.totalSizeMB,
    required this.maxSizeMB,
    required this.utilizationPercent,
  });

  @override
  String toString() {
    return 'AudioCacheStats(files: $totalFiles, size: ${totalSizeMB.toStringAsFixed(2)} MB / $maxSizeMB MB, utilization: ${utilizationPercent.toStringAsFixed(1)}%)';
  }
}

