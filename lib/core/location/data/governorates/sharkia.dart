// lib/core/location/governorates/sharkia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode sharkiaGovernorate = EgyptLocationNode(
  slug: 'sharkia',
  enName: 'Sharkia',
  arName: 'الشرقية',
  // 'sharqia' is a legacy spelling found in DB — listed as alias so it resolves
  aliases: ['sharkia', 'الشرقية', 'الشرقيه', 'sharqiyya', 'sharqia'],
  children: [
    EgyptLocationNode(slug: 'zagazig', enName: 'Zagazig', arName: 'الزقازيق', aliases: ['zagazig', 'الزقازيق']),
    EgyptLocationNode(slug: 'bilbeis', enName: 'Bilbeis', arName: 'بلبيس', aliases: ['bilbeis', 'بلبيس']),
    EgyptLocationNode(slug: '10th_ramadan', enName: '10th of Ramadan', arName: 'العاشر من رمضان', aliases: ['10th ramadan', 'العاشر من رمضان', '10th-ramadan']),
    EgyptLocationNode(slug: 'hihya', enName: 'Hihya', arName: 'ههيا', aliases: ['hihya', 'ههيا']),
    EgyptLocationNode(slug: 'abu_hammad', enName: 'Abu Hammad', arName: 'أبو حماد', aliases: ['abu hammad', 'أبو حماد', 'abu-hammad']),
    EgyptLocationNode(slug: 'faqous', enName: 'Faqous', arName: 'فاقوس', aliases: ['faqous', 'فاقوس']),
    EgyptLocationNode(slug: 'meet_abu_omar', enName: 'Meet Abu Omar', arName: 'ميت أبو عمر', aliases: ['meet abu omar', 'ميت أبو عمر', 'meet-abu-omar']),
  ],
);
