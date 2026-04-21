// lib/core/location/governorates/gharbia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode gharbiaGovernorate = EgyptLocationNode(
  slug: 'gharbia',
  enName: 'Gharbia',
  arName: 'الغربية',
  aliases: ['gharbia', 'الغربية', 'غربية'],
  children: [
    EgyptLocationNode(
      slug: 'tanta',
      enName: 'Tanta',
      arName: 'طنطا',
      aliases: ['tanta', 'طنطا'],
    ),
    EgyptLocationNode(
      slug: 'mahalla',
      enName: 'El Mahalla El Kubra',
      arName: 'المحلة الكبرى',
      aliases: ['mahalla', 'المحلة', 'المحلة الكبرى', 'el mahalla'],
    ),
    EgyptLocationNode(
      slug: 'kafr-zayat',
      enName: 'Kafr El Zayat',
      arName: 'كفر الزيات',
      aliases: ['kafr zayat', 'kafr el zayat', 'كفر الزيات'],
    ),
    EgyptLocationNode(
      slug: 'zefta',
      enName: 'Zefta',
      arName: 'زفتى',
      aliases: ['zefta', 'زفتى'],
    ),
    EgyptLocationNode(
      slug: 'samanoud',
      enName: 'Samanoud',
      arName: 'سمنود',
      aliases: ['samanoud', 'سمنود'],
    ),
    EgyptLocationNode(
      slug: 'basyoun',
      enName: 'Basyoun',
      arName: 'بسيون',
      aliases: ['basyoun', 'بسيون'],
    ),
    EgyptLocationNode(
      slug: 'qutor',
      enName: 'Qutor',
      arName: 'قطور',
      aliases: ['qutor', 'قطور'],
    ),
  ],
);
