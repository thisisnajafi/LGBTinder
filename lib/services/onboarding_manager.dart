import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _onboardingSkippedKey = 'onboarding_skipped';
  static const String _onboardingVersionKey = 'onboarding_version';
  static const String _firstLaunchKey = 'first_launch';
  
  static const String _currentOnboardingVersion = '1.0.0';

  /// Check if onboarding has been completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Check if onboarding was skipped
  static Future<bool> isOnboardingSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSkippedKey) ?? false;
  }

  /// Check if this is the first app launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    await prefs.setBool(_firstLaunchKey, false);
    await prefs.setString(_onboardingVersionKey, _currentOnboardingVersion);
  }

  /// Mark onboarding as skipped
  static Future<void> markOnboardingSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSkippedKey, true);
    await prefs.setBool(_firstLaunchKey, false);
  }

  /// Reset onboarding state (for testing or re-onboarding)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    await prefs.remove(_onboardingSkippedKey);
    await prefs.remove(_onboardingVersionKey);
    await prefs.setBool(_firstLaunchKey, true);
  }

  /// Check if onboarding should be shown (new version or first launch)
  static Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVersion = prefs.getString(_onboardingVersionKey);
    final isFirstLaunch = prefs.getBool(_firstLaunchKey) ?? true;
    
    // Show onboarding if it's the first launch or if the version has changed
    return isFirstLaunch || lastVersion != _currentOnboardingVersion;
  }

  /// Get onboarding statistics
  static Future<Map<String, dynamic>> getOnboardingStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'isCompleted': prefs.getBool(_onboardingCompletedKey) ?? false,
      'isSkipped': prefs.getBool(_onboardingSkippedKey) ?? false,
      'isFirstLaunch': prefs.getBool(_firstLaunchKey) ?? true,
      'lastVersion': prefs.getString(_onboardingVersionKey),
      'currentVersion': _currentOnboardingVersion,
    };
  }

  /// Update onboarding version (for future updates)
  static Future<void> updateOnboardingVersion(String newVersion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_onboardingVersionKey, newVersion);
  }
}
