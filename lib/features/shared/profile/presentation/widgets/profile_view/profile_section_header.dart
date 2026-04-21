import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String titleKey;
  const ProfileSectionHeader({super.key, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rOnly(bottom: 8, right: 4),
      child: Text(
        titleKey.tr(context),
        style: GoogleFonts.cairo(
          fontSize: context.sp(13),
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
