// lib/features/house_seeker/search/data/repositories/search_repository_impl.dart

import '../../../../house_seeker/home/data/models/property_filter_model.dart';
import '../../../../house_seeker/home/data/models/property_model.dart';
import '../../../../house_seeker/home/data/models/rental_option_model.dart';
import '../datasources/search_datasource.dart';
import 'search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchDatasource _ds;
  SearchRepositoryImpl(this._ds);

  @override
  Future<List<PropertyModel>> searchProperties({
    required PropertyFilterModel filter,
    required int limit,
  }) async {
    final rows = await _ds.searchProperties(filter: filter, limit: limit);
    return rows.map(_mapRow).toList();
  }

  PropertyModel _mapRow(Map<String, dynamic> m) {
    final optRaw = m['rental_options'] as List? ?? [];
    final owner = m['profiles'] as Map<String, dynamic>?;
    final options = optRaw
        .map((o) => RentalOptionModel.fromMap(o as Map<String, dynamic>))
        .toList();

    return PropertyModel.fromMap({
      ...m,
      if (owner != null) ...{
        'owner_name': '${owner['first_name'] ?? ''} ${owner['last_name'] ?? ''}'
            .trim(),
        'owner_phone': owner['phone_number'],
        'owner_avatar': owner['profile_image_url'],
      },
    }, options: options);
  }
}
