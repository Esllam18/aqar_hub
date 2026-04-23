// lib/features/shared/comments/presentation/widgets/comment_item/comment_item.dart
//
// A single comment row: avatar, author name, timestamp, text, delete button.

// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
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

    return Padding(
      padding: context.rOnly(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          _CommentAvatar(
            name: comment.authorName,
            imageUrl: comment.authorAvatar,
          ),
          SizedBox(width: context.r(10)),

          // ── Bubble ──────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row
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
                    if (canDel) ...[
                      SizedBox(width: context.r(4)),
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
                    color: const Color(0xFFF4F7FB),
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

// ── Avatar ────────────────────────────────────────────────────────────────────

class _CommentAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  const _CommentAvatar({this.name, this.imageUrl});

  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = context.r(36);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
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
      child: Icon(
        Icons.delete_outline_rounded,
        size: context.r(16),
        color: AppColors.error.withOpacity(0.70),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<CommentsCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'comment_delete_title'.tr(context),
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'comment_delete_body'.tr(context),
          style: GoogleFonts.tajawal(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(context),
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'delete'.tr(context),
              style: GoogleFonts.cairo(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.deleteComment(commentId);
    }
  }
}
