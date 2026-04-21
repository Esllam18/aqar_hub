// filter_sheet_widgets.dart — Reusable sheet primitives shared across all filter bottom sheets
// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Generic choice bottom sheet container ─────────────────────────────────────

class FilterChoiceSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const FilterChoiceSheet({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.72,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.r(24)),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: context.r(12)),
            Container(
              width: context.r(40),
              height: context.r(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(context.r(4)),
              ),
            ),
            SizedBox(height: context.r(14)),
            Padding(
              padding: context.rSymmetric(horizontal: 18),
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                ),
              ),
            ),
            SizedBox(height: context.r(14)),
            Expanded(
              child: ListView.separated(
                padding: context.rOnly(
                  left: 18,
                  right: 18,
                  bottom: 18 + MediaQuery.paddingOf(context).bottom,
                ),
                itemCount: children.length,
                separatorBuilder: (_, __) => SizedBox(height: context.r(8)),
                itemBuilder: (_, i) => children[i],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet tile ────────────────────────────────────────────────────────────────

class FilterSheetTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const FilterSheetTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(context.r(14)),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: context.rSymmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.35)
                : Colors.grey.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(14),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFF1B2D5E),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: context.r(18),
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Filter chip button ────────────────────────────────────────────────────────

class FilterChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const FilterChipButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(context.r(14)),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: context.rSymmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.withOpacity(0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isActive ? 0.16 : 0.05),
              blurRadius: context.r(8),
              offset: Offset(0, context.r(2)),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.r(16),
              color: isActive ? Colors.white : const Color(0xFF1B2D5E),
            ),
            SizedBox(width: context.r(8)),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF1B2D5E),
              ),
            ),
            SizedBox(width: context.r(4)),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: context.r(16),
              color: isActive ? Colors.white : const Color(0xFF1B2D5E),
            ),
          ],
        ),
      ),
    );
  }
}
