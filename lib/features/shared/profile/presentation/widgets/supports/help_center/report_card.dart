import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({super.key});

  Future<void> _openReport() async {
    // Opens the device email app pre-filled with a report template
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@aqarhub.app',
      queryParameters: {
        'subject': 'AqarHub — Report / Bug',
        'body': 'Describe your issue here...',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openReport,
      child: Container(
        padding: context.rAll(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: const Color(0xFFE53935).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.r(46),
              height: context.r(46),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.r(13)),
              ),
              child: Icon(
                Icons.flag_outlined,
                color: Colors.white,
                size: context.r(20),
              ),
            ),
            SizedBox(width: context.r(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'help_report_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                  Text(
                    'help_report_subtitle'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: context.r(13),
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
