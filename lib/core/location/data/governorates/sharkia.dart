// lib/core/location/governorates/sharkia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode sharkiaGovernorate = EgyptLocationNode(
  slug: 'sharkia',
  enName: 'Sharkia',
  arName: 'الشرقية',
  aliases: ['sharkia', 'sharqia', 'الشرقية', 'شرقية'],
  children: [
    EgyptLocationNode(
      slug: 'zagazig',
      enName: 'Zagazig',
      arName: 'الزقازيق',
      aliases: ['zagazig', 'الزقازيق', 'زقازيق'],
    ),
    EgyptLocationNode(
      slug: 'bilbeis',
      enName: 'Bilbeis',
      arName: 'بلبيس',
      aliases: ['bilbeis', 'بلبيس'],
    ),
    EgyptLocationNode(
      slug: '10th-ramadan',
      enName: '10th of Ramadan',
      arName: 'العاشر من رمضان',
      aliases: ['10th ramadan', 'العاشر من رمضان', 'عاشر رمضان'],
    ),
    EgyptLocationNode(
      slug: 'hihya',
      enName: 'Hihya',
      arName: 'ههيا',
      aliases: ['hihya', 'ههيا'],
    ),
    EgyptLocationNode(
      slug: 'abu-hammad',
      enName: 'Abu Hammad',
      arName: 'أبو حماد',
      aliases: ['abu hammad', 'أبو حماد'],
    ),
    EgyptLocationNode(
      slug: 'faqous',
      enName: 'Faqous',
      arName: 'فاقوس',
      aliases: ['faqous', 'فاقوس'],
    ),
    EgyptLocationNode(
      slug: 'meet-abu-omar',
      enName: 'Meet Abu Omar',
      arName: 'ميت أبو عمر',
      aliases: ['meet abu omar', 'ميت أبو عمر'],
    ),
  ],
);
