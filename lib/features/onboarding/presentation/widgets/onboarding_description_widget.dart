import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingDescriptionWidget extends StatelessWidget {
  final String descriptionKey;

  const OnboardingDescriptionWidget({super.key, required this.descriptionKey});

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fade(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
      child: Text(
        descriptionKey.tr(context),
        textAlign: TextAlign.center,
        style: GoogleFonts.tajawal(
          fontSize: context.sp(15),
          fontWeight: FontWeight.w400,
          color: AppColors.primary.withValues(alpha: 0.7),
          height: 1.6,
        ),
      ),
    );
  }
}
