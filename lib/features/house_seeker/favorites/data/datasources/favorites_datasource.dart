import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FavoritesDatasource {
  Future<List<String>> fetchFavoriteIds(String userId);
  Future<void> addFavorite(String userId, String propertyId);
  Future<void> removeFavorite(String userId, String propertyId);
}

class FavoritesDatasourceImpl implements FavoritesDatasource {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<String>> fetchFavoriteIds(String userId) async {
    final res = await _supabase
        .from('favorites')
        .select('property_id')
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(
      res as List,
    ).map((m) => m['property_id'] as String).toList();
  }

  @override
  Future<void> addFavorite(String userId, String propertyId) async {
    final existing = await _supabase
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('property_id', propertyId)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('favorites').insert({
        'user_id': userId,
        'property_id': propertyId,
      });
    }
  }

  @override
  Future<void> removeFavorite(String userId, String propertyId) async {
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('property_id', propertyId);
  }
}
