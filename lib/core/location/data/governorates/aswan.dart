// lib/core/location/governorates/aswan.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode aswanGovernorate = EgyptLocationNode(
  slug: 'aswan',
  enName: 'Aswan',
  arName: 'أسوان',
  aliases: ['aswan', 'أسوان', 'اسوان'],
  children: [
    EgyptLocationNode(slug: 'aswan-city', enName: 'Aswan City', arName: 'مدينة أسوان', aliases: ['aswan city', 'مدينة أسوان']),
    EgyptLocationNode(slug: 'kom-ombo', enName: 'Kom Ombo', arName: 'كوم أمبو', aliases: ['kom ombo', 'كوم أمبو']),
    EgyptLocationNode(slug: 'edfu', enName: 'Edfu', arName: 'إدفو', aliases: ['edfu', 'إدفو', 'idfu']),
    EgyptLocationNode(slug: 'nasr-el-nuba', enName: 'Nasr El Nuba', arName: 'نصر النوبة', aliases: ['nasr nuba', 'نصر النوبة']),
    EgyptLocationNode(slug: 'daraw', enName: 'Daraw', arName: 'دراو', aliases: ['daraw', 'دراو']),
  ],
);
