// lib/.../add_property/step_amenities.dart — Step 3: Amenities / Features

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'add_property_shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepAmenities extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AddPropertyFormModel form;
  final ValueChanged<AddPropertyFormModel> onChanged;

  const StepAmenities({
    super.key,
    required this.formKey,
    required this.form,
    required this.onChanged,
  });

  static const _amenities = {
    'amenity_wifi': Icons.wifi_rounded,
    'amenity_parking': Icons.local_parking_rounded,
    'amenity_elevator': Icons.elevator_rounded,
    'amenity_security': Icons.security_rounded,
    'amenity_gym': Icons.fitness_center_rounded,
    'amenity_pool': Icons.pool_rounded,
    'amenity_ac': Icons.ac_unit_rounded,
    'amenity_balcony': Icons.balcony_rounded,
    'amenity_garden': Icons.yard_rounded,
    'amenity_storage': Icons.inventory_2_rounded,
    'amenity_generator': Icons.bolt_rounded,
    'amenity_concierge': Icons.support_agent_rounded,
    'amenity_pets': Icons.pets_rounded,
    'amenity_laundry': Icons.local_laundry_service_rounded,
    'amenity_guard': Icons.shield_rounded,
    'amenity_cctv': Icons.videocam_rounded,
    'amenity_kitchen': Icons.kitchen_rounded,
    'amenity_water': Icons.water_drop_rounded,
    'amenity_near_mosque': Icons.mosque_rounded,
    'amenity_near_school': Icons.school_rounded,
    'amenity_near_hospital': Icons.local_hospital_rounded,
    'amenity_near_transport': Icons.directions_bus_rounded,
    'amenity_smart': Icons.devices_rounded,
    'amenity_solar': Icons.wb_sunny_rounded,
  };

  void _toggle(String key, List<String> current, AddPropertyFormModel form) {
    final list = List<String>.from(current);
    list.contains(key) ? list.remove(key) : list.add(key);
    onChanged(form.copyWith(amenities: list));
  }

  @override
  Widget build(BuildContext context) {
    final selected = form.amenities;
    return stepScroll(
      context,
      Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepAlertBanner(
              message: 'addprop_banner_amenities'.tr(context),
              type: AlertBannerType.tip,
              icon: Icons.star_outline_rounded,
            ),
            SectionTitle('addprop_step_amenities'.tr(context)),
            HintText('addprop_amenities_hint'.tr(context)),
            if (selected.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: context.r(16)),
                padding: context.rSymmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(context.r(8)),
                ),
                child: Text(
                  '${selected.length} ${'addprop_amenities_selected'.tr(context)}',
                  style: GoogleFonts.cairo(
                    fontSize: context.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: context.r(10),
                mainAxisSpacing: context.r(10),
                childAspectRatio: 3.0,
              ),
              itemCount: _amenities.length,
              itemBuilder: (ctx, i) {
                final key = _amenities.keys.elementAt(i);
                final icon = _amenities.values.elementAt(i);
                final active = selected.contains(key);
                return GestureDetector(
                  onTap: () => _toggle(key, selected, form),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: context.rSymmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(context.r(10)),
                      border: Border.all(
                        color: active
                            ? AppColors.primary
                            : Colors.grey.withOpacity(0.22),
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: context.r(6),
                                offset: Offset(0, context.r(2)),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: context.r(16),
                          color: active ? Colors.white : Colors.grey.shade500,
                        ),
                        SizedBox(width: context.r(6)),
                        Expanded(
                          child: Text(
                            key.tr(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.tajawal(
                              fontSize: context.sp(11.5),
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF1B2D5E),
                            ),
                          ),
                        ),
                        if (active)
                          Icon(
                            Icons.check_circle_rounded,
                            size: context.r(14),
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
