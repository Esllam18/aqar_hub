// lib/core/location/data/egypt_locations.dart
//
// Complete Egypt location tree — all 27 governorates.
//
// IMPORTANT — DB storage contract:
//   • governorate_slug  →  EgyptLocationNode.slug  (e.g. 'cairo')
//   • city_slug         →  child.slug              (e.g. 'nasr-city')
//   • area_slug         →  grandchild.slug         (e.g. 'zahraa-nasr')
//   • city              →  same as city_slug (legacy column, keep in sync)
//   • location_path     →  '{gov}/{city}' or '{gov}/{city}/{area}'
//
// NEVER store arName / enName in any of the above columns.

import 'package:aqar_hub/core/location/models/location_node.dart';

import 'governorates/alexandria.dart';
import 'governorates/cairo.dart';
import 'governorates/giza.dart';
import 'governorates/monufia.dart';
import 'governorates/dakahlia.dart';
import 'governorates/gharbia.dart';
import 'governorates/qalyubia.dart';
import 'governorates/beheira.dart';
import 'governorates/sharkia.dart';
import 'governorates/beni_suef.dart';
import 'governorates/minya.dart';
import 'governorates/asyut.dart';
import 'governorates/sohag.dart';
import 'governorates/qena.dart';
import 'governorates/luxor.dart';
import 'governorates/aswan.dart';
import 'governorates/red_sea.dart';
import 'governorates/south_sinai.dart';
import 'governorates/north_sinai.dart';
import 'governorates/fayoum.dart';
import 'governorates/damietta.dart';
import 'governorates/ismailia.dart';
import 'governorates/suez.dart';
import 'governorates/port_said.dart';
import 'governorates/kafr_el_sheikh.dart';
import 'governorates/matrouh.dart';
import 'governorates/new_valley.dart';

abstract final class EgyptLocations {
  // ── Master list ────────────────────────────────────────────────────────────

  static const List<EgyptLocationNode> governorates = [
    alexandriaGovernorate,
    aswanGovernorate,
    asyutGovernorate,
    beheiraGovernorate,
    beniSuefGovernorate,
    cairoGovernorate,
    dakahliaGovernorate,
    damiettaGovernorate,
    fayoumGovernorate,
    gharbiaGovernorate,
    gizaGovernorate,
    ismailiaGovernorate,
    kafrElSheikhGovernorate,
    luxorGovernorate,
    matrouhGovernorate,
    minyaGovernorate,
    monufiaGovernorate,
    newValleyGovernorate,
    northSinaiGovernorate,
    portSaidGovernorate,
    qalyubiaGovernorate,
    qenaGovernorate,
    redSeaGovernorate,
    sharkiaGovernorate,
    sohagGovernorate,
    southSinaiGovernorate,
    suezGovernorate,
  ];

  // ── Lookup maps (built once, lazily) ──────────────────────────────────────

  static final Map<String, EgyptLocationNode> _bySlug = {
    for (final g in governorates) g.slug: g,
  };

  static final Map<String, EgyptLocationNode> _cityByKey = {
    for (final g in governorates)
      for (final c in g.children) '${g.slug}/${c.slug}': c,
  };

  static final Map<String, EgyptLocationNode> _areaByKey = {
    for (final g in governorates)
      for (final c in g.children)
        for (final a in c.children) '${g.slug}/${c.slug}/${a.slug}': a,
  };

  // ── Finders ───────────────────────────────────────────────────────────────

  /// Find a governorate by its slug.
  static EgyptLocationNode? findGovernorate(String? slug) =>
      slug == null ? null : _bySlug[slug];

  /// Find a city by [governorateSlug] + [citySlug].
  static EgyptLocationNode? findCity({
    required String? governorateSlug,
    required String? citySlug,
  }) {
    if (governorateSlug == null || citySlug == null) return null;
    return _cityByKey['$governorateSlug/$citySlug'];
  }

  /// Find an area by [governorateSlug] + [citySlug] + [areaSlug].
  static EgyptLocationNode? findArea({
    required String? governorateSlug,
    required String? citySlug,
    required String? areaSlug,
  }) {
    if (governorateSlug == null || citySlug == null || areaSlug == null) {
      return null;
    }
    return _areaByKey['$governorateSlug/$citySlug/$areaSlug'];
  }

  /// Returns cities for a given governorate slug.
  static List<EgyptLocationNode> citiesForGovernorate(String? slug) =>
      findGovernorate(slug)?.children ?? const [];

  /// Returns areas for a given governorate + city slug pair.
  static List<EgyptLocationNode> areasForCity({
    required String? governorateSlug,
    required String? citySlug,
  }) =>
      findCity(
        governorateSlug: governorateSlug,
        citySlug: citySlug,
      )?.children ??
      const [];

  // ── Location-path helpers ─────────────────────────────────────────────────

  /// Builds the canonical `location_path` stored in the DB.
  /// Format: `{govSlug}` | `{govSlug}/{citySlug}` | `{govSlug}/{citySlug}/{areaSlug}`
  static String buildLocationPath({
    required String governorateSlug,
    String? citySlug,
    String? areaSlug,
  }) {
    var path = governorateSlug;
    if (citySlug != null && citySlug.isNotEmpty) {
      path = '$path/$citySlug';
      if (areaSlug != null && areaSlug.isNotEmpty) {
        path = '$path/$areaSlug';
      }
    }
    return path;
  }

  /// Parses a `location_path` string back into its slug components.
  static ({String gov, String? city, String? area}) parseLocationPath(
    String? path,
  ) {
    if (path == null || path.isEmpty) return (gov: '', city: null, area: null);
    final parts = path.split('/');
    return (
      gov: parts[0],
      city: parts.length > 1 ? parts[1] : null,
      area: parts.length > 2 ? parts[2] : null,
    );
  }
}
