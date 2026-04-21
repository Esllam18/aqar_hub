// lib/.../add_property/step_specs.dart — Step 2: Rooms, beds, area, furnished

// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/home/data/models/add_property_form_model.dart';
import 'add_property_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class StepSpecs extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AddPropertyFormModel form;
  final ValueChanged<AddPropertyFormModel> onChanged;

  const StepSpecs({
    super.key,
    required this.formKey,
    required this.form,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => stepScroll(
    context,
    Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepAlertBanner(
            message: 'addprop_banner_specs'.tr(context),
            type: AlertBannerType.tip,
            icon: Icons.tune_rounded,
          ),
          SectionTitle('addprop_step_specs'.tr(context)),
          NumberChipSelector(
            label: 'stat_rooms'.tr(context),
            value: form.totalRooms,
            max: 10,
            onChanged: (v) => onChanged(form.copyWith(totalRooms: v)),
          ),
          NumberChipSelector(
            label: 'stat_beds'.tr(context),
            value: form.totalBeds,
            max: 20,
            onChanged: (v) => onChanged(form.copyWith(totalBeds: v)),
          ),
          NumberChipSelector(
            label: 'stat_bath'.tr(context),
            value: form.bathrooms,
            max: 8,
            onChanged: (v) => onChanged(form.copyWith(bathrooms: v)),
          ),
          Text(
            'stat_area'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(13),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: context.r(8)),
          inputField(
            context: context,
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            initialValue: form.areaM2?.toStringAsFixed(0),
            suffix: Padding(
              padding: context.rOnly(right: 12),
              child: Text(
                'm²',
                style: GoogleFonts.cairo(
                  fontSize: context.sp(13),
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            onChanged: (v) =>
                onChanged(form.copyWith(areaM2: double.tryParse(v))),
          ),
          SizedBox(height: context.r(20)),
          _FurnishedToggle(
            value: form.isFurnished,
            onChanged: (v) => onChanged(form.copyWith(isFurnished: v)),
          ),
        ],
      ),
    ),
  );
}

class _FurnishedToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _FurnishedToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    padding: context.rAll(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(context.r(14)),
      border: Border.all(color: Colors.grey.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.chair_outlined,
          size: context.r(20),
          color: Colors.grey.shade500,
        ),
        SizedBox(width: context.r(12)),
        Expanded(
          child: Text(
            value
                ? 'filter_furnished_yes'.tr(context)
                : 'filter_furnished_no'.tr(context),
            style: GoogleFonts.tajawal(
              fontSize: context.sp(14),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1B2D5E),
            ),
          ),
        ),
        Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}
