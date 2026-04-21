// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OwnerHomeFilter { all, rent, sale, attention }

class OwnerFiltersBar extends StatelessWidget {
  final OwnerHomeFilter selected;
  final ValueChanged<OwnerHomeFilter> onChanged;

  const OwnerFiltersBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  String _label(BuildContext context, OwnerHomeFilter filter) {
    switch (filter) {
      case OwnerHomeFilter.all:
        return 'filterall'.tr(context);
      case OwnerHomeFilter.rent:
        return 'homefilterrent'.tr(context);
      case OwnerHomeFilter.sale:
        return 'homefiltersale'.tr(context);
      case OwnerHomeFilter.attention:
        return 'ownerfilteralerts'.tr(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.r(42),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: context.rSymmetric(horizontal: 8),
        itemCount: OwnerHomeFilter.values.length,
        separatorBuilder: (_, __) => SizedBox(width: context.r(8)),
        itemBuilder: (context, index) {
          final filter = OwnerHomeFilter.values[index];
          final isSelected = selected == filter;

          return InkWell(
            borderRadius: BorderRadius.circular(context.r(999)),
            onTap: () => onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: context.rSymmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(context.r(999)),
              ),
              child: Center(
                child: Text(
                  _label(context, filter),
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(11),
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
