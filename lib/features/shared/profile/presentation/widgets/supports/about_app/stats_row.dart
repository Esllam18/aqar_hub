import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.home_work_rounded, '10K+', 'about_stat_listings'),
      (Icons.people_rounded, '5K+', 'about_stat_users'),
      (Icons.star_rounded, '4.8', 'about_stat_rating'),
    ];
    return Row(
      children: stats.map((s) {
        final (icon, value, key) = s;
        return Expanded(
          child: Container(
            margin: context.rSymmetric(horizontal: 4),
            padding: context.rSymmetric(horizontal: 8, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(14)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: context.r(22)),
                SizedBox(height: context.r(6)),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  key.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10),
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
