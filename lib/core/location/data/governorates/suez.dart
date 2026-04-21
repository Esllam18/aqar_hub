// lib/core/location/governorates/suez.dart
import 'package:aqar_hub/core/location/models/location_node.dart';

const EgyptLocationNode suezGovernorate = EgyptLocationNode(
  slug: 'suez',
  enName: 'Suez',
  arName: 'السويس',
  aliases: ['suez', 'السويس', 'سويس'],
  children: [
    EgyptLocationNode(slug: 'suez-city', enName: 'Suez City', arName: 'مدينة السويس', aliases: ['suez city', 'مدينة السويس']),
    EgyptLocationNode(slug: 'arbeen', enName: 'El Arbeen', arName: 'الأربعين', aliases: ['el arbeen', 'الأربعين', 'arbeen']),
    EgyptLocationNode(slug: 'ataka', enName: 'Ataka', arName: 'عتاقة', aliases: ['ataka', 'عتاقة']),
    EgyptLocationNode(slug: 'faisal', enName: 'Faisal', arName: 'فيصل', aliases: ['faisal', 'فيصل']),
  ],
);
