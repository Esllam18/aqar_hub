// lib/core/location/governorates/minya.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode minyaGovernorate = EgyptLocationNode(
  slug: 'minya',
  enName: 'Minya',
  arName: 'المنيا',
  aliases: ['minya', 'المنيا', 'منيا', 'el minya'],
  children: [
    EgyptLocationNode(
      slug: 'minya-city',
      enName: 'Minya City',
      arName: 'مدينة المنيا',
      aliases: ['minya city', 'مدينة المنيا'],
    ),
    EgyptLocationNode(
      slug: 'mallawi',
      enName: 'Mallawi',
      arName: 'ملوي',
      aliases: ['mallawi', 'ملوي'],
    ),
    EgyptLocationNode(
      slug: 'samalut',
      enName: 'Samalut',
      arName: 'سمالوط',
      aliases: ['samalut', 'سمالوط'],
    ),
    EgyptLocationNode(
      slug: 'beni-mazar',
      enName: 'Beni Mazar',
      arName: 'بني مزار',
      aliases: ['beni mazar', 'بني مزار'],
    ),
    EgyptLocationNode(
      slug: 'maghagha',
      enName: 'Maghagha',
      arName: 'مغاغة',
      aliases: ['maghagha', 'مغاغة'],
    ),
    EgyptLocationNode(
      slug: 'matai',
      enName: 'Matai',
      arName: 'مطاي',
      aliases: ['matai', 'مطاي'],
    ),
    EgyptLocationNode(
      slug: 'abu-qurqas',
      enName: 'Abu Qurqas',
      arName: 'أبو قرقاص',
      aliases: ['abu qurqas', 'أبو قرقاص'],
    ),
  ],
);
