import '../../../home/data/models/property_model.dart';
import '../../../home/data/models/rental_option_model.dart';
import '../datasources/favorites_datasource.dart';
import 'favorites_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesDatasource _favDatasource;
  final SupabaseClient _supabase = Supabase.instance.client;

  FavoritesRepositoryImpl(this._favDatasource);

  static const _select = '''
    *,
    rental_options(*),
    profiles!properties_owner_id_fkey(
      first_name, last_name, phone_number, profile_image_url
    )
  ''';

  @override
  Future<List<String>> getFavoriteIds(String userId) =>
      _favDatasource.fetchFavoriteIds(userId);

  @override
  Future<void> addFavorite(String userId, String propertyId) =>
      _favDatasource.addFavorite(userId, propertyId);

  @override
  Future<void> removeFavorite(String userId, String propertyId) =>
      _favDatasource.removeFavorite(userId, propertyId);

  @override
  Future<List<PropertyModel>> getFavoriteProperties(String userId) async {
    final ids = await _favDatasource.fetchFavoriteIds(userId);
    if (ids.isEmpty) return [];

    final response = await _supabase
        .from('properties')
        .select(_select)
        .inFilter('id', ids);

    final raw = List<Map<String, dynamic>>.from(response as List);
    return raw.map(_mapToModel).toList();
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
