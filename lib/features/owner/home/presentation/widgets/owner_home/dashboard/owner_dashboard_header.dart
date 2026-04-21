// lib/features/owner/home/presentation/widgets/owner_home/dashboard/owner_dashboard_header.dart
// Greeting + date row shown at the top of the owner dashboard.

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerDashboardHeader extends StatelessWidget {
  const OwnerDashboardHeader({super.key});

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    if (h < 12) return 'greeting_morning'.tr(context);
    if (h < 17) return 'greeting_afternoon'.tr(context);
    return 'greeting_evening'.tr(context);
  }

  String _ownerName() {
    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    final first = meta?['first_name'] as String?;
    return (first != null && first.isNotEmpty) ? first : '';
  }

  @override
  Widget build(BuildContext context) {
    final name = _ownerName();
    return Padding(
      padding: context.rOnly(left: 16, right: 16, top: 14, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting(context)}${name.isNotEmpty ? '، $name' : ''}',
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'owner_dashboard_subtitle'.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(11.5),
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: context.rSymmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Text(
              _todayLabel(),
              style: GoogleFonts.cairo(
                fontSize: context.sp(11),
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}
