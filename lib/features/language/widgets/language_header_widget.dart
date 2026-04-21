import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageHeaderWidget extends StatelessWidget {
  const LanguageHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Globe icon
        AppAnimations.scale(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          beginScale: 0.3,
          child: Container(
            width: context.r(80),
            height: context.r(80),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.language_rounded,
              size: context.r(40),
              color: AppColors.primary,
            ),
          ),
        ),

        SizedBox(height: context.r(24)),

        // Bilingual title — always LTR, never flips
        AppAnimations.combined(
          type: CombineType.fadeSlide,
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          direction: SlideDirection.up,
          curve: Curves.easeOutCubic,
          child: Text(
            'اختر لغتك  /  Choose Language',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: context.sp(22),
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),

        SizedBox(height: context.r(8)),

        AppAnimations.fade(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 300),
          child: Text(
            'يمكنك تغييرها لاحقاً  /  You can change it later',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w500,
              fontSize: context.sp(14),
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
