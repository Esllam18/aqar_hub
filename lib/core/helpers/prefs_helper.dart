// lib/core/helpers/prefs_helper.dart
//
// Thin compatibility shim used by ProfileCubit.
// All real work is delegated to AppPrefs.

import 'app_prefs.dart';

class PrefsHelper {
  PrefsHelper._();

  static Map<String, dynamic>? getCachedProfile() =>
      AppPrefs.getCachedProfile();

  static Future<void> cacheProfile(Map<String, dynamic> map) =>
      AppPrefs.cacheProfile(map);

  static Future<void> clearProfile() => AppPrefs.clearProfile();
}
