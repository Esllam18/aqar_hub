// lib/core/location/governorates/dakahlia.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode dakahliaGovernorate = EgyptLocationNode(
  slug: 'dakahlia',
  enName: 'Dakahlia',
  arName: 'الدقهلية',
  aliases: ['dakahlia', 'الدقهلية', 'دقهلية'],
  children: [
    EgyptLocationNode(
      slug: 'mansoura',
      enName: 'Mansoura',
      arName: 'المنصورة',
      aliases: ['mansoura', 'المنصورة', 'منصورة', 'el mansoura'],
    ),
    EgyptLocationNode(
      slug: 'talkhaa',
      enName: 'Talkhaa',
      arName: 'طلخا',
      aliases: ['talkhaa', 'talkha', 'طلخا'],
    ),
    EgyptLocationNode(
      slug: 'mit-ghamr',
      enName: 'Mit Ghamr',
      arName: 'ميت غمر',
      aliases: ['mit ghamr', 'ميت غمر'],
    ),
    EgyptLocationNode(
      slug: 'aga',
      enName: 'Aga',
      arName: 'أجا',
      aliases: ['aga', 'أجا'],
    ),
    EgyptLocationNode(
      slug: 'sinbillawein',
      enName: 'Sinbillawein',
      arName: 'السنبلاوين',
      aliases: ['sinbillawein', 'السنبلاوين'],
    ),
    EgyptLocationNode(
      slug: 'belkas',
      enName: 'Belkas',
      arName: 'بلقاس',
      aliases: ['belkas', 'بلقاس'],
    ),
    EgyptLocationNode(
      slug: 'sherbin',
      enName: 'Sherbin',
      arName: 'شربين',
      aliases: ['sherbin', 'شربين'],
    ),
  ],
);
