// search_results_view.dart — Results list + result card + filter badge
// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/animations/app_animations.dart';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/data/models/property_model.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:aqar_hub/features/house_seeker/home/presentation/views/property_details_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_states_ui.dart';

class SearchResultsView extends StatelessWidget {
  final List<PropertyModel> properties;
  final String summaryAr, summaryEn;
  final ScrollController scrollCtrl;
  final VoidCallback onReset;

  const SearchResultsView({
    super.key,
    required this.properties,
    required this.summaryAr,
    required this.summaryEn,
    required this.scrollCtrl,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) return SearchEmptyResults(onReset: onReset);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final badge = isAr ? summaryAr : summaryEn;

    return ListView(
      controller: scrollCtrl,
      padding: context.rOnly(left: 16, right: 16, top: 16, bottom: 36),
      children: [
        AppAnimations.fade(
          duration: const Duration(milliseconds: 400),
          child: _FilterBadge(text: badge),
        ),
        SizedBox(height: context.r(14)),
        AppAnimations.fade(
          duration: const Duration(milliseconds: 400),
          delay: const Duration(milliseconds: 60),
          child: Padding(
            padding: context.rOnly(bottom: 12),
            child: Text(
              '${properties.length} ${properties.length == 1 ? 'search_result_singular'.tr(context) : 'search_result_plural'.tr(context)}',
              style: GoogleFonts.cairo(
                fontSize: context.sp(14),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B2D5E),
              ),
            ),
          ),
        ),
        ...properties.asMap().entries.map(
          (e) => AppAnimations.combined(
            type: CombineType.fadeSlide,
            duration: const Duration(milliseconds: 420),
            delay: Duration(milliseconds: 80 + e.key * 65),
            child: SearchResultCard(
              property: e.value,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PropertyDetailsView(property: e.value),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: context.r(6)),
        AppAnimations.fade(
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: 80 + properties.length * 65),
          child: Center(
            child: TextButton.icon(
              onPressed: onReset,
              icon: Icon(
                Icons.refresh_rounded,
                size: context.r(15),
                color: AppColors.primary.withOpacity(0.65),
              ),
              label: Text(
                'search_new'.tr(context),
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(13),
                  color: AppColors.primary.withOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterBadge extends StatelessWidget {
  final String text;
  const _FilterBadge({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: context.rSymmetric(horizontal: 16, vertical: 11),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(context.r(14)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: context.rAll(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          child: Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: context.r(14),
          ),
        ),
        SizedBox(width: context.r(10)),
        Expanded(
          child: Text(
            text.isEmpty ? 'search_all_props'.tr(context) : text,
            style: GoogleFonts.tajawal(
              fontSize: context.sp(12),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white.withOpacity(0.55),
          size: context.r(14),
        ),
      ],
    ),
  );
}

class SearchResultCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onTap;
  const SearchResultCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImg =
        property.imageUrls.isNotEmpty && property.imageUrls.first.isNotEmpty;
    final price = property.displayPrice;
    final (labelText, labelColor) = switch (property.priceLabel) {
      'offer' => ('🔥 ${'label_offer'.tr(context)}', const Color(0xFFF59E0B)),
      'verified' => (
        '✅ ${'label_verified'.tr(context)}',
        const Color(0xFF059669),
      ),
      'featured' => (
        '⭐ ${'label_featured'.tr(context)}',
        const Color(0xFF7C3AED),
      ),
      _ => (
        property.isForSale
            ? 'label_sale'.tr(context)
            : 'label_rent'.tr(context),
        AppColors.primary,
      ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: context.rOnly(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.07),
              blurRadius: context.r(16),
              offset: Offset(0, context.r(4)),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: context.r(175),
                  width: double.infinity,
                  child: hasImg
                      ? CachedNetworkImage(
                          imageUrl: property.imageUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: const Color(0xFFF0F1F5)),
                          errorWidget: (_, __, ___) => _Placeholder(),
                        )
                      : _Placeholder(),
                ),
                Positioned(
                  top: context.r(10),
                  right: context.r(10),
                  child: Container(
                    padding: context.rSymmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(context.r(10)),
                    ),
                    child: Text(
                      labelText,
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(11),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: context.rAll(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: context.sp(15),
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B2D5E),
                    ),
                  ),
                  SizedBox(height: context.r(4)),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: context.r(13),
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: context.r(3)),
                      Expanded(
                        child: Text(
                          PropertyHelpers.locationLabel(property),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (price != null) ...[
                    SizedBox(height: context.r(8)),
                    Text(
                      '${price.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')} ${'currency'.tr(context)}',
                      style: GoogleFonts.cairo(
                        fontSize: context.sp(17),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFF0F1F5),
    child: Icon(
      Icons.apartment_rounded,
      color: Colors.grey.shade300,
      size: context.r(50),
    ),
  );
}
