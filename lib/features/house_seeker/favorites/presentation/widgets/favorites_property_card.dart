import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/navigation/navigation.dart';
import 'package:aqar_hub/core/services/navigation/transition_type.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/data/models/property_model.dart';
import '../cubit/favorites_cubit.dart';

class FavoritesPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final int index;

  const FavoritesPropertyCard({
    super.key,
    required this.property,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimations.combined(
      type: CombineType.fadeSlide,
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: index * 70),
      child: GestureDetector(
        onTap: () => Navigation.to(
          PropertyDetailsView(property: property),
          transition: TransitionType.slide,
        ),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ────────────────────────────────────────────────
              _CardImage(property: property),

              // ── Details ──────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: context.rAll(12),
                  child: _CardDetails(property: property),
                ),
              ),

              // ── Remove button ─────────────────────────────────────────
              Padding(
                padding: context.rOnly(top: 10, right: 10),
                child: _RemoveButton(propertyId: property.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Image ─────────────────────────────────────────────────────────────────────

class _CardImage extends StatelessWidget {
  final PropertyModel property;
  const _CardImage({required this.property});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.horizontal(
        left: Radius.circular(context.r(18)),
      ),
      child: SizedBox(
        width: context.r(110),
        height: context.r(130),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            property.firstImage != null
                ? CachedNetworkImage(
                    imageUrl: property.firstImage!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey.shade100),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.apartment_rounded,
                        color: Colors.grey.shade300,
                        size: context.r(28),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.apartment_rounded,
                      color: Colors.grey.shade300,
                      size: context.r(28),
                    ),
                  ),

            // Badge
            if (property.isVerified || property.isOffer)
              Positioned(
                bottom: context.r(6),
                left: context.r(6),
                child: Container(
                  padding: context.rSymmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: property.isVerified
                        ? const Color(0xFF1E88E5)
                        : const Color(0xFFF57C00),
                    borderRadius: BorderRadius.circular(context.r(6)),
                  ),
                  child: Text(
                    property.isVerified
                        ? 'badge_verified'.tr(context)
                        : 'badge_offer'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(8),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Rented overlay
            if (property.isRented)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: Text(
                      'property_rented'.tr(context),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(9),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Details ───────────────────────────────────────────────────────────────────

class _CardDetails extends StatelessWidget {
  final PropertyModel property;
  const _CardDetails({required this.property});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          property.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            fontSize: context.sp(13),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2D5E),
            height: 1.3,
          ),
        ),
        SizedBox(height: context.r(5)),

        // Location
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: context.r(12),
              color: Colors.grey.shade400,
            ),
            SizedBox(width: context.r(2)),
            Expanded(
              child: Text(
                property.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(10),
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.r(8)),

        // Stats
        Row(
          children: [
            if (property.totalRooms != null) ...[
              Icon(
                Icons.bed_outlined,
                size: context.r(11),
                color: Colors.grey.shade500,
              ),
              SizedBox(width: context.r(2)),
              Text(
                '${property.totalRooms}',
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(10),
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(width: context.r(8)),
            ],
            if (property.areaM2 != null) ...[
              Icon(
                Icons.straighten_outlined,
                size: context.r(11),
                color: Colors.grey.shade500,
              ),
              SizedBox(width: context.r(2)),
              Text(
                '${property.areaM2?.toInt()} م²',
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(10),
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: context.r(8)),

        // Price
        if (property.displayPrice != null)
          Text(
            PropertyHelpers.formatPrice(property.displayPrice!, context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(14),
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}

// ── Remove button ─────────────────────────────────────────────────────────────

class _RemoveButton extends StatelessWidget {
  final String propertyId;
  const _RemoveButton({required this.propertyId});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _confirmRemove(context),
    child: Container(
      width: context.r(30),
      height: context.r(30),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.favorite_rounded,
        color: Colors.redAccent,
        size: context.r(15),
      ),
    ),
  );

  void _confirmRemove(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FavoritesCubit>(),
        child: _RemoveConfirmSheet(propertyId: propertyId),
      ),
    );
  }
}

// ── Remove confirm sheet ──────────────────────────────────────────────────────

class _RemoveConfirmSheet extends StatelessWidget {
  final String propertyId;
  const _RemoveConfirmSheet({required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: context.r(40),
              height: context.r(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(context.r(4)),
              ),
            ),
          ),
          SizedBox(height: context.r(20)),

          // Icon
          Container(
            width: context.r(60),
            height: context.r(60),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              color: Colors.redAccent,
              size: context.r(28),
            ),
          ),
          SizedBox(height: context.r(16)),

          // Title
          Text(
            'favorites_remove_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(17),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(6)),
          Text(
            'favorites_remove_subtitle'.tr(context),
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: context.r(24)),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: context.rSymmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(14)),
                    ),
                  ),
                  child: Text(
                    'btn_cancel'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.r(12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<FavoritesCubit>().toggle(propertyId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: context.rSymmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(14)),
                    ),
                  ),
                  child: Text(
                    'favorites_btn_remove'.tr(context),
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
