// lib/features/auth/presentation/widgets/auth_header.dart

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthHeader extends StatelessWidget {
  final String titleKey;
  final String subtitleKey;

  const AuthHeader({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          titleKey.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(26),
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: context.r(8)),
        Text(
          subtitleKey.tr(context),
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(15),
            color: AppColors.primary.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}
