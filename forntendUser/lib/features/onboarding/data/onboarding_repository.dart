import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _onboardingDataKey = 'onboarding_data';
  
  final SharedPreferences _prefs;
  
  OnboardingRepository(this._prefs);
  
  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }
  
  /// Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    await _prefs.setBool(_onboardingCompletedKey, true);
  }
  
  /// Reset onboarding completion status
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_onboardingCompletedKey, false);
  }
  
  /// Save onboarding data
  Future<void> saveOnboardingData(Map<String, dynamic> data) async {
    await _prefs.setString(_onboardingDataKey, jsonEncode(data));
  }
  
  /// Get saved onboarding data
  Future<Map<String, dynamic>?> getOnboardingData() async {
    final dataString = _prefs.getString(_onboardingDataKey);
    if (dataString != null) {
      try {
        return jsonDecode(dataString) as Map<String, dynamic>;
      } catch (e) {
        // Handle JSON decode error
        return null;
      }
    }
    return null;
  }
  
  /// Clear onboarding data
  Future<void> clearOnboardingData() async {
    await _prefs.remove(_onboardingDataKey);
  }
  
  /// Get onboarding progress
  Future<int> getOnboardingProgress() async {
    final data = await getOnboardingData();
    return data?['progress'] ?? 0;
  }
  
  /// Save onboarding progress
  Future<void> saveOnboardingProgress(int progress) async {
    final data = await getOnboardingData() ?? {};
    data['progress'] = progress;
    await saveOnboardingData(data);
  }
  
  /// Check if user has seen specific onboarding screen
  Future<bool> hasSeenScreen(int screenIndex) async {
    final data = await getOnboardingData();
    final seenScreens = data?['seen_screens'] as List<dynamic>? ?? [];
    return seenScreens.contains(screenIndex);
  }
  
  /// Mark screen as seen
  Future<void> markScreenAsSeen(int screenIndex) async {
    final data = await getOnboardingData() ?? {};
    final seenScreens = List<int>.from(data['seen_screens'] ?? []);
    if (!seenScreens.contains(screenIndex)) {
      seenScreens.add(screenIndex);
      data['seen_screens'] = seenScreens;
      await saveOnboardingData(data);
    }
  }
  
  /// Get onboarding start time
  Future<DateTime?> getOnboardingStartTime() async {
    final data = await getOnboardingData();
    final timestamp = data?['start_time'];
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  
  /// Set onboarding start time
  Future<void> setOnboardingStartTime() async {
    final data = await getOnboardingData() ?? {};
    data['start_time'] = DateTime.now().millisecondsSinceEpoch;
    await saveOnboardingData(data);
  }
  
  /// Get onboarding completion time
  Future<DateTime?> getOnboardingCompletionTime() async {
    final data = await getOnboardingData();
    final timestamp = data?['completion_time'];
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
  
  /// Set onboarding completion time
  Future<void> setOnboardingCompletionTime() async {
    final data = await getOnboardingData() ?? {};
    data['completion_time'] = DateTime.now().millisecondsSinceEpoch;
    await saveOnboardingData(data);
  }
  
  /// Calculate onboarding duration
  Future<Duration?> getOnboardingDuration() async {
    final startTime = await getOnboardingStartTime();
    final completionTime = await getOnboardingCompletionTime();
    
    if (startTime != null && completionTime != null) {
      return completionTime.difference(startTime);
    }
    return null;
  }
  
  /// Get user preferences from onboarding
  Future<Map<String, dynamic>> getUserPreferences() async {
    final data = await getOnboardingData();
    return Map<String, dynamic>.from(data?['preferences'] ?? {});
  }
  
  /// Save user preferences from onboarding
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final data = await getOnboardingData() ?? {};
    data['preferences'] = preferences;
    await saveOnboardingData(data);
  }
  
  /// Check if user has completed all onboarding steps
  Future<bool> hasCompletedAllSteps() async {
    final data = await getOnboardingData();
    final completedSteps = data?['completed_steps'] as List<dynamic>? ?? [];
    final totalSteps = data?['total_steps'] ?? 3;
    return completedSteps.length >= totalSteps;
  }
  
  /// Mark step as completed
  Future<void> markStepCompleted(int stepIndex) async {
    final data = await getOnboardingData() ?? {};
    final completedSteps = List<int>.from(data['completed_steps'] ?? []);
    if (!completedSteps.contains(stepIndex)) {
      completedSteps.add(stepIndex);
      data['completed_steps'] = completedSteps;
      await saveOnboardingData(data);
    }
  }
  
  /// Get completed steps count
  Future<int> getCompletedStepsCount() async {
    final data = await getOnboardingData();
    final completedSteps = data?['completed_steps'] as List<dynamic>? ?? [];
    return completedSteps.length;
  }
  
  /// Get total steps count
  Future<int> getTotalStepsCount() async {
    final data = await getOnboardingData();
    return data?['total_steps'] ?? 3;
  }
  
  /// Set total steps count
  Future<void> setTotalStepsCount(int totalSteps) async {
    final data = await getOnboardingData() ?? {};
    data['total_steps'] = totalSteps;
    await saveOnboardingData(data);
  }
}
