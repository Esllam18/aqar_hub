// lib/features/shared/comments/presentation/widgets/comment_list/comments_section_header.dart
//
// Section header with title + comment count badge.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentsSectionHeader extends StatelessWidget {
  final int count;

  const CommentsSectionHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Accent bar
        Container(
          width: context.r(4),
          height: context.r(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(context.r(4)),
          ),
        ),
        SizedBox(width: context.r(10)),
        Text(
          'comment_section_title'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2D5E),
          ),
        ),
        SizedBox(width: context.r(8)),
        if (count > 0)
          Container(
            padding: context.rSymmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: context.sp(11),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}
