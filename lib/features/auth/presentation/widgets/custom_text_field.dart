// lib/features/auth/presentation/widgets/custom_text_field.dart

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelKey;
  final String? hintKey;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? errorText;
  final TextDirection? textDirection;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final TextInputAction textInputAction;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelKey,
    this.hintKey,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.errorText,
    this.textDirection,
    this.inputFormatters,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──────────────────────────────────────────────────────────
        Text(
          labelKey.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(13),
            fontWeight: FontWeight.w600,
            color: AppColors.primary.withValues(alpha: 0.8),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: context.r(6)),

        // ── Field ──────────────────────────────────────────────────────────
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textDirection: textDirection,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onChanged: onChanged,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(15),
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            hintText: hintKey?.tr(context),
            hintStyle: GoogleFonts.tajawal(
              fontSize: context.sp(14),
              color: Colors.grey.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.primary.withValues(alpha: 0.6),
              size: context.r(20),
            ),
            suffixIcon: suffixIcon,
            errorText: errorText?.tr(context),
            errorStyle: GoogleFonts.tajawal(
              fontSize: context.sp(12),
              color: Colors.red,
            ),
            filled: true,
            fillColor: AppColors.primary.withValues(alpha: 0.04),
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.r(16),
              vertical: context.r(14),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.r(12)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.r(12)),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.r(12)),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.r(12)),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.r(12)),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
