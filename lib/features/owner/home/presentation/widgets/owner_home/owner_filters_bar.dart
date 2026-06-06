// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum OwnerHomeFilter { all, rent, sale, notificationsAndComments }

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
      case OwnerHomeFilter.notificationsAndComments:
        return 'owner_filter_notif_comments'.tr(context);
    }
  }

  IconData _icon(OwnerHomeFilter filter) {
    switch (filter) {
      case OwnerHomeFilter.all:
        return Icons.grid_view_rounded;
      case OwnerHomeFilter.rent:
        return Icons.home_work_outlined;
      case OwnerHomeFilter.sale:
        return Icons.sell_outlined;
      case OwnerHomeFilter.notificationsAndComments:
        return Icons.notifications_active_rounded;
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
        separatorBuilder: (_, __) => SizedBox(width: context.r(6)),
        itemBuilder: (context, index) {
          final filter = OwnerHomeFilter.values[index];
          final isSelected = selected == filter;

          return InkWell(
            borderRadius: BorderRadius.circular(context.r(999)),
            onTap: () => onChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: context.rSymmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(context.r(999)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _icon(filter),
                    size: context.r(13),
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  SizedBox(width: context.r(5)),
                  Text(
                    _label(context, filter),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
