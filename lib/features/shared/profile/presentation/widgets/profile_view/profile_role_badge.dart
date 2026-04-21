import 'package:aqar_hub/core/enums/app_role.dart'; // ✅
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileRoleBadge extends StatelessWidget {
  final AppRole role; // ✅ replaces bool isOwner

  const ProfileRoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isOwner = role == AppRole.owner;
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOwner ? Icons.business_rounded : Icons.search_rounded,
            size: context.r(12),
            color: Colors.white,
          ),
          SizedBox(width: context.r(5)),
          Text(
            isOwner ? 'role_owner'.tr(context) : 'role_seeker'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
