// lib/core/location/helper/egypt_location_helper.dart
//
// ┌──────────────────────────────────────────────────────────────────────────┐
// │  EgyptLocationHelper                                                     │
// │                                                                          │
// │  Purpose:                                                                │
// │    1. Resolve a raw Arabic or English location string stored in the DB  │
// │       back to the canonical slug (used by the data-migration script).   │
// │    2. Provide safe display helpers that accept EITHER a slug OR a        │
// │       legacy display name and always return the correct localised name. │
// │    3. Guarantee that the UI layer never renders a raw slug to the user. │
// └──────────────────────────────────────────────────────────────────────────┘

import 'package:aqar_hub/core/location/data/egypt_locations.dart';
import 'package:aqar_hub/core/location/models/location_node.dart';

abstract final class EgyptLocationHelper {
  // ── Slug resolution ────────────────────────────────────────────────────────

  /// Converts any raw governorate value (slug, Arabic name, English name,
  /// alias) to the canonical slug.
  ///
  /// • If [raw] is already a valid slug → returned unchanged.
  /// • If [raw] matches a node via fuzzy alias matching → canonical slug returned.
  /// • Otherwise → [raw] returned as-is so callers can flag unresolved rows.
  static String resolveGovernorateSlug(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';

    final trimmed = raw.trim();

    // Already a valid slug?
    if (EgyptLocations.findGovernorate(trimmed) != null) return trimmed;

    final normalised = EgyptLocationNode.normalize(trimmed);

    for (final gov in EgyptLocations.governorates) {
      if (gov.matches(normalised)) return gov.slug;
    }

    return trimmed;
  }

  /// Converts any raw city value to its canonical slug within [governorateSlug].
  ///
  /// Falls back to the raw value if no match is found.
  static String resolveCitySlug({
    required String governorateSlug,
    required String? raw,
  }) {
    if (raw == null || raw.trim().isEmpty) return '';

    final trimmed = raw.trim();
    final cities = EgyptLocations.citiesForGovernorate(governorateSlug);
    if (cities.isEmpty) return '';

    // Already a valid slug?
    if (EgyptLocations.findCity(
          governorateSlug: governorateSlug,
          citySlug: trimmed,
        ) !=
        null) {
      return trimmed;
    }

    final normalised = EgyptLocationNode.normalize(trimmed);
    for (final city in cities) {
      if (city.matches(normalised)) return city.slug;
    }

    return trimmed;
  }

  /// Converts any raw area value to its canonical slug.
  ///
  /// Falls back to the raw value if no match is found.
  static String resolveAreaSlug({
    required String governorateSlug,
    required String citySlug,
    required String? raw,
  }) {
    if (raw == null || raw.trim().isEmpty) return '';

    final trimmed = raw.trim();
    final areas = EgyptLocations.areasForCity(
      governorateSlug: governorateSlug,
      citySlug: citySlug,
    );
    if (areas.isEmpty) return '';

    // Already a valid slug?
    if (EgyptLocations.findArea(
          governorateSlug: governorateSlug,
          citySlug: citySlug,
          areaSlug: trimmed,
        ) !=
        null) {
      return trimmed;
    }

    final normalised = EgyptLocationNode.normalize(trimmed);
    for (final area in areas) {
      if (area.matches(normalised)) return area.slug;
    }

    return trimmed;
  }

  // ── Safe display helpers ───────────────────────────────────────────────────
  //
  // These helpers accept EITHER a canonical slug OR a legacy display name
  // (Arabic or English) that may still exist in old DB rows.  They always
  // return the correct localised label for the current [lang].
  //
  // Use these everywhere you need to DISPLAY a location value from the DB.
  // NEVER display the raw slug or raw DB value directly to the user.

  /// Returns the localised governorate name for [slugOrLegacy] in [lang].
  ///
  /// Resolution order:
  ///   1. Try direct slug lookup.
  ///   2. Try fuzzy alias resolution (handles Arabic / English legacy values).
  ///   3. Fall back to [slugOrLegacy] so nothing silently disappears.
  static String governorateName(String? slugOrLegacy, {required String lang}) {
    if (slugOrLegacy == null || slugOrLegacy.trim().isEmpty) return '';

    // Direct slug lookup
    var node = EgyptLocations.findGovernorate(slugOrLegacy.trim());

    // Legacy value — try to resolve it
    if (node == null) {
      final resolved = resolveGovernorateSlug(slugOrLegacy);
      node = EgyptLocations.findGovernorate(resolved);
    }

    if (node == null) return slugOrLegacy.trim();
    return node.labelForLang(lang);
  }

  /// Returns the localised city name for [citySlugOrLegacy] in [lang].
  static String cityName({
    required String? governorateSlug,
    required String? citySlugOrLegacy,
    required String lang,
  }) {
    if (citySlugOrLegacy == null || citySlugOrLegacy.trim().isEmpty) return '';

    // Resolve governorate slug first (it may also be a legacy value)
    final govSlug = resolveGovernorateSlug(governorateSlug);

    // Direct slug lookup
    var node = EgyptLocations.findCity(
      governorateSlug: govSlug,
      citySlug: citySlugOrLegacy.trim(),
    );

    // Legacy value — try to resolve it
    if (node == null) {
      final resolved = resolveCitySlug(
        governorateSlug: govSlug,
        raw: citySlugOrLegacy,
      );
      node = EgyptLocations.findCity(
        governorateSlug: govSlug,
        citySlug: resolved,
      );
    }

    if (node == null) return citySlugOrLegacy.trim();
    return node.labelForLang(lang);
  }

  /// Returns the localised area name for [areaSlugOrLegacy] in [lang].
  static String areaName({
    required String? governorateSlug,
    required String? citySlug,
    required String? areaSlugOrLegacy,
    required String lang,
  }) {
    if (areaSlugOrLegacy == null || areaSlugOrLegacy.trim().isEmpty) return '';

    final govSlug = resolveGovernorateSlug(governorateSlug);
    final cSlug = resolveCitySlug(governorateSlug: govSlug, raw: citySlug);

    var node = EgyptLocations.findArea(
      governorateSlug: govSlug,
      citySlug: cSlug,
      areaSlug: areaSlugOrLegacy.trim(),
    );

    if (node == null) {
      final resolved = resolveAreaSlug(
        governorateSlug: govSlug,
        citySlug: cSlug,
        raw: areaSlugOrLegacy,
      );
      node = EgyptLocations.findArea(
        governorateSlug: govSlug,
        citySlug: cSlug,
        areaSlug: resolved,
      );
    }

    if (node == null) return areaSlugOrLegacy.trim();
    return node.labelForLang(lang);
  }

  /// Builds a human-readable location string (e.g. "القاهرة / مدينة نصر")
  /// from the three DB values, using [lang] for localisation.
  ///
  /// Each parameter may be a slug OR a legacy display name — both are handled.
  static String fullLocationLabel({
    required String? governorateSlug,
    required String? citySlug,
    String? areaSlug,
    required String lang,
  }) {
    final parts = <String>[];

    final gov = governorateName(governorateSlug, lang: lang);
    if (gov.isNotEmpty) parts.add(gov);

    if (citySlug != null && citySlug.isNotEmpty) {
      final city = cityName(
        governorateSlug: governorateSlug,
        citySlugOrLegacy: citySlug,
        lang: lang,
      );
      if (city.isNotEmpty) parts.add(city);
    }

    if (areaSlug != null && areaSlug.isNotEmpty) {
      final area = areaName(
        governorateSlug: governorateSlug,
        citySlug: citySlug,
        areaSlugOrLegacy: areaSlug,
        lang: lang,
      );
      if (area.isNotEmpty) parts.add(area);
    }

    return parts.join(' / ');
  }

  // ── Canonical slug extraction (for reading DB rows into the form) ──────────

  /// Given a value from the DB [governorate_slug] column (which may be a slug,
  /// an Arabic name, or an English name from old rows), returns the canonical
  /// slug to populate the form model.
  static String canonicalGovernorateSlug(String? raw) =>
      resolveGovernorateSlug(raw);

  /// Given a value from the DB [city_slug] (or legacy [city]) column, returns
  /// the canonical city slug to populate the form model.
  static String canonicalCitySlug({
    required String governorateSlug,
    required String? raw,
  }) => resolveCitySlug(governorateSlug: governorateSlug, raw: raw);

  /// Given a value from the DB [area_slug] column, returns the canonical area
  /// slug to populate the form model.
  static String canonicalAreaSlug({
    required String governorateSlug,
    required String citySlug,
    required String? raw,
  }) => resolveAreaSlug(
    governorateSlug: governorateSlug,
    citySlug: citySlug,
    raw: raw,
  );
}
