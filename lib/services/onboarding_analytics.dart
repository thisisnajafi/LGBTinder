import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingAnalytics {
  static const String _analyticsKey = 'onboarding_analytics';
  
  /// Track onboarding step completion
  static Future<void> trackStepCompleted(int stepIndex, String stepTitle) async {
    final analytics = await _getAnalytics();
    final stepKey = 'step_${stepIndex}_completed';
    
    analytics[stepKey] = {
      'stepIndex': stepIndex,
      'stepTitle': stepTitle,
      'timestamp': DateTime.now().toIso8601String(),
      'completed': true,
    };
    
    await _saveAnalytics(analytics);
  }

  /// Track onboarding step skipped
  static Future<void> trackStepSkipped(int stepIndex, String stepTitle) async {
    final analytics = await _getAnalytics();
    final stepKey = 'step_${stepIndex}_skipped';
    
    analytics[stepKey] = {
      'stepIndex': stepIndex,
      'stepTitle': stepTitle,
      'timestamp': DateTime.now().toIso8601String(),
      'skipped': true,
    };
    
    await _saveAnalytics(analytics);
  }

  /// Track onboarding completion
  static Future<void> trackOnboardingCompleted({
    required int totalSteps,
    required int completedSteps,
    required int skippedSteps,
    required Duration timeSpent,
  }) async {
    final analytics = await _getAnalytics();
    
    analytics['onboarding_completed'] = {
      'totalSteps': totalSteps,
      'completedSteps': completedSteps,
      'skippedSteps': skippedSteps,
      'completionRate': completedSteps / totalSteps,
      'timeSpent': timeSpent.inSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _saveAnalytics(analytics);
  }

  /// Track onboarding abandonment
  static Future<void> trackOnboardingAbandoned({
    required int currentStep,
    required Duration timeSpent,
  }) async {
    final analytics = await _getAnalytics();
    
    analytics['onboarding_abandoned'] = {
      'currentStep': currentStep,
      'timeSpent': timeSpent.inSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _saveAnalytics(analytics);
  }

  /// Track button interactions
  static Future<void> trackButtonInteraction({
    required String buttonType,
    required String action,
    required int stepIndex,
  }) async {
    final analytics = await _getAnalytics();
    final interactionKey = 'button_${buttonType}_${action}_step_$stepIndex';
    
    analytics[interactionKey] = {
      'buttonType': buttonType,
      'action': action,
      'stepIndex': stepIndex,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _saveAnalytics(analytics);
  }

  /// Track onboarding preferences
  static Future<void> trackOnboardingPreferences({
    required Map<String, dynamic> preferences,
  }) async {
    final analytics = await _getAnalytics();
    
    analytics['onboarding_preferences'] = {
      'preferences': preferences,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _saveAnalytics(analytics);
  }

  /// Get onboarding analytics data
  static Future<Map<String, dynamic>> getAnalytics() async {
    return await _getAnalytics();
  }

  /// Clear onboarding analytics
  static Future<void> clearAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_analyticsKey);
  }

  /// Get onboarding completion rate
  static Future<double> getCompletionRate() async {
    final analytics = await _getAnalytics();
    final completed = analytics['onboarding_completed'];
    
    if (completed != null) {
      return completed['completionRate'] ?? 0.0;
    }
    
    return 0.0;
  }

  /// Get average time spent on onboarding
  static Future<int> getAverageTimeSpent() async {
    final analytics = await _getAnalytics();
    final completed = analytics['onboarding_completed'];
    
    if (completed != null) {
      return completed['timeSpent'] ?? 0;
    }
    
    return 0;
  }

  /// Get most skipped step
  static Future<String?> getMostSkippedStep() async {
    final analytics = await _getAnalytics();
    int maxSkips = 0;
    String? mostSkippedStep;
    
    for (final key in analytics.keys) {
      if (key.startsWith('step_') && key.endsWith('_skipped')) {
        final stepData = analytics[key];
        if (stepData != null && stepData['skipped'] == true) {
          final stepTitle = stepData['stepTitle'] as String?;
          if (stepTitle != null) {
            maxSkips++;
            mostSkippedStep = stepTitle;
          }
        }
      }
    }
    
    return mostSkippedStep;
  }

  /// Get onboarding engagement score
  static Future<double> getEngagementScore() async {
    final analytics = await _getAnalytics();
    double score = 0.0;
    
    // Completion bonus
    if (analytics.containsKey('onboarding_completed')) {
      score += 50.0;
    }
    
    // Step completion bonus
    int completedSteps = 0;
    for (final key in analytics.keys) {
      if (key.startsWith('step_') && key.endsWith('_completed')) {
        completedSteps++;
      }
    }
    score += completedSteps * 10.0;
    
    // Time spent bonus (up to 20 points)
    final completed = analytics['onboarding_completed'];
    if (completed != null) {
      final timeSpent = completed['timeSpent'] as int? ?? 0;
      score += (timeSpent / 60.0).clamp(0.0, 20.0); // 1 point per minute, max 20
    }
    
    return score.clamp(0.0, 100.0);
  }

  /// Private helper methods
  static Future<Map<String, dynamic>> _getAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    final analyticsJson = prefs.getString(_analyticsKey);
    
    if (analyticsJson != null) {
      try {
        return Map<String, dynamic>.from(json.decode(analyticsJson));
      } catch (e) {
        return {};
      }
    }
    
    return {};
  }

  static Future<void> _saveAnalytics(Map<String, dynamic> analytics) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_analyticsKey, json.encode(analytics));
  }
}
