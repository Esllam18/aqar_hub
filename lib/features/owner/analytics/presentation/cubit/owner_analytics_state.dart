part of 'owner_analytics_cubit.dart';

// ── Analytics data model ───────────────────────────────────────────────────

class OwnerAnalyticsData {
  final int totalProperties;
  final int rentProperties;
  final int saleProperties;
  final int rentedProperties;
  final int availableProperties;

  final double totalPortfolioValue;
  final double totalRentValue;
  final double totalSaleValue;

  // Property type breakdown
  final Map<String, int> byPropertyType;

  // Listing months timeline (last 6 months)
  final List<MonthlyCount> listingsByMonth;

  // City breakdown
  final Map<String, int> byCity;

  // Rental option type breakdown
  final Map<String, int> byRentalOptionType;

  // Furnished vs Unfurnished
  final int furnished;
  final int unfurnished;

  const OwnerAnalyticsData({
    required this.totalProperties,
    required this.rentProperties,
    required this.saleProperties,
    required this.rentedProperties,
    required this.availableProperties,
    required this.totalPortfolioValue,
    required this.totalRentValue,
    required this.totalSaleValue,
    required this.byPropertyType,
    required this.listingsByMonth,
    required this.byCity,
    required this.byRentalOptionType,
    required this.furnished,
    required this.unfurnished,
  });
}

class MonthlyCount {
  final String label; // e.g. "Jan"
  final int year;
  final int month;
  final int count;

  const MonthlyCount({
    required this.label,
    required this.year,
    required this.month,
    required this.count,
  });
}

// ── States ─────────────────────────────────────────────────────────────────

sealed class OwnerAnalyticsState {
  const OwnerAnalyticsState();
}

final class OwnerAnalyticsInitial extends OwnerAnalyticsState {
  const OwnerAnalyticsInitial();
}

final class OwnerAnalyticsLoading extends OwnerAnalyticsState {
  const OwnerAnalyticsLoading();
}

final class OwnerAnalyticsLoaded extends OwnerAnalyticsState {
  final OwnerAnalyticsData data;
  const OwnerAnalyticsLoaded(this.data);
}

final class OwnerAnalyticsError extends OwnerAnalyticsState {
  final String message;
  const OwnerAnalyticsError(this.message);
}
