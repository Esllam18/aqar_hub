// lib/core/location/governorates/beheira.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode beheiraGovernorate = EgyptLocationNode(
  slug: 'beheira',
  enName: 'Beheira',
  arName: 'البحيرة',
  aliases: ['beheira', 'البحيرة', 'بحيرة'],
  children: [
    EgyptLocationNode(
      slug: 'damanhur',
      enName: 'Damanhur',
      arName: 'دمنهور',
      aliases: ['damanhur', 'دمنهور'],
    ),
    EgyptLocationNode(
      slug: 'kafr-dawwar',
      enName: 'Kafr El Dawwar',
      arName: 'كفر الدوار',
      aliases: ['kafr dawwar', 'كفر الدوار'],
    ),
    EgyptLocationNode(
      slug: 'rashid',
      enName: 'Rashid',
      arName: 'رشيد',
      aliases: ['rashid', 'رشيد', 'rosetta'],
    ),
    EgyptLocationNode(
      slug: 'abu-hummus',
      enName: 'Abu Hummus',
      arName: 'أبو حمص',
      aliases: ['abu hummus', 'أبو حمص'],
    ),
    EgyptLocationNode(
      slug: 'edku',
      enName: 'Edku',
      arName: 'إدكو',
      aliases: ['edku', 'إدكو'],
    ),
    EgyptLocationNode(
      slug: 'burg-arab',
      enName: 'Burg El Arab',
      arName: 'برج العرب',
      aliases: ['burg el arab', 'برج العرب', 'borg el arab'],
    ),
    EgyptLocationNode(
      slug: 'housh-issa',
      enName: 'Housh Issa',
      arName: 'حوش عيسى',
      aliases: ['housh issa', 'حوش عيسى'],
    ),
  ],
);
