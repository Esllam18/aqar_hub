// lib/core/location/models/location_node.dart
//
// A single node in the Egypt location tree (governorate, city, or area).
//
// ┌─────────────────────────────────────────────────────────────────┐
// │  CANONICAL VALUE  →  slug  (stored in DB, never changes)       │
// │  DISPLAY VALUE    →  label(context) (AR or EN, never stored)   │
// └─────────────────────────────────────────────────────────────────┘

import 'package:flutter/widgets.dart';

class EgyptLocationNode {
  /// Stable, language-independent identifier stored in the database.
  /// Example: 'cairo', 'nasr-city', 'beni_suef'
  final String slug;

  /// English display name — shown when locale is non-Arabic.
  final String enName;

  /// Arabic display name — shown when locale is 'ar'.
  final String arName;

  /// Alternative spellings / transliterations used for fuzzy search/migration.
  final List<String> aliases;

  /// Sub-locations (cities inside a governorate, areas inside a city).
  final List<EgyptLocationNode> children;

  const EgyptLocationNode({
    required this.slug,
    required this.enName,
    required this.arName,
    this.aliases = const [],
    this.children = const [],
  });

  // ── Display ────────────────────────────────────────────────────────────────

  /// Returns the localised name based on the widget tree's current locale.
  /// NEVER store this value in the database — use [slug] instead.
  String label(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    return lang == 'ar' ? arName : enName;
  }

  /// Returns the localised name without a BuildContext (pass the language code
  /// directly).  Useful in BLoC / repository layers that have no context.
  String labelForLang(String languageCode) =>
      languageCode == 'ar' ? arName : enName;

  // ── Slug validation ────────────────────────────────────────────────────────

  /// Returns true when [value] looks like a slug (only lowercase ASCII,
  /// digits, hyphens, and underscores).  Used by the display layer to decide
  /// whether a stored value needs to be resolved through the tree or can be
  /// shown as-is.
  static bool isSlug(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return RegExp(r'^[a-z0-9_-]+$').hasMatch(value.trim());
  }

  // ── Fuzzy matching for migration ──────────────────────────────────────────

  /// Returns true if [rawValue] (already normalised) matches this node.
  /// Used by [EgyptLocationHelper.resolveSlug] to convert legacy AR/EN names
  /// stored in the database back to the canonical slug.
  bool matches(String normalizedText) {
    final pool = <String>{slug, enName, arName, ...aliases};
    for (final item in pool) {
      if (_normalize(item).isEmpty) continue;
      if (normalizedText.contains(_normalize(item)) ||
          _normalize(item).contains(normalizedText)) {
        return true;
      }
    }
    return false;
  }

  // ── Internal normalisation ─────────────────────────────────────────────────

  static String _normalize(String value) {
    var s = value.toLowerCase().trim();

    const replacements = {
      'أ': 'ا',
      'إ': 'ا',
      'آ': 'ا',
      'ة': 'ه',
      'ى': 'ي',
      'ؤ': 'و',
      'ئ': 'ي',
    };

    replacements.forEach((from, to) {
      s = s.replaceAll(from, to);
    });

    s = s.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF\s-]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  /// Normalise a raw string for external callers (e.g. [EgyptLocationHelper]).
  static String normalize(String value) => _normalize(value);
}
