import '../../../home/data/models/property_model.dart';

abstract interface class FavoritesRepository {
  Future<List<PropertyModel>> getFavoriteProperties(String userId);
  Future<void> addFavorite(String userId, String propertyId);
  Future<void> removeFavorite(String userId, String propertyId);
  Future<List<String>> getFavoriteIds(String userId);
}
