// lib/features/house_seeker/search/data/repositories/search_repository.dart

import '../../../../house_seeker/home/data/models/property_filter_model.dart';
import '../../../../house_seeker/home/data/models/property_model.dart';

abstract interface class SearchRepository {
  Future<List<PropertyModel>> searchProperties({
    required PropertyFilterModel filter,
    required int limit,
  });
}
