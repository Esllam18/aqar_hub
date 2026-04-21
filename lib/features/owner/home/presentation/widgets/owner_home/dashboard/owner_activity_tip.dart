// lib/features/owner/home/presentation/widgets/owner_home/dashboard/owner_activity_tip.dart
// Contextual tip card — shows a different tip based on portfolio state.

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerActivityTip extends StatelessWidget {
  final int total;
  final int alerts;
  final int available;

  const OwnerActivityTip({
    super.key,
    required this.total,
    required this.alerts,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    final tip = _selectTip(context);
    return Container(
      margin: context.rOnly(left: 16, right: 16, top: 4, bottom: 2),
      padding: context.rSymmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tip.bgColor,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: tip.borderColor),
      ),
      child: Row(
        children: [
          Icon(tip.icon, color: tip.iconColor, size: context.r(20)),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Text(
              tip.message,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12),
                color: tip.textColor,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _Tip _selectTip(BuildContext context) {
    if (alerts > 0) {
      return _Tip(
        message: 'tip_has_alerts'.tr(context),
        icon: Icons.warning_amber_rounded,
        bgColor: const Color(0xFFFFF8E1),
        borderColor: AppColors.warning.withOpacity(0.35),
        iconColor: AppColors.warning,
        textColor: const Color(0xFF7B5800),
      );
    }
    if (total == 0) {
      return _Tip(
        message: 'tip_no_properties'.tr(context),
        icon: Icons.lightbulb_outline_rounded,
        bgColor: const Color(0xFFE8F4FD),
        borderColor: AppColors.info.withOpacity(0.35),
        iconColor: AppColors.info,
        textColor: const Color(0xFF0D3B6E),
      );
    }
    if (available == 0) {
      return _Tip(
        message: 'tip_all_rented'.tr(context),
        icon: Icons.celebration_rounded,
        bgColor: const Color(0xFFE8F5E9),
        borderColor: AppColors.success.withOpacity(0.35),
        iconColor: AppColors.success,
        textColor: const Color(0xFF1B5E20),
      );
    }
    return _Tip(
      message: 'owner_guide_body'.tr(context),
      icon: Icons.tips_and_updates_rounded,
      bgColor: const Color(0xFFE8EFF9),
      borderColor: AppColors.primary.withOpacity(0.25),
      iconColor: AppColors.primary,
      textColor: const Color(0xFF1B2D5E),
    );
  }
}

class _Tip {
  final String message;
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  const _Tip({
    required this.message,
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}
