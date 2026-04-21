import '../models/property_filter_model.dart';
import '../models/property_model.dart';

abstract interface class PropertyRepository {
  Future<List<PropertyModel>> getProperties({
    required PropertyFilterModel filter,
    required int page,
    required int pageSize,
  });

  Future<PropertyModel?> getPropertyById(String id);
}
