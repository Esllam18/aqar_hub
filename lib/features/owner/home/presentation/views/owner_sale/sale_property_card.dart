// lib/features/owner/home/presentation/views/owner_sale/sale_property_card.dart
//
// Sale property card — image, badges, specs, price.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalePropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  const SalePropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = property;
    final hasImage = p.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.r(18),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.r(20))),
              child: SizedBox(
                height: context.r(190),
                width: double.infinity,
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: p.imageUrls.first,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(context),
                      )
                    : _placeholder(context),
              ),
            ),

            // Info
            Padding(
              padding: context.rAll(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Wrap(
                    spacing: context.r(6),
                    children: [
                      _Badge(
                          label: 'homefiltersale'.tr(context),
                          color: const Color(0xFF7C3AED)),
                      _Badge(
                        label: 'propertytype_${p.propertyType}'.tr(context),
                        color: AppColors.primary,
                        outlined: true,
                      ),
                      if (p.isRented)
                        _Badge(
                            label: 'propertyrented'.tr(context),
                            color: Colors.redAccent),
                    ],
                  ),
                  SizedBox(height: context.r(10)),

                  // Title
                  Text(
                    p.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B2D5E),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: context.r(6)),

                  // Location
                  Row(children: [
                    Icon(Icons.location_on_rounded,
                        size: context.r(13), color: Colors.grey.shade400),
                    SizedBox(width: context.r(3)),
                    Expanded(
                      child: Text(
                        [
                          if (p.address.isNotEmpty) p.address,
                          if (p.city.isNotEmpty) p.city,
                        ].join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                            fontSize: context.sp(11.5),
                            color: Colors.grey.shade500),
                      ),
                    ),
                  ]),
                  SizedBox(height: context.r(12)),

                  // Specs
                  Row(children: [
                    if (p.totalRooms != null)
                      _SpecChip(
                          icon: Icons.meeting_room_outlined,
                          label: '${p.totalRooms} ${'stat_rooms'.tr(context)}'),
                    if (p.bathrooms != null) ...[
                      SizedBox(width: context.r(8)),
                      _SpecChip(
                          icon: Icons.bathtub_outlined,
                          label: '${p.bathrooms} ${'stat_bath'.tr(context)}'),
                    ],
                    if (p.areaM2 != null) ...[
                      SizedBox(width: context.r(8)),
                      _SpecChip(
                          icon: Icons.straighten_rounded,
                          label: '${p.areaM2!.toStringAsFixed(0)} m²'),
                    ],
                  ]),
                  SizedBox(height: context.r(14)),

                  // Price + arrow
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'addprop_base_price_sale_hint'.tr(context),
                            style: GoogleFonts.tajawal(
                                fontSize: context.sp(10),
                                color: Colors.grey.shade400),
                          ),
                          SizedBox(height: context.r(2)),
                          Text(
                            p.basePrice != null
                                ? PropertyHelpers.formatPrice(
                                    p.basePrice!, context)
                                : '—',
                            style: GoogleFonts.cairo(
                              fontSize: context.sp(18),
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: context.r(38),
                      height: context.r(38),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          color: const Color(0xFF7C3AED), size: context.r(18)),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: const Color(0xFFF1F5F9),
        child: Center(
          child: Icon(Icons.apartment_rounded,
              color: Colors.grey.shade300, size: context.r(48)),
        ),
      );
}

// ── Badge ──────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  const _Badge({required this.label, required this.color, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(context.r(20)),
        border: outlined ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Text(label,
          style: GoogleFonts.tajawal(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

// ── Spec chip ─────────────────────────────────────────────────────────────────

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SpecChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: context.r(12), color: Colors.grey.shade500),
        SizedBox(width: context.r(4)),
        Text(label,
            style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
