import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/property_filter_model.dart';
import 'property_datasource.dart';

class PropertyDatasourceImpl implements PropertyDatasource {
  final SupabaseClient supabase = Supabase.instance.client;

  static const String _baseSelect = '''
    *,
    rental_options(*),
    profiles!properties_owner_id_fkey(
      first_name,
      last_name,
      phone_number,
      profile_image_url
    )
  ''';

  static const String _selectWithRentalInner = '''
    *,
    rental_options!inner(*),
    profiles!properties_owner_id_fkey(
      first_name,
      last_name,
      phone_number,
      profile_image_url
    )
  ''';

  @override
  Future<List<Map<String, dynamic>>> fetchProperties({
    required PropertyFilterModel filter,
    required int page,
    required int pageSize,
  }) async {
    final select = filter.rentalType != null
        ? _selectWithRentalInner
        : _baseSelect;

    dynamic query = supabase.from('properties').select(select);

    // ── CRITICAL: Only show available (not already rented) properties ──────
    // For rent listings, hide units that are fully rented out.
    // Sale properties do not use is_rented, so we only apply this to rent.
    if (filter.listingType == 'rent' || filter.listingType == null) {
      // When listing_type is null (showing all), apply a compound filter:
      // show sale properties always, show rent properties only if not rented.
      if (filter.listingType == null) {
        query = query.or(
          'listing_type.eq.sale,and(listing_type.eq.rent,is_rented.eq.false)',
        );
      } else {
        // Explicitly filtering rent — hide rented ones
        query = query.eq('is_rented', false);
      }
    }

    if (filter.listingType != null) {
      query = query.eq('listing_type', filter.listingType!);
    }

    if (filter.governorateSlug != null) {
      query = query.eq('governorate_slug', filter.governorateSlug!);
    }

    if (filter.citySlug != null) {
      query = query.eq('city_slug', filter.citySlug!);
    }

    if (filter.areaSlug != null) {
      query = query.eq('area_slug', filter.areaSlug!);
    }

    if (filter.propertyType != null) {
      query = query.eq('property_type', filter.propertyType!);
    }

    if (filter.isFurnished != null) {
      query = query.eq('is_furnished', filter.isFurnished!);
    }

    if (filter.targetAudience != null && filter.targetAudience != 'all') {
      query = query.eq('target_audience', filter.targetAudience!);
    }

    if (filter.minRooms != null) {
      query = query.gte('total_rooms', filter.minRooms!);
    }

    if (filter.minBeds != null) {
      query = query.gte('total_beds', filter.minBeds!);
    }

    if (filter.minPrice != null) {
      query = query.gte('base_price', filter.minPrice!);
    }

    if (filter.maxPrice != null) {
      query = query.lte('base_price', filter.maxPrice!);
    }

    if (filter.rentalType != null) {
      query = query.eq('rental_options.type', filter.rentalType!);
    }

    final offset = page * pageSize;

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    return List<Map<String, dynamic>>.from(response as List);
  }

  @override
  Future<Map<String, dynamic>?> fetchPropertyById(String id) async {
    final response = await supabase
        .from('properties')
        .select(_baseSelect)
        .eq('id', id)
        .maybeSingle();

    return response;
  }
}
