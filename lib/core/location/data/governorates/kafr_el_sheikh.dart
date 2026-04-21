// lib/core/location/governorates/kafr_el_sheikh.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode kafrElSheikhGovernorate = EgyptLocationNode(
  slug: 'kafr_el_sheikh',
  enName: 'Kafr El Sheikh',
  arName: 'كفر الشيخ',
  aliases: ['kafr el sheikh', 'kafr el-sheikh', 'كفر الشيخ', 'kafr_el_sheikh'],
  children: [
    EgyptLocationNode(slug: 'kafr-city', enName: 'Kafr El Sheikh City', arName: 'مدينة كفر الشيخ', aliases: ['kafr city', 'مدينة كفر الشيخ']),
    EgyptLocationNode(slug: 'desouk', enName: 'Desouk', arName: 'دسوق', aliases: ['desouk', 'دسوق']),
    EgyptLocationNode(slug: 'fuwwah', enName: 'Fuwwah', arName: 'فوه', aliases: ['fuwwah', 'فوه']),
    EgyptLocationNode(slug: 'baltim', enName: 'Baltim', arName: 'بلطيم', aliases: ['baltim', 'بلطيم']),
    EgyptLocationNode(slug: 'sidi-salim', enName: 'Sidi Salim', arName: 'سيدي سالم', aliases: ['sidi salim', 'سيدي سالم']),
  ],
);
