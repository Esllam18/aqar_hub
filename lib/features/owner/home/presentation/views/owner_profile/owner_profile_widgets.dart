// lib/features/owner/home/presentation/views/owner_profile/owner_profile_widgets.dart
//
// Stats row, info card, property card, type badge, skeleton, error body.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Stats row ─────────────────────────────────────────────────────────────────

class OwnerProfileStatsRow extends StatelessWidget {
  final int propertiesCount;
  final String memberSince;
  final String? city;

  const OwnerProfileStatsRow({
    super.key,
    required this.propertiesCount,
    required this.memberSince,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rOnly(left: 16, right: 16, top: 4, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: context.r(16),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                icon: Icons.apartment_rounded,
                value: '$propertiesCount',
                label: 'owner_profile_listings'.tr(context),
                iconColor: AppColors.primary,
              ),
            ),
            _VertDivider(),
            Expanded(
              child: _StatCell(
                icon: Icons.calendar_today_rounded,
                value: memberSince,
                label: 'owner_profile_member_since'.tr(context),
                iconColor: const Color(0xFF059669),
              ),
            ),
            if ((city ?? '').isNotEmpty) ...[
              _VertDivider(),
              Expanded(
                child: _StatCell(
                  icon: Icons.location_city_rounded,
                  value: city!,
                  label: 'profile_city'.tr(context),
                  iconColor: const Color(0xFFD97706),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: context.r(50), color: Colors.grey.shade100);
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: context.rSymmetric(horizontal: 6, vertical: 14),
        child: Column(
          children: [
            Icon(icon, size: context.r(18), color: iconColor),
            SizedBox(height: context.r(4)),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: context.sp(13),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B2D5E),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(10),
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
}

// ── Info card (email + address) ───────────────────────────────────────────────

class OwnerProfileInfoCard extends StatelessWidget {
  final String? email;
  final String? address;
  const OwnerProfileInfoCard({super.key, this.email, this.address});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rOnly(left: 16, right: 16, top: 8, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.r(12),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            if ((email ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'owner_profile_email'.tr(context),
                value: email!,
                showDivider: (address ?? '').isNotEmpty,
              ),
            if ((address ?? '').isNotEmpty)
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'owner_profile_address'.tr(context),
                value: address!,
                showDivider: false,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: context.rOnly(left: 16, right: 16, top: 12, bottom: 12),
          child: Row(
            children: [
              Container(
                width: context.r(36),
                height: context.r(36),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Icon(icon, color: AppColors.primary, size: context.r(18)),
              ),
              SizedBox(width: context.r(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.tajawal(
                            fontSize: context.sp(10),
                            color: Colors.grey.shade500)),
                    Text(value,
                        style: GoogleFonts.tajawal(
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B2D5E))),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.shade100,
            indent: context.r(64),
          ),
      ],
    );
  }
}

// ── Property card (in profile listing) ───────────────────────────────────────

class OwnerProfilePropertyCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  const OwnerProfilePropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = property.firstImage != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: context.rOnly(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(14)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.r(12),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(context.r(14))),
              child: SizedBox(
                width: context.r(96),
                height: context.r(96),
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: property.firstImage!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(context),
                      )
                    : _placeholder(context),
              ),
            ),
            SizedBox(width: context.r(12)),
            Expanded(
              child: Padding(
                padding: context.rOnly(right: 14, top: 12, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B2D5E),
                      ),
                    ),
                    SizedBox(height: context.r(4)),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: context.r(11), color: Colors.grey.shade400),
                        SizedBox(width: context.r(3)),
                        Expanded(
                          child: Text(
                            property.city,
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
                    SizedBox(height: context.r(8)),
                    Row(
                      children: [
                        Text(
                          '${property.basePrice?.toStringAsFixed(0) ?? '—'} ${'currency'.tr(context)}',
                          style: GoogleFonts.cairo(
                            fontSize: context.sp(13),
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        _TypeBadge(property: property),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: AppColors.primary.withValues(alpha: 0.07),
        child: Center(
          child: Icon(
            Icons.apartment_rounded,
            color: AppColors.primary.withValues(alpha: 0.35),
            size: context.r(28),
          ),
        ),
      );
}

class _TypeBadge extends StatelessWidget {
  final PropertyModel property;
  const _TypeBadge({required this.property});

  @override
  Widget build(BuildContext context) {
    final isForSale = property.isForSale;
    return Container(
      padding: context.rSymmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isForSale
            ? Colors.orange.shade50
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.r(6)),
      ),
      child: Text(
        isForSale
            ? 'home_filter_sale'.tr(context)
            : 'home_filter_rent'.tr(context),
        style: GoogleFonts.cairo(
          fontSize: context.sp(10),
          fontWeight: FontWeight.w700,
          color: isForSale ? Colors.orange.shade700 : AppColors.primary,
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class OwnerProfileSkeleton extends StatelessWidget {
  const OwnerProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Column(
          children: [
            Container(height: context.r(310), color: const Color(0xFF1565C0)),
            Padding(
              padding: context.rAll(16),
              child: Column(
                children: List.generate(
                  4,
                  (i) => Container(
                    height: context.r(96),
                    margin: context.rOnly(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(context.r(14)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Error body ────────────────────────────────────────────────────────────────

class OwnerProfileErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const OwnerProfileErrorBody({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: Padding(
            padding: context.rAll(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: context.r(48), color: Colors.redAccent),
                SizedBox(height: context.r(12)),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(13),
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: context.r(20)),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('retry'.tr(context)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
