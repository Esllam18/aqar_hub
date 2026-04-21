// lib/core/location/governorates/qena.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode qenaGovernorate = EgyptLocationNode(
  slug: 'qena',
  enName: 'Qena',
  arName: 'قنا',
  aliases: ['qena', 'قنا'],
  children: [
    EgyptLocationNode(slug: 'qena-city', enName: 'Qena City', arName: 'مدينة قنا', aliases: ['qena city', 'مدينة قنا']),
    EgyptLocationNode(slug: 'nag-hammadi', enName: 'Nag Hammadi', arName: 'نجع حمادي', aliases: ['nag hammadi', 'نجع حمادي']),
    EgyptLocationNode(slug: 'dishna', enName: 'Dishna', arName: 'دشنا', aliases: ['dishna', 'دشنا']),
    EgyptLocationNode(slug: 'qus', enName: 'Qus', arName: 'قوص', aliases: ['qus', 'قوص']),
    EgyptLocationNode(slug: 'farshout', enName: 'Farshout', arName: 'فرشوط', aliases: ['farshout', 'فرشوط']),
  ],
);
