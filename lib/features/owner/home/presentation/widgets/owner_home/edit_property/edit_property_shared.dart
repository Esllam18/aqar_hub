// lib/features/owner/home/presentation/widgets/owner_home/edit_property/edit_property_shared.dart
//
// Shared form widgets used across all edit property sections:
// SectionCard, Field, ChipSelector, NumberChipSelector, ToggleRow,
// AlertBanner, StatusBanner, ImageEditorGrid, ImageThumb.

import 'dart:io';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Section card ──────────────────────────────────────────────────────────────

class EditSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const EditSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: context.rAll(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: context.r(18), color: AppColors.primary),
              SizedBox(width: context.r(8)),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(14)),
          ...children,
        ],
      ),
    );
  }
}

// ── Text field ────────────────────────────────────────────────────────────────

class EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? suffix;
  final int? minLines;
  final int? maxLines;

  const EditField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffix,
    this.minLines,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines ?? 1,
      style: GoogleFonts.tajawal(fontSize: context.sp(14)),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: GoogleFonts.tajawal(
          fontSize: context.sp(13),
          color: Colors.grey,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(12)),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.r(12)),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        contentPadding: context.rSymmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

// ── Chip selector ─────────────────────────────────────────────────────────────

class EditChipSelector<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;

  const EditChipSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(12),
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: context.r(8)),
        Wrap(
          spacing: context.r(8),
          runSpacing: context.r(8),
          children: options.map((opt) {
            final sel = opt == selected;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: context.rSymmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(context.r(10)),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  labelBuilder(opt),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(12.5),
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : const Color(0xFF1B2D5E),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Number chip selector ──────────────────────────────────────────────────────

class EditNumberChipSelector extends StatelessWidget {
  final String label;
  final List<int> options;
  final int? selected;
  final void Function(int?) onChanged;

  const EditNumberChipSelector({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(12),
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: context.r(8)),
        Wrap(
          spacing: context.r(8),
          runSpacing: context.r(8),
          children: options.map((n) {
            final sel = n == selected;
            return GestureDetector(
              onTap: () => onChanged(sel ? null : n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: context.r(44),
                height: context.r(36),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(context.r(10)),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  '$n',
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : const Color(0xFF1B2D5E),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Toggle row ────────────────────────────────────────────────────────────────

class EditToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  final Color? activeColor;

  const EditToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13.5),
              color: const Color(0xFF1B2D5E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeColor ?? AppColors.primary,
        ),
      ],
    );
  }
}

// ── Alert banner ──────────────────────────────────────────────────────────────

class EditAlertBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const EditAlertBanner({
    super.key,
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rAll(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: context.r(16)),
          SizedBox(width: context.r(8)),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12),
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status banner (rented) ────────────────────────────────────────────────────

class EditStatusBanner extends StatelessWidget {
  final bool isRented;
  const EditStatusBanner({super.key, required this.isRented});

  @override
  Widget build(BuildContext context) {
    if (!isRented) return const SizedBox.shrink();
    return Container(
      padding: context.rAll(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_rounded, color: AppColors.error, size: context.r(20)),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Text(
              'owner_rented_status_banner'.tr(context),
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image editor grid ─────────────────────────────────────────────────────────

class EditImageEditorGrid extends StatelessWidget {
  final List<String> keptUrls;
  final List<File> newFiles;
  final void Function(int) onRemoveExisting;
  final void Function(int) onRemoveNew;
  final VoidCallback onAdd;

  const EditImageEditorGrid({
    super.key,
    required this.keptUrls,
    required this.newFiles,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final total = keptUrls.length + newFiles.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (total == 0)
          Center(
            child: Padding(
              padding: context.rSymmetric(vertical: 12),
              child: Text(
                'edit_no_images'.tr(context),
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(13),
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        Wrap(
          spacing: context.r(10),
          runSpacing: context.r(10),
          children: [
            ...List.generate(
              keptUrls.length,
              (i) => _ImageThumb(
                child: CachedNetworkImage(
                  imageUrl: keptUrls[i],
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
                onRemove: () => onRemoveExisting(i),
              ),
            ),
            ...List.generate(
              newFiles.length,
              (i) => _ImageThumb(
                onRemove: () => onRemoveNew(i),
                isNew: true,
                child: Image.file(newFiles[i], fit: BoxFit.cover),
              ),
            ),
            // Add button
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: context.r(88),
                height: context.r(88),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.primary,
                      size: context.r(26),
                    ),
                    SizedBox(height: context.r(4)),
                    Text(
                      'edit_add_photos'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(10),
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (total > 0)
          Padding(
            padding: context.rOnly(top: 8),
            child: Text(
              '$total ${'edit_photos_count'.tr(context)}',
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  final bool isNew;
  const _ImageThumb({
    required this.child,
    required this.onRemove,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: context.r(88),
          height: context.r(88),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.r(12)),
            border: isNew
                ? Border.all(
                    color: const Color(0xFF43A047).withValues(alpha: 0.6),
                    width: 2,
                  )
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: context.r(22),
              height: context.r(22),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: context.r(13),
              ),
            ),
          ),
        ),
        if (isNew)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'new',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
