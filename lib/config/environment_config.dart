import 'package:flutter/foundation.dart';

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;
  
  // Environment-specific configurations
  static const Map<Environment, Map<String, String>> _configs = {
    Environment.development: {
      'apiBaseUrl': 'https://api-dev.lgbtinder.com',
      'websocketUrl': 'wss://ws-dev.lgbtinder.com',
      'appName': 'LGBTinder Dev',
      'appVersion': '1.0.0-dev',
      'debugMode': 'true',
      'logLevel': 'debug',
      'enableAnalytics': 'false',
      'enableCrashReporting': 'false',
      'enablePerformanceMonitoring': 'false',
      'apiTimeout': '30000',
      'maxRetries': '3',
      'cacheExpiration': '300', // 5 minutes
      'rateLimitEnabled': 'false',
      'mockDataEnabled': 'true',
    },
    Environment.staging: {
      'apiBaseUrl': 'https://api-staging.lgbtinder.com',
      'websocketUrl': 'wss://ws-staging.lgbtinder.com',
      'appName': 'LGBTinder Staging',
      'appVersion': '1.0.0-staging',
      'debugMode': 'true',
      'logLevel': 'info',
      'enableAnalytics': 'true',
      'enableCrashReporting': 'true',
      'enablePerformanceMonitoring': 'true',
      'apiTimeout': '20000',
      'maxRetries': '2',
      'cacheExpiration': '600', // 10 minutes
      'rateLimitEnabled': 'true',
      'mockDataEnabled': 'false',
    },
    Environment.production: {
      'apiBaseUrl': 'https://api.lgbtinder.com',
      'websocketUrl': 'wss://ws.lgbtinder.com',
      'appName': 'LGBTinder',
      'appVersion': '1.0.0',
      'debugMode': 'false',
      'logLevel': 'error',
      'enableAnalytics': 'true',
      'enableCrashReporting': 'true',
      'enablePerformanceMonitoring': 'true',
      'apiTimeout': '15000',
      'maxRetries': '2',
      'cacheExpiration': '1800', // 30 minutes
      'rateLimitEnabled': 'true',
      'mockDataEnabled': 'false',
    },
  };

  // Get current environment
  static Environment get currentEnvironment => _currentEnvironment;

  // Set environment
  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  // Get configuration value
  static String getConfig(String key) {
    return _configs[_currentEnvironment]?[key] ?? '';
  }

  // Get API base URL
  static String get apiBaseUrl => getConfig('apiBaseUrl');

  // Get WebSocket URL
  static String get websocketUrl => getConfig('websocketUrl');

  // Get app name
  static String get appName => getConfig('appName');

  // Get app version
  static String get appVersion => getConfig('appVersion');

  // Get debug mode
  static bool get debugMode => getConfig('debugMode') == 'true';

  // Get log level
  static String get logLevel => getConfig('logLevel');

  // Get analytics enabled
  static bool get enableAnalytics => getConfig('enableAnalytics') == 'true';

  // Get crash reporting enabled
  static bool get enableCrashReporting => getConfig('enableCrashReporting') == 'true';

  // Get performance monitoring enabled
  static bool get enablePerformanceMonitoring => getConfig('enablePerformanceMonitoring') == 'true';

  // Get API timeout
  static int get apiTimeout => int.tryParse(getConfig('apiTimeout')) ?? 15000;

  // Get max retries
  static int get maxRetries => int.tryParse(getConfig('maxRetries')) ?? 2;

  // Get cache expiration
  static int get cacheExpiration => int.tryParse(getConfig('cacheExpiration')) ?? 300;

  // Get rate limit enabled
  static bool get rateLimitEnabled => getConfig('rateLimitEnabled') == 'true';

  // Get mock data enabled
  static bool get mockDataEnabled => getConfig('mockDataEnabled') == 'true';

  // Get all configuration for current environment
  static Map<String, String> get allConfig => _configs[_currentEnvironment] ?? {};

  // Check if running in development
  static bool get isDevelopment => _currentEnvironment == Environment.development;

  // Check if running in staging
  static bool get isStaging => _currentEnvironment == Environment.staging;

  // Check if running in production
  static bool get isProduction => _currentEnvironment == Environment.production;

  // Get environment name
  static String get environmentName {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }

  // Initialize environment based on build mode
  static void initialize() {
    if (kDebugMode) {
      // In debug mode, default to development
      _currentEnvironment = Environment.development;
    } else {
      // In release mode, default to production
      _currentEnvironment = Environment.production;
    }
  }

  // Get environment-specific API endpoints
  static Map<String, String> get apiEndpoints {
    final baseUrl = apiBaseUrl;
    return {
      'auth': {
        'register': '$baseUrl/auth/register',
        'checkUserState': '$baseUrl/auth/check-user-state',
        'verifyEmail': '$baseUrl/auth/send-verification',
        'completeProfile': '$baseUrl/complete-registration',
      },
      'reference': {
        'countries': '$baseUrl/countries',
        'cities': '$baseUrl/cities',
        'genders': '$baseUrl/genders',
        'jobs': '$baseUrl/jobs',
        'education': '$baseUrl/education',
        'interests': '$baseUrl/interests',
        'languages': '$baseUrl/languages',
        'musicGenres': '$baseUrl/music-genres',
        'relationGoals': '$baseUrl/relation-goals',
        'preferredGenders': '$baseUrl/preferred-genders',
      },
      'user': {
        'currentUser': '$baseUrl/user',
        'updateProfile': '$baseUrl/profile/update',
        'uploadPicture': '$baseUrl/profile-pictures/upload',
      },
      'matching': {
        'likeUser': '$baseUrl/likes/like',
        'getMatches': '$baseUrl/likes/matches',
      },
      'chat': {
        'sendMessage': '$baseUrl/chat/send',
        'getHistory': '$baseUrl/chat/history',
      },
    };
  }

  // Get environment-specific WebSocket endpoints
  static Map<String, String> get websocketEndpoints {
    final baseUrl = websocketUrl;
    return {
      'main': baseUrl,
      'chat': '$baseUrl/chat',
      'notifications': '$baseUrl/notifications',
    };
  }

  // Get environment-specific feature flags
  static Map<String, bool> get featureFlags {
    return {
      'enablePushNotifications': isProduction || isStaging,
      'enableBiometricAuth': isProduction,
      'enableAdvancedMatching': isProduction || isStaging,
      'enableVideoCalls': isProduction,
      'enableLocationServices': isProduction || isStaging,
      'enableSocialLogin': isProduction || isStaging,
      'enablePremiumFeatures': isProduction,
      'enableBetaFeatures': isDevelopment || isStaging,
      'enableDebugMenu': isDevelopment,
      'enableMockData': isDevelopment,
    };
  }

  // Get environment-specific security settings
  static Map<String, dynamic> get securitySettings {
    return {
      'requireSSL': isProduction || isStaging,
      'certificatePinning': isProduction,
      'encryptLocalStorage': isProduction || isStaging,
      'biometricAuth': isProduction,
      'sessionTimeout': isProduction ? 3600 : 7200, // 1 hour in prod, 2 hours in dev/staging
      'maxLoginAttempts': isProduction ? 3 : 5,
      'lockoutDuration': isProduction ? 900 : 300, // 15 minutes in prod, 5 minutes in dev/staging
    };
  }

  // Get environment-specific performance settings
  static Map<String, dynamic> get performanceSettings {
    return {
      'maxConcurrentRequests': isProduction ? 3 : 5,
      'requestTimeout': apiTimeout,
      'cacheSize': isProduction ? 50 : 100, // MB
      'imageCompression': isProduction ? 0.8 : 0.9,
      'enableRequestBatching': isProduction || isStaging,
      'enableResponseCaching': true,
      'enableImageCaching': true,
      'enableDataPrefetching': isProduction || isStaging,
    };
  }

  // Get environment-specific logging settings
  static Map<String, dynamic> get loggingSettings {
    return {
      'logLevel': logLevel,
      'enableConsoleLogging': isDevelopment || isStaging,
      'enableFileLogging': isProduction || isStaging,
      'enableRemoteLogging': isProduction,
      'maxLogFileSize': isProduction ? 10 : 50, // MB
      'logRetentionDays': isProduction ? 7 : 30,
    };
  }

  // Validate configuration
  static bool validateConfig() {
    final config = _configs[_currentEnvironment];
    if (config == null) return false;

    // Check required configurations
    final requiredKeys = [
      'apiBaseUrl',
      'websocketUrl',
      'appName',
      'appVersion',
    ];

    for (final key in requiredKeys) {
      if (!config.containsKey(key) || config[key]!.isEmpty) {
        return false;
      }
    }

    return true;
  }

  // Get configuration summary
  static Map<String, dynamic> getConfigSummary() {
    return {
      'environment': environmentName,
      'apiBaseUrl': apiBaseUrl,
      'websocketUrl': websocketUrl,
      'appName': appName,
      'appVersion': appVersion,
      'debugMode': debugMode,
      'logLevel': logLevel,
      'enableAnalytics': enableAnalytics,
      'enableCrashReporting': enableCrashReporting,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'apiTimeout': apiTimeout,
      'maxRetries': maxRetries,
      'cacheExpiration': cacheExpiration,
      'rateLimitEnabled': rateLimitEnabled,
      'mockDataEnabled': mockDataEnabled,
      'featureFlags': featureFlags,
      'securitySettings': securitySettings,
      'performanceSettings': performanceSettings,
      'loggingSettings': loggingSettings,
    };
  }
}
