// lib/core/location/governorates/new_valley.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode newValleyGovernorate = EgyptLocationNode(
  slug: 'new_valley',
  enName: 'New Valley',
  arName: 'الوادي الجديد',
  aliases: ['new valley', 'الوادي الجديد', 'new_valley'],
  children: [
    EgyptLocationNode(slug: 'kharga', enName: 'Kharga', arName: 'الخارجة', aliases: ['kharga', 'الخارجة']),
    EgyptLocationNode(slug: 'dakhla', enName: 'Dakhla', arName: 'الداخلة', aliases: ['dakhla', 'الداخلة']),
    EgyptLocationNode(slug: 'farafra', enName: 'Farafra', arName: 'الفرافرة', aliases: ['farafra', 'الفرافرة']),
    EgyptLocationNode(slug: 'baris', enName: 'Baris', arName: 'باريس', aliases: ['baris', 'باريس']),
  ],
);
