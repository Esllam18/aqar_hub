// lib/features/owner/home/presentation/widgets/owner_home/property_card/property_card_widgets.dart
//
// All stateless sub-widgets for OwnerPropertyCard:
// HeaderImage, TopMetaRow, LocationRow, RentalOptionTile,
// InfoChip, ActionButton, Badge, SectionTitle,
// SheetTitle, ModernSheet, CircleIconButton.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:aqar_hub/core/location/helper/location_display_helper.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Header image ──────────────────────────────────────────────────────────────

class CardHeaderImage extends StatelessWidget {
  final OwnerPropertyModel property;
  const CardHeaderImage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(context.r(24))),
      child: SizedBox(
        height: context.r(210),
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (property.firstImage != null)
              CachedNetworkImage(
                imageUrl: property.firstImage!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: context.r(2),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => _placeholder(context),
              )
            else
              _placeholder(context),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.42),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Badges
            Positioned(
              top: context.r(14),
              left: context.r(14),
              right: context.r(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: context.r(6),
                      runSpacing: context.r(6),
                      children: [
                        if (property.isVerified)
                          CardBadge(
                            label: 'badgeverified'.tr(context),
                            color: const Color(0xFF2563EB),
                          ),
                        if (property.isOffer)
                          CardBadge(
                            label: 'badgeoffer'.tr(context),
                            color: const Color(0xFFF59E0B),
                          ),
                      ],
                    ),
                  ),
                  if (property.isRented)
                    CardBadge(
                      label: 'propertyrented'.tr(context),
                      color: const Color(0xFFEF4444),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: const Color(0xFFF8FAFC),
        child: Icon(Icons.apartment_rounded,
            color: Colors.grey.shade300, size: context.r(46)),
      );
}

// ── Top meta row (audience pill + price) ─────────────────────────────────────

class CardTopMetaRow extends StatelessWidget {
  final OwnerPropertyModel property;
  const CardTopMetaRow({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: context.rSymmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(context.r(999)),
            ),
            child: Text(
              PropertyHelpers.audienceLabel(property.targetAudience, context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(11),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: context.r(10)),
        if (property.displayPrice != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                PropertyHelpers.formatPrice(property.displayPrice!, context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              if (!property.isForSale)
                Text(
                  'pricepermonth'.tr(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10.5),
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ── Location row ──────────────────────────────────────────────────────────────

class CardLocationRow extends StatelessWidget {
  final OwnerPropertyModel property;
  const CardLocationRow({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final locLabel = LocationDisplayHelper.fullLabel(
      context: context,
      address: property.address,
      governorateSlug: property.governorateSlug,
      citySlug: property.citySlug,
      areaSlug: property.areaSlug,
    );
    return Row(
      children: [
        Icon(Icons.location_on_outlined,
            size: context.r(15), color: Colors.grey.shade500),
        SizedBox(width: context.r(5)),
        Expanded(
          child: Text(
            locLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(11.5),
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Rental option tile ────────────────────────────────────────────────────────

class CardRentalOptionTile extends StatelessWidget {
  final RentalOptionModel option;
  final VoidCallback onTap;
  const CardRentalOptionTile(
      {super.key, required this.option, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBooked = option.availableQuantity <= 0;
    final isLimited =
        option.availableQuantity > 0 && option.availableQuantity <= 2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(16)),
      child: Container(
        margin: context.rOnly(bottom: 10),
        padding: context.rAll(13),
        decoration: BoxDecoration(
          color: isBooked
              ? const Color(0xFFF8FAFC)
              : AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: isBooked
                ? const Color(0xFFE2E8F0)
                : AppColors.primary.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: context.r(42),
              height: context.r(42),
              decoration: BoxDecoration(
                color: isBooked
                    ? Colors.grey.shade200
                    : AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
              child: Icon(
                option.type == 'bed'
                    ? Icons.single_bed_outlined
                    : option.type == 'room'
                        ? Icons.bed_outlined
                        : Icons.apartment_outlined,
                color: isBooked ? Colors.grey : AppColors.primary,
              ),
            ),
            SizedBox(width: context.r(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PropertyHelpers.rentalTypeLabel(option.type, context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(12.5),
                      fontWeight: FontWeight.w700,
                      color: isBooked
                          ? Colors.grey.shade500
                          : const Color(0xFF102048),
                    ),
                  ),
                  SizedBox(height: context.r(3)),
                  Text(
                    isBooked
                        ? 'optionfullybooked'.tr(context)
                        : isLimited
                            ? 'optionlimited'.tr(context)
                            : '${option.availableQuantity}/${option.totalQuantity} ${'optionavailable'.tr(context)}',
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(10.8),
                      color: isBooked
                          ? Colors.grey.shade500
                          : isLimited
                              ? Colors.orange.shade700
                              : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${option.price.toInt()} ${'currency'.tr(context)}',
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: context.r(2)),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: context.r(18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────

class CardInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const CardInfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(context.r(999)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.r(13), color: AppColors.primary),
          SizedBox(width: context.r(5)),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(10.5),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool fullWidth;

  const CardActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(14)),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: context.rSymmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: activeColor.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, size: context.r(17), color: activeColor),
            SizedBox(width: context.r(7)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w700,
                  color: activeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class CardBadge extends StatelessWidget {
  final String label;
  final Color color;
  const CardBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rSymmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.r(9)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: context.sp(10),
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class CardSectionTitle extends StatelessWidget {
  final String title;
  const CardSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: context.sp(13),
          fontWeight: FontWeight.w800,
          color: const Color(0xFF102048),
        ),
      );
}

// ── Sheet title (drag handle + title text) ────────────────────────────────────

class CardSheetTitle extends StatelessWidget {
  final String title;
  const CardSheetTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.r(42),
          height: context.r(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(context.r(4)),
          ),
        ),
        SizedBox(height: context.r(16)),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: context.sp(16),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF102048),
          ),
        ),
      ],
    );
  }
}

// ── Modern sheet container ────────────────────────────────────────────────────

class CardModernSheet extends StatelessWidget {
  final Widget child;
  const CardModernSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(
        left: 20,
        right: 20,
        top: 16,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(28)),
        ),
      ),
      child: child,
    );
  }
}

// ── Circle icon button ────────────────────────────────────────────────────────

class CardCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const CardCircleIconButton(
      {super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(999)),
      child: Container(
        width: context.r(42),
        height: context.r(42),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.grey.shade100
              : AppColors.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: disabled ? Colors.grey.shade400 : AppColors.primary,
        ),
      ),
    );
  }
}
