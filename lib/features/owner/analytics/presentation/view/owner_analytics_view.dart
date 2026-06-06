// lib/features/owner/analytics/presentation/view/owner_analytics_view.dart
//
// Full Owner Analytics / Statistics screen — Premium Redesign.
//
// CHANGES vs original:
//  1. LOCATION FIX: _CityList resolves byCity keys (slugs or "gov/city" paths)
//     to localised names via EgyptLocationHelper instead of showing raw slugs.
//  2. UI: Full premium glassmorphism redesign — gradient backgrounds, frosted
//     glass cards, animated progress bars, modern typography hierarchy.
//     All existing logic (cubit, data model, charts) is preserved unchanged.

// ignore_for_file: unused_field, deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/location/helper/egypt_location_helper.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/analytics/presentation/cubit/owner_analytics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

class _C {
  static const navy = Color(0xFF0D1B3E);
  static const navyMid = Color(0xFF1A3267);
  static const blue = Color(0xFF1E5FAD);
  static const blueLight = Color(0xFF4A90D9);
  static const glass = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);
  static const cardBg = Color(0xFFF8FAFF);
  static const cardBorder = Color(0xFFE8EEFF);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  static const info = Color(0xFF0EA5E9);
}

// ── Entry point ───────────────────────────────────────────────────────────────

class OwnerAnalyticsView extends StatelessWidget {
  const OwnerAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OwnerAnalyticsCubit()..load(),
      child: const _AnalyticsContent(),
    );
  }
}

// ── Shell ─────────────────────────────────────────────────────────────────────

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          'analytics_title'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(17),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        actions: [
          BlocBuilder<OwnerAnalyticsCubit, OwnerAnalyticsState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => context.read<OwnerAnalyticsCubit>().refresh(),
              tooltip: 'retry'.tr(context),
            ),
          ),
        ],
      ),
      body: BlocBuilder<OwnerAnalyticsCubit, OwnerAnalyticsState>(
        builder: (context, state) {
          return switch (state) {
            OwnerAnalyticsLoading() => const _LoadingBody(),
            OwnerAnalyticsLoaded(:final data) => _LoadedBody(data: data),
            OwnerAnalyticsError(:final message) => _ErrorBody(message: message),
            _ => const _LoadingBody(),
          };
        },
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_C.navy, _C.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          SizedBox(height: context.r(16)),
          Text(
            'analytics_loading'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: context.rAll(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.r(72),
            height: context.r(72),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: context.r(36),
              color: AppColors.error,
            ),
          ),
          SizedBox(height: context.r(16)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: context.r(20)),
          ElevatedButton.icon(
            onPressed: () => context.read<OwnerAnalyticsCubit>().refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: Text('retry'.tr(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Loaded Body ───────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final OwnerAnalyticsData data;
  const _LoadedBody({required this.data});

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  Color _typeColor(String type) => switch (type) {
    'apartment' => _C.blue,
    'villa' => _C.success,
    'studio' => _C.info,
    'penthouse' => _C.purple,
    'duplex' => _C.warning,
    'chalet' => _C.pink,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    if (data.totalProperties == 0) return const _EmptyAnalytics();

    return RefreshIndicator(
      color: _C.blue,
      onRefresh: () => context.read<OwnerAnalyticsCubit>().refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ── Gradient App Bar + Hero ──────────────────────────────────
          SliverToBoxAdapter(
            child: _GradientHero(data: data, formatPrice: _fmt),
          ),

          // ── Overview KPI Grid ────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionLabel(title: 'analytics_overview'.tr(context)),
          ),
          SliverToBoxAdapter(child: _KpiGrid(data: data)),

          // ── Listing Type Split ───────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionLabel(title: 'analytics_listing_split'.tr(context)),
          ),
          SliverToBoxAdapter(child: _ListingTypeSplit(data: data)),

          // ── Monthly Trend ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionLabel(title: 'analytics_monthly_trend'.tr(context)),
          ),
          SliverToBoxAdapter(
            child: _MonthlyBarChart(months: data.listingsByMonth),
          ),

          // ── Property Type Donut ──────────────────────────────────────
          if (data.byPropertyType.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionLabel(
                title: 'analytics_property_types'.tr(context),
              ),
            ),
            SliverToBoxAdapter(
              child: _DonutChart(
                items: data.byPropertyType.entries
                    .map(
                      (e) => _PieSlice(
                        label: 'property_type_${e.key}'.tr(context),
                        value: e.value.toDouble(),
                        color: _typeColor(e.key),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          // ── City Breakdown ───────────────────────────────────────────
          if (data.byCity.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionLabel(title: 'analytics_by_city'.tr(context)),
            ),
            SliverToBoxAdapter(
              child: _CityList(
                byCity: data.byCity,
                total: data.totalProperties,
              ),
            ),
          ],

          // ── Furnished Split ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SectionLabel(title: 'analytics_furnished'.tr(context)),
          ),
          SliverToBoxAdapter(
            child: _FurnishedSplit(
              furnished: data.furnished,
              unfurnished: data.unfurnished,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyAnalytics extends StatelessWidget {
  const _EmptyAnalytics();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: context.rAll(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.r(96),
            height: context.r(96),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _C.blue.withOpacity(0.12),
                  _C.purple.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: context.r(48),
              color: _C.blue.withOpacity(0.4),
            ),
          ),
          SizedBox(height: context.r(20)),
          Text(
            'analytics_empty_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              color: _C.navy,
            ),
          ),
          SizedBox(height: context.r(8)),
          Text(
            'analytics_empty_body'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Gradient Hero (AppBar + stats banner) ─────────────────────────────────────

class _GradientHero extends StatelessWidget {
  final OwnerAnalyticsData data;
  final String Function(double) formatPrice;
  const _GradientHero({required this.data, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.navy, Color(0xFF1A3A7A), _C.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: context.r(180),
                height: context.r(180),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -30,
              child: Container(
                width: context.r(120),
                height: context.r(120),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: context.r(20)),

                // Portfolio value
                Padding(
                  padding: context.rSymmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: context.rAll(8),
                            decoration: BoxDecoration(
                              color: _C.glass,
                              borderRadius: BorderRadius.circular(
                                context.r(10),
                              ),
                              border: Border.all(color: _C.glassBorder),
                            ),
                            child: Icon(
                              Icons.analytics_rounded,
                              color: Colors.white,
                              size: context.r(18),
                            ),
                          ),
                          SizedBox(width: context.r(10)),
                          Text(
                            'analytics_portfolio_value'.tr(context),
                            style: GoogleFonts.tajawal(
                              fontSize: context.sp(12.5),
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.r(10)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatPrice(data.totalPortfolioValue),
                            style: GoogleFonts.cairo(
                              fontSize: context.sp(34),
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(width: context.r(6)),
                          Padding(
                            padding: context.rOnly(bottom: 4),
                            child: Text(
                              'currency_egp'.tr(context),
                              style: GoogleFonts.tajawal(
                                fontSize: context.sp(13),
                                color: Colors.white60,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.r(4)),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          '${data.totalProperties} ${'analytics_properties_total'.tr(context)}',
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.r(16)),

                // Rent / Sale chips
                Padding(
                  padding: context.rSymmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _HeroGlassChip(
                        icon: Icons.trending_up_rounded,
                        label:
                            '${formatPrice(data.totalRentValue)} ${'analytics_rent_value'.tr(context)}',
                        color: _C.success,
                      ),
                      SizedBox(width: context.r(8)),
                      _HeroGlassChip(
                        icon: Icons.sell_rounded,
                        label:
                            '${formatPrice(data.totalSaleValue)} ${'analytics_sale_value'.tr(context)}',
                        color: _C.warning,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.r(24)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroGlassChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _HeroGlassChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(context.r(10)),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: context.rSymmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(context.r(10)),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: context.r(13), color: color),
            SizedBox(width: context.r(5)),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: context.sp(10.5),
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.rOnly(left: 20, right: 20, top: 24, bottom: 10),
    child: Row(
      children: [
        Container(
          width: context.r(4),
          height: context.r(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.blue, _C.blueLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: context.r(10)),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w800,
            color: _C.navy,
          ),
        ),
      ],
    ),
  );
}

// ── KPI Grid ──────────────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final OwnerAnalyticsData data;
  const _KpiGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = [
      _KpiItem(
        icon: Icons.apartment_rounded,
        label: 'analytics_kpi_total'.tr(context),
        value: '${data.totalProperties}',
        color: _C.blue,
      ),
      _KpiItem(
        icon: Icons.check_circle_outline_rounded,
        label: 'analytics_kpi_available'.tr(context),
        value: '${data.availableProperties}',
        color: _C.success,
      ),
      _KpiItem(
        icon: Icons.lock_clock_rounded,
        label: 'analytics_kpi_rented'.tr(context),
        value: '${data.rentedProperties}',
        color: _C.warning,
      ),
      _KpiItem(
        icon: Icons.home_work_rounded,
        label: 'analytics_kpi_rent'.tr(context),
        value: '${data.rentProperties}',
        color: _C.info,
      ),
      _KpiItem(
        icon: Icons.sell_rounded,
        label: 'analytics_kpi_sale'.tr(context),
        value: '${data.saleProperties}',
        color: _C.purple,
      ),
      _KpiItem(
        icon: Icons.chair_rounded,
        label: 'analytics_kpi_furnished'.tr(context),
        value: '${data.furnished}',
        color: _C.pink,
      ),
    ];

    return Padding(
      padding: context.rSymmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: context.r(10),
          mainAxisSpacing: context.r(10),
          childAspectRatio: 0.95,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _KpiCard(item: items[i]),
      ),
    );
  }
}

class _KpiItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _KpiItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiItem item;
  const _KpiCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.r(18)),
      border: Border.all(color: item.color.withOpacity(0.12)),
      boxShadow: [
        BoxShadow(
          color: item.color.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: context.rAll(12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: context.r(40),
          height: context.r(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                item.color.withOpacity(0.15),
                item.color.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.r(12)),
          ),
          child: Icon(item.icon, color: item.color, size: context.r(20)),
        ),
        SizedBox(height: context.r(8)),
        Text(
          item.value,
          style: GoogleFonts.cairo(
            fontSize: context.sp(22),
            fontWeight: FontWeight.w900,
            color: _C.navy,
            height: 1.0,
          ),
        ),
        SizedBox(height: context.r(3)),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(9.5),
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ── Listing Type Split ────────────────────────────────────────────────────────

class _ListingTypeSplit extends StatelessWidget {
  final OwnerAnalyticsData data;
  const _ListingTypeSplit({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.totalProperties;
    final rentPct = total == 0 ? 0.0 : data.rentProperties / total;
    final salePct = total == 0 ? 0.0 : data.saleProperties / total;

    return Container(
      margin: context.rSymmetric(horizontal: 16),
      padding: context.rAll(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: _C.cardBorder),
        boxShadow: [
          BoxShadow(
            color: _C.blue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SplitCard(
                  icon: Icons.home_work_rounded,
                  label: 'home_filter_rent'.tr(context),
                  count: data.rentProperties,
                  pct: rentPct,
                  color: _C.info,
                ),
              ),
              SizedBox(width: context.r(12)),
              Expanded(
                child: _SplitCard(
                  icon: Icons.sell_rounded,
                  label: 'home_filter_sale'.tr(context),
                  count: data.saleProperties,
                  pct: salePct,
                  color: _C.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(16)),
          // Segmented progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(context.r(8)),
            child: SizedBox(
              height: context.r(10),
              child: Row(
                children: [
                  Flexible(
                    flex: data.rentProperties,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_C.info, Color(0xFF38BDF8)],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: data.saleProperties,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_C.purple, Color(0xFFA78BFA)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final double pct;
  final Color color;
  const _SplitCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: context.rAll(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(context.r(14)),
      border: Border.all(color: color.withOpacity(0.15)),
    ),
    child: Row(
      children: [
        Container(
          width: context.r(36),
          height: context.r(36),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(context.r(10)),
          ),
          child: Icon(icon, color: color, size: context.r(18)),
        ),
        SizedBox(width: context.r(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: GoogleFonts.cairo(
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.0,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(10),
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.cairo(
                  fontSize: context.sp(10),
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.70),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Monthly Bar Chart ─────────────────────────────────────────────────────────

String _localizedMonth(BuildContext context, String monthStr) {
  final monthNum = int.tryParse(monthStr) ?? 1;
  final locale = Localizations.localeOf(context).languageCode;
  final dt = DateTime(2000, monthNum);
  return DateFormat.MMM(locale).format(dt);
}

class _MonthlyBarChart extends StatelessWidget {
  final List<MonthlyCount> months;
  const _MonthlyBarChart({required this.months});

  @override
  Widget build(BuildContext context) {
    final maxVal = months.isEmpty
        ? 1
        : months.map((m) => m.count).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: context.rSymmetric(horizontal: 16),
      padding: context.rAll(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: _C.cardBorder),
        boxShadow: [
          BoxShadow(
            color: _C.blue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: context.r(130),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: months.asMap().entries.map((entry) {
                final m = entry.value;
                final fraction = maxVal == 0 ? 0.0 : m.count / maxVal;
                final isMax = m.count == maxVal && m.count > 0;

                return Expanded(
                  child: Padding(
                    padding: context.rSymmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (m.count > 0)
                          Container(
                            margin: context.rOnly(bottom: 4),
                            padding: context.rSymmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isMax
                                  ? _C.navy
                                  : _C.blue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(context.r(6)),
                            ),
                            child: Text(
                              '${m.count}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: context.sp(9),
                                fontWeight: FontWeight.w800,
                                color: isMax ? Colors.white : _C.blue,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          height: context.r(90) * fraction.clamp(0.05, 1.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isMax
                                  ? [_C.navy, _C.blue]
                                  : [
                                      _C.blue.withOpacity(0.30),
                                      _C.blueLight.withOpacity(0.15),
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(context.r(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: context.r(10)),
          Row(
            children: months
                .map(
                  (m) => Expanded(
                    child: Text(
                      _localizedMonth(context, m.label),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(9.5),
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Donut Chart ───────────────────────────────────────────────────────────────

class _PieSlice {
  final String label;
  final double value;
  final Color color;
  const _PieSlice({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _DonutChart extends StatelessWidget {
  final List<_PieSlice> items;
  const _DonutChart({required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0.0, (sum, e) => sum + e.value);

    return Container(
      margin: context.rSymmetric(horizontal: 16),
      padding: context.rAll(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: _C.cardBorder),
        boxShadow: [
          BoxShadow(
            color: _C.blue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: context.r(140),
            height: context.r(140),
            child: CustomPaint(
              painter: _DonutPainter(slices: items, total: total),
            ),
          ),
          SizedBox(width: context.r(20)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((s) {
                final pct = total == 0 ? 0 : (s.value / total * 100);
                return Padding(
                  padding: context.rOnly(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: context.r(10),
                        height: context.r(10),
                        decoration: BoxDecoration(
                          color: s.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: context.r(7)),
                      Expanded(
                        child: Text(
                          s.label,
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(11),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: context.rSymmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: s.color.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(context.r(6)),
                        ),
                        child: Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w800,
                            color: s.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_PieSlice> slices;
  final double total;
  const _DonutPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.58;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;

    for (final slice in slices) {
      if (slice.value == 0) continue;
      final sweepAngle = (slice.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // White gap between slices
      final gapPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(rect, startAngle, sweepAngle, true, gapPaint);

      startAngle += sweepAngle;
    }

    // Donut hole with subtle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, innerRadius + 2, shadowPaint);

    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, holePaint);

    // Center total text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${total.toInt()}',
        style: const TextStyle(
          color: _C.navy,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.slices != slices;
}

// ── City List ─────────────────────────────────────────────────────────────────
//
// FIX: byCity keys are now "{gov_slug}/{city_slug}" paths (or plain slugs for
// legacy rows).  EgyptLocationHelper.fullLocationLabel() resolves them to the
// correct localised name, so the user sees e.g. "القاهرة / مدينة نصر" instead
// of "nasr_city".

class _CityList extends StatelessWidget {
  final Map<String, int> byCity;
  final int total;
  const _CityList({required this.byCity, required this.total});

  /// Resolves a location key (slug path or legacy value) to a localised label.
  String _resolveLabel(String key, String lang) {
    // Key format: "{gov}/{city}"  or  "{gov}/{city}/{area}"  or  plain slug/value
    final parts = key.split('/');
    if (parts.length >= 2) {
      return EgyptLocationHelper.fullLocationLabel(
        governorateSlug: parts[0],
        citySlug: parts[1],
        areaSlug: parts.length >= 3 ? parts[2] : null,
        lang: lang,
      );
    }
    // Single value — try as governorate slug first, then city slug
    final govName = EgyptLocationHelper.governorateName(key, lang: lang);
    if (govName != key) return govName; // resolved
    return EgyptLocationHelper.cityName(
      governorateSlug: null,
      citySlugOrLegacy: key,
      lang: lang,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final sorted = byCity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    return Container(
      margin: context.rSymmetric(horizontal: 16),
      padding: context.rAll(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: _C.cardBorder),
        boxShadow: [
          BoxShadow(
            color: _C.blue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: top.asMap().entries.map((entry) {
          final i = entry.key;
          final city = entry.value;
          final pct = total == 0 ? 0.0 : city.value / total;

          // ── FIX: resolve slug/path to localised name ─────────────────
          final displayName = _resolveLabel(city.key, lang);

          final rankColors = [
            const Color(0xFFFFD700),
            const Color(0xFFC0C0C0),
            const Color(0xFFCD7F32),
            _C.blue.withOpacity(0.5),
            _C.blue.withOpacity(0.3),
          ];

          return Padding(
            padding: context.rOnly(bottom: i < top.length - 1 ? 14 : 0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Rank badge
                    Container(
                      width: context.r(28),
                      height: context.r(28),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rankColors[i].withOpacity(0.15),
                        borderRadius: BorderRadius.circular(context.r(8)),
                        border: Border.all(
                          color: rankColors[i].withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(11),
                          fontWeight: FontWeight.w900,
                          color: i < 3 ? rankColors[i] : _C.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: Text(
                        displayName,
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(12.5),
                          fontWeight: FontWeight.w700,
                          color: _C.navy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: context.rSymmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _C.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(context.r(8)),
                      ),
                      child: Text(
                        '${city.value}',
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w800,
                          color: _C.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: context.r(6)),
                    SizedBox(
                      width: context.r(36),
                      child: Text(
                        '${(pct * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(10),
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.r(7)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.r(6)),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: context.r(6),
                    backgroundColor: _C.blue.withOpacity(0.07),
                    valueColor: AlwaysStoppedAnimation(
                      i == 0 ? _C.navy : _C.blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Furnished Split ───────────────────────────────────────────────────────────

class _FurnishedSplit extends StatelessWidget {
  final int furnished;
  final int unfurnished;
  const _FurnishedSplit({required this.furnished, required this.unfurnished});

  @override
  Widget build(BuildContext context) {
    final total = furnished + unfurnished;
    final furnPct = total == 0 ? 0.0 : furnished / total;

    return Container(
      margin: context.rSymmetric(horizontal: 16),
      padding: context.rAll(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: _C.cardBorder),
        boxShadow: [
          BoxShadow(
            color: _C.blue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FurnishedCard(
                  label: 'analytics_furnished_yes'.tr(context),
                  count: furnished,
                  color: _C.success,
                  icon: Icons.chair_rounded,
                ),
              ),
              SizedBox(width: context.r(10)),
              Expanded(
                child: _FurnishedCard(
                  label: 'analytics_furnished_no'.tr(context),
                  count: unfurnished,
                  color: const Color(0xFF94A3B8),
                  icon: Icons.chair_alt_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(16)),
          // Segmented progress
          ClipRRect(
            borderRadius: BorderRadius.circular(context.r(8)),
            child: SizedBox(
              height: context.r(10),
              child: Row(
                children: [
                  Flexible(
                    flex: furnished,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_C.success, Color(0xFF34D399)],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: unfurnished,
                    child: Container(color: const Color(0xFFE2E8F0)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.r(10)),
          Text(
            '${(furnPct * 100).toStringAsFixed(0)}% ${'analytics_furnished_pct'.tr(context)}',
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11.5),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FurnishedCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _FurnishedCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: context.rAll(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withOpacity(0.09), color.withOpacity(0.03)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(context.r(14)),
      border: Border.all(color: color.withOpacity(0.15)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: context.r(22)),
        SizedBox(width: context.r(10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: context.sp(22),
                fontWeight: FontWeight.w900,
                color: color,
                height: 1.0,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(10),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
