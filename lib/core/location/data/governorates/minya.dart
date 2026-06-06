// lib/core/location/governorates/minya.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode minyaGovernorate = EgyptLocationNode(
  slug: 'minya',
  enName: 'Minya',
  arName: 'المنيا',
  aliases: ['minya', 'المنيا', 'menia'],
  children: [
    EgyptLocationNode(slug: 'minya_city', enName: 'Minya City', arName: 'مدينة المنيا', aliases: ['minya city', 'مدينة المنيا', 'minya-city']),
    EgyptLocationNode(slug: 'mallawi', enName: 'Mallawi', arName: 'ملوي', aliases: ['mallawi', 'ملوي']),
    EgyptLocationNode(slug: 'samalut', enName: 'Samalut', arName: 'سمالوط', aliases: ['samalut', 'سمالوط']),
    EgyptLocationNode(slug: 'beni_mazar', enName: 'Beni Mazar', arName: 'بني مزار', aliases: ['beni mazar', 'بني مزار', 'beni-mazar']),
    EgyptLocationNode(slug: 'maghagha', enName: 'Maghagha', arName: 'مغاغة', aliases: ['maghagha', 'مغاغة']),
    EgyptLocationNode(slug: 'matai', enName: 'Matai', arName: 'مطاي', aliases: ['matai', 'مطاي']),
    EgyptLocationNode(slug: 'abu_qurqas', enName: 'Abu Qurqas', arName: 'أبو قرقاص', aliases: ['abu qurqas', 'أبو قرقاص', 'abu-qurqas']),
  ],
);
