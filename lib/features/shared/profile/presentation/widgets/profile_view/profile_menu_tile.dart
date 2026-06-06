import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String labelKey;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showDivider;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.labelKey,
    required this.onTap,
    this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ KEY FIX: Read from MaterialApp locale, NOT from nearest Directionality
    // This bypasses any parent Directionality override
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.r(12)),
        child: Column(
          children: [
            Padding(
              padding: context.rOnly(left: 16, right: 16, top: 13, bottom: 13),
              child: Row(
                children: [
                  // ── Icon Badge ───────────────────────────────────────
                  Container(
                    width: context.r(40),
                    height: context.r(40),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(context.r(11)),
                    ),
                    child: Icon(icon, color: iconColor, size: context.r(20)),
                  ),
                  SizedBox(width: context.r(14)),

                  // ── Label ────────────────────────────────────────────
                  Expanded(
                    child: Text(
                      labelKey.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                  ),

                  // ── Trailing / Chevron ───────────────────────────────
                  if (trailing != null)
                    trailing!
                  else
                    Icon(
                      // ✅ Correct chevron direction per locale
                      isRtl
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: context.r(13),
                      color: Colors.grey.shade400,
                    ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade100,
                indent: context.r(70),
                endIndent: context.r(16),
              ),
          ],
        ),
      ),
    );
  }
}
