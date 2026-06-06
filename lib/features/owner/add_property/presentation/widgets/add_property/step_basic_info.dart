// lib/features/owner/add_property/presentation/widgets/add_property/step_basic_info.dart
// ignore_for_file: deprecated_member_use

import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/location/data/egypt_locations.dart';
import 'package:aqar_hub/core/location/models/location_node.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/map/map_picker_screen.dart';
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
  State<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends State<StepBasicInfo> {
  // Internal slug state — these mirror the form slugs held by the parent.
  // We keep them in local state so we can update the pickers reactively
  // without waiting for a full rebuild from the parent.
  late String _gov;
  late String _city;
  late String _area;

  late final TextEditingController _addressCtrl;
  late final TextEditingController _locationLinkCtrl;

  @override
  void initState() {
    super.initState();
    _gov = widget.form.governorateSlug;
    _city = widget.form.citySlug;
    _area = widget.form.areaSlug;
    _addressCtrl = TextEditingController(text: widget.form.address);
    _locationLinkCtrl = TextEditingController(text: widget.form.locationLink);
  }

  @override
  void didUpdateWidget(StepBasicInfo old) {
    super.didUpdateWidget(old);
    // Sync text controllers when the parent pushes a new form (e.g. map pick).
    if (widget.form.address != _addressCtrl.text) {
      _addressCtrl.text = widget.form.address;
      _addressCtrl.selection =
          TextSelection.collapsed(offset: _addressCtrl.text.length);
    }
    final link = widget.form.locationLink;
    if (link != _locationLinkCtrl.text) {
      _locationLinkCtrl.text = link;
      _locationLinkCtrl.selection =
          TextSelection.collapsed(offset: _locationLinkCtrl.text.length);
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _locationLinkCtrl.dispose();
    super.dispose();
  }

  // ── Derived helpers ────────────────────────────────────────────────────────

  EgyptLocationNode? get _govNode =>
      EgyptLocations.findGovernorate(_gov.isEmpty ? null : _gov);

  List<EgyptLocationNode> get _cities =>
      EgyptLocations.citiesForGovernorate(_gov.isEmpty ? null : _gov);

  List<EgyptLocationNode> get _areas => EgyptLocations.areasForCity(
        governorateSlug: _gov.isEmpty ? null : _gov,
        citySlug: _city.isEmpty ? null : _city,
      );

  /// True when the minimum required location info is filled in.
  bool get _locationDone =>
      _gov.isNotEmpty && (_cities.isEmpty || _city.isNotEmpty);

  // ── Map picker ─────────────────────────────────────────────────────────────

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: widget.form.latitude,
          initialLng: widget.form.longitude,
        ),
      ),
    );
    if (result == null || !mounted) return;

    if (result.address.isNotEmpty) {
      _addressCtrl.text = result.address;
      _addressCtrl.selection =
          TextSelection.collapsed(offset: result.address.length);
    }
    _locationLinkCtrl.text = result.googleMapsUrl;
    _locationLinkCtrl.selection =
        TextSelection.collapsed(offset: result.googleMapsUrl.length);

    widget.onChanged(
      widget.form.copyWith(
        latitude: result.latitude,
        longitude: result.longitude,
        address:
            result.address.isNotEmpty ? result.address : widget.form.address,
        locationLink: result.googleMapsUrl,
      ),
    );
  }

  // ── Location pickers ───────────────────────────────────────────────────────

  void _pickGov() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _LocationSheet(
          title: 'addprop_select_governorate'.tr(context),
          items: EgyptLocations.governorates,
          selectedSlug: _gov.isEmpty ? null : _gov,
          onSelected: (node) {
            Navigator.pop(context);
            setState(() {
              _gov = node.slug;
              _city = '';
              _area = '';
            });
            widget.onChanged(
              widget.form.copyWith(
                governorateSlug: node.slug,
                citySlug: '',
                areaSlug: '',
              ),
            );
            // Auto-open city picker if cities exist.
            if (EgyptLocations.citiesForGovernorate(node.slug).isNotEmpty) {
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
        onSelected: (node) {
          Navigator.pop(context);
          setState(() {
            _city = node.slug;
            _area = '';
          });
          widget.onChanged(
            widget.form.copyWith(citySlug: node.slug, areaSlug: ''),
          );
          // Auto-open area picker if areas exist.
          final areas = EgyptLocations.areasForCity(
            governorateSlug: _gov,
            citySlug: node.slug,
          );
          if (areas.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 300), _pickArea);
          }
        },
      ),
    );
  }

  void _pickArea() {
    if (_areas.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationSheet(
        title: 'addprop_select_area'.tr(context),
        items: _areas,
        selectedSlug: _area.isEmpty ? null : _area,
        onSelected: (node) {
          Navigator.pop(context);
          setState(() => _area = node.slug);
          widget.onChanged(widget.form.copyWith(areaSlug: node.slug));
        },
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final govLabel =
        _govNode?.label(context) ?? 'addprop_select_governorate'.tr(context);

    final cityNode = EgyptLocations.findCity(
      governorateSlug: _gov,
      citySlug: _city,
    );
    final cityLabel = _city.isNotEmpty
        ? (cityNode?.label(context) ?? _city)
        : (_cities.isNotEmpty ? 'addprop_select_city'.tr(context) : null);

    final areaNode = EgyptLocations.findArea(
      governorateSlug: _gov,
      citySlug: _city,
      areaSlug: _area,
    );
    final areaLabel = _area.isNotEmpty
        ? (areaNode?.label(context) ?? _area)
        : (_areas.isNotEmpty ? 'addprop_select_area'.tr(context) : null);

    return stepScroll(
      context,
      Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ────────────────────────────────────────────────────
            StepAlertBanner(
              message: 'addprop_banner_basic'.tr(context),
              icon: Icons.home_work_outlined,
            ),

            // ── Title ─────────────────────────────────────────────────────
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

            // ── Location header ───────────────────────────────────────────
            Row(
              children: [
                SectionTitle('addprop_location'.tr(context)),
                SizedBox(width: context.r(6)),
                const RequiredBadge(),
              ],
            ),
            HintText('addprop_location_hint'.tr(context)),

            // Governorate picker
            _PickerTile(
              icon: Icons.location_city_rounded,
              label: govLabel,
              isSelected: _gov.isNotEmpty,
              onTap: _pickGov,
            ),

            // City picker — only shown when governorate is selected and
            // the governorate has cities.
            if (_gov.isNotEmpty && _cities.isNotEmpty) ...[
              SizedBox(height: context.r(10)),
              _PickerTile(
                icon: Icons.place_rounded,
                label: cityLabel ?? 'addprop_select_city'.tr(context),
                isSelected: _city.isNotEmpty,
                onTap: _pickCity,
              ),
            ],

            // Area picker — only shown when city is selected and the city
            // has sub-areas.
            if (_city.isNotEmpty && _areas.isNotEmpty) ...[
              SizedBox(height: context.r(10)),
              _PickerTile(
                icon: Icons.map_outlined,
                label: areaLabel ?? 'addprop_select_area'.tr(context),
                isSelected: _area.isNotEmpty,
                onTap: _pickArea,
              ),
            ],

            if (_locationDone) ...[
              SizedBox(height: context.r(8)),
              _LocationConfirmed(),
            ],
            SizedBox(height: context.r(24)),

            // ── Address ───────────────────────────────────────────────────
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
              controller: _addressCtrl,
              onChanged: (v) =>
                  widget.onChanged(widget.form.copyWith(address: v)),
            ),
            SizedBox(height: context.r(24)),

            // ── Map pin ───────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SectionTitle('addprop_pin_on_map'.tr(context)),
                          SizedBox(width: context.r(6)),
                          const OptionalBadge(),
                        ],
                      ),
                      Padding(
                        padding: context.rOnly(bottom: 10),
                        child: Text(
                          'addprop_pin_on_map_hint'.tr(context),
                          style: GoogleFonts.tajawal(
                            fontSize: context.sp(12),
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: context.r(12)),
                GestureDetector(
                  onTap: _openMapPicker,
                  child: Container(
                    width: context.r(56),
                    height: context.r(56),
                    decoration: BoxDecoration(
                      color: widget.form.latitude != null
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(context.r(16)),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(
                          widget.form.latitude != null ? 0 : 0.25,
                        ),
                      ),
                    ),
                    child: Icon(
                      widget.form.latitude != null
                          ? Icons.location_on_rounded
                          : Icons.add_location_alt_outlined,
                      size: context.r(26),
                      color: widget.form.latitude != null
                          ? Colors.white
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.form.latitude != null)
              _MapConfirmed(
                lat: widget.form.latitude!,
                lng: widget.form.longitude!,
                onClear: () =>
                    widget.onChanged(widget.form.copyWith(clearLatLng: true)),
                onEdit: _openMapPicker,
              ),
            SizedBox(height: context.r(24)),

            // ── Location link ─────────────────────────────────────────────
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
              controller: _locationLinkCtrl,
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final uri = Uri.tryParse(v.trim());
                final host = uri?.host.toLowerCase() ?? '';
                final path = uri?.path.toLowerCase() ?? '';
                final isValid = host == 'maps.google.com' ||
                    host == 'maps.google.com.eg' ||
                    (host == 'www.google.com' && path.startsWith('/maps')) ||
                    host == 'goo.gl' ||
                    host == 'maps.app.goo.gl';
                if (!isValid) {
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

// ── Location confirmed banner ─────────────────────────────────────────────────

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

// ── Map confirmed chip ────────────────────────────────────────────────────────

class _MapConfirmed extends StatelessWidget {
  final double lat;
  final double lng;
  final VoidCallback onClear;
  final VoidCallback onEdit;

  const _MapConfirmed({
    required this.lat,
    required this.lng,
    required this.onClear,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.rOnly(top: 8),
      padding: context.rAll(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: AppColors.primary.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: context.r(16),
          ),
          SizedBox(width: context.r(8)),
          Expanded(
            child: Text(
              'addprop_map_pin_set'.tr(context),
              style: GoogleFonts.tajawal(
                fontSize: context.sp(12),
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: context.rSymmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(context.r(8)),
              ),
              child: Text(
                'btn_edit'.tr(context),
                style: GoogleFonts.cairo(
                  fontSize: context.sp(11),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: context.r(6)),
          GestureDetector(
            onTap: onClear,
            child: Icon(
              Icons.close_rounded,
              size: context.r(16),
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Picker tile ───────────────────────────────────────────────────────────────

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
            color: isSelected
                ? AppColors.primary.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey.withOpacity(0.25),
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
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade600,
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

// ── Location bottom sheet ─────────────────────────────────────────────────────

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
                        padding:
                            context.rSymmetric(horizontal: 14, vertical: 13),
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
                              // ✅ label(context) → reads arName or enName
                              // based on the current locale.
                              // The slug is NEVER displayed to the user.
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
              SizedBox(
                height:
                    context.r(8) + MediaQuery.paddingOf(context).bottom,
              ),
            ],
          ),
        ),
      );
}
