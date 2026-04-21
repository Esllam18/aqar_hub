// lib/features/owner/home/presentation/widgets/owner_home/owner_property_card.dart
//
// Orchestrator only — 1,075 lines → ~180 lines.
// All sub-widgets moved to property_card/property_card_widgets.dart.

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/house_seeker/home/helpers/property_helpers.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/owner_property_alert_banner.dart';
import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/property_card/property_card_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerPropertyCard extends StatelessWidget {
  final OwnerPropertyModel property;
  final int index;
  final Future<bool> Function(String propertyId, String description)
      onSaveDescription;
  final Future<bool> Function(String propertyId, bool isRented) onToggleRented;
  final Future<bool> Function(RentalOptionModel option, int availableQuantity)
      onUpdateAvailability;
  final Future<bool> Function(String propertyId) onDelete;
  final void Function(OwnerPropertyModel property)? onEdit;

  const OwnerPropertyCard({
    super.key,
    required this.property,
    required this.index,
    required this.onSaveDescription,
    required this.onToggleRented,
    required this.onUpdateAvailability,
    required this.onDelete,
    this.onEdit,
  });

  bool get _hasAlerts => property.alerts.any((a) => a.code != 'available');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.rOnly(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: context.r(24),
            offset: Offset(0, context.r(10)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeaderImage(property: property),
          Padding(
            padding: context.rAll(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardTopMetaRow(property: property),
                SizedBox(height: context.r(10)),
                Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF102048),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: context.r(8)),
                CardLocationRow(property: property),
                if (_hasAlerts) ...[
                  SizedBox(height: context.r(12)),
                  ...property.alerts
                      .where((a) => a.code != 'available')
                      .take(3)
                      .map((alert) => OwnerPropertyAlertBanner(alert: alert)),
                ],
                SizedBox(height: context.r(14)),
                Wrap(
                  spacing: context.r(8),
                  runSpacing: context.r(8),
                  children: [
                    if (property.totalRooms != null)
                      CardInfoChip(
                        icon: Icons.bed_outlined,
                        label: '${property.totalRooms} ${'statrooms'.tr(context)}',
                      ),
                    if (property.totalBeds != null)
                      CardInfoChip(
                        icon: Icons.single_bed_outlined,
                        label: '${property.totalBeds} ${'statbeds'.tr(context)}',
                      ),
                    if (property.areaM2 != null)
                      CardInfoChip(
                        icon: Icons.straighten_outlined,
                        label: '${property.areaM2!.toInt()} ${'statarea'.tr(context)}',
                      ),
                    CardInfoChip(
                      icon: Icons.people_outline_rounded,
                      label: PropertyHelpers.audienceLabel(
                          property.targetAudience, context),
                    ),
                    CardInfoChip(
                      icon: property.isForSale
                          ? Icons.sell_outlined
                          : Icons.home_work_outlined,
                      label: property.isForSale
                          ? 'homefiltersale'.tr(context)
                          : 'homefilterrent'.tr(context),
                    ),
                  ],
                ),
                if (property.rentalOptions.isNotEmpty) ...[
                  SizedBox(height: context.r(16)),
                  CardSectionTitle(
                      title: 'detailsrentaloptions'.tr(context)),
                  SizedBox(height: context.r(10)),
                  ...property.rentalOptions.map(
                    (option) => CardRentalOptionTile(
                      option: option,
                      onTap: () => _showAvailabilitySheet(context, option),
                    ),
                  ),
                ],
                SizedBox(height: context.r(16)),
                CardSectionTitle(
                    title: 'detailsdescription'.tr(context)),
                SizedBox(height: context.r(8)),
                Container(
                  width: double.infinity,
                  padding: context.rAll(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(context.r(16)),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    property.description.trim().isEmpty
                        ? '—'
                        : property.description,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(12.5),
                      color: const Color(0xFF475569),
                      height: 1.6,
                    ),
                  ),
                ),
                SizedBox(height: context.r(16)),
                // Edit button
                if (onEdit != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onEdit!(property),
                      icon: Icon(Icons.edit_rounded, size: context.r(18)),
                      label: Text('owner_edit_property'.tr(context)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: Size(double.infinity, context.r(46)),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(context.r(14)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.r(8)),
                ],
                // Secondary actions
                Row(
                  children: [
                    Expanded(
                      child: CardActionButton(
                        icon: Icons.edit_note_rounded,
                        label: 'owner_edit_description'.tr(context),
                        onTap: () => _showDescriptionSheet(context),
                      ),
                    ),
                    SizedBox(width: context.r(8)),
                    Expanded(
                      child: CardActionButton(
                        icon: property.isRented
                            ? Icons.lock_open_rounded
                            : Icons.lock_clock_rounded,
                        label: property.isRented
                            ? 'owner_mark_available'.tr(context)
                            : 'owner_mark_rented'.tr(context),
                        onTap: () => _toggleRented(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.r(8)),
                SizedBox(
                  width: double.infinity,
                  child: CardActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'owner_delete_property_title'.tr(context),
                    color: const Color(0xFFE53935),
                    fullWidth: true,
                    onTap: () => _confirmDelete(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sheets ──────────────────────────────────────────────────────────────────

  Future<void> _showDescriptionSheet(BuildContext context) async {
    final controller = TextEditingController(text: property.description);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CardModernSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CardSheetTitle(
                  title: 'owner_edit_description'.tr(context)),
              SizedBox(height: context.r(14)),
              TextField(
                controller: controller,
                minLines: 4,
                maxLines: 7,
                style: GoogleFonts.tajawal(fontSize: context.sp(13)),
                decoration: InputDecoration(
                  hintText: 'owner_write_description'.tr(context),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.r(16)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(context.r(16)),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: context.r(16)),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('btncancel'.tr(context)),
                  ),
                ),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await onSaveDescription(
                          property.id, controller.text.trim());
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _snack(context,
                          success: ok,
                          successMsg:
                              'owner_description_updated'.tr(context),
                          errorMsg:
                              'owner_description_update_failed'.tr(context));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0),
                    child: Text('btnsave'.tr(context)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleRented(BuildContext context) async {
    final target = !property.isRented;
    final ok = await onToggleRented(property.id, target);
    if (!context.mounted) return;
    _snack(context,
        success: ok,
        successMsg: target
            ? 'owner_status_rented_updated'.tr(context)
            : 'owner_status_available_updated'.tr(context),
        errorMsg: 'owner_status_update_failed'.tr(context));
  }

  Future<void> _showAvailabilitySheet(
      BuildContext context, RentalOptionModel option) async {
    int current = option.availableQuantity;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => CardModernSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CardSheetTitle(
                  title: 'owner_update_availability'.tr(context)),
              SizedBox(height: context.r(8)),
              Text(PropertyHelpers.rentalTypeLabel(option.type, context),
                  style: GoogleFonts.tajawal(
                      fontSize: context.sp(13),
                      color: Colors.grey.shade600)),
              SizedBox(height: context.r(18)),
              Container(
                padding: context.rAll(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(context.r(18)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CardCircleIconButton(
                      icon: Icons.remove,
                      onTap: current <= 0
                          ? null
                          : () => setState(() => current--),
                    ),
                    SizedBox(width: context.r(12)),
                    Container(
                      width: context.r(84),
                      height: context.r(56),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(context.r(16)),
                      ),
                      child: Text('$current',
                          style: GoogleFonts.cairo(
                              fontSize: context.sp(20),
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                    ),
                    SizedBox(width: context.r(12)),
                    CardCircleIconButton(
                      icon: Icons.add,
                      onTap: current >= option.totalQuantity
                          ? null
                          : () => setState(() => current++),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.r(10)),
              Text(
                  '${'owner_total_quantity'.tr(context)}: ${option.totalQuantity}',
                  style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade600)),
              SizedBox(height: context.r(18)),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('btncancel'.tr(context)),
                  ),
                ),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok =
                          await onUpdateAvailability(option, current);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      _snack(ctx,
                          success: ok,
                          successMsg:
                              'owner_availability_updated'.tr(context),
                          errorMsg:
                              'owner_availability_update_failed'.tr(context));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0),
                    child: Text('btnsave'.tr(context)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => CardModernSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.r(56),
              height: context.r(56),
              decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: Icon(Icons.delete_outline_rounded,
                  color: const Color(0xFFE53935), size: context.r(28)),
            ),
            SizedBox(height: context.r(14)),
            Text('owner_delete_property_title'.tr(context),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF102048))),
            SizedBox(height: context.r(8)),
            Text('owner_delete_property_subtitle'.tr(context),
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                    fontSize: context.sp(12.5),
                    color: Colors.grey.shade600,
                    height: 1.6)),
            SizedBox(height: context.r(18)),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('btncancel'.tr(context)),
                ),
              ),
              SizedBox(width: context.r(10)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await onDelete(property.id);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _snack(context,
                        success: ok,
                        successMsg: 'owner_property_deleted'.tr(context),
                        errorMsg:
                            'owner_property_delete_failed'.tr(context));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      elevation: 0),
                  child:
                      Text('owner_delete_property_title'.tr(context)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context,
      {required bool success,
      required String successMsg,
      required String errorMsg}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? AppColors.success : AppColors.error,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(14))),
        content: Text(success ? successMsg : errorMsg,
            style: GoogleFonts.tajawal(
                fontSize: context.sp(12),
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ));
  }
}
