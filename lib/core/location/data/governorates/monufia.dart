// lib/core/location/governorates/monufia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode monufiaGovernorate = EgyptLocationNode(
  slug: 'monufia',
  enName: 'Monufia',
  arName: 'المنوفية',
  aliases: ['monufia', 'menoufia', 'المنوفية', 'منوفية'],
  children: [
    EgyptLocationNode(
      slug: 'shibin-el-kom',
      enName: 'Shibin El Kom',
      arName: 'شبين الكوم',
      aliases: ['shibin el kom', 'شبين الكوم', 'شبين الكوم'],
    ),
    EgyptLocationNode(
      slug: 'menouf',
      enName: 'Menouf',
      arName: 'منوف',
      aliases: ['menouf', 'منوف'],
    ),
    EgyptLocationNode(
      slug: 'ashmoun',
      enName: 'Ashmoun',
      arName: 'أشمون',
      aliases: ['ashmoun', 'أشمون'],
    ),
    EgyptLocationNode(
      slug: 'sadat-city',
      enName: 'Sadat City',
      arName: 'مدينة السادات',
      aliases: ['sadat city', 'مدينة السادات', 'السادات'],
    ),
    EgyptLocationNode(
      slug: 'quesna',
      enName: 'Quesna',
      arName: 'قويسنا',
      aliases: ['quesna', 'قويسنا'],
    ),
    EgyptLocationNode(
      slug: 'berkat-sab3',
      enName: 'Berkat El Sab3',
      arName: 'بركة السبع',
      aliases: ['berkat el sab3', 'بركة السبع', 'بركه السبع'],
    ),
    EgyptLocationNode(
      slug: 'tala',
      enName: 'Tala',
      arName: 'طلا',
      aliases: ['tala', 'طلا'],
    ),
  ],
);
