// lib/core/location/governorates/qalyubia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode qalyubiaGovernorate = EgyptLocationNode(
  slug: 'qalyubia',
  enName: 'Qalyubia',
  arName: 'القليوبية',
  aliases: ['qalyubia', 'qaliubiya', 'القليوبية', 'قليوبية'],
  children: [
    EgyptLocationNode(
      slug: 'banha',
      enName: 'Banha',
      arName: 'بنها',
      aliases: ['banha', 'بنها'],
    ),
    EgyptLocationNode(
      slug: 'shubra-alkheima',
      enName: 'Shubra Al Khayma',
      arName: 'شبرا الخيمة',
      aliases: ['shubra khayma', 'شبرا الخيمة', 'شبرا الخيمه'],
    ),
    EgyptLocationNode(
      slug: 'qalyub',
      enName: 'Qalyub',
      arName: 'قليوب',
      aliases: ['qalyub', 'قليوب'],
    ),
    EgyptLocationNode(
      slug: 'khosous',
      enName: 'Khosous',
      arName: 'الخصوص',
      aliases: ['khosous', 'الخصوص'],
    ),
    EgyptLocationNode(
      slug: 'obour',
      enName: 'Obour City',
      arName: 'مدينة العبور',
      aliases: ['obour', 'العبور', 'مدينة العبور'],
    ),
    EgyptLocationNode(
      slug: 'toukh',
      enName: 'Toukh',
      arName: 'طوخ',
      aliases: ['toukh', 'طوخ'],
    ),
    EgyptLocationNode(
      slug: 'shibin-qanatir',
      enName: 'Shibin Al Qanatir',
      arName: 'شبين القناطر',
      aliases: ['shibin qanatir', 'شبين القناطر'],
    ),
  ],
);
