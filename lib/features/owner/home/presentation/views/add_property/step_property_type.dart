// lib/.../add_property/step_property_type.dart — Step 1: Property type

import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/features/owner/home/data/models/add_property_form_model.dart';
import 'add_property_shared.dart';
import 'package:flutter/material.dart';

class StepPropertyType extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AddPropertyFormModel form;
  final ValueChanged<AddPropertyFormModel> onChanged;

  const StepPropertyType({super.key, required this.formKey, required this.form, required this.onChanged});

  static const _types = ['apartment', 'villa', 'studio', 'penthouse', 'duplex', 'chalet'];
  static const _icons = {
    'apartment': '🏢', 'villa': '🏡', 'studio': '🏠',
    'penthouse': '🏙️', 'duplex': '🏘️', 'chalet': '⛺',
  };

  @override
  Widget build(BuildContext context) => stepScroll(context, Form(key: formKey,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      StepAlertBanner(message: 'addprop_banner_type'.tr(context), icon: Icons.category_outlined),
      SectionTitle('addprop_step_type'.tr(context)),
      HintText('addprop_type_hint'.tr(context)),
      ChipGroup<String>(
        values: _types,
        selected: form.propertyType,
        label: (ctx, v) => '${_icons[v] ?? ''} ${'propertytype_$v'.tr(ctx)}',
        onSelected: (v) => onChanged(form.copyWith(propertyType: v)),
      ),
    ])));
}
