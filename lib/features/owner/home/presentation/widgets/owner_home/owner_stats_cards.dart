// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerStatsCards extends StatelessWidget {
  final int total;
  final int sale;
  final int rented;
  final int alerts;

  const OwnerStatsCards({
    super.key,
    required this.total,
    required this.sale,
    required this.rented,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        title: 'owner_stats_listings'.tr(context),
        value: '$total',
        icon: Icons.apartment_rounded,
      ),
      _StatItem(
        title: 'home_filter_sale'.tr(context),
        value: '$sale',
        icon: Icons.sell_rounded,
      ),
      _StatItem(
        title: 'property_rented'.tr(context),
        value: '$rented',
        icon: Icons.lock_clock_rounded,
      ),
      _StatItem(
        title: 'owner_stats_alerts'.tr(context),
        value: '$alerts',
        icon: Icons.notifications_active_rounded,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: context.r(10),
        mainAxisSpacing: context.r(10),
        childAspectRatio: 1.8,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return Container(
          padding: context.rAll(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: context.r(16),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: context.r(42),
                height: context.r(42),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.14),
                      AppColors.secondary.withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(context.r(13)),
                ),
                child: Icon(item.icon, color: AppColors.primary),
              ),
              SizedBox(width: context.r(10)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.value,
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(17),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B2D5E),
                      ),
                    ),
                    SizedBox(height: context.r(2)),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(10.8),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });
}
