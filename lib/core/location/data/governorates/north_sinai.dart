// lib/core/location/governorates/north_sinai.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode northSinaiGovernorate = EgyptLocationNode(
  slug: 'north_sinai',
  enName: 'North Sinai',
  arName: 'شمال سيناء',
  aliases: ['north sinai', 'شمال سيناء', 'north_sinai'],
  children: [
    EgyptLocationNode(slug: 'arish', enName: 'El Arish', arName: 'العريش', aliases: ['arish', 'العريش', 'el arish']),
    EgyptLocationNode(slug: 'rafah', enName: 'Rafah', arName: 'رفح', aliases: ['rafah', 'رفح']),
    EgyptLocationNode(slug: 'sheikh-zuweid', enName: 'Sheikh Zuweid', arName: 'الشيخ زويد', aliases: ['sheikh zuweid', 'الشيخ زويد']),
    EgyptLocationNode(slug: 'bir-el-abed', enName: 'Bir El Abed', arName: 'بئر العبد', aliases: ['bir el abed', 'بئر العبد']),
    EgyptLocationNode(slug: 'hasna', enName: 'Hasna', arName: 'حسنة', aliases: ['hasna', 'حسنة']),
  ],
);
