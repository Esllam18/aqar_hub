import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrentLangBadge extends StatelessWidget {
  const CurrentLangBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF00897B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        isAr ? 'العربية' : 'English',
        style: GoogleFonts.tajawal(
          fontSize: context.sp(11),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF00897B),
        ),
      ),
    );
  }
}
