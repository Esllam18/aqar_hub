// lib/features/owner/home/presentation/widgets/owner_home/dashboard/owner_kpi_row.dart
// 4-card KPI row: total listings, available, rented, for-sale.

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerKpiRow extends StatelessWidget {
  final int total;
  final int available;
  final int rented;
  final int sale;

  const OwnerKpiRow({
    super.key,
    required this.total,
    required this.available,
    required this.rented,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(
        label: 'owner_stats_listings'.tr(context),
        value: total,
        icon: Icons.apartment_rounded,
        color: AppColors.primary,
      ),
      _KpiCard(
        label: 'owner_kpi_available'.tr(context),
        value: available,
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.success,
      ),
      _KpiCard(
        label: 'property_rented'.tr(context),
        value: rented,
        icon: Icons.lock_clock_rounded,
        color: AppColors.warning,
      ),
      _KpiCard(
        label: 'home_filter_sale'.tr(context),
        value: sale,
        icon: Icons.sell_rounded,
        color: AppColors.info,
      ),
    ];

    return Padding(
      padding: context.rOnly(left: 16, right: 16, top: 14, bottom: 4),
      child: Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: context.rSymmetric(horizontal: 4),
                  child: c,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rAll(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.r(34),
            height: context.r(34),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(icon, color: color, size: context.r(18)),
          ),
          SizedBox(height: context.r(6)),
          Text(
            '$value',
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          Text(
            label,
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
}
