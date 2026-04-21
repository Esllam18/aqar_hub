// lib/core/location/governorates/red_sea.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode redSeaGovernorate = EgyptLocationNode(
  slug: 'red_sea',
  enName: 'Red Sea',
  arName: 'البحر الأحمر',
  aliases: ['red sea', 'البحر الأحمر', 'البحر الاحمر', 'red_sea'],
  children: [
    EgyptLocationNode(slug: 'hurghada', enName: 'Hurghada', arName: 'الغردقة', aliases: ['hurghada', 'الغردقة', 'هرغادة', 'ghardaqa']),
    EgyptLocationNode(slug: 'safaga', enName: 'Safaga', arName: 'سفاجا', aliases: ['safaga', 'سفاجا']),
    EgyptLocationNode(slug: 'el-gouna', enName: 'El Gouna', arName: 'الجونة', aliases: ['el gouna', 'الجونة', 'جونة', 'gouna']),
    EgyptLocationNode(slug: 'marsa-alam', enName: 'Marsa Alam', arName: 'مرسى علم', aliases: ['marsa alam', 'مرسى علم']),
    EgyptLocationNode(slug: 'quseir', enName: 'Quseir', arName: 'القصير', aliases: ['quseir', 'القصير']),
    EgyptLocationNode(slug: 'soma-bay', enName: 'Soma Bay', arName: 'سوما باي', aliases: ['soma bay', 'سوما باي']),
    EgyptLocationNode(slug: 'sahl-hasheesh', enName: 'Sahl Hasheesh', arName: 'سهل حشيش', aliases: ['sahl hasheesh', 'سهل حشيش']),
  ],
);
