import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  static Future<bool> hasSeenOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_hasSeenOnboardingKey) ?? false;
  }

  static Future<bool> markOnboardingSeen() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setBool(_hasSeenOnboardingKey, true);
  }
}
