// lib/core/location/governorates/giza.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode gizaGovernorate = EgyptLocationNode(
  slug: 'giza',
  enName: 'Giza',
  arName: 'الجيزة',
  aliases: ['giza', 'الجيزة', 'الجيزه'],
  children: [
    EgyptLocationNode(
      slug: 'dokki',
      enName: 'Dokki',
      arName: 'الدقي',
      aliases: ['dokki', 'الدقي', 'الدقى'],
    ),
    EgyptLocationNode(
      slug: 'mohandessin',
      enName: 'Mohandessin',
      arName: 'المهندسين',
      aliases: ['mohandessin', 'المهندسين', 'مهندسين'],
    ),
    EgyptLocationNode(
      slug: 'sixth-of-october',
      enName: '6th of October',
      arName: 'السادس من أكتوبر',
      aliases: ['6 october', '6th of october', '٦ اكتوبر', '6 أكتوبر',
                'أكتوبر', 'october city', 'سادس اكتوبر'],
    ),
    EgyptLocationNode(
      slug: 'sheikh-zayed',
      enName: 'Sheikh Zayed',
      arName: 'الشيخ زايد',
      aliases: ['sheikh zayed', 'الشيخ زايد', 'زايد', 'شيخ زايد'],
    ),
    EgyptLocationNode(
      slug: 'haram',
      enName: 'Haram',
      arName: 'الهرم',
      aliases: ['haram', 'الهرم'],
    ),
    EgyptLocationNode(
      slug: 'embaba',
      enName: 'Embaba',
      arName: 'إمبابة',
      aliases: ['embaba', 'إمبابة', 'امبابة', 'imbaba'],
    ),
    EgyptLocationNode(
      slug: 'agouza',
      enName: 'Agouza',
      arName: 'العجوزة',
      aliases: ['agouza', 'العجوزة', 'العجوزه'],
    ),
    EgyptLocationNode(
      slug: 'giza-city',
      enName: 'Giza City',
      arName: 'مدينة الجيزة',
      aliases: ['giza city', 'مدينة الجيزة', 'وسط الجيزة'],
    ),
    EgyptLocationNode(
      slug: 'faisal',
      enName: 'Faisal',
      arName: 'فيصل',
      aliases: ['faisal', 'فيصل'],
    ),
    EgyptLocationNode(
      slug: 'kirdasa',
      enName: 'Kirdasa',
      arName: 'كرداسة',
      aliases: ['kirdasa', 'كرداسة'],
    ),
  ],
);
