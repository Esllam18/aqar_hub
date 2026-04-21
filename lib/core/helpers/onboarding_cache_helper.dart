import 'package:shared_preferences/shared_preferences.dart';

abstract final class OnboardingCacheHelper {
  static const String _key = 'is_onboarding_seen';

  static Future<void> setSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}
