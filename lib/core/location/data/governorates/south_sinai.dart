// lib/core/location/governorates/south_sinai.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode southSinaiGovernorate = EgyptLocationNode(
  slug: 'south_sinai',
  enName: 'South Sinai',
  arName: 'جنوب سيناء',
  aliases: ['south sinai', 'جنوب سيناء', 'south_sinai'],
  children: [
    EgyptLocationNode(slug: 'sharm-elsheikh', enName: 'Sharm El Sheikh', arName: 'شرم الشيخ', aliases: ['sharm el sheikh', 'شرم الشيخ', 'شرم', 'sharm']),
    EgyptLocationNode(slug: 'dahab', enName: 'Dahab', arName: 'دهب', aliases: ['dahab', 'دهب']),
    EgyptLocationNode(slug: 'nuweiba', enName: 'Nuweiba', arName: 'نويبع', aliases: ['nuweiba', 'نويبع']),
    EgyptLocationNode(slug: 'taba', enName: 'Taba', arName: 'طابا', aliases: ['taba', 'طابا']),
    EgyptLocationNode(slug: 'ras-sudr', enName: 'Ras Sudr', arName: 'رأس سدر', aliases: ['ras sudr', 'رأس سدر']),
    EgyptLocationNode(slug: 'saint-catherine', enName: 'Saint Catherine', arName: 'سانت كاترين', aliases: ['saint catherine', 'سانت كاترين']),
  ],
);
