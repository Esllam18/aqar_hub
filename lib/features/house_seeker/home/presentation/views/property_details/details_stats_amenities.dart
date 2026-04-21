// lib/features/house_seeker/home/presentation/views/property_details/details_stats_amenities.dart
//
// Quick stats row + amenities chip grid.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Quick stats ───────────────────────────────────────────────────────────────

class DetailsQuickStats extends StatelessWidget {
  final PropertyModel property;
  const DetailsQuickStats({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final p = property;
    final stats = <Map<String, dynamic>>[
      if (p.totalRooms != null)
        {
          'icon': Icons.bed_outlined,
          'value': '${p.totalRooms}',
          'label': 'stat_rooms'.tr(context),
        },
      if (p.bathrooms != null)
        {
          'icon': Icons.bathtub_outlined,
          'value': '${p.bathrooms}',
          'label': 'stat_bath'.tr(context),
        },
      if (p.areaM2 != null)
        {
          'icon': Icons.straighten_outlined,
          'value': '${p.areaM2?.toInt()} m²',
          'label': 'stat_area'.tr(context),
        },
      if (p.totalBeds != null)
        {
          'icon': Icons.single_bed_outlined,
          'value': '${p.totalBeds}',
          'label': 'stat_beds'.tr(context),
        },
    ];

    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: context.rAll(14),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats
            .map(
              (s) => _StatItem(
                icon: s['icon'] as IconData,
                value: s['value'] as String,
                label: s['label'] as String,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: context.r(20), color: AppColors.primary),
        SizedBox(height: context.r(4)),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: context.sp(14),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2D5E),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: context.sp(10),
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

// ── Amenities grid ────────────────────────────────────────────────────────────

class DetailsAmenitiesSection extends StatelessWidget {
  final List<String> amenities;
  const DetailsAmenitiesSection({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox.shrink();
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'details_amenities'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(15),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(12)),
          Wrap(
            spacing: context.r(8),
            runSpacing: context.r(8),
            children: amenities.map((a) => _AmenityChip(label: a)).toList(),
          ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  const _AmenityChip({required this.label});

  IconData _icon() {
    final l = label.toLowerCase();
    if (l.contains('wifi') || l.contains('internet')) return Icons.wifi_rounded;
    if (l.contains('park')) return Icons.local_parking_rounded;
    if (l.contains('gym') || l.contains('sport')) return Icons.fitness_center_rounded;
    if (l.contains('pool') || l.contains('swim')) return Icons.pool_rounded;
    if (l.contains('security') || l.contains('guard')) return Icons.security_rounded;
    if (l.contains('elevator') || l.contains('lift')) return Icons.elevator_rounded;
    if (l.contains('balcony') || l.contains('terrace')) return Icons.balcony_rounded;
    if (l.contains('laundry') || l.contains('washer')) return Icons.local_laundry_service_rounded;
    if (l.contains('air') || l.contains('ac')) return Icons.ac_unit_rounded;
    if (l.contains('garden') || l.contains('yard')) return Icons.yard_rounded;
    if (l.contains('storage')) return Icons.inventory_2_rounded;
    if (l.contains('pet')) return Icons.pets_rounded;
    return Icons.check_circle_outline_rounded;
  }

  String _displayLabel(BuildContext context) {
    try {
      final translated = label.tr(context);
      return (translated == label || translated.isEmpty) ? label : translated;
    } catch (_) {
      return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: context.r(13), color: AppColors.primary),
          SizedBox(width: context.r(5)),
          Text(
            _displayLabel(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11.5),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2D5E),
            ),
          ),
        ],
      ),
    );
  }
}
