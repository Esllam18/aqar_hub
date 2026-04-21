// lib/features/owner/home/presentation/widgets/ai_price_check_widget.dart
//
// AI Price Check — uses real Groq API (llama-3.3-70b) instead of the mock.
// API key is read from .env via GROQ_API_KEY.
// All strings use .tr(context) for full AR/EN localization.

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/home/data/models/add_property_form_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

  // ── Groq API price estimation ──────────────────────────────────────────────
  Future<AiPriceResult> _runAiCheck(AddPropertyFormModel form) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

    // If no API key, fall back to a helpful error rather than a silent mock
    if (apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not set in .env');
    }

    final basePrice = form.basePrice ?? 0;

    // Map governorate slug → Arabic display name for a more accurate prompt
    const govNames = {
      'cairo': 'القاهرة',
      'giza': 'الجيزة',
      'alexandria': 'الإسكندرية',
      'qalyubia': 'القليوبية',
      'dakahlia': 'الدقهلية',
      'gharbia': 'الغربية',
      'monufia': 'المنوفية',
      'beheira': 'البحيرة',
      'damietta': 'دمياط',
      'sharkia': 'الشرقية',
      'kafr_el_sheikh': 'كفر الشيخ',
      'ismailia': 'الإسماعيلية',
      'suez': 'السويس',
      'port_said': 'بورسعيد',
      'beni_suef': 'بني سويف',
      'fayoum': 'الفيوم',
      'minya': 'المنيا',
      'asyut': 'أسيوط',
      'sohag': 'سوهاج',
      'qena': 'قنا',
      'luxor': 'الأقصر',
      'aswan': 'أسوان',
      'red_sea': 'البحر الأحمر',
      'south_sinai': 'جنوب سيناء',
      'north_sinai': 'شمال سيناء',
      'matrouh': 'مطروح',
      'new_valley': 'الوادي الجديد',
    };

    final govDisplay =
        govNames[form.governorateSlug] ?? form.governorateSlug;
    final listingAr = form.isRent ? 'إيجار' : 'بيع';
    final furnishedAr = form.isFurnished ? 'مفروشة' : 'غير مفروشة';

    const typeNames = {
      'apartment': 'شقة',
      'villa': 'فيلا',
      'studio': 'استوديو',
      'penthouse': 'بنتهاوس',
      'duplex': 'دوبلكس',
      'chalet': 'شاليه',
    };
    final typeDisplay = typeNames[form.propertyType] ?? form.propertyType;

    final prompt = '''
أنت خبير تقييم عقارات في مصر. بناءً على المعطيات التالية، قيّم السعر المطلوب وقدّم توصية.

تفاصيل العقار:
- النوع: $typeDisplay
- المحافظة: $govDisplay
- المساحة: ${form.areaM2 ?? 'غير محددة'} م²
- غرف النوم: ${form.totalRooms ?? 'غير محددة'}
- الحمامات: ${form.bathrooms ?? 'غير محددة'}
- التأثيث: $furnishedAr
- نوع الإعلان: $listingAr
- السعر المطلوب: $basePrice جنيه مصري

قواعد الرد (مهم جداً):
١. أجب فقط بـ JSON صالح — لا شرح، لا markdown، لا أكواد.
٢. استخدم هذا الشكل بالضبط:
{"suggested": NUMBER, "min": NUMBER, "max": NUMBER, "label": "offer"|"normal"|"verified", "confidence": "low"|"medium"|"high", "explanation_ar": "جملة واحدة قصيرة باللغة العربية"}

تعريف التصنيفات:
- offer: السعر أقل من المتوسط بـ 15% أو أكثر (صفقة ممتازة للمستأجر/المشتري)
- verified: السعر في النطاق المعقول (±15% من المتوسط)
- normal: السعر أعلى من المتوسط بـ 15% أو أكثر

مثال على الرد:
{"suggested": 5000, "min": 4250, "max": 5750, "label": "verified", "confidence": "high", "explanation_ar": "السعر مناسب لشقة مفروشة في هذه المنطقة"}
''';

    final response = await http
        .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'llama-3.3-70b-versatile',
            'max_tokens': 200,
            'temperature': 0.2,
            'messages': [
              {'role': 'user', 'content': prompt},
            ],
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 429) {
      throw Exception('quota_exceeded');
    }
    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content =
        (body['choices'] as List).first['message']['content'] as String;

    // Strip markdown fences if model adds them
    final clean = content
        .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    Map<String, dynamic> data;
    try {
      data = jsonDecode(clean) as Map<String, dynamic>;
    } catch (_) {
      // Try to extract JSON from within any surrounding text
      final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(clean);
      if (match == null) throw Exception('Invalid JSON response from AI');
      data = jsonDecode(match.group(0)!) as Map<String, dynamic>;
    }

    final suggested = (data['suggested'] as num?)?.toDouble() ?? basePrice;
    final min = (data['min'] as num?)?.toDouble() ?? suggested * 0.85;
    final max = (data['max'] as num?)?.toDouble() ?? suggested * 1.15;
    final label = (data['label'] as String?)?.toLowerCase() ?? 'normal';
    final confidenceStr =
        (data['confidence'] as String?)?.toLowerCase() ?? 'medium';
    final explanationAr =
        (data['explanation_ar'] as String?) ?? '';

    // Validate label is one of the DB-allowed values
    final safeLabel =
        ['offer', 'verified', 'normal'].contains(label) ? label : 'normal';

    final confidence = switch (confidenceStr) {
      'high' => AiConfidence.high,
      'low' => AiConfidence.low,
      _ => AiConfidence.medium,
    };

    return AiPriceResult(
      suggestedPrice: suggested,
      minPrice: min,
      maxPrice: max,
      priceLabel: safeLabel,
      confidence: confidence,
      explanation: explanationAr,
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
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────────────────
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

        // ── Body ──────────────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: switch (_state) {
            _CheckState.idle => _IdleCard(
              key: const ValueKey('idle'),
              onCheck: _check,
            ),
            _CheckState.loading =>
              const _LoadingCard(key: ValueKey('loading')),
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
  const _ResultCard(
      {super.key, required this.result, required this.onReCheck});

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
          // ── Label row ────────────────────────────────────────────────
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
                padding:
                    context.rSymmetric(horizontal: 8, vertical: 4),
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

          // ── Price stats ──────────────────────────────────────────────
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

          // ── Explanation ──────────────────────────────────────────────
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

          // ── Re-check ─────────────────────────────────────────────────
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