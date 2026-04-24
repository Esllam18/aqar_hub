// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/owner_profile/presentation/view/owner_profile_page.dart';
import 'package:aqar_hub/features/shared/comments/data/models/comment_model.dart';
import 'package:aqar_hub/features/shared/comments/presentation/cubit/comments_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;

  const CommentItem({super.key, required this.comment});

  String _formatDate(BuildContext context, DateTime dt) {
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());

    if (diff.inSeconds < 60) return 'comment_just_now'.tr(context);
    if (diff.inMinutes < 60) {
      return 'comment_minutes_ago'
          .tr(context)
          .replaceAll('{n}', '${diff.inMinutes}');
    }
    if (diff.inHours < 24) {
      return 'comment_hours_ago'
          .tr(context)
          .replaceAll('{n}', '${diff.inHours}');
    }
    if (diff.inDays < 7) {
      return 'comment_days_ago'.tr(context).replaceAll('{n}', '${diff.inDays}');
    }
    return DateFormat('d MMM yyyy', locale).format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommentsCubit>();
    final canDel = cubit.canDelete(comment);
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    // Optimistic entries haven't been saved to DB yet — don't show delete
    final isOptimistic = comment.id.startsWith('__optimistic__');

    return Padding(
      padding: context.rOnly(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tappable avatar → navigate to the commenter's profile ────────
          _CommentAvatar(
            userId: comment.userId,
            name: comment.authorName,
            imageUrl: comment.authorAvatar,
          ),
          SizedBox(width: context.r(10)),

          // ── Bubble ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row: name | timestamp | delete
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorName ??
                            'comment_unknown_author'.tr(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(12.5),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(context, comment.createdAt),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(10),
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (canDel && !isOptimistic) ...[
                      SizedBox(width: context.r(2)),
                      _DeleteButton(commentId: comment.id),
                    ],
                  ],
                ),
                SizedBox(height: context.r(4)),

                // Comment bubble
                Container(
                  width: double.infinity,
                  padding: context.rSymmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOptimistic
                        ? AppColors.primary.withOpacity(0.05)
                        : const Color(0xFFF4F7FB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        isRtl ? context.r(16) : context.r(4),
                      ),
                      topRight: Radius.circular(
                        isRtl ? context.r(4) : context.r(16),
                      ),
                      bottomLeft: Radius.circular(context.r(16)),
                      bottomRight: Radius.circular(context.r(16)),
                    ),
                  ),
                  child: Text(
                    comment.content,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(13),
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tappable avatar ───────────────────────────────────────────────────────────

class _CommentAvatar extends StatelessWidget {
  final String userId;
  final String? name;
  final String? imageUrl;

  const _CommentAvatar({required this.userId, this.name, this.imageUrl});

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerProfilePage(
          ownerId: userId,
          ownerName: name,
          ownerAvatar: imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = context.r(38);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () => _openProfile(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.10),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    _InitialsFallback(initials: _initials),
                placeholder: (_, __) => _InitialsFallback(initials: _initials),
              )
            : _InitialsFallback(initials: _initials),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  final String initials;
  const _InitialsFallback({required this.initials});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      initials,
      style: GoogleFonts.cairo(
        fontSize: context.sp(13),
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    ),
  );
}

// ── Delete button ─────────────────────────────────────────────────────────────

class _DeleteButton extends StatelessWidget {
  final String commentId;
  const _DeleteButton({required this.commentId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmDelete(context),
      // Extra hit area so small icon is easy to tap
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: context.rOnly(left: 6, top: 2, bottom: 2),
        child: Icon(
          Icons.delete_outline_rounded,
          size: context.r(20),
          color: AppColors.error.withOpacity(0.72),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<CommentsCubit>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => _DeleteConfirmSheet(),
    );

    if (confirmed == true) {
      cubit.deleteComment(commentId);
    }
  }
}

// ── Delete confirmation bottom sheet ─────────────────────────────────────────

class _DeleteConfirmSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(28)),
        ),
      ),
      padding: EdgeInsets.only(
        left: context.r(24),
        right: context.r(24),
        top: context.r(16),
        bottom: context.r(40) + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ───────────────────────────────────────────────
          Container(
            width: context.r(44),
            height: context.r(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(context.r(4)),
            ),
          ),
          SizedBox(height: context.r(24)),

          // ── Icon ─────────────────────────────────────────────────────
          Container(
            width: context.r(64),
            height: context.r(64),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: context.r(30),
            ),
          ),
          SizedBox(height: context.r(18)),

          // ── Title ────────────────────────────────────────────────────
          Text(
            'comment_delete_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(18),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(8)),

          // ── Body ─────────────────────────────────────────────────────
          Text(
            'comment_delete_body'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: context.r(32)),

          // ── Buttons ──────────────────────────────────────────────────
          Row(
            children: [
              // Cancel
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: context.rSymmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(16)),
                    ),
                  ),
                  child: Text(
                    'cancel'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.r(12)),

              // Delete
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: context.rSymmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(16)),
                    ),
                  ),
                  child: Text(
                    'delete'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
