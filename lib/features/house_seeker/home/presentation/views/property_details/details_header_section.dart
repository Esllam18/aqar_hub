// lib/features/house_seeker/home/presentation/views/property_details/details_header_section.dart
//
// Title, price, listing-type tags for the property details screen.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsHeaderSection extends StatelessWidget {
  final PropertyModel property;
  const DetailsHeaderSection({super.key, required this.property});

  String _typeLabel(BuildContext ctx, String? type) => switch (type) {
        'villa' => 'property_type_villa'.tr(ctx),
        'studio' => 'property_type_studio'.tr(ctx),
        'penthouse' => 'property_type_penthouse'.tr(ctx),
        'duplex' => 'property_type_duplex'.tr(ctx),
        'chalet' => 'property_type_chalet'.tr(ctx),
        _ => 'propertytypeapartment'.tr(ctx),
      };

  @override
  Widget build(BuildContext context) {
    final p = property;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: context.r(8),
          runSpacing: context.r(8),
          children: [
            _Tag(
              text: _typeLabel(context, p.propertyType),
              color: AppColors.primary,
              bg: AppColors.primary.withValues(alpha: 0.08),
            ),
            _Tag(
              text: p.isForSale
                  ? 'home_filter_sale'.tr(context)
                  : 'home_filter_rent'.tr(context),
              color: p.isForSale
                  ? const Color(0xFF8E24AA)
                  : const Color(0xFF43A047),
              bg: (p.isForSale
                      ? const Color(0xFF8E24AA)
                      : const Color(0xFF43A047))
                  .withValues(alpha: 0.08),
            ),
            if (p.priceLabel == 'verified')
              _Tag(
                text: 'badge_verified'.tr(context),
                color: const Color(0xFF1565C0),
                bg: const Color(0xFF1565C0).withValues(alpha: 0.08),
              ),
            if (p.priceLabel == 'offer')
              _Tag(
                text: 'badge_offer'.tr(context),
                color: const Color(0xFFFF9800),
                bg: const Color(0xFFFF9800).withValues(alpha: 0.10),
              ),
          ],
        ),
        SizedBox(height: context.r(12)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                p.title,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(21),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                  height: 1.25,
                ),
              ),
            ),
            if (p.displayPrice != null) ...[
              SizedBox(width: context.r(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PropertyHelpers.formatPrice(p.displayPrice!, context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(18),
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  if (!p.isForSale)
                    Text(
                      'price_per_month'.tr(context),
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(10),
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const _Tag({required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: context.sp(10.5),
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
