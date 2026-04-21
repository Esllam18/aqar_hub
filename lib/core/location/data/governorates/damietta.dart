// lib/core/location/governorates/damietta.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode damiettaGovernorate = EgyptLocationNode(
  slug: 'damietta',
  enName: 'Damietta',
  arName: 'دمياط',
  aliases: ['damietta', 'دمياط', 'دميات'],
  children: [
    EgyptLocationNode(slug: 'new-damietta', enName: 'New Damietta', arName: 'دمياط الجديدة', aliases: ['new damietta', 'دمياط الجديدة']),
    EgyptLocationNode(slug: 'faraskour', enName: 'Faraskour', arName: 'فارسكور', aliases: ['faraskour', 'فارسكور']),
    EgyptLocationNode(slug: 'zarqa', enName: 'Zarqa', arName: 'الزرقا', aliases: ['zarqa', 'الزرقا']),
    EgyptLocationNode(slug: 'kafr-el-battikh', enName: 'Kafr El Battikh', arName: 'كفر البطيخ', aliases: ['kafr el battikh', 'كفر البطيخ']),
  ],
);
