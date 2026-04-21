import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/property_model.dart';
import '../../../helpers/property_helpers.dart';

class DetailsInfoRow extends StatelessWidget {
  final PropertyModel property;
  const DetailsInfoRow({super.key, required this.property});

  String _locationLabel() {
    final parts = <String>[
      if (property.address.trim().isNotEmpty) property.address.trim(),
      property.city.trim(),
    ];
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.r(8),
      runSpacing: context.r(8),
      children: [
        _InfoChip(
          icon: Icons.location_on_outlined,
          label: _locationLabel(),
          color: const Color(0xFFE53935),
        ),
        _InfoChip(
          icon: Icons.people_outline_rounded,
          label: PropertyHelpers.audienceLabel(
            property.targetAudience,
            context,
          ),
          color: const Color(0xFF1E88E5),
        ),
        _InfoChip(
          icon: property.isForSale ? Icons.sell_outlined : Icons.home_outlined,
          label: property.isForSale
              ? 'home_filter_sale'.tr(context)
              : 'home_filter_rent'.tr(context),
          color: const Color(0xFF43A047),
        ),
        if (property.isFurnished)
          _InfoChip(
            icon: Icons.chair_outlined,
            label: 'filter_furnished_yes'.tr(context),
            color: const Color(0xFF00897B),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
      padding: context.rSymmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: color.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: context.r(10),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.r(15), color: color),
          SizedBox(width: context.r(6)),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF30415D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
