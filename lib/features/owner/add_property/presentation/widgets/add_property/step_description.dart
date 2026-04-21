// lib/.../add_property/step_description.dart — Step 7: Description + AI check

import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'package:aqar_hub/features/owner/add_property/presentation/widgets/ai_price_check_widget.dart';
import 'add_property_shared.dart';
import 'package:flutter/material.dart';

class StepDescription extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AddPropertyFormModel form;
  final ValueChanged<AddPropertyFormModel> onChanged;

  const StepDescription({
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
            message: 'addprop_banner_description'.tr(context),
            type: AlertBannerType.success,
            icon: Icons.rocket_launch_outlined,
          ),
          SectionTitle('addprop_step_description'.tr(context)),
          HintText('addprop_description_hint'.tr(context)),
          inputField(
            context: context,
            hint: 'addprop_description_placeholder'.tr(context),
            initialValue: form.description,
            maxLines: 5,
            onChanged: (v) => onChanged(form.copyWith(description: v)),
          ),
          SizedBox(height: context.r(28)),
          AiPriceCheckWidget(
            form: form,
            onResult: (r) => onChanged(form.copyWith(aiPriceResult: r)),
          ),
        ],
      ),
    ),
  );
}
