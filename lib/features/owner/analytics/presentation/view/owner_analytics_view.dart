// lib/features/owner/analytics/presentation/view/owner_analytics_view.dart
//
// Full Owner Analytics / Statistics screen.
// Data is fetched directly from Supabase properties + rental_options.
// No external chart library required — all charts are drawn with CustomPaint.

// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/analytics/presentation/cubit/owner_analytics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: context.r(14)),
        Text(
          'analytics_loading'.tr(context),
          style: GoogleFonts.tajawal(
            fontSize: context.sp(13),
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
          Icon(
            Icons.error_outline_rounded,
            size: context.r(48),
            color: AppColors.error,
          ),
          SizedBox(height: context.r(12)),
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

  @override
  Widget build(BuildContext context) {
    if (data.totalProperties == 0) {
      return _EmptyAnalytics();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<OwnerAnalyticsCubit>().refresh(),
      child: ListView(
        padding: context.rOnly(bottom: 40),
        children: [
          // ── Hero Banner ─────────────────────────────────────────────────
          _HeroBanner(data: data, formatPrice: _fmt),

          // ── KPI Grid ────────────────────────────────────────────────────
          _SectionTitle(title: 'analytics_overview'.tr(context)),
          _KpiGrid(data: data),

          // ── Listing Type Split ───────────────────────────────────────────
          _SectionTitle(title: 'analytics_listing_split'.tr(context)),
          _ListingTypeSplit(data: data),

          // ── Monthly Trend ────────────────────────────────────────────────
          _SectionTitle(title: 'analytics_monthly_trend'.tr(context)),
          _MonthlyBarChart(months: data.listingsByMonth),

          // ── Property Type Breakdown ──────────────────────────────────────
          if (data.byPropertyType.isNotEmpty) ...[
            _SectionTitle(title: 'analytics_property_types'.tr(context)),
            _DonutChart(
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
          ],

          // ── City Breakdown ───────────────────────────────────────────────
          if (data.byCity.isNotEmpty) ...[
            _SectionTitle(title: 'analytics_by_city'.tr(context)),
            _CityList(byCity: data.byCity, total: data.totalProperties),
          ],

          // ── Furnished Split ──────────────────────────────────────────────
          _SectionTitle(title: 'analytics_furnished'.tr(context)),
          _FurnishedSplit(
            furnished: data.furnished,
            unfurnished: data.unfurnished,
          ),

          SizedBox(height: context.r(20)),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    return switch (type) {
      'apartment' => AppColors.primary,
      'villa' => AppColors.success,
      'studio' => AppColors.info,
      'penthouse' => const Color(0xFF9333EA),
      'duplex' => AppColors.warning,
      'chalet' => const Color(0xFFEC4899),
      _ => AppColors.textSecondary,
    };
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: context.rAll(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: context.r(72),
            color: Colors.grey.shade300,
          ),
          SizedBox(height: context.r(16)),
          Text(
            'analytics_empty_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final OwnerAnalyticsData data;
  final String Function(double) formatPrice;
  const _HeroBanner({required this.data, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.rOnly(left: 16, right: 16, top: 16, bottom: 4),
      padding: context.rSymmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2D5E), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.r(20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: context.rAll(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: context.r(20),
                ),
              ),
              SizedBox(width: context.r(10)),
              Text(
                'analytics_portfolio_value'.tr(context),
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(13),
                  color: Colors.white.withOpacity(0.80),
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(12)),
          Text(
            '${formatPrice(data.totalPortfolioValue)} ${'currency_egp'.tr(context)}',
            style: GoogleFonts.cairo(
              fontSize: context.sp(28),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: context.r(4)),
          Text(
            '${data.totalProperties} ${'analytics_properties_total'.tr(context)}',
            style: GoogleFonts.tajawal(
              fontSize: context.sp(12),
              color: Colors.white.withOpacity(0.70),
            ),
          ),
          SizedBox(height: context.r(14)),
          Row(
            children: [
              _HeroChip(
                icon: Icons.trending_up_rounded,
                label:
                    '${formatPrice(data.totalRentValue)} ${'analytics_rent_value'.tr(context)}',
                color: const Color(0xFF34D399),
              ),
              SizedBox(width: context.r(8)),
              _HeroChip(
                icon: Icons.sell_rounded,
                label:
                    '${formatPrice(data.totalSaleValue)} ${'analytics_sale_value'.tr(context)}',
                color: const Color(0xFFFBBF24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: context.rSymmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(context.r(8)),
      border: Border.all(color: color.withOpacity(0.40)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: context.r(12), color: color),
        SizedBox(width: context.r(4)),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: context.sp(10),
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.rOnly(left: 20, right: 20, top: 22, bottom: 10),
    child: Row(
      children: [
        Container(
          width: context.r(4),
          height: context.r(18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: context.r(8)),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: context.sp(14),
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
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
        color: AppColors.primary,
      ),
      _KpiItem(
        icon: Icons.check_circle_outline_rounded,
        label: 'analytics_kpi_available'.tr(context),
        value: '${data.availableProperties}',
        color: AppColors.success,
      ),
      _KpiItem(
        icon: Icons.lock_clock_rounded,
        label: 'analytics_kpi_rented'.tr(context),
        value: '${data.rentedProperties}',
        color: AppColors.warning,
      ),
      _KpiItem(
        icon: Icons.home_work_rounded,
        label: 'analytics_kpi_rent'.tr(context),
        value: '${data.rentProperties}',
        color: AppColors.info,
      ),
      _KpiItem(
        icon: Icons.sell_rounded,
        label: 'analytics_kpi_sale'.tr(context),
        value: '${data.saleProperties}',
        color: const Color(0xFF9333EA),
      ),
      _KpiItem(
        icon: Icons.chair_rounded,
        label: 'analytics_kpi_furnished'.tr(context),
        value: '${data.furnished}',
        color: const Color(0xFFEC4899),
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
          childAspectRatio: 1.0,
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
      borderRadius: BorderRadius.circular(context.r(16)),
      boxShadow: AppShadows.soft,
    ),
    padding: context.rAll(12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: context.r(36),
          height: context.r(36),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(context.r(10)),
          ),
          child: Icon(item.icon, color: item.color, size: context.r(18)),
        ),
        SizedBox(height: context.r(8)),
        Text(
          item.value,
          style: GoogleFonts.cairo(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1B2D5E),
          ),
        ),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(9),
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
      padding: context.rAll(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: AppShadows.soft,
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
                  color: AppColors.info,
                ),
              ),
              SizedBox(width: context.r(12)),
              Expanded(
                child: _SplitCard(
                  icon: Icons.sell_rounded,
                  label: 'home_filter_sale'.tr(context),
                  count: data.saleProperties,
                  pct: salePct,
                  color: const Color(0xFF9333EA),
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(16)),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(context.r(4)),
            child: SizedBox(
              height: context.r(8),
              child: Row(
                children: [
                  Flexible(
                    flex: data.rentProperties,
                    child: Container(color: AppColors.info),
                  ),
                  Flexible(
                    flex: data.saleProperties,
                    child: Container(color: const Color(0xFF9333EA)),
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
    padding: context.rAll(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(context.r(12)),
    ),
    child: Row(
      children: [
        Container(
          width: context.r(34),
          height: context.r(34),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(context.r(9)),
          ),
          child: Icon(icon, color: color, size: context.r(17)),
        ),
        SizedBox(width: context.r(8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: context.sp(18),
                fontWeight: FontWeight.w900,
                color: color,
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
      ],
    ),
  );
}

// ── Monthly Bar Chart ─────────────────────────────────────────────────────────
// Converts a month number string ("1".."12") to a short localized month name.
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
      padding: context.rAll(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          SizedBox(
            height: context.r(120),
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
                          Text(
                            '${m.count}',
                            style: GoogleFonts.cairo(
                              fontSize: context.sp(9),
                              fontWeight: FontWeight.w700,
                              color: isMax
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        SizedBox(height: context.r(2)),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: context.r(90) * fraction.clamp(0.05, 1.0),
                          decoration: BoxDecoration(
                            color: isMax
                                ? AppColors.primary
                                : AppColors.primary.withOpacity(0.25),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(context.r(6)),
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
          SizedBox(height: context.r(8)),
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
      padding: context.rAll(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          SizedBox(
            height: context.r(140),
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
                        padding: context.rOnly(bottom: 8),
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
                            SizedBox(width: context.r(6)),
                            Expanded(
                              child: Text(
                                s.label,
                                style: GoogleFonts.tajawal(
                                  fontSize: context.sp(10.5),
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: GoogleFonts.cairo(
                                fontSize: context.sp(10),
                                fontWeight: FontWeight.w700,
                                color: s.color,
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
    final innerRadius = radius * 0.55;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -3.14159 / 2; // Start at top

    for (final slice in slices) {
      if (slice.value == 0) continue;
      final sweepAngle = (slice.value / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // Draw inner circle (donut hole)
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, holePaint);

    // Center text: total
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${total.toInt()}',
        style: const TextStyle(
          color: Color(0xFF1B2D5E),
          fontSize: 18,
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

class _CityList extends StatelessWidget {
  final Map<String, int> byCity;
  final int total;
  const _CityList({required this.byCity, required this.total});

  @override
  Widget build(BuildContext context) {
    final sorted = byCity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    return Container(
      margin: context.rSymmetric(horizontal: 16),
      padding: context.rAll(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: top.asMap().entries.map((entry) {
          final i = entry.key;
          final city = entry.value;
          final pct = total == 0 ? 0.0 : city.value / total;

          return Padding(
            padding: context.rOnly(bottom: i < top.length - 1 ? 12 : 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: context.r(26),
                      height: context.r(26),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(context.r(7)),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(11),
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: context.r(10)),
                    Expanded(
                      child: Text(
                        city.key,
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${city.value}',
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: context.r(6)),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(10),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.r(6)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.r(4)),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: context.r(5),
                    backgroundColor: AppColors.primary.withOpacity(0.08),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
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
      padding: context.rAll(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FurnishedChip(
                  label: 'analytics_furnished_yes'.tr(context),
                  count: furnished,
                  color: AppColors.success,
                  icon: Icons.chair_rounded,
                ),
              ),
              SizedBox(width: context.r(10)),
              Expanded(
                child: _FurnishedChip(
                  label: 'analytics_furnished_no'.tr(context),
                  count: unfurnished,
                  color: AppColors.textSecondary,
                  icon: Icons.chair_alt_rounded,
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(14)),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.r(4)),
            child: SizedBox(
              height: context.r(8),
              child: Row(
                children: [
                  Flexible(
                    flex: furnished,
                    child: Container(color: AppColors.success),
                  ),
                  Flexible(
                    flex: unfurnished,
                    child: Container(color: Colors.grey.shade200),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.r(8)),
          Text(
            '${(furnPct * 100).toStringAsFixed(0)}% ${'analytics_furnished_pct'.tr(context)}',
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FurnishedChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _FurnishedChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: context.rAll(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(context.r(12)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: context.r(20)),
        SizedBox(width: context.r(8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: context.sp(18),
                fontWeight: FontWeight.w900,
                color: color,
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
