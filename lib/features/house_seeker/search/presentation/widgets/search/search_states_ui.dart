// search_states_ui.dart — Welcome, Thinking, Reply, Error, Empty UI states
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Welcome ───────────────────────────────────────────────────────────────────

class SearchWelcome extends StatelessWidget {
  final void Function(String) onExampleTap;
  const SearchWelcome({super.key, required this.onExampleTap});

  static const _examples = [
    'search_example_1',
    'search_example_2',
    'search_example_3',
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: context.rOnly(left: 20, right: 20, top: 28, bottom: 32),
    child: Column(
      children: [
        AppAnimations.combined(
          type: CombineType.fadeSlide,
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 100),
          child: Container(
            width: context.r(88),
            height: context.r(88),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B2D5E), Color(0xFF2A5298)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(context.r(26)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B2D5E).withOpacity(0.25),
                  blurRadius: context.r(24),
                  offset: Offset(0, context.r(8)),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: context.r(44),
            ),
          ),
        ),
        SizedBox(height: context.r(22)),
        AppAnimations.fade(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 180),
          child: Text(
            'search_welcome_title'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: context.sp(19),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1B2D5E),
            ),
          ),
        ),
        SizedBox(height: context.r(8)),
        AppAnimations.fade(
          duration: const Duration(milliseconds: 500),
          delay: const Duration(milliseconds: 230),
          child: Text(
            'search_welcome_body'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade500,
              height: 1.65,
            ),
          ),
        ),
        SizedBox(height: context.r(28)),
        AppAnimations.fade(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 280),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'search_try_these'.tr(context),
              style: GoogleFonts.cairo(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B2D5E),
              ),
            ),
          ),
        ),
        SizedBox(height: context.r(10)),
        ..._examples.asMap().entries.map(
          (e) => AppAnimations.combined(
            type: CombineType.fadeSlide,
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: 320 + e.key * 70),
            child: _ExampleRow(
              text: e.value.tr(context),
              onTap: () => onExampleTap(e.value),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ExampleRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _ExampleRow({required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: context.rOnly(bottom: 10),
      padding: context.rSymmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: AppColors.primary.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: context.r(16),
            color: AppColors.primary.withOpacity(0.45),
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: const Color(0xFF1B2D5E).withOpacity(0.75),
              ),
            ),
          ),
          Icon(
            Icons.north_west_rounded,
            size: context.r(13),
            color: Colors.grey.shade300,
          ),
        ],
      ),
    ),
  );
}

// ── Thinking ──────────────────────────────────────────────────────────────────

class SearchThinking extends StatefulWidget {
  final int phase;
  const SearchThinking({super.key, required this.phase});
  @override
  State<SearchThinking> createState() => _ThinkingState();
}

class _ThinkingState extends State<SearchThinking>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;
  int _step = 0;
  Timer? _timer;
  static const _p1 = ['search_step_1', 'search_step_2'];
  static const _p2 = ['search_step_3', 'search_step_4'];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.90,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _timer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (mounted) setState(() => _step++);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.phase == 1 ? _p1 : _p2;
    final key = steps[_step % steps.length];
    final title = widget.phase == 1
        ? 'search_analyzing'.tr(context)
        : 'search_loading'.tr(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: context.r(86),
              height: context.r(86),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2D5E), Color(0xFF2A5298)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B2D5E).withOpacity(0.30),
                    blurRadius: context.r(28),
                    spreadRadius: context.r(4),
                  ),
                ],
              ),
              child: Icon(
                widget.phase == 1
                    ? Icons.psychology_rounded
                    : Icons.search_rounded,
                color: Colors.white,
                size: context.r(38),
              ),
            ),
          ),
          SizedBox(height: context.r(26)),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: context.sp(17),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(10)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              key.tr(context),
              key: ValueKey(key),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: Colors.grey.shade500,
              ),
            ),
          ),
          SizedBox(height: context.r(24)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  final active = i == _step % 3;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: context.rSymmetric(horizontal: 4),
                    width: active ? context.r(20) : context.r(8),
                    height: context.r(8),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(context.r(4)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reply ─────────────────────────────────────────────────────────────────────

class SearchReplyView extends StatelessWidget {
  final String reply;
  final VoidCallback onReset;
  const SearchReplyView({
    super.key,
    required this.reply,
    required this.onReset,
  });
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: context.rAll(24),
    child: AppAnimations.combined(
      type: CombineType.fadeSlide,
      duration: const Duration(milliseconds: 450),
      child: Container(
        width: double.infinity,
        padding: context.rAll(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: context.r(58),
              height: context.r(58),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(context.r(16)),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: context.r(28),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: context.r(16)),
            Text(
              reply,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(14),
                color: const Color(0xFF1B2D5E),
                height: 1.65,
              ),
            ),
            SizedBox(height: context.r(22)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReset,
                icon: Icon(
                  Icons.search_rounded,
                  size: context.r(15),
                  color: Colors.white,
                ),
                label: Text(
                  'search_try_again'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  padding: context.rSymmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.r(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Empty results ─────────────────────────────────────────────────────────────

class SearchEmptyResults extends StatelessWidget {
  final VoidCallback onReset;
  const SearchEmptyResults({super.key, required this.onReset});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: context.rAll(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAnimations.combined(
            type: CombineType.fadeSlide,
            duration: const Duration(milliseconds: 450),
            child: Icon(
              Icons.search_off_rounded,
              size: context.r(72),
              color: Colors.grey.shade300,
            ),
          ),
          SizedBox(height: context.r(18)),
          AppAnimations.fade(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 80),
            child: Text(
              'search_no_results'.tr(context),
              style: GoogleFonts.cairo(
                fontSize: context.sp(17),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B2D5E),
              ),
            ),
          ),
          SizedBox(height: context.r(8)),
          AppAnimations.fade(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 140),
            child: Text(
              'search_no_results_hint'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: Colors.grey.shade500,
                height: 1.65,
              ),
            ),
          ),
          SizedBox(height: context.r(24)),
          AppAnimations.fade(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 200),
            child: ElevatedButton.icon(
              onPressed: onReset,
              icon: Icon(
                Icons.tune_rounded,
                size: context.r(15),
                color: Colors.white,
              ),
              label: Text(
                'search_modify'.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: context.rSymmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Error ─────────────────────────────────────────────────────────────────────

class SearchErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const SearchErrorView({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: context.rAll(32),
      child: AppAnimations.combined(
        type: CombineType.fadeSlide,
        duration: const Duration(milliseconds: 450),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.r(78),
              height: context.r(78),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(context.r(22)),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: context.r(36),
                color: Colors.red.shade300,
              ),
            ),
            SizedBox(height: context.r(18)),
            Text(
              'search_error_title'.tr(context),
              style: GoogleFonts.cairo(
                fontSize: context.sp(17),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B2D5E),
              ),
            ),
            SizedBox(height: context.r(8)),
            Text(
              'search_error_body'.tr(context),
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: context.r(24)),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                size: context.r(15),
                color: Colors.white,
              ),
              label: Text(
                'search_retry'.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: context.rSymmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Quota error ───────────────────────────────────────────────────────────────

class SearchQuotaView extends StatelessWidget {
  const SearchQuotaView({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: context.rAll(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: context.r(72),
            color: Colors.orange.shade300,
          ),
          SizedBox(height: context.r(16)),
          Text(
            'search_quota_title'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(8)),
          Text(
            'search_quota_body'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade500,
              height: 1.65,
            ),
          ),
        ],
      ),
    ),
  );
}
