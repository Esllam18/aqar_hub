import 'package:aqar_hub/features/shared/profile/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OwnerProfileDatasource
//
// Uses the proven pattern from ProfileDatasourceImpl:
//   .from('profiles').select().eq('id', uid).single()
//   → ProfileModel.fromMap(data)
//
// This ensures we get the same field mapping that works in the rest of the app.
//
// File path:
//   lib/features/house_seeker/home/data/datasources/owner_profile_datasource.dart
// ─────────────────────────────────────────────────────────────────────────────

class OwnerProfileDatasource {
  SupabaseClient get _db => Supabase.instance.client;

  /// Fetch the profiles row for [ownerId] and parse it into [ProfileModel].
  /// Returns null if no row exists (owner never completed their profile).
  Future<ProfileModel?> fetchProfile(String ownerId) async {
    try {
      final data = await _db
          .from('profiles')
          .select()
          .eq('id', ownerId)
          .single();
      return ProfileModel.fromMap(data);
    } catch (_) {
      // single() throws if no row; treat as "no profile found"
      return null;
    }
  }

  /// Fetch auth user_metadata for Google OAuth fallback.
  /// Only populated when [ownerId] is the currently signed-in user.
  Map<String, dynamic>? fetchCurrentUserMeta(String ownerId) {
    final user = _db.auth.currentUser;
    if (user?.id != ownerId) return null;
    return user?.userMetadata;
  }

  /// Fetch all published properties for [ownerId], newest first.
  Future<List<Map<String, dynamic>>> fetchProperties(String ownerId) async {
    final rows = await _db
        .from('properties')
        .select(
          'id, title, city, address, base_price, listing_type, '
          'property_type, image_urls, is_rented, price_label, '
          'target_audience, is_furnished, total_rooms, total_beds, '
          'bathrooms, area_m2, description, owner_id, video_url, '
          'governorate_slug, city_slug, area_slug, location_path, '
          'latitude, longitude, created_at, rental_options(*)',
        )
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(rows);
  }
}
