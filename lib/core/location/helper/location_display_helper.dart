// lib/core/location/helper/location_display_helper.dart
//
// A single entry-point used by EVERY widget that needs to display a
// location string from a property model.
//
// CONTRACT:
//   • Input  : governorateSlug, citySlug, areaSlug  (from DB — always slugs)
//   • Output : localised human-readable string that changes with app language
//
// NEVER pass model.city directly to UI — that column is a legacy fallback
// and may contain a slug.  Always use locationLabel() or governorateLabel().

import 'package:flutter/widgets.dart';
import 'package:aqar_hub/core/location/data/egypt_locations.dart';

abstract final class LocationDisplayHelper {
  // ── Primary method: full label for display ────────────────────────────────

  /// Returns a human-readable location label for the given slugs.
  ///
  /// Examples (AR locale):
  ///   governorateSlug='cairo', citySlug='nasr_city'  → 'مدينة نصر، القاهرة'
  ///   governorateSlug='beni_suef', citySlug=''       → 'بني سويف'
  ///   all empty                                       → ''
  static String locationLabel({
    required BuildContext context,
    required String? governorateSlug,
    required String? citySlug,
    String? areaSlug,
  }) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    return _build(
      governorateSlug: governorateSlug,
      citySlug: citySlug,
      areaSlug: areaSlug,
      lang: lang,
    );
  }

  /// Convenience: governorate name only.
  static String governorateLabel({
    required BuildContext context,
    required String? governorateSlug,
  }) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final node = EgyptLocations.findGovernorate(governorateSlug);
    if (node == null) return '';
    return node.labelForLang(lang);
  }

  // ── Internal builder ──────────────────────────────────────────────────────

  static String _build({
    required String? governorateSlug,
    required String? citySlug,
    String? areaSlug,
    required String lang,
  }) {
    final parts = <String>[];

    // City / area first (more specific → less specific order)
    if (areaSlug != null && areaSlug.isNotEmpty) {
      final node = EgyptLocations.findArea(
        governorateSlug: governorateSlug,
        citySlug: citySlug,
        areaSlug: areaSlug,
      );
      if (node != null) parts.add(node.labelForLang(lang));
    }

    if (citySlug != null && citySlug.isNotEmpty) {
      final node = EgyptLocations.findCity(
        governorateSlug: governorateSlug,
        citySlug: citySlug,
      );
      if (node != null) parts.add(node.labelForLang(lang));
    }

    if (governorateSlug != null && governorateSlug.isNotEmpty) {
      final node = EgyptLocations.findGovernorate(governorateSlug);
      if (node != null) parts.add(node.labelForLang(lang));
    }

    return parts.join('، ');
  }

  // ── Full label with optional address prefix ───────────────────────────────

  /// Returns "address, city, governorate" where address is free-text and
  /// city/governorate are resolved from slugs.
  static String fullLabel({
    required BuildContext context,
    required String? address,
    required String? governorateSlug,
    required String? citySlug,
    String? areaSlug,
  }) {
    final loc = locationLabel(
      context: context,
      governorateSlug: governorateSlug,
      citySlug: citySlug,
      areaSlug: areaSlug,
    );

    final parts = <String>[
      if (address != null && address.trim().isNotEmpty) address.trim(),
      if (loc.isNotEmpty) loc,
    ];
    return parts.join('، ');
  }
}
