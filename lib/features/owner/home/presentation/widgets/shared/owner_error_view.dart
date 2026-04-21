// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const OwnerErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: context.rSymmetric(horizontal: 22, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.r(340)),
          child: Container(
            width: double.infinity,
            padding: context.rAll(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(28)),
              border: Border.all(color: AppColors.error.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: context.r(28),
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.r(84),
                  height: context.r(84),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withOpacity(0.14),
                        AppColors.error.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: context.r(56),
                      height: context.r(56),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.10),
                            blurRadius: context.r(10),
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: context.r(28),
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.r(18)),
                Text(
                  'Something went wrong',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(18),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2D5E),
                  ),
                ),
                SizedBox(height: context.r(8)),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: context.r(20)),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(context.r(16)),
                    child: InkWell(
                      onTap: onRetry,
                      borderRadius: BorderRadius.circular(context.r(16)),
                      child: Padding(
                        padding: context.rSymmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: context.r(20),
                            ),
                            SizedBox(width: context.r(8)),
                            Text(
                              'btnretry'.tr(context),
                              style: GoogleFonts.tajawal(
                                fontSize: context.sp(13),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.r(10)),
                Text(
                  'Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(11.5),
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
