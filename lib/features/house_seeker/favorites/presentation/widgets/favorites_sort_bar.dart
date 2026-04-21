import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/data/models/property_model.dart';

enum FavoritesSortOption { newest, priceLow, priceHigh }

class FavoritesSortBar extends StatelessWidget {
  final int count;
  final FavoritesSortOption selected;
  final ValueChanged<FavoritesSortOption> onChanged;

  const FavoritesSortBar({
    super.key,
    required this.count,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.rSymmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Count
          Text(
            '$count ${'favorites_count_label'.tr(context)}',
            style: GoogleFonts.cairo(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          const Spacer(),

          // Sort dropdown
          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: Container(
              padding: context.rSymmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(context.r(10)),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: context.r(14),
                    color: AppColors.primary,
                  ),
                  SizedBox(width: context.r(6)),
                  Text(
                    _labelForSort(selected, context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: context.r(4)),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: context.r(14),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _labelForSort(FavoritesSortOption opt, BuildContext context) =>
      switch (opt) {
        FavoritesSortOption.newest => 'sort_newest'.tr(context),
        FavoritesSortOption.priceLow => 'sort_price_low'.tr(context),
        FavoritesSortOption.priceHigh => 'sort_price_high'.tr(context),
      };

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        selected: selected,
        onSelect: (opt) {
          Navigator.of(context).pop();
          onChanged(opt);
        },
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final FavoritesSortOption selected;
  final ValueChanged<FavoritesSortOption> onSelect;

  const _SortSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.rOnly(
        left: 20,
        right: 20,
        top: 16,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          SizedBox(height: context.r(16)),
          Text(
            'sort_title'.tr(context),
            style: GoogleFonts.cairo(
              fontSize: context.sp(16),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B2D5E),
            ),
          ),
          SizedBox(height: context.r(12)),
          ...FavoritesSortOption.values.map(
            (opt) => _SortTile(
              option: opt,
              isSelected: selected == opt,
              onTap: () => onSelect(opt),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  final FavoritesSortOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  String _label(BuildContext context) => switch (option) {
    FavoritesSortOption.newest => 'sort_newest'.tr(context),
    FavoritesSortOption.priceLow => 'sort_price_low'.tr(context),
    FavoritesSortOption.priceHigh => 'sort_price_high'.tr(context),
  };

  IconData get _icon => switch (option) {
    FavoritesSortOption.newest => Icons.access_time_rounded,
    FavoritesSortOption.priceLow => Icons.arrow_downward_rounded,
    FavoritesSortOption.priceHigh => Icons.arrow_upward_rounded,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: context.rOnly(bottom: 8),
      padding: context.rAll(14),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _icon,
            size: context.r(18),
            color: isSelected ? AppColors.primary : Colors.grey.shade500,
          ),
          SizedBox(width: context.r(12)),
          Expanded(
            child: Text(
              _label(context),
              style: GoogleFonts.tajawal(
                fontSize: context.sp(14),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              size: context.r(18),
              color: AppColors.primary,
            ),
        ],
      ),
    ),
  );
}

// ── Sort helper ───────────────────────────────────────────────────────────────

abstract final class FavoritesSorter {
  static List<PropertyModel> sort(
    List<PropertyModel> list,
    FavoritesSortOption option,
  ) {
    final copy = List<PropertyModel>.from(list);
    switch (option) {
      case FavoritesSortOption.newest:
        copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case FavoritesSortOption.priceLow:
        copy.sort(
          (a, b) => (a.displayPrice ?? 0).compareTo(b.displayPrice ?? 0),
        );
      case FavoritesSortOption.priceHigh:
        copy.sort(
          (a, b) => (b.displayPrice ?? 0).compareTo(a.displayPrice ?? 0),
        );
    }
    return copy;
  }
}
