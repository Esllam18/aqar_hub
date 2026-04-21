import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_logout_dialog.dart';

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ProfileLogoutDialog.show(context),
        icon: Icon(
          Icons.logout_rounded,
          color: const Color(0xFFE53935),
          size: context.r(18),
        ),
        label: Text(
          'btn_logout'.tr(context),
          style: GoogleFonts.tajawal(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w700,
            color: const Color(0xFFE53935),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFFE53935).withValues(alpha: 0.4),
          ),
          padding: context.rSymmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(16)),
          ),
        ),
      ),
    );
  }
}
