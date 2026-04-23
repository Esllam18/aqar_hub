import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../house_seeker/home/data/models/property_filter_model.dart';

abstract interface class SearchDatasource {
  Future<List<Map<String, dynamic>>> searchProperties({
    required PropertyFilterModel filter,
    required int limit,
  });
}

class SearchDatasourceImpl implements SearchDatasource {
  final SupabaseClient _db = Supabase.instance.client;

  static const String _select = '''
    *,
    rental_options(*),
    profiles!properties_owner_id_fkey(
      first_name,
      last_name,
      phone_number,
      profile_image_url
    )
  ''';

  @override
  Future<List<Map<String, dynamic>>> searchProperties({
    required PropertyFilterModel filter,
    required int limit,
  }) async {
    dynamic q = _db.from('properties').select(_select);

    // ── CRITICAL: Only show available (not already rented) properties ──────
    if (filter.listingType == 'rent') {
      q = q.eq('is_rented', false);
    } else if (filter.listingType == null) {
      q = q.or(
        'listing_type.eq.sale,and(listing_type.eq.rent,is_rented.eq.false)',
      );
    }
    // For sale: is_rented is not meaningful, no filter needed.

    if (filter.listingType != null) {
      q = q.eq('listing_type', filter.listingType!);
    }
    if (filter.propertyType != null) {
      q = q.eq('property_type', filter.propertyType!);
    }
    if (filter.governorateSlug != null) {
      q = q.eq('governorate_slug', filter.governorateSlug!);
    }
    if (filter.citySlug != null) {
      q = q.eq('city_slug', filter.citySlug!);
    }
    if (filter.minPrice != null) {
      q = q.gte('base_price', filter.minPrice!);
    }
    if (filter.maxPrice != null) {
      q = q.lte('base_price', filter.maxPrice!);
    }
    if (filter.minRooms != null) {
      q = q.gte('total_rooms', filter.minRooms!);
    }
    if (filter.minBeds != null) {
      q = q.gte('total_beds', filter.minBeds!);
    }
    if (filter.isFurnished != null) {
      q = q.eq('is_furnished', filter.isFurnished!);
    }
    if (filter.targetAudience != null && filter.targetAudience != 'all') {
      q = q.or(
        'target_audience.eq.${filter.targetAudience!},target_audience.eq.all',
      );
    }

    final rows =
        await q.order('created_at', ascending: false).limit(limit) as List;

    return rows.map((r) => Map<String, dynamic>.from(r as Map)).toList();
  }
}
