// lib/core/location/egypt_locations.dart
// Complete Egypt location tree — all 27 governorates
// Slugs match DB governorate_slug column EXACTLY (underscores, not hyphens)

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

  static final Map<String, EgyptLocationNode> _bySlug = {
    for (final g in governorates) g.slug: g,
  };

  static final Map<String, EgyptLocationNode> _cityByKey = {
    for (final g in governorates)
      for (final c in g.children) '${g.slug}/${c.slug}': c,
  };

  static EgyptLocationNode? findGovernorate(String? slug) =>
      slug == null ? null : _bySlug[slug];

  static EgyptLocationNode? findCity({
    required String? governorateSlug,
    required String? citySlug,
  }) {
    if (governorateSlug == null || citySlug == null) return null;
    return _cityByKey['$governorateSlug/$citySlug'];
  }

  static List<EgyptLocationNode> citiesForGovernorate(String? slug) =>
      findGovernorate(slug)?.children ?? const [];
}
