import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SheetOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String labelKey;
  final VoidCallback onTap;
  final bool isDestructive;

  const SheetOption({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.labelKey,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: context.rSymmetric(horizontal: 4),
      leading: Container(
        width: context.r(42),
        height: context.r(42),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(context.r(12)),
        ),
        child: Icon(icon, color: iconColor, size: context.r(20)),
      ),
      title: Text(
        labelKey.tr(context),
        style: GoogleFonts.tajawal(
          fontSize: context.sp(15),
          fontWeight: FontWeight.w600,
          color: isDestructive ? const Color(0xFFE53935) : Colors.grey.shade800,
        ),
      ),
    );
  }
}
