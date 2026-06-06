// lib/core/location/governorates/beheira.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode beheiraGovernorate = EgyptLocationNode(
  slug: 'beheira',
  enName: 'Beheira',
  arName: 'البحيرة',
  aliases: ['beheira', 'البحيرة', 'البحيره', 'buhayra'],
  children: [
    EgyptLocationNode(slug: 'damanhur', enName: 'Damanhur', arName: 'دمنهور', aliases: ['damanhur', 'دمنهور']),
    EgyptLocationNode(slug: 'kafr_dawwar', enName: 'Kafr El Dawwar', arName: 'كفر الدوار', aliases: ['kafr el dawwar', 'كفر الدوار', 'kafr-dawwar']),
    EgyptLocationNode(slug: 'rashid', enName: 'Rashid', arName: 'رشيد', aliases: ['rashid', 'رشيد', 'rosetta']),
    EgyptLocationNode(slug: 'abu_hummus', enName: 'Abu Hummus', arName: 'أبو حمص', aliases: ['abu hummus', 'أبو حمص', 'abu-hummus']),
    EgyptLocationNode(slug: 'edku', enName: 'Edku', arName: 'إدكو', aliases: ['edku', 'إدكو']),
    EgyptLocationNode(slug: 'burg_arab', enName: 'Burg El Arab', arName: 'برج العرب', aliases: ['burg arab', 'برج العرب', 'burg-arab']),
    EgyptLocationNode(slug: 'housh_issa', enName: 'Housh Issa', arName: 'حوش عيسى', aliases: ['housh issa', 'حوش عيسى', 'housh-issa']),
  ],
);
