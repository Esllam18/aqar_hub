// ignore_for_file: unused_local_variable

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/comments/data/datasources/comments_datasource.dart';
import 'package:aqar_hub/features/shared/comments/data/repositories/comments_repository.dart';
import 'package:aqar_hub/features/shared/comments/presentation/cubit/comments_cubit.dart';
import 'package:aqar_hub/features/shared/comments/presentation/widgets/comment_input/comment_input_bar.dart';
import 'package:aqar_hub/features/shared/comments/presentation/widgets/comment_list/comment_list.dart';
import 'package:aqar_hub/features/shared/comments/presentation/widgets/comment_list/comments_section_header.dart';
import 'package:aqar_hub/features/shared/comments/presentation/widgets/states/comments_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsSection extends StatelessWidget {
  final String propertyId;
  final String propertyOwnerId;

  const CommentsSection({
    super.key,
    required this.propertyId,
    required this.propertyOwnerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommentsCubit(
        repo: CommentsRepository(CommentsDatasource()),
        propertyId: propertyId,
        propertyOwnerId: propertyOwnerId,
      )..load(),
      child: _CommentsSectionContent(propertyId: propertyId),
    );
  }
}

class _CommentsSectionContent extends StatelessWidget {
  final String propertyId;
  const _CommentsSectionContent({required this.propertyId});

  bool get _isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommentsCubit, CommentsState>(
      listener: (context, state) {
        if (state is CommentsSubmitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('comment_submit_error'.tr(context)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<CommentsCubit, CommentsState>(
        builder: (context, state) {
          final comments = state is CommentsLoaded ? state.comments : [];
          final count = comments.length;

          return Container(
            padding: context.rAll(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(18)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────────────
                CommentsSectionHeader(count: count),
                SizedBox(height: context.r(16)),

                // ── Input bar ─────────────────────────────────────────────
                CommentInputBar(isLoggedIn: _isLoggedIn),
                SizedBox(height: context.r(18)),

                // ── Divider ───────────────────────────────────────────────
                if (state is CommentsLoaded && state.comments.isNotEmpty) ...[
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey.shade100,
                  ),
                  SizedBox(height: context.r(14)),
                ],

                // ── Comment list / states ─────────────────────────────────
                switch (state) {
                  CommentsLoading() => const CommentsLoadingSkeleton(),
                  CommentsError(:final message) => CommentsErrorState(
                    message: message,
                  ),
                  CommentsLoaded(
                    :final comments,
                    :final hasMore,
                    :final loadingMore,
                  )
                      when comments.isEmpty =>
                    const CommentsEmptyState(),
                  CommentsLoaded(
                    :final comments,
                    :final hasMore,
                    :final loadingMore,
                  ) =>
                    CommentList(
                      comments: comments,
                      hasMore: hasMore,
                      loadingMore: loadingMore,
                    ),
                  CommentsSubmitError(:final previousState) => CommentList(
                    comments: previousState.comments,
                    hasMore: previousState.hasMore,
                    loadingMore: previousState.loadingMore,
                  ),
                  _ => const CommentsLoadingSkeleton(),
                },
              ],
            ),
          );
        },
      ),
    );
  }
}
