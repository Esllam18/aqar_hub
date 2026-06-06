// lib/core/location/governorates/sohag.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode sohagGovernorate = EgyptLocationNode(
  slug: 'sohag',
  enName: 'Sohag',
  arName: 'سوهاج',
  aliases: ['sohag', 'سوهاج'],
  children: [
    EgyptLocationNode(slug: 'sohag_city', enName: 'Sohag City', arName: 'مدينة سوهاج', aliases: ['sohag city', 'مدينة سوهاج', 'sohag-city']),
    EgyptLocationNode(slug: 'akhmim', enName: 'Akhmim', arName: 'أخميم', aliases: ['akhmim', 'أخميم']),
    EgyptLocationNode(slug: 'girga', enName: 'Girga', arName: 'جرجا', aliases: ['girga', 'جرجا']),
    EgyptLocationNode(slug: 'tahta', enName: 'Tahta', arName: 'طهطا', aliases: ['tahta', 'طهطا']),
    EgyptLocationNode(slug: 'balyana', enName: 'Balyana', arName: 'البلينا', aliases: ['balyana', 'البلينا']),
    EgyptLocationNode(slug: 'tema', enName: 'Tema', arName: 'تيما', aliases: ['tema', 'تيما']),
    EgyptLocationNode(slug: 'el_maragha', enName: 'El Maragha', arName: 'المراغة', aliases: ['el maragha', 'المراغة', 'el-maragha']),
  ],
);
