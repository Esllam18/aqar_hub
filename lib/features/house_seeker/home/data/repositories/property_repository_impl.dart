import '../datasources/property_datasource.dart';
import '../models/property_filter_model.dart';
import '../models/property_model.dart';
import '../models/rental_option_model.dart';
import 'property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyDatasource _datasource;
  PropertyRepositoryImpl(this._datasource);

  @override
  Future<List<PropertyModel>> getProperties({
    required PropertyFilterModel filter,
    required int page,
    required int pageSize,
  }) async {
    final data = await _datasource.fetchProperties(
      filter: filter,
      page: page,
      pageSize: pageSize,
    );
    return data.map(_mapToModel).toList();
  }

  @override
  Future<PropertyModel?> getPropertyById(String id) async {
    final m = await _datasource.fetchPropertyById(id);
    return m != null ? _mapToModel(m) : null;
  }

  PropertyModel _mapToModel(Map<String, dynamic> m) {
    final optionsRaw = m['rental_options'] as List?;
    final ownerRaw = m['profiles'] as Map<String, dynamic>?;

    final options =
        optionsRaw
            ?.map((o) => RentalOptionModel.fromMap(o as Map<String, dynamic>))
            .toList() ??
        [];

    final merged = {
      ...m,
      if (ownerRaw != null) ...{
        'owner_name':
            '${ownerRaw['first_name'] ?? ''} ${ownerRaw['last_name'] ?? ''}'
                .trim(),
        'owner_phone': ownerRaw['phone_number'],
        'owner_avatar': ownerRaw['profile_image_url'],
      },
    };

    return PropertyModel.fromMap(merged, options: options);
  }
}
