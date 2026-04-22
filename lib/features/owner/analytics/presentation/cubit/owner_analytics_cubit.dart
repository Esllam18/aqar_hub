import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'owner_analytics_state.dart';

class OwnerAnalyticsCubit extends Cubit<OwnerAnalyticsState> {
  final _supabase = Supabase.instance.client;

  OwnerAnalyticsCubit() : super(const OwnerAnalyticsInitial());

  String? get _uid => _supabase.auth.currentUser?.id;

  static const _monthNames = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) {
      emit(const OwnerAnalyticsError('Not signed in.'));
      return;
    }

    emit(const OwnerAnalyticsLoading());

    try {
      // Fetch all owner properties with rental options
      final raw = await _supabase
          .from('properties')
          .select('*, rental_options(*)')
          .eq('owner_id', uid)
          .order('created_at', ascending: true);

      final rows = List<Map<String, dynamic>>.from(raw as List);

      // ── Aggregate ────────────────────────────────────────────────────────
      int rentCount = 0;
      int saleCount = 0;
      int rentedCount = 0;
      double portfolioValue = 0;
      double rentValue = 0;
      double saleValue = 0;

      final byType = <String, int>{};
      final byCity = <String, int>{};
      final byRentalType = <String, int>{};
      int furnished = 0;
      int unfurnished = 0;

      // Group by month (last 6 months relative to newest listing)
      final now = DateTime.now();
      // Build a list of the last 6 calendar months
      final months = List.generate(6, (i) {
        final dt = DateTime(now.year, now.month - (5 - i), 1);
        return MonthlyCount(
          label: _monthNames[dt.month],
          year: dt.year,
          month: dt.month,
          count: 0,
        );
      });

      for (final row in rows) {
        final listingType = (row['listing_type'] as String? ?? 'rent');
        final isRented = row['is_rented'] == true;
        final isFurnishedProp = row['is_furnished'] == true;
        final propertyType = (row['property_type'] as String? ?? 'apartment');
        final city = (row['city'] as String? ?? '').trim();
        final basePrice = (row['base_price'] as num?)?.toDouble() ?? 0.0;
        final createdAtStr = row['created_at'] as String? ?? '';
        final createdAt = DateTime.tryParse(createdAtStr) ?? now;

        if (listingType == 'sale') {
          saleCount++;
          saleValue += basePrice;
        } else {
          rentCount++;
          rentValue += basePrice;
        }

        if (isRented) rentedCount++;
        portfolioValue += basePrice;

        // Property type breakdown
        byType[propertyType] = (byType[propertyType] ?? 0) + 1;

        // City breakdown
        if (city.isNotEmpty) {
          byCity[city] = (byCity[city] ?? 0) + 1;
        }

        // Furnished
        if (isFurnishedProp) {
          furnished++;
        } else {
          unfurnished++;
        }

        // Rental options breakdown
        final rentalOptions = row['rental_options'] as List? ?? [];
        for (final opt in rentalOptions) {
          final optType = (opt as Map<String, dynamic>)['type'] as String? ?? '';
          if (optType.isNotEmpty) {
            byRentalType[optType] = (byRentalType[optType] ?? 0) + 1;
          }
        }

        // Monthly count (last 6 months only)
        for (var i = 0; i < months.length; i++) {
          if (months[i].year == createdAt.year &&
              months[i].month == createdAt.month) {
            months[i] = MonthlyCount(
              label: months[i].label,
              year: months[i].year,
              month: months[i].month,
              count: months[i].count + 1,
            );
            break;
          }
        }
      }

      emit(
        OwnerAnalyticsLoaded(
          OwnerAnalyticsData(
            totalProperties: rows.length,
            rentProperties: rentCount,
            saleProperties: saleCount,
            rentedProperties: rentedCount,
            availableProperties: rows.length - rentedCount,
            totalPortfolioValue: portfolioValue,
            totalRentValue: rentValue,
            totalSaleValue: saleValue,
            byPropertyType: byType,
            listingsByMonth: months,
            byCity: byCity,
            byRentalOptionType: byRentalType,
            furnished: furnished,
            unfurnished: unfurnished,
          ),
        ),
      );
    } catch (e) {
      emit(OwnerAnalyticsError(e.toString()));
    }
  }

  Future<void> refresh() => load();
}
