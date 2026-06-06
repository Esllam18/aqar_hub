import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium information card used in the About screen.
/// Drop-in replacement for the old InfoCard widget.
class AboutInfoCard extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String titleKey;
  final String bodyKey;

  const AboutInfoCard({
    super.key,
    required this.icon,
    required this.gradient,
    required this.titleKey,
    required this.bodyKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.09),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.r(48),
            height: context.r(48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
            child: Icon(icon, color: Colors.white, size: context.r(22)),
          ),
          SizedBox(width: context.r(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKey.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(14),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2D5E),
                  ),
                ),
                SizedBox(height: context.r(5)),
                Text(
                  bodyKey.tr(context),
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
