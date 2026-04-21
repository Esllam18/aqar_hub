import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorView extends StatelessWidget {
  final String messageKey;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.messageKey, required this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: context.r(52),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: context.r(14)),
          Text(
            messageKey.tr(context),
            style: GoogleFonts.tajawal(color: Colors.grey.shade500),
          ),
          SizedBox(height: context.r(18)),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: context.r(18)),
            label: Text(
              'btn_retry'.tr(context),
              style: GoogleFonts.tajawal(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
