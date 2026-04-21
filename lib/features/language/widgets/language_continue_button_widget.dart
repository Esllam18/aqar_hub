import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageContinueButton extends StatelessWidget {
  final String selectedCode;
  final VoidCallback onPressed;

  const LanguageContinueButton({
    super.key,
    required this.selectedCode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fade(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 550),
      child: SizedBox(
        width: double.infinity,
        height: context.r(54),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
          ),
          child: Text(
            selectedCode == 'ar' ? 'متابعة' : 'Continue',
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
