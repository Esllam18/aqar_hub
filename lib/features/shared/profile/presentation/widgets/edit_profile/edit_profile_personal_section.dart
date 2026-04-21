import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePersonalSection extends StatelessWidget {
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController cityCtrl;
  final String? firstNameError;
  final String? lastNameError;
  final String? phoneError;
  final String? cityError;

  const EditProfilePersonalSection({
    super.key,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.phoneCtrl,
    required this.cityCtrl,
    this.firstNameError,
    this.lastNameError,
    this.phoneError,
    this.cityError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(labelKey: 'edit_section_personal'),
        SizedBox(height: context.r(12)),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: firstNameCtrl,
                labelKey: 'auth_first_name_label',
                hintKey: 'hint_first_name',
                icon: Icons.person_outline,
                errorText: firstNameError,
              ),
            ),
            SizedBox(width: context.r(12)),
            Expanded(
              child: CustomTextField(
                controller: lastNameCtrl,
                labelKey: 'auth_last_name_label',
                hintKey: 'hint_last_name',
                icon: Icons.person_outline,
                errorText: lastNameError,
              ),
            ),
          ],
        ),
        SizedBox(height: context.r(14)),
        CustomTextField(
          controller: phoneCtrl,
          labelKey: 'auth_phone_label',
          hintKey: 'hint_phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          errorText: phoneError,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
        ),
        SizedBox(height: context.r(14)),
        CustomTextField(
          controller: cityCtrl,
          labelKey: 'auth_city_label',
          hintKey: 'hint_city',
          icon: Icons.location_city_outlined,
          errorText: cityError,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String labelKey;
  const _SectionLabel({required this.labelKey});

  @override
  Widget build(BuildContext context) => Text(
    labelKey.tr(context),
    style: GoogleFonts.cairo(
      fontSize: context.sp(14),
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
    ),
  );
}
