import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingTitleWidget extends StatelessWidget {
  final String titleKey;

  const OnboardingTitleWidget({super.key, required this.titleKey});

  @override
  Widget build(BuildContext context) {
    return AppAnimations.combined(
      type: CombineType.fadeSlide,
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 200),
      direction: SlideDirection.up,
      curve: Curves.easeOutCubic,
      child: Text(
        titleKey.tr(context),
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: context.sp(26),
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          height: 1.4,
        ),
      ),
    );
  }
}
