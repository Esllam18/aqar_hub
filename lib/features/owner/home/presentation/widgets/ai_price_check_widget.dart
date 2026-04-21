// lib/features/owner/home/presentation/widgets/ai_price_check_widget.dart
//
// AI Price Check — matches app design system (AppColors.primary, Cairo/Tajawal fonts)
// All strings go through .tr(context) for full localization support.

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/home/data/models/add_property_form_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum _CheckState { idle, loading, done, error }

class AiPriceCheckWidget extends StatefulWidget {
  final AddPropertyFormModel form;
  final ValueChanged<AiPriceResult> onResult;

  const AiPriceCheckWidget({
    super.key,
    required this.form,
    required this.onResult,
  });

  @override
  State<AiPriceCheckWidget> createState() => _AiPriceCheckWidgetState();
}

class _AiPriceCheckWidgetState extends State<AiPriceCheckWidget> {
  _CheckState _state = _CheckState.idle;
  AiPriceResult? _result;
  String? _errorMsg;

  // ── Mock AI evaluation ─────────────────────────────────────────────────────
  // TODO: Replace with real API call when ready.
  Future<AiPriceResult> _runAiCheck(AddPropertyFormModel form) async {
    await Future.delayed(const Duration(milliseconds: 1600));

    final basePrice = form.basePrice ?? 0;
    final isFurnished = form.isFurnished;
    final rooms = form.totalRooms ?? 1;
    final area = form.areaM2 ?? 50;
    final isRent = form.isRent;

    double marketFactor = 1.0;
    if (isFurnished) marketFactor += 0.15;
    if (rooms >= 3) marketFactor += 0.10;
    if (area > 100) marketFactor += 0.10;

    final suggested = basePrice > 0 ? basePrice * marketFactor : 0.0;
    final minP = suggested * 0.85;
    final maxP = suggested * 1.15;

    if (basePrice <= 0) {
      return AiPriceResult(
        suggestedPrice: 0,
        priceLabel: 'normal',
        confidence: AiConfidence.low,
        explanation: 'ai_no_price_entered'.tr(context),
      );
    }

    final ratio = basePrice / (suggested > 0 ? suggested : basePrice);

    if (ratio < 0.80) {
      return AiPriceResult(
        suggestedPrice: suggested,
        minPrice: minP,
        maxPrice: maxP,
        priceLabel: 'offer',
        confidence: AiConfidence.high,
        explanation: 'ai_below_market'.tr(context),
      );
    }

    if (ratio > 1.20) {
      return AiPriceResult(
        suggestedPrice: suggested,
        minPrice: minP,
        maxPrice: maxP,
        priceLabel: 'normal',
        confidence: AiConfidence.medium,
        explanation: 'ai_above_market'.tr(context),
      );
    }

    // Within range — verified
    // Note: 'featured' is intentionally mapped to 'verified' here because
    // the DB constraint only allows normal|verified|offer
    return AiPriceResult(
      suggestedPrice: suggested,
      minPrice: minP,
      maxPrice: maxP,
      priceLabel: isRent
          ? 'verified'
          : (basePrice > 2000000 ? 'verified' : 'verified'),
      confidence: AiConfidence.high,
      explanation: 'ai_fair_price'.tr(context),
    );
  }

  Future<void> _check() async {
    setState(() {
      _state = _CheckState.loading;
      _result = null;
      _errorMsg = null;
    });
    try {
      final result = await _runAiCheck(widget.form);
      if (!mounted) return;
      setState(() {
        _state = _CheckState.done;
        _result = result;
      });
      widget.onResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _CheckState.error;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: context.r(40),
              height: context.r(40),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(context.r(12)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: context.r(10),
                    offset: Offset(0, context.r(3)),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: context.r(20),
              ),
            ),
            SizedBox(width: context.r(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ai_price_check_title'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                  Text(
                    'ai_price_check_subtitle'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(11),
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: context.r(14)),

        // ── Body ─────────────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: switch (_state) {
            _CheckState.idle => _IdleCard(
              key: const ValueKey('idle'),
              onCheck: _check,
            ),
            _CheckState.loading => const _LoadingCard(key: ValueKey('loading')),
            _CheckState.done => _ResultCard(
              key: const ValueKey('done'),
              result: _result!,
              onReCheck: _check,
            ),
            _CheckState.error => _ErrorCard(
              key: const ValueKey('error'),
              message: _errorMsg,
              onRetry: _check,
            ),
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Idle card
// ─────────────────────────────────────────────────────────────────────────────

class _IdleCard extends StatelessWidget {
  final VoidCallback onCheck;
  const _IdleCard({super.key, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.psychology_rounded,
            color: AppColors.primary.withOpacity(0.5),
            size: context.r(32),
          ),
          SizedBox(height: context.r(10)),
          Text(
            'ai_price_check_desc'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(12),
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          SizedBox(height: context.r(14)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheck,
              icon: Icon(
                Icons.auto_awesome_rounded,
                size: context.r(16),
                color: Colors.white,
              ),
              label: Text(
                'ai_price_check_btn'.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                padding: context.rSymmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
              ),
            ),
          ),
          SizedBox(height: context.r(8)),
          Text(
            'ai_price_check_optional'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(10),
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading card
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.rAll(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: Colors.grey.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: context.r(36),
            height: context.r(36),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: context.r(14)),
          Text(
            'ai_price_check_analyzing'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(4)),
          Text(
            'ai_price_check_wait'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11),
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result card
// ─────────────────────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final AiPriceResult result;
  final VoidCallback onReCheck;
  const _ResultCard({super.key, required this.result, required this.onReCheck});

  Color get _accentColor => switch (result.priceLabel) {
    'offer' => const Color(0xFFF59E0B),
    'verified' => const Color(0xFF059669),
    _ => AppColors.primary,
  };

  IconData get _accentIcon => switch (result.priceLabel) {
    'offer' => Icons.local_offer_rounded,
    'verified' => Icons.verified_rounded,
    _ => Icons.check_circle_outline_rounded,
  };

  Color get _confidenceColor => switch (result.confidence) {
    AiConfidence.high => const Color(0xFF059669),
    AiConfidence.medium => const Color(0xFFF59E0B),
    AiConfidence.low => Colors.grey.shade500,
  };

  @override
  Widget build(BuildContext context) {
    final currency = 'currency'.tr(context);

    return Container(
      width: double.infinity,
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: _accentColor.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.08),
            blurRadius: context.r(14),
            offset: Offset(0, context.r(4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: context.rAll(6),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(context.r(8)),
                ),
                child: Icon(
                  _accentIcon,
                  color: _accentColor,
                  size: context.r(18),
                ),
              ),
              SizedBox(width: context.r(10)),
              Expanded(
                child: Text(
                  'ai_result_label_${result.priceLabel}'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(15),
                    fontWeight: FontWeight.w800,
                    color: _accentColor,
                  ),
                ),
              ),
              Container(
                padding: context.rSymmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _confidenceColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(context.r(8)),
                ),
                child: Text(
                  'ai_confidence_${result.confidence.name}'.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w700,
                    color: _confidenceColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: context.r(14)),

          // ── Price stats ────────────────────────────────────────────────
          if (result.suggestedPrice > 0) ...[
            Row(
              children: [
                Expanded(
                  child: _PriceStat(
                    label: 'ai_suggested_price'.tr(context),
                    value:
                        '${result.suggestedPrice.toStringAsFixed(0)} $currency',
                    color: _accentColor,
                    bold: true,
                  ),
                ),
                if (result.minPrice != null && result.maxPrice != null)
                  Expanded(
                    child: _PriceStat(
                      label: 'ai_price_range'.tr(context),
                      value:
                          '${result.minPrice!.toStringAsFixed(0)} – ${result.maxPrice!.toStringAsFixed(0)}',
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.r(12)),
          ],

          // ── Explanation ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: context.rAll(12),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: context.r(14),
                  color: _accentColor,
                ),
                SizedBox(width: context.r(8)),
                Expanded(
                  child: Text(
                    result.explanation,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: context.r(8)),

          // ── Re-check ──────────────────────────────────────────────────
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: onReCheck,
              icon: Icon(
                Icons.refresh_rounded,
                size: context.r(13),
                color: Colors.grey.shade500,
              ),
              label: Text(
                'ai_recheck'.tr(context),
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(11),
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price stat cell
// ─────────────────────────────────────────────────────────────────────────────

class _PriceStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _PriceStat({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(10),
            color: Colors.grey.shade500,
          ),
        ),
        SizedBox(height: context.r(2)),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: context.sp(13),
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error card
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const _ErrorCard({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade400,
            size: context.r(28),
          ),
          SizedBox(height: context.r(8)),
          Text(
            'ai_check_error'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: context.r(4)),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                color: Colors.grey.shade500,
              ),
            ),
          ],
          SizedBox(height: context.r(12)),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: context.r(14)),
            label: Text(
              'ai_retry'.tr(context),
              style: GoogleFonts.cairo(fontSize: context.sp(12)),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
