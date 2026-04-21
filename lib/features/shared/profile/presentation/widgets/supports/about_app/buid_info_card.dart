import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildInfoCard extends StatelessWidget {
  final String version;
  const BuildInfoCard({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          _BuildRow(
            label: 'about_version_label'.tr(context),
            value: 'v$version',
            valueColor: AppColors.primary,
          ),
          Divider(height: context.r(20), color: Colors.grey.shade100),
          _BuildRow(
            label: 'about_platform_label'.tr(context),
            value: 'Android & iOS',
            valueColor: Colors.grey.shade700,
          ),
          Divider(height: context.r(20), color: Colors.grey.shade100),
          _BuildRow(
            label: 'about_developer_label'.tr(context),
            value: 'AqarHub Team',
            valueColor: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }
}

class _BuildRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _BuildRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(13),
            color: Colors.grey.shade500,
          ),
        ),
        Container(
          padding: context.rSymmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: valueColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(context.r(20)),
          ),
          child: Text(
            value,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(12),
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
