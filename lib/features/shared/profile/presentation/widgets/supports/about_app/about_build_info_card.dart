import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium build info card shown at the bottom of the About screen.
/// Drop-in replacement for the old BuildInfoCard widget.
class AboutBuildInfoCard extends StatelessWidget {
  final String version;
  const AboutBuildInfoCard({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        icon: Icons.tag_rounded,
        labelKey: 'about_version_label',
        value: 'v$version',
        valueColor: AppColors.primary,
      ),
      (
        icon: Icons.smartphone_rounded,
        labelKey: 'about_platform_label',
        value: 'Android & iOS',
        valueColor: Colors.grey.shade700,
      ),
      (
        icon: Icons.person_outline_rounded,
        labelKey: 'about_developer_label',
        value: 'Eslam Maher',
        valueColor: Colors.grey.shade700,
      ),
      (
        icon: Icons.translate_rounded,
        labelKey: 'about_languages_label',
        value: 'العربية · English',
        valueColor: Colors.grey.shade700,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: context.rSymmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4B8C), Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.r(18)),
                topRight: Radius.circular(context.r(18)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: context.r(18),
                ),
                SizedBox(width: context.r(10)),
                Text(
                  'about_build_title'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Rows
          Padding(
            padding: context.rAll(16),
            child: Column(
              children: rows.asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;
                return Column(
                  children: [
                    _BuildRow(
                      icon: row.icon,
                      label: row.labelKey.tr(context),
                      value: row.value,
                      valueColor: row.valueColor,
                    ),
                    if (i < rows.length - 1)
                      Divider(
                        height: context.r(20),
                        color: Colors.grey.shade100,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _BuildRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: context.r(16), color: Colors.grey.shade400),
        SizedBox(width: context.r(8)),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(13),
            color: Colors.grey.shade500,
          ),
        ),
        const Spacer(),
        Container(
          padding: context.rSymmetric(horizontal: 10, vertical: 4),
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
