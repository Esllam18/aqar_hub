// lib/features/owner/home/presentation/views/add_property/add_property_shared.dart
// Shared helpers, decorations, and micro-widgets used across all wizard steps.
// Having them here keeps every step file under 100 lines.

// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Step scroll wrapper ───────────────────────────────────────────────────────

Widget stepScroll(BuildContext context, Widget child) =>
    SingleChildScrollView(padding: context.rAll(16), child: child);

// ── Section title ─────────────────────────────────────────────────────────────

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.rOnly(bottom: 12),
    child: Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: context.sp(15),
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1B2D5E),
      ),
    ),
  );
}

// ── Hint text ─────────────────────────────────────────────────────────────────

class HintText extends StatelessWidget {
  final String text;
  const HintText(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: context.rOnly(bottom: 14),
    child: Text(
      text,
      style: GoogleFonts.tajawal(
        fontSize: context.sp(12),
        color: Colors.grey.shade500,
        height: 1.4,
      ),
    ),
  );
}

// ── Required / Optional badges ────────────────────────────────────────────────

class RequiredBadge extends StatelessWidget {
  const RequiredBadge({super.key});
  @override
  Widget build(BuildContext context) =>
      _badge(context, 'addprop_required_label'.tr(context), Colors.redAccent);
}

class OptionalBadge extends StatelessWidget {
  const OptionalBadge({super.key});
  @override
  Widget build(BuildContext context) => _badge(
    context,
    'addprop_optional'.tr(context),
    Colors.grey.shade500,
    bg: Colors.grey.shade100,
  );
}

Widget _badge(BuildContext context, String text, Color color, {Color? bg}) =>
    Container(
      padding: context.rSymmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg ?? color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(context.r(6)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: context.sp(10),
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

// ── Input field ───────────────────────────────────────────────────────────────

Widget inputField({
  required BuildContext context,
  required String hint,
  required ValueChanged<String> onChanged,
  String? initialValue,
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffix,
  Widget? prefix,
  bool readOnly = false,
  VoidCallback? onTap,
  TextEditingController? controller,
}) {
  final radius = BorderRadius.circular(context.r(12));
  final border = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
  );
  final focused = OutlineInputBorder(
    borderRadius: radius,
    borderSide: const BorderSide(color: AppColors.primary),
  );
  final error = OutlineInputBorder(
    borderRadius: radius,
    borderSide: const BorderSide(color: Colors.redAccent),
  );

  return TextFormField(
    controller: controller,
    initialValue: controller == null ? initialValue : null,
    readOnly: readOnly,
    onTap: onTap,
    keyboardType: keyboardType,
    maxLines: maxLines,
    inputFormatters: inputFormatters,
    style: GoogleFonts.tajawal(fontSize: context.sp(14)),
    validator: validator,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(
        fontSize: context.sp(13),
        color: Colors.grey.shade400,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: context.rSymmetric(horizontal: 14, vertical: 14),
      prefixIcon: prefix,
      suffixIcon: suffix,
      border: border,
      enabledBorder: border,
      focusedBorder: focused,
      errorBorder: error,
      focusedErrorBorder: error,
    ),
  );
}

// ── Chip group ────────────────────────────────────────────────────────────────

class ChipGroup<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(BuildContext, T) label;
  final ValueChanged<T> onSelected;

  const ChipGroup({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.r(10),
      runSpacing: context.r(10),
      children: values.map((v) {
        final active = v == selected;
        return GestureDetector(
          onTap: () => onSelected(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: context.rSymmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(context.r(12)),
              border: Border.all(
                color: active
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.22),
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: context.r(8),
                        offset: Offset(0, context.r(2)),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label(context, v),
              style: GoogleFonts.cairo(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF1B2D5E),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Number chip selector ──────────────────────────────────────────────────────

class NumberChipSelector extends StatelessWidget {
  final String label;
  final int? value;
  final int max;
  final ValueChanged<int?> onChanged;

  const NumberChipSelector({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rOnly(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: context.r(8)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(context, null, 'addprop_any'.tr(context)),
                ...List.generate(max, (i) => _chip(context, i + 1, '${i + 1}')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, int? v, String text) {
    final active = value == v;
    return Padding(
      padding: context.rOnly(right: 8),
      child: GestureDetector(
        onTap: () => onChanged(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: context.r(52),
          height: context.r(42),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(context.r(10)),
            border: Border.all(
              color: active ? AppColors.primary : Colors.grey.withOpacity(0.25),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF1B2D5E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step alert banner ─────────────────────────────────────────────────────────

enum AlertBannerType { info, success, warning, tip }

class StepAlertBanner extends StatelessWidget {
  final String message;
  final AlertBannerType type;
  final IconData? icon;

  const StepAlertBanner({
    super.key,
    required this.message,
    this.type = AlertBannerType.info,
    this.icon,
  });

  Color get _bg => switch (type) {
    AlertBannerType.info => const Color(0xFFEFF6FF),
    AlertBannerType.success => const Color(0xFFF0FDF4),
    AlertBannerType.warning => const Color(0xFFFFFBEB),
    AlertBannerType.tip => const Color(0xFFF5F3FF),
  };

  Color get _border => switch (type) {
    AlertBannerType.info => const Color(0xFFBFDBFE),
    AlertBannerType.success => const Color(0xFFBBF7D0),
    AlertBannerType.warning => const Color(0xFFFDE68A),
    AlertBannerType.tip => const Color(0xFFDDD6FE),
  };

  Color get _iconColor => switch (type) {
    AlertBannerType.info => const Color(0xFF3B82F6),
    AlertBannerType.success => const Color(0xFF059669),
    AlertBannerType.warning => const Color(0xFFD97706),
    AlertBannerType.tip => const Color(0xFF7C3AED),
  };

  IconData get _defaultIcon => switch (type) {
    AlertBannerType.info => Icons.info_outline_rounded,
    AlertBannerType.success => Icons.check_circle_outline_rounded,
    AlertBannerType.warning => Icons.warning_amber_rounded,
    AlertBannerType.tip => Icons.tips_and_updates_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.rOnly(bottom: 20),
      padding: context.rAll(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon, size: context.r(18), color: _iconColor),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12.5),
                color: _iconColor.withOpacity(0.85),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image thumbnail ───────────────────────────────────────────────────────────

class ImageThumb extends StatelessWidget {
  final File file;
  final bool isCover;
  final VoidCallback onRemove;

  const ImageThumb({
    super.key,
    required this.file,
    required this.isCover,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(context.r(10)),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        if (isCover)
          Positioned(
            bottom: context.r(4),
            left: context.r(4),
            child: Container(
              padding: context.rSymmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(context.r(6)),
              ),
              child: Text(
                'addprop_cover'.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(9),
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        Positioned(
          top: context.r(4),
          right: context.r(4),
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: context.r(22),
              height: context.r(22),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: context.r(14),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
