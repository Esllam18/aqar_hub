import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialButton extends StatelessWidget {
  final String textKey;
  final String? imagePath;
  final IconData? iconData;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.textKey,
    required this.onPressed,
    this.imagePath,
    this.iconData,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.r(54),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          side: BorderSide(
            color: backgroundColor != null
                ? Colors.grey.withValues(alpha: 0.3)
                : AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(14)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: context.r(22),
                height: context.r(22),
              )
            else if (iconData != null)
              Icon(iconData, size: context.r(22)),

            SizedBox(width: context.r(10)),

            Text(
              textKey.tr(context),
              style: GoogleFonts.cairo(
                fontSize: context.sp(15),
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
