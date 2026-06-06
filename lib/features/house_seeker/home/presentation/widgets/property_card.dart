import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/property_model.dart';
import 'package:aqar_hub/core/location/helper/location_display_helper.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final int index;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.index = 0,
  });

  /// A property is "fully occupied" when:
  ///   - it has rental options AND all of them have availableQuantity == 0
  ///   OR
  ///   - isRented == true (whole apartment marked as rented)
  bool get _isFullyOccupied {
    if (property.isRented) return true;
    if (property.rentalOptions.isEmpty) return false;
    return property.rentalOptions.every((o) => o.availableQuantity <= 0);
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimations.combined(
      type: CombineType.fadeSlide,
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: index * 60),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: context.rOnly(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(18)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.07),
                blurRadius: context.r(16),
                offset: Offset(0, context.r(4)),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageSection(
                property: property,
                isFavorite: isFavorite,
                onFavoriteTap: onFavoriteTap,
                isFullyOccupied: _isFullyOccupied,
              ),
              _DetailsSection(property: property),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Image + badges ─────────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  final PropertyModel property;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final bool isFullyOccupied;

  const _ImageSection({
    required this.property,
    required this.isFavorite,
    required this.isFullyOccupied,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(18))),
      child: Stack(
        children: [
          // ── Property image ─────────────────────────────────────────────
          SizedBox(
            height: context.r(190),
            width: double.infinity,
            child: property.firstImage != null
                ? CachedNetworkImage(
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
                    errorWidget: (_, __, ___) => _PlaceholderImage(),
                  )
                : _PlaceholderImage(),
          ),

          // ── Fully occupied overlay (replaces old "rented" overlay) ─────
          // Triggered by isRented (whole unit) OR all rental options = 0
          if (isFullyOccupied)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.70),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: context.rSymmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade700,
                      borderRadius: BorderRadius.circular(context.r(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: context.r(12),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.do_not_disturb_rounded,
                          color: Colors.white,
                          size: context.r(16),
                        ),
                        SizedBox(width: context.r(6)),
                        Text(
                          property.isRented
                              ? 'property_rented'.tr(context)
                              : 'property_fully_occupied'.tr(context),
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Badges (top-start) ─────────────────────────────────────────
          Positioned(
            top: context.r(10),
            left: context.r(10),
            child: Row(
              children: [
                if (property.isVerified)
                  _Badge(
                    label: 'badge_verified'.tr(context),
                    color: const Color(0xFF1E88E5),
                  ),
                if (property.isOffer) ...[
                  SizedBox(width: context.r(6)),
                  _Badge(
                    label: 'badge_offer'.tr(context),
                    color: const Color(0xFFF57C00),
                  ),
                ],
              ],
            ),
          ),

          // ── Favorite button (top-end) ──────────────────────────────────
          Positioned(
            top: context.r(10),
            right: context.r(10),
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onTap: onFavoriteTap,
            ),
          ),

          // ── Image count indicator ──────────────────────────────────────
          if (property.imageUrls.length > 1)
            Positioned(
              bottom: context.r(10),
              right: context.r(10),
              child: Container(
                padding: context.rSymmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(context.r(8)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: context.r(12),
                      color: Colors.white,
                    ),
                    SizedBox(width: context.r(4)),
                    Text(
                      '${property.imageUrls.length}',
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(11),
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Details section ───────────────────────────────────────────────────────────

class _DetailsSection extends StatelessWidget {
  final PropertyModel property;
  const _DetailsSection({required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rAll(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ───────────────────────────────────────────────────────
          Text(
            property.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: context.sp(15),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(4)),

          // ── Location ────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: context.r(13),
                color: Colors.grey.shade500,
              ),
              SizedBox(width: context.r(3)),
              Expanded(
                child: Text(
                  LocationDisplayHelper.fullLabel(
                    context: context,
                    address: property.address,
                    governorateSlug: property.governorateSlug,
                    citySlug: property.citySlug,
                    areaSlug: property.areaSlug,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(11),
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.r(10)),

          // ── Quick stats row ─────────────────────────────────────────────
          Row(
            children: [
              if (property.totalRooms != null)
                _StatChip(
                  icon: Icons.bed_outlined,
                  value: '${property.totalRooms}',
                  label: 'stat_rooms'.tr(context),
                ),
              if (property.bathrooms != null) ...[
                SizedBox(width: context.r(8)),
                _StatChip(
                  icon: Icons.bathtub_outlined,
                  value: '${property.bathrooms}',
                  label: 'stat_bath'.tr(context),
                ),
              ],
              if (property.areaM2 != null) ...[
                SizedBox(width: context.r(8)),
                _StatChip(
                  icon: Icons.straighten_outlined,
                  value: '${property.areaM2?.toInt()}',
                  label: 'stat_area'.tr(context),
                ),
              ],
              const Spacer(),
              if (property.isFurnished)
                Container(
                  padding: context.rSymmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.r(6)),
                  ),
                  child: Text(
                    'filter_furnished_yes'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(10),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00897B),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.r(12)),

          // ── Price row ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (property.displayPrice != null) ...[
                Text(
                  PropertyHelpers.formatPrice(property.displayPrice!, context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(17),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                if (!property.isForSale)
                  Padding(
                    padding: context.rOnly(bottom: 1, right: 2),
                    child: Text(
                      ' / ${'price_per_month'.tr(context)}',
                      style: GoogleFonts.tajawal(
                        fontSize: context.sp(10),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
              const Spacer(),
              _AudienceChip(audience: property.targetAudience),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: context.rSymmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(context.r(7)),
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

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  const _FavoriteButton({required this.isFavorite, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: context.r(34),
      height: context.r(34),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: context.r(6),
          ),
        ],
      ),
      child: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFavorite ? Colors.redAccent : Colors.grey.shade500,
        size: context.r(18),
      ),
    ),
  );
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: context.r(13), color: Colors.grey.shade500),
      SizedBox(width: context.r(3)),
      Text(
        '$value $label',
        style: GoogleFonts.tajawal(
          fontSize: context.sp(11),
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}

class _AudienceChip extends StatelessWidget {
  final String audience;
  const _AudienceChip({required this.audience});

  Color get _color => switch (audience) {
    'male' => const Color(0xFF1E88E5),
    'female' => const Color(0xFFE91E8C),
    'family' => const Color(0xFF43A047),
    _ => Colors.grey.shade500,
  };

  IconData get _icon => switch (audience) {
    'male' => Icons.male_rounded,
    'female' => Icons.female_rounded,
    'family' => Icons.family_restroom_rounded,
    _ => Icons.people_outline_rounded,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: context.rSymmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(context.r(7)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: context.r(12), color: _color),
        SizedBox(width: context.r(3)),
        Text(
          PropertyHelpers.audienceLabel(audience, context),
          style: GoogleFonts.tajawal(
            fontSize: context.sp(10),
            fontWeight: FontWeight.w600,
            color: _color,
          ),
        ),
      ],
    ),
  );
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.grey.shade100,
    child: Center(
      child: Icon(
        Icons.apartment_rounded,
        size: context.r(40),
        color: Colors.grey.shade300,
      ),
    ),
  );
}
