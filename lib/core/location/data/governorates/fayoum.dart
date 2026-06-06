// lib/core/location/governorates/fayoum.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode fayoumGovernorate = EgyptLocationNode(
  slug: 'fayoum',
  enName: 'Fayoum',
  arName: 'الفيوم',
  aliases: ['fayoum', 'الفيوم', 'fayum'],
  children: [
    EgyptLocationNode(slug: 'fayoum_city', enName: 'Fayoum City', arName: 'مدينة الفيوم', aliases: ['fayoum city', 'مدينة الفيوم', 'fayoum-city']),
    EgyptLocationNode(slug: 'lake_qarun', enName: 'Lake Qarun', arName: 'بحيرة قارون', aliases: ['lake qarun', 'بحيرة قارون', 'قارون', 'lake-qarun']),
    EgyptLocationNode(slug: 'sinnuris', enName: 'Sinnuris', arName: 'سنورس', aliases: ['sinnuris', 'سنورس']),
    EgyptLocationNode(slug: 'tamiya', enName: 'Tamiya', arName: 'طامية', aliases: ['tamiya', 'طامية']),
    EgyptLocationNode(slug: 'itsa', enName: 'Itsa', arName: 'إطسا', aliases: ['itsa', 'إطسا']),
    EgyptLocationNode(slug: 'yousef_seddik', enName: 'Yousef El Seddik', arName: 'يوسف الصديق', aliases: ['yousef seddik', 'يوسف الصديق', 'yousef-seddik']),
  ],
);
