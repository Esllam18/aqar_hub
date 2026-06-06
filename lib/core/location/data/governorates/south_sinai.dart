// lib/core/location/governorates/south_sinai.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode southSinaiGovernorate = EgyptLocationNode(
  slug: 'south_sinai',
  enName: 'South Sinai',
  arName: 'جنوب سيناء',
  aliases: ['south sinai', 'جنوب سيناء'],
  children: [
    EgyptLocationNode(slug: 'sharm_elsheikh', enName: 'Sharm El Sheikh', arName: 'شرم الشيخ', aliases: ['sharm el sheikh', 'شرم الشيخ', 'شرم', 'sharm', 'sharm-elsheikh']),
    EgyptLocationNode(slug: 'dahab', enName: 'Dahab', arName: 'دهب', aliases: ['dahab', 'دهب']),
    EgyptLocationNode(slug: 'nuweiba', enName: 'Nuweiba', arName: 'نويبع', aliases: ['nuweiba', 'نويبع']),
    EgyptLocationNode(slug: 'taba', enName: 'Taba', arName: 'طابا', aliases: ['taba', 'طابا']),
    EgyptLocationNode(slug: 'ras_sudr', enName: 'Ras Sudr', arName: 'رأس سدر', aliases: ['ras sudr', 'رأس سدر', 'ras-sudr']),
    EgyptLocationNode(slug: 'saint_catherine', enName: 'Saint Catherine', arName: 'سانت كاترين', aliases: ['saint catherine', 'سانت كاترين', 'saint-catherine']),
  ],
);
