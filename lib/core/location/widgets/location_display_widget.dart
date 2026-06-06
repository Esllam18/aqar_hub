// lib/core/location/widgets/location_display_widget.dart
//
// ┌──────────────────────────────────────────────────────────────────────────┐
// │  LocationDisplayWidget                                                   │
// │                                                                          │
// │  Drop-in widget that accepts raw DB values (slugs OR legacy display      │
// │  names) and renders the correctly localised location string.             │
// │                                                                          │
// │  Usage:                                                                  │
// │    LocationDisplayWidget(                                                │
// │      governorateSlug: property.governorateSlug,                         │
// │      citySlug: property.citySlug,                                       │
// │      areaSlug: property.areaSlug,                                       │
// │      style: Theme.of(context).textTheme.bodyMedium,                     │
// │    )                                                                     │
// └──────────────────────────────────────────────────────────────────────────┘

import 'package:aqar_hub/core/location/helper/egypt_location_helper.dart';
import 'package:flutter/material.dart';

class LocationDisplayWidget extends StatelessWidget {
  /// Raw value from the DB [governorate_slug] column.
  /// May be a slug ('cairo') or a legacy name ('القاهرة' / 'Cairo').
  final String? governorateSlug;

  /// Raw value from the DB [city_slug] column (falls back to [city] column).
  final String? citySlug;

  /// Raw value from the DB [area_slug] column (optional).
  final String? areaSlug;

  /// Separator between parts.  Defaults to ' / '.
  final String separator;

  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const LocationDisplayWidget({
    super.key,
    this.governorateSlug,
    this.citySlug,
    this.areaSlug,
    this.separator = ' / ',
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();

    final label = EgyptLocationHelper.fullLocationLabel(
      governorateSlug: governorateSlug,
      citySlug: citySlug,
      areaSlug: areaSlug,
      lang: lang,
    );

    return Text(label, style: style, maxLines: maxLines, overflow: overflow);
  }
}

/// Lightweight helper extension on [String?] that resolves a raw DB slug /
/// legacy name to a localised label.  Useful in situations where you already
/// have a [BuildContext] and just need a string.
///
/// Example:
///   Text(property.governorateSlug.toGovernorateLabel(context))
extension LocationStringX on String? {
  /// Returns the localised governorate label for [this] slug / legacy value.
  String toGovernorateLabel(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    return EgyptLocationHelper.governorateName(this, lang: lang);
  }

  /// Returns the localised city label for [this] slug / legacy value.
  String toCityLabel(BuildContext context, {required String? governorateSlug}) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    return EgyptLocationHelper.cityName(
      governorateSlug: governorateSlug,
      citySlugOrLegacy: this,
      lang: lang,
    );
  }
}
