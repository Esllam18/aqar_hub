import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqTile extends StatefulWidget {
  final String questionKey;
  final String answerKey;
  const FaqTile({
    super.key,
    required this.questionKey,
    required this.answerKey,
  });

  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _rotate = Tween(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: context.rOnly(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: _open
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: _open
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: context.rAll(14),
              child: Row(
                children: [
                  Container(
                    width: context.r(32),
                    height: context.r(32),
                    decoration: BoxDecoration(
                      color: _open
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(context.r(9)),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: context.r(16),
                      color: _open ? AppColors.primary : Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(width: context.r(12)),
                  Expanded(
                    child: Text(
                      widget.questionKey.tr(context),
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w700,
                        color: _open ? AppColors.primary : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _rotate,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _open ? AppColors.primary : Colors.grey.shade400,
                      size: context.r(22),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: context.rOnly(left: 58, right: 14, bottom: 14),
                child: Text(
                  widget.answerKey.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(13),
                    color: Colors.grey.shade600,
                    height: 1.7,
                  ),
                ),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
        ),
      ),
    );
  }
}
