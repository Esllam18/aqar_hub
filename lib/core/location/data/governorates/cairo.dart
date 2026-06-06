// lib/core/location/governorates/cairo.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode cairoGovernorate = EgyptLocationNode(
  slug: 'cairo',
  enName: 'Cairo',
  arName: 'القاهرة',
  aliases: ['cairo', 'القاهرة', 'القاهره'],
  children: [
    EgyptLocationNode(
      slug: 'nasr_city',
      enName: 'Nasr City',
      arName: 'مدينة نصر',
      aliases: ['nasr city', 'مدينة نصر', 'مدينه نصر', 'madinet nasr', 'نصر', 'nasr-city'],
    ),
    EgyptLocationNode(
      slug: 'heliopolis',
      enName: 'Heliopolis',
      arName: 'مصر الجديدة',
      aliases: ['heliopolis', 'مصر الجديدة', 'هيليوبوليس', 'مصر الجديده'],
    ),
    EgyptLocationNode(
      slug: 'maadi',
      enName: 'Maadi',
      arName: 'المعادي',
      aliases: ['maadi', 'المعادي', 'المعادى'],
      children: [
        EgyptLocationNode(
          slug: 'degla',
          enName: 'Degla',
          arName: 'دجلة',
          aliases: ['degla', 'دجلة'],
        ),
        EgyptLocationNode(
          slug: 'sarayat',
          enName: 'Sarayat',
          arName: 'السرايات',
          aliases: ['sarayat', 'السرايات'],
        ),
        EgyptLocationNode(
          slug: 'corniche_maadi',
          enName: 'Corniche El Maadi',
          arName: 'كورنيش المعادي',
          aliases: ['corniche maadi', 'كورنيش المعادي'],
        ),
      ],
    ),
    EgyptLocationNode(
      slug: 'new_cairo',
      enName: 'New Cairo',
      arName: 'القاهرة الجديدة',
      aliases: ['new cairo', 'القاهرة الجديدة', 'التجمع', 'التجمع الخامس',
                'fifth settlement', 'قاهره جديده', 'new-cairo'],
      children: [
        EgyptLocationNode(
          slug: 'fifth_settlement',
          enName: 'Fifth Settlement',
          arName: 'التجمع الخامس',
          aliases: ['fifth settlement', 'التجمع الخامس', 'التجمع'],
        ),
        EgyptLocationNode(
          slug: 'rehab',
          enName: 'El Rehab',
          arName: 'الرحاب',
          aliases: ['rehab', 'الرحاب'],
        ),
        EgyptLocationNode(
          slug: 'madinaty',
          enName: 'Madinaty',
          arName: 'مدينتي',
          aliases: ['madinaty', 'مدينتي'],
        ),
      ],
    ),
    EgyptLocationNode(
      slug: 'helwan',
      enName: 'Helwan',
      arName: 'حلوان',
      aliases: ['helwan', 'حلوان'],
    ),
    EgyptLocationNode(
      slug: 'ain_shams',
      enName: 'Ain Shams',
      arName: 'عين شمس',
      aliases: ['ain shams', 'عين شمس', 'عين شمش', 'ain-shams'],
    ),
    EgyptLocationNode(
      slug: 'shorouk',
      enName: 'El Shorouk',
      arName: 'الشروق',
      aliases: ['shorouk', 'el shorouk', 'الشروق', 'مدينة الشروق'],
    ),
    EgyptLocationNode(
      slug: 'badr',
      enName: 'Badr City',
      arName: 'مدينة بدر',
      aliases: ['badr city', 'مدينة بدر', 'بدر'],
    ),
    EgyptLocationNode(
      slug: 'downtown',
      enName: 'Downtown',
      arName: 'وسط البلد',
      aliases: ['downtown', 'وسط البلد', 'وسط القاهرة'],
    ),
    EgyptLocationNode(
      slug: 'zamalek',
      enName: 'Zamalek',
      arName: 'الزمالك',
      aliases: ['zamalek', 'الزمالك'],
    ),
    EgyptLocationNode(
      slug: 'garden_city',
      enName: 'Garden City',
      arName: 'جاردن سيتي',
      aliases: ['garden city', 'جاردن سيتي', 'garden-city'],
    ),
    EgyptLocationNode(
      slug: 'shubra',
      enName: 'Shubra',
      arName: 'شبرا',
      aliases: ['shubra', 'شبرا', 'شبره'],
    ),
    EgyptLocationNode(
      slug: 'dar_el_salam',
      enName: 'Dar El Salam',
      arName: 'دار السلام',
      aliases: ['dar el salam', 'دار السلام', 'dar-el-salam'],
    ),
    EgyptLocationNode(
      slug: 'basatin',
      enName: 'El Basatin',
      arName: 'البساتين',
      aliases: ['basatin', 'البساتين'],
    ),
  ],
);
