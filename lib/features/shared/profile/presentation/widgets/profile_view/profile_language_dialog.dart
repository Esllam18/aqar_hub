import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/localization/locale_cubit.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileLanguageDialog extends StatelessWidget {
  const ProfileLanguageDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => BlocProvider.value(
      value: context.read<LocaleCubit>(),
      child: const ProfileLanguageDialog(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final currentCode = Localizations.localeOf(context).languageCode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: context.rSymmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: context.rOnly(top: 24, bottom: 20, left: 24, right: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.r(24)),
                  topRight: Radius.circular(context.r(24)),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: context.r(52),
                    height: context.r(52),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      color: Colors.white,
                      size: context.r(26),
                    ),
                  ),
                  SizedBox(height: context.r(12)),
                  Text(
                    'lang_dialog_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(17),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: context.r(4)),
                  Text(
                    'lang_dialog_subtitle'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Options ──────────────────────────────────────────────────
            Padding(
              padding: context.rAll(20),
              child: Column(
                children: [
                  _LangOption(
                    langCode: 'ar',
                    nameKey: 'lang_arabic',
                    nativeName: 'العربية',
                    isSelected: currentCode == 'ar',
                  ),
                  SizedBox(height: context.r(10)),
                  _LangOption(
                    langCode: 'en',
                    nameKey: 'lang_english',
                    nativeName: 'English',
                    isSelected: currentCode == 'en',
                  ),
                  SizedBox(height: context.r(4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String langCode;
  final String nameKey;
  final String nativeName;
  final bool isSelected;

  const _LangOption({
    required this.langCode,
    required this.nameKey,
    required this.nativeName,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<LocaleCubit>().changeLanguage(langCode);
        Navigator.of(context).pop();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: context.rSymmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.07)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: context.r(22),
              height: context.r(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: isSelected ? 0 : 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: context.r(13),
                    )
                  : null,
            ),

            SizedBox(width: context.r(14)),

            // Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameKey.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    nativeName,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
