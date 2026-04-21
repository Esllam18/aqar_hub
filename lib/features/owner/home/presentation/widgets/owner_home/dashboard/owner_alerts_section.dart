// lib/features/owner/home/presentation/widgets/owner_home/dashboard/owner_alerts_section.dart
//
// Standalone alerts section — shown above properties list, not inside cards.
// Gives clear guidance to the owner about properties needing attention.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerAlertsSection extends StatelessWidget {
  final List<OwnerPropertyModel> properties;
  final VoidCallback onViewAll;

  const OwnerAlertsSection({
    super.key,
    required this.properties,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Collect all properties with alerts
    final alertProps = properties
        .where((p) => p.alerts.any((a) => a.code != 'available'))
        .toList();

    if (alertProps.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: context.rOnly(left: 16, right: 16, top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.08),
            blurRadius: context.r(16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: context.rOnly(left: 16, right: 12, top: 14, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: context.r(36),
                  height: context.r(36),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Icon(Icons.notifications_active_rounded,
                      color: AppColors.warning, size: context.r(20)),
                ),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'owner_alerts_title'.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(13.5),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF7B5800),
                        ),
                      ),
                      Text(
                        '${alertProps.length} ${'owner_alerts_properties'.tr(context)}',
                        style: GoogleFonts.tajawal(
                          fontSize: context.sp(11),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    'owner_alerts_view_all'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(11.5),
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // Alert rows — max 3 shown
          ...alertProps.take(3).map(
                (p) => _AlertRow(property: p),
              ),
          if (alertProps.length > 3)
            Padding(
              padding: context.rOnly(left: 16, right: 16, bottom: 12, top: 4),
              child: Text(
                '+${alertProps.length - 3} ${'owner_alerts_more'.tr(context)}',
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(11),
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          if (alertProps.length <= 3) SizedBox(height: context.r(4)),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final OwnerPropertyModel property;
  const _AlertRow({required this.property});

  @override
  Widget build(BuildContext context) {
    final alerts = property.alerts.where((a) => a.code != 'available').toList();
    final firstAlert = alerts.first;

    Color color;
    IconData icon;
    switch (firstAlert.code) {
      case 'fullyBooked':
        color = const Color(0xFFE53935);
        icon = Icons.event_busy_rounded;
        break;
      case 'limited':
        color = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case 'rented':
        color = AppColors.info;
        icon = Icons.lock_clock_rounded;
        break;
      default:
        color = AppColors.primary;
        icon = Icons.info_outline_rounded;
    }

    return Padding(
      padding: context.rOnly(left: 16, right: 16, top: 10, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: context.r(16), color: color),
          SizedBox(width: context.r(8)),
          Expanded(
            child: Text(
              property.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12.5),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B2D5E),
              ),
            ),
          ),
          SizedBox(width: context.r(8)),
          Container(
            padding: context.rSymmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Text(
              '${alerts.length} ${'owner_alerts_issues'.tr(context)}',
              style: GoogleFonts.tajawal(
                fontSize: context.sp(10),
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
