// lib/core/location/governorates/asyut.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode asyutGovernorate = EgyptLocationNode(
  slug: 'asyut',
  enName: 'Asyut',
  arName: 'أسيوط',
  aliases: ['asyut', 'asyout', 'أسيوط', 'اسيوط', 'assiut'],
  children: [
    EgyptLocationNode(
      slug: 'asyut-city',
      enName: 'Asyut City',
      arName: 'مدينة أسيوط',
      aliases: ['asyut city', 'مدينة أسيوط'],
    ),
    EgyptLocationNode(
      slug: 'dayrout',
      enName: 'Dayrout',
      arName: 'ديروط',
      aliases: ['dayrout', 'ديروط'],
    ),
    EgyptLocationNode(
      slug: 'manfalut',
      enName: 'Manfalut',
      arName: 'منفلوط',
      aliases: ['manfalut', 'منفلوط'],
    ),
    EgyptLocationNode(
      slug: 'qusiya',
      enName: 'Qusiya',
      arName: 'القوصية',
      aliases: ['qusiya', 'القوصية'],
    ),
    EgyptLocationNode(
      slug: 'abnoub',
      enName: 'Abnoub',
      arName: 'أبنوب',
      aliases: ['abnoub', 'أبنوب'],
    ),
    EgyptLocationNode(
      slug: 'abu-tig',
      enName: 'Abu Tig',
      arName: 'أبو تيج',
      aliases: ['abu tig', 'أبو تيج'],
    ),
    EgyptLocationNode(
      slug: 'sahel-salim',
      enName: 'Sahel Salim',
      arName: 'ساحل سليم',
      aliases: ['sahel salim', 'ساحل سليم'],
    ),
  ],
);
