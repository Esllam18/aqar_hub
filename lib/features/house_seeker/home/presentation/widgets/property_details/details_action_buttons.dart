import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsActionButtons extends StatelessWidget {
  final VoidCallback onWhatsApp;
  final VoidCallback onLocation;
  final VoidCallback? onChat;

  const DetailsActionButtons({
    super.key,
    required this.onWhatsApp,
    required this.onLocation,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(
        left: 16,
        right: 16,
        top: 14,
        bottom: 14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: context.r(18),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _SolidButton(
              label: 'details_btn_whatsapp'.tr(context),
              icon: Icons.chat_rounded,
              color: const Color(0xFF25D366),
              onTap: onWhatsApp,
            ),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            flex: 2,
            child: _OutlineButton(
              label: 'details_btn_location'.tr(context),
              icon: Icons.location_on_rounded,
              color: const Color(0xFF1E88E5),
              onTap: onLocation,
            ),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            flex: 2,
            child: _OutlineButton(
              label: 'details_btn_chat'.tr(context),
              icon: Icons.forum_outlined,
              color: AppColors.primary,
              onTap: onChat ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _SolidButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SolidButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.r(50),
        padding: context.rSymmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(context.r(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: context.r(18)),
            SizedBox(width: context.r(6)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.r(50),
        padding: context.rSymmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: context.r(17)),
            SizedBox(width: context.r(5)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
