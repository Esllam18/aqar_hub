// lib/core/location/governorates/aswan.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode aswanGovernorate = EgyptLocationNode(
  slug: 'aswan',
  enName: 'Aswan',
  arName: 'أسوان',
  aliases: ['aswan', 'أسوان', 'اسوان'],
  children: [
    EgyptLocationNode(slug: 'aswan_city', enName: 'Aswan City', arName: 'مدينة أسوان', aliases: ['aswan city', 'مدينة أسوان', 'aswan-city']),
    EgyptLocationNode(slug: 'kom_ombo', enName: 'Kom Ombo', arName: 'كوم أمبو', aliases: ['kom ombo', 'كوم أمبو', 'kom-ombo']),
    EgyptLocationNode(slug: 'edfu', enName: 'Edfu', arName: 'إدفو', aliases: ['edfu', 'إدفو', 'idfu']),
    EgyptLocationNode(slug: 'nasr_el_nuba', enName: 'Nasr El Nuba', arName: 'نصر النوبة', aliases: ['nasr nuba', 'نصر النوبة', 'nasr-el-nuba']),
    EgyptLocationNode(slug: 'daraw', enName: 'Daraw', arName: 'دراو', aliases: ['daraw', 'دراو']),
  ],
);
