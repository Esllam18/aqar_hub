import '../models/property_filter_model.dart';

abstract interface class PropertyDatasource {
  Future<List<Map<String, dynamic>>> fetchProperties({
    required PropertyFilterModel filter,
    required int page,
    required int pageSize,
  });

  Future<Map<String, dynamic>?> fetchPropertyById(String id);
}
