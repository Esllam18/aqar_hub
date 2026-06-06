import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A consistent section label with a primary-coloured left accent bar.
/// Used across help_center and contact_us screens.
class HelpSectionLabel extends StatelessWidget {
  final String label;

  const HelpSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.r(4),
          height: context.r(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B4B8C), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(context.r(4)),
          ),
        ),
        SizedBox(width: context.r(10)),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2D5E),
          ),
        ),
      ],
    );
  }
}
