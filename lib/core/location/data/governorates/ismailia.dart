// lib/core/location/governorates/ismailia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode ismailiaGovernorate = EgyptLocationNode(
  slug: 'ismailia',
  enName: 'Ismailia',
  arName: 'الإسماعيلية',
  aliases: ['ismailia', 'الإسماعيلية', 'الاسماعيلية', 'اسماعيلية'],
  children: [
    EgyptLocationNode(slug: 'ismailia-city', enName: 'Ismailia City', arName: 'مدينة الإسماعيلية', aliases: ['ismailia city', 'مدينة الإسماعيلية']),
    EgyptLocationNode(slug: 'qantara-east', enName: 'Qantara East', arName: 'القنطرة شرق', aliases: ['qantara east', 'القنطرة شرق']),
    EgyptLocationNode(slug: 'qantara-west', enName: 'Qantara West', arName: 'القنطرة غرب', aliases: ['qantara west', 'القنطرة غرب']),
    EgyptLocationNode(slug: 'fayed', enName: 'Fayed', arName: 'فايد', aliases: ['fayed', 'فايد']),
    EgyptLocationNode(slug: 'tale3', enName: 'Tale3', arName: 'الطلع', aliases: ['tale3', 'الطلع']),
  ],
);
