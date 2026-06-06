// lib/core/location/governorates/red_sea.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode redSeaGovernorate = EgyptLocationNode(
  slug: 'red_sea',
  enName: 'Red Sea',
  arName: 'البحر الأحمر',
  aliases: ['red sea', 'البحر الأحمر', 'البحر الاحمر'],
  children: [
    EgyptLocationNode(slug: 'hurghada', enName: 'Hurghada', arName: 'الغردقة', aliases: ['hurghada', 'الغردقة', 'هرغادة', 'ghardaqa']),
    EgyptLocationNode(slug: 'safaga', enName: 'Safaga', arName: 'سفاجا', aliases: ['safaga', 'سفاجا']),
    EgyptLocationNode(slug: 'el_gouna', enName: 'El Gouna', arName: 'الجونة', aliases: ['el gouna', 'الجونة', 'جونة', 'gouna', 'el-gouna']),
    EgyptLocationNode(slug: 'marsa_alam', enName: 'Marsa Alam', arName: 'مرسى علم', aliases: ['marsa alam', 'مرسى علم', 'marsa-alam']),
    EgyptLocationNode(slug: 'quseir', enName: 'Quseir', arName: 'القصير', aliases: ['quseir', 'القصير']),
    EgyptLocationNode(slug: 'soma_bay', enName: 'Soma Bay', arName: 'سوما باي', aliases: ['soma bay', 'سوما باي', 'soma-bay']),
    EgyptLocationNode(slug: 'sahl_hasheesh', enName: 'Sahl Hasheesh', arName: 'سهل حشيش', aliases: ['sahl hasheesh', 'سهل حشيش', 'sahl-hasheesh']),
  ],
);
