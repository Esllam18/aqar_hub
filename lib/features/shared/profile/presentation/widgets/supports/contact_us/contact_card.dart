import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactCard extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String titleKey;
  final String valueKey;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const ContactCard({
    super.key,
    required this.icon,
    required this.gradient,
    required this.titleKey,
    required this.valueKey,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.rAll(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: context.r(50),
              height: context.r(50),
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
                  Row(
                    children: [
                      Text(
                        titleKey.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(14),
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(width: context.r(8)),
                      Container(
                        padding: context.rSymmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(context.r(20)),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(10),
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    valueKey.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: context.r(13),
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
