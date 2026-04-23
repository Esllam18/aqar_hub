// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/location/data/egypt_locations.dart';
import 'package:aqar_hub/core/location/models/location_node.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/add_property/data/models/add_property_form_model.dart';
import 'add_property_shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepBasicInfo extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final AddPropertyFormModel form;
  final ValueChanged<AddPropertyFormModel> onChanged;
  const StepBasicInfo({
    super.key,
    required this.formKey,
    required this.form,
    required this.onChanged,
  });
  @override
  State<StepBasicInfo> createState() => _State();
}

class _State extends State<StepBasicInfo> {
  late String _gov, _city;
  @override
  void initState() {
    super.initState();
    _gov = widget.form.governorateSlug;
    _city = widget.form.citySlug;
  }

  EgyptLocationNode? get _govNode =>
      EgyptLocations.findGovernorate(_gov.isEmpty ? null : _gov);
  List<EgyptLocationNode> get _cities =>
      EgyptLocations.citiesForGovernorate(_gov.isEmpty ? null : _gov);
  bool get _done => _gov.isNotEmpty && (_cities.isEmpty || _city.isNotEmpty);

  void _pickGov() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LocationSheet(
      title: 'addprop_select_governorate'.tr(context),
      items: EgyptLocations.governorates,
      selectedSlug: _gov.isEmpty ? null : _gov,
      onSelected: (n) {
        Navigator.pop(context);
        setState(() {
          _gov = n.slug;
          _city = '';
        });
        widget.onChanged(
          widget.form.copyWith(governorateSlug: n.slug, citySlug: ''),
        );
        if (EgyptLocations.citiesForGovernorate(n.slug).isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 300), _pickCity);
        }
      },
    ),
  );

  void _pickCity() {
    if (_cities.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationSheet(
        title: 'addprop_select_city'.tr(context),
        items: _cities,
        selectedSlug: _city.isEmpty ? null : _city,
        onSelected: (n) {
          Navigator.pop(context);
          setState(() => _city = n.slug);
          widget.onChanged(widget.form.copyWith(citySlug: n.slug));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final govLabel =
        _govNode?.label(context) ?? 'addprop_select_governorate'.tr(context);
    final cityLabel = _city.isNotEmpty
        ? (EgyptLocations.findCity(
                governorateSlug: _gov,
                citySlug: _city,
              )?.label(context) ??
              _city)
        : (_cities.isNotEmpty ? 'addprop_select_city'.tr(context) : null);

    return stepScroll(
      context,
      Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepAlertBanner(
              message: 'addprop_banner_basic'.tr(context),
              icon: Icons.home_work_outlined,
            ),
            SectionTitle('addprop_property_title'.tr(context)),
            inputField(
              context: context,
              hint: 'addprop_title_placeholder'.tr(context),
              initialValue: widget.form.title,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'addprop_required'.tr(context)
                  : null,
              onChanged: (v) =>
                  widget.onChanged(widget.form.copyWith(title: v)),
            ),
            SizedBox(height: context.r(24)),
            Row(
              children: [
                SectionTitle('addprop_location'.tr(context)),
                SizedBox(width: context.r(6)),
                const RequiredBadge(),
              ],
            ),
            HintText('addprop_location_hint'.tr(context)),
            _PickerTile(
              icon: Icons.location_city_rounded,
              label: govLabel,
              isSelected: _gov.isNotEmpty,
              onTap: _pickGov,
            ),
            if (_gov.isNotEmpty && _cities.isNotEmpty) ...[
              SizedBox(height: context.r(10)),
              _PickerTile(
                icon: Icons.place_rounded,
                label: cityLabel ?? 'addprop_select_city'.tr(context),
                isSelected: _city.isNotEmpty,
                onTap: _pickCity,
              ),
            ],
            if (_done) ...[
              SizedBox(height: context.r(8)),
              _LocationConfirmed(),
            ],
            SizedBox(height: context.r(24)),
            Row(
              children: [
                SectionTitle('addprop_address'.tr(context)),
                SizedBox(width: context.r(6)),
                const OptionalBadge(),
              ],
            ),
            inputField(
              context: context,
              hint: 'addprop_address_placeholder'.tr(context),
              initialValue: widget.form.address,
              onChanged: (v) =>
                  widget.onChanged(widget.form.copyWith(address: v)),
            ),
            SizedBox(height: context.r(24)),
            Row(
              children: [
                SectionTitle('addprop_location_link'.tr(context)),
                SizedBox(width: context.r(6)),
                const OptionalBadge(),
              ],
            ),
            HintText('addprop_location_link_hint'.tr(context)),
            inputField(
              context: context,
              hint: 'addprop_location_link_placeholder'.tr(context),
              initialValue: widget.form.locationLink,
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                // Accept only proper Google Maps domains, not any URL that
                // happens to contain the word "map" anywhere.
                final uri = Uri.tryParse(v.trim());
                final host = uri?.host.toLowerCase() ?? '';
                final path = uri?.path.toLowerCase() ?? '';
                final isValidGoogleMapsUrl =
                    host == 'maps.google.com' ||
                    host == 'maps.google.com.eg' ||
                    host == 'www.google.com' && path.startsWith('/maps') ||
                    host == 'goo.gl' ||
                    host == 'maps.app.goo.gl';
                if (!isValidGoogleMapsUrl) {
                  return 'addprop_location_link_invalid'.tr(context);
                }
                return null;
              },
              onChanged: (v) => widget.onChanged(
                widget.form.copyWith(
                  locationLink: v.trim().isEmpty ? null : v.trim(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationConfirmed extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: context.rAll(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF0FDF4),
      borderRadius: BorderRadius.circular(context.r(10)),
      border: Border.all(color: const Color(0xFFBBF7D0)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: const Color(0xFF059669),
          size: context.r(16),
        ),
        SizedBox(width: context.r(8)),
        Text(
          'addprop_location_set'.tr(context),
          style: GoogleFonts.tajawal(
            fontSize: context.sp(12),
            color: const Color(0xFF059669),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(context.r(12)),
    onTap: onTap,
    child: Container(
      padding: context.rSymmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: context.r(18),
            color: isSelected ? AppColors.primary : Colors.grey.shade500,
          ),
          SizedBox(width: context.r(10)),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: context.sp(13),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
          ),
          Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: context.r(18),
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
          ),
        ],
      ),
    ),
  );
}

class _LocationSheet extends StatelessWidget {
  final String title;
  final List<EgyptLocationNode> items;
  final String? selectedSlug;
  final ValueChanged<EgyptLocationNode> onSelected;
  const _LocationSheet({
    required this.title,
    required this.items,
    this.selectedSlug,
    required this.onSelected,
  });
  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: 0.75,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: context.r(12)),
          Container(
            width: context.r(40),
            height: context.r(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(context.r(4)),
            ),
          ),
          SizedBox(height: context.r(14)),
          Padding(
            padding: context.rSymmetric(horizontal: 18),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B2D5E),
                ),
              ),
            ),
          ),
          SizedBox(height: context.r(12)),
          Expanded(
            child: ListView.separated(
              padding: context.rSymmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: context.r(6)),
              itemBuilder: (_, i) {
                final item = items[i];
                final sel = item.slug == selectedSlug;
                return InkWell(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  onTap: () => onSelected(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: context.rSymmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(context.r(12)),
                      border: Border.all(
                        color: sel
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label(context),
                            style: GoogleFonts.tajawal(
                              fontSize: context.sp(14),
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: sel
                                  ? AppColors.primary
                                  : const Color(0xFF1B2D5E),
                            ),
                          ),
                        ),
                        if (sel)
                          Icon(
                            Icons.check_circle_rounded,
                            size: context.r(18),
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: context.r(8) + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    ),
  );
}
