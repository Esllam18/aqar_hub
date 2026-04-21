// lib/features/owner/home/presentation/widgets/owner_home/dashboard/owner_revenue_banner.dart
// Revenue summary banner — shows total portfolio value & alert count.

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerRevenueBanner extends StatelessWidget {
  final double totalRevenue;
  final int alertsCount;

  const OwnerRevenueBanner({
    super.key,
    required this.totalRevenue,
    required this.alertsCount,
  });

  String _formatPrice(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.rOnly(left: 16, right: 16, top: 14, bottom: 2),
      padding: context.rSymmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2D5E), Color(0xFF1565C0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'owner_portfolio_value'.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(11),
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),
                SizedBox(height: context.r(2)),
                Text(
                  '${_formatPrice(totalRevenue)} ${'currency_egp'.tr(context)}',
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(22),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (alertsCount > 0)
            Container(
              padding: context.rSymmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.22),
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(
                  color: Colors.orangeAccent.withOpacity(0.50),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orangeAccent,
                    size: 16,
                  ),
                  SizedBox(width: context.r(4)),
                  Text(
                    '$alertsCount ${'owner_stats_alerts'.tr(context)}',
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(11),
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w700,
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
