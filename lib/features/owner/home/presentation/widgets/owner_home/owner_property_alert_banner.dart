// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:aqar_hub/features/owner/home/data/models/property_alert_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerPropertyAlertBanner extends StatelessWidget {
  final PropertyAlertModel alert;

  const OwnerPropertyAlertBanner({super.key, required this.alert});

  Color get _color {
    switch (alert.severity) {
      case PropertyAlertSeverity.success:
        return AppColors.success;
      case PropertyAlertSeverity.info:
        return AppColors.info;
      case PropertyAlertSeverity.warning:
        return AppColors.warning;
      case PropertyAlertSeverity.error:
        return AppColors.error;
    }
  }

  IconData get _icon {
    switch (alert.code) {
      case 'rented':
        return Icons.lock_clock_rounded;
      case 'verified':
        return Icons.verified_rounded;
      case 'offer':
        return Icons.local_offer_rounded;
      case 'fullyBooked':
        return Icons.event_busy_rounded;
      case 'limited':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _message(BuildContext context) {
    switch (alert.code) {
      case 'rented':
        return 'property_rented'.tr(context);

      case 'verified':
        return 'badge_verified'.tr(context);

      case 'offer':
        return 'badge_offer'.tr(context);

      case 'fullyBooked':
        final type = PropertyHelpers.rentalTypeLabel(
          alert.rentalType ?? 'apartment',
          context,
        );
        return 'owner_alert_fully_booked'.trArgs(context, {'type': type});

      case 'limited':
        final type = PropertyHelpers.rentalTypeLabel(
          alert.rentalType ?? 'apartment',
          context,
        );
        return 'owner_alert_limited'.trArgs(context, {
          'count': alert.remaining ?? 0,
          'type': type,
        });

      default:
        return 'owner_alert_available'.tr(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      margin: context.rOnly(bottom: 8),
      padding: context.rSymmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: context.r(28),
            height: context.r(28),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(context.r(9)),
            ),
            child: Icon(_icon, size: context.r(16), color: color),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Text(
              _message(context),
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11.5),
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.95),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
