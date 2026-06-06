// lib/features/owner/home/presentation/widgets/owner_home/edit_property_view.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:aqar_hub/core/location/data/egypt_locations.dart';
import 'package:aqar_hub/core/location/helper/location_display_helper.dart';
import 'package:aqar_hub/core/location/models/location_node.dart';
import 'package:aqar_hub/core/localization/app_localizations.dart';
import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:aqar_hub/features/owner/home/data/datasources/owner_properties_remote_datasource.dart';
import 'package:aqar_hub/features/owner/home/data/models/owner_property_model.dart';
import 'package:aqar_hub/features/owner/home/data/models/rental_option_model.dart';
import 'package:aqar_hub/features/owner/home/data/repositories/owner_properties_repository_impl.dart';
import 'package:aqar_hub/features/owner/edit_property/cubit/edit_property_cubit.dart';
import 'package:aqar_hub/features/owner/edit_property/cubit/edit_property_state.dart';
import 'package:aqar_hub/features/owner/edit_property/edit_property_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPropertyView extends StatelessWidget {
  final OwnerPropertyModel property;
  const EditPropertyView({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditPropertyCubit(
        repository: OwnerPropertiesRepositoryImpl(
          OwnerPropertiesRemoteDatasource(),
        ),
        original: property,
      ),
      child: _EditContent(property: property),
    );
  }
}

class _EditContent extends StatefulWidget {
  final OwnerPropertyModel property;
  const _EditContent({required this.property});

  @override
  State<_EditContent> createState() => _EditContentState();
}

class _EditContentState extends State<_EditContent> {
  final _formKey = GlobalKey<FormState>();
  final _picker   = ImagePicker();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _areaCtrl;

  // ── Location state — slugs only ───────────────────────────────────────────
  late String _governorateSlug;
  late String _citySlug;
  late String _areaSlug;

  late int?   _rooms, _beds, _baths;
  late bool   _furnished, _isRented;
  late String _listingType, _audience, _propType;
  late List<RentalOptionModel> _rentalOptions;
  late List<String> _keptUrls;
  final List<File> _newFiles = [];

  static const _roomOpts = [1, 2, 3, 4, 5, 6, 7, 8];
  static const _bedOpts  = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  static const _bathOpts = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _titleCtrl   = TextEditingController(text: p.title);
    _descCtrl    = TextEditingController(text: p.description);
    _addressCtrl = TextEditingController(text: p.address);
    _priceCtrl   = TextEditingController(text: p.basePrice?.toInt().toString() ?? '');
    _areaCtrl    = TextEditingController(text: p.areaM2?.toInt().toString() ?? '');
    _rooms       = p.totalRooms;
    _beds        = p.totalBeds;
    _baths       = p.bathrooms;
    _furnished   = p.isFurnished;
    _isRented    = p.isRented;
    _listingType = p.listingType;
    _audience    = p.targetAudience;
    _propType    = p.propertyType;
    _rentalOptions = List.from(p.rentalOptions);
    _keptUrls      = List.from(p.imageUrls);
    // Initialise location slugs from model
    _governorateSlug = p.governorateSlug ?? '';
    _citySlug        = p.citySlug        ?? '';
    _areaSlug        = p.areaSlug        ?? '';
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _addressCtrl, _priceCtrl, _areaCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Derived location helpers ───────────────────────────────────────────────

  List<EgyptLocationNode> get _cities =>
      EgyptLocations.citiesForGovernorate(_governorateSlug.isEmpty ? null : _governorateSlug);

  List<EgyptLocationNode> get _areas =>
      EgyptLocations.areasForCity(
        governorateSlug: _governorateSlug.isEmpty ? null : _governorateSlug,
        citySlug:        _citySlug.isEmpty        ? null : _citySlug,
      );

  // ── Pickers ───────────────────────────────────────────────────────────────

  void _pickGovernorate() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _LocationSheet(
          title: 'addprop_select_governorate'.tr(context),
          items: EgyptLocations.governorates,
          selectedSlug: _governorateSlug.isEmpty ? null : _governorateSlug,
          onSelected: (node) {
            Navigator.pop(context);
            setState(() {
              _governorateSlug = node.slug;
              _citySlug        = '';
              _areaSlug        = '';
            });
            final cities = EgyptLocations.citiesForGovernorate(node.slug);
            if (cities.isNotEmpty) {
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
        selectedSlug: _citySlug.isEmpty ? null : _citySlug,
        onSelected: (node) {
          Navigator.pop(context);
          setState(() {
            _citySlug = node.slug;
            _areaSlug = '';
          });
          final areas = EgyptLocations.areasForCity(
            governorateSlug: _governorateSlug,
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
        selectedSlug: _areaSlug.isEmpty ? null : _areaSlug,
        onSelected: (node) {
          Navigator.pop(context);
          setState(() => _areaSlug = node.slug);
        },
      ),
    );
  }

  // ── Image / submit ─────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() => _newFiles.addAll(picked.map((x) => File(x.path))));
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_governorateSlug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        content: Text('addprop_location_required'.tr(context),
            style: GoogleFonts.tajawal(color: Colors.white)),
      ));
      return;
    }
    context.read<EditPropertyCubit>().save(
      title:           _titleCtrl.text.trim(),
      description:     _descCtrl.text.trim(),
      address:         _addressCtrl.text.trim(),
      city:        _citySlug,
      totalRooms:      _rooms,
      totalBeds:       _beds,
      bathrooms:       _baths,
      areaM2:          double.tryParse(_areaCtrl.text),
      isFurnished:     _furnished,
      listingType:     _listingType,
      targetAudience:  _audience,
      propertyType:    _propType,
      basePrice:       double.tryParse(_priceCtrl.text),
      isRented:        _isRented,
      rentalOptions:   _rentalOptions,
      keptImageUrls:   _keptUrls,
      newImageFiles:   _newFiles,
    );
  }

  String _typeLabel(String t) => switch (t) {
        'villa'     => 'property_type_villa'.tr(context),
        'studio'    => 'property_type_studio'.tr(context),
        'penthouse' => 'property_type_penthouse'.tr(context),
        'duplex'    => 'property_type_duplex'.tr(context),
        'chalet'    => 'property_type_chalet'.tr(context),
        _           => 'propertytypeapartment'.tr(context),
      };

  String _audienceLabel(String v) => switch (v) {
        'male'   => 'audience_male'.tr(context),
        'female' => 'audience_female'.tr(context),
        'family' => 'audience_family'.tr(context),
        _        => 'audience_all'.tr(context),
      };

  @override
  Widget build(BuildContext context) {
    // ── Current location display label (localised, not slug) ─────────────
    final locationLabel = _governorateSlug.isEmpty
        ? 'addprop_select_governorate'.tr(context)
        : LocationDisplayHelper.locationLabel(
            context: context,
            governorateSlug: _governorateSlug,
            citySlug: _citySlug.isEmpty ? null : _citySlug,
            areaSlug: _areaSlug.isEmpty ? null : _areaSlug,
          );

    return BlocListener<EditPropertyCubit, EditPropertyState>(
      listener: (ctx, state) {
        if (state is EditPropertySuccess) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            content: Text('owner_property_updated'.tr(ctx),
                style: GoogleFonts.tajawal(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ));
          Navigator.pop(ctx, state.updatedProperty);
        } else if (state is EditPropertyError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            content: Text(state.message,
                style: GoogleFonts.tajawal(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'owner_edit_property'.tr(context),
            style: GoogleFonts.cairo(
                fontSize: context.sp(18),
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1B2D5E)),
          ),
          actions: [
            BlocBuilder<EditPropertyCubit, EditPropertyState>(
              builder: (ctx, state) {
                final loading = state is EditPropertyLoading;
                return Padding(
                  padding: context.rOnly(right: 12),
                  child: TextButton(
                    onPressed: loading ? null : _submit,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          context.rSymmetric(horizontal: 16, vertical: 8),
                    ),
                    child: loading
                        ? SizedBox(
                            width: context.r(16),
                            height: context.r(16),
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('btnsave'.tr(context),
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800)),
                  ),
                );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: context.rOnly(left: 16, right: 16, top: 8, bottom: 100),
            children: [
              EditStatusBanner(isRented: _isRented),
              SizedBox(height: context.r(16)),

              // ── Photos ────────────────────────────────────────────────
              EditSectionCard(
                title: 'addprop_photos'.tr(context),
                icon: Icons.photo_library_outlined,
                children: [
                  EditImageEditorGrid(
                    keptUrls: _keptUrls,
                    newFiles: _newFiles,
                    onRemoveExisting: (i) =>
                        setState(() => _keptUrls.removeAt(i)),
                    onRemoveNew: (i) =>
                        setState(() => _newFiles.removeAt(i)),
                    onAdd: _pickImages,
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Basic info ────────────────────────────────────────────
              EditSectionCard(
                title: 'owner_section_basic_info'.tr(context),
                icon: Icons.info_outline_rounded,
                children: [
                  EditField(
                    controller: _titleCtrl,
                    label: 'addprop_title'.tr(context),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'addprop_required'.tr(context)
                        : null,
                  ),
                  SizedBox(height: context.r(12)),
                  EditField(
                    controller: _addressCtrl,
                    label: 'addprop_address'.tr(context),
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Location pickers (slugs — NOT a text field) ───────────
              EditSectionCard(
                title: 'addprop_location'.tr(context),
                icon: Icons.location_on_outlined,
                children: [
                  // Current selection display
                  if (_governorateSlug.isNotEmpty)
                    Padding(
                      padding: context.rOnly(bottom: 10),
                      child: Container(
                        padding: context.rAll(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius:
                              BorderRadius.circular(context.r(10)),
                          border:
                              Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: const Color(0xFF059669),
                                size: context.r(16)),
                            SizedBox(width: context.r(8)),
                            Expanded(
                              child: Text(
                                locationLabel,
                                style: GoogleFonts.tajawal(
                                    fontSize: context.sp(13),
                                    color: const Color(0xFF059669),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Governorate picker tile
                  _PickerTile(
                    icon: Icons.location_city_rounded,
                    label: _governorateSlug.isEmpty
                        ? 'addprop_select_governorate'.tr(context)
                        : (EgyptLocations.findGovernorate(_governorateSlug)
                                ?.label(context) ??
                            _governorateSlug),
                    isSelected: _governorateSlug.isNotEmpty,
                    onTap: _pickGovernorate,
                  ),

                  // City picker tile — only when gov is chosen and has cities
                  if (_governorateSlug.isNotEmpty && _cities.isNotEmpty) ...[
                    SizedBox(height: context.r(10)),
                    _PickerTile(
                      icon: Icons.place_rounded,
                      label: _citySlug.isEmpty
                          ? 'addprop_select_city'.tr(context)
                          : (EgyptLocations.findCity(
                                    governorateSlug: _governorateSlug,
                                    citySlug: _citySlug,
                                  )?.label(context) ??
                              _citySlug),
                      isSelected: _citySlug.isNotEmpty,
                      onTap: _pickCity,
                    ),
                  ],

                  // Area picker tile — only when city is chosen and has areas
                  if (_citySlug.isNotEmpty && _areas.isNotEmpty) ...[
                    SizedBox(height: context.r(10)),
                    _PickerTile(
                      icon: Icons.map_outlined,
                      label: _areaSlug.isEmpty
                          ? 'addprop_select_area'.tr(context)
                          : (EgyptLocations.findArea(
                                    governorateSlug: _governorateSlug,
                                    citySlug: _citySlug,
                                    areaSlug: _areaSlug,
                                  )?.label(context) ??
                              _areaSlug),
                      isSelected: _areaSlug.isNotEmpty,
                      onTap: _pickArea,
                    ),
                  ],
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Property type ─────────────────────────────────────────
              EditSectionCard(
                title: 'owner_section_property_type'.tr(context),
                icon: Icons.apartment_rounded,
                children: [
                  EditChipSelector<String>(
                    label: 'addprop_property_type'.tr(context),
                    options: const [
                      'apartment', 'villa', 'studio',
                      'penthouse', 'duplex', 'chalet',
                    ],
                    selected: _propType,
                    labelBuilder: _typeLabel,
                    onChanged: (v) => setState(() => _propType = v),
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Specs ─────────────────────────────────────────────────
              EditSectionCard(
                title: 'owner_section_specs'.tr(context),
                icon: Icons.straighten_rounded,
                children: [
                  EditNumberChipSelector(
                    label: 'addprop_rooms'.tr(context),
                    options: _roomOpts,
                    selected: _rooms,
                    onChanged: (v) => setState(() => _rooms = v),
                  ),
                  SizedBox(height: context.r(12)),
                  EditNumberChipSelector(
                    label: 'addprop_beds'.tr(context),
                    options: _bedOpts,
                    selected: _beds,
                    onChanged: (v) => setState(() => _beds = v),
                  ),
                  SizedBox(height: context.r(12)),
                  EditNumberChipSelector(
                    label: 'addprop_bathrooms'.tr(context),
                    options: _bathOpts,
                    selected: _baths,
                    onChanged: (v) => setState(() => _baths = v),
                  ),
                  SizedBox(height: context.r(12)),
                  EditField(
                    controller: _areaCtrl,
                    label: 'addprop_area'.tr(context),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffix: 'm²',
                  ),
                  SizedBox(height: context.r(12)),
                  EditToggleRow(
                    label: 'addprop_furnished'.tr(context),
                    value: _furnished,
                    onChanged: (v) => setState(() => _furnished = v),
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Listing type ──────────────────────────────────────────
              EditSectionCard(
                title: 'owner_section_listing'.tr(context),
                icon: Icons.sell_outlined,
                children: [
                  EditChipSelector<String>(
                    label: 'addprop_listing_type'.tr(context),
                    options: const ['rent', 'sale'],
                    selected: _listingType,
                    labelBuilder: (v) => v == 'rent'
                        ? 'homefilterrent'.tr(context)
                        : 'homefiltersale'.tr(context),
                    onChanged: (v) => setState(() => _listingType = v),
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Target audience ───────────────────────────────────────
              EditSectionCard(
                title: 'owner_section_audience'.tr(context),
                icon: Icons.people_outline_rounded,
                children: [
                  EditChipSelector<String>(
                    label: 'addprop_target_audience'.tr(context),
                    options: const ['all', 'male', 'female', 'family'],
                    selected: _audience,
                    labelBuilder: _audienceLabel,
                    onChanged: (v) => setState(() => _audience = v),
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Price ─────────────────────────────────────────────────
              EditSectionCard(
                title: 'owner_section_price'.tr(context),
                icon: Icons.attach_money_rounded,
                children: [
                  EditField(
                    controller: _priceCtrl,
                    label: 'addprop_price'.tr(context),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffix: 'currency'.tr(context),
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Rental options ────────────────────────────────────────
              if (_listingType == 'rent') ...[
                _RentalOptionsEditor(
                  options: _rentalOptions,
                  onChanged: (opts) =>
                      setState(() => _rentalOptions = opts),
                ),
                SizedBox(height: context.r(12)),
              ],

              // ── Description ───────────────────────────────────────────
              EditSectionCard(
                title: 'detailsdescription'.tr(context),
                icon: Icons.description_outlined,
                children: [
                  EditField(
                    controller: _descCtrl,
                    label: 'addprop_description'.tr(context),
                    minLines: 4,
                    maxLines: 8,
                  ),
                ],
              ),
              SizedBox(height: context.r(12)),

              // ── Status ────────────────────────────────────────────────
              EditSectionCard(
                title: 'owner_section_status'.tr(context),
                icon: Icons.lock_clock_rounded,
                children: [
                  EditToggleRow(
                    label: 'owner_mark_rented'.tr(context),
                    value: _isRented,
                    onChanged: (v) => setState(() => _isRented = v),
                    activeColor: AppColors.error,
                  ),
                  if (_isRented)
                    Padding(
                      padding: context.rOnly(top: 10),
                      child: EditAlertBanner(
                        message: 'owner_rented_alert'.tr(context),
                        color: AppColors.error,
                        icon: Icons.lock_rounded,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
              Icon(icon,
                  size: context.r(18),
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.shade500),
              SizedBox(width: context.r(10)),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.tajawal(
                    fontSize: context.sp(13),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
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
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.shade400,
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
                top: Radius.circular(context.r(24))),
          ),
          child: Column(
            children: [
              SizedBox(height: context.r(12)),
              Container(
                width: context.r(40),
                height: context.r(4),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(context.r(4))),
              ),
              SizedBox(height: context.r(14)),
              Padding(
                padding: context.rSymmetric(horizontal: 18),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(title,
                      style: GoogleFonts.cairo(
                          fontSize: context.sp(17),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B2D5E))),
                ),
              ),
              SizedBox(height: context.r(12)),
              Expanded(
                child: ListView.separated(
                  padding: context.rSymmetric(horizontal: 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: context.r(6)),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final sel = item.slug == selectedSlug;
                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(context.r(12)),
                      onTap: () => onSelected(item),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: context.rSymmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary.withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(context.r(12)),
                          border: Border.all(
                            color: sel
                                ? AppColors.primary.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              // label(context) → reads arName or enName
                              // based on current locale.
                              // Slug is NEVER displayed.
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
                              Icon(Icons.check_circle_rounded,
                                  size: context.r(18),
                                  color: AppColors.primary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                  height: context.r(8) +
                      MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      );
}

// ── Rental options editor (unchanged) ────────────────────────────────────────

class _RentalOptionsEditor extends StatelessWidget {
  final List<RentalOptionModel> options;
  final void Function(List<RentalOptionModel>) onChanged;
  const _RentalOptionsEditor(
      {required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return EditSectionCard(
      title: 'addprop_rental_options'.tr(context),
      icon: Icons.calendar_month_outlined,
      children: [
        ...options.asMap().entries.map((e) {
          final i   = e.key;
          final opt = e.value;
          return Padding(
            padding: context.rOnly(bottom: 8),
            child: _OptionTile(
              option: opt,
              onEdit: () async {
                final updated =
                    await showModalBottomSheet<RentalOptionModel>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _RentalOptionSheet(option: opt),
                );
                if (updated != null) {
                  final list = List<RentalOptionModel>.from(options);
                  list[i] = updated;
                  onChanged(list);
                }
              },
              onDelete: () {
                final list = List<RentalOptionModel>.from(options);
                list.removeAt(i);
                onChanged(list);
              },
            ),
          );
        }),
        TextButton.icon(
          onPressed: () async {
            final added =
                await showModalBottomSheet<RentalOptionModel>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _RentalOptionSheet(),
            );
            if (added != null) onChanged([...options, added]);
          },
          icon: const Icon(Icons.add_rounded),
          label: Text('addprop_add_rental_option'.tr(context)),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final RentalOptionModel option;
  final VoidCallback onEdit, onDelete;
  const _OptionTile(
      {required this.option, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (option.type) {
      'daily'   => 'rental_daily'.tr(context),
      'weekly'  => 'rental_weekly'.tr(context),
      'monthly' => 'rental_monthly'.tr(context),
      _         => 'rental_yearly'.tr(context),
    };
    return Container(
      padding: context.rAll(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(typeLabel,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: context.sp(13),
                        color: const Color(0xFF1B2D5E))),
                Text(
                  '${option.price.toInt()} ${'currency'.tr(context)} · '
                  '${option.totalQuantity} ${'addprop_units'.tr(context)}',
                  style: GoogleFonts.tajawal(
                      fontSize: context.sp(12),
                      color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined,
                size: context.r(18), color: AppColors.primary),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded,
                size: context.r(18), color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _RentalOptionSheet extends StatefulWidget {
  final RentalOptionModel? option;
  const _RentalOptionSheet({this.option});
  @override
  State<_RentalOptionSheet> createState() => _RentalOptionSheetState();
}

class _RentalOptionSheetState extends State<_RentalOptionSheet> {
  late String _type;
  late TextEditingController _priceCtrl, _qtyCtrl, _availCtrl;

  @override
  void initState() {
    super.initState();
    _type      = widget.option?.type ?? 'monthly';
    _priceCtrl = TextEditingController(
        text: widget.option?.price.toInt().toString() ?? '');
    _qtyCtrl   = TextEditingController(
        text: widget.option?.totalQuantity.toString() ?? '1');
    _availCtrl = TextEditingController(
        text: widget.option?.availableQuantity.toString() ?? '1');
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _availCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(context.r(24))),
        ),
        padding: context.rAll(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('addprop_rental_option'.tr(context),
                style: GoogleFonts.cairo(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.w800)),
            SizedBox(height: context.r(16)),
            EditChipSelector<String>(
              label: 'addprop_rental_type'.tr(context),
              options: const ['daily', 'weekly', 'monthly', 'yearly'],
              selected: _type,
              labelBuilder: (v) => switch (v) {
                'daily'   => 'rental_daily'.tr(context),
                'weekly'  => 'rental_weekly'.tr(context),
                'monthly' => 'rental_monthly'.tr(context),
                _         => 'rental_yearly'.tr(context),
              },
              onChanged: (v) => setState(() => _type = v),
            ),
            SizedBox(height: context.r(12)),
            Row(
              children: [
                Expanded(
                  child: EditField(
                    controller: _priceCtrl,
                    label: 'addprop_price'.tr(context),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
                SizedBox(width: context.r(10)),
                Expanded(
                  child: EditField(
                    controller: _qtyCtrl,
                    label: 'addprop_units'.tr(context),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.r(12)),
            EditField(
              controller: _availCtrl,
              label: 'addprop_available'.tr(context),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: context.r(20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    RentalOptionModel(
                      id: widget.option?.id ?? '',
                      type: _type,
                      price: double.tryParse(_priceCtrl.text) ?? 0,
                      totalQuantity:
                          int.tryParse(_qtyCtrl.text) ?? 1,
                      availableQuantity:
                          int.tryParse(_availCtrl.text) ?? 1,
                      propertyId: widget.option?.propertyId ??
                          Supabase.instance.client.auth.currentUser
                              ?.id ??
                          '',
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(context.r(14))),
                  padding: context.rSymmetric(vertical: 14),
                ),
                child: Text('btnsave'.tr(context),
                    style:
                        GoogleFonts.cairo(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
