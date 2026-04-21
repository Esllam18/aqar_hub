import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ Single widget used for both favoritesCount and apartmentsCount
class ProfileCountBadge extends StatelessWidget {
  final int count;
  final Color color;
  const ProfileCountBadge({
    super.key,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.cairo(
          fontSize: context.sp(12),
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
