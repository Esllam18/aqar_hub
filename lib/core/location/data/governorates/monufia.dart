// lib/core/location/governorates/monufia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode monufiaGovernorate = EgyptLocationNode(
  slug: 'monufia',
  enName: 'Monufia',
  arName: 'المنوفية',
  aliases: ['monufia', 'المنوفية', 'المنوفيه', 'menoufia'],
  children: [
    EgyptLocationNode(slug: 'shibin_el_kom', enName: 'Shibin El Kom', arName: 'شبين الكوم', aliases: ['shibin el kom', 'شبين الكوم', 'shibin-el-kom']),
    EgyptLocationNode(slug: 'shebeen', enName: 'Shebeen El Kom', arName: 'شبين الكوم', aliases: ['shebeen', 'شبين الكوم', 'shebeen el kom']),
    EgyptLocationNode(slug: 'menouf', enName: 'Menouf', arName: 'منوف', aliases: ['menouf', 'منوف']),
    EgyptLocationNode(slug: 'ashmoun', enName: 'Ashmoun', arName: 'أشمون', aliases: ['ashmoun', 'أشمون']),
    EgyptLocationNode(slug: 'sadat_city', enName: 'Sadat City', arName: 'مدينة السادات', aliases: ['sadat city', 'مدينة السادات', 'sadat-city']),
    EgyptLocationNode(slug: 'quesna', enName: 'Quesna', arName: 'قويسنا', aliases: ['quesna', 'قويسنا']),
    EgyptLocationNode(slug: 'berkat_sab3', enName: 'Berkat El Sab3', arName: 'بركة السبع', aliases: ['berkat sab3', 'بركة السبع', 'berkat-sab3']),
    EgyptLocationNode(slug: 'tala', enName: 'Tala', arName: 'طلا', aliases: ['tala', 'طلا']),
  ],
);
