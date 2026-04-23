// lib/features/shared/comments/presentation/widgets/states/comments_state_widgets.dart
//
// Loading skeleton, error body, and empty state for the comments section.

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/comments/presentation/cubit/comments_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Loading skeleton ──────────────────────────────────────────────────────────

class CommentsLoadingSkeleton extends StatelessWidget {
  const CommentsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: context.rOnly(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar placeholder
              Container(
                width: context.r(36),
                height: context.r(36),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.r(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name placeholder
                    Container(
                      height: context.r(10),
                      width: context.r(90),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(context.r(4)),
                      ),
                    ),
                    SizedBox(height: context.r(8)),
                    // Content placeholder
                    Container(
                      height: context.r(40),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(context.r(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class CommentsErrorState extends StatelessWidget {
  final String message;
  const CommentsErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rSymmetric(vertical: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: context.r(36),
              color: Colors.grey.shade300,
            ),
            SizedBox(height: context.r(8)),
            Text(
              'comment_error_loading'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12),
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: context.r(12)),
            GestureDetector(
              onTap: () => context.read<CommentsCubit>().load(),
              child: Container(
                padding: context.rSymmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Text(
                  'retry'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class CommentsEmptyState extends StatelessWidget {
  const CommentsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rSymmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: context.r(40),
              color: Colors.grey.shade300,
            ),
            SizedBox(height: context.r(10)),
            Text(
              'comment_empty_title'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: context.r(4)),
            Text(
              'comment_empty_body'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11.5),
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
