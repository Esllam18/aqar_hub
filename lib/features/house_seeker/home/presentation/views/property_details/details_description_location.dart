// lib/features/house_seeker/home/presentation/views/property_details/details_description_location.dart
//
// Expandable description card + location card + owner-only bottom bar.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Description ───────────────────────────────────────────────────────────────

class DetailsDescriptionSection extends StatelessWidget {
  final String description;
  final bool expanded;
  final VoidCallback onToggle;
  const DetailsDescriptionSection({
    super.key,
    required this.description,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (description.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: context.rAll(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: context.r(14),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'details_description'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(15),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(8)),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: Text(
              description,
              maxLines: expanded ? null : 4,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                color: Colors.grey.shade700,
                height: 1.7,
              ),
            ),
          ),
          if (description.trim().length > 140)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: onToggle,
                child: Text(
                  expanded
                      ? 'btn_show_less'.tr(context)
                      : 'btn_show_more'.tr(context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Location card ─────────────────────────────────────────────────────────────

class DetailsLocationCard extends StatelessWidget {
  final String? address;
  final String? city;
  final VoidCallback onOpen;
  const DetailsLocationCard({
    super.key,
    this.address,
    this.city,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final label = [
      address,
      city,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: double.infinity,
        padding: context.rAll(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: context.r(14),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.r(46),
              height: context.r(46),
              decoration: BoxDecoration(
                color: const Color(0xFF34A853).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(context.r(14)),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: const Color(0xFF34A853),
                size: context.r(24),
              ),
            ),
            SizedBox(width: context.r(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'details_location'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(13),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                  if (label.isNotEmpty) ...[
                    SizedBox(height: context.r(2)),
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(11),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: context.r(8)),
            Container(
              padding: context.rSymmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF34A853).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(context.r(8)),
              ),
              child: Text(
                'details_open_maps'.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF34A853),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Owner-only bottom bar (location button only) ──────────────────────────────

class DetailsLocationOnlyBar extends StatelessWidget {
  final VoidCallback onLocation;
  const DetailsLocationOnlyBar({super.key, required this.onLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(
        left: 16,
        right: 16,
        top: 14,
        bottom: 14 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: context.r(18),
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: context.r(50),
        child: ElevatedButton.icon(
          onPressed: onLocation,
          icon: Icon(Icons.location_on_rounded, size: context.r(18)),
          label: Text(
            'details_btn_location'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(14),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(16)),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
