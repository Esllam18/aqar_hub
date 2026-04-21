import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/rental_option_model.dart';
import '../../../helpers/property_helpers.dart';

class DetailsRentalOptions extends StatelessWidget {
  final List<RentalOptionModel> options;

  const DetailsRentalOptions({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details_rental_options'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(15),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2D5E),
          ),
        ),
        SizedBox(height: context.r(10)),
        ...options.map(
          (o) => Padding(
            padding: context.rOnly(bottom: 10),
            child: _RentalOptionTile(option: o),
          ),
        ),
      ],
    );
  }
}

class _RentalOptionTile extends StatelessWidget {
  final RentalOptionModel option;

  const _RentalOptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    final isBooked = option.isFullyBooked;
    final isLimited = option.isLimited;

    final Color accent = isBooked
        ? Colors.grey.shade400
        : isLimited
        ? Colors.orange
        : AppColors.primary;

    final Color availabilityColor = isBooked
        ? Colors.grey.shade400
        : isLimited
        ? Colors.orange
        : const Color(0xFF43A047);

    return Container(
      padding: context.rAll(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(
          color: isBooked
              ? Colors.grey.withValues(alpha: 0.18)
              : accent.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: context.r(12),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: context.r(44),
            height: context.r(44),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Icon(
              _iconForType(option.type),
              size: context.r(20),
              color: accent,
            ),
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PropertyHelpers.rentalTypeLabel(option.type, context),
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(13),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B2D5E),
                  ),
                ),
                SizedBox(height: context.r(4)),
                Text(
                  _availabilityText(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.w700,
                    color: availabilityColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.r(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${option.price.toInt()} ${'currency'.tr(context)}',
                style: GoogleFonts.cairo(
                  fontSize: context.sp(14),
                  fontWeight: FontWeight.w900,
                  color: isBooked ? Colors.grey.shade400 : AppColors.primary,
                ),
              ),
              if (!isBooked)
                Text(
                  _priceUnit(context),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(10),
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _availabilityText(BuildContext context) {
    if (option.isFullyBooked) {
      return 'option_fully_booked'.tr(context);
    }
    if (option.isLimited) {
      return '${'option_limited'.tr(context)} (${option.availableQuantity})';
    }
    return '${option.availableQuantity}/${option.totalQuantity} ${'option_available'.tr(context)}';
  }

  String _priceUnit(BuildContext context) {
    switch (option.type) {
      case 'bed':
        return '/ bed';
      case 'room':
        return '/ room';
      default:
        return '/ unit';
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'bed':
        return Icons.single_bed_outlined;
      case 'room':
        return Icons.bed_outlined;
      default:
        return Icons.apartment_outlined;
    }
  }
}
