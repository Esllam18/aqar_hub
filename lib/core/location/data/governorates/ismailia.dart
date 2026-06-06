// lib/core/location/governorates/ismailia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode ismailiaGovernorate = EgyptLocationNode(
  slug: 'ismailia',
  enName: 'Ismailia',
  arName: 'الإسماعيلية',
  aliases: ['ismailia', 'الإسماعيلية', 'الاسماعيليه', 'ismailiyya'],
  children: [
    EgyptLocationNode(
      slug: 'ismailia_city',
      enName: 'Ismailia City',
      arName: 'مدينة الإسماعيلية',
      aliases: ['ismailia city', 'مدينة الإسماعيلية', 'ismailia-city'],
      children: [
        EgyptLocationNode(slug: 'downtown', enName: 'Downtown', arName: 'وسط المدينة', aliases: ['downtown', 'وسط المدينة']),
      ],
    ),
    EgyptLocationNode(slug: 'qantara_east', enName: 'Qantara East', arName: 'القنطرة شرق', aliases: ['qantara east', 'القنطرة شرق', 'qantara-east']),
    EgyptLocationNode(slug: 'qantara_west', enName: 'Qantara West', arName: 'القنطرة غرب', aliases: ['qantara west', 'القنطرة غرب', 'qantara-west']),
    EgyptLocationNode(slug: 'fayed', enName: 'Fayed', arName: 'فايد', aliases: ['fayed', 'فايد']),
    EgyptLocationNode(slug: 'tale3', enName: 'Tale3', arName: 'الطلع', aliases: ['tale3', 'الطلع']),
  ],
);
