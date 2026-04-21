// lib/core/location/governorates/fayoum.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode fayoumGovernorate = EgyptLocationNode(
  slug: 'fayoum',
  enName: 'Fayoum',
  arName: 'الفيوم',
  aliases: ['faiyum', 'fayoum', 'الفيوم', 'فيوم'],
  children: [
    EgyptLocationNode(slug: 'fayoum-city', enName: 'Fayoum City', arName: 'مدينة الفيوم', aliases: ['fayoum city', 'مدينة الفيوم']),
    EgyptLocationNode(slug: 'lake-qarun', enName: 'Lake Qarun', arName: 'بحيرة قارون', aliases: ['lake qarun', 'بحيرة قارون', 'قارون']),
    EgyptLocationNode(slug: 'sinnuris', enName: 'Sinnuris', arName: 'سنورس', aliases: ['sinnuris', 'سنورس']),
    EgyptLocationNode(slug: 'tamiya', enName: 'Tamiya', arName: 'طامية', aliases: ['tamiya', 'طامية']),
    EgyptLocationNode(slug: 'itsa', enName: 'Itsa', arName: 'إطسا', aliases: ['itsa', 'إطسا']),
    EgyptLocationNode(slug: 'yousef-seddik', enName: 'Yousef El Seddik', arName: 'يوسف الصديق', aliases: ['yousef seddik', 'يوسف الصديق']),
  ],
);
