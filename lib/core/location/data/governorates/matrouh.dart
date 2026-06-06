// lib/core/location/governorates/matrouh.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode matrouhGovernorate = EgyptLocationNode(
  slug: 'matrouh',
  enName: 'Matrouh',
  arName: 'مطروح',
  aliases: ['matrouh', 'مطروح', 'مرسى مطروح', 'marsa matruh'],
  children: [
    EgyptLocationNode(slug: 'marsa_matrouh', enName: 'Marsa Matrouh', arName: 'مرسى مطروح', aliases: ['marsa matrouh', 'مرسى مطروح', 'marsa-matrouh']),
    EgyptLocationNode(slug: 'sidi_barrani', enName: 'Sidi Barrani', arName: 'سيدي براني', aliases: ['sidi barrani', 'سيدي براني', 'sidi-barrani']),
    EgyptLocationNode(slug: 'sallum', enName: 'Sallum', arName: 'السلوم', aliases: ['sallum', 'السلوم']),
    EgyptLocationNode(slug: 'siwa', enName: 'Siwa', arName: 'سيوة', aliases: ['siwa', 'سيوة']),
    EgyptLocationNode(slug: 'el_hamam', enName: 'El Hamam', arName: 'الحمام', aliases: ['el hamam', 'الحمام', 'el-hamam']),
  ],
);
