import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/shared/profile/data/models/help_topic_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen step-by-step guide detail page.
/// Navigated to from the help category grid.
class HelpGuideDetailView extends StatelessWidget {
  final HelpGuide guide;

  const HelpGuideDetailView({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: context.r(160),
            pinned: true,
            backgroundColor: guide.gradient.first,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: context.r(20),
              ),
              onPressed: Navigation.back,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: guide.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: context.r(24)),
                      Container(
                        width: context.r(64),
                        height: context.r(64),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          guide.icon,
                          color: Colors.white,
                          size: context.r(30),
                        ),
                      ),
                      SizedBox(height: context.r(10)),
                      Text(
                        guide.titleKey.tr(context),
                        style: GoogleFonts.cairo(
                          fontSize: context.sp(18),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: context.rSymmetric(horizontal: 24),
                        child: Text(
                          guide.subtitleKey.tr(context),
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            color: Colors.white.withValues(alpha: 0.80),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Steps ───────────────────────────────────────────────────
          SliverPadding(
            padding: context.rAll(18),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index < guide.steps.length) {
                  return _StepCard(
                    step: guide.steps[index],
                    stepNumber: index + 1,
                    isLast: index == guide.steps.length - 1,
                    accentColor: guide.gradient.first,
                  );
                }
                return SizedBox(height: context.r(80));
              }, childCount: guide.steps.length + 1),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step card ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final HelpStep step;
  final int stepNumber;
  final bool isLast;
  final Color accentColor;

  const _StepCard({
    required this.step,
    required this.stepNumber,
    required this.isLast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left timeline ────────────────────────────────────────
          SizedBox(
            width: context.r(52),
            child: Column(
              children: [
                Container(
                  width: context.r(40),
                  height: context.r(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: context.r(2),
                      margin: context.rOnly(top: 6, bottom: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                if (isLast) SizedBox(height: context.r(20)),
              ],
            ),
          ),

          // ── Content card ─────────────────────────────────────────
          Expanded(
            child: Container(
              margin: context.rOnly(bottom: isLast ? 0 : 16, left: 4),
              padding: context.rAll(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.r(16)),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: context.r(38),
                    height: context.r(38),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(context.r(10)),
                    ),
                    child: Icon(
                      step.icon,
                      color: accentColor,
                      size: context.r(18),
                    ),
                  ),
                  SizedBox(width: context.r(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.titleKey.tr(context),
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B2D5E),
                          ),
                        ),
                        SizedBox(height: context.r(4)),
                        Text(
                          step.bodyKey.tr(context),
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(13),
                            color: Colors.grey.shade600,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
