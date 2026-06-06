// lib/core/location/governorates/qalyubia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode qalyubiaGovernorate = EgyptLocationNode(
  slug: 'qalyubia',
  enName: 'Qalyubia',
  arName: 'القليوبية',
  aliases: ['qalyubia', 'القليوبية', 'القليوبيه', 'qaliobeya'],
  children: [
    EgyptLocationNode(slug: 'banha', enName: 'Banha', arName: 'بنها', aliases: ['banha', 'بنها']),
    EgyptLocationNode(slug: 'shubra_alkheima', enName: 'Shubra Al Khayma', arName: 'شبرا الخيمة', aliases: ['shubra alkheima', 'شبرا الخيمة', 'shubra-alkheima']),
    EgyptLocationNode(slug: 'qalyub', enName: 'Qalyub', arName: 'قليوب', aliases: ['qalyub', 'قليوب']),
    EgyptLocationNode(slug: 'khosous', enName: 'Khosous', arName: 'الخصوص', aliases: ['khosous', 'الخصوص']),
    EgyptLocationNode(slug: 'obour', enName: 'Obour City', arName: 'مدينة العبور', aliases: ['obour city', 'مدينة العبور', 'obour']),
    EgyptLocationNode(slug: 'toukh', enName: 'Toukh', arName: 'طوخ', aliases: ['toukh', 'طوخ']),
    EgyptLocationNode(slug: 'shibin_qanatir', enName: 'Shibin Al Qanatir', arName: 'شبين القناطر', aliases: ['shibin qanatir', 'شبين القناطر', 'shibin-qanatir']),
  ],
);
