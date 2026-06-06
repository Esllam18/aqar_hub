// lib/features/shared/comments/presentation/widgets/comment_list/comment_list.dart
//
// Scrollable list of CommentItems with a "Load more" button at the bottom.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/comments/data/models/comment_model.dart';
import 'package:aqar_hub/features/shared/comments/presentation/cubit/comments_cubit.dart';
import 'package:aqar_hub/features/shared/comments/presentation/widgets/comment_item/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentList extends StatelessWidget {
  final List<CommentModel> comments;
  final bool hasMore;
  final bool loadingMore;

  const CommentList({
    super.key,
    required this.comments,
    required this.hasMore,
    required this.loadingMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Comment rows
        ...comments.map((c) => CommentItem(key: ValueKey(c.id), comment: c)),

        // Load more
        if (hasMore) _LoadMoreButton(loading: loadingMore),

        // End spacer
        SizedBox(height: context.r(8)),
      ],
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  const _LoadMoreButton({required this.loading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rOnly(top: 4, bottom: 8),
      child: loading
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          : GestureDetector(
              onTap: () => context.read<CommentsCubit>().loadMore(),
              child: Container(
                padding: context.rSymmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Text(
                  'comment_load_more'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
    );
  }
}
