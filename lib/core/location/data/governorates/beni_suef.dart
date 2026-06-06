// lib/core/location/governorates/beni_suef.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode beniSuefGovernorate = EgyptLocationNode(
  slug: 'beni_suef',
  enName: 'Beni Suef',
  arName: 'بني سويف',
  aliases: ['beni suef', 'bani suef', 'بني سويف', 'بنى سويف', 'beni_suef', 'beni-suef'],
  children: [
    EgyptLocationNode(
      slug: 'beni_suef_city',
      enName: 'Beni Suef City',
      arName: 'مدينة بني سويف',
      aliases: ['beni suef city', 'مدينة بني سويف', 'وسط بني سويف', 'beni-suef-city'],
    ),
    EgyptLocationNode(
      slug: 'hay_awal',
      enName: 'First District',
      arName: 'الحي الأول',
      aliases: ['hay awal', 'الحي الأول', 'الحى الاول', 'first district', 'hay-awal'],
    ),
    EgyptLocationNode(
      slug: 'nile_corniche',
      enName: 'Nile Corniche',
      arName: 'كورنيش النيل',
      aliases: ['nile corniche', 'كورنيش النيل', 'الكورنيش', 'nile-corniche'],
    ),
    EgyptLocationNode(
      slug: 'nahda',
      enName: 'El Nahda',
      arName: 'حي النهضة',
      aliases: ['nahda', 'النهضة', 'حي النهضة'],
    ),
    EgyptLocationNode(
      slug: 'beba',
      enName: 'Beba',
      arName: 'ببا',
      aliases: ['beba', 'ببا'],
    ),
    EgyptLocationNode(
      slug: 'ihnasya',
      enName: 'Ihnasya',
      arName: 'إهناسيا',
      aliases: ['ihnasya', 'إهناسيا'],
    ),
    EgyptLocationNode(
      slug: 'nasser_city',
      enName: 'Nasser City',
      arName: 'حي ناصر',
      aliases: ['nasser city', 'حي ناصر', 'ناصر', 'nasser-city'],
    ),
    EgyptLocationNode(
      slug: 'shabaab',
      enName: 'Youth District',
      arName: 'حي الشباب',
      aliases: ['shabaab', 'حي الشباب', 'الشباب'],
    ),
    EgyptLocationNode(
      slug: 'wahda',
      enName: 'El Wahda',
      arName: 'حي الوحدة',
      aliases: ['wahda', 'الوحدة', 'حي الوحدة'],
    ),
  ],
);
