// lib/.../add_property/step_listing_type.dart — Step 4: Listing + Audience

import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/home/data/models/add_property_form_model.dart';
import 'add_property_shared.dart';
import 'package:flutter/material.dart';

class StepListingType extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AddPropertyFormModel form;
  final ValueChanged<AddPropertyFormModel> onChanged;

  const StepListingType({super.key, required this.formKey, required this.form, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isRent = form.listingType == 'rent';
    return stepScroll(context, Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      StepAlertBanner(
        message: isRent ? 'addprop_banner_listing_rent'.tr(context) : 'addprop_banner_listing_sale'.tr(context),
        type: isRent ? AlertBannerType.info : AlertBannerType.tip,
        icon: isRent ? Icons.vpn_key_outlined : Icons.sell_outlined),
      SectionTitle('addprop_listing_type'.tr(context)),
      ChipGroup<String>(
        values: const ['rent', 'sale'],
        selected: form.listingType,
        label: (ctx, v) => v == 'rent' ? '🔑 ${'homefilterrent'.tr(ctx)}' : '🏷️ ${'homefiltersale'.tr(ctx)}',
        onSelected: (v) => onChanged(form.copyWith(listingType: v))),
      if (isRent) ...[
        SizedBox(height: context.r(24)),
        SectionTitle('addprop_target_audience'.tr(context)),
        HintText('addprop_audience_hint'.tr(context)),
        ChipGroup<String>(
          values: const ['all', 'male', 'female', 'family'],
          selected: form.targetAudience,
          label: (ctx, v) {
            const icons = {'all': '👥', 'male': '👨', 'female': '👩', 'family': '👨‍👩‍👧'};
            return '${icons[v]} ${'audience_$v'.tr(ctx)}';
          },
          onSelected: (v) => onChanged(form.copyWith(targetAudience: v))),
      ],
    ])));
  }
}
