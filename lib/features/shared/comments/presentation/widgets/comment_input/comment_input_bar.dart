// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/comments/presentation/cubit/comments_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentInputBar extends StatefulWidget {
  final bool isLoggedIn;

  const CommentInputBar({super.key, required this.isLoggedIn});

  @override
  State<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  int _charCount = 0;

  static const _maxChars = 1000;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      setState(() => _charCount = _ctrl.text.length);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    await context.read<CommentsCubit>().addComment(text);
    _ctrl.clear();
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return _GuestInputHint();
    }

    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        final isSubmitting = state is CommentsLoaded && state.submitting;

        return Container(
          padding: context.rOnly(left: 16, right: 16, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(18)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ── Text field ──────────────────────────────────────────
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      maxLines: 4,
                      minLines: 1,
                      maxLength: _maxChars,
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.newline,
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(13.5),
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'comment_hint'.tr(context),
                        hintStyle: GoogleFonts.tajawal(
                          fontSize: context.sp(13),
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(width: context.r(10)),

                  // ── Send button ─────────────────────────────────────────
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _charCount > 0 && !isSubmitting ? 1.0 : 0.35,
                    child: GestureDetector(
                      onTap: _charCount > 0 && !isSubmitting
                          ? () => _submit(context)
                          : null,
                      child: Container(
                        width: context.r(40),
                        height: context.r(40),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(context.r(12)),
                        ),
                        child: isSubmitting
                            ? Padding(
                                padding: context.rAll(10),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: context.r(18),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              // ── Character counter ───────────────────────────────────────
              if (_charCount > 0)
                Padding(
                  padding: context.rOnly(top: 4),
                  child: Text(
                    '$_charCount / $_maxChars',
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(9.5),
                      color: _charCount > (_maxChars * 0.9)
                          ? AppColors.error
                          : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Guest hint (shown when not logged in) ─────────────────────────────────────

class _GuestInputHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rAll(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: context.r(18),
            color: AppColors.primary.withOpacity(0.60),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Text(
              'comment_login_required'.tr(context),
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12.5),
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
