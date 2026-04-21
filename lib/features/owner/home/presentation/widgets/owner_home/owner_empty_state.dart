// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/owner_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerEmptyState extends StatelessWidget {
  /// Called when user taps "Add Property". Pass null to hide the button.
  final VoidCallback? onAddTap;

  /// When true: the list is empty because of a filter, not because
  /// the owner has no properties. Different icon + message, no add button.
  final bool isFilterEmpty;

  /// Which filter produced the empty result (used for messaging).
  final OwnerHomeFilter? filterName;

  const OwnerEmptyState({
    super.key,
    this.onAddTap,
    this.isFilterEmpty = false,
    this.filterName,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isFilterEmpty
        ? Icons.filter_list_off_rounded
        : Icons.apartment_rounded;

    final title = isFilterEmpty
        ? 'owner_filter_empty_title'.tr(context)
        : 'owner_empty_title'.tr(context);

    final subtitle = isFilterEmpty
        ? 'owner_filter_empty_subtitle'.tr(context)
        : 'owner_empty_subtitle'.tr(context);

    return Center(
      child: SingleChildScrollView(
        padding: context.rSymmetric(horizontal: 26, vertical: 24),
        child: Container(
          width: double.infinity,
          padding: context.rAll(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: context.r(22),
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.r(96),
                height: context.r(96),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      AppColors.secondary.withOpacity(0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: context.r(44),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: context.r(20)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                ),
              ),
              SizedBox(height: context.r(8)),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: context.sp(13),
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              if (!isFilterEmpty && onAddTap != null) ...[
                SizedBox(height: context.r(22)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAddTap,
                    icon: const Icon(Icons.add_rounded),
                    label: Text('owner_add_property'.tr(context)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: Size(double.infinity, context.r(48)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.r(16)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
