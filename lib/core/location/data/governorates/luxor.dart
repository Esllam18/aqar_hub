// lib/core/location/governorates/luxor.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode luxorGovernorate = EgyptLocationNode(
  slug: 'luxor',
  enName: 'Luxor',
  arName: 'الأقصر',
  aliases: ['luxor', 'الأقصر', 'الاقصر'],
  children: [
    EgyptLocationNode(slug: 'luxor_city', enName: 'Luxor City', arName: 'مدينة الأقصر', aliases: ['luxor city', 'مدينة الأقصر', 'luxor-city']),
    EgyptLocationNode(slug: 'karnak', enName: 'Karnak', arName: 'الكرنك', aliases: ['karnak', 'الكرنك']),
    EgyptLocationNode(slug: 'esna', enName: 'Esna', arName: 'إسنا', aliases: ['esna', 'إسنا']),
    EgyptLocationNode(slug: 'armant', enName: 'Armant', arName: 'إرمنت', aliases: ['armant', 'إرمنت']),
    EgyptLocationNode(slug: 'toud', enName: 'Toud', arName: 'طود', aliases: ['toud', 'طود']),
  ],
);
