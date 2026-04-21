// lib/core/helpers/app_prefs.dart
//
// Unified SharedPreferences layer for AqarHub.
//
// DESIGN:
//   • The class supports BOTH usage patterns:
//       (a) async  — original style used everywhere in the project
//       (b) sync   — fast reads after init(), used for caching features
//   • Call `await AppPrefs.init()` once in main() before runApp().
//     All callers that used the old async pattern continue to work unchanged
//     because every write method also calls SharedPreferences.getInstance()
//     as a fallback, so nothing breaks if init() is not yet called.
//   • Never import SharedPreferences directly elsewhere.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppPrefs {
  // ── Singleton instance (populated by init) ────────────────────────────────
  static SharedPreferences? _prefs;

  /// Call once in main() before runApp() for fast synchronous reads.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Internal helper: returns the cached instance or awaits a fresh one.
  static Future<SharedPreferences> _get() async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ── Keys ──────────────────────────────────────────────────────────────────

  static const _kUserId = 'user_id';
  static const _kUserRole = 'user_role';
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kNeedsProfile = 'needs_profile';
  static const _kUserName = 'user_name';
  static const _kUserEmail = 'user_email';
  static const _kUserPhone = 'user_phone';
  static const _kUserCity = 'user_city';
  static const _kUserAvatar = 'user_avatar';
  static const _kProfileJson = 'cached_profile_json';
  static const _kFcmToken = 'fcm_token';
  static const _kAppLang = 'app_language';
  static const _kPropertiesCache = 'cached_properties_json';
  static const _kPropsCacheTs = 'cached_properties_timestamp';
  static const _kFavIds = 'cached_fav_ids';
  static const _kOwnerPropsCache = 'cached_owner_props_json';
  static const _kOwnerPropsCacheTs = 'cached_owner_props_timestamp';
  static const _kConversationsCache = 'cached_conversations_json';

  // Cache TTL: property list expires after 5 minutes
  static const _propsCacheTtlMs = 5 * 60 * 1000;

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<void> saveUserId(String id) async {
    final p = await _get();
    await p.setString(_kUserId, id);
  }

  static Future<void> saveUserRole(String role) async {
    final p = await _get();
    await p.setString(_kUserRole, role);
  }

  static Future<void> setLoggedIn(bool value) async {
    final p = await _get();
    await p.setBool(_kIsLoggedIn, value);
  }

  static Future<void> setNeedsProfile(bool value) async {
    final p = await _get();
    await p.setBool(_kNeedsProfile, value);
  }

  // Async reads (original API — always works, even before init())
  static Future<String?> getUserId() async {
    final p = await _get();
    return p.getString(_kUserId);
  }

  static Future<String?> getUserRole() async {
    final p = await _get();
    return p.getString(_kUserRole);
  }

  static Future<bool> isLoggedIn() async {
    final p = await _get();
    return p.getBool(_kIsLoggedIn) ?? false;
  }

  static Future<bool> needsProfile() async {
    final p = await _get();
    return p.getBool(_kNeedsProfile) ?? false;
  }

  // Sync reads (fast — only valid after init() has been awaited)
  static String get userIdSync => _prefs?.getString(_kUserId) ?? '';
  static String get userRoleSync => _prefs?.getString(_kUserRole) ?? '';
  static bool get isLoggedInSync => _prefs?.getBool(_kIsLoggedIn) ?? false;
  static bool get needsProfileSync => _prefs?.getBool(_kNeedsProfile) ?? false;

  // ── User quick-access fields ──────────────────────────────────────────────
  // Written once after login / profile-completion so the app never needs
  // a network call just to show the user's own name or avatar.

  static Future<void> saveUserName(String name) async {
    final p = await _get();
    await p.setString(_kUserName, name);
  }

  static Future<void> saveUserEmail(String email) async {
    final p = await _get();
    await p.setString(_kUserEmail, email);
  }

  static Future<void> saveUserPhone(String phone) async {
    final p = await _get();
    await p.setString(_kUserPhone, phone);
  }

  static Future<void> saveUserCity(String city) async {
    final p = await _get();
    await p.setString(_kUserCity, city);
  }

  static Future<void> saveUserAvatar(String url) async {
    final p = await _get();
    await p.setString(_kUserAvatar, url);
  }

  static String get userName => _prefs?.getString(_kUserName) ?? '';
  static String get userEmail => _prefs?.getString(_kUserEmail) ?? '';
  static String get userPhone => _prefs?.getString(_kUserPhone) ?? '';
  static String get userCity => _prefs?.getString(_kUserCity) ?? '';
  static String get userAvatar => _prefs?.getString(_kUserAvatar) ?? '';

  // ── Full profile cache ────────────────────────────────────────────────────
  // Stores the full ProfileModel as JSON so ProfileCubit can restore its last
  // known state without a network round-trip on every app start.

  static Future<void> cacheProfile(Map<String, dynamic> profileMap) async {
    final p = await _get();
    await p.setString(_kProfileJson, jsonEncode(profileMap));
    // Mirror individual quick-access fields
    final first = (profileMap['first_name'] as String? ?? '').trim();
    final last = (profileMap['last_name'] as String? ?? '').trim();
    final name = '$first $last'.trim();
    if (name.isNotEmpty) await saveUserName(name);
    if ((profileMap['email'] ?? '') != '') {
      await saveUserEmail(profileMap['email'] as String);
    }
    if ((profileMap['phone_number'] ?? '') != '') {
      await saveUserPhone(profileMap['phone_number'] as String);
    }
    if ((profileMap['city'] ?? '') != '') {
      await saveUserCity(profileMap['city'] as String);
    }
    if ((profileMap['profile_image_url'] ?? '') != '') {
      await saveUserAvatar(profileMap['profile_image_url'] as String);
    }
  }

  static Map<String, dynamic>? getCachedProfile() {
    final raw = _prefs?.getString(_kProfileJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearProfile() async {
    final p = await _get();
    await p.remove(_kProfileJson);
    await p.remove(_kUserName);
    await p.remove(_kUserEmail);
    await p.remove(_kUserPhone);
    await p.remove(_kUserCity);
    await p.remove(_kUserAvatar);
  }

  // ── FCM token ─────────────────────────────────────────────────────────────

  static Future<void> saveFcmToken(String token) async {
    final p = await _get();
    await p.setString(_kFcmToken, token);
  }

  static String? get fcmToken => _prefs?.getString(_kFcmToken);

  // ── Language ──────────────────────────────────────────────────────────────
  // Language is intentionally NOT cleared on logout.

  static Future<void> saveLanguage(String langCode) async {
    final p = await _get();
    await p.setString(_kAppLang, langCode);
  }

  static String get language => _prefs?.getString(_kAppLang) ?? 'ar';

  // ── Property list cache (home feed — first page only) ─────────────────────
  // TTL: 5 minutes.  Only the default (no-filter) page is cached.

  static Future<void> cacheProperties(List<Map<String, dynamic>> list) async {
    final p = await _get();
    await p.setString(_kPropertiesCache, jsonEncode(list));
    await p.setInt(_kPropsCacheTs, DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns the cached list if it hasn't expired, otherwise null.
  static List<Map<String, dynamic>>? getCachedProperties() {
    final p = _prefs;
    if (p == null) return null;
    final ts = p.getInt(_kPropsCacheTs) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age > _propsCacheTtlMs) return null; // stale
    final raw = p.getString(_kPropertiesCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearPropertiesCache() async {
    final p = await _get();
    await p.remove(_kPropertiesCache);
    await p.remove(_kPropsCacheTs);
  }

  // ── Favorites IDs cache ───────────────────────────────────────────────────
  // Lightweight cache of favourite property-IDs so heart icons render instantly.

  static Future<void> cacheFavIds(List<String> ids) async {
    final p = await _get();
    await p.setStringList(_kFavIds, ids);
  }

  static List<String> getCachedFavIds() =>
      _prefs?.getStringList(_kFavIds) ?? [];

  static Future<void> clearFavIds() async {
    final p = await _get();
    await p.remove(_kFavIds);
    await p.remove(_kOwnerPropsCache);
    await p.remove(_kOwnerPropsCacheTs);
    await p.remove(_kConversationsCache);
  }

  // ── Full clear (logout) ───────────────────────────────────────────────────
  // Language (_kAppLang) is intentionally kept so the user's language
  // preference survives logout.

  // ── Owner properties cache (5-min TTL) ──────────────────────────────────

  static const _ownerPropsTtlMs = 5 * 60 * 1000;

  static Future<void> cacheOwnerProperties(
    List<Map<String, dynamic>> list,
  ) async {
    final p = await _get();
    await p.setString(_kOwnerPropsCache, jsonEncode(list));
    await p.setInt(_kOwnerPropsCacheTs, DateTime.now().millisecondsSinceEpoch);
    _prefs = p;
  }

  /// Returns cached list if within TTL, otherwise null.
  static List<Map<String, dynamic>>? getCachedOwnerProperties() {
    final p = _prefs;
    if (p == null) return null;
    final ts = p.getInt(_kOwnerPropsCacheTs) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - ts > _ownerPropsTtlMs) {
      return null;
    }
    final raw = p.getString(_kOwnerPropsCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearOwnerPropertiesCache() async {
    final p = await _get();
    await p.remove(_kOwnerPropsCache);
    await p.remove(_kOwnerPropsCacheTs);
    _prefs = p;
  }

  // ── Conversations cache ───────────────────────────────────────────────────

  static Future<void> cacheConversations(
    List<Map<String, dynamic>> list,
  ) async {
    final p = await _get();
    await p.setString(_kConversationsCache, jsonEncode(list));
    _prefs = p;
  }

  static List<Map<String, dynamic>>? getCachedConversations() {
    final raw = _prefs?.getString(_kConversationsCache);
    if (raw == null || raw.isEmpty) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearConversationsCache() async {
    final p = await _get();
    await p.remove(_kConversationsCache);
    _prefs = p;
  }

  static Future<void> clear() async {
    final p = await _get();
    await p.remove(_kUserId);
    await p.remove(_kUserRole);
    await p.remove(_kIsLoggedIn);
    await p.remove(_kNeedsProfile);
    await p.remove(_kUserName);
    await p.remove(_kUserEmail);
    await p.remove(_kUserPhone);
    await p.remove(_kUserCity);
    await p.remove(_kUserAvatar);
    await p.remove(_kProfileJson);
    await p.remove(_kFcmToken);
    await p.remove(_kPropertiesCache);
    await p.remove(_kPropsCacheTs);
    await p.remove(_kFavIds);
    // _kAppLang is intentionally NOT removed
  }
}
