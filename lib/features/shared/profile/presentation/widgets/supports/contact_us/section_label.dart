import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: context.r(4),
        height: context.r(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      SizedBox(width: context.r(8)),
      Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: context.sp(14),
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade700,
        ),
      ),
    ],
  );
}
