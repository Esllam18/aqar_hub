import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Working hours info card shown on the Contact Us screen.
class ContactHoursCard extends StatelessWidget {
  const ContactHoursCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if currently within working hours (Sun–Thu 9–18, Fri–Sat 10–16)
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon … 7=Sun
    final hour = now.hour;
    final bool isOpen = () {
      // Sun = 7, Mon-Thu = 1-4
      if (weekday <= 4) return hour >= 9 && hour < 18;
      if (weekday == 7) return hour >= 9 && hour < 18;
      return hour >= 10 && hour < 16;
    }();

    return Container(
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        border: Border.all(
          color: isOpen
              ? const Color(0xFF16A34A).withValues(alpha: 0.25)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.r(46),
            height: context.r(46),
            decoration: BoxDecoration(
              color: isOpen
                  ? const Color(0xFF16A34A).withValues(alpha: 0.10)
                  : AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(context.r(13)),
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: isOpen ? const Color(0xFF16A34A) : AppColors.primary,
              size: context.r(22),
            ),
          ),
          SizedBox(width: context.r(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'contact_hours_title'.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B2D5E),
                      ),
                    ),
                    SizedBox(width: context.r(8)),
                    Container(
                      padding: context.rSymmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(context.r(20)),
                      ),
                      child: Text(
                        isOpen
                            ? 'contact_status_open'.tr(context)
                            : 'contact_status_closed'.tr(context),
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(10),
                          fontWeight: FontWeight.w700,
                          color: isOpen
                              ? const Color(0xFF16A34A)
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.r(4)),
                Text(
                  'contact_hours_value'.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(13),
                    color: Colors.grey.shade600,
                    height: 1.7,
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
