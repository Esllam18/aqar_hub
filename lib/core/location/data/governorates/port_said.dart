// lib/core/location/governorates/port_said.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode portSaidGovernorate = EgyptLocationNode(
  slug: 'port_said',
  enName: 'Port Said',
  arName: 'بورسعيد',
  aliases: ['port said', 'بورسعيد', 'بور سعيد'],
  children: [
    EgyptLocationNode(slug: 'port_said_city', enName: 'Port Said City', arName: 'مدينة بورسعيد', aliases: ['port said city', 'مدينة بورسعيد', 'port-said-city']),
    EgyptLocationNode(slug: 'zohour', enName: 'El Zohour', arName: 'حي الزهور', aliases: ['zohour', 'الزهور', 'حي الزهور']),
    EgyptLocationNode(slug: 'dawahi', enName: 'El Dawahi', arName: 'حي الضواحي', aliases: ['dawahi', 'الضواحي']),
    EgyptLocationNode(slug: 'arab', enName: 'El Arab', arName: 'حي العرب', aliases: ['arab', 'العرب']),
  ],
);
