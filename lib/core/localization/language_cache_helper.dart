// lib/core/helpers/language_cache_helper.dart

import 'package:shared_preferences/shared_preferences.dart';

abstract final class LanguageCacheHelper {
  static const String _key = 'selected_language';

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  /// Returns saved language code, null if never selected
  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// True only if user has explicitly selected a language before
  static Future<bool> isLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    return saved != null && saved.isNotEmpty;
  }
}
