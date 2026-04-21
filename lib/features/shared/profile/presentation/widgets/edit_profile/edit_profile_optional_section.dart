import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditProfileOptionalSection extends StatelessWidget {
  final TextEditingController nationalIdCtrl;
  final TextEditingController addressCtrl;
  final DateTime? dateOfBirth;
  final ValueChanged<DateTime> onDatePicked;

  const EditProfileOptionalSection({
    super.key,
    required this.nationalIdCtrl,
    required this.addressCtrl,
    required this.dateOfBirth,
    required this.onDatePicked,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(1995),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDatePicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_section_optional'.tr(context),
          style: GoogleFonts.cairo(
            fontSize: context.sp(14),
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: context.r(12)),

        // Date of birth tile
        GestureDetector(
          onTap: () => _pickDate(context),
          child: Container(
            padding: context.rSymmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(14)),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: AppColors.primary.withValues(alpha: 0.7),
                  size: context.r(20),
                ),
                SizedBox(width: context.r(12)),
                Expanded(
                  child: Text(
                    dateOfBirth != null
                        ? DateFormat('dd / MM / yyyy').format(dateOfBirth!)
                        : 'hint_dob'.tr(context),
                    style: GoogleFonts.tajawal(
                      fontSize: context.sp(14),
                      color: dateOfBirth != null
                          ? Colors.grey.shade800
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey.shade400,
                  size: context.r(16),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: context.r(14)),
        CustomTextField(
          controller: nationalIdCtrl,
          labelKey: 'profile_national_id_label',
          hintKey: 'hint_national_id',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
          ],
        ),
        SizedBox(height: context.r(14)),
        CustomTextField(
          controller: addressCtrl,
          labelKey: 'profile_address_label',
          hintKey: 'profile_address_hint',
          icon: Icons.home_outlined,
        ),
      ],
    );
  }
}
